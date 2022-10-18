`include "femto.vh"

module ibusif (
    input wire clk,
    input wire rstn,

    // processor interface
    input wire          jmp_req,
    input wire[31:0]    jmp_addr,
    input wire          instr_req, // typically vld of pipeline stage 0
    input wire          instr_size, // 1 - requesting 16-bit data, 0 - requesting 32-bit data

    output wire[31:0]   instr,

    // bus interface
    output wire[31:0]   i_haddr,
    output wire         i_hprot, // data/instruction access indicator
    output wire[1:0]    i_hsize,
    output wire[31:0]   i_hwdata,
    output wire         i_htrans, // indicate whether the transfer is valid, bit 1 of AHB HTRANS
    input wire[31:0]    i_hrdata,
    input wire          i_hresp,
    input wire          i_hready
);

    wire ibus_busy;
    wire ibus_req;
    wire ibus_resp;
    wire[1:0] ibus_resp_size;
    wire[31:0] ibus_req_addr;
    wire[31:0] ibus_resp_data;
    wire[1:0] ibus_req_size;
    
    wire[1:0] ifq_vacant_16bit_entry;
    wire[1:0] ifq_filled_16bit_entry;
    
    begin: GEN_bus_busy
        wire bus_req_asserted;
        dff bus_req_asserted_dff (
            .clk(clk            ),
            .rstn(rstn          ),
            .set(i_htrans),
            .vld(i_hready),
            .setv(1'b1),
            .in (1'b0           ),
            .out(bus_req_asserted)
        );
        assign ibus_busy = bus_req_asserted & ~i_hready;
    end


    begin: GEN_ibus_resp
        wire ibus_prev_req_vld; // not cancelled by jmp
        dff ibus_prev_req_vld_dff (
            .clk(clk            ),
            .rstn(rstn          ),
            .set(jmp_req & ~ibus_req),
            .vld(ibus_req),
            .setv(1'b0),
            .in (1'b1           ),
            .out(ibus_prev_req_vld)
        );
        assign ibus_resp = i_hready & ibus_prev_req_vld & ~jmp_req;

        dff #(
            .WIDTH(2)
        ) ibus_prev_req_hsize_dff (
            .clk(clk            ),
            .rstn(1'b1          ), // no need to reset
            .set(1'b0),
            .vld(ibus_req),
            .setv(1'b0),
            .in (ibus_req_size[0]     ),
            .out(ibus_resp_size)
        );
        
        assign ibus_resp_data = i_hrdata;
    end

    begin: GEN_ibus_req_addr
        wire[31:0] next_njmp_addr; // non-jmp increasing
        wire[31:0] next_jmp_addr;
        wire[31:0] addr; // not called "pc" because addr can be in the middle of an instruction
        dff #(
            .WIDTH(32),
            .INITV(`RESET_PC),
        ) ibus_req_addr_dff (
            .clk (clk                     ),
            .rstn(rstn                    ),
            .set (jmp_req),
            .setv(next_jmp_addr),
            .vld (ibus_req),
            .in  (next_njmp_addr        ),
            .out (addr          )
        );
        assign next_njmp_addr = {ibus_addr[31:2]+30'd1, 2'b00};
        assign next_jmp_addr = ibus_req ? {jmp_addr[31:2]+30'd1, 2'b00} : jmp_addr;

        assign ibus_req_addr = jmp_req ? jmp_addr : addr;
    end

    begin: GEN_ibus_req
        // if ibus_req_addr is 16-bit aligned or only 16-bit space is left, 16-bit access is made
        assign ibus_req_size = (ibus_req_addr[1] || (ifq_vacant_16bit_entry==2'd1)) ? 2'b01 /* 16-bit access */ : 2'b10 /* 32-bit access */;
        assign ibus_req = (jmp || ifq_vacant_16bit_entry) && ~ibus_busy;
    end

    instr_fetch_queue ifq(
        .clk             (clk ),
        .rstn            (rstn),
        .clr             (jmp_req ),

        .in_req            (ibus_resp        ),
        .in_16bit          (ibus_resp_size[0]), // hsize[0]==1'b1 indicates 16-bit rdata
        .in                (ibus_resp_data           ),
        .vacant_16bit_entry(ifq_vacant_16bit_entry),

        .out_req           (instr_req                ),
        .out_16bit         (instr_size                ),
        .out               (instr             ),
        .filled_16bit_entry(ifq_filled_16bit_entry)
    );
endmodule
