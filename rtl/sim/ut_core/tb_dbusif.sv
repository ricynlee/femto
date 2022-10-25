`timescale 1ns / 1ps

module tb_dbusif;

    logic clk = 0;
    logic rstn = 0;

    initial
        forever begin
            #20.833 clk = ~clk;
        end

    initial begin
        #200 rstn = 1;
    end

    /* input  */logic       acc_req = 0;
    /* input  */logic       acc_w_rb = 0;
    /* input  */logic[1:0]  acc_size = 0;
    /* input  */logic[31:0] acc_addr = 0;
    /* input  */logic[31:0] acc_wdata = 0;
    /* output */logic       data_vld; // r/w access done
    /* output */logic[31:0] data;
    /* output */logic       data_has_fault; // resp's correspoding acess

    /* output */logic        hwrite;
    /* output */logic [31:0] haddr;
    /* output */logic        hprot;  // data/instruction access indicator
    /* output */logic [ 1:0] hsize;
    /* output */logic [31:0] hwdata;
    /* output */logic        htrans;  // indicate whether the transfer is valid, bit 1 of AHB HTRANS
    /* input  */logic [31:0] hrdata;
    /* input  */logic        hresp;
    /* input  */logic        hready;

    always @(posedge clk) begin
        if (~rstn) begin
            hresp  <= 0;
            hready <= 1'b1;
        end else begin
            if (htrans) begin
                hrdata <= {haddr[7:0] + 8'd3, haddr[7:0] + 8'd2, haddr[7:0] + 8'd1, haddr[7:0] + 8'd0};
                hready <= (haddr != 32'h00000040);
                hresp  <= (haddr == 32'h00000040);
            end else begin
                hready <= 1'b1;
                if (hready) hresp <= 0;
            end
        end
    end

    initial begin
        wait(rstn==1);
        @(posedge clk) begin
            acc_req   = 1;
            acc_w_rb  = 0;
            acc_size  = 0;
            acc_addr  = 0;
        end
        @(posedge clk) begin
            acc_req   = 0;
            acc_wdata = 0;
        end
        wait(data_vld);
    end

    dbusif dbusif (
        .clk           (clk           ),
        .rstn          (rstn          ),
        .acc_req       (acc_req       ),
        .acc_w_rb      (acc_w_rb      ),
        .acc_size      (acc_size      ),
        .acc_addr      (acc_addr      ),
        .acc_wdata     (acc_wdata     ),
        .data_vld      (data_vld      ),
        .data          (data          ),
        .data_has_fault(data_has_fault),
        .haddr         (haddr         ),
        .hprot         (hprot         ),
        .hsize         (hsize         ),
        .hwrite        (hwrite        ),
        .hwdata        (hwdata        ),
        .htrans        (htrans        ),
        .hrdata        (hrdata        ),
        .hresp         (hresp         ),
        .hready        (hready        )
    );

endmodule
