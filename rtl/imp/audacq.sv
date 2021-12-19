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
     *  CR      | 4       | 4    | WO     | -
     *
     *  SSR
     *   Fresh(31) | (30:24) | Count (23:16) | Sample (15:0)
     *  CR
     *   FEN(31) | (30:4) | Trunc(3:0)
     */

    `define FRESH   31
    `define COUNT   23:16
    `define SAMPLE  15:0

    `define FEN     31
    `define TRUNC   3:0

    // fault generation
    wire invld_addr = (addr[1:0]!=0);
    wire invld_acc  = (acc!=`BUS_ACC_4B);
    wire invld_wr   = (w_rb ^ addr[2]);
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

    // control register
    reg         filter_en;
    reg[3:0]    trunc_width;
    always @ (posedge clk) begin
        if (~rstn) begin
            filter_en <= 0;
            trunc_width <= 0;
        end else if (req && ~invld && (addr==3'd4) && w_rb) begin
            filter_en <= wdata[`FEN];
            trunc_width <= wdata[`TRUNC];
        end
    end

    // audio data acquisition
    wire        arrive_acq;
    wire[23:0]  sample_raw;
    audacq audacq (
        .clk (clk ),
        .rstn(rstn),
        .arrive(arrive_acq),
        .sample(sample_raw),
        .sck(sck),
        .ws (ws ),
        .lrs(lrs),
        .sd (sd )
    );

    wire[31:0]  sample_raw_ext = {{8{sample_raw[23]}}, sample_raw};
    wire[15:0]  sample_trunc = sample_raw_ext[trunc_width+:16];

    wire        arrive_filter;
    wire[15:0]  sample_filtered;
    iir_filter iir_filter (
        .clk (clk ),
        .rstn(rstn),
        .din_vld (arrive_acq  ),
        .din     (sample_trunc),
        .dout_vld(arrive_filter  ),
        .dout    (sample_filtered)
    );

    wire        arrive = filter_en ? arrive_filter : arrive_acq;
    wire[15:0]  sample = filter_en ? sample_filtered : sample_trunc ;

    // status and sample
    always @ (posedge clk) begin
        if (~rstn) begin
            rdata <= 32'd0;
        end else if (arrive) begin
            rdata[`SAMPLE] <= sample;
            rdata[`COUNT] <= rdata[`COUNT]+1;
            rdata[`FRESH] <= 1;
        end else if (resp) begin
            rdata[`FRESH] <= 0;
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

    assign  sample = acq_r;
    assign  arrive = (state==LOW && next_state==HIGH && trigger);

    assign lrs = 1'b0; // mono-channel, sample if ws is low
    assign  sck = (state==IDLE) || (count[0]);
    assign  ws = (state==IDLE) || (state==HIGH);
endmodule

module iir_filter (
    input wire  clk,
    input wire  rstn,

    input wire          din_vld,
    input wire[15:0]    din,    // S16.n fixed point
    output wire         dout_vld,
    output wire[15:0]   dout    // S16.n fixed point
);
    localparam          ORDER = 6;

    localparam[15:0]    COE_B[0:ORDER] = { // S16.12 fixed point
        16'd32, -16'd63, 16'd53, 16'd0, -16'd53, 16'd63, -16'd32
    };

    localparam[15:0]    COE_A[0:ORDER] = { // S16.12 fixed point
        16'd0 /*this has to be 0*/, -16'd12395, 16'd23231, -16'd25916, 16'd20413, -16'd9566, 16'd2778
    };

    localparam  COE_1 = 4096; // S16.12 fixed point

    // mul acc
    wire        mul_acc_clr,
                mul_acc_iv;
    reg         mul_acc_a_sb;
    reg[15:0]   mul_acc_xyz, // X,Y,Z
                mul_acc_coe; // COE
    wire        mul_acc_ov;
    wire[15:0]  mul_acc_s;
    mul_acc mul_acc (
        .clk (clk ),
        .rstn(rstn),
        .clr (mul_acc_clr ),
        .iv  (mul_acc_iv  ),
        .a   (mul_acc_xyz ),
        .b   (mul_acc_coe ),
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
    wire[15:0]  x;
    dff #(
        .WIDTH(16     ),
        .VALID("async")
    ) din_keeper (
        .clk(clk),

        .vld(din_vld && state==IDLE),

        .in (din),
        .out(x  )
    );

    // data flow
    wire[15:0]  z[0:ORDER+1];
    generate for (genvar i = 0; i <= ORDER; i = i + 1)
        begin: Z
            wire        v; // input vld
            wire[15:0]  o;
            dff #(
                .WIDTH(16    ),
                .RESET("sync"),
                .VALID("sync")
            ) z_dff (
                .clk (clk ),
                .rstn(rstn),

                .vld (v        ),
                .in  (mul_acc_s),
                .out (o        )
            );

            assign  v = (state==SUB_YA) && (order==i) && mul_acc_ov;
            assign  z[i] = o;
        end
    endgenerate
    wire[15:0]  y = z[0];
    assign      z[ORDER+1] = 16'd0;

    always @ (*) case (next_state)
        ADD_Z:
            begin
                mul_acc_xyz = z[next_order+1];
                mul_acc_coe = COE_1;
                mul_acc_a_sb = 1;
            end
        ADD_XB:
            begin
                mul_acc_xyz = x;
                mul_acc_coe = COE_B[order];
                mul_acc_a_sb = 1;
            end
        SUB_YA:
            begin
                mul_acc_xyz = y;
                mul_acc_coe = COE_A[order];
                mul_acc_a_sb = 0;
            end
        default:
            begin
                mul_acc_xyz = 16'dx;
                mul_acc_coe = 16'dx;
                mul_acc_a_sb = 1'bx;
            end
    endcase

    assign  mul_acc_iv = (next_state==ADD_Z && state!=ADD_Z) ||
                         (next_state==ADD_XB && state!=ADD_XB) ||
                         (next_state==SUB_YA && state!=SUB_YA);
    assign  mul_acc_clr = (next_state==ADD_Z && state!=ADD_Z);

    assign  dout_vld = (next_state==IDLE && state!=IDLE);
    assign  dout = y;

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
        default: // IDLE, ACC2
            if (iv)
                next_state = MUL1;
            else
                next_state = IDLE;
        MUL1: next_state = MUL2;
        MUL2: next_state = MUL3;
        MUL3: next_state = ACC1;
        ACC1: next_state = ACC2;
    endcase

    wire    valid_clr = (state==IDLE || next_state==MUL1) & clr;
    assign  ov = state==ACC2;

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
        .CLK   (clk              ),
        .SCLR  (valid_clr        ),
        .B     (p_vld ? p : 16'd0),
        .ADD   (a_sb             ),
        .Q     (s                )
    );
endmodule
