`include "femto.vh"
`include "timescale.vh"

(* keep_hierarchy = "yes" *)
module qspinor_controller(
    input wire  clk,

    input wire  nor_rstn    ,
    input wire  qspinor_rstn,

    // user interface - bus read
    input wire[`NOR_VA_WIDTH-1:0]   nor_addr,
    input wire                      nor_w_rb,
    input wire[`BUS_ACC_WIDTH-1:0]  nor_acc,
    output wire[`BUS_WIDTH-1:0]     nor_rdata,
    input wire[`BUS_WIDTH-1:0]      nor_wdata,
    input wire                      nor_req,
    output wire                     nor_resp,
    output wire                     nor_fault,

    // user interface - ip access
    input wire[`QSPINOR_VA_WIDTH-1:0]   qspinor_addr,
    input wire                          qspinor_w_rb,
    input wire[`BUS_ACC_WIDTH-1:0]      qspinor_acc,
    output wire[`BUS_WIDTH-1:0]         qspinor_rdata,
    input wire[`BUS_WIDTH-1:0]          qspinor_wdata,
    input wire                          qspinor_req,
    output wire                         qspinor_resp,
    output wire                         qspinor_fault,

    // qspi nor peripheral interface
    output wire         qspi_csb,
    output wire         qspi_sclk,
    output wire[3:0]    qspi_dir,
    output wire[3:0]    qspi_mosi,
    input wire[3:0]     qspi_miso
);

    wire[1:0]   nor_width,           qspinor_width;
    wire        nor_tx_req,          qspinor_tx_req;
    wire        nor_txq_rdy,         qspinor_txq_rdy;
    wire[7:0]   nor_txq_d,           qspinor_txq_d;
    wire        nor_tx_resp,         qspinor_tx_resp;
    wire        nor_rx_req,          qspinor_rx_req;
    wire        nor_rxq_rdy,         qspinor_rxq_rdy;
    wire[7:0]   nor_rxq_d,           qspinor_rxq_d;
    wire        nor_rx_resp,         qspinor_rx_resp;
    wire        nor_dmy_req,         qspinor_dmy_req;
    wire        nor_dmy_dir,         qspinor_dmy_dir;
    wire[3:0]   nor_dmy_out_pattern, qspinor_dmy_out_pattern;
    wire        nor_dmy_resp,        qspinor_dmy_resp;
    wire        nor_qspi_csb,        qspinor_qspi_csb;

    wire[1:0]   cfg_cmd_width;
    wire[1:0]   cfg_addr_width;
    wire[1:0]   cfg_dmy_width;
    wire[1:0]   cfg_data_width;
    wire[7:0]   cfg_cmd_octet;
    wire[3:0]   cfg_dmy_cnt;
    wire        cfg_dmy_dir;
    wire[3:0]   cfg_dmy_out_pattern;

    qspinor_bus_read_controller qspinor_bus_read_controller (
        .clk (clk     ),
        .rstn(nor_rstn),

        .addr (nor_addr ),
        .w_rb (nor_w_rb ),
        .acc  (nor_acc  ),
        .rdata(nor_rdata),
        .wdata(nor_wdata),
        .req  (nor_req  ),
        .resp (nor_resp ),
        .fault(nor_fault),

        .cfg_cmd_width      (cfg_cmd_width      ),
        .cfg_addr_width     (cfg_addr_width     ),
        .cfg_dmy_width      (cfg_dmy_width      ),
        .cfg_data_width     (cfg_data_width     ),
        .cfg_cmd_octet      (cfg_cmd_octet      ),
        .cfg_dmy_cnt        (cfg_dmy_cnt        ),
        .cfg_dmy_dir        (cfg_dmy_dir        ),
        .cfg_dmy_out_pattern(cfg_dmy_out_pattern),

        .width          (nor_width          ),
        .tx_req         (nor_tx_req         ),
        .txq_rdy        (nor_txq_rdy        ),
        .txq_d          (nor_txq_d          ),
        .tx_resp        (nor_tx_resp        ),
        .rx_req         (nor_rx_req         ),
        .rxq_rdy        (nor_rxq_rdy        ),
        .rxq_d          (nor_rxq_d          ),
        .rx_resp        (nor_rx_resp        ),
        .dmy_req        (nor_dmy_req        ),
        .dmy_dir        (nor_dmy_dir        ),
        .dmy_out_pattern(nor_dmy_out_pattern),
        .dmy_resp       (nor_dmy_resp       ),

        .qspi_csb(nor_qspi_csb)
    );

    qspinor_ip_access_controller qspinor_ip_access_controller (
        .clk (clk         ),
        .rstn(qspinor_rstn),

        .addr (qspinor_addr ),
        .w_rb (qspinor_w_rb ),
        .acc  (qspinor_acc  ),
        .rdata(qspinor_rdata),
        .wdata(qspinor_wdata),
        .req  (qspinor_req  ),
        .resp (qspinor_resp ),
        .fault(qspinor_fault),

        .cfg_cmd_width      (cfg_cmd_width      ),
        .cfg_addr_width     (cfg_addr_width     ),
        .cfg_dmy_width      (cfg_dmy_width      ),
        .cfg_data_width     (cfg_data_width     ),
        .cfg_cmd_octet      (cfg_cmd_octet      ),
        .cfg_dmy_cnt        (cfg_dmy_cnt        ),
        .cfg_dmy_dir        (cfg_dmy_dir        ),
        .cfg_dmy_out_pattern(cfg_dmy_out_pattern),

        .width          (qspinor_width          ),
        .tx_req         (qspinor_tx_req         ),
        .txq_rdy        (qspinor_txq_rdy        ),
        .txq_d          (qspinor_txq_d          ),
        .tx_resp        (qspinor_tx_resp        ),
        .rx_req         (qspinor_rx_req         ),
        .rxq_rdy        (qspinor_rxq_rdy        ),
        .rxq_d          (qspinor_rxq_d          ),
        .rx_resp        (qspinor_rx_resp        ),
        .dmy_req        (qspinor_dmy_req        ),
        .dmy_dir        (qspinor_dmy_dir        ),
        .dmy_out_pattern(qspinor_dmy_out_pattern),
        .dmy_resp       (qspinor_dmy_resp       ),

        .qspi_csb(qspinor_qspi_csb)
    );

    wire[1:0]   io_width;
    wire        io_tx_req, io_rx_req, io_dmy_req;
    wire        io_txq_rdy, io_rxq_rdy;
    wire[7:0]   io_txq_d, io_rxq_d;
    wire        io_tx_resp, io_rx_resp, io_dmy_resp;
    wire        io_dmy_dir;
    wire[3:0]   io_dmy_out_pattern;

    assign nor_tx_resp = ~nor_qspi_csb & io_tx_resp;
    assign qspinor_tx_resp = ~qspinor_qspi_csb & io_tx_resp;
    assign nor_rx_resp = ~nor_qspi_csb & io_rx_resp;
    assign qspinor_rx_resp = ~qspinor_qspi_csb & io_rx_resp;
    assign nor_dmy_resp = ~nor_qspi_csb & io_dmy_resp;
    assign qspinor_dmy_resp = ~qspinor_qspi_csb & io_dmy_resp;
    assign nor_rxq_d = io_rxq_d;
    assign qspinor_rxq_d = io_rxq_d;

    assign io_width           = nor_qspi_csb ? qspinor_width           : nor_width          ;
    assign io_tx_req          = nor_qspi_csb ? qspinor_tx_req          : nor_tx_req         ;
    assign io_txq_rdy         = nor_qspi_csb ? qspinor_txq_rdy         : nor_txq_rdy        ;
    assign io_txq_d           = nor_qspi_csb ? qspinor_txq_d           : nor_txq_d          ;
    assign io_rx_req          = nor_qspi_csb ? qspinor_rx_req          : nor_rx_req         ;
    assign io_rxq_rdy         = nor_qspi_csb ? qspinor_rxq_rdy         : nor_rxq_rdy        ;
    assign io_dmy_req         = nor_qspi_csb ? qspinor_dmy_req         : nor_dmy_req        ;
    assign io_dmy_dir         = nor_qspi_csb ? qspinor_dmy_dir         : nor_dmy_dir        ;
    assign io_dmy_out_pattern = nor_qspi_csb ? qspinor_dmy_out_pattern : nor_dmy_out_pattern;

    qspinor_io qspinor_io (
        .clk (clk                    ),
        .rstn(nor_rstn & qspinor_rstn),

        .width(io_width),

        .tx_req (io_tx_req ),
        .txq_rdy(io_txq_rdy),
        .txq_d  (io_txq_d  ),
        .tx_resp(io_tx_resp),

        .rx_req (io_rx_req ),
        .rxq_rdy(io_rxq_rdy),
        .rxq_d  (io_rxq_d  ),
        .rx_resp(io_rx_resp),

        .dmy_req        (io_dmy_req        ),
        .dmy_dir        (io_dmy_dir        ),
        .dmy_out_pattern(io_dmy_out_pattern),
        .dmy_resp       (io_dmy_resp       ),

        .qspi_sclk(qspi_sclk),
        .qspi_dir (qspi_dir ),
        .qspi_mosi(qspi_mosi),
        .qspi_miso(qspi_miso)
    );
    assign  qspi_csb = nor_qspi_csb & qspinor_qspi_csb;

