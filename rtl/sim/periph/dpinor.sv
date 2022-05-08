`include "timescale.vh"

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
