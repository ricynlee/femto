`include "timescale.vh"

module simtop;

    reg clk = 0;
    initial forever #41.667 clk<=~clk;

    wire [3:0] led;
    wire uart_loopback;
    wire fault;
    wire qspinor_sck;
    wire qspinor_csb;
    wire [3:0] qspinor_data;
    // spinor qspinor(
    //     .sck(qspinor_sck),
    //     .csb(qspinor_csb),
    //     .si(qspinor_data[0]),
    //     .so(qspinor_data[1])
    // );

    qspinor qspinor(
        .sck(qspinor_sck),
        .csb(qspinor_csb),
        .dio(qspinor_data)
    );

    sram sram();
    
    initial $readmemh("D:/femto/rtl/sim/sram-init.hex", sram.array);

    top top(
        .sysclk     (clk             ),
        .sysrst     (1'b0            ),
        .fault      (fault           ),
        .gpio       (led             ),
        .uart_tx    (uart_loopback   ),
        .uart_rx    (uart_loopback   ),
        .sram_ce_bar(sram.sram_ce_bar),
        .sram_oe_bar(sram.sram_oe_bar),
        .sram_we_bar(sram.sram_we_bar),
        .sram_data  (sram.sram_data  ),
        .sram_addr  (sram.sram_addr  ),
        .qspi_sck   (qspinor_sck),
        .qspi_csb   (qspinor_csb),
        .qspi_data  (qspinor_data)
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

module spinor(
    input wire  sck,
    input wire  csb,
    input wire  si,
    output reg  so
);

    wire [7:0] array[0:511];
`include "qspinor.vh"

    reg [7:0] cmd;
    reg [23:0] addr;
    always @ (negedge csb) fork
        begin:spi_comm
            integer i;
            for(i=7; i>=0; i=i-1)
                @(posedge sck) cmd[i]=si;
    
            for(i=23; i>=0; i=i-1)
                @(posedge sck) addr[i]=si;
            
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

module qspinor(
    input wire       sck,
    input wire       csb,
    inout wire [3:0] dio
);

    wire [7:0] array[0:511];
`include "qspinor.vh"

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

