`include "timescale.vh"
`include "simpaths.vh"

module simtop #(
    parameter HEX_PATH = `HEX_PATH
);

    reg clk = 0;
    initial forever #41.667 clk<=~clk;

    reg rst = 1;
    initial #8us @(negedge clk) rst = 0;

    wire [3:0] led;
    wire uart_rxd, uart_txd;

    wire nor_sck;
    wire nor_csb;
    wire [3:0]  nor_sio;

    pullup(nor_sio[0]);
    pullup(nor_sio[1]);
    pullup(nor_sio[2]);
    pullup(nor_sio[3]);

    localparam  DPI_SEL = 1, QPI_SEL = 2, SPI_SEL = 0;
    reg[1:0]    norflash_sel = SPI_SEL;
    dpinor dpinorflash(
        .sck(nor_sck     ),
        .csb(nor_csb | (norflash_sel!=DPI_SEL)),
        .dio(nor_sio[1:0])
    );
    initial $readmemh({HEX_PATH, "nor-init.hex"}, dpinorflash.array);

    qpinor qpinorflash(
        .sck(nor_sck),
        .csb(nor_csb | (norflash_sel!=QPI_SEL)),
        .dio(nor_sio)
    );
    initial $readmemh({HEX_PATH, "nor-init.hex"}, qpinorflash.array);

    MX25U51245G # (
        .Init_File({HEX_PATH, "nor-init.hex"})
    ) spinorflash (
        .SCLK (nor_sck   ),
        .CS   (nor_csb | (norflash_sel!=SPI_SEL)),
        .SI   (nor_sio[0]),
        .SO   (nor_sio[1]),
        .WP   (nor_sio[2]),
        .SIO3 (nor_sio[3]),
        .RESET(1'b1      )
    );
    initial #10ns spinorflash.Status_Reg[6] = 1'b1; // Quad enabled by default

    sram sram();
    initial $readmemh({HEX_PATH, "sram-init.hex"}, sram.array);

    logic   i2s_sd;
    wrapper top (
        .sysclk     (clk),
        .sysrst     (rst),
        .led_r      (led[3]),
        .led_g      (led[2]),
        .led_b      (led[1]),
        .button     (led[0]),
        .uart_tx    (uart_txd), // loopback
        .uart_rx    (uart_txd),
        .ada_sd     (i2s_sd)
    );

    always @ (posedge top.ada_sck) begin
        if (top.ada_ws) begin
            i2s_sd <= 1'bx;
        end else begin
            i2s_sd <= $urandom % 1;
        end
    end

    // endsim
    always @ (posedge top.clk) begin
        if (top.femto.tmr_req && top.femto.bus_wdata=="PASS") begin
            $display("PASS");
            $finish(0);
        end else if (top.femto.tmr_req && top.femto.bus_wdata=="FAIL") begin
            $display("FAIL");
            $finish(0);
        end
    end

    // print
    always @ (posedge top.clk) begin
        if (top.femto.tmr_req && top.femto.bus_wdata[31:8]=="PRN") begin
            $write("%c", top.femto.bus_wdata[7:0]);
        end
    end

    // nor sel
    always @ (posedge top.clk) if (top.femto.tmr_req) begin
        if (top.femto.bus_wdata=="D2PI")
            norflash_sel = DPI_SEL;
        else if (top.femto.bus_wdata=="Q4PI")
            norflash_sel = QPI_SEL;
        else
            norflash_sel = SPI_SEL;
    end

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

module dpinor( // supports 2-2-2 read operations only
    input wire       sck,
    input wire       csb,
    inout wire [1:0] dio
);

    reg [7:0] array[0:511];

    reg [7:0]  cmd;
    reg [23:0] addr;
    reg [1:0]  dir = 0;
    reg [1:0]  dout;
    wire [1:0] din;

    generate
        for (genvar i=0; i<2; i=i+1) begin
            assign dio[i] = dir[i] ? dout[i] : 1'bz;
            assign din[i] = dir[i] ? 1'bx : dio[i];
        end
    endgenerate

    always @ (negedge csb) fork
        begin:spi_comm
            integer i;
            dir = 2'h0;
            for(i=6; i>=0; i=i-2)
                @(posedge sck) cmd[i+:2]=din;

            dir = 2'h0;
            for(i=22; i>=0; i=i-2)
                @(posedge sck) addr[i+:2]=din;

            dir = 2'h0;
            for(i=7; i>=0; i=i-1)
                @(posedge sck);

            #40 dir = 2'h3;
            forever begin
                for (i=6; i>=0; i=i-2)
                    @(negedge sck) dout[1:0] = array[addr][i+:2];
                addr=addr+1;
            end
        end
        begin
            @(posedge csb);
            dir = 2'h0;
            disable spi_comm;
        end
    join

endmodule

module qpinor( // supports 4-4-4 read operations only
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
