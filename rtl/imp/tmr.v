`include "femto.vh"
`include "timescale.vh"

module timer_controller # (
    parameter   DIV = `TMR_DIV // 0<DIV<=65536
)(
    input wire  clk,
    input wire  rstn, // sync

    output wire interrupt,

    // user interface
    input wire[`TMR_VA_WIDTH-1:0]   addr,
    input wire                      w_rb,
    input wire[`BUS_ACC_WIDTH-1:0]  acc,
    output reg[`BUS_WIDTH-1:0]      rdata,
    input wire[`BUS_WIDTH-1:0]      wdata,
    input wire                      req,
    output reg                      resp,
    output wire                     fault
);

    /*
     * Register map
     *  Name    | Address | Size | Access | Note
     *  TR      | 0       | 4    | R/W    | -
     *  INTCSR  | 4       | 4    | R/W    | -
     *
     * INTCSR
     *  (31:8) | INTEN(7) | (6:0)
     */

    // fault generation
    wire invld_addr = (addr[1:0]!=0);
    wire invld_acc  = (acc!=`BUS_ACC_4B);
    wire invld_wr   = 0;

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

    // register operation
    reg[31:0]   tr;
    reg         inten;
    always @ (posedge clk)
        if (req & ~invld & ~w_rb)
            rdata <= addr[2] ? {24'd0, inten, 7'd0} : tr;

    reg[15:0]   div;
    always @ (posedge clk) begin
        if (~rstn)
            div <= 0;
        else if (req & ~invld & w_rb)
            div <= DIV-1;
        else if (tr) begin
            if (div==0)
                div <= DIV-1;
            else
                div <= div-1;
        end
        /* // Resetting div is unnecessary but keep the code
        else
            div <= 0;
        */
    end

    always @ (posedge clk) begin
        if (~rstn) begin
            tr <= 0;
            inten <= 1'b0;
        end else if (req & ~invld & w_rb) begin
            if (addr[2])
                inten <= wdata[7];
            else
                tr <= wdata;
        end else if (tr && !div) begin
            tr <= tr-1;
        end
    end

    assign interrupt = inten && (tr==1) && (div==0);
endmodule
