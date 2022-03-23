`include "timescale.vh"

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