endmodule

// qspi nor master
// one byte/dummy pulse each req
module qspinor_io # (
    parameter   MODE = `QSPINOR_MODE,
    parameter   X1 = `QSPINOR_X1,
    parameter   X2 = `QSPINOR_X2,
    parameter   X4 = `QSPINOR_X4
)(
    input wire          clk,
    input wire          rstn,

    input wire[1:0]     width,

    input wire          tx_req,
    input wire          txq_rdy,
    input wire[7:0]     txq_d,
    output reg          tx_resp, // also queue req

    input wire          rx_req,
    input wire          rxq_rdy,
    output reg[7:0]     rxq_d,
    output reg          rx_resp, // also queue req

    input wire          dmy_req,
    input wire          dmy_dir,
    input wire[3:0]     dmy_out_pattern,
    output reg          dmy_resp,

    output reg          qspi_sclk,
    output reg[3:0]     qspi_dir,
    output reg[3:0]     qspi_mosi,
    input wire[3:0]     qspi_miso
);
    // state control
    localparam  IDLE     = 0 ,
                WAIT_TXQ = 1 ,
                WAIT_RXQ = 2 ,
                TX7_0    = 3 , TX7_1    = 4 , TX6_0    = 5 , TX6_1    = 6 , TX5_0    = 7 , TX5_1    = 8 , TX4_0    = 9 , TX4_1    = 10, TX3_0    = 11, TX3_1    = 12, TX2_0    = 13, TX2_1    = 14, TX1_0    = 15, TX1_1    = 16, TX0_0    = 17, TX0_1    = 18,
                RX7_0    = 19, RX7_1    = 20, RX6_0    = 21, RX6_1    = 22, RX5_0    = 23, RX5_1    = 24, RX4_0    = 25, RX4_1    = 26, RX3_0    = 27, RX3_1    = 28, RX2_0    = 29, RX2_1    = 30, RX1_0    = 31, RX1_1    = 32, RX0_0    = 33, RX0_1    = 34,
                DMYO_0   = 35, DMYO_1   = 36,
                DMYI_0   = 37, DMYI_1   = 38;

    reg[7:0] state, next_state;
    always @ (posedge clk)
        if (~rstn)
            state <= IDLE;
        else
            state <= next_state;

    always @ (*) case (state)
        IDLE, TX0_1, RX0_1, DMYO_1, DMYI_1:
            if (tx_req) begin
                if (txq_rdy)
                    next_state = (width==X1) ? TX7_0 : (width==X2) ? TX3_0 : /* X4 */ TX1_0;
                else
                    next_state = WAIT_TXQ;
            end else if (rx_req) begin
                if (rxq_rdy)
                    next_state = (width==X1) ? RX7_0 : (width==X2) ? RX3_0 : /* X4 */ RX1_0;
                else
                    next_state = WAIT_RXQ;
            end else if (dmy_req) begin
                if (dmy_dir)
                    next_state = DMYO_0;
                else
                    next_state = DMYI_0;
            end else
                next_state = IDLE;
        WAIT_TXQ:
            if (txq_rdy)
                next_state = (width==X1) ? TX7_0 : (width==X2) ? TX3_0 : /* X4 */ TX1_0;
            else
                next_state = WAIT_TXQ;
        WAIT_RXQ:
            if (rxq_rdy)
                next_state = (width==X1) ? RX7_0 : (width==X2) ? RX3_0 : /* X4 */ RX1_0;
            else
                next_state = WAIT_RXQ;
        TX7_0: next_state = TX7_1;
        TX7_1: next_state = TX6_0;
        TX6_0: next_state = TX6_1;
        TX6_1: next_state = TX5_0;
        TX5_0: next_state = TX5_1;
        TX5_1: next_state = TX4_0;
        TX4_0: next_state = TX4_1;
        TX4_1: next_state = TX3_0;
        TX3_0: next_state = TX3_1;
        TX3_1: next_state = TX2_0;
        TX2_0: next_state = TX2_1;
        TX2_1: next_state = TX1_0;
        TX1_0: next_state = TX1_1;
        TX1_1: next_state = TX0_0;
        TX0_0: next_state = TX0_1;
        RX7_0: next_state = RX7_1;
        RX7_1: next_state = RX6_0;
        RX6_0: next_state = RX6_1;
        RX6_1: next_state = RX5_0;
        RX5_0: next_state = RX5_1;
        RX5_1: next_state = RX4_0;
        RX4_0: next_state = RX4_1;
        RX4_1: next_state = RX3_0;
        RX3_0: next_state = RX3_1;
        RX3_1: next_state = RX2_0;
        RX2_0: next_state = RX2_1;
        RX2_1: next_state = RX1_0;
        RX1_0: next_state = RX1_1;
        RX1_1: next_state = RX0_0;
        RX0_0: next_state = RX0_1;
        DMYO_0: next_state = DMYO_1;
        DMYI_0: next_state = DMYI_1;
        default: // erroneous
            next_state = IDLE;
    endcase

    // cfg_cmd_octet done
    always @ (posedge clk) begin
        if (~rstn) begin
            tx_resp <= 1'b0;
            rx_resp <= 1'b0;
            dmy_resp <= 1'b0;
        end else if (state==TX0_0) begin
            tx_resp <= 1'b1;
        end else if (state==RX0_0) begin
            rx_resp <= 1'b1;
        end else if (state==DMYO_0 || state==DMYI_0) begin
            dmy_resp <= 1'b1;
        end else begin
            tx_resp <= 1'b0;
            rx_resp <= 1'b0;
            dmy_resp <= 1'b0;
        end
    end

    // qspi sclk
    always @ (*) case (state) // better use "assign" to propagate x
        TX7_0, TX6_0, TX5_0, TX4_0, TX3_0, TX2_0, TX1_0, TX0_0, RX7_0, RX6_0, RX5_0, RX4_0, RX3_0, RX2_0, RX1_0, RX0_0, DMYO_0, DMYI_0:
            qspi_sclk = 1'b0;
        TX7_1, TX6_1, TX5_1, TX4_1, TX3_1, TX2_1, TX1_1, TX0_1, RX7_1, RX6_1, RX5_1, RX4_1, RX3_1, RX2_1, RX1_1, RX0_1, DMYO_1, DMYI_1:
            qspi_sclk = 1'b1;
        default:
            qspi_sclk = MODE ? 1'b1 : 1'b0;
    endcase

    // qspi dir
    always @ (*) case (state) // better use "assign" to propagate x
        TX7_0, TX7_1, TX6_0, TX6_1, TX5_0, TX5_1, TX4_0, TX4_1, TX3_0, TX3_1, TX2_0, TX2_1, TX1_0, TX1_1, TX0_0, TX0_1, DMYO_0, DMYO_1:
            qspi_dir = (width==X1) ? {`IOR_DIR_IN, `IOR_DIR_IN, `IOR_DIR_IN, `IOR_DIR_OUT} :
                       (width==X2) ? {`IOR_DIR_IN, `IOR_DIR_IN, `IOR_DIR_OUT, `IOR_DIR_OUT} :
                       /* X4 */      {`IOR_DIR_OUT, `IOR_DIR_OUT, `IOR_DIR_OUT, `IOR_DIR_OUT};
        default:
            qspi_dir = {`IOR_DIR_IN, `IOR_DIR_IN, `IOR_DIR_IN, `IOR_DIR_IN};
    endcase

    // qspi mosi
    always @ (*) case (state) // better use "assign" to propagate x
        TX7_0, TX7_1: qspi_mosi = {3'dx, txq_d[7]};
        TX6_0, TX6_1: qspi_mosi = {3'dx, txq_d[6]};
        TX5_0, TX5_1: qspi_mosi = {3'dx, txq_d[5]};
        TX4_0, TX4_1: qspi_mosi = {3'dx, txq_d[4]};
        TX3_0, TX3_1:
            qspi_mosi = (width==X1) ? {3'dx, txq_d[3]} :
                        /* X2 */      {2'dx, txq_d[7:6]};
        TX2_0, TX2_1:
            qspi_mosi = (width==X1) ? {3'dx, txq_d[2]} :
                        /* X2 */      {2'dx, txq_d[5:4]};
        TX1_0, TX1_1:
            qspi_mosi = (width==X1) ? {3'dx, txq_d[1]} :
                        (width==X2) ? {2'dx, txq_d[3:2]} :
                        /* X4 */      txq_d[7:4];
        TX0_0, TX0_1:
            qspi_mosi = (width==X1) ? {3'dx, txq_d[0]} :
                        (width==X2) ? {2'dx, txq_d[1:0]} :
                        /* X4 */      txq_d[3:0];
        DMYO_0, DMYO_1: qspi_mosi = dmy_out_pattern;
        default: qspi_mosi = 4'dx;
    endcase

    // qspi miso
    always @ (posedge clk) case (state)
        RX7_0: rxq_d[7] <= qspi_miso[1];
        RX6_0: rxq_d[6] <= qspi_miso[1];
        RX5_0: rxq_d[5] <= qspi_miso[1];
        RX4_0: rxq_d[4] <= qspi_miso[1];
        RX3_0:
            if (width==X1)
                rxq_d[3] <= qspi_miso[1];
            else /* X2 */
                rxq_d[7:6] <= qspi_miso[1:0];
        RX2_0:
            if (width==X1)
                rxq_d[2] <= qspi_miso[1];
            else /* X2 */
                rxq_d[5:4] <= qspi_miso[1:0];
        RX1_0:
            if (width==X1)
                rxq_d[1] <= qspi_miso[1];
            else if (width==X2)
                rxq_d[3:2] <= qspi_miso[1:0];
            else /* X4 */
                rxq_d[7:4] <= qspi_miso;
        RX0_0:
            if (width==X1)
                rxq_d[0] <= qspi_miso[1];
            else if (width==X2)
                rxq_d[1:0] <= qspi_miso[1:0];
            else /* X4 */
                rxq_d[3:0] <= qspi_miso;
    endcase
endmodule

// qspi nor master
// 3-byte mode only
module qspinor_bus_read_controller (
    input wire  clk,
    input wire  rstn,

    // user interface
    input wire[`NOR_VA_WIDTH-1:0]   addr,
    input wire                      w_rb,
    input wire[`BUS_ACC_WIDTH-1:0]  acc,
    output reg[`BUS_WIDTH-1:0]      rdata,
    input wire[`BUS_WIDTH-1:0]      wdata,
    input wire                      req,
    output reg                      resp,
    output wire                     fault,

    // cfg from qspinor_ip_access_controller
    input wire[1:0]     cfg_cmd_width,
    input wire[1:0]     cfg_addr_width,
    input wire[1:0]     cfg_dmy_width,
    input wire[1:0]     cfg_data_width,

    input wire[7:0]     cfg_cmd_octet,
    input wire[3:0]     cfg_dmy_cnt,
    input wire          cfg_dmy_dir,
    input wire[3:0]     cfg_dmy_out_pattern,

    // interface with qspinor_io module
    output reg[1:0]     width,

    output reg          tx_req,
    output wire         txq_rdy,
    output reg[7:0]     txq_d,
    input wire          tx_resp, // also queue req

    output reg          rx_req,
    output wire         rxq_rdy,
    input wire[7:0]     rxq_d,
    input wire          rx_resp, // also queue req

    output reg          dmy_req,
    output wire         dmy_dir,
    output wire[3:0]    dmy_out_pattern,
    input wire          dmy_resp,

    // cs
    output wire qspi_csb
);
    // fault generation
    wire invld_addr = 0;
    wire invld_acc  = (addr[0]==1'd1 && acc!=`BUS_ACC_1B) || (addr[1:0]==2'd2 && acc==`BUS_ACC_4B);
    wire invld_wr   = w_rb;
    wire invld_d    = 0;

    wire invld      = |{invld_addr,invld_acc,invld_wr,invld_d};
    assign fault    = req & invld;

    // latch request
    wire[`NOR_VA_WIDTH-1:0]  req_addr;
    wire[`BUS_ACC_WIDTH-1:0] req_acc;
    dff #(
        .WIDTH(`NOR_VA_WIDTH+`BUS_ACC_WIDTH),
        .VALID("async")
    ) req_acc_dff (
        .clk(clk         ),
        .vld(req & ~invld),
        .in ({addr, acc}        ),
        .out({req_addr, req_acc})
    );

    // state
    localparam  IDLE  = 0 ,
                PREP  = 1 ,
                CMD   = 2 ,
                ADDR2 = 3 ,  ADDR1 = 4 ,  ADDR0 = 5 ,
                DMY15 = 6 ,  DMY14 = 7 ,  DMY13 = 8 ,  DMY12 = 9 ,  DMY11 = 10,  DMY10 = 11,  DMY9  = 12,  DMY8  = 13,  DMY7  = 14,  DMY6  = 15,  DMY5  = 16,  DMY4  = 17,  DMY3  = 18,  DMY2  = 19,  DMY1  = 20,
                DATA3 = 21,  DATA2 = 22,  DATA1 = 23,  DATA0 = 24;

    reg[7:0]    state, next_state;
    always @ (posedge clk)
        if (~rstn)
            state <= IDLE;
        else
            state <= next_state;

    always @ (*) case (state)
        IDLE: next_state = (req & ~invld) ? PREP : IDLE;
        PREP: next_state = CMD;
        CMD: next_state = tx_resp ? ADDR2 : CMD;
        ADDR2: next_state = tx_resp ? ADDR1 : ADDR2;
        ADDR1: next_state = tx_resp ? ADDR0 : ADDR1;
        ADDR0:
            if (tx_resp) case (cfg_dmy_cnt)
                0: case (req_acc)
                    `BUS_ACC_4B: next_state = DATA3;
                    `BUS_ACC_2B: next_state = DATA1;
                    default:     next_state = DATA0; // BUS_ACC_1B
                endcase
                1 : next_state = DMY1 ;
                2 : next_state = DMY2 ;
                3 : next_state = DMY3 ;
                4 : next_state = DMY4 ;
                5 : next_state = DMY5 ;
                6 : next_state = DMY6 ;
                7 : next_state = DMY7 ;
                8 : next_state = DMY8 ;
                9 : next_state = DMY9 ;
                10: next_state = DMY10;
                11: next_state = DMY11;
                12: next_state = DMY12;
                13: next_state = DMY13;
                14: next_state = DMY14;
                15: next_state = DMY15;
            endcase else
                next_state = ADDR0;
        DMY15: next_state = dmy_resp ? DMY14 : DMY15;
        DMY14: next_state = dmy_resp ? DMY13 : DMY14;
        DMY13: next_state = dmy_resp ? DMY12 : DMY13;
        DMY12: next_state = dmy_resp ? DMY11 : DMY12;
        DMY11: next_state = dmy_resp ? DMY10 : DMY11;
        DMY10: next_state = dmy_resp ? DMY9  : DMY10;
        DMY9 : next_state = dmy_resp ? DMY8  : DMY9 ;
        DMY8 : next_state = dmy_resp ? DMY7  : DMY8 ;
        DMY7 : next_state = dmy_resp ? DMY6  : DMY7 ;
        DMY6 : next_state = dmy_resp ? DMY5  : DMY6 ;
        DMY5 : next_state = dmy_resp ? DMY4  : DMY5 ;
        DMY4 : next_state = dmy_resp ? DMY3  : DMY4 ;
        DMY3 : next_state = dmy_resp ? DMY2  : DMY3 ;
        DMY2 : next_state = dmy_resp ? DMY1  : DMY2 ;
        DMY1 :
            if (dmy_resp) case (req_acc)
                `BUS_ACC_4B: next_state = DATA3;
                `BUS_ACC_2B: next_state = DATA1;
                default:     next_state = DATA0; // BUS_ACC_1B
            endcase else
                next_state = DMY1;
        DATA3: next_state = rx_resp ? DATA2 : DATA3;
        DATA2: next_state = rx_resp ? DATA1 : DATA2;
        DATA1: next_state = rx_resp ? DATA0 : DATA1;
        DATA0: next_state = rx_resp ? IDLE : DATA0;
        default: next_state = IDLE;
    endcase

    // control
    assign qspi_csb = state==IDLE;

    always @ (*) case (next_state) // better use assign to propagate x
        CMD: begin
            width = cfg_cmd_width;
            tx_req = (state==PREP);
            rx_req = 0;
            dmy_req = 0;
        end
        ADDR2: begin
            width = cfg_addr_width;
            tx_req = tx_resp;
            rx_req = 0;
            dmy_req = 0;
        end
        ADDR1: begin
            width = cfg_addr_width;
            tx_req = tx_resp;
            rx_req = 0;
            dmy_req = 0;
        end
        ADDR0: begin
            width = cfg_addr_width;
            tx_req = tx_resp;
            rx_req = 0;
            dmy_req = 0;
        end
        DMY15: begin
            width = cfg_dmy_width;
            tx_req = 0;
            rx_req = 0;
            dmy_req = tx_resp;
        end
        DMY14, DMY13, DMY12, DMY11, DMY10, DMY9, DMY8, DMY7, DMY6, DMY5, DMY4, DMY3, DMY2, DMY1: begin
            width = cfg_dmy_width;
            tx_req = 0;
            rx_req = 0;
            dmy_req = dmy_resp;
        end
        DATA3: begin
            width = cfg_data_width;
            tx_req = 0;
            rx_req = dmy_resp | tx_resp;
            dmy_req = 0;
        end
        DATA2: begin
            width = cfg_data_width;
            tx_req = 0;
            rx_req = rx_resp;
            dmy_req = 0;
        end
        DATA1, DATA0: begin
            width = cfg_data_width;
            tx_req = 0;
            rx_req = dmy_resp | tx_resp | rx_resp;
            dmy_req = 0;
        end
        default: begin
            width = 2'dx;
            tx_req = 0;
            rx_req = 0;
            dmy_req = 0;
        end
    endcase

    always @ (posedge clk) case (next_state)
        CMD:     txq_d <= cfg_cmd_octet;
        ADDR2:   txq_d <= req_addr[23:16];
        ADDR1:   txq_d <= req_addr[15:8];
        ADDR0:   txq_d <= req_addr[7:0];
        default: txq_d <= 8'dx;
    endcase

    assign txq_rdy = 1;
    assign rxq_rdy = 1;
    assign dmy_dir = cfg_dmy_dir;
    assign dmy_out_pattern = cfg_dmy_out_pattern;

    // resp generation
    always @ (posedge clk) begin
        if (~rstn)
            resp <= 0;
        else if ((state!=IDLE) && (next_state==IDLE))
            resp <= 1;
        else
            resp <= 0;
    end

    // rdata
    always @ (posedge clk) begin
        if (rx_resp) case (req_acc)
            `BUS_ACC_4B:
                if (state==DATA3)
                    rdata[7:0] <= rxq_d;
                else if (state==DATA2)
                    rdata[15:8] <= rxq_d;
                else if (state==DATA1)
                    rdata[23:16] <= rxq_d;
                else if (state==DATA0)
                    rdata[31:24] <= rxq_d;
            `BUS_ACC_2B:
                if (state==DATA1)
                    rdata[7:0] <= rxq_d;
                else if (state==DATA0)
                    rdata[15:8] <= rxq_d;
            default:
                if (state==DATA0)
                    rdata[7:0] <= rxq_d;
        endcase
    end
endmodule

module qspinor_ip_access_controller(
    input wire  clk,
    input wire  rstn,

    // user interface
    input wire[`QSPINOR_VA_WIDTH-1:0]   addr,
    input wire                          w_rb,
    input wire[`BUS_ACC_WIDTH-1:0]      acc,
    output reg[`BUS_WIDTH-1:0]          rdata,
    input wire[`BUS_WIDTH-1:0]          wdata,
    input wire                          req,
    output reg                          resp,
    output wire                         fault,

    // cfg to qspinor_bus_read_controller
    output wire[1:0]    cfg_cmd_width,
    output wire[1:0]    cfg_addr_width,
    output wire[1:0]    cfg_dmy_width,
    output wire[1:0]    cfg_data_width,

    output wire[7:0]    cfg_cmd_octet,
    output wire[3:0]    cfg_dmy_cnt,
    output wire         cfg_dmy_dir,
    output wire[3:0]    cfg_dmy_out_pattern,

    // interface with qspinor_io module
    output wire[1:0]    width,

    output reg          tx_req,
    output wire         txq_rdy,
    output wire[7:0]    txq_d,
    input wire          tx_resp, // also queue req

    output reg          rx_req,
    output wire         rxq_rdy,
    input wire[7:0]     rxq_d,
    input wire          rx_resp, // also queue req

    output reg          dmy_req,
    output wire         dmy_dir,
    output wire[3:0]    dmy_out_pattern,
    input wire          dmy_resp,

    // cs
    output reg  qspi_csb
);

    /*
     * Register map
     *  Name   | Address | Size | Access | Note
     *  IPCSR  | 0       | 2    | R/W    | -
     *  TXD    | 2       | 1    | W      | -
     *  RXD    | 3       | 1    | R      | -
     *  TXQCSR | 4       | 1    | R/W    | -
     *  RXQCSR | 5       | 1    | R/W    | -
     *  NORCSR | 6       | 2    | R/W    | -
     *
     * IPCSR
     *  DUMMY_OUT_PATTERN(15:12) | COUNT(11:8) | WIDTH(7:6) | DUMMY(5) | DIR(4) | (3:2) | BUSY(1) | SEL(0)
     * TXQCSR
     *  (7:2) | CLR(1) | RDY(0)
     * RXQCSR
     *  (7:2) | CLR(1) | RDY(0)
     * NORCSR
     *  CMD(15:8) | DUMMY_COUNT(7:4) | DUMMY_DIR(3) | MODE(2:0)
     */

    `define IP_DOP      15:12
    `define IP_CNT      11:8
    `define IP_WID      7:6
    `define IP_DMY      5
    `define IP_DIR      4
    `define IP_INVLD    2
    `define IP_BSY      1
    `define IP_SEL      0

    `define TXQ_CLR     1
    `define RXQ_CLR     1

    `define NOR_CMD     15:8
    `define NOR_DMYCNT  7:4
    `define NOR_DMYDIR  3
    `define NOR_MODE    2:0

    // fault generation
    wire invld_addr = (addr==1) || (addr==7);
    wire invld_acc  = (addr==0 || addr==6) ? (acc!=`BUS_ACC_2B) : (acc!=`BUS_ACC_1B);
    wire invld_wr   = w_rb ? (addr==3) : (addr==2);
    wire invld_d    = 0;

    wire invld      = |{invld_addr,invld_acc,invld_wr,invld_d};
    assign fault    = req & invld;

    // data queues
    wire      txq_w = req & ~invld & (addr==2);
    wire[7:0] txq_wd = wdata[7:0];
    wire      txq_full, txq_empty;
    wire      txq_clr = req & ~invld & (addr==4) & w_rb & (wdata[`TXQ_CLR]);

    wire      txq_r;
    wire[7:0] txq_rd_raw, txq_rd;
    fifo # (
        .WIDTH(8),
        .DEPTH(16),
        .CLEAR("sync")
    ) qspinor_txq (
        .clk  (clk ),
        .rstn (rstn),
        .din  (txq_wd  ),
        .w    (txq_w   ),
        .full (txq_full),
        .clr  (txq_clr ),
        .dout (txq_rd_raw),
        .r    (txq_r    ),
        .empty(txq_empty)
    );

    dff # (
        .WIDTH(8),
        .VALID("async")
    ) txq_rd_dff (
        .clk(clk       ),
        .vld(txq_r     ),
        .in (txq_rd_raw),
        .out(txq_rd    )
    );

    wire      rxq_r = req & ~invld & (addr==3);
    wire[7:0] rxq_rd;
    wire      rxq_empty, rxq_full;
    wire      rxq_clr = req & ~invld & (addr==5) & w_rb & (wdata[`RXQ_CLR]);

    wire      rxq_w;
    wire[7:0] rxq_wd;

    fifo # (
        .WIDTH(8),
        .DEPTH(16),
        .CLEAR("sync")
    ) qspinor_rxq (
        .clk  (clk ),
        .rstn (rstn),
        .dout (rxq_rd   ),
        .r    (rxq_r    ),
        .empty(rxq_empty),
        .clr  (rxq_clr  ),
        .din  (rxq_wd  ),
        .w    (rxq_w   ),
        .full (rxq_full)
    );

    // data interaction busy indicator
    wire    busy;
    wire    seq_req = req && ~invld && w_rb && addr==0;

    // latch request for data interaction
    reg[15:0]   queued_ipcsr_wdata;
    reg         queued;
    always @ (posedge clk) begin
        if (~rstn) begin
            queued <= 0;
        end else begin
            if (seq_req & busy) begin
                queued <= 1;
                queued_ipcsr_wdata <= wdata[15:0];
            end

            if (~busy)
                queued <= 0;
        end
    end

    wire[15:0]  normal_ipcsr_wdata = wdata[15:0];
    wire        delayed_seq_req = queued & ~busy;
    wire        normal_seq_req = seq_req & ~busy;
    wire[15:0]  ipcsr_wdata;
    dff # (
        .WIDTH(16     ),
        .VALID("async")
    ) ipcsr_wdata_dff (
        .clk(clk        ),
        .vld(normal_seq_req | delayed_seq_req),
        .in (delayed_seq_req ? queued_ipcsr_wdata : normal_ipcsr_wdata),
        .out(ipcsr_wdata)
    );

    // resp generation
    always @ (posedge clk) begin
        if (~rstn)
            resp <= 0;
        else if (busy)
            resp <= (req & ~invld & ~seq_req) | delayed_seq_req;
        else
            resp <= (req & ~invld) | delayed_seq_req;
    end

    // register access
    reg[15:0]   norcsr;
    always @ (posedge clk) begin
        if (~rstn)
            norcsr <= 0;
        else if (req & ~invld) case (addr)
            0: rdata <= {30'd0, busy, ~qspi_csb};
            3: rdata <= {24'd0, rxq_rd};
            4: rdata <= {31'd0, ~txq_full};
            5: rdata <= {31'd0, ~rxq_empty};
            6:
                if (w_rb)
                    norcsr <= wdata[15:0];
                else
                    rdata <= {16'd0, norcsr};
        endcase
    end

    always @ (posedge clk) begin
        if (~rstn)
            qspi_csb <= 1'b1;
        else if (normal_seq_req | delayed_seq_req)
            qspi_csb <= ~ipcsr_wdata[`IP_SEL];
    end

    // cfg out for bus read module
    // Modes: 0-111 1-112 2-114 3-122 4-144 5-222 6-444
    assign cfg_cmd_width = (norcsr[`NOR_MODE]==6) ? `QSPINOR_X4 :
                           (norcsr[`NOR_MODE]==5) ? `QSPINOR_X2 :
                           /* otherwise */    `QSPINOR_X1;
    assign cfg_addr_width = (norcsr[`NOR_MODE]==6) ? `QSPINOR_X4 :
                            (norcsr[`NOR_MODE]==5) ? `QSPINOR_X2 :
                            (norcsr[`NOR_MODE]==4) ? `QSPINOR_X4 :
                            (norcsr[`NOR_MODE]==3) ? `QSPINOR_X2 :
                            /* norcsr[`NOR_MODE] */    `QSPINOR_X1;
    assign cfg_dmy_width = cfg_addr_width;
    assign cfg_data_width = (norcsr[`NOR_MODE]==6) ? `QSPINOR_X4 :
                            (norcsr[`NOR_MODE]==5) ? `QSPINOR_X2 :
                            (norcsr[`NOR_MODE]==4) ? `QSPINOR_X4 :
                            (norcsr[`NOR_MODE]==3) ? `QSPINOR_X2 :
                            (norcsr[`NOR_MODE]==2) ? `QSPINOR_X4 :
                            (norcsr[`NOR_MODE]==1) ? `QSPINOR_X2 :
                            /* otherwise */    `QSPINOR_X1;
    assign  cfg_cmd_octet = norcsr[`NOR_CMD];
    assign  cfg_dmy_cnt = norcsr[`NOR_DMYCNT];
    assign  cfg_dmy_dir = norcsr[`NOR_DMYDIR];
    assign  cfg_dmy_out_pattern = 4'd0;


    // data interaction state control
    localparam  IDLE          = 0 ,
                PREP_TLOOP    = 1 ,
                PREP_TCNT15   = 2 , PREP_TCNT14   = 3 , PREP_TCNT13   = 4 , PREP_TCNT12   = 5 , PREP_TCNT11   = 6 , PREP_TCNT10   = 7 , PREP_TCNT9    = 8 , PREP_TCNT8    = 9 , PREP_TCNT7    = 10, PREP_TCNT6    = 11, PREP_TCNT5    = 12, PREP_TCNT4    = 13, PREP_TCNT3    = 14, PREP_TCNT2    = 15, PREP_TCNT1    = 16,
                PREP_RLOOP    = 17,
                PREP_RCNT15   = 18, PREP_RCNT14   = 19, PREP_RCNT13   = 20, PREP_RCNT12   = 21, PREP_RCNT11   = 22, PREP_RCNT10   = 23, PREP_RCNT9    = 24, PREP_RCNT8    = 25, PREP_RCNT7    = 26, PREP_RCNT6    = 27, PREP_RCNT5    = 28, PREP_RCNT4    = 29, PREP_RCNT3    = 30, PREP_RCNT2    = 31, PREP_RCNT1    = 32,
                PREP_DCNT16   = 33, PREP_DCNT15   = 34, PREP_DCNT14   = 35, PREP_DCNT13   = 36, PREP_DCNT12   = 37, PREP_DCNT11   = 38, PREP_DCNT10   = 39, PREP_DCNT9    = 40, PREP_DCNT8    = 41, PREP_DCNT7    = 42, PREP_DCNT6    = 43, PREP_DCNT5    = 44, PREP_DCNT4    = 45, PREP_DCNT3    = 46, PREP_DCNT2    = 47, PREP_DCNT1    = 48,
                TLOOP         = 49,
                TCNT15        = 50, TCNT14        = 51, TCNT13        = 52, TCNT12        = 53, TCNT11        = 54, TCNT10        = 55, TCNT9         = 56, TCNT8         = 57, TCNT7         = 58, TCNT6         = 59, TCNT5         = 60, TCNT4         = 61, TCNT3         = 62, TCNT2         = 63, TCNT1         = 64,
                RLOOP         = 65,
                RCNT15        = 66, RCNT14        = 67, RCNT13        = 68, RCNT12        = 69, RCNT11        = 70, RCNT10        = 71, RCNT9         = 72, RCNT8         = 73, RCNT7         = 74, RCNT6         = 75, RCNT5         = 76, RCNT4         = 77, RCNT3         = 78, RCNT2         = 79, RCNT1         = 80,
                DCNT16        = 81, DCNT15        = 82, DCNT14        = 83, DCNT13        = 84, DCNT12        = 85, DCNT11        = 86, DCNT10        = 87, DCNT9         = 88, DCNT8         = 89, DCNT7         = 90, DCNT6         = 91, DCNT5         = 92, DCNT4         = 93, DCNT3         = 94, DCNT2         = 95, DCNT1         = 96;

    reg[7:0]    state, next_state;
    always @ (posedge clk)
        if (~rstn)
            state <= IDLE;
        else
            state <= next_state;

    assign  busy = (state!=IDLE);

    always @ (*) case (state)
        IDLE:
            if (delayed_seq_req | seq_req) begin
                if (ipcsr_wdata[`IP_DMY]) case (ipcsr_wdata[`IP_CNT]) // dummy
                    default: next_state = qspi_csb ? PREP_DCNT16 : DCNT16;
                    1 : next_state = qspi_csb ? PREP_DCNT1  : DCNT1 ;
                    2 : next_state = qspi_csb ? PREP_DCNT2  : DCNT2 ;
                    3 : next_state = qspi_csb ? PREP_DCNT3  : DCNT3 ;
                    4 : next_state = qspi_csb ? PREP_DCNT4  : DCNT4 ;
                    5 : next_state = qspi_csb ? PREP_DCNT5  : DCNT5 ;
                    6 : next_state = qspi_csb ? PREP_DCNT6  : DCNT6 ;
                    7 : next_state = qspi_csb ? PREP_DCNT7  : DCNT7 ;
                    8 : next_state = qspi_csb ? PREP_DCNT8  : DCNT8 ;
                    9 : next_state = qspi_csb ? PREP_DCNT9  : DCNT9 ;
                    10: next_state = qspi_csb ? PREP_DCNT10 : DCNT10;
                    11: next_state = qspi_csb ? PREP_DCNT11 : DCNT11;
                    12: next_state = qspi_csb ? PREP_DCNT12 : DCNT12;
                    13: next_state = qspi_csb ? PREP_DCNT13 : DCNT13;
                    14: next_state = qspi_csb ? PREP_DCNT14 : DCNT14;
                    15: next_state = qspi_csb ? PREP_DCNT15 : DCNT15;
                endcase else if (ipcsr_wdata[`IP_DIR]) case (ipcsr_wdata[`IP_CNT]) // tx
                    default: next_state = qspi_csb ? PREP_TLOOP : ~txq_empty ? TLOOP : IDLE ;
                    1 : next_state = qspi_csb ? PREP_TCNT1  : TCNT1  ;
                    2 : next_state = qspi_csb ? PREP_TCNT2  : TCNT2  ;
                    3 : next_state = qspi_csb ? PREP_TCNT3  : TCNT3  ;
                    4 : next_state = qspi_csb ? PREP_TCNT4  : TCNT4  ;
                    5 : next_state = qspi_csb ? PREP_TCNT5  : TCNT5  ;
                    6 : next_state = qspi_csb ? PREP_TCNT6  : TCNT6  ;
                    7 : next_state = qspi_csb ? PREP_TCNT7  : TCNT7  ;
                    8 : next_state = qspi_csb ? PREP_TCNT8  : TCNT8  ;
                    9 : next_state = qspi_csb ? PREP_TCNT9  : TCNT9  ;
                    10: next_state = qspi_csb ? PREP_TCNT10 : TCNT10 ;
                    11: next_state = qspi_csb ? PREP_TCNT11 : TCNT11 ;
                    12: next_state = qspi_csb ? PREP_TCNT12 : TCNT12 ;
                    13: next_state = qspi_csb ? PREP_TCNT13 : TCNT13 ;
                    14: next_state = qspi_csb ? PREP_TCNT14 : TCNT14 ;
                    15: next_state = qspi_csb ? PREP_TCNT15 : TCNT15 ;
                endcase else case (ipcsr_wdata[`IP_CNT]) // rx
                    default: next_state = qspi_csb ? PREP_RLOOP : ~rxq_full ? RLOOP : IDLE ;
                    1 : next_state = qspi_csb ? PREP_RCNT1  : RCNT1  ;
                    2 : next_state = qspi_csb ? PREP_RCNT2  : RCNT2  ;
                    3 : next_state = qspi_csb ? PREP_RCNT3  : RCNT3  ;
                    4 : next_state = qspi_csb ? PREP_RCNT4  : RCNT4  ;
                    5 : next_state = qspi_csb ? PREP_RCNT5  : RCNT5  ;
                    6 : next_state = qspi_csb ? PREP_RCNT6  : RCNT6  ;
                    7 : next_state = qspi_csb ? PREP_RCNT7  : RCNT7  ;
                    8 : next_state = qspi_csb ? PREP_RCNT8  : RCNT8  ;
                    9 : next_state = qspi_csb ? PREP_RCNT9  : RCNT9  ;
                    10: next_state = qspi_csb ? PREP_RCNT10 : RCNT10 ;
                    11: next_state = qspi_csb ? PREP_RCNT11 : RCNT11 ;
                    12: next_state = qspi_csb ? PREP_RCNT12 : RCNT12 ;
                    13: next_state = qspi_csb ? PREP_RCNT13 : RCNT13 ;
                    14: next_state = qspi_csb ? PREP_RCNT14 : RCNT14 ;
                    15: next_state = qspi_csb ? PREP_RCNT15 : RCNT15 ;
                endcase
            end else
                next_state = IDLE;
        PREP_TLOOP  : next_state = ~txq_empty ? TLOOP : IDLE;
        PREP_TCNT15 : next_state = TCNT15;
        PREP_TCNT14 : next_state = TCNT14;
        PREP_TCNT13 : next_state = TCNT13;
        PREP_TCNT12 : next_state = TCNT12;
        PREP_TCNT11 : next_state = TCNT11;
        PREP_TCNT10 : next_state = TCNT10;
        PREP_TCNT9  : next_state = TCNT9 ;
        PREP_TCNT8  : next_state = TCNT8 ;
        PREP_TCNT7  : next_state = TCNT7 ;
        PREP_TCNT6  : next_state = TCNT6 ;
        PREP_TCNT5  : next_state = TCNT5 ;
        PREP_TCNT4  : next_state = TCNT4 ;
        PREP_TCNT3  : next_state = TCNT3 ;
        PREP_TCNT2  : next_state = TCNT2 ;
        PREP_TCNT1  : next_state = TCNT1 ;
        PREP_RLOOP  : next_state = ~rxq_full ? RLOOP : IDLE;
        PREP_RCNT15 : next_state = RCNT15;
        PREP_RCNT14 : next_state = RCNT14;
        PREP_RCNT13 : next_state = RCNT13;
        PREP_RCNT12 : next_state = RCNT12;
        PREP_RCNT11 : next_state = RCNT11;
        PREP_RCNT10 : next_state = RCNT10;
        PREP_RCNT9  : next_state = RCNT9 ;
        PREP_RCNT8  : next_state = RCNT8 ;
        PREP_RCNT7  : next_state = RCNT7 ;
        PREP_RCNT6  : next_state = RCNT6 ;
        PREP_RCNT5  : next_state = RCNT5 ;
        PREP_RCNT4  : next_state = RCNT4 ;
        PREP_RCNT3  : next_state = RCNT3 ;
        PREP_RCNT2  : next_state = RCNT2 ;
        PREP_RCNT1  : next_state = RCNT1 ;
        PREP_DCNT16 : next_state = DCNT16;
        PREP_DCNT15 : next_state = DCNT15;
        PREP_DCNT14 : next_state = DCNT14;
        PREP_DCNT13 : next_state = DCNT13;
        PREP_DCNT12 : next_state = DCNT12;
        PREP_DCNT11 : next_state = DCNT11;
        PREP_DCNT10 : next_state = DCNT10;
        PREP_DCNT9  : next_state = DCNT9 ;
        PREP_DCNT8  : next_state = DCNT8 ;
        PREP_DCNT7  : next_state = DCNT7 ;
        PREP_DCNT6  : next_state = DCNT6 ;
        PREP_DCNT5  : next_state = DCNT5 ;
        PREP_DCNT4  : next_state = DCNT4 ;
        PREP_DCNT3  : next_state = DCNT3 ;
        PREP_DCNT2  : next_state = DCNT2 ;
        PREP_DCNT1  : next_state = DCNT1 ;
        TLOOP :  next_state = (tx_resp && txq_empty) ? IDLE : TLOOP;
        TCNT15:  next_state = tx_resp ? TCNT14 : TCNT15;
        TCNT14:  next_state = tx_resp ? TCNT13 : TCNT14;
        TCNT13:  next_state = tx_resp ? TCNT12 : TCNT13;
        TCNT12:  next_state = tx_resp ? TCNT11 : TCNT12;
        TCNT11:  next_state = tx_resp ? TCNT10 : TCNT11;
        TCNT10:  next_state = tx_resp ? TCNT9  : TCNT10;
        TCNT9 :  next_state = tx_resp ? TCNT8  : TCNT9 ;
        TCNT8 :  next_state = tx_resp ? TCNT7  : TCNT8 ;
        TCNT7 :  next_state = tx_resp ? TCNT6  : TCNT7 ;
        TCNT6 :  next_state = tx_resp ? TCNT5  : TCNT6 ;
        TCNT5 :  next_state = tx_resp ? TCNT4  : TCNT5 ;
        TCNT4 :  next_state = tx_resp ? TCNT3  : TCNT4 ;
        TCNT3 :  next_state = tx_resp ? TCNT2  : TCNT3 ;
        TCNT2 :  next_state = tx_resp ? TCNT1  : TCNT2 ;
        TCNT1 :  next_state = tx_resp ? IDLE : TCNT1;
        RLOOP :  next_state = (rx_resp && rxq_full) ? IDLE : RLOOP;
        RCNT15:  next_state = rx_resp ? RCNT14 : RCNT15;
        RCNT14:  next_state = rx_resp ? RCNT13 : RCNT14;
        RCNT13:  next_state = rx_resp ? RCNT12 : RCNT13;
        RCNT12:  next_state = rx_resp ? RCNT11 : RCNT12;
        RCNT11:  next_state = rx_resp ? RCNT10 : RCNT11;
        RCNT10:  next_state = rx_resp ? RCNT9  : RCNT10;
        RCNT9 :  next_state = rx_resp ? RCNT8  : RCNT9 ;
        RCNT8 :  next_state = rx_resp ? RCNT7  : RCNT8 ;
        RCNT7 :  next_state = rx_resp ? RCNT6  : RCNT7 ;
        RCNT6 :  next_state = rx_resp ? RCNT5  : RCNT6 ;
        RCNT5 :  next_state = rx_resp ? RCNT4  : RCNT5 ;
        RCNT4 :  next_state = rx_resp ? RCNT3  : RCNT4 ;
        RCNT3 :  next_state = rx_resp ? RCNT2  : RCNT3 ;
        RCNT2 :  next_state = rx_resp ? RCNT1  : RCNT2 ;
        RCNT1 :  next_state = rx_resp ? IDLE : RCNT1;
        DCNT16:  next_state = dmy_resp ? DCNT15 : DCNT16;
        DCNT15:  next_state = dmy_resp ? DCNT14 : DCNT15;
        DCNT14:  next_state = dmy_resp ? DCNT13 : DCNT14;
        DCNT13:  next_state = dmy_resp ? DCNT12 : DCNT13;
        DCNT12:  next_state = dmy_resp ? DCNT11 : DCNT12;
        DCNT11:  next_state = dmy_resp ? DCNT10 : DCNT11;
        DCNT10:  next_state = dmy_resp ? DCNT9  : DCNT10;
        DCNT9 :  next_state = dmy_resp ? DCNT8  : DCNT9 ;
        DCNT8 :  next_state = dmy_resp ? DCNT7  : DCNT8 ;
        DCNT7 :  next_state = dmy_resp ? DCNT6  : DCNT7 ;
        DCNT6 :  next_state = dmy_resp ? DCNT5  : DCNT6 ;
        DCNT5 :  next_state = dmy_resp ? DCNT4  : DCNT5 ;
        DCNT4 :  next_state = dmy_resp ? DCNT3  : DCNT4 ;
        DCNT3 :  next_state = dmy_resp ? DCNT2  : DCNT3 ;
        DCNT2 :  next_state = dmy_resp ? DCNT1  : DCNT2 ;
        DCNT1 :  next_state = dmy_resp ? IDLE : DCNT1;
        default: next_state = IDLE;
    endcase

    // data interaction control
    assign  width = ipcsr_wdata[`IP_WID];

    assign  txq_rdy = ~txq_empty;
    assign  txq_d = txq_rd;
    assign  txq_r = tx_req;

    assign  rxq_rdy = ~rxq_full;
    assign  rxq_wd = rxq_d;
    assign  rxq_w = rx_resp;

    assign  dmy_dir = ipcsr_wdata[`IP_DIR];
    assign  dmy_out_pattern = ipcsr_wdata[`IP_DOP];

    always @ (*) case (next_state) // better use assign to propagate x
        TLOOP:   begin tx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_TLOOP || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT15:  begin tx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_TCNT15; rx_req = 0; dmy_req = 0; end
        TCNT14:  begin tx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_TCNT14 || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT13:  begin tx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_TCNT13 || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT12:  begin tx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_TCNT12 || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT11:  begin tx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_TCNT11 || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT10:  begin tx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_TCNT10 || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT9 :  begin tx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_TCNT9  || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT8 :  begin tx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_TCNT8  || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT7 :  begin tx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_TCNT7  || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT6 :  begin tx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_TCNT6  || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT5 :  begin tx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_TCNT5  || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT4 :  begin tx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_TCNT4  || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT3 :  begin tx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_TCNT3  || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT2 :  begin tx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_TCNT2  || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT1 :  begin tx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_TCNT1  || tx_resp; rx_req = 0; dmy_req = 0; end
        RLOOP:   begin rx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_RLOOP || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT15:  begin rx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_RCNT15; tx_req = 0; dmy_req = 0; end
        RCNT14:  begin rx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_RCNT14 || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT13:  begin rx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_RCNT13 || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT12:  begin rx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_RCNT12 || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT11:  begin rx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_RCNT11 || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT10:  begin rx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_RCNT10 || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT9 :  begin rx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_RCNT9  || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT8 :  begin rx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_RCNT8  || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT7 :  begin rx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_RCNT7  || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT6 :  begin rx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_RCNT6  || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT5 :  begin rx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_RCNT5  || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT4 :  begin rx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_RCNT4  || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT3 :  begin rx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_RCNT3  || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT2 :  begin rx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_RCNT2  || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT1 :  begin rx_req  = (normal_seq_req | delayed_seq_req) || state==PREP_RCNT1  || rx_resp; tx_req = 0; dmy_req = 0; end
        DCNT16:  begin dmy_req = (normal_seq_req | delayed_seq_req) || state==PREP_DCNT16; tx_req = 0; rx_req = 0; end
        DCNT15:  begin dmy_req = (normal_seq_req | delayed_seq_req) || state==PREP_DCNT14 || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT14:  begin dmy_req = (normal_seq_req | delayed_seq_req) || state==PREP_DCNT14 || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT13:  begin dmy_req = (normal_seq_req | delayed_seq_req) || state==PREP_DCNT13 || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT12:  begin dmy_req = (normal_seq_req | delayed_seq_req) || state==PREP_DCNT12 || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT11:  begin dmy_req = (normal_seq_req | delayed_seq_req) || state==PREP_DCNT11 || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT10:  begin dmy_req = (normal_seq_req | delayed_seq_req) || state==PREP_DCNT10 || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT9 :  begin dmy_req = (normal_seq_req | delayed_seq_req) || state==PREP_DCNT9  || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT8 :  begin dmy_req = (normal_seq_req | delayed_seq_req) || state==PREP_DCNT8  || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT7 :  begin dmy_req = (normal_seq_req | delayed_seq_req) || state==PREP_DCNT7  || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT6 :  begin dmy_req = (normal_seq_req | delayed_seq_req) || state==PREP_DCNT6  || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT5 :  begin dmy_req = (normal_seq_req | delayed_seq_req) || state==PREP_DCNT5  || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT4 :  begin dmy_req = (normal_seq_req | delayed_seq_req) || state==PREP_DCNT4  || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT3 :  begin dmy_req = (normal_seq_req | delayed_seq_req) || state==PREP_DCNT3  || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT2 :  begin dmy_req = (normal_seq_req | delayed_seq_req) || state==PREP_DCNT2  || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT1 :  begin dmy_req = (normal_seq_req | delayed_seq_req) || state==PREP_DCNT1  || dmy_resp; tx_req = 0; rx_req = 0; end
        default: begin tx_req = 0; rx_req = 0; dmy_req = 0; end
    endcase
endmodule
