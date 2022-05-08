`include "timescale.vh"

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
