`include "femto.vh"
`include "timescale.vh"

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
                TX7_0    = 3 ,
                TX7_1    = 4 ,
                TX6_0    = 5 ,
                TX6_1    = 6 ,
                TX5_0    = 7 ,
                TX5_1    = 8 ,
                TX4_0    = 9 ,
                TX4_1    = 10,
                TX3_0    = 11,
                TX3_1    = 12,
                TX2_0    = 13,
                TX2_1    = 14,
                TX1_0    = 15,
                TX1_1    = 16,
                TX0_0    = 17,
                TX0_1    = 18,
                RX7_0    = 19,
                RX7_1    = 20,
                RX6_0    = 21,
                RX6_1    = 22,
                RX5_0    = 23,
                RX5_1    = 24,
                RX4_0    = 25,
                RX4_1    = 26,
                RX3_0    = 27,
                RX3_1    = 28,
                RX2_0    = 29,
                RX2_1    = 30,
                RX1_0    = 31,
                RX1_1    = 32,
                RX0_0    = 33,
                RX0_1    = 34,
                DMYO_0   = 35,
                DMYO_1   = 36,
                DMYI_0   = 37,
                DMYI_1   = 38;

    reg[7:0] state, next_state;
    always @ (posedge clk)
        if (~rstn)
            state <= IDLE;
        else
            state <= next_state;

    always @ (*) case (state)
        IDLE:
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
            end
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
        TX7_0, TX7_1, TX6_0, TX6_1, TX5_0, TX5_1, TX4_0, TX4_1, TX3_0, TX3_1, TX2_0, TX2_1, TX1_0, TX1_1, TX0_0:
            next_state = state+1; // bad practice
        RX7_0, RX7_1, RX6_0, RX6_1, RX5_0, RX5_1, RX4_0, RX4_1, RX3_0, RX3_1, RX2_0, RX2_1, RX1_0, RX1_1, RX0_0:
            next_state = state+1; // bad practice
        DMYO_0:
            next_state = DMYO_1;
        DMYI_0:
            next_state = DMYI_1;
        default: // TX0_1, RX0_1, DMYO_1, DMYI_1, erroneous
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
        TX7_0, TX7_1:
            qspi_mosi = {3'dx, txq_d[7]};
        TX6_0, TX6_1:
            qspi_mosi = {3'dx, txq_d[6]};
        TX5_0, TX5_1:
            qspi_mosi = {3'dx, txq_d[5]};
        TX4_0, TX4_1:
            qspi_mosi = {3'dx, txq_d[4]};
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
        DMYO_0, DMYO_1:
            qspi_mosi = dmy_out_pattern;
        default:
            qspi_mosi = 4'dx;
    endcase

    // qspi miso
    always @ (posedge clk) case (state)
        RX7_0:
            rxq_d[7] <= qspi_miso[1];
        RX6_0:
            rxq_d[6] <= qspi_miso[1];
        RX5_0:
            rxq_d[5] <= qspi_miso[1];
        RX4_0:
            rxq_d[4] <= qspi_miso[1];
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
                CMD   = 1 ,
                ADDR2 = 2 ,
                ADDR1 = 3 ,
                ADDR0 = 4 ,
                DMY15 = 5 ,
                DMY14 = 6 ,
                DMY13 = 7 ,
                DMY12 = 8 ,
                DMY11 = 9 ,
                DMY10 = 10,
                DMY9  = 11,
                DMY8  = 12,
                DMY7  = 13,
                DMY6  = 14,
                DMY5  = 15,
                DMY4  = 16,
                DMY3  = 17,
                DMY2  = 18,
                DMY1  = 19,
                DATA3 = 20,
                DATA2 = 21,
                DATA1 = 22,
                DATA0 = 23;

    reg[7:0]    state, next_state;
    always @ (posedge clk)
        if (~rstn)
            state <= IDLE;
        else
            state <= next_state;

    always @ (*) case (state)
        IDLE:
            if (req & ~invld)
                next_state = CMD;
            else
                next_state = IDLE;
        CMD:
            if (tx_resp)
                next_state = ADDR2;
            else
                next_state = CMD;
        ADDR2, ADDR1:
            if (tx_resp)
                next_state = state+1; // bad practice
            else
                next_state = state;
        ADDR0:
            if (tx_resp)
                next_state = 15+DMY15-cfg_dmy_cnt; // bad practice
            else
                next_state = ADDR0;
        DMY15, DMY14, DMY13, DMY12, DMY11, DMY10, DMY9, DMY8, DMY7, DMY6, DMY5, DMY4, DMY3, DMY2:
            if (dmy_resp)
                next_state = state+1; // bad practice
            else
                next_state = state;
        DMY1:
            if (dmy_resp) case (req_acc)
                `BUS_ACC_4B: next_state = DATA3;
                `BUS_ACC_2B: next_state = DATA1;
                default:     next_state = DATA0; // BUS_ACC_1B
            endcase else
                next_state = state;
        DATA3, DATA2, DATA1:
            if (rx_resp)
                next_state = state+1; // bad practice
            else
                next_state = state;
        DATA0:
            if (rx_resp)
                next_state = IDLE;
            else
                next_state = DATA0;
        default:
            next_state = IDLE;
    endcase

    // control
    assign qspi_csb = (state==IDLE) && (next_state==IDLE);

    always @ (*) case (next_state) // better use assign to propagate x
        CMD: begin
            width = cfg_cmd_width;
            tx_req = req;
            rx_req = 0;
            dmy_req = 0;
            txq_d = cfg_cmd_octet;
        end
        ADDR2: begin
            width = cfg_addr_width;
            tx_req = tx_resp;
            rx_req = 0;
            dmy_req = 0;
            txq_d = req_addr[23:16];
        end
        ADDR1: begin
            width = cfg_addr_width;
            tx_req = tx_resp;
            rx_req = 0;
            dmy_req = 0;
            txq_d = req_addr[15:8];
        end
        ADDR0: begin
            width = cfg_addr_width;
            tx_req = tx_resp;
            rx_req = 0;
            dmy_req = 0;
            txq_d = req_addr[7:0];
        end
        DMY15: begin
            width = cfg_dmy_width;
            tx_req = 0;
            rx_req = 0;
            dmy_req = tx_resp;
            txq_d = 8'dx;
        end
        DMY14, DMY13, DMY12, DMY11, DMY10, DMY9, DMY8, DMY7, DMY6, DMY5, DMY4, DMY3, DMY2, DMY1: begin
            width = cfg_dmy_width;
            tx_req = 0;
            rx_req = 0;
            dmy_req = dmy_resp;
            txq_d = 8'dx;
        end
        DATA3: begin
            width = cfg_data_width;
            tx_req = 0;
            rx_req = dmy_resp;
            dmy_req = 0;
            txq_d = 8'dx;
        end
        DATA2, DATA1, DATA0: begin
            width = cfg_data_width;
            tx_req = 0;
            rx_req = rx_resp;
            dmy_req = 0;
            txq_d = 8'dx;
        end
        default: begin
            width = 2'dx;
            tx_req = 0;
            rx_req = 0;
            dmy_req = 0;
            txq_d = 8'dx;
        end
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
    output wire qspi_csb
);

    /*
     * Register map
     *  Name   | Address | Size | Access | Note
     *  REQ    | 0       | 2    | W      | -
     *  TXD    | 2       | 1    | W      | -
     *  RXD    | 3       | 1    | R      | -
     *  TXQCSR | 4       | 1    | R/W    | -
     *  RXQCSR | 5       | 1    | R/W    | -
     *  NORCSR | 6       | 2    | R/W    | -
     *
     * REQ
     *  DUMMY_OUT_PATTERN(15:12) | COUNT(11:8) | (7:6) | WIDTH(5:4) | DUMMY(3) | DIR(2) | (1) | SEL(0)
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
    wire invld_wr   = w_rb ? (addr==3) : (addr<3);
    wire invld_d    = ((addr==0) && wdata[0] && wdata[3] && (wdata[11:8]==0)) ||
                      ((addr==6) && w_rb && (wdata[2:0]>6));

    wire invld      = |{invld_addr,invld_acc,invld_wr,invld_d};
    assign fault    = req & invld;

    // latch request
    wire[`QSPINOR_VA_WIDTH-1:0] req_addr;
    wire[`BUS_WIDTH-1:0]        req_wdata;
    dff # (
        .WIDTH(`QSPINOR_VA_WIDTH+`BUS_WIDTH),
        .VALID("async")
    ) req_acc_dff (
        .clk(clk         ),
        .vld(req & ~invld),
        .in ({addr, wdata}        ),
        .out({req_addr, req_wdata})
    );

    // data queues
    wire      mosiq_w = req & ~invld & (addr==2);
    wire[7:0] mosiq_wd = wdata[7:0];
    wire      mosiq_full, txq_empty;
    wire      mosiq_clr = req & ~invld & (addr==4) & w_rb & (wdata[1]);

    wire      txq_r;
    wire[7:0] txq_rd;
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
        .dout (txq_rd   ),
        .r    (txq_r    ),
        .empty(txq_empty)
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

    // register access
    reg[15:0]   norcsr;
    wire[7:0]   norcsr_cmd_octet = norcsr[15:8];
    wire[3:0]   norcsr_dmy_cnt = norcsr[7:4];
    wire        norcsr_dmy_dir = norcsr[3];
    wire[2:0]   norcsr_mode = norcsr[2:0];

    always @ (posedge clk) begin
        if (~rstn) begin
            norcsr <= 0;
        end else if (req & ~invld) case (addr)
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

    // cfg out
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

    // state
    localparam  IDLE    = 0 ,
                TCNTMAX = 1 ,
                TCNT15  = 2 ,
                TCNT14  = 3 ,
                TCNT13  = 4 ,
                TCNT12  = 5 ,
                TCNT11  = 6 ,
                TCNT10  = 7 ,
                TCNT9   = 8 ,
                TCNT8   = 9 ,
                TCNT7   = 10,
                TCNT6   = 11,
                TCNT5   = 12,
                TCNT4   = 13,
                TCNT3   = 14,
                TCNT2   = 15,
                TCNT1   = 16,
                RCNTMAX = 17,
                RCNT15  = 18,
                RCNT14  = 19,
                RCNT13  = 20,
                RCNT12  = 21,
                RCNT11  = 22,
                RCNT10  = 23,
                RCNT9   = 24,
                RCNT8   = 25,
                RCNT7   = 26,
                RCNT6   = 27,
                RCNT5   = 28,
                RCNT4   = 29,
                RCNT3   = 30,
                RCNT2   = 31,
                RCNT1   = 32,
                DCNT15  = 33,
                DCNT14  = 34,
                DCNT13  = 35,
                DCNT12  = 36,
                DCNT11  = 37,
                DCNT10  = 38,
                DCNT9   = 39,
                DCNT8   = 40,
                DCNT7   = 41,
                DCNT6   = 42,
                DCNT5   = 43,
                DCNT4   = 44,
                DCNT3   = 45,
                DCNT2   = 46,
                DCNT1   = 47;
    reg[7:0]    state, next_state;
    always @ (posedge clk)
        if (~rstn)
            state <= IDLE;
        else
            state <= next_state;

    always @ (*) case (state)
        IDLE:
            if (req && ~invld && req_addr==0 && req_wdata[0]) begin // selected
                if (req_wdata[3]) begin // dummy
                    next_state = 15+DCNT15-req_wdata[11:8]; // bad practice
                end else if (req_wdata[2]) begin // tx
                    if (req_wdata[11:8])
                        next_state = 15+TCNT15-req_wdata[11:8]; // bad practice
                    else if (~txq_empty)
                        next_state = TCNTMAX;
                    else
                        next_state = IDLE;
                end else begin // rx
                    if (req_wdata[11:8])
                        next_state = 15+RCNT15-req_wdata[11:8]; // bad practice
                    else if (~rxq_full)
                        next_state = RCNTMAX;
                    else
                        next_state = IDLE;
                end
            end else
                next_state = IDLE;
        TCNTMAX:
            if (tx_resp && txq_empty)
                next_state = IDLE;
            else
                next_state = TCNTMAX;
        TCNT15, TCNT14, TCNT13, TCNT12, TCNT11, TCNT10, TCNT9, TCNT8, TCNT7, TCNT6, TCNT5, TCNT4, TCNT3, TCNT2:
            if (tx_resp)
                next_state = state+1; // bad practice
            else
                next_state = state;
        TCNT1:
            if (tx_resp)
                next_state = IDLE;
            else
                next_state = TCNT1;
        RCNTMAX:
            if (rx_resp && rxq_full)
                next_state = IDLE;
            else
                next_state = RCNTMAX;
        RCNT15, RCNT14, RCNT13, RCNT12, RCNT11, RCNT10, RCNT9, RCNT8, RCNT7, RCNT6, RCNT5, RCNT4, RCNT3, RCNT2:
            if (rx_resp)
                next_state = state+1; // bad practice
            else
                next_state = state;
        RCNT1:
            if (rx_resp)
                next_state = IDLE;
            else
                next_state = RCNT1;
        DCNT15, DCNT14, DCNT13, DCNT12, DCNT11, DCNT10, DCNT9, DCNT8, DCNT7, DCNT6, DCNT5, DCNT4, DCNT3, DCNT2:
            if (dmy_resp)
                next_state = state+1; // bad practice
            else
                next_state = state;
        DCNT1:
            if (dmy_resp)
                next_state = IDLE;
            else
                next_state = DCNT1;
        default:
            next_state = IDLE;
    endcase

    // control
    assign  width = req_wdata[5:4];

    assign  txq_rdy = ~txq_empty;
    assign  txq_d = txq_rd;
    assign  txq_r = tx_resp;

    assign  rxq_rdy = ~rxq_full;
    assign  rxq_wd = rxq_d;
    assign  rxq_w = rx_resp;

    assign  dmy_dir = req_wdata[2];
    assign  dmy_out_pattern = req_wdata[15:12];

    assign  qspi_csb = (state==IDLE) && (next_state==IDLE);

    always @ (*) case (next_state) // better use assign to propagate x
        TCNTMAX, TCNT15, TCNT14, TCNT13, TCNT12, TCNT11, TCNT10, TCNT9, TCNT8, TCNT7, TCNT6, TCNT5, TCNT4, TCNT3, TCNT2, TCNT1:
            begin
                tx_req = req | tx_resp;
                rx_req = 0;
                dmy_req = 0;
            end
        RCNTMAX, RCNT15, RCNT14, RCNT13, RCNT12, RCNT11, RCNT10, RCNT9, RCNT8, RCNT7, RCNT6, RCNT5, RCNT4, RCNT3, RCNT2, RCNT1:
            begin
                tx_req = 0;
                rx_req = req | rx_resp;
                dmy_req = 0;
            end
        DCNT15, DCNT14, DCNT13, DCNT12, DCNT11, DCNT10, DCNT9, DCNT8, DCNT7, DCNT6, DCNT5, DCNT4, DCNT3, DCNT2, DCNT1:
            begin
                tx_req = 0;
                rx_req = 0;
                dmy_req = req | dmy_resp;
            end
        default:
            begin
                tx_req = 0;
                rx_req = 0;
                dmy_req = 0;
            end
    endcase

    // resp generation
    always @ (posedge clk) begin
        if (~rstn)
            resp <= 0;
        else if (state==IDLE && next_state==IDLE)
            resp <= req & ~invld;
        else if (state!=IDLE && next_state==IDLE)
            resp <= 1;
        else
            resp <= 0;
    end
endmodule

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
    wire        nor_qspi_csb,         qspinor_qspi_csb;

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

    wire        io_width;
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
