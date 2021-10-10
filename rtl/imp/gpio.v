`include "timescale.vh"

(* keep_hierarchy = "yes" *)
module gpio_controller(
    input wire  clk,
    input wire  rstn,

    output reg[`GPIO_WIDTH-1:0]     dir,
    input wire[`GPIO_WIDTH-1:0]     i,
    output reg[`GPIO_WIDTH-1:0]     o,

    input wire[`GPIO_VA_WIDTH-1:0]  addr,
    input wire                      w_rb,
    input wire[`BUS_ACC_WIDTH-1:0]  acc,
    output wire[`BUS_WIDTH-1:0]     rdata,
    input wire[`BUS_WIDTH-1:0]      wdata,
    input wire                      req,
    output reg                      resp,
    output wire                     fault
);
    /*
     * Register map
     *  Name | Address | Size | Access | Note
     *  D    | 0       | 4    | R/W    | -
     *  DIR  | 4       | 4    | R/W    | -
     */

    // fault generation
    wire invld_addr = (addr!=0 && addr!=4);
    wire invld_acc  = (acc != `BUS_ACC_4B);
    wire invld_wr   = 0;
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

    // gpio control
    reg [`GPIO_WIDTH-1:0] rdata_r;
    assign rdata = {{(`BUS_WIDTH-`GPIO_WIDTH){1'b0}}, rdata_r}; // might need updates if GPIO_WIDTH==32

    always @ (posedge clk) begin
        if (rstn==0) begin
            dir <= {`GPIO_WIDTH{`IOR_DIR_IN}};
        end else if (req) begin
            if (addr==0) begin
                if (~w_rb) begin // read io
                    rdata_r <= i;
                end else begin // write io
                    o <= wdata[`GPIO_WIDTH-1:0];
                end
            end else begin
                if (~w_rb) begin // read dir
                    rdata_r <= dir;
                end else begin // write dir
                    dir <= wdata[`GPIO_WIDTH-1:0] ^ {`GPIO_WIDTH{`IOR_DIR_IN}};
                end
            end
        end
    end
endmodule
