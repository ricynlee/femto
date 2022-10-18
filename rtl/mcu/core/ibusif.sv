`include "femto.vh"

module ibusif (
    input wire clk,
    input wire rstn,

    // processor interface
    input wire          jmp_req,
    input wire[31:0]    jmp_addr,
    input wire          instr_req,
    output wire[31:0]   instr,
    output wire[31:0]   instr_pc,
    output wire         instr_c,

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
    wire ibus_resp_hsize; // bit 0 only
    wire[31:0] ibus_req_addr;
    
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

        dff ibus_prev_req_hsize_dff ( // only bit 0 covered as 16/32 bit indicator
            .clk(clk            ),
            .rstn(1'b1          ), // no need to reset
            .set(1'b0),
            .vld(ibus_req),
            .setv(1'b0),
            .in (i_hsize[0]     ),
            .out(ibus_resp_hsize)
        );
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
        
    end
        instr_fetch_queue ifq(
            .clk             (clk ),
            .rstn            (rstn),
            .clr             (jmp_req ),

            .in_req            (ibus_resp        ),
            .in_16bit          (ibus_resp_hsize), // hsize==1'b1 indicates 16-bit rdata
            .in                (i_hrdata           ),
            .vacant_16bit_entry(    ),

            .out_req           (s0_vld                ),
            .out_16bit         (s0_cif                ),
            .out               (if_ir_raw             ),
            .filled_16bit_entry(  )
        );


endmodule
