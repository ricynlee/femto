`include "femto.vh"
`include "sim/timescale.vh"

/* Cmd format
 *  Dummy DOE Width Count
 *    7    6   5:4   3:0
 * Warning
 *  No cmd_body validity check performed
*/
`define CMD_DMY 7
`define CMD_DOE 6
`define CMD_WID 5:4
`define CMD_CNT 3:0

module qspinor_io (
    input wire          clk,
    input wire          rstn,

    input wire          cmd_trig,
    input wire[7:4]     cmd_body,
    output reg          cmd_done,

    input wire          host_do_rdy,
    output wire         host_do_req,
    input wire[7:0]     host_do, // host data out to nor

    output wire         host_di_rdy,
    output wire         host_di_req,
    output wire[7:0]    host_di, // host data in from nor

    output reg          spi_sclk,
    output wire[3:0]    spi_dir,
    input wire[3:0]     spi_miso,
    output wire[3:0]    spi_mosi
);

    // cmd_body buffering
    wire[7:4] cmd_buff;
    dff #(
        .WIDTH(4     ),
        .VALID("sync")
    ) cmd_dff (
        .clk(clk     ),
        .vld(cmd_trig),
        .in (cmd_body),
        .out(cmd_buff)
    );

    wire[7:4] cmd_gate = cmd_trig ? cmd_body : cmd_buff;
    /*
                 _
     cmd_trig __/ \_______
                 _
     cmd_body XXX_XXXXXXXX
              ____ _______
     cmd_buff ____X_______
              __ _________
     cmd_gate __X_________
     */

    // state control
    localparam  IDLE = 0,
                WAIT = 1,
                TOGG = 2;

    reg[7:0] state, next_state;
    reg[7:0] tx_togg_index, rx_togg_index;
    always @ (posedge clk)
        if (~rstn)
            state <= IDLE;
        else
            state <= next_state;

    always @ (*) case (state)
        IDLE:
            if (cmd_trig) begin
                if (~cmd_gate[`CMD_DOE] & cmd_gate[`CMD_DMY])
                    next_state = TOGG;
                else if (cmd_gate[`CMD_DOE])
                    next_state = host_do_rdy ? TOGG : WAIT;
                else
                    next_state = host_di_rdy ? TOGG : WAIT;

                tx_togg_index = (cmd_gate[`CMD_DMY] ? 2 : (16>>cmd_gate[`CMD_WID])) - 1;
            end else begin
                next_state = IDLE;
                tx_togg_index = 0;
            end
        WAIT: begin
            tx_togg_index = rx_togg_index;
            if (cmd_gate[`CMD_DOE])
                next_state = host_do_rdy ? TOGG : WAIT;
            else
                next_state = host_di_rdy ? TOGG : WAIT;
        end
        TOGG: begin
            tx_togg_index = rx_togg_index-1

            if (!rx_togg_index)
                next_state = IDLE;
            else
                next_state = TOGG;
        end
        default: begin
            next_state = IDLE;
            tx_togg_index = 0;
        end
    endcase

    always @ (posedge clk) begin
        rx_togg_index <= tx_togg_index;
    end
endmodule








































































//     /* Cmd format
//      *  Dummy DOE Width Count
//      *    7    6   5:4   3:0
//      * Warning
//      *  No cmd_body validity check performed
//     */
//
//     // cmd_body buffering
//     wire[7:0] cmd_held, cmd_buff;
//     dff #(
//         .WIDTH(11    ),
//         .VALID("sync")
//     ) cmd_dff (
//         .clk(clk     ),
//         .vld(cmd_trig),
//         .in (cmd_body     ),
//         .out(cmd_buff)
//     );
//
//     wire        cmd_dmy_at_trig = cmd_held[7];
//     wire        cmd_doe_at_trig = cmd_held[6];
//     wire        cmd_dmy_at_trig = cmd_held[7];
//     wire        cmd_doe_at_trig = cmd_held[6];
//     wire[1:0]   cmd_wid = cmd_held[5:4];
//     wire[3:0]   cmd_cnt = cmd_held[3:0];
//
//     // state control
//     localparam  IDLE = 0,
//                 WAIT = 1,
//                 TOGGLE = 2;
//     reg[7:0]    state = IDLE;
//     reg[7:0]    next_state;
//     reg[7:0]    toggle_index;
//
//     always @ (*) begin
//         case (state)
//         IDLE, default:
//             if (cmd_trig) begin
//                 if (cmd_doe_at_trig) begin
//                     if (host_do_rdy)
//                         next_state = TOGGLE;
//                     else
//                         next_state = WAIT;
//                 end else begin
//                     if (cmd_dmy_at_trig | host_di_rdy)
//                         next_state = TOGGLE;
//                     else
//                         next_state = WAIT;
//                 end
//             end else
//                 next_state = IDLE;
//         WAIT:
//             if (cmd_doe_at_trig) begin
//                 if (host_do_rdy)
//                     next_state = TOGGLE;
//                 else
//                     next_state = WAIT;
//             end else begin
//                 if (cmd_dmy_at_trig | host_di_rdy)
//                     next_state = TOGGLE;
//                 else
//                     next_state = WAIT;
//             end
//         TOGGLE:
//             if (toggle_index==1)
//                 next_state = IDLE;
//             else
//                 next_state = TOGGLE;
//         endcase
//     end
//
//     always @ (posedge clk)
//         state <= next_state;
//
//     always @ (posedge clk) begin
//         if (~rstn) begin
//             toggle_index <= 0;
//         end else if (toggle_index) begin
//             toggle_index <= toggle_index-1;
//         end else if ((state==IDLE && cmd_trig) || (state==WAIT)) begin
//             if (cmd_doe_at_trig) begin
//                 toggle_index <= ~host_do_rdy ? 0 : cmd_dmy_at_trig ? {cmd_cnt, 1'b1} : ((16>>cmd_wid)-1);
//             end else begin
//                 toggle_index <= cmd_dmy_at_trig ? {cmd_cnt, 1'b1} : host_di_rdy ? ((16>>cmd_wid)-1) : 0;
//             end
//         end
//     end
//
//     always @ (posedge clk) begin
//         if (~rstn) begin
//             cmd_done <= 0;
//         end else if (toggle_index==1) begin
//             cmd_done <= 1;
//         end else begin
//             cmd_done <= 0;
//         end
//     end
//
//     // host interface
//     assign host_do_req = host_do_rdy & cmd_doe_at_trig & ((state==IDLE && cmd_trig) || state==WAIT);
//     assign host_di_req = host_di_rdy & ~cmd_doe_at_trig & ~cmd_dmy_at_trig & cmd_done;
//
//     // qspi interface
//     generate
//         if (`QSPINOR_MODE /*3*/) begin
//             assign spi_sclk = ~toggle_index[0];
//         end else begin
//             assign spi_sclk = (toggle_index || cmd_done) & ~toggle_index[0];
//         end
//     endgenerate
//
//     assign spi_dir[3] = (toggle_index || cmd_done) ? ((cmd_wid==2'b10 && cmd_doe_at_trig) ? `IOR_DIR_OUT : `IOR_DIR_IN) : `QSPINOR_IDLE_DIR;
//     assign spi_dir[2] = (toggle_index || cmd_done) ? ((cmd_wid==2'b10 && cmd_doe_at_trig) ? `IOR_DIR_OUT : `IOR_DIR_IN) : `QSPINOR_IDLE_DIR;
//     assign spi_dir[1] = (toggle_index || cmd_done) ? ((cmd_wid && cmd_doe_at_trig) ? `IOR_DIR_OUT : `IOR_DIR_IN) : `QSPINOR_IDLE_DIR;
//     assign spi_dir[0] = (toggle_index || cmd_done) ? (cmd_doe_at_trig ? `IOR_DIR_OUT : `IOR_DIR_IN) : `QSPINOR_IDLE_DIR;
//
//     wire[10:0] do_extended;
//     dff #(
//         .WIDTH(11     ),
//         .VALID("async")
//     ) cmd_dff (
//         .clk(clk            ),
//         .vld(host_do_req    ),
//         .in ({3'd0, host_do}),
//         .out(do_extended    )
//     );
//     assign spi_mosi = cmd_dmy_at_trig ? do_extended[3:0] : do_extended[(toggle_index[7:1]<<cmd_wid)+:4];
//
//     reg[-3:7] di_extended; // synthesizable in vivado
//     always @ (posedge clk) begin
//         if (toggle_index && ~spi_sclk) begin
//             di_extended[(toggle_index[7:1]<<cmd_wid)-:4] <= spi_miso;
//         end
//     end
//     generate
//         for(genvar i=0; i<8; i=i+1) begin assign host_di[i]=di_extended[i]; end
//     endgenerate
//
// endmodule
