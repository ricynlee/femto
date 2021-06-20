`include "femto.vh"
`include "sim/timescale.vh"

module sernor_io (
    input wire  clk,
    input wire  rstn,

    input wire          trig,
    output reg          done,
    input wire[7:0]     dout, // to nor, externally guaranteed constant before next done
    output wire[7:0]    din, // from nor

    input wire          dir, // externally guaranteed constant before next done
    input wire[1:0]     wid, // externally guaranteed constant before next done

    output wire         spi_sclk,
    output wire         spi_dir,
    input wire[7:0]     spi_din, // from nor
    output wire[7:0]    spi_dout // to nor
);

    // state control
    reg[7:0]    tog_index;
    wire        busy = (tog_index!=0);
    always @ (posedge clk) begin
        if (~rstn) begin
            tog_index <= 0;
        end else if (~busy) begin
            if (trig) begin
                tog_index <= 16-(1<<wid);
            end
        end else begin
            if (tog_index) begin
                tog_index <= tog_index-(1<<wid);
            end
        end
    end

    always @ (posedge clk) begin
        if (~rstn) begin
            done <= 0;
        end else if (tog_index==(1<<wid)) begin
            done <= 1;
        end else begin
            done <= 0;
        end
    end

    // data interaction
    generate if (`SERNOR_MODE)
        assign spi_sclk = (busy | done) ? ~tog_index[wid] : 1'b1;
    else
        assign spi_sclk = (busy | done) ? ~tog_index[wid] : 1'b0;
    endgenerate
    
    assign spi_dir = (busy | done) ? (dir ? `IOR_DIR_OUT : `IOR_DIR_IN) : `SERNOR_IDLE_DIR;

    wire[14:0] dout_extended = {7'd0, dout};
    assign spi_dout = dout_extended[tog_index[7:1]+:8];

    reg[14:0] din_extended;
    always @ (posedge clk) begin
        if (busy & ~spi_sclk) begin
            din_extended[tog_index[7:1]+:8] <=
        end
    end

endmodule
