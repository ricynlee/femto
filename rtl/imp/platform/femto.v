`include "timescale.vh"
`include "femto.vh"

// for VLA dbg: (*keep_hierarchy="true"*)
module femto (
    input wire  clk ,
    input wire  rstn,

    inout wire[`GPIO_WIDTH-1:0] gpio,

    input wire  uart_rx,
    output wire uart_tx,

    output wire       sram_ce_bar,
    output wire       sram_oe_bar,
    output wire       sram_we_bar,
    inout wire[7:0]   sram_data  ,
    output wire[18:0] sram_addr  ,

    output wire     qspi_sck,
    output wire     qspi_csb,
    inout wire[3:0] qspi_sio
);
    /******************************************************************************************************************************************************************/
    // fault signals
    wire            fault;
    wire[`XLEN-1:0] fault_addr;
    wire[7:0]       fault_cause;

    // reset signals
    wire[`RST_WIDTH-1:0]    rstn_vec; // rstn vector
    wire                    misc_rstn,
                            core_rstn,
                            rom_rstn,
                            tcm_rstn,
                            sram_rstn,
                            qspinor_rstn,
                            gpio_rstn,
                            uart_rstn,
                            tmr_rstn,
                            eic_rstn;

    // io signals
    wire[`GPIO_WIDTH-1:0]   ior_gpio_dir;
    wire[`GPIO_WIDTH-1:0]   ior_gpio_i  ;
    wire[`GPIO_WIDTH-1:0]   ior_gpio_o  ;

    wire                    ior_uart_rx;
    wire                    ior_uart_tx;

    wire                    ior_sram_ce_bar  ;
    wire                    ior_sram_oe_bar  ;
    wire                    ior_sram_we_bar  ;
    wire                    ior_sram_data_dir;
    wire[7:0]               ior_sram_data_in ;
    wire[7:0]               ior_sram_data_out;
    wire[18:0]              ior_sram_addr    ;

    wire                    ior_qspi_csb ;
    wire                    ior_qspi_sclk;
    wire[3:0]               ior_qspi_dir ;
    wire[3:0]               ior_qspi_mosi;
    wire[3:0]               ior_qspi_miso;

    // bus fabric signals
    wire[`XLEN-1:0]

    // interrupt signals
    wire                       ext_int_trigger, ext_int_handled; // eic-core
    wire[`EXT_INT_SRC_NUM-1:0] ext_int_src_vect; // periph-eic

    /******************************************************************************************************************************************************************/
    // fabric
    core core (
        .clk (clk      ),
        .rstn(core_rstn),

        .core_fault   (core_fault   ),
        .core_fault_pc(core_fault_pc),

        .ext_int_trigger(ext_int_trigger),
        .ext_int_handled(ext_int_handled),

        .ibus_addr (ibus_addr ),
        .ibus_w_rb (ibus_w_rb ),
        .ibus_acc  (ibus_acc  ),
        .ibus_rdata(ibus_rdata),
        .ibus_wdata(ibus_wdata),
        .ibus_req  (ibus_req  ),
        .ibus_resp (ibus_resp ),

        .dbus_addr (dbus_addr ),
        .dbus_w_rb (dbus_w_rb ),
        .dbus_acc  (dbus_acc  ),
        .dbus_rdata(dbus_rdata),
        .dbus_wdata(dbus_wdata),
        .dbus_req  (dbus_req  ),
        .dbus_resp (dbus_resp )
    );

    // gpio

    // uart

    // timer


    // reset

    /******************************************************************************************************************************************************************/
    // ioring
    ioring ioring (
        .gpio_dir(ior_gpio_dir),
        .gpio_i  (ior_gpio_i  ),
        .gpio_o  (ior_gpio_o  ),

        .uart_rx(ior_uart_rx),
        .uart_tx(ior_uart_tx),

        .sram_ce_bar  (ior_sram_ce_bar  ),
        .sram_oe_bar  (ior_sram_oe_bar  ),
        .sram_we_bar  (ior_sram_we_bar  ),
        .sram_data_dir(ior_sram_data_dir),
        .sram_data_in (ior_sram_data_in ),
        .sram_data_out(ior_sram_data_out),
        .sram_addr    (ior_sram_addr    ),

        .qspi_csb (ior_qspi_csb ),
        .qspi_sclk(ior_qspi_sclk),
        .qspi_dir (ior_qspi_dir ),
        .qspi_mosi(ior_qspi_mosi),
        .qspi_miso(ior_qspi_miso),

        .pad_gpio(gpio),

        .pad_uart_rx(uart_rx),
        .pad_uart_tx(uart_tx),

        .pad_sram_ce_bar(sram_ce_bar),
        .pad_sram_oe_bar(sram_oe_bar),
        .pad_sram_we_bar(sram_we_bar),
        .pad_sram_data  (sram_data  ),
        .pad_sram_addr  (sram_addr  ),

        .pad_qspi_sck(qspi_sck),
        .pad_qspi_csb(qspi_csb),
        .pad_qspi_sio(qspi_sio)
    );

    /******************************************************************************************************************************************************************/
    begin: FAULT_ARBITRATION
        wire farb_fault = |{core_fault, bus_i_fault, bus_d_fault, rom_i_fault, rom_d_fault, tcm_i_fault, tcm_d_fault, sram_i_fault, sram_d_fault, nor_i_fault, nor_d_fault, gpio_fault, uart_fault, qspinor_fault, tmr_fault, eic_fault, rst_fault},
             farb_ibus_fault = |{bus_i_fault, rom_i_fault, tcm_i_fault, sram_i_fault, nor_i_fault};
        dff #(
            .VALID("sync"   ),
            .RESET("sync"   ),
            .WIDTH(1+8+`XLEN)
        ) fault_dff (
            .clk (clk       ),
            .rstn(misc_rstn ),
            .vld (farb_fault),
            .in ({
                1'b1,
                (core_fault ? `RST_FAULT_CORE : farb_ibus_fault ? `RST_FAULT_IBUS : `RST_FAULT_DBUS),
                (core_fault ? core_fault_pc : farb_ibus_fault ? ibus_addr : dbus_addr)
            }),
            .out({fault, fault_cause, fault_addr})
        );
    end

    /******************************************************************************************************************************************************************/
    // reset
    assign  misc_rstn    = rstn_vec[`RST_MISC   ];
    assign  core_rstn    = rstn_vec[`RST_CORE   ];
    assign  rom_rstn     = rstn_vec[`RST_ROM    ];
    assign  tcm_rstn     = rstn_vec[`RST_TCM    ];
    assign  sram_rstn    = rstn_vec[`RST_SRAM   ];
    assign  qspinor_rstn = rstn_vec[`RST_QSPINOR];
    assign  gpio_rstn    = rstn_vec[`RST_GPIO   ];
    assign  uart_rstn    = rstn_vec[`RST_UART   ];
    assign  tmr_rstn     = rstn_vec[`RST_TMR    ];
    assign  eic_rstn     = rstn_vec[`RST_EIC    ];

endmodule
