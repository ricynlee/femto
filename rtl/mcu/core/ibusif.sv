`include "femto.vh"

module ibusif (
    input wire clk,
    input wire rstn,

    // processor interface
    input wire        jmp_req,
    input wire [31:0] jmp_addr, // pipeline's id stage shall ensure jmp_addr is 2-aligned

    input wire       instr_fetch,      // typically vld of pipeline stage 0
    input wire [1:0] instr_fetch_size, // bit 0: 1 - requesting 16-bit data, 0 - requesting 32-bit data

    output wire [ 1:0] instr_vld_size,  // 2'b00 - not vld, 2'b01 - 16 bits vld, 2'b1x - 32 bits vld
    output wire [31:0] instr,           // not actual instruction 'cause it can be a partial (16/32) one
    output wire        instr_has_fault, // instr's corresponding bus access triggered bus fault

    // bus interface (ahblite-like)
    output wire [31:0] haddr,
    output wire        hprot,   // data/instruction access indicator
    output wire [ 1:0] hsize,
    output wire        hwrite,
    output wire [31:0] hwdata,
    output wire        htrans,  // indicate whether the transfer is valid, bit 1 of AHB HTRANS
    input  wire [31:0] hrdata,
    input  wire        hresp,
    input  wire        hready
);

    wire       trans_busy;  // trans req would be ignored
    wire       trans_resp;
    wire [1:0] trans_resp_size;

    generate
        if (0) begin : GEN_trans_busy_init_forced
            wire init_force_busy;
            dff #(
                .INITV(1'b1)
            ) init_force_busy_dff (
                .clk (clk),
                .rstn(rstn),
                .set (1'b0),
                .setv(1'b0),
                .vld (1'b1),
                .in  (1'b0),
                .out (init_force_busy)
            );

            assign trans_busy = ~hready | init_force_busy;
        end else begin : GEN_trans_busy
            assign trans_busy = ~hready;
        end
    endgenerate

    generate
        if (1) begin : GEN_trans_resp
            wire prev_trans_req_vld;  // not cancelled by jmp
            dff prev_trans_req_vld_dff (
                .clk (clk),
                .rstn(rstn),
                .set (htrans),
                .setv(1'b1),
                .vld (jmp_req | hready),
                .in  (1'b0),
                .out (prev_trans_req_vld)
            );
            assign trans_resp = hready & prev_trans_req_vld & ~jmp_req;

            dff #(
                .WIDTH(2)
            ) trans_resp_size_dff (
                .clk (clk),
                .rstn(1'b1),            // no need to reset
                .set (1'b0),
                .setv(1'b0),
                .vld (htrans),
                .in  (hsize),
                .out (trans_resp_size)
            );
        end
    endgenerate

    generate
        if (1) begin : GEN_trans_addr
            wire [31:0] next_addr;  // non-jmp prediction
            wire [31:0] next_jmp_addr;  // jmp prediction
            wire [31:0] pred_addr;  // predicted addr
            dff #(
                .WIDTH(32),
                .INITV(`RESET_PC)
            ) ibus_req_addr_dff (
                .clk (clk),
                .rstn(rstn),
                .set (jmp_req),
                .setv(next_jmp_addr),
                .vld (htrans),
                .in  (next_addr),
                .out (pred_addr)
            );
            assign next_addr     = {pred_addr[31:2] + 30'd1, 2'b00};  // always move to 4-aligned addr
            assign next_jmp_addr = htrans ? {jmp_addr[31:2] + 30'd1, 2'b00} : {jmp_addr[31:1], 1'b0};  // always move to 4-aligned addr

            assign haddr         = jmp_req ? {jmp_addr[31:1], 1'b0} : pred_addr;  // not called "pc" because addr can be in the middle of an instruction
        end
    endgenerate

    generate
        if (1) begin : GEN_trans_req
            wire [1:0] ifq_vacant_16bit_entry;
            wire [1:0] ifq_filled_16bit_entry;
            wire [1:0] ifq_has_bus_fault;
            assign hsize  = haddr[1] ? 2'b01  /* force 16-bit access */ : 2'b10;
            assign htrans = ~trans_busy && (jmp_req || (!ifq_has_bus_fault && ifq_vacant_16bit_entry));
            instr_fetch_queue ifq (
                .clk (clk),
                .rstn(rstn),
                .clr (jmp_req),

                .in_req            (trans_resp),
                .in_16bit          (trans_resp_size[0]),     // hsize[0]==1'b1 indicates 16-bit rdata
                .in                (hrdata),
                .vacant_16bit_entry(ifq_vacant_16bit_entry),

                .out_req           (instr_fetch),
                .out_16bit         (instr_fetch_size[0]),
                .out               (instr),
                .filled_16bit_entry(ifq_filled_16bit_entry)
            );

            dff #(
                .WIDTH(2)
            ) ibus_fault_status_dff (
                .clk (clk),
                .rstn(rstn),
                .set (jmp_req),           // clear fault
                .setv(2'b00),
                .vld (hresp),             // thanks to ahblite spec, hresp comes 1 hclk earlier than hready
                .in  (trans_resp_size),
                .out (ifq_has_bus_fault)
            );

            assign instr_has_fault = (ifq_filled_16bit_entry <= ifq_has_bus_fault);
            assign instr_vld_size  = ifq_filled_16bit_entry;
        end
    endgenerate

    assign hprot  = 1'b0;  // always set "opcode fetch"
    assign hwdata = 32'dx;  // for simulation only
    assign hwrite = 1'b0;  // always set "read"
endmodule
