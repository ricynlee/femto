`include "timescale.vh"
`include "simpaths.vh"

module simtop #(
    parameter NOR_TYPE = "spi", // spi, qspi
    parameter HEX_PATH = `HEX_PATH
);

    reg clk = 0;
    initial forever #41.667 clk<=~clk;

    wire [3:0] led;
    wire uart_rxd, uart_txd;
    wire fault;

    wire nor_sck;
    wire nor_csb;
    wire [3:0] nor_sio;
    generate
        if(NOR_TYPE=="spi") begin
            spinor norflash(
                .sck(nor_sck),
                .csb(nor_csb),
                .si(nor_sio[0]),
                .so(nor_sio[1])
            );
            initial $readmemh({HEX_PATH, "nor-init.hex"}, norflash.array);
        end else begin
            qspinor norflash(
                .sck(nor_sck),
                .csb(nor_csb),
                .dio(nor_sio)
            );
            initial $readmemh({HEX_PATH, "nor-init.hex"}, norflash.array);
        end
    endgenerate

    sram sram();
    initial $readmemh({HEX_PATH, "sram-init.hex"}, sram.array);

    top top(
        .sysclk     (clk             ),
        .sysrst     (1'b0            ),
        .fault      (fault           ),
        .gpio       (led             ),
        .uart_tx    (uart_txd   ),
        .uart_rx    (uart_rxd   ),
        .sram_ce_bar(sram.sram_ce_bar),
        .sram_oe_bar(sram.sram_oe_bar),
        .sram_we_bar(sram.sram_we_bar),
        .sram_data  (sram.sram_data  ),
        .sram_addr  (sram.sram_addr  ),
        .qspi_sck   (nor_sck),
        .qspi_csb   (nor_csb),
        .qspi_data  (nor_sio)
    );

    uart_host uart_host(
        .dut_uart_rxd(uart_rxd),
        .dut_uart_txd(uart_txd)
    );
endmodule

module sram(
    input wire         sram_ce_bar,
    input wire         sram_oe_bar,
    input wire         sram_we_bar,
    inout wire  [7:0]  sram_data  ,
    input wire [18:0]  sram_addr
);
    reg [7:0] array[0:(1<<19)-1];

    reg [7:0] sram_data_out;
    wire [7:0] sram_data_in;

    assign sram_data = (sram_oe_bar | ~sram_we_bar) ? 8'hzz : sram_data_out;
    assign sram_data_in = sram_we_bar ? 8'hxx : sram_data;

    always @ (*) begin
        if (sram_ce_bar==0) begin
            #8;
            if (sram_we_bar==0) begin
                array[sram_addr] <= sram_data_in;
            end else begin
                sram_data_out <= array[sram_addr];
            end
        end
    end

endmodule

module spinor( // supports 1-1-1 read operations only
    input wire  sck,
    input wire  csb,
    input wire  si,
    output reg  so
);

    reg [7:0] array[0:511];

    reg [7:0] cmd;
    reg [23:0] addr;
    always @ (negedge csb) fork
        begin:spi_comm
            integer i;
            for(i=7; i>=0; i=i-1)
                @(posedge sck) cmd[i]=si;
            $display("CMD=%x", cmd);

            for(i=23; i>=0; i=i-1)
                @(posedge sck) addr[i]=si;
            $display("ADDR=%x DATA=%x", addr, array[addr]);

            forever begin
                for (i=7; i>=0; i=i-1)
                    @(negedge sck) so = array[addr][i];
                addr=addr+1;
            end
        end
        begin
            @(posedge csb);
            so <= 1'bx;
            disable spi_comm;
        end
join

endmodule

module qspinor( // supports 4-4-4 read operations only
    input wire       sck,
    input wire       csb,
    inout wire [3:0] dio
);

    reg [7:0] array[0:511];

    reg [7:0]  cmd;
    reg [23:0] addr;
    reg [3:0]  dir = 0;
    reg [3:0]  dout;
    wire [3:0] din;

    generate
        for (genvar i=0; i<4; i=i+1) begin
            assign dio[i] = dir[i] ? dout[i] : 1'bz;
            assign din[i] = dir[i] ? 1'bx : dio[i];
        end
    endgenerate

    always @ (negedge csb) fork
        begin:spi_comm
            integer i;
            dir = 4'h0;
            for(i=4; i>=0; i=i-4)
                @(posedge sck) cmd[i+:4]=din;

            dir = 4'h0;
            for(i=20; i>=0; i=i-4)
                @(posedge sck) addr[i+:4]=din;

            dir = 4'h0;
            for(i=9; i>=0; i=i-1)
                @(posedge sck);

            #40 dir = 4'hf;
            forever begin
                for (i=4; i>=0; i=i-4)
                    @(negedge sck) dout = array[addr][i+:4];
                addr=addr+1;
            end
        end
        begin
            @(posedge csb);
            dir = 4'h0;
            disable spi_comm;
        end
    join

endmodule

module uart_host(
    input wire  dut_uart_txd,
    output reg  dut_uart_rxd
);

    time bit_duration = 1000000000.0 / 57600;
    initial begin
        dut_uart_rxd = 1'b1;
        #200000;
        send(8'hc3);
    end

    task automatic send(input[7:0] octet);
        integer i;
        begin
            dut_uart_rxd = 1'b0;
            #bit_duration;
            for (i=0; i<8; i=i+1) begin
                dut_uart_rxd = octet[i];
                #bit_duration;
            end
            dut_uart_rxd = 1'b1;
            #bit_duration;
        end
    endtask

endmodule
