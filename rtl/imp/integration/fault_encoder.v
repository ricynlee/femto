`include "timescale.vh"
`include "femto.vh"

module fault_encoder (
    input wire clk,
    input wire rstn,
    
    input wire core_fault,
    input wire ibus_fault,
    input wire dbus_fault,
    input wire pbus_fault,
    input wire rom_i_fault,
    input wire rom_d_fault,
    input wire tcm_i_fault,
    input wire tcm_d_fault,
    input wire sram_i_fault,
    input wire sram_d_fault,
    input wire nor_i_fault,
    input wire nor_d_fault,
    input wire qspi_fault, // d
    input wire eic_fault, // d
    input wire uart_fault, // d
    input wire gpio_fault, // d
    input wire tmr_fault, // d
    input wire rst_fault, // d

    input wire[`XLEN-1:0] ibus_addr,
    input wire[`XLEN-1:0] dbus_addr,
    input wire[`XLEN-1:0] pbus_addr,
    input wire[`XLEN-1:0] core_fault_pc,

    output wire            halt, // halt bus activity upon fault

    output wire            fault,
    output wire[7:0]       fault_cause,
    output wire[`XLEN-1:0] fault_addr
);
    wire fault_occurred = { core_fault, ibus_fault, dbus_fault, pbus_fault, rom_i_fault,
        rom_d_fault, tcm_i_fault, tcm_d_fault, sram_i_fault, sram_d_fault, nor_i_fault,
        nor_d_fault, qspi_fault, eic_fault, uart_fault, gpio_fault, tmr_fault, rst_fault };
    wire[7:0] fault_cause_comb =
        (core_fault) ?
            `RST_FAULT_CORE :
        (ibus_fault) ?
            `RST_FAULT_IBUS :
        (| {dbus_fault, pbus_fault}) ?
            `RST_FAULT_DBUS :
        (| {rom_i_fault, tcm_i_fault, sram_i_fault, nor_i_fault}) ?
            `RST_FAULT_IPER :
        /* otherwise, even if no fault at all */
            `RST_FAULT_DPER ;
    wire[`XLEN-1:0] fault_addr_comb =
        (core_fault) ?
            core_fault_pc :
        (ibus_fault) ?
            ibus_addr :
        (dbus_fault) ?
            dbus_addr :
        (pbus_fault) ?
            pbus_addr :
        (| {rom_i_fault, tcm_i_fault, sram_i_fault, nor_i_fault}) ?
            ibus_addr :
        (| {eic_fault, uart_fault, gpio_fault, tmr_fault, rst_fault}) ?
            pbus_addr :
        /* otherwise, even if no fault at all */
            dbus_addr ;

    dff #(
        .VALID("sync"   ),
        .RESET("sync"   ),
        .WIDTH(1+8+`XLEN)
    ) fault_dff (
        .clk (clk ),
        .rstn(rstn),

        .vld (fault_occurred                           ),
        .in  ({1'b1, fault_cause_comb, fault_addr_comb}),
        .out ({fault, fault_cause, fault_addr}         )
    );

    assign halt = fault;
endmodule
