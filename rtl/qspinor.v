`include "sim/timescale.vh"
// `include "femto.vh"

// Intended to support 1-1-1 and 4-4-4 protocols under mode 0

module qspinor_controller #(
    parameter   SHARED_QUEUES = 1
)(
    input wire                              clk,
    input wire                              rstn,

    input wire                              req,
    output wire                             resp,
    input wire                              wr_b,
    input wire [$clog2(`BUS_ACC_CNT)-1:0]   acc,
    input wire                              ctrl_sel, // 0-read, 1-control
    input wire [`QSPINOR_ABW-1:0]           addr,
    input wire [`BUS_WIDTH-1:0]             wdata,
    output wire [`BUS_WIDTH-1:0]            rdata,
    output wire                             fault,
    // hw interface
    output wire                             qspi_sck,
    output wire                             qspi_csb,
    inout wire [3:0]                        qspi_data
);
    wire invld_wr = req && (ctrl_sel ? /*REG begin*/ (
        wr_b ? (/*RO begin*/addr[2:0]==3'd5 || addr[2:0]==3'd6 /*RO end*/) : (/*WO begin*/ addr[2:0]==3'd2 || addr[2:0]==3'd4 || addr[2:0]==3'd7 /*WO end*/)
    ) /*REG end*/ : wr_b);

    wire invld_acc = req && ctrl_sel && ( /*REG begin*/
        (acc!=`BUS_ACC_1B && (/*1B begin*/ addr[2:0]==3'd4 || addr[2:0]==3'd5 || addr[2:0]==3'd6 || addr[2:0]==3'd7 /*1B end*/)) ||
        (acc!=`BUS_ACC_2B && (/*2B begin*/ addr[2:0]==3'd0 || addr[2:0]==3'd2 /*2B end*/))
    /*REG end*/);

    wire invld_d; // invld data
    assign fault = invld_wr | invld_acc | invld_d;

    /*********************************************************************************************/
    wire req_decision; // delayable req for reg 2/4/7 and qspinor_read, normal req otherwise

    wire                    ctrl_sel_kept, wr_b_kept;
    wire [`QSPINOR_ABW-1:0] addr_kept;
    wire [15:0]             wdata_kept;
    wire [1:0]              acc_kept;
    dff #(
        .WIDTH(1+1+`QSPINOR_ABW+16+2),
        .RESET("sync"),
        .VALID("async")
    ) req_keeper (
        .clk (clk ),
        .rstn(rstn),
        .vld (req ),
        .in  ({
            ctrl_sel,
            wr_b,
            addr,
            wdata[15:0],
            acc
        }),
        .out ({
            ctrl_sel_kept,
            wr_b_kept,
            addr_kept,
            wdata_kept,
            acc_kept
        })
    );

    /*********************************************************************************************/
    // REG access resp
    reg reg_resp;
    always @ (posedge clk) begin
        if (rstn==0) begin
            reg_resp <= 0;
        end else begin
            reg_resp <= req_decision && ctrl_sel_kept;
        end
    end

    // R/W REG 0
    `define BF_QUAD_EN      0
    `define BF_DUMMY_CYCLES 7:4
    `define BF_READ_CMD     15:8

    reg         quad_en;
    reg [3:0]   dummy_cycles;
    reg [7:0]   read_cmd;

    always @ (posedge clk) begin
        if (rstn==0) begin
            quad_en <= 0;
            dummy_cycles <= 0;
            read_cmd <= 8'h03; // 1-1-1 read cmd for mainstream SPI NOR devices
        end else if (req_decision && ctrl_sel_kept && wr_b_kept && addr_kept[2:0]==3'd0) begin
            quad_en <= wdata_kept[`BF_QUAD_EN];
            dummy_cycles <= wdata_kept[`BF_DUMMY_CYCLES];
            read_cmd <= wdata_kept[`BF_READ_CMD];
        end
    end

    // W/O REG 2
    `define BF_BYTES_2_READ 8:0
    `define BF_REQUIRE_READ 15

    wire        io_req = req_decision && ctrl_sel_kept && wr_b_kept && addr_kept[2:0]==3'd2;
    wire        io_bytes_in_vld = wdata_kept[`BF_REQUIRE_READ];
    wire [8:0]  io_bytes_in = wdata_kept[`BF_BYTES_2_READ];

    // W/O REG 4
    wire        doq_wreq = req_decision && ctrl_sel_kept && wr_b_kept && addr_kept[2:0]==3'd4;
    wire [7:0]  doq_din  = wdata_kept[7:0];

    // R/O REG 5
    wire        diq_rreq = req_decision && ctrl_sel_kept && ~wr_b_kept && addr_kept[2:0]==3'd5;
    wire [7:0]  diq_dout;

    // R/O REG 6
    `define BF_DOQ_FULL     0
    `define BF_DIQ_EMPTY    1
    `define BF_IO_BUSY      7
    wire    doq_full;
    wire    diq_empty;
    wire    io_busy;

    // W/O REG 7
    `define BF_DOQ_CLEAR    0
    `define BF_DIQ_CLEAR    1
    wire    doq_clear = req_decision && ctrl_sel_kept && wr_b_kept && addr_kept[2:0]==3'd7 && wdata_kept[`BF_DOQ_CLEAR];
    wire    diq_clear = req_decision && ctrl_sel_kept && wr_b_kept && addr_kept[2:0]==3'd7 && wdata_kept[`BF_DIQ_CLEAR];

    // READ REG response data
    reg [`BUS_WIDTH-1:0] reg_resp_data;
    always @ (posedge clk) begin
        if (rstn==0) begin
            reg_resp_data <= 0;
        end else begin
            if (req_decision && ctrl_sel_kept && ~wr_b_kept) begin
                case (addr_kept[2:0])
                    3'd0: begin
                        reg_resp_data[`BF_QUAD_EN] <= quad_en;
                        reg_resp_data[`BF_DUMMY_CYCLES] <= dummy_cycles;
                        reg_resp_data[`BF_READ_CMD] <= read_cmd;
                    end
                    3'd5: begin
                        reg_resp_data[7:0] <= diq_dout;
                    end
                    3'd6: begin
                        reg_resp_data[`BF_DOQ_FULL] <= doq_full;
                        reg_resp_data[`BF_DIQ_EMPTY] <= diq_empty;
                        reg_resp_data[`BF_IO_BUSY] <= io_busy;
                    end
                endcase
            end else if (reg_resp) begin
                reg_resp_data <= 0;
            end
        end
    end

    /*********************************************************************************************/
    reg     req_onhold;
    wire    req_onhold_cond = ~ctrl_sel || addr[2:0]==3'd2 || addr[2:0]==3'd4 || addr[2:0]==3'd7; // req onhold cond amid io_busy
    always @ (posedge clk) begin
        if (rstn==0) begin
            req_onhold <= 0;
        end else begin
            if (io_busy) begin
                if (req & req_onhold_cond) begin
                    req_onhold <= 1;
                end
            end else begin
                req_onhold <= 0;
            end
        end
    end

    assign req_decision = io_busy ? (req & ~req_onhold_cond) : (req | req_onhold);

    /*********************************************************************************************/
    // To qspi_io
    wire        doq_rreq;
    wire [7:0]  doq_dout;
    wire        doq_empty;
    wire        diq_wreq;
    wire [7:0]  diq_din;
    wire        diq_full;

    generate
        if (SHARED_QUEUES) begin
            wire        q_clear, q_really_full, q_really_empty, q_wreq, q_rreq, q_almost_full, q_almost_empty;
            wire [7:0]  q_din, q_dout;

            assign q_clear = diq_clear | doq_clear;
            assign q_din   = diq_wreq ? diq_din : doq_din;
            assign q_wreq  = diq_wreq | doq_wreq;
            assign q_rreq  = doq_rreq | diq_rreq;

            fifo #(
                .WIDTH(8     ),
                .DEPTH(512   ),
                .CLEAR("sync")
            ) q ( // DIOQ
                .clk         (clk           ),
                .rstn        (rstn          ),
                .w           (q_wreq        ),
                .din         (q_din         ),
                .r           (q_rreq        ),
                .dout        (q_dout        ),
                .full        (q_really_full ),
                .almost_full (q_almost_full ),
                .empty       (q_really_empty),
                .almost_empty(q_almost_empty),
                .clr         (q_clear       )
            );

            assign diq_dout  = q_dout;
            assign doq_dout  = q_dout;
            assign diq_empty = q_really_empty;
            assign doq_empty = q_almost_empty | q_really_empty;
            assign diq_full  = q_almost_full | q_really_full;
            assign doq_full  = q_really_full;

            assign invld_d = req && ctrl_sel && ( /*REG begin*/
                addr[2:0]==3'd2 && q_really_empty
            /*REG end*/ );
        end else begin
            wire doq_almost_empty, doq_really_empty;
            fifo #(
                .WIDTH(8     ),
                .DEPTH(512   ),
                .CLEAR("sync")
            ) doq ( // Data Out (from bus to QSPI) Queue
                .clk         (clk             ),
                .rstn        (rstn            ),
                .w           (doq_wreq        ),
                .din         (doq_din         ),
                .r           (doq_rreq        ),
                .dout        (doq_dout        ),
                .full        (doq_full        ),
                .empty       (doq_almost_empty),
                .almost_empty(doq_really_empty),
                .clr         (doq_clear       )
            );
            assign doq_empty = doq_almost_empty | doq_really_empty;

            wire diq_almost_full, doq_really_full;
            fifo #(
                .WIDTH(8     ),
                .DEPTH(512   ),
                .CLEAR("sync")
            ) diq ( // Data In (from QSPI to bus) Queue
                .clk        (clk            ),
                .rstn       (rstn           ),
                .w          (diq_wreq       ),
                .din        (diq_din        ),
                .r          (diq_rreq       ),
                .dout       (diq_dout       ),
                .full       (doq_really_full),
                .almost_full(diq_almost_full),
                .empty      (diq_empty      ),
                .clr        (diq_clear      )
            );
            assign diq_full = diq_almost_full | doq_really_full;

            assign invld_d = req && ctrl_sel && ( /*REG begin*/
                addr[2:0]==3'd2 && doq_really_empty
            /*REG end*/ );
        end
    endgenerate

    /*********************************************************************************************/
    wire        qspi_io_csb;
    wire        qspi_io_sck;
    wire [3:0]  qspi_io_dir;
    wire [3:0]  qspi_io_sdo;
    wire [3:0]  qspi_io_sdi;
    qspi_io qspi_io (
        .clk         (clk            ),
        .rstn        (rstn           ),
        .doq_dout    (doq_dout       ),
        .doq_empty   (doq_empty      ),
        .doq_pop     (doq_rreq       ),
        .diq_din     (diq_din        ),
        .diq_full    (diq_full       ),
        .diq_push    (diq_wreq       ),
        .quad_en     (quad_en        ),
        .req         (io_req         ),
        .bytes_out   (9'd0           ), // whole doq
        .bytes_in    (io_bytes_in    ),
        .bytes_in_vld(io_bytes_in_vld),
        .busy        (io_busy        ),
        .csb         (qspi_io_csb    ),
        .sck         (qspi_io_sck    ),
        .dir         (qspi_io_dir    ),
        .sdo         (qspi_io_sdo    ),
        .sdi         (qspi_io_sdi    )
    );

    /*********************************************************************************************/
    wire        qspinor_read_req = req_decision && ~wr_b_kept && ~ctrl_sel_kept;

    wire        qspinor_read_resp;
    wire [31:0] qspinor_read_resp_data;

    wire        qspinor_read_csb;
    wire        qspinor_read_sck;
    wire [3:0]  qspinor_read_dir;
    wire [3:0]  qspinor_read_sdo;
    wire [3:0]  qspinor_read_sdi;
    qspinor_read qspinor_read(
        .clk         (clk                                   ),
        .rstn        (rstn                                  ),
        .req         (qspinor_read_req                      ),
        .acc         (acc_kept                              ),
        .addr        ({{(24-`QSPINOR_ABW){1'b0}}, addr_kept}),
        .cmd         (read_cmd                              ),
        .quad_en     (quad_en                               ),
        .dummy_cycles(dummy_cycles                          ),
        .resp        (qspinor_read_resp                     ),
        .resp_data   (qspinor_read_resp_data                ),
        .csb         (qspinor_read_csb                      ),
        .sck         (qspinor_read_sck                      ),
        .dir         (qspinor_read_dir                      ),
        .sdo         (qspinor_read_sdo                      ),
        .sdi         (qspinor_read_sdi                      )
    );

    /*********************************************************************************************/
    assign resp = reg_resp | qspinor_read_resp;
    assign rdata = qspinor_read_resp ? qspinor_read_resp_data : reg_resp_data;

    /*********************************************************************************************/
    assign qspi_csb = qspi_io_csb & qspinor_read_csb;
    assign qspi_sck = (~qspi_io_csb) ? qspi_io_sck : qspinor_read_sck;

    wire [3:0] qspi_dir = (~qspi_io_csb) ? qspi_io_dir : (~qspinor_read_csb) ? qspinor_read_dir : 4'h0;
    wire [3:0] qspi_sdo = (~qspi_io_csb) ? qspi_io_sdo : (~qspinor_read_csb) ? qspinor_read_sdo : 4'h0;
    wire [3:0] qspi_sdi;
    assign qspi_io_sdi = qspi_sdi;
    assign qspinor_read_sdi = qspi_sdi;
    generate
        for (genvar i=0; i<4; i=i+1) begin
            assign qspi_data[i] = qspi_dir[i] ? qspi_sdo[i] : 1'bz;
            assign qspi_sdi[i] = qspi_dir[i] ? 1'b0 : qspi_data[i];
        end
    endgenerate    

