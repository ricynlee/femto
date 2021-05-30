`include "sim/timescale.vh"
// `include "femto.vh"

module uart_controller(
    input wire  clk,
    input wire  rstn, // sync
    // user interface
    input wire  req,
    output reg  resp,
    input wire  wr_b,
    input wire [$clog2(`BUS_ACC_CNT)-1:0]   acc,
    input wire  [1:0]                       addr,
    input wire  [31:0]                      wdata,
    output reg  [31:0]                      rdata,
    output wire                             fault,

    input wire  rx,
    output wire tx
);
    localparam  TXD_ADDR = 2'b00,
                RXD_ADDR = 2'b01,
                TXQ_CHK_ADDR = 2'b10,
                RXQ_CHK_ADDR = 2'b11;

    wire invld_acc = req & (acc!=`BUS_ACC_1B); // we don't need to handle unaligned r/w here
    wire invld_wr  = req & (wr_b ? (addr==RXD_ADDR || addr==TXQ_CHK_ADDR || addr==RXQ_CHK_ADDR) : addr==TXD_ADDR);
    wire invld_d   = 0;
    assign fault = invld_acc | invld_wr | invld_d;

    always @ (posedge clk) begin
        if (rstn==0) begin
            resp <= 0;
        end else begin
            resp <= req;
        end
    end

    wire uart_rxq_empty, uart_txq_full;
    wire uart_tx_req, uart_rx_resp;
    wire [7:0] uart_rx_data;
    wire [7:0] uart_tx_data = wdata[7:0];
    uart_transceiver ux(
        .clk (clk),
        .rstn(rstn),
        .rx  (rx),
        .tx  (tx),
        .rxq_empty(uart_rxq_empty),
        .txq_full (uart_txq_full ),
        .recv_resp(uart_rx_resp  ),
        .send_req (uart_tx_req   ),
        .recv_data(uart_rx_data  ),
        .send_data(uart_tx_data  )
    );
    
    assign uart_tx_req = req && addr==TXD_ADDR && wr_b==1;
    assign uart_rx_resp = req && addr==RXD_ADDR && wr_b==0;
    
    always @ (posedge clk) begin
        if (wr_b==0) begin
            if (uart_rx_resp) begin
                rdata[7:0] <= uart_rx_data;
            end else if (req) begin
                case (addr)
                    TXQ_CHK_ADDR:   rdata[7:0] <= {7'd0, uart_txq_full};
                    RXQ_CHK_ADDR:   rdata[7:0] <= {7'd0, uart_rxq_empty};
                    default: rdata[7:0] <= 8'd0;
                endcase
            end
        end
    end
endmodule

module uart_transceiver(
    input wire          clk,
    input wire          rstn,
    // UART interface
    input wire          rx,
    output wire         tx,

    // Rx user interface
    output wire         rxq_empty,
    input wire          recv_resp,
    output wire [7:0]   recv_data,

    // Tx user interface
    output wire         txq_full,
    input wire          send_req,
    input wire  [7:0]   send_data
);

    // Receiver
    wire uart_rx_fetch_trig;
    wire [7:0] uart_rx_fetch_data;
    
    integer rxbcnt=0;
    always @ (posedge uart_rx_fetch_trig) begin
        #1;
        $display("UART RX #%d: 0x%02x", rxbcnt, uart_rx_fetch_data);
        rxbcnt=rxbcnt+1;
    end

    fifo # (
        .WIDTH(8)
    ) uart_rx_fifo (
        .clk  (clk               ),
        .rstn (rstn              ),
        .din  (uart_rx_fetch_data),
        .dout (recv_data         ),
        .w    (uart_rx_fetch_trig),
        .r    (recv_resp         ),
        .empty(rxq_empty         )
    );

    uart_rx ur(
        .clk       (clk               ),
        .rstn      (rstn              ),
        .rx        (rx                ),
        .fetch_trig(uart_rx_fetch_trig),
        .fetch_data(uart_rx_fetch_data)
    );

    // Transmitter
    reg uart_tx_send_trig;
    wire [7:0] uart_tx_send_data;
    wire uart_tx_busy;
    wire uart_tx_idle;

    fifo # (
        .WIDTH(8)
    ) uart_tx_fifo (
        .clk  (clk              ),
        .rstn (rstn             ),
        .din  (send_data        ),
        .dout (uart_tx_send_data),
        .w    (send_req         ),
        .r    (uart_tx_send_trig),
        .full (txq_full         ),
        .empty(uart_tx_idle     )
    );
    
    uart_tx ut(
        .clk      (clk              ),
        .rstn     (rstn             ),
        .tx       (tx               ),
        .tx_bsy   (uart_tx_busy     ),
        .send_trig(uart_tx_send_trig),
        .send_data(uart_tx_send_data)
    );

    always@(posedge clk or negedge rstn)begin
        if (rstn==0) begin
            uart_tx_send_trig<=1'b0;
        end else begin
            uart_tx_send_trig<=~(uart_tx_send_trig|uart_tx_idle|uart_tx_busy);
        end
    end

endmodule

module uart_rx #(
    parameter   SYSCLOCK=12000000, // <Hz>
    parameter   BAUDRATE=57600,
    parameter   NEDORD=10, // Nedge Detector order
    parameter   NEDPAT=11'b11111000000, // Nedge Detector pattern
    parameter   NEDDLY=5, // Nedge Detector delay
    parameter   CLKPERFRM=16'd2077, // floor(SYSCLOCK/BAUDRATE*10)-NEDDLY-1
    // bit order is lsb-msb
    parameter   TBITAT=16'd99, // starT bit, round(SYSCLOCK/BAUDRATE*.5)-NEDDLY
    parameter   BIT0AT=16'd308, // round(SYSCLOCK/BAUDRATE*1.5)-NEDDLY
    parameter   BIT1AT=16'd516, // round(SYSCLOCK/BAUDRATE*2.5)-NEDDLY
    parameter   BIT2AT=16'd724, // round(SYSCLOCK/BAUDRATE*3.5)-NEDDLY
    parameter   BIT3AT=16'd933, // round(SYSCLOCK/BAUDRATE*4.5)-NEDDLY
    parameter   BIT4AT=16'd1141, // round(SYSCLOCK/BAUDRATE*5.5)-NEDDLY
    parameter   BIT5AT=16'd1349, // round(SYSCLOCK/BAUDRATE*6.5)-NEDDLY
    parameter   BIT6AT=16'd1558, // round(SYSCLOCK/BAUDRATE*7.5)-NEDDLY
    parameter   BIT7AT=16'd1766, // round(SYSCLOCK/BAUDRATE*8.5)-NEDDLY
    parameter   PBITAT=16'd1974 // stoP bit, round(SYSCLOCK/BAUDRATE*9.5)-NEDDLY
)(
    input wire          clk,
    input wire          rstn,

    input wire          rx,

    output reg          fetch_trig,
    output reg [7:0]    fetch_data
);

    // reception start detect
    (*async_reg = "true"*) reg     [NEDORD:1]      prev_rx;
    reg                     rx_nedge; // reception starts at nedge of rx
    wire    [NEDORD+1:1]    prev_rx_tmp;
    assign                  prev_rx_tmp={prev_rx[NEDORD:1],rx};
    always@(posedge clk)begin
        if (rstn==0) begin
            prev_rx<={NEDORD{1'b1}}; // init val should be all 1s
            rx_nedge<=1'b0;
        end else begin
            prev_rx<=prev_rx_tmp[NEDORD:1];
            if({prev_rx,rx}==NEDPAT)
                rx_nedge<=1'b1;
            else
                rx_nedge<=1'b0;
        end
    end

    // rx flow control
    reg     [15:0]  rx_cnt;
    reg             rx_bsy;

    always@(posedge clk)begin
        if (rstn==0) begin
            rx_cnt<=16'd0;
            rx_bsy<=1'b0;
            fetch_trig<=1'b0;
        end else begin
            if(rx_nedge & (~rx_bsy)/* 2nd condition is vital */)
                rx_bsy<=1'b1;

            if(rx_bsy)begin
                rx_cnt<=rx_cnt+1'b1;

                if(rx_cnt==TBITAT)begin
                    if(rx==1'b1) rx_bsy<=1'b0;
                end

                if(rx_cnt==PBITAT)begin
                    rx_bsy<=1'b0;
                    if(rx==1'b1) fetch_trig<=1'b1;
                end
            end else /*if(~rx_bsy)*/ begin
                rx_cnt<=16'd0;
            end

            if(fetch_trig)
                fetch_trig<=1'b0;
        end
    end

    // rx data control
    (*async_reg = "true"*) reg fetch_data_bit[3:1];
    always@(posedge clk)begin
        if (rstn==0) begin
            fetch_data<=8'd0;
        end else begin
            case(rx_cnt)
                (BIT0AT-3): fetch_data_bit[3]<=rx;
                (BIT0AT-2): fetch_data_bit[2]<=rx;
                (BIT0AT-1): fetch_data_bit[1]<=rx;
                BIT0AT:     fetch_data[0] <= (fetch_data_bit[3] & fetch_data_bit[2]) | (fetch_data_bit[2] & fetch_data_bit[1]) | (fetch_data_bit[1] & fetch_data_bit[3]);
                (BIT1AT-3): fetch_data_bit[3]<=rx;
                (BIT1AT-2): fetch_data_bit[2]<=rx;
                (BIT1AT-1): fetch_data_bit[1]<=rx;
                BIT1AT:     fetch_data[1] <= (fetch_data_bit[3] & fetch_data_bit[2]) | (fetch_data_bit[2] & fetch_data_bit[1]) | (fetch_data_bit[1] & fetch_data_bit[3]);
                (BIT2AT-3): fetch_data_bit[3]<=rx;
                (BIT2AT-2): fetch_data_bit[2]<=rx;
                (BIT2AT-1): fetch_data_bit[1]<=rx;
                BIT2AT:     fetch_data[2] <= (fetch_data_bit[3] & fetch_data_bit[2]) | (fetch_data_bit[2] & fetch_data_bit[1]) | (fetch_data_bit[1] & fetch_data_bit[3]);
                (BIT3AT-3): fetch_data_bit[3]<=rx;
                (BIT3AT-2): fetch_data_bit[2]<=rx;
                (BIT3AT-1): fetch_data_bit[1]<=rx;
                BIT3AT:     fetch_data[3] <= (fetch_data_bit[3] & fetch_data_bit[2]) | (fetch_data_bit[2] & fetch_data_bit[1]) | (fetch_data_bit[1] & fetch_data_bit[3]);
                (BIT4AT-3): fetch_data_bit[3]<=rx;
                (BIT4AT-2): fetch_data_bit[2]<=rx;
                (BIT4AT-1): fetch_data_bit[1]<=rx;
                BIT4AT:     fetch_data[4] <= (fetch_data_bit[3] & fetch_data_bit[2]) | (fetch_data_bit[2] & fetch_data_bit[1]) | (fetch_data_bit[1] & fetch_data_bit[3]);
                (BIT5AT-3): fetch_data_bit[3]<=rx;
                (BIT5AT-2): fetch_data_bit[2]<=rx;
                (BIT5AT-1): fetch_data_bit[1]<=rx;
                BIT5AT:     fetch_data[5] <= (fetch_data_bit[3] & fetch_data_bit[2]) | (fetch_data_bit[2] & fetch_data_bit[1]) | (fetch_data_bit[1] & fetch_data_bit[3]);
                (BIT6AT-3): fetch_data_bit[3]<=rx;
                (BIT6AT-2): fetch_data_bit[2]<=rx;
                (BIT6AT-1): fetch_data_bit[1]<=rx;
                BIT6AT:     fetch_data[6] <= (fetch_data_bit[3] & fetch_data_bit[2]) | (fetch_data_bit[2] & fetch_data_bit[1]) | (fetch_data_bit[1] & fetch_data_bit[3]);
                (BIT7AT-3): fetch_data_bit[3]<=rx;
                (BIT7AT-2): fetch_data_bit[2]<=rx;
                (BIT7AT-1): fetch_data_bit[1]<=rx;
                BIT7AT:     fetch_data[7] <= (fetch_data_bit[3] & fetch_data_bit[2]) | (fetch_data_bit[2] & fetch_data_bit[1]) | (fetch_data_bit[1] & fetch_data_bit[3]);
            endcase
        end
    end

endmodule

module uart_tx #(
    parameter   SYSCLOCK=12000000, // <Hz>
    parameter   BAUDRATE=57600,
    parameter   CLKPERFRM=16'd2084, // ceil(SYSCLOCK/BAUDRATE*10)
    // bit order is lsb-msb
    parameter   TBITAT=16'd1, // starT bit, round(SYSCLOCK/BAUDRATE*0)+1
    parameter   BIT0AT=16'd209, // round(SYSCLOCK/BAUDRATE*1)+1
    parameter   BIT1AT=16'd418, // round(SYSCLOCK/BAUDRATE*2)+1
    parameter   BIT2AT=16'd626, // round(SYSCLOCK/BAUDRATE*3)+1
    parameter   BIT3AT=16'd834, // round(SYSCLOCK/BAUDRATE*4)+1
    parameter   BIT4AT=16'd1043, // round(SYSCLOCK/BAUDRATE*5)+1
    parameter   BIT5AT=16'd1251, // round(SYSCLOCK/BAUDRATE*6)+1
    parameter   BIT6AT=16'd1459, // round(SYSCLOCK/BAUDRATE*7)+1
    parameter   BIT7AT=16'd1668, // round(SYSCLOCK/BAUDRATE*8)+1
    parameter   PBITAT=16'd1876 // stoP bit, round(SYSCLOCK/BAUDRATE*9)+1
)(
    input wire          clk,
    input wire          rstn,

    output reg          tx=1'b1,

    output reg          tx_bsy,
    input wire          send_trig,
    input wire  [7:0]   send_data
);

    // tx flow control
    reg     [15:0]  tx_cnt;
    always@(posedge clk)begin
        if (rstn==0) begin
            tx_cnt<=16'd0;
            tx_bsy<=1'b0;
        end else begin
            if(send_trig & (~tx_bsy)/* 2nd condition is vital */)
                tx_bsy<=1'b1;

            if(tx_bsy)begin
                if(tx_cnt==CLKPERFRM)begin
                    tx_cnt<=16'd0;
                    tx_bsy<=1'b0;
                end else
                    tx_cnt<=tx_cnt+1'b1;
            end
        end
    end

    // tx data control
    reg     [7:0]   data2send;
    always@(posedge clk)begin
        if (rstn==0) begin
            data2send<=8'd0;
            tx<=1'b1; // init val should be 1
        end else begin
            if(send_trig & (~tx_bsy)/* 2nd condition is vital */)
                data2send<=send_data;

            case(tx_cnt)
                TBITAT: tx<=1'b0;
                BIT0AT: tx<=data2send[0];
                BIT1AT: tx<=data2send[1];
                BIT2AT: tx<=data2send[2];
                BIT3AT: tx<=data2send[3];
                BIT4AT: tx<=data2send[4];
                BIT5AT: tx<=data2send[5];
                BIT6AT: tx<=data2send[6];
                BIT7AT: tx<=data2send[7];
                PBITAT: tx<=1'b1;
            endcase
        end
    end

endmodule
