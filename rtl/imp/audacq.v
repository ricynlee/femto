`include "femto.vh"
`include "timescale.vh"

module audacq_controller(
    input wire  clk,
    input wire  rstn, // sync

    // user interface
    input wire[`ADA_VA_WIDTH-1:0]   addr,
    input wire                      w_rb,
    input wire[`BUS_ACC_WIDTH-1:0]  acc,
    output reg[`BUS_WIDTH-1:0]      rdata,
    input wire[`BUS_WIDTH-1:0]      wdata,
    input wire                      req,
    output reg                      resp,

    output wire fault,

    output wire sck,
    output wire ws,
    output wire lrs,
    input wire  sd
);

    /*
     * Register map
     *  Name    | Address | Size | Access | Note
     *  SSR     | 0       | 4    | RO     | -
     *
     *  SSR
     *   Status (31:24) | Sample (23:0)
     */

    // fault generation
    wire invld_addr = (addr!=0);
    wire invld_acc  = (acc!=`BUS_ACC_4B);
    wire invld_wr   = w_rb;
    wire invld_d    = 0;

    wire invld      = |{invld_addr,invld_acc,invld_wr,invld_d};
    assign fault    = req & invld;

    // resp generation
    always @ (posedge clk) begin
        if (~rstn) begin
            resp <= 0;
        end else begin
            resp <= req & ~invld;
        end
    end

    // audio data acquisition
    wire        arrive;
    wire[23:0]  sample;
    audacq audacq (
        .clk (clk ),
        .rstn(rstn),
        .arrive(arrive),
        .sample(sample),
        .sck(sck),
        .ws (ws ),
        .lrs(lrs),
        .sd (sd )
    );

    // data
    always @ (posedge clk) begin
        if (~rstn) begin
            rdata <= 32'd0;
        end else if (arrive) begin
            rdata[23:0] <= sample;
            rdata[31] <= 1'b1;
        end else if (resp) begin
            rdata[31] <= 1'b0;
        end
    end
endmodule

// MSB-LSB, left-aligned
module audacq # (
    parameter   PRIMARY_DIV = 26
)(
    input wire  clk,
    input wire  rstn,

    output wire         arrive,
    output wire[23:0]   sample,

    output wire sck,
    output wire ws,
    output wire lrs,
    input wire  sd
);
    // primary divider
    reg[7:0] prim_div_cnt;
    always @ (posedge clk) begin
        if (~rstn) begin
            prim_div_cnt <= 0;
        end else if (prim_div_cnt==PRIMARY_DIV-1) begin
            prim_div_cnt <= 0;
        end else begin
            prim_div_cnt <= prim_div_cnt + 1;
        end
    end

    wire trigger = (prim_div_cnt==0);

    // state control
    localparam  IDLE = 0,
                LOW  = 1,
                HIGH = 2;

    reg[7:0]    state, next_state;
    reg[7:0]    count, next_count;
    always @ (posedge clk) begin
        if (~rstn) begin
            state <= IDLE;
            count <= 0;
        end else if (trigger) begin
            state <= next_state;
            count <= next_count;
        end
    end

    always @ (*) case (state)
        default:
            if (count==63) begin
                next_state = LOW;
                next_count = 0;
            end else begin
                next_state = IDLE;
                next_count = count + 1;
            end
        LOW:
            if (count==63) begin
                next_state = HIGH;
                next_count = 0;
            end else begin
                next_state = LOW;
                next_count = count + 1;
            end
        HIGH:
            if (count==63) begin
                next_state = LOW;
                next_count = 0;
            end else begin
                next_state = HIGH;
                next_count = count + 1;
            end
    endcase

    // data acquisition
    (* async_reg = "true" *)
    reg[23:0]   acq_r;
    always @ (posedge clk) if (state==LOW && trigger) case (count)
        2 : acq_r[23] <= sd;
        4 : acq_r[22] <= sd;
        6 : acq_r[21] <= sd;
        8 : acq_r[20] <= sd;
        10: acq_r[19] <= sd;
        12: acq_r[18] <= sd;
        14: acq_r[17] <= sd;
        16: acq_r[16] <= sd;
        18: acq_r[15] <= sd;
        20: acq_r[14] <= sd;
        22: acq_r[13] <= sd;
        24: acq_r[12] <= sd;
        26: acq_r[11] <= sd;
        28: acq_r[10] <= sd;
        30: acq_r[9]  <= sd;
        32: acq_r[8]  <= sd;
        34: acq_r[7]  <= sd;
        36: acq_r[6]  <= sd;
        38: acq_r[5]  <= sd;
        40: acq_r[4]  <= sd;
        42: acq_r[3]  <= sd;
        44: acq_r[2]  <= sd;
        46: acq_r[1]  <= sd;
        48: acq_r[0]  <= sd;
    endcase

    assign lrs = 1'b0; // mono-channel, sample if ws is low
    assign  sample = acq_r;
    assign  sck = (state==IDLE) || (count[0]);
    assign  ws = (state==IDLE) || (state==HIGH);
    assign  arrive = (state==LOW && next_state==HIGH && trigger);
endmodule

module iir_filter (
    input wire  clk,
    input wire  rstn,

    input wire          din_vld,
    input wire[15:0]    din,    // S16.n fixed point
    output wire         dout_vld,
    output wire[15:0]   dout    // S16.n fixed point
);
    localparam ORDER = 4;

    localparam[0:ORDER] COE_B = { // S16.12 fixed point
        32, -63, 53, 0, -53, 63, -32
    };

    localparam[0:ORDER] COE_A = { // S16.12 fixed point
        4096, -12395, 23231, -25916, 20413, -9566, 2778
    };

    // mul acc
    wire        mul_acc_clr
    mul_acc_iv, mul_acc_ov, mul_acc_a_sb;
    reg[15:0]   mul_acc_a, // X,Y
                mul_acc_b; // COE
    wire[15:0]  mul_acc_s;
    mul_acc mul_acc (
        .clk (clk ),
        .rstn(rstn),
        .clr (mul_acc_clr),
        .iv  (mul_acc_iv ),
        .a   (mul_acc_a),
        .b   (mul_acc_b),
        .a_sb(mul_acc_a_sb),
        .ov  (mul_acc_ov  ),
        .s   (mul_acc_s   )
    );

    // state control
    localparam  IDLE   = 0,
                ADD_Z  = 1,
                ADD_XB = 2,
                SUB_YA = 3;

    reg[7:0] state, next_state;
    reg[7:0] order, next_order;
    always @ (posedge clk) begin
        if (~rstn) begin
            state <= IDLE;
            order <= 0;
        end else begin
            state <= next_state;
            order <= next_order;
        end
    end

    always @ (*) case (state)
        default:
            if (din_vld) begin
                next_state = ADD_Z;
                next_order = 0;
            end else begin
                next_state = IDLE;
                next_order = 0;
            end
        ADD_Z:
            if (mul_acc_ov) begin
                next_state = ADD_XB;
                next_order = order;
            end else begin
                next_state = ADD_Z;
                next_order = order;
            end
        ADD_XB:
            if (mul_acc_ov) begin
                next_state = SUB_YA;
                next_order = order;
            end else begin
                next_state = ADD_XB;
                next_order = order;
            end
        SUB_YA:
            if (mul_acc_ov) begin
                if (order==ORDER) begin
                    next_state = IDLE;
                    next_order = 0;
                end else begin
                    next_state = ADD_Z;
                    next_order = order+1;
                end
            end else begin
                next_state = SUB_YA;
                next_order = order;
            end
    endcase

    // input buffering
    wire[15:0]  din_kept;
    dff #(
        .WIDTH(16     ),
        .VALID("async")
    ) din_keeper (
        .clk(clk),

        .vld(din_vld && state==IDLE),

        .in (din     ),
        .out(din_kept)
    );

    // data flow
    generate for (genvar i = 1; i <= ORDER; i = i + 1)
        begin: STAGE
            wire        iv; // input vld
            wire[15:0]  zi, zo;
            dff #(
                .WIDTH(16    ),
                .RESET("sync"),
                .VALID("sync"),
            ) z (
                .clk (clk ),
                .rstn(rstn),

                .vld (iv),
                .in  (zi),
                .out (zo)
            );

            assign  iv = (order==i) && mul_acc_ov;
            assign  zi = mul_acc_s;
        end
    endgenerate

    always @ (*) case (next_state)
        mul_acc_a =
    end

endmodule

module mul_acc (
    input wire  clk,
    input wire  rstn,

    input wire  clr, // sync

    input wire          iv,
    input wire[15:0]    a,
    input wire[15:0]    b,
    input wire          a_sb,

    output wire         ov,
    output wire[15:0]   s
);
    // not sure if Xilinx mul & acc are configured as fully pipelined
    // so let's assume no

    // state control
    localparam  IDLE = 0,
                MUL1 = 1,
                MUL2 = 2,
                MUL3 = 3,
                ACC1 = 4,
                ACC2 = 5;
    reg[7:0]    state, next_state;
    always @ (posedge clk) begin
        if (~rstn)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @ (*) case (state)
        default:
            if (iv)
                next_state = MUL1;
            else
                next_state = IDLE;
        MUL1: next_state = MUL2;
        MUL2: next_state = MUL3;
        MUL3: next_state = ACC1;
        ACC1: next_state = ACC2;
        ACC2: next_state = IDLE;
    endcase

    wire    mul_acc_idle = state==IDLE;
    wire    valid_clr = mul_acc_idle & clr;

    // calculation
    wire[15:0]  p;
    mul mul ( // mul latency 3
        .CLK(clk   ),
        .A  (a),
        .B  (b),
        .P  (p)
    );

    wire    p_vld = state==MUL3;
    acc acc ( // acc latency 2
        .CLK   (clk      ),
        .SCLR  (valid_clr),
        .BYPASS(p_vld    ), // low active, equivalent to vld
        .B     (p        ),
        .ADD   (a_sb     ),
        .Q     (s        )
    );

    assign  ov = state==ACC2;
endmodule
