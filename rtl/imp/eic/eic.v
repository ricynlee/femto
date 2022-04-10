`include "femto.vh"
`include "timescale.vh"

module extint_controller (
    input wire clk,
    input wire rstn,
    // core interface
    output wire ext_int_trigger,
    input wire  ext_int_handled,
    // ip interface
    input wire[`EXT_INT_SRC_NUM-1:0] ext_int_src_vect, // int from ip, posedge active
    // bus interface
    input wire[$clog2(`EIC_SIZE)-1:0]   addr,
    input wire                          w_rb,
    input wire[`BUS_ACC_WIDTH-1:0]      acc,
    output reg[`BUS_WIDTH-1:0]          rdata,
    input wire[`BUS_WIDTH-1:0]          wdata,
    input wire                          req,
    output reg                          resp,
    output wire                         fault
);
    // interrupt posedge detection
    wire[`EXT_INT_SRC_NUM-1:0] ext_int_pulse;
    begin:PEDGE_DETECT
        reg[`EXT_INT_SRC_NUM-1:0] prev_ext_int_from;
        always @ (posedge clk) begin
            if (~rstn) begin
                prev_ext_int_from <= {`EXT_INT_SRC_NUM{1'b0}};
            end else begin
                prev_ext_int_from <= ext_int_vect;
            end
        end
        assign ext_int_pulse = ~prev_ext_int_from & ext_int_vect;
    end // PEDGE_DETECT

    // interrupt flag: one-hot interrupt number
    reg[`EXT_INT_SRC_NUM-1:0]  ext_int_clr;
    wire[`EXT_INT_SRC_NUM-1:0] ext_int_flag;
    begin: IFLAG_HANDLER
        reg[`EXT_INT_SRC_NUM-1:0]  ext_int;
        wire[`EXT_INT_SRC_NUM-1:0] ext_int_minus_one = ext_int-1'b1;
        wire[`EXT_INT_SRC_NUM-1:0] ext_int_after_handled = ext_int_minus_one & ext_int;
        always @ (posedge clk) begin
            if (~rstn) begin
                ext_int <= {`EXT_INT_SRC_NUM{1'b0}};
            end else begin
                ext_int <= ((ext_int_handled ? ext_int_after_handled : ext_int) | ext_int_pulse) & ext_int_clr;
            end
        end
        assign ext_int_trigger = |ext_int;
        assign ext_int_flag = ext_int;
    end // IFLAG_HANDLER

    // fault generation
    wire invld_addr = 0;
    wire invld_acc  = (acc!=`BUS_ACC_4B);
    wire invld_wr   = 0;

    wire invld      = |{invld_addr,invld_acc,invld_wr};
    assign fault    = req & invld;

    // resp generation
    always @ (posedge clk) begin
        if (~rstn) begin
            resp <= 1'b0;
        end else begin
            resp <= req & ~invld;
        end
    end

    always @ (posedge clk) begin
        if (~rstn) begin
            ext_int_clr <= {`EXT_INT_SRC_NUM{1'b1}};
            rdata <= {`XLEN{1'b0}};
        end else begin
            if (req & ~invld & w_rb)
                ext_int_clr <= ~wdata[`EXT_INT_SRC_NUM-1:0];
            else
                ext_int_clr <= {`EXT_INT_SRC_NUM{1'b1}};

            if (req & ~invld & ~w_rb)
                rdata[`EXT_INT_SRC_NUM-1:0] <= ext_int_flag; // implicitly extended
        end
    end
endmodule
