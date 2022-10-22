`timescale 1ns / 1ps

module tb_ibusif;

    logic clk = 0;
    logic rstn = 0;

    initial
        forever begin
            #20.833 clk = ~clk;
        end

    initial begin
        #200 rstn = 1;
    end

    /* input  */logic        instr_fetch;  // typically vld of pipeline stage 0
    /* input  */logic [ 1:0] instr_fetch_size;  // bit 0: 1 - requesting 16-bit data, 0 - requesting 32-bit data
    /* output */logic [ 1:0] instr_vld_size;  // 2'b00 - not vld, 2'b01 - 16-bit instr vld, 2'b1x - 32-bit instr vld
    /* output */logic [31:0] instr;
    /* output */logic        instr_has_fault;  // instr contains bus fault
    /* output */logic [31:0] haddr;
    /* output */logic        hprot;  // data/instruction access indicator
    /* output */logic [ 1:0] hsize;
    /* output */logic [31:0] hwdata;
    /* output */logic        htrans;  // indicate whether the transfer is valid, bit 1 of AHB HTRANS
    /* output */logic        hwrite;
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

    logic jmp;
    initial begin
        jmp = 0;
        #800;
        @(posedge clk) jmp <= 1;
        @(posedge clk) jmp <= 0;
        #2us;
        @(posedge clk) jmp <= 1;
        @(posedge clk) jmp <= 0;
    end

    logic instr_fetch_scheme;
    initial begin
        instr_fetch_scheme = 0;
        @(posedge jmp);
        @(posedge jmp);
        #1ns;
        instr_fetch_scheme = 1;
    end

    assign instr_fetch      = instr_fetch_scheme ? |instr_vld_size : (instr_vld_size == 2'b10);
    assign instr_fetch_size = instr_fetch_scheme ? 2'b01 : 2'b10;

    ibusif ibusif (
        .clk (clk),
        .rstn(rstn),

        // processor interface
        .jmp_req (jmp),
        .jmp_addr('h00000002),

        .instr_fetch     (instr_fetch),      // typically vld of pipeline stage 0
        .instr_fetch_size(instr_fetch_size), // bit 0: 1 - requesting 16-bit data, 0 - requesting 32-bit data

        .instr_vld_size      (instr_vld_size),       // 2'b00 - not vld, 2'b01 - 16-bit instr vld, 2'b1x - 32-bit instr vld
        .instr               (instr),
        .instr_has_fault(instr_has_fault), // instr contains bus fault

        .haddr (haddr),
        .hprot (hprot),   // data/instruction access indicator
        .hsize (hsize),
        .hwrite(hwrite),
        .hwdata(hwdata),
        .htrans(htrans),  // indicate whether the transfer is valid, bit 1 of AHB HTRANS
        .hrdata(hrdata),
        .hresp (hresp),
        .hready(hready)
    );

endmodule
