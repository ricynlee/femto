module instr_fetch_queue (
    input wire clk,
    input wire rstn,

    input wire        in_req,
    input wire        in_16bit,  // 0:32-bit data, 1:16-bit data
    input wire [31:0] in,

    input  wire        out_req,
    input  wire        out_16bit,  // 0:32-bit data, 1:16-bit data
    output wire [31:0] out,

    input wire clr,

    output wire [1:0] vacant_16bit_entry,  // number
    output wire [1:0] filled_16bit_entry   // number
);
    generate
        for (genvar i = 0; i < 2; i = i + 1) begin : pingpong
            wire w, r;
            wire full, empty;
            wire almost_full, almost_empty;
            wire [15:0] din, dout;
            fifo #(
                .WIDTH(16),
                .DEPTH(4),      /* 3 is enough */
                .CLEAR("sync")
            ) fifo (
                .clk         (clk),
                .rstn        (rstn),
                .din         (din),
                .dout        (dout),
                .w           (w),
                .r           (r),
                .clr         (clr),
                .full        (full),
                .empty       (empty),
                .almost_full (almost_full),
                .almost_empty(almost_empty)
            );
        end
    endgenerate

    reg wsel, rsel;

    // note: both fifos' depth are 2, and we'are not expecting "one:2, the other:0" situation
    // note: actual capacity of the queue is 4 entries, but we would reserve 2 for an incoming (outgoing) 32-bit instruction for safety
    //       while the instruction is being written into (read from) fifos, we cannot see full (empty) flag change
    assign vacant_16bit_entry = (pingpong[0].full & pingpong[1].full) ? 2'd0 :  // actually 0
 ((pingpong[0].full & pingpong[1].almost_full) | (pingpong[1].full & pingpong[0].almost_full)) ? 2'd0 :  // actually 1
 (pingpong[0].almost_full & pingpong[1].almost_full) ? 2'd0 :  // actually 2
 (pingpong[0].almost_full ^ pingpong[1].almost_full) ? 2'd1 :  // actually 3
  /* ~pingpong[0].almost_full & ~pingpong[1].almost_full */
 2'd2;  // actually >=4

    assign filled_16bit_entry = (pingpong[0].empty & pingpong[1].empty) ? 2'd0 :  // actually 0
 ((pingpong[0].empty & pingpong[1].almost_empty) | (pingpong[1].empty & pingpong[0].almost_empty)) ? 2'd1 :  // actually 1
 (pingpong[0].almost_empty & pingpong[1].almost_empty) ? 2'd2 :  // actually 2
 (pingpong[0].almost_empty ^ pingpong[1].almost_empty) ? 2'd2 :  // actually 3
  /* ~pingpong[0].almost_empty & ~pingpong[1].almost_empty */
 2'd2;  // actually >=4

    assign pingpong[0].w      = in_req & (~in_16bit | ~wsel);
    assign pingpong[1].w      = in_req & (~in_16bit | wsel);

    assign pingpong[0].r      = out_req & (~out_16bit | ~rsel);
    assign pingpong[1].r      = out_req & (~out_16bit | rsel);

    assign pingpong[0].din    = wsel ? in[31:16] : in[15:0];
    assign pingpong[1].din    = wsel ? in[15:0] : in[31:16];

    assign out[15:0]          = rsel ? pingpong[1].dout : pingpong[0].dout;
    assign out[31:16]         = rsel ? pingpong[0].dout : pingpong[1].dout;

    always @(posedge clk) begin
        if (~rstn | clr) begin
            wsel <= 1'b0;
            rsel <= 1'b0;
        end else begin
            if (~(pingpong[0].full & pingpong[1].full) & in_req & in_16bit) begin
                wsel <= ~wsel;
            end
            if (~(pingpong[0].empty & pingpong[1].empty) & out_req & out_16bit) begin
                rsel <= ~rsel;
            end
        end
    end
endmodule
