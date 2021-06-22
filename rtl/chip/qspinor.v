`include "femto.vh"
`include "sim/timescale.vh"

module qspinor_io (
    input wire  clk,
    input wire  rstn,

    input wire          trig,
    output reg          done,
    input wire[7:0]     dout, // to nor, externally guaranteed constant before next done
    output wire[7:0]    din, // from nor

    input wire          dir, // externally guaranteed constant before next done
    input wire[1:0]     wid, // <3'b11, externally guaranteed constant before next done

    output reg          spi_sclk,
    output wire         spi_dir,
    input wire[3:0]     spi_din, // from nor
    output wire[3:0]    spi_dout // to nor
);

    // state control
    reg[7:0]    toggle_index;
    always @ (posedge clk) begin
        if (~rstn) begin
            toggle_index <= 0;
        end else if (toggle_index==0) begin
            if (trig) begin
                toggle_index <= (16>>wid)-1;
            end
        end else begin
            toggle_index <= toggle_index-1;
        end
    end

    always @ (posedge clk) begin
        if (~rstn) begin
            done <= 0;
        end else if (toggle_index==1) begin
            done <= 1;
        end else begin
            done <= 0;
        end
    end

    // data interaction
    always @ (posedge clk) begin
        if (~rstn) begin
            spi_sclk <= (`SERNOR_MODE) ? 1'b1 : 1'b0;
        end else if (toggle_index==0) begin
            if (trig | !(`SERNOR_MODE))
                spi_sclk <= 1'b0;
        end else begin
            spi_sclk <= ~spi_sclk;
        end
    end

    assign spi_dir = (toggle_index || done) ? (dir ? `IOR_DIR_OUT : `IOR_DIR_IN) : `SERNOR_IDLE_DIR;

    wire[10:0] dout_extended = {4'd0, dout};
    assign spi_dout = dout_extended[(toggle_index[7:1]<<wid)+:4];

    reg[0:10] din_extended;
    always @ (posedge clk) begin
        if (toggle_index && ~spi_sclk) begin
            din_extended[(toggle_index[7:1]<<wid)+:4] <= spi_din;
        end
    end
    generate
        for(genvar i=0; i<8; i=i+1) begin assign din[i] = din_extended[i+3]; end
    endgenerate

endmodule
