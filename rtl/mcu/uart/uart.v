`include "femto.vh"
`include "timescale.vh"

module uart_controller(
    input wire  clk,
    input wire  rstn, // sync

    input wire  rx,
    output wire tx,

    output wire interrupt,

    // user interface
    input wire[$clog2(`UART_SIZE)-1:0]  addr,
    input wire                          w_rb,
    input wire[`BUS_ACC_WIDTH-1:0]      acc,
    output reg[`BUS_WIDTH-1:0]          rdata,
    input wire[`BUS_WIDTH-1:0]          wdata,
    input wire                          req,
    output reg                          resp,
    output wire                         fault
);
    /*
     * Register map
     *  Name    | Address | Size | Access | Note
     *  TXD     | 0       | 1    | W      | -
     *  RXD     | 1       | 1    | R      | -
     *  TXQCSR  | 2       | 1    | R/W    | -
     *  RXQCSR  | 3       | 1    | R/W    | -
     *
     * TXQCSR
     *  INTEN(7) | (6:1) | RDY(0)
     * RXQCSR
     *  INTEN(7) | (6:2) | CLR(1) | RDY(0)
     */

    // fault generation
    wire invld_addr = 0;
    wire invld_acc  = (acc != `BUS_ACC_1B);
    wire invld_wr   = ((addr==0 && ~w_rb) || ((addr==1 || addr==2) && w_rb));

    wire invld      = |{invld_addr,invld_acc,invld_wr};
    assign fault    = req & invld;

    // resp generation
    always @ (posedge clk) begin
        if (~rstn) begin
            resp <= 0;
        end else begin
            resp <= req & ~invld;
        end
    end

    // uart t/r interface
    wire uart_rxq_empty, uart_rxq_clr, uart_txq_full;
    wire uart_tx_req, uart_rx_req;
    wire [7:0] uart_rx_data;
    wire [7:0] uart_tx_data = wdata[7:0];

    uart_transceiver ux(
        .clk (clk ),
        .rstn(rstn),
        .rx  (rx  ),
        .tx  (tx  ),
        .rxq_empty(uart_rxq_empty),
        .rxq_clr  (uart_rxq_clr  ),
        .txq_full (uart_txq_full ),
        .recv_resp(uart_rx_req   ),
        .send_req (uart_tx_req   ),
        .recv_data(uart_rx_data  ),
        .send_data(uart_tx_data  )
    );

    assign uart_tx_req=(req & ~invld) && (addr==0) && w_rb;
    assign uart_rx_req=(req & ~invld) && (addr==1) && ~w_rb;
    assign uart_rxq_clr=(req & ~invld) && (addr==3) && w_rb && wdata[1];

    reg txinten, rxinten;
    always @ (posedge clk) begin
        if (~rstn) begin
            txinten <= 1'b0;
            rxinten <= 1'b0;
        end else if (req & ~invld) case (addr)
            1: if (~w_rb) rdata[7:0] <= uart_rx_data;
            2: if (~w_rb) rdata[7:0] <= {txinten, 6'd0, ~uart_txq_full};  else txinten <= wdata[7];
            3: if (~w_rb) rdata[7:0] <= {rxinten, 6'd0, ~uart_rxq_empty}; else rxinten <= wdata[7];
        endcase
    end

    assign interrupt = (txinten & ~uart_txq_full) | (rxinten & ~uart_rxq_empty);
endmodule

module uart_transceiver(
    input wire          clk,
    input wire          rstn,

    // UART interface
    input wire          rx,
    output wire         tx,

    // Rx user interface
    output wire         rxq_empty,
    input wire          rxq_clr,
    input wire          recv_resp,
    output wire[7:0]    recv_data,

    // Tx user interface
    output wire         txq_full,
    input wire          send_req,
    input wire[7:0]     send_data
);
    // Receiver
    wire        uart_rx_fetch_trig;
    wire[7:0]   uart_rx_fetch_data;

    fifo # (
        .WIDTH(8               ),
        .DEPTH(`UART_FIFO_DEPTH),
        .CLEAR("sync"          )
    ) uart_rx_fifo (
        .clk  (clk               ),
        .rstn (rstn              ),
        .din  (uart_rx_fetch_data),
        .dout (recv_data         ),
        .w    (uart_rx_fetch_trig),
        .r    (recv_resp         ),
        .empty(rxq_empty         ),
        .clr  (rxq_clr           )
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
        .WIDTH(8               ),
        .DEPTH(`UART_FIFO_DEPTH)
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

    // Transmitter control
    always@(posedge clk or negedge rstn)begin
        if (rstn==0) begin
            uart_tx_send_trig<=1'b0;
        end else begin
            uart_tx_send_trig<=~(uart_tx_send_trig|uart_tx_idle|uart_tx_busy);
        end
    end
endmodule

module uart_rx #(
    parameter   SYSCLOCK=`SYSCLK_FREQ, // <Hz>
    parameter   BAUDRATE=`UART_BAUD
)(
    input wire          clk,
    input wire          rstn,

    input wire          rx,

    output reg          fetch_trig,
    output reg [7:0]    fetch_data
);
    localparam  NEDET_ORDER=5,                                                            // Nedge Detector order
                NEDET_DELAY=(NEDET_ORDER+1)/2,                                            // Nedge Detector delay
                NEDET_PATTERN={{NEDET_DELAY{1'b1}}, {(NEDET_ORDER-NEDET_DELAY+1){1'b0}}}; // Nedge Detector pattern

    localparam  CLKPERFRM   = (SYSCLOCK*10+BAUDRATE-1)/BAUDRATE,
                BIT_INI_CNT = (( 1*SYSCLOCK+BAUDRATE*2-1)/(BAUDRATE*2))-NEDET_DELAY,
                BIT_0_CNT   = (( 3*SYSCLOCK+BAUDRATE*2-1)/(BAUDRATE*2))-NEDET_DELAY,
                BIT_1_CNT   = (( 5*SYSCLOCK+BAUDRATE*2-1)/(BAUDRATE*2))-NEDET_DELAY,
                BIT_2_CNT   = (( 7*SYSCLOCK+BAUDRATE*2-1)/(BAUDRATE*2))-NEDET_DELAY,
                BIT_3_CNT   = (( 9*SYSCLOCK+BAUDRATE*2-1)/(BAUDRATE*2))-NEDET_DELAY,
                BIT_4_CNT   = ((11*SYSCLOCK+BAUDRATE*2-1)/(BAUDRATE*2))-NEDET_DELAY,
                BIT_5_CNT   = ((13*SYSCLOCK+BAUDRATE*2-1)/(BAUDRATE*2))-NEDET_DELAY,
                BIT_6_CNT   = ((15*SYSCLOCK+BAUDRATE*2-1)/(BAUDRATE*2))-NEDET_DELAY,
                BIT_7_CNT   = ((17*SYSCLOCK+BAUDRATE*2-1)/(BAUDRATE*2))-NEDET_DELAY,
                BIT_FIN_CNT = ((19*SYSCLOCK+BAUDRATE*2-1)/(BAUDRATE*2))-NEDET_DELAY;

    // reception start detect
    reg[NEDET_ORDER:1]  prev_rx;
    wire rx_nedge = ({prev_rx, rx}==NEDET_PATTERN);

    always@(posedge clk)begin
        if (rstn==0) begin
            prev_rx<={NEDET_ORDER{1'b1}}; // init val should be all 1s
        end else begin
            prev_rx<={prev_rx[NEDET_ORDER-1:1], rx};
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

                if(rx_cnt==BIT_INI_CNT)begin
                    if(rx==1'b1) rx_bsy<=1'b0;
                end

                if(rx_cnt==BIT_FIN_CNT)begin
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
    reg sample[3:1];
    always@(posedge clk)begin
        if (rstn==0) begin
            fetch_data<=8'd0;
        end else begin
            case(rx_cnt)
                (BIT_0_CNT-3),(BIT_1_CNT-3),(BIT_2_CNT-3),(BIT_3_CNT-3),(BIT_4_CNT-3),(BIT_5_CNT-3),(BIT_6_CNT-3),(BIT_7_CNT-3):    sample[3]<=rx;
                (BIT_0_CNT-2),(BIT_1_CNT-2),(BIT_2_CNT-2),(BIT_3_CNT-2),(BIT_4_CNT-2),(BIT_5_CNT-2),(BIT_6_CNT-2),(BIT_7_CNT-2):    sample[2]<=rx;
                (BIT_0_CNT-1),(BIT_1_CNT-1),(BIT_2_CNT-1),(BIT_3_CNT-1),(BIT_4_CNT-1),(BIT_5_CNT-1),(BIT_6_CNT-1),(BIT_7_CNT-1):    sample[1]<=rx;
                BIT_0_CNT:  fetch_data[0] <= (sample[3] & sample[2]) | (sample[2] & sample[1]) | (sample[1] & sample[3]);
                BIT_1_CNT:  fetch_data[1] <= (sample[3] & sample[2]) | (sample[2] & sample[1]) | (sample[1] & sample[3]);
                BIT_2_CNT:  fetch_data[2] <= (sample[3] & sample[2]) | (sample[2] & sample[1]) | (sample[1] & sample[3]);
                BIT_3_CNT:  fetch_data[3] <= (sample[3] & sample[2]) | (sample[2] & sample[1]) | (sample[1] & sample[3]);
                BIT_4_CNT:  fetch_data[4] <= (sample[3] & sample[2]) | (sample[2] & sample[1]) | (sample[1] & sample[3]);
                BIT_5_CNT:  fetch_data[5] <= (sample[3] & sample[2]) | (sample[2] & sample[1]) | (sample[1] & sample[3]);
                BIT_6_CNT:  fetch_data[6] <= (sample[3] & sample[2]) | (sample[2] & sample[1]) | (sample[1] & sample[3]);
                BIT_7_CNT:  fetch_data[7] <= (sample[3] & sample[2]) | (sample[2] & sample[1]) | (sample[1] & sample[3]);
            endcase
        end
    end
endmodule

module uart_tx #(
    parameter   SYSCLOCK=`SYSCLK_FREQ, // <Hz>
    parameter   BAUDRATE=`UART_BAUD
)(
    input wire      clk,
    input wire      rstn,

    output reg      tx,

    output reg      tx_bsy,
    input wire      send_trig,
    input wire[7:0] send_data
);

    localparam  CLKPERFRM   = (SYSCLOCK*10+BAUDRATE-1)/BAUDRATE,
                BIT_INI_CNT = 1,
                BIT_0_CNT   = (SYSCLOCK*1+BAUDRATE/2)/BAUDRATE+1,
                BIT_1_CNT   = (SYSCLOCK*2+BAUDRATE/2)/BAUDRATE+1,
                BIT_2_CNT   = (SYSCLOCK*3+BAUDRATE/2)/BAUDRATE+1,
                BIT_3_CNT   = (SYSCLOCK*4+BAUDRATE/2)/BAUDRATE+1,
                BIT_4_CNT   = (SYSCLOCK*5+BAUDRATE/2)/BAUDRATE+1,
                BIT_5_CNT   = (SYSCLOCK*6+BAUDRATE/2)/BAUDRATE+1,
                BIT_6_CNT   = (SYSCLOCK*7+BAUDRATE/2)/BAUDRATE+1,
                BIT_7_CNT   = (SYSCLOCK*8+BAUDRATE/2)/BAUDRATE+1,
                BIT_FIN_CNT = (SYSCLOCK*9+BAUDRATE/2)/BAUDRATE+1;

    // tx flow control
    reg[15:0]   tx_cnt;
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
    reg[7:0]    send_data_r;
    always@(posedge clk)begin
        if (rstn==0) begin
            send_data_r<=8'd0;
            tx<=1'b1; // init val should be 1
        end else begin
            if(send_trig & (~tx_bsy)/* 2nd condition is vital */)
                send_data_r<=send_data;

            case(tx_cnt)
                BIT_INI_CNT: tx<=1'b0;
                BIT_0_CNT:   tx<=send_data_r[0];
                BIT_1_CNT:   tx<=send_data_r[1];
                BIT_2_CNT:   tx<=send_data_r[2];
                BIT_3_CNT:   tx<=send_data_r[3];
                BIT_4_CNT:   tx<=send_data_r[4];
                BIT_5_CNT:   tx<=send_data_r[5];
                BIT_6_CNT:   tx<=send_data_r[6];
                BIT_7_CNT:   tx<=send_data_r[7];
                BIT_FIN_CNT: tx<=1'b1;
            endcase
        end
    end
endmodule
