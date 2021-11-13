`include "femto.vh"
`include "timescale.vh"

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
    wire        nor_tx_req,          qspinor_tx_req;
    wire[1:0]   nor_width,           qspinor_width;
    wire        nor_txq_rdy,         qspinor_txq_rdy;
    wire[7:0]   nor_txq_d,           qspinor_txq_d;
    wire        nor_rx_req,          qspinor_rx_req;
    wire        nor_rxq_rdy,         qspinor_rxq_rdy;
    wire        nor_dmy_req,         qspinor_dmy_req;
    wire        nor_dmy_dir,         qspinor_dmy_dir;
    wire[3:0]   nor_dmy_out_pattern, qspinor_dmy_out_pattern;
    wire        nor_qspi_csb,        qspinor_qspi_csb;

    wire[1:0]   cfg_cmd_width;
    wire[1:0]   cfg_addr_width;
    wire[1:0]   cfg_dmy_width;
    wire[1:0]   cfg_data_width;
    wire[7:0]   cfg_cmd_octet;
    wire[3:0]   cfg_dmy_cnt;
    wire        cfg_dmy_dir;
    wire[3:0]   cfg_dmy_out_pattern;

    wire        io_tx_req = qspinor_tx_req | nor_tx_req,
                io_rx_req = qspinor_rx_req | nor_rx_req,
                io_dmy_req = qspinor_dmy_req | nor_dmy_req;
    wire[1:0]   io_width = nor_qspi_csb ? qspinor_width : nor_width;
    wire        io_txq_rdy = nor_qspi_csb ? qspinor_txq_rdy : nor_txq_rdy,
                io_rxq_rdy = nor_qspi_csb ? qspinor_rxq_rdy : nor_rxq_rdy;
    wire[7:0]   io_txq_d = nor_qspi_csb ? qspinor_txq_d : nor_txq_d;
    wire        io_dmy_dir = nor_qspi_csb ? qspinor_dmy_dir : nor_dmy_dir;
    wire[3:0]   io_dmy_out_pattern = nor_qspi_csb ? qspinor_dmy_out_pattern : nor_dmy_out_pattern;
    wire        io_tx_resp, io_rx_resp, io_dmy_resp;
    wire[7:0]   io_rxq_d;

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

        .status_qspinor_csb (qspinor_qspi_csb   ),
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
        .tx_resp        (io_tx_resp         ),
        .rx_req         (nor_rx_req         ),
        .rxq_rdy        (nor_rxq_rdy        ),
        .rxq_d          (io_rxq_d           ),
        .rx_resp        (io_rx_resp         ),
        .dmy_req        (nor_dmy_req        ),
        .dmy_dir        (nor_dmy_dir        ),
        .dmy_out_pattern(nor_dmy_out_pattern),
        .dmy_resp       (io_dmy_resp       ),

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
        .tx_resp        (io_tx_resp             ),
        .rx_req         (qspinor_rx_req         ),
        .rxq_rdy        (qspinor_rxq_rdy        ),
        .rxq_d          (io_rxq_d               ),
        .rx_resp        (io_rx_resp             ),
        .dmy_req        (qspinor_dmy_req        ),
        .dmy_dir        (qspinor_dmy_dir        ),
        .dmy_out_pattern(qspinor_dmy_out_pattern),
        .dmy_resp       (io_dmy_resp            ),

        .qspi_csb(qspinor_qspi_csb)
    );

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
    localparam  IDLE     = 0,
                WAIT_TXQ = 1,
                WAIT_RXQ = 2,
                TX       = 3,
                RX       = 4,
                DMY_O    = 5,
                DMY_I    = 6;

    reg[7:0]    state, next_state;
    reg[7:0]    cnt, next_cnt;
    always @ (posedge clk) begin
        if (~rstn) begin
            state <= IDLE;
            cnt <= 0;
        end else begin
            state <= next_state;
            cnt <= next_cnt;
        end
    end

    always @ (*) begin
        if (cnt==0) begin // IDLE, finalizing TX, RX, DMY
            if (tx_req) begin
                if (txq_rdy) begin
                    next_state = TX;
                    next_cnt = (width==X1) ? 15 : (width==X2) ? 7 : /* X4 */ 3;
                end else begin
                    next_state = WAIT_TXQ;
                    next_cnt = (-1);
                end
            end else if (rx_req) begin
                if (rxq_rdy) begin
                    next_state = RX;
                    next_cnt = (width==X1) ? 15 : (width==X2) ? 7 : /* X4 */ 3;
                end else begin
                    next_state = WAIT_RXQ;
                    next_cnt = (-1);
                end
            end else if (dmy_req) begin
                if (dmy_dir) begin
                    next_state = DMY_O;
                    next_cnt = 1;
                end else begin
                    next_state = DMY_I;
                    next_cnt = 1;
                end
            end else begin
                next_state = IDLE;
                next_cnt = 0;
            end
        end else if (state==WAIT_TXQ) begin
            if (txq_rdy) begin
                next_state = TX;
                next_cnt = (width==X1) ? 15 : (width==X2) ? 7 : /* X4 */ 3;
            end else begin
                next_state = WAIT_TXQ;
                next_cnt = (-1);
            end
        end else if (state==WAIT_RXQ) begin
            if (rxq_rdy) begin
                next_state = RX;
                next_cnt = (width==X1) ? 15 : (width==X2) ? 7 : /* X4 */ 3;
            end else begin
                next_state = WAIT_RXQ;
                next_cnt = (-1);
            end
        end else if (state==TX) begin // excluding cnt==0
            next_state = TX;
            next_cnt = cnt-1;
        end else if (state==RX) begin // excluding cnt==0
            next_state = RX;
            next_cnt = cnt-1;
        end else if (state==DMY_O) begin // excluding cnt==0, only cnt==1
            next_state = DMY_O;
            next_cnt = 0;
        end else if (state==DMY_I) begin // excluding cnt==0, only cnt==1
            next_state = DMY_I;
            next_cnt = 0;
        end else begin
            next_state = IDLE;
            next_cnt = 0;
        end
    end

    // cfg_cmd_octet done
    always @ (posedge clk) begin
        if (~rstn) begin
            tx_resp <= 1'b0;
            rx_resp <= 1'b0;
            dmy_resp <= 1'b0;
        end else if (cnt==1) begin
            if (state==TX)
                tx_resp <= 1'b1;
            else if (state==RX)
                rx_resp <= 1'b1;
            else if (state==DMY_O || state==DMY_I)
                dmy_resp <= 1'b1;
        end else begin
            tx_resp <= 1'b0;
            rx_resp <= 1'b0;
            dmy_resp <= 1'b0;
        end
    end

    // qspi sclk
    always @ (*) begin // better use "assign" to propagate x
        if (state==TX || state==RX || state==DMY_O || state==DMY_I)
            qspi_sclk = ~cnt[0];
        else
            qspi_sclk = MODE ? 1'b1 : 1'b0;
    end

    // qspi dir
    always @ (*) begin // better use "assign" to propagate x
        if (state==TX || state==DMY_O)
            qspi_dir = (width==X1) ? {`IOR_DIR_IN, `IOR_DIR_IN, `IOR_DIR_IN, `IOR_DIR_OUT} :
                       (width==X2) ? {`IOR_DIR_IN, `IOR_DIR_IN, `IOR_DIR_OUT, `IOR_DIR_OUT} :
                       /* X4 */      {`IOR_DIR_OUT, `IOR_DIR_OUT, `IOR_DIR_OUT, `IOR_DIR_OUT};
        else
            qspi_dir = {`IOR_DIR_IN, `IOR_DIR_IN, `IOR_DIR_IN, `IOR_DIR_IN};
    end

    // qspi mosi
    always @ (*) case (state) // better use "assign" to propagate x
        TX:
            if (width==X1)
                qspi_mosi = {3'dx, txq_d[cnt[3:1]]};
            else if (width==X2)
                qspi_mosi = {2'dx, txq_d[{cnt[2:1], 1'd0}+:2]};
            else /* X4 */
                qspi_mosi = txq_d[{cnt[1], 2'd0}+:4];
        DMY_O, DMY_I: qspi_mosi = dmy_out_pattern;
        default: qspi_mosi = 4'dx;
    endcase

    // qspi miso
    always @ (posedge clk) if (state==RX) begin
        if (width==X1)
            rxq_d[cnt[3:1]] <= qspi_miso[1];
        else if (width==X2)
            rxq_d[{cnt[2:1], 1'd0}+:2] <= qspi_miso[1:0];
        else /* X4 */
            rxq_d[{cnt[1], 2'd0}+:4] <= qspi_miso;
    end
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

    // cfg/status from qspinor_ip_access_controller
    input wire          status_qspinor_csb,

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
    output reg  qspi_csb
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
    localparam  IDLE  = 0,
                WAIT  = 1,
                PREP  = 2,
                CMD   = 3,
                ADDR  = 4,
                DMY   = 5,
                DATA  = 6;

    reg[7:0]    state, next_state;
    reg[7:0]    cnt, next_cnt;
    always @ (posedge clk) begin
        if (~rstn) begin
            state <= IDLE;
            cnt <= 0;
        end else begin
            state <= next_state;
            cnt <= next_cnt;
        end
    end

    always @ (*) case (state)
        IDLE:
            if (req & ~invld) begin
                next_state = WAIT;
                next_cnt = 1; // keep csb hi for a while in case of a narrow positive pulse
            end else begin
                next_state = IDLE;
                next_cnt = 0;
            end
        WAIT: begin
            if (status_qspinor_csb) begin
                if (cnt==0) begin
                    next_state = PREP;
                    next_cnt = 0;
                end else begin
                    next_state = WAIT;
                    next_cnt = cnt-1;
                end
            end else begin
                next_state = WAIT;
                next_cnt = cnt;
            end
        end
        PREP: begin
            next_state = CMD;
            next_cnt = 0;
        end
        CMD:
            if (tx_resp) begin
                next_state = ADDR;
                next_cnt = 2;
            end else begin
                next_state = CMD;
                next_cnt = 0;
            end
        ADDR:
            if (tx_resp) begin
                if (cnt==0) begin
                    if (cfg_dmy_cnt) begin
                        next_state = DMY;
                        next_cnt = cfg_dmy_cnt;
                    end else begin
                        next_state = DATA;
                        next_cnt = (req_acc==`BUS_ACC_4B) ? 3 : (req_acc==`BUS_ACC_2B) ? 1 : /*BUS_ACC_1B*/ 0;
                    end
                end else begin
                    next_state = ADDR;
                    next_cnt = cnt-1;
                end
            end else begin
                next_state = ADDR;
                next_cnt = cnt;
            end
        DMY:
            if (dmy_resp) begin
                if (cnt==1) begin
                    next_state = DATA;
                    next_cnt = (req_acc==`BUS_ACC_4B) ? 3 : (req_acc==`BUS_ACC_2B) ? 1 : /*BUS_ACC_1B*/ 0;
                end else begin
                    next_state = DMY;
                    next_cnt = cnt-1;
                end
            end else begin
                next_state = DMY;
                next_cnt = cnt;
            end
        DATA:
            if (rx_resp) begin
                if (cnt==0) begin
                    next_state = IDLE;
                    next_cnt = 0;
                end else begin
                    next_state = DATA;
                    next_cnt = cnt-1;
                end
            end else begin
                next_state = DATA;
                next_cnt = cnt;
            end
        default: begin
            next_state = IDLE;
            next_cnt = 0;
        end
    endcase

    // control
    always @ (posedge clk) begin
        if (~rstn)
            qspi_csb <= 1;
        else if (next_state==IDLE)
            qspi_csb <= 1;
        else if (next_state==PREP)
            qspi_csb <= 0;
    end

    always @ (*) case (next_state) // better use assign to propagate x
        CMD: begin
            width = cfg_cmd_width;
            tx_req = (state==PREP);
            rx_req = 0;
            dmy_req = 0;
        end
        ADDR: begin
            width = cfg_addr_width;
            tx_req = tx_resp;
            rx_req = 0;
            dmy_req = 0;
        end
        DMY: begin
            width = cfg_dmy_width;
            tx_req = 0;
            rx_req = 0;
            dmy_req = tx_resp | dmy_resp;
        end
        DATA: begin
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

    always @ (posedge clk) begin
        if (next_state==CMD)
            txq_d <= cfg_cmd_octet;
        else if (next_state==ADDR)
            txq_d <= (next_cnt==2) ? req_addr[23:16] : (next_cnt==1) ? req_addr[15:8] : /* 0 */ req_addr[7:0];
        else
            txq_d <= 8'dx;
    end

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
        if (rx_resp && state==DATA) case (req_acc)
            `BUS_ACC_4B: begin
                if (cnt==3) rdata[7:0]   <= rxq_d;
                if (cnt==2) rdata[15:8]  <= rxq_d;
                if (cnt==1) rdata[23:16] <= rxq_d;
                if (cnt==0) rdata[31:24] <= rxq_d;
            end
            `BUS_ACC_2B: begin
                if (cnt==1) rdata[7:0]  <= rxq_d;
                if (cnt==0) rdata[15:8] <= rxq_d;
            end
            default: // BUS_ACC_1B
                if (cnt==0) rdata[7:0] <= rxq_d;
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
     *  CLR(7) | WSCNT(6:0)
     * RXQCSR
     *  CLR(7) | RSCNT(6:0)
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

    `define TXQ_CLR     7
    `define RXQ_CLR     7

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

    // data interaction busy indicator
    wire    busy;

    // data queues
    wire      txq_w = req & ~invld & (addr==2);
    wire[7:0] txq_wd = wdata[7:0];
    wire      txq_full, txq_empty;
    wire      txq_clr = req & ~invld & (addr==4) & w_rb & wdata[`TXQ_CLR] & ~busy;

    wire      txq_r;
    wire[7:0] txq_rd_raw, txq_rd;
    fifo # (
        .WIDTH(8                  ),
        .DEPTH(`QSPINOR_FIFO_DEPTH),
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
    wire      rxq_clr = req & ~invld & (addr==5) & w_rb & wdata[`RXQ_CLR];

    wire      rxq_w;
    wire[7:0] rxq_wd;

    fifo # (
        .WIDTH(8                  ),
        .DEPTH(`QSPINOR_FIFO_DEPTH),
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

    reg[6:0] wscnt, rscnt; // writable/readable slot cnt
    always @ (posedge clk) begin
        if (~rstn) begin
            wscnt <= `QSPINOR_FIFO_DEPTH;
            rscnt <= 0;
        end else begin
            if (txq_clr)
                wscnt <= `QSPINOR_FIFO_DEPTH;
            else case ({txq_w&~txq_full, txq_r&~txq_empty})
                2'b01: wscnt<=wscnt+1;
                2'b10: wscnt<=wscnt-1;
            endcase

            if (rxq_clr)
                rscnt <= 0;
            else case ({rxq_w&~rxq_full, rxq_r&~rxq_empty})
                2'b01: rscnt<=rscnt-1;
                2'b10: rscnt<=rscnt+1;
            endcase
        end
    end

    // latch request for data interaction
    wire    seq_req = req && ~invld && w_rb && addr==0;
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

            if (~busy) queued <= 0;
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
            4: rdata <= {25'd0, wscnt};
            5: rdata <= {25'd0, rscnt};
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
                           /* otherwise */          `QSPINOR_X1;
    assign cfg_addr_width = (norcsr[`NOR_MODE]==6) ? `QSPINOR_X4 :
                            (norcsr[`NOR_MODE]==5) ? `QSPINOR_X2 :
                            (norcsr[`NOR_MODE]==4) ? `QSPINOR_X4 :
                            (norcsr[`NOR_MODE]==3) ? `QSPINOR_X2 :
                            /* norcsr[`NOR_MODE] */  `QSPINOR_X1;
    assign cfg_dmy_width = cfg_addr_width;
    assign cfg_data_width = (norcsr[`NOR_MODE]==6) ? `QSPINOR_X4 :
                            (norcsr[`NOR_MODE]==5) ? `QSPINOR_X2 :
                            (norcsr[`NOR_MODE]==4) ? `QSPINOR_X4 :
                            (norcsr[`NOR_MODE]==3) ? `QSPINOR_X2 :
                            (norcsr[`NOR_MODE]==2) ? `QSPINOR_X4 :
                            (norcsr[`NOR_MODE]==1) ? `QSPINOR_X2 :
                            /* otherwise */          `QSPINOR_X1;
    assign  cfg_cmd_octet = norcsr[`NOR_CMD];
    assign  cfg_dmy_cnt = norcsr[`NOR_DMYCNT];
    assign  cfg_dmy_dir = norcsr[`NOR_DMYDIR];
    assign  cfg_dmy_out_pattern = 4'd0;


    // data interaction state control
    localparam  IDLE       = 0 ,
                PREP_TLOOP = 1 , // wait for CS or FIFO
                PREP_TCNT  = 2 ,
                PREP_RLOOP = 3 , // wait for CS or FIFO
                PREP_RCNT  = 4 ,
                PREP_DCNT  = 5 ,
                TLOOP      = 6 ,
                TCNT       = 7 ,
                RLOOP      = 8 ,
                RCNT       = 9 ,
                DCNT       = 10;

    reg[7:0]    state, next_state;
    reg[7:0]    cnt, next_cnt;
    always @ (posedge clk) begin
        if (~rstn) begin
            state <= IDLE;
            cnt <= 0;
        end else begin
            state <= next_state;
            cnt <= next_cnt;
        end
    end

    assign  busy = (state!=IDLE);

    always @ (*) case (state)
        IDLE:
            if ((delayed_seq_req | normal_seq_req) & ipcsr_wdata[`IP_SEL]) begin
                if (ipcsr_wdata[`IP_DMY]) begin // dummy
                    next_state = qspi_csb ? PREP_DCNT : DCNT;
                    next_cnt = ipcsr_wdata[`IP_CNT] ? ipcsr_wdata[`IP_CNT] : 16;
                end else if (ipcsr_wdata[`IP_DIR]) begin // tx
                    if (ipcsr_wdata[`IP_CNT]) begin
                        next_state = qspi_csb ? PREP_TCNT : TCNT;
                        next_cnt = ipcsr_wdata[`IP_CNT];
                    end else begin
                        next_state = (qspi_csb | txq_empty) ? PREP_TLOOP : TLOOP;
                        next_cnt = 0;
                    end
                end else begin // rx
                    if (ipcsr_wdata[`IP_CNT]) begin
                        next_state = qspi_csb ? PREP_RCNT : RCNT;
                        next_cnt = ipcsr_wdata[`IP_CNT];
                    end else begin
                        next_state = (qspi_csb | rxq_full) ? PREP_RLOOP : RLOOP;
                        next_cnt = 0;
                    end
                end
            end else begin // no req
                next_state = IDLE;
                next_cnt = 0;
            end
        PREP_TLOOP: begin
            next_state = txq_empty ? PREP_TLOOP : TLOOP;
            next_cnt = 0;
        end
        PREP_TCNT: begin
            next_state = TCNT;
            next_cnt = cnt;
        end
        PREP_RLOOP: begin
            next_state = rxq_full ? PREP_RLOOP : RLOOP;
            next_cnt = 0;
        end
        PREP_RCNT: begin
            next_state = RCNT;
            next_cnt = cnt;
        end
        PREP_DCNT: begin
            next_state = DCNT;
            next_cnt = cnt;
        end
        TLOOP: begin
            next_state = (tx_resp && txq_empty) ? IDLE : TLOOP;
            next_cnt = 0;
        end
        TCNT:
            if (cnt==1) begin
                next_state = tx_resp ? IDLE : TCNT;
                next_cnt = tx_resp ? 0 : 1;
            end else begin
                next_state = TCNT;
                next_cnt = tx_resp ? (cnt-1) : cnt;
            end
        RLOOP: begin
            next_state = (rx_resp && rxq_full) ? IDLE : RLOOP;
            next_cnt = 0;
        end
        RCNT:
            if (cnt==1) begin
                next_state = rx_resp ? IDLE : RCNT;
                next_cnt = rx_resp ? 0 : 1;
            end else begin
                next_state = RCNT;
                next_cnt = rx_resp ? (cnt-1) : cnt;
            end
        DCNT:
            if (cnt==1) begin
                next_state = dmy_resp ? IDLE : DCNT;
                next_cnt = dmy_resp ? 0 : 1;
            end else begin
                next_state = DCNT;
                next_cnt = dmy_resp ? (cnt-1) : cnt;
            end
        default: begin
            next_state = IDLE;
            next_cnt = 0;
        end
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
        TLOOP   : begin tx_req  = (state==PREP_TLOOP) || (normal_seq_req | delayed_seq_req | tx_resp ); rx_req = 0; dmy_req = 0; end
        TCNT    : begin tx_req  = (state==PREP_TCNT ) || (normal_seq_req | delayed_seq_req | tx_resp ); rx_req = 0; dmy_req = 0; end
        RLOOP   : begin rx_req  = (state==PREP_RLOOP) || (normal_seq_req | delayed_seq_req | rx_resp ); tx_req = 0; dmy_req = 0; end
        RCNT    : begin rx_req  = (state==PREP_RCNT ) || (normal_seq_req | delayed_seq_req | rx_resp ); tx_req = 0; dmy_req = 0; end
        DCNT    : begin dmy_req = (state==PREP_DCNT ) || (normal_seq_req | delayed_seq_req | dmy_resp); tx_req = 0; rx_req = 0 ; end
        default : begin tx_req = 0; rx_req = 0; dmy_req = 0; end
    endcase
endmodule