endmodule

`define LAUNCHED    0 // sck
`define LATCHED     1 // sck
`define SEL         0 // csb
`define UNSEL       1 // csb

module qspi_io(
    input wire          clk,
    input wire          rstn,

    input wire [7:0]    doq_dout,
    input wire          doq_empty, // almost empty
    output wire         doq_pop,

    output wire [7:0]   diq_din,
    input wire          diq_full, // almost full
    output wire         diq_push,

    input wire          req,
    input wire          quad_en,
    input wire [8:0]    bytes_out, // Bytes to write to QSPI NOR. 0 - till doq empty. Otherwise - actual bytes or till doq empty.
    input wire [8:0]    bytes_in,  // Bytes to read from QSPI NOR. 0 - till diq full. Otherwise - actual bytes or till diq full.
    input wire          bytes_in_vld,
    output wire         busy,

    output reg          csb,
    output reg          sck,
    output reg [3:0]    dir,
    output wire [3:0]   sdo,
    input wire [3:0]    sdi
);
    // Premised req is a single-clk pulse
    // Premised bytes_out do not change between reqs

    assign busy = csb==`SEL;

    wire [8:0] bytes_in_kept;
    wire       bytes_in_vld_kept;
    wire       quad_en_kept;
    dff #(
        .WIDTH(11),
        .RESET("sync"),
        .VALID("async")
    ) req_keeper (
        .clk (clk ),
        .rstn(rstn),
        .vld (req ),
        .in  ({bytes_in, bytes_in_vld, quad_en}),
        .out ({bytes_in_kept, bytes_in_vld_kept, quad_en_kept})
    );

    localparam  IDLE  = 0,
                DOUT  = 1,
                DIN   = 2;

    reg [7:0]   state;
    reg [15:0]  bit_index;
    wire [15:0] bit_step = quad_en_kept?4:1;

    wire [7:0]   txd = doq_dout;
    wire [7:0]  txd_bit_index = {5'd0, bit_index[2:0]};
    assign sdo = txd[txd_bit_index+:4];

    (*async_reg = "true"*)
    reg [7:0]   rxd;
    wire [7:0]  rxd_bit_index = {5'd0, bit_index[2:0]};
    assign diq_din = rxd;

    assign doq_pop = (state==DOUT && txd_bit_index==0 && sck==`LATCHED /*TO_LAUNCH*/);
    assign diq_push = (state==DIN && rxd_bit_index==0 && sck==`LATCHED);

    always @(posedge clk) begin
        if (rstn==0) begin
            state <= IDLE;
            csb <= `UNSEL;
            dir <= 4'h0;
        end else case(state)
            default: begin
                sck <= `LAUNCHED;
                if (req) begin
                    // jump to DOUT
                    /*
                     * Doq should better not be empty
                     */
                    state <= DOUT;
                    csb <= `SEL;
                    bit_index <= {bytes_out, 3'd0} - bit_step;
                    dir <= quad_en_kept?4'hf:4'h1;
                end
            end
            DOUT: begin
                sck <= ~sck;
                if (sck==`LATCHED) begin
                    if (bit_index[2:0] || (bit_index[15:3] && ~doq_empty)) begin
                        bit_index <= bit_index - bit_step;
                    end else begin
                        dir <= 4'h0;
                        if (bytes_in_vld_kept) begin
                            // jump to DIN
                            /*
                             * What if diq is already full?
                             * - I'm ignoring it.
                             */
                            state <= DIN;
                            bit_index <= {bytes_in_kept, 3'd0} - bit_step;
                        end else begin
                            // jump to IDLE
                            state <= IDLE;
                            csb <= `UNSEL;
                        end
                    end
                end
            end
            DIN: begin
                sck <= ~sck;
                if (sck==`LATCHED) begin
                    if (bit_index[2:0] || (bit_index[15:3] && ~diq_full)) begin
                        bit_index <= bit_index - bit_step;
                    end else begin
                        // jump to IDLE
                        state <= IDLE;
                        csb <= `UNSEL;
                    end
                end else /*sck == TO_LATCH*/ begin
                    if (quad_en_kept) begin
                        rxd[rxd_bit_index+:4] <= sdi;
                    end else begin
                        rxd[rxd_bit_index+:1] <= sdi[1];
                    end
                end
            end
        endcase
    end
endmodule

module qspinor_read(
    input wire          clk,
    input wire          rstn,

    input wire          req,
    input wire [7:0]    cmd,
    input wire [23:0]   addr,
    input wire          quad_en,
    input wire [1:0]    acc,
    input wire [3:0]    dummy_cycles, // Actual dummy cycles - 0:none
    output reg          resp,
    output wire [31:0]  resp_data,

    output reg          csb,
    output reg          sck,
    output reg [3:0]    dir,
    output wire [3:0]   sdo,
    input wire [3:0]    sdi
);
    // Premised req is a single-clk pulse

    wire [23:0] addr_kept;
    wire [1:0]  acc_kept;
    wire [7:0]  cmd_kept;
    wire        quad_en_kept;
    wire [3:0]  dummy_cycles_kept;
    dff #(
        .WIDTH(24+$clog2(`BUS_ACC_CNT)+8+1+4),
        .RESET("sync"),
        .VALID("async")
    ) req_keeper (
        .clk (clk ),
        .rstn(rstn),
        .vld (req ),
        .in  ({
            addr,
            acc,
            cmd,
            quad_en,
            dummy_cycles
        }),
        .out ({
            addr_kept,
            acc_kept,
            cmd_kept,
            quad_en_kept,
            dummy_cycles_kept
        })
    );

    localparam  IDLE  = 0,
                DOUT  = 1,
                DUMMY = 2,
                DIN   = 3;

    reg [7:0]   state;
    reg [7:0]   bit_index;
    wire [7:0]  bit_step = quad_en_kept?4:1;

    wire [31:0] txd = {cmd_kept, addr_kept};
    assign sdo = txd[bit_index+:4];

    (*async_reg = "true"*)
    reg [31:0]  rxd;
    assign resp_data = rxd;
    wire [7:0]  rxd_bit_index = bit_index^(acc_kept==`BUS_ACC_1B ? 0 : acc_kept==`BUS_ACC_2B ? 8 : 24);

    always @(posedge clk) begin
        if (rstn==0) begin
            state <= IDLE;
            csb <= `UNSEL;
            dir <= 4'h0;
            resp <= 0;
        end else case(state)
            default: begin
                sck <= `LAUNCHED;
                resp <= 0;
                if (req) begin
                    // jump to DOUT
                    state <= DOUT;
                    csb <= `SEL;
                    bit_index <= 32 - bit_step;
                    dir <= quad_en_kept?4'hf:4'h1;
                end
            end
            DOUT: begin
                sck <= ~sck;
                if (sck==`LATCHED) begin
                    if (bit_index) begin
                        bit_index <= bit_index - bit_step;
                    end else begin
                        dir <= 4'h0;
                        if (dummy_cycles_kept) begin
                            // jump to DUMMY
                            state <= DUMMY;
                            bit_index <= dummy_cycles_kept - 1;
                        end else begin
                            // jump to DIN
                            state <= DIN;
                            bit_index <= (acc_kept==`BUS_ACC_1B ? 8 : acc_kept==`BUS_ACC_2B ? 16 : 32) - bit_step;
                        end
                    end
                end
            end
            DUMMY: begin
                sck <= ~sck;
                if (sck==`LATCHED) begin
                    if (bit_index) begin
                        bit_index <= bit_index - 1;
                    end else begin
                        // jump to DIN
                        state <= DIN;
                        bit_index <= (acc_kept==`BUS_ACC_1B ? 8 : acc_kept==`BUS_ACC_2B ? 16 : 32) - bit_step;
                    end
                end
            end
            DIN: begin
                sck <= ~sck;
                if (sck==`LATCHED) begin
                    if (bit_index) begin
                        bit_index <= bit_index - bit_step;
                    end else begin
                        // jump to IDLE
                        state <= IDLE;
                        csb <= `UNSEL;
                        resp <= 1;
                    end
                end else /*sck == TO_LATCH*/ begin
                    if (quad_en_kept) begin
                        rxd[rxd_bit_index+:4] <= sdi;
                    end else begin
                        rxd[rxd_bit_index+:1] <= sdi[1];
                    end
                end
            end
        endcase
    end
endmodule
