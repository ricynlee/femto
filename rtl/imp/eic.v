// This file is generated with ..\tools\eic_rtl_gen.py
// XLEN = 32, EISN = 4

module extint_controller # (
    parameter INFO_TYPE = "number" // "number", "flag"
)(
    input wire clk,
    input wire rstn,
    // core interface
    output wire       ext_int_trigger,
    output wire[31:0] ext_int_info,
    input wire        ext_int_handled,
    // ip interface
    input wire[3:0] ext_int_from // int from ip, posedge active
);
    // interrupt posedge detection
    wire[3:0] ext_int_pulse;
    begin:PEDGE_DETECT
        reg[3:0] prev_ext_int_from;
        always @ (posedge clk) begin
            if (~rstn) begin
                prev_ext_int_from <= 4'd0;
            end else begin
                prev_ext_int_from <= ext_int_from;
            end
        end
        assign ext_int_pulse = ~prev_ext_int_from & ext_int_from;
    end // PEDGE_DETECT

    // interrupt flag: one-hot interrupt number
    wire[31:0] ext_int_flag;
    wire       ext_int_flag_vld;
    begin: IFLAG_HANDLER
        reg[3:0]  ext_int;
        wire[3:0] ext_int_minus_one = ext_int-1'b1;
        wire[3:0] ext_int_after_handled = ext_int_minus_one & ext_int;
        wire[3:0] ext_int_to_be_handled = ~ext_int_minus_one & ext_int;
        always @ (posedge clk) begin
            if (~rstn) begin
                ext_int <= 4'd0;
            end else begin
                ext_int <= (ext_int_handled ? ext_int_after_handled : ext_int) | ext_int_pulse;
            end
        end

        assign ext_int_flag = {28'd0, ext_int_to_be_handled};
        assign ext_int_flag_vld = |ext_int;
    end // IFLAG_HANDLER

    generate
        if (INFO_TYPE=="number") begin
            // interrupt number: binary interrupt flag
            wire[31:0] ext_int_num;
            wire       ext_int_num_vld;
            begin: INUM_HANDLER
                reg[3:0] ext_int;
                reg      ext_int_vld;
                always @ (posedge clk) begin
                    if (~rstn) begin
                        ext_int_vld <= 1'b0;
                    end else begin
                        ext_int <= ext_int_flag[3:0];
                        ext_int_vld <= ext_int_handled ? 1'b0 : ext_int_flag_vld;
                    end
                end

                assign ext_int_num[0] = |{ext_int[1], ext_int[3]};
                assign ext_int_num[1] = |{ext_int[2], ext_int[3]};
                assign ext_int_num[31:2] = 30'd0;
                assign ext_int_num_vld = ext_int_vld;
            end // INUM_HANDLER

            assign ext_int_info = ext_int_num;
            assign ext_int_trigger = ext_int_num_vld;
        end else begin // INFO_TYPE=="flag"
            assign ext_int_info = ext_int_flag;
            assign ext_int_trigger = ext_int_flag_vld;
        end
    endgenerate

endmodule
