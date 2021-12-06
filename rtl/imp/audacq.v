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
    wire[17:0]  sample;
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
            rdata[23:0] <= {{6{sample[17]}}, sample};
            rdata[31] <= 1'b1;
        end else if (resp) begin
            rdata[31] <= 1'b0;
        end
    end
endmodule

module audacq (
    input wire  clk,
    input wire  rstn,

    output reg          arrive,
    output wire[17:0]   sample,

    output reg  sck,
    output reg  ws,
    output wire lrs,
    input wire  sd
);
    // state control
    localparam  IDLE = 0,
                INIT = 1,
                LOW  = 2,
                HIGH = 3;

    reg[7:0]    state, next_state;
    reg[7:0]    count, next_count;
    always @ (posedge clk) begin
        if (~rstn) begin
            state <= IDLE;
        end else begin
            state <= next_state;
            count <= next_count;
        end
    end

    always @ (*) case (state)
        default:
            begin
                next_state = INIT;
                next_count = 0;
            end
        INIT:
            if (count==1) begin
                next_state = LOW;
                next_count = 0;
            end else begin
                next_state = INIT;
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
    assign lrs = 1'b0; // mono-channel, sample if ws is low

    (* async_reg = "true" *)
    reg[17:0]   acq_r;
    always @ (posedge clk) begin
        if (~rstn) begin
            sck <= 1'b0;
            ws <= 1'b1;
            arrive <= 1'b0;
        end else if (state==INIT) case (count)
            default: sck <= 1'b1;
            1:       sck <= 1'b0;
        endcase else if (state==LOW) case (count)
            2:  acq_r[17] <= sd;
            4:  acq_r[16] <= sd;
            6:  acq_r[15] <= sd;
            8:  acq_r[14] <= sd;
            10: acq_r[13] <= sd;
            12: acq_r[12] <= sd;
            14: acq_r[11] <= sd;
            16: acq_r[10] <= sd;
            18: acq_r[9]  <= sd;
            20: acq_r[8]  <= sd;
            22: acq_r[7]  <= sd;
            24: acq_r[6]  <= sd;
            26: acq_r[5]  <= sd;
            28: acq_r[4]  <= sd;
            30: acq_r[3]  <= sd;
            32: acq_r[2]  <= sd;
            34: acq_r[1]  <= sd;
            36: acq_r[0]  <= sd;
            62: arrive <= 1'b1;
            63: arrive <= 1'b0;
        endcase
    end
    assign  sample = acq_r;
endmodule
