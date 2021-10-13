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
                PREAM = 1 ,
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
        IDLE: next_state = (req & ~invld) ? PREAM : IDLE;
        PREAM: next_state = CMD;
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
            tx_req = (state==PREAM);
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
     *  DUMMY_OUT_PATTERN(15:12) | COUNT(11:8) | (7:6) | WIDTH(5:4) | DUMMY(3) | DIR(2) | BUSY(1) | SEL(0)
     * TXQCSR
     *  (7:2) | CLR(1) | RDY(0)
     * RXQCSR
     *  (7:2) | CLR(1) | RDY(0)
     * NORCSR
     *  CMD(15:8) | DUMMY_COUNT(7:4) | DUMMY_DIR(3) | MODE(2:0)
     */

    // fault generation
    wire invld_addr = (addr==1) || (addr==7);
    wire invld_acc  = (addr==0 || addr==6) ? (acc!=`BUS_ACC_2B) : (acc!=`BUS_ACC_1B);
    wire invld_wr   = w_rb ? (addr==3) : (addr==2);
    wire invld_d    = ((addr==6) && w_rb && (wdata[2:0]>6)); // unsupported mode

    wire invld      = |{invld_addr,invld_acc,invld_wr,invld_d};
    assign fault    = req & invld;

    // data queues
    wire      mosiq_w = req & ~invld & (addr==2);
    wire[7:0] mosiq_wd = wdata[7:0];
    wire      mosiq_full, txq_empty;
    wire      mosiq_clr = req & ~invld & (addr==4) & w_rb & (wdata[1]);

    wire      txq_r;
    wire[7:0] txq_rd_raw, txq_rd;
    fifo # (
        .WIDTH(8),
        .DEPTH(16),
        .CLEAR("sync")
    ) qspinor_mosiq (
        .clk  (clk ),
        .rstn (rstn),
        .din  (mosiq_wd  ),
        .w    (mosiq_w   ),
        .full (mosiq_full),
        .clr  (mosiq_clr ),
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

    wire      misoq_r = req & ~invld & (addr==3);
    wire[7:0] misoq_rd;
    wire      misoq_empty, rxq_full;
    wire      misoq_clr = req & ~invld & (addr==5) & w_rb & (wdata[1]);

    wire      rxq_w;
    wire[7:0] rxq_wd;

    fifo # (
        .WIDTH(8),
        .DEPTH(16),
        .CLEAR("sync")
    ) qspinor_misoq (
        .clk  (clk ),
        .rstn (rstn),
        .dout (misoq_rd   ),
        .r    (misoq_r    ),
        .empty(misoq_empty),
        .clr  (misoq_clr  ),
        .din  (rxq_wd  ),
        .w    (rxq_w   ),
        .full (rxq_full)
    );

    // cfg out for bus read module
    // Modes: 0-111 1-112 2-114 3-122 4-144 5-222 6-444
    assign cfg_cmd_width = (norcsr_mode==6) ? `QSPINOR_X4 :
                           (norcsr_mode==5) ? `QSPINOR_X2 :
                           /* otherwise */    `QSPINOR_X1;
    assign cfg_addr_width = (norcsr_mode==6) ? `QSPINOR_X4 :
                            (norcsr_mode==5) ? `QSPINOR_X2 :
                            (norcsr_mode==4) ? `QSPINOR_X4 :
                            (norcsr_mode==3) ? `QSPINOR_X2 :
                            /* otherwise */    `QSPINOR_X1;
    assign cfg_dmy_width = cfg_addr_width;
    assign cfg_data_width = (norcsr_mode==6) ? `QSPINOR_X4 :
                            (norcsr_mode==5) ? `QSPINOR_X2 :
                            (norcsr_mode==4) ? `QSPINOR_X4 :
                            (norcsr_mode==3) ? `QSPINOR_X2 :
                            (norcsr_mode==2) ? `QSPINOR_X4 :
                            (norcsr_mode==1) ? `QSPINOR_X2 :
                            /* otherwise */    `QSPINOR_X1;
    assign  cfg_cmd_octet = norcsr_cmd_octet;
    assign  cfg_dmy_cnt = norcsr_dmy_cnt;
    assign  cfg_dmy_dir = norcsr_dmy_dir;
    assign  cfg_dmy_out_pattern = 4'd0;

    // // // // BEGIN: data interaction with NOR flash
    // state
    localparam  IDLE          = 0 ,
                PREAM_TCNTMAX = 1 ,
                PREAM_TCNT15  = 2 , PREAM_TCNT14  = 3 , PREAM_TCNT13  = 4 , PREAM_TCNT12  = 5 , PREAM_TCNT11  = 6 , PREAM_TCNT10  = 7 , PREAM_TCNT9   = 8 , PREAM_TCNT8   = 9 , PREAM_TCNT7   = 10, PREAM_TCNT6   = 11, PREAM_TCNT5   = 12, PREAM_TCNT4   = 13, PREAM_TCNT3   = 14, PREAM_TCNT2   = 15, PREAM_TCNT1   = 16,
                PREAM_RCNTMAX = 17,
                PREAM_RCNT15  = 18, PREAM_RCNT14  = 19, PREAM_RCNT13  = 20, PREAM_RCNT12  = 21, PREAM_RCNT11  = 22, PREAM_RCNT10  = 23, PREAM_RCNT9   = 24, PREAM_RCNT8   = 25, PREAM_RCNT7   = 26, PREAM_RCNT6   = 27, PREAM_RCNT5   = 28, PREAM_RCNT4   = 29, PREAM_RCNT3   = 30, PREAM_RCNT2   = 31, PREAM_RCNT1   = 32,
                PREAM_DCNT15  = 33, PREAM_DCNT14  = 34, PREAM_DCNT13  = 35, PREAM_DCNT12  = 36, PREAM_DCNT11  = 37, PREAM_DCNT10  = 38, PREAM_DCNT9   = 39, PREAM_DCNT8   = 40, PREAM_DCNT7   = 41, PREAM_DCNT6   = 42, PREAM_DCNT5   = 43, PREAM_DCNT4   = 44, PREAM_DCNT3   = 45, PREAM_DCNT2   = 46, PREAM_DCNT1   = 47,
                TCNTMAX       = 48,
                TCNT15        = 49, TCNT14        = 50, TCNT13        = 51, TCNT12        = 52, TCNT11        = 53, TCNT10        = 54, TCNT9         = 55, TCNT8         = 56, TCNT7         = 57, TCNT6         = 58, TCNT5         = 59, TCNT4         = 60, TCNT3         = 61, TCNT2         = 62, TCNT1         = 63,
                RCNTMAX       = 64,
                RCNT15        = 65, RCNT14        = 66, RCNT13        = 67, RCNT12        = 68, RCNT11        = 69, RCNT10        = 70, RCNT9         = 71, RCNT8         = 72, RCNT7         = 73, RCNT6         = 74, RCNT5         = 75, RCNT4         = 76, RCNT3         = 77, RCNT2         = 78, RCNT1         = 79,
                DCNT15        = 80, DCNT14        = 81, DCNT13        = 82, DCNT12        = 83, DCNT11        = 84, DCNT10        = 85, DCNT9         = 86, DCNT8         = 87, DCNT7         = 88, DCNT6         = 89, DCNT5         = 90, DCNT4         = 91, DCNT3         = 92, DCNT2         = 93, DCNT1         = 94;

    reg[7:0]    state, next_state;
    always @ (posedge clk)
        if (~rstn)
            state <= IDLE;
        else
            state <= next_state;

    always @ (*) case (state)
        IDLE:
            if (!req || invld) // no req
                next_state = IDLE;
            else if (addr || ~wdata[0]) // not selected
                next_state = IDLE;
            else if (wdata[3]) case (wdata[11:8]) // dummy
                1 : next_state = qspi_csb ? PREAM_DCNT1  : DCNT1 ;
                2 : next_state = qspi_csb ? PREAM_DCNT2  : DCNT2 ;
                3 : next_state = qspi_csb ? PREAM_DCNT3  : DCNT3 ;
                4 : next_state = qspi_csb ? PREAM_DCNT4  : DCNT4 ;
                5 : next_state = qspi_csb ? PREAM_DCNT5  : DCNT5 ;
                6 : next_state = qspi_csb ? PREAM_DCNT6  : DCNT6 ;
                7 : next_state = qspi_csb ? PREAM_DCNT7  : DCNT7 ;
                8 : next_state = qspi_csb ? PREAM_DCNT8  : DCNT8 ;
                9 : next_state = qspi_csb ? PREAM_DCNT9  : DCNT9 ;
                10: next_state = qspi_csb ? PREAM_DCNT10 : DCNT10;
                11: next_state = qspi_csb ? PREAM_DCNT11 : DCNT11;
                12: next_state = qspi_csb ? PREAM_DCNT12 : DCNT12;
                13: next_state = qspi_csb ? PREAM_DCNT13 : DCNT13;
                14: next_state = qspi_csb ? PREAM_DCNT14 : DCNT14;
                15: next_state = qspi_csb ? PREAM_DCNT15 : DCNT15;
                default: next_state = IDLE;
            endcase else if (wdata[2]) case (wdata[11:8]) // tx
                default: next_state = qspi_csb ? PREAM_TCNTMAX : ~txq_empty ? TCNTMAX : IDLE ;
                1 : next_state = qspi_csb ? PREAM_TCNT1  : TCNT1  ;
                2 : next_state = qspi_csb ? PREAM_TCNT2  : TCNT2  ;
                3 : next_state = qspi_csb ? PREAM_TCNT3  : TCNT3  ;
                4 : next_state = qspi_csb ? PREAM_TCNT4  : TCNT4  ;
                5 : next_state = qspi_csb ? PREAM_TCNT5  : TCNT5  ;
                6 : next_state = qspi_csb ? PREAM_TCNT6  : TCNT6  ;
                7 : next_state = qspi_csb ? PREAM_TCNT7  : TCNT7  ;
                8 : next_state = qspi_csb ? PREAM_TCNT8  : TCNT8  ;
                9 : next_state = qspi_csb ? PREAM_TCNT9  : TCNT9  ;
                10: next_state = qspi_csb ? PREAM_TCNT10 : TCNT10 ;
                11: next_state = qspi_csb ? PREAM_TCNT11 : TCNT11 ;
                12: next_state = qspi_csb ? PREAM_TCNT12 : TCNT12 ;
                13: next_state = qspi_csb ? PREAM_TCNT13 : TCNT13 ;
                14: next_state = qspi_csb ? PREAM_TCNT14 : TCNT14 ;
                15: next_state = qspi_csb ? PREAM_TCNT15 : TCNT15 ;
            endcase else case (wdata[11:8]) // rx
                default: next_state = qspi_csb ? PREAM_RCNTMAX : ~rxq_full ? RCNTMAX : IDLE ;
                1 : next_state = qspi_csb ? PREAM_RCNT1  : RCNT1  ;
                2 : next_state = qspi_csb ? PREAM_RCNT2  : RCNT2  ;
                3 : next_state = qspi_csb ? PREAM_RCNT3  : RCNT3  ;
                4 : next_state = qspi_csb ? PREAM_RCNT4  : RCNT4  ;
                5 : next_state = qspi_csb ? PREAM_RCNT5  : RCNT5  ;
                6 : next_state = qspi_csb ? PREAM_RCNT6  : RCNT6  ;
                7 : next_state = qspi_csb ? PREAM_RCNT7  : RCNT7  ;
                8 : next_state = qspi_csb ? PREAM_RCNT8  : RCNT8  ;
                9 : next_state = qspi_csb ? PREAM_RCNT9  : RCNT9  ;
                10: next_state = qspi_csb ? PREAM_RCNT10 : RCNT10 ;
                11: next_state = qspi_csb ? PREAM_RCNT11 : RCNT11 ;
                12: next_state = qspi_csb ? PREAM_RCNT12 : RCNT12 ;
                13: next_state = qspi_csb ? PREAM_RCNT13 : RCNT13 ;
                14: next_state = qspi_csb ? PREAM_RCNT14 : RCNT14 ;
                15: next_state = qspi_csb ? PREAM_RCNT15 : RCNT15 ;
            endcase
        PREAM_TCNTMAX: next_state = ~txq_empty ? TCNTMAX : IDLE;
        PREAM_TCNT15 : next_state = TCNT15;
        PREAM_TCNT14 : next_state = TCNT14;
        PREAM_TCNT13 : next_state = TCNT13;
        PREAM_TCNT12 : next_state = TCNT12;
        PREAM_TCNT11 : next_state = TCNT11;
        PREAM_TCNT10 : next_state = TCNT10;
        PREAM_TCNT9  : next_state = TCNT9 ;
        PREAM_TCNT8  : next_state = TCNT8 ;
        PREAM_TCNT7  : next_state = TCNT7 ;
        PREAM_TCNT6  : next_state = TCNT6 ;
        PREAM_TCNT5  : next_state = TCNT5 ;
        PREAM_TCNT4  : next_state = TCNT4 ;
        PREAM_TCNT3  : next_state = TCNT3 ;
        PREAM_TCNT2  : next_state = TCNT2 ;
        PREAM_TCNT1  : next_state = TCNT1 ;
        PREAM_RCNTMAX: next_state = ~rxq_full ? RCNTMAX : IDLE;
        PREAM_RCNT15 : next_state = RCNT15;
        PREAM_RCNT14 : next_state = RCNT14;
        PREAM_RCNT13 : next_state = RCNT13;
        PREAM_RCNT12 : next_state = RCNT12;
        PREAM_RCNT11 : next_state = RCNT11;
        PREAM_RCNT10 : next_state = RCNT10;
        PREAM_RCNT9  : next_state = RCNT9 ;
        PREAM_RCNT8  : next_state = RCNT8 ;
        PREAM_RCNT7  : next_state = RCNT7 ;
        PREAM_RCNT6  : next_state = RCNT6 ;
        PREAM_RCNT5  : next_state = RCNT5 ;
        PREAM_RCNT4  : next_state = RCNT4 ;
        PREAM_RCNT3  : next_state = RCNT3 ;
        PREAM_RCNT2  : next_state = RCNT2 ;
        PREAM_RCNT1  : next_state = RCNT1 ;
        PREAM_DCNT15 : next_state = DCNT15;
        PREAM_DCNT14 : next_state = DCNT14;
        PREAM_DCNT13 : next_state = DCNT13;
        PREAM_DCNT12 : next_state = DCNT12;
        PREAM_DCNT11 : next_state = DCNT11;
        PREAM_DCNT10 : next_state = DCNT10;
        PREAM_DCNT9  : next_state = DCNT9 ;
        PREAM_DCNT8  : next_state = DCNT8 ;
        PREAM_DCNT7  : next_state = DCNT7 ;
        PREAM_DCNT6  : next_state = DCNT6 ;
        PREAM_DCNT5  : next_state = DCNT5 ;
        PREAM_DCNT4  : next_state = DCNT4 ;
        PREAM_DCNT3  : next_state = DCNT3 ;
        PREAM_DCNT2  : next_state = DCNT2 ;
        PREAM_DCNT1  : next_state = DCNT1 ;
        TCNTMAX: next_state = (tx_resp && txq_empty) ? IDLE : TCNTMAX;
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
        RCNTMAX: next_state = (rx_resp && rxq_full) ? IDLE : RCNTMAX;
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

    // latch request for data interaction
    wire[`BUS_WIDTH-1:0]    ipcsr_wdata;
    dff # (
        .WIDTH(`BUS_WIDTH),
        .VALID("async")
    ) ipcsr_wdata_dff (
        .clk(clk                         ),
        .vld(req && ~invld && state==IDLE),
        .in (wdata                       ),
        .out(ipcsr_wdata                 )
    );

    // control
    assign  width = ipcsr_wdata[5:4];

    assign  txq_rdy = ~txq_empty;
    assign  txq_d = txq_rd;
    assign  txq_r = tx_req;

    assign  rxq_rdy = ~rxq_full;
    assign  rxq_wd = rxq_d;
    assign  rxq_w = rx_resp;

    assign  dmy_dir = ipcsr_wdata[2];
    assign  dmy_out_pattern = ipcsr_wdata[15:12];

    always @ (*) case (next_state) // better use assign to propagate x
        TCNTMAX: begin tx_req = (req && state==IDLE) || state==PREAM_TCNTMAX || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT15:  begin tx_req = (req && state==IDLE) || state==PREAM_TCNT15; rx_req = 0; dmy_req = 0; end
        TCNT14:  begin tx_req = (req && state==IDLE) || state==PREAM_TCNT14 || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT13:  begin tx_req = (req && state==IDLE) || state==PREAM_TCNT13 || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT12:  begin tx_req = (req && state==IDLE) || state==PREAM_TCNT12 || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT11:  begin tx_req = (req && state==IDLE) || state==PREAM_TCNT11 || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT10:  begin tx_req = (req && state==IDLE) || state==PREAM_TCNT10 || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT9 :  begin tx_req = (req && state==IDLE) || state==PREAM_TCNT9  || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT8 :  begin tx_req = (req && state==IDLE) || state==PREAM_TCNT8  || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT7 :  begin tx_req = (req && state==IDLE) || state==PREAM_TCNT7  || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT6 :  begin tx_req = (req && state==IDLE) || state==PREAM_TCNT6  || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT5 :  begin tx_req = (req && state==IDLE) || state==PREAM_TCNT5  || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT4 :  begin tx_req = (req && state==IDLE) || state==PREAM_TCNT4  || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT3 :  begin tx_req = (req && state==IDLE) || state==PREAM_TCNT3  || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT2 :  begin tx_req = (req && state==IDLE) || state==PREAM_TCNT2  || tx_resp; rx_req = 0; dmy_req = 0; end
        TCNT1 :  begin tx_req = (req && state==IDLE) || state==PREAM_TCNT1  || tx_resp; rx_req = 0; dmy_req = 0; end
        RCNTMAX: begin rx_req = (req && state==IDLE) || state==PREAM_RCNTMAX || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT15:  begin rx_req = (req && state==IDLE) || state==PREAM_RCNT15; tx_req = 0; dmy_req = 0; end
        RCNT14:  begin rx_req = (req && state==IDLE) || state==PREAM_RCNT14 || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT13:  begin rx_req = (req && state==IDLE) || state==PREAM_RCNT13 || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT12:  begin rx_req = (req && state==IDLE) || state==PREAM_RCNT12 || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT11:  begin rx_req = (req && state==IDLE) || state==PREAM_RCNT11 || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT10:  begin rx_req = (req && state==IDLE) || state==PREAM_RCNT10 || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT9 :  begin rx_req = (req && state==IDLE) || state==PREAM_RCNT9  || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT8 :  begin rx_req = (req && state==IDLE) || state==PREAM_RCNT8  || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT7 :  begin rx_req = (req && state==IDLE) || state==PREAM_RCNT7  || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT6 :  begin rx_req = (req && state==IDLE) || state==PREAM_RCNT6  || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT5 :  begin rx_req = (req && state==IDLE) || state==PREAM_RCNT5  || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT4 :  begin rx_req = (req && state==IDLE) || state==PREAM_RCNT4  || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT3 :  begin rx_req = (req && state==IDLE) || state==PREAM_RCNT3  || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT2 :  begin rx_req = (req && state==IDLE) || state==PREAM_RCNT2  || rx_resp; tx_req = 0; dmy_req = 0; end
        RCNT1 :  begin rx_req = (req && state==IDLE) || state==PREAM_RCNT1  || rx_resp; tx_req = 0; dmy_req = 0; end
        DCNT15:  begin dmy_req = (req && state==IDLE) || state==PREAM_DCNT15; tx_req = 0; rx_req = 0; end
        DCNT14:  begin dmy_req = (req && state==IDLE) || state==PREAM_DCNT14 || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT13:  begin dmy_req = (req && state==IDLE) || state==PREAM_DCNT13 || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT12:  begin dmy_req = (req && state==IDLE) || state==PREAM_DCNT12 || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT11:  begin dmy_req = (req && state==IDLE) || state==PREAM_DCNT11 || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT10:  begin dmy_req = (req && state==IDLE) || state==PREAM_DCNT10 || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT9 :  begin dmy_req = (req && state==IDLE) || state==PREAM_DCNT9  || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT8 :  begin dmy_req = (req && state==IDLE) || state==PREAM_DCNT8  || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT7 :  begin dmy_req = (req && state==IDLE) || state==PREAM_DCNT7  || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT6 :  begin dmy_req = (req && state==IDLE) || state==PREAM_DCNT6  || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT5 :  begin dmy_req = (req && state==IDLE) || state==PREAM_DCNT5  || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT4 :  begin dmy_req = (req && state==IDLE) || state==PREAM_DCNT4  || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT3 :  begin dmy_req = (req && state==IDLE) || state==PREAM_DCNT3  || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT2 :  begin dmy_req = (req && state==IDLE) || state==PREAM_DCNT2  || dmy_resp; tx_req = 0; rx_req = 0; end
        DCNT1 :  begin dmy_req = (req && state==IDLE) || state==PREAM_DCNT1  || dmy_resp; tx_req = 0; rx_req = 0; end
        default: begin tx_req = 0; rx_req = 0; dmy_req = 0; end
    endcase
    // // // // END: data interaction with NOR flash

    // resp generation
    always @ (posedge clk) begin
        if (~rstn)
            resp <= 0;
        else
            resp <= req & ~invld;
    end

    // register access
    reg[15:0]   norcsr;
    wire[7:0]   norcsr_cmd_octet = norcsr[15:8];
    wire[3:0]   norcsr_dmy_cnt = norcsr[7:4];
    wire        norcsr_dmy_dir = norcsr[3];
    wire[2:0]   norcsr_mode = norcsr[2:0];

    always @ (posedge clk) begin
        if (~rstn) begin
            norcsr <= 0;
            qspi_csb <= 1'b1;
        end else if (req & ~invld) case (addr)
            0:
                if (w_rb)
                    qspi_csb <= ~wdata[0] && (state==IDLE);
                else
                    rdata <= {30'd0, (state!=IDLE), ~qspi_csb};
            3:
                rdata <= {24'd0, misoq_rd};
            4:
                rdata <= {31'd0, ~mosiq_full};
            5:
                rdata <= {31'd0, ~misoq_empty};
            6:
                if (w_rb)
                    norcsr <= wdata[15:0];
                else
                    rdata <= norcsr;
        endcase
    end
endmodule
