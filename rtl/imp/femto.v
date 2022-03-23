`include "timescale.vh"
`include "femto.vh"

(*keep_hierarchy="true"*)
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
    // fault signals
    wire    core_fault,
            bus_fault,
            rom_fault,
            tcm_fault,
            sram_fault,
            nor_fault,
            gpio_fault,
            uart_fault,
            qspinor_fault,
            tmr_fault,
            rst_fault;

    wire    fault;

    // reset signals
    wire[`RST_WIDTH-1:0]    rstn_vec; // rstn vector
    wire                    core_rstn,
                            rom_rstn,
                            tcm_rstn,
                            sram_rstn,
                            nor_rstn,
                            gpio_rstn,
                            uart_rstn,
                            qspinor_rstn,
                            tmr_rstn;

    // instruction bus signals
    wire[`XLEN-1:0]                 ibus_addr;
    wire                            ibus_w_rb;
    wire[$clog2(`BUS_ACC_CNT)-1:0]  ibus_acc;
    wire[`BUS_WIDTH-1:0]            ibus_rdata, ibus_wdata;
    wire                            ibus_req, ibus_resp;

    wire    ibus_rom_req,  ibus_rom_resp,
            ibus_tcm_req,  ibus_tcm_resp,
            ibus_sram_req, ibus_sram_resp,
            ibus_nor_req,  ibus_nor_resp;

    wire[`BUS_WIDTH-1:0]    ibus_rom_rdata ,
                            ibus_tcm_rdata ,
                            ibus_sram_rdata,
                            ibus_nor_rdata ;

    // data bus signals
    wire[`XLEN-1:0]                 dbus_addr;
    wire                            dbus_w_rb;
    wire[$clog2(`BUS_ACC_CNT)-1:0]  dbus_acc;
    wire[`BUS_WIDTH-1:0]            dbus_rdata, dbus_wdata;
    wire                            dbus_req, dbus_resp;

    wire    dbus_rom_req,     dbus_rom_resp,
            dbus_tcm_req,     dbus_tcm_resp,
            dbus_sram_req,    dbus_sram_resp,
            dbus_nor_req,     dbus_nor_resp,
            dbus_gpio_req,    dbus_gpio_resp,
            dbus_uart_req,    dbus_uart_resp,
            dbus_qspinor_req, dbus_qspinor_resp,
            dbus_tmr_req,     dbus_tmr_resp,
            dbus_rst_req,     dbus_rst_resp;

    wire[`BUS_WIDTH-1:0]    dbus_rom_rdata    ,
                            dbus_tcm_rdata    ,
                            dbus_sram_rdata   ,
                            dbus_nor_rdata    ,
                            dbus_gpio_rdata   ,
                            dbus_uart_rdata   ,
                            dbus_qspinor_rdata,
                            dbus_tmr_rdata    ,
                            dbus_eic_rdata    ,
                            dbus_rst_rdata    ;

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

    /******************************************************************************************************************************************************************/
    begin: FAULT_GEN
        dff #(
            .VALID("sync")
        ) req_acc_dff (
            .clk(clk                ),
            .vld(ibus_req | dbus_req),
            .in (|{core_fault, bus_fault, rom_fault, tcm_fault, sram_fault, nor_fault, gpio_fault, uart_fault, qspinor_fault, tmr_fault, rst_fault}),
            .out(fault              )
        );
    end

    /******************************************************************************************************************************************************************/
    begin: RESET_GEN
        assign  core_rstn    = rstn_vec[`RST_CORE];
        assign  rom_rstn     = rstn_vec[`RST_ROM ];
        assign  tcm_rstn     = rstn_vec[`RST_TCM ];
        assign  sram_rstn    = rstn_vec[`RST_SRAM];
        assign  nor_rstn     = rstn_vec[`RST_NOR ];
        assign  gpio_rstn    = rstn_vec[`RST_GPIO];
        assign  uart_rstn    = rstn_vec[`RST_UART];
        assign  qspinor_rstn = rstn_vec[`RST_QSPI];
        assign  tmr_rstn     = rstn_vec[`RST_TMR ];
    end

    /******************************************************************************************************************************************************************/
    begin: BUS_REQ_MUX_RESP_DEMUX
        wire    ibus_rom_req_sel  = (ibus_addr & `ROM_SEL_MASK)==`ROM_ADDR;
        wire    ibus_tcm_req_sel  = (ibus_addr & `TCM_SEL_MASK)==`TCM_ADDR;
        wire    ibus_sram_req_sel = (ibus_addr & `SRAM_SEL_MASK)==`SRAM_ADDR;
        wire    ibus_nor_req_sel  = (ibus_addr & `NOR_SEL_MASK)==`NOR_ADDR;

        wire    ibus_rom_resp_sel,
                ibus_tcm_resp_sel,
                ibus_sram_resp_sel,
                ibus_nor_resp_sel;
        dff # (
            .WIDTH(4     ),
            .VALID("sync")
        ) ibus_resp_sel_dff (
            .clk (clk     ),
            .vld (ibus_req),
            .in  ({ibus_rom_req_sel, ibus_tcm_req_sel, ibus_sram_req_sel, ibus_nor_req_sel}    ),
            .out ({ibus_rom_resp_sel, ibus_tcm_resp_sel, ibus_sram_resp_sel, ibus_nor_resp_sel})
        );

        wire    dbus_rom_req_sel     = (dbus_addr & `ROM_SEL_MASK)==`ROM_ADDR;
        wire    dbus_tcm_req_sel     = (dbus_addr & `TCM_SEL_MASK)==`TCM_ADDR;
        wire    dbus_sram_req_sel    = (dbus_addr & `SRAM_SEL_MASK)==`SRAM_ADDR;
        wire    dbus_nor_req_sel     = (dbus_addr & `NOR_SEL_MASK)==`NOR_ADDR;
        wire    dbus_gpio_req_sel    = (dbus_addr & `GPIO_SEL_MASK)==`GPIO_ADDR;
        wire    dbus_uart_req_sel    = (dbus_addr & `UART_SEL_MASK)==`UART_ADDR;
        wire    dbus_qspinor_req_sel = (dbus_addr & `QSPINOR_SEL_MASK)==`QSPINOR_ADDR;
        wire    dbus_tmr_req_sel     = (dbus_addr & `TMR_SEL_MASK)==`TMR_ADDR;
        wire    dbus_eic_req_sel     = (dbus_addr & `EIC_SEL_MASK)==`EIC_ADDR;
        wire    dbus_rst_req_sel     = (dbus_addr & `RST_SEL_MASK)==`RST_ADDR;

        wire    dbus_rom_resp_sel,
                dbus_tcm_resp_sel,
                dbus_sram_resp_sel,
                dbus_nor_resp_sel,
                dbus_gpio_resp_sel,
                dbus_uart_resp_sel,
                dbus_qspinor_resp_sel,
                dbus_tmr_resp_sel,
                dbus_eic_resp_sel,
                dbus_rst_resp_sel;
        dff # (
            .WIDTH(10    ),
            .VALID("sync")
        ) dbus_resp_sel_dff (
            .clk (clk     ),
            .vld (dbus_req),
            .in  ({dbus_rom_req_sel, dbus_tcm_req_sel, dbus_sram_req_sel, dbus_nor_req_sel, dbus_gpio_req_sel, dbus_uart_req_sel, dbus_qspinor_req_sel, dbus_tmr_req_sel, dbus_eic_req_sel, dbus_rst_req_sel}         ),
            .out ({dbus_rom_resp_sel, dbus_tcm_resp_sel, dbus_sram_resp_sel, dbus_nor_resp_sel, dbus_gpio_resp_sel, dbus_uart_resp_sel, dbus_qspinor_resp_sel, dbus_tmr_resp_sel, dbus_eic_resp_sel, dbus_rst_resp_sel})
        );

        // MUX
        assign  ibus_rom_req  = ibus_req & ibus_rom_req_sel ;
        assign  ibus_tcm_req  = ibus_req & ibus_tcm_req_sel ;
        assign  ibus_sram_req = ibus_req & ibus_sram_req_sel;
        assign  ibus_nor_req  = ibus_req & ibus_nor_req_sel ;

        assign  dbus_rom_req     = dbus_req & dbus_rom_req_sel    ;
        assign  dbus_tcm_req     = dbus_req & dbus_tcm_req_sel    ;
        assign  dbus_sram_req    = dbus_req & dbus_sram_req_sel   ;
        assign  dbus_nor_req     = dbus_req & dbus_nor_req_sel    ;
        assign  dbus_gpio_req    = dbus_req & dbus_gpio_req_sel   ;
        assign  dbus_uart_req    = dbus_req & dbus_uart_req_sel   ;
        assign  dbus_qspinor_req = dbus_req & dbus_qspinor_req_sel;
        assign  dbus_tmr_req     = dbus_req & dbus_tmr_req_sel    ;
        assign  dbus_eic_req     = dbus_req & dbus_eic_req_sel    ;
        assign  dbus_rst_req     = dbus_req & dbus_rst_req_sel    ;

        // DEMUX
        assign  ibus_resp = fault ? 1'b0 : |{ibus_rom_resp, ibus_tcm_resp, ibus_sram_resp, ibus_nor_resp};
        assign  ibus_rdata = ibus_rom_resp_sel  ? ibus_rom_rdata  :
                             ibus_tcm_resp_sel  ? ibus_tcm_rdata  :
                             ibus_sram_resp_sel ? ibus_sram_rdata :
                             ibus_nor_resp_sel  ? ibus_nor_rdata  : {`BUS_WIDTH{1'bx}};

        assign  dbus_resp = fault ? 1'b0 : |{dbus_rom_resp, dbus_tcm_resp, dbus_sram_resp, dbus_nor_resp, dbus_gpio_resp, dbus_uart_resp, dbus_qspinor_resp, dbus_tmr_resp, dbus_rst_resp};
        assign  dbus_rdata = dbus_rom_resp_sel     ? dbus_rom_rdata     :
                             dbus_tcm_resp_sel     ? dbus_tcm_rdata     :
                             dbus_sram_resp_sel    ? dbus_sram_rdata    :
                             dbus_nor_resp_sel     ? dbus_nor_rdata     :
                             dbus_gpio_resp_sel    ? dbus_gpio_rdata    :
                             dbus_uart_resp_sel    ? dbus_uart_rdata    :
                             dbus_qspinor_resp_sel ? dbus_qspinor_rdata :
                             dbus_tmr_resp_sel     ? dbus_tmr_rdata     :
                             dbus_eic_resp_sel     ? dbus_eic_rdata     :
                             dbus_rst_resp_sel     ? dbus_rst_rdata     : {`BUS_WIDTH{1'bx}};

        // fault
        wire ibus_fault = ibus_req & ~|{ibus_rom_req_sel, ibus_tcm_req_sel, ibus_sram_req_sel, ibus_nor_req_sel};
        wire dbus_fault = dbus_req & ~|{dbus_rom_req_sel, dbus_tcm_req_sel, dbus_sram_req_sel, dbus_nor_req_sel, dbus_gpio_req_sel, dbus_uart_req_sel, dbus_qspinor_req_sel, dbus_tmr_req_sel, dbus_eic_req_sel, dbus_rst_req_sel};
        assign  bus_fault = ibus_fault | dbus_fault;
    end

    /******************************************************************************************************************************************************************/
    // interrupt
    wire            ext_int_trigger, ext_int_handled;
    wire[3:0]       ext_int_from;

    /******************************************************************************************************************************************************************/
    // core

    core core (
        .clk (clk      ),
        .rstn(core_rstn),

        .core_fault   (core_fault),
        .core_fault_pc(),

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
    begin: FABRIC_ROM
        wire[`XLEN-1:0]                 bus_addr;
        wire                            bus_w_rb;
        wire[$clog2(`BUS_ACC_CNT)-1:0]  bus_acc;
        wire[`BUS_WIDTH-1:0]            bus_rdata, bus_wdata;
        wire                            bus_req, bus_resp;

        bus_mux rom_bus_mux (
            .clk       (clk     ),
            .rstn      (rom_rstn),

            .dbus_addr (dbus_addr     ),
            .dbus_w_rb (dbus_w_rb     ),
            .dbus_acc  (dbus_acc      ),
            .dbus_wdata(dbus_wdata    ),
            .dbus_rdata(dbus_rom_rdata),
            .dbus_req  (dbus_rom_req  ),
            .dbus_resp (dbus_rom_resp ),

            .ibus_addr (ibus_addr     ),
            .ibus_w_rb (ibus_w_rb     ),
            .ibus_acc  (ibus_acc      ),
            .ibus_wdata(ibus_wdata    ),
            .ibus_rdata(ibus_rom_rdata),
            .ibus_req  (ibus_rom_req  ),
            .ibus_resp (ibus_rom_resp ),

            .bus_addr  (bus_addr ),
            .bus_w_rb  (bus_w_rb ),
            .bus_acc   (bus_acc  ),
            .bus_rdata (bus_rdata),
            .bus_wdata (bus_wdata),
            .bus_req   (bus_req  ),
            .bus_resp  (bus_resp )
        );

        rom_controller rom_controller (
            .clk (clk     ),
            .rstn(rom_rstn),

            .addr (bus_addr[`ROM_VA_WIDTH-1:0]),
            .w_rb (bus_w_rb                   ),
            .acc  (bus_acc                    ),
            .rdata(bus_rdata                  ),
            .wdata(bus_wdata                  ),
            .req  (bus_req                    ),
            .resp (bus_resp                   ),

            .fault(rom_fault)
        );
    end

    /******************************************************************************************************************************************************************/
    begin: FABRIC_TCM
        wire[`XLEN-1:0]                 bus_addr;
        wire                            bus_w_rb;
        wire[$clog2(`BUS_ACC_CNT)-1:0]  bus_acc;
        wire[`BUS_WIDTH-1:0]            bus_rdata, bus_wdata;
        wire                            bus_req, bus_resp;

        bus_mux tcm_bus_mux (
            .clk       (clk     ),
            .rstn      (tcm_rstn),

            .dbus_addr (dbus_addr     ),
            .dbus_w_rb (dbus_w_rb     ),
            .dbus_acc  (dbus_acc      ),
            .dbus_wdata(dbus_wdata    ),
            .dbus_rdata(dbus_tcm_rdata),
            .dbus_req  (dbus_tcm_req  ),
            .dbus_resp (dbus_tcm_resp ),

            .ibus_addr (ibus_addr     ),
            .ibus_w_rb (ibus_w_rb     ),
            .ibus_acc  (ibus_acc      ),
            .ibus_wdata(ibus_wdata    ),
            .ibus_rdata(ibus_tcm_rdata),
            .ibus_req  (ibus_tcm_req  ),
            .ibus_resp (ibus_tcm_resp ),

            .bus_addr  (bus_addr ),
            .bus_w_rb  (bus_w_rb ),
            .bus_acc   (bus_acc  ),
            .bus_rdata (bus_rdata),
            .bus_wdata (bus_wdata),
            .bus_req   (bus_req  ),
            .bus_resp  (bus_resp )
        );

        tcm_controller tcm_controller (
            .clk (clk     ),
            .rstn(tcm_rstn),

            .addr (bus_addr[`TCM_VA_WIDTH-1:0]),
            .w_rb (bus_w_rb                   ),
            .acc  (bus_acc                    ),
            .rdata(bus_rdata                  ),
            .wdata(bus_wdata                  ),
            .req  (bus_req                    ),
            .resp (bus_resp                   ),

            .fault(tcm_fault)
        );
    end

    /******************************************************************************************************************************************************************/
    begin: FABRIC_SRAM
        wire[`XLEN-1:0]                 bus_addr;
        wire                            bus_w_rb;
        wire[$clog2(`BUS_ACC_CNT)-1:0]  bus_acc;
        wire[`BUS_WIDTH-1:0]            bus_rdata, bus_wdata;
        wire                            bus_req, bus_resp;

        bus_mux sram_bus_mux (
            .clk       (clk      ),
            .rstn      (sram_rstn),

            .dbus_addr (dbus_addr      ),
            .dbus_w_rb (dbus_w_rb      ),
            .dbus_acc  (dbus_acc       ),
            .dbus_wdata(dbus_wdata     ),
            .dbus_rdata(dbus_sram_rdata),
            .dbus_req  (dbus_sram_req  ),
            .dbus_resp (dbus_sram_resp ),

            .ibus_addr (ibus_addr      ),
            .ibus_w_rb (ibus_w_rb      ),
            .ibus_acc  (ibus_acc       ),
            .ibus_wdata(ibus_wdata     ),
            .ibus_rdata(ibus_sram_rdata),
            .ibus_req  (ibus_sram_req  ),
            .ibus_resp (ibus_sram_resp ),

            .bus_addr  (bus_addr ),
            .bus_w_rb  (bus_w_rb ),
            .bus_acc   (bus_acc  ),
            .bus_rdata (bus_rdata),
            .bus_wdata (bus_wdata),
            .bus_req   (bus_req  ),
            .bus_resp  (bus_resp )
        );

        sram_controller sram_controller (
            .clk (clk      ),
            .rstn(sram_rstn),

            .addr (bus_addr[`SRAM_VA_WIDTH-1:0]),
            .w_rb (bus_w_rb                    ),
            .acc  (bus_acc                     ),
            .rdata(bus_rdata                   ),
            .wdata(bus_wdata                   ),
            .req  (bus_req                     ),
            .resp (bus_resp                    ),

            .fault(sram_fault),

            .sram_ce_bar  (ior_sram_ce_bar  ),
            .sram_oe_bar  (ior_sram_oe_bar  ),
            .sram_we_bar  (ior_sram_we_bar  ),
            .sram_data_dir(ior_sram_data_dir),
            .sram_data_in (ior_sram_data_in ),
            .sram_data_out(ior_sram_data_out),
            .sram_addr    (ior_sram_addr    )
        );
    end

    /******************************************************************************************************************************************************************/
    begin: FABRIC_QSPINOR
        wire[`XLEN-1:0]                 bus_addr;
        wire                            bus_w_rb;
        wire[$clog2(`BUS_ACC_CNT)-1:0]  bus_acc;
        wire[`BUS_WIDTH-1:0]            bus_rdata, bus_wdata;
        wire                            bus_req, bus_resp;

        bus_mux qspinor_bus_mux (
            .clk       (clk     ),
            .rstn      (nor_rstn),

            .dbus_addr (dbus_addr     ),
            .dbus_w_rb (dbus_w_rb     ),
            .dbus_acc  (dbus_acc      ),
            .dbus_wdata(dbus_wdata    ),
            .dbus_rdata(dbus_nor_rdata),
            .dbus_req  (dbus_nor_req  ),
            .dbus_resp (dbus_nor_resp ),

            .ibus_addr (ibus_addr     ),
            .ibus_w_rb (ibus_w_rb     ),
            .ibus_acc  (ibus_acc      ),
            .ibus_wdata(ibus_wdata    ),
            .ibus_rdata(ibus_nor_rdata),
            .ibus_req  (ibus_nor_req  ),
            .ibus_resp (ibus_nor_resp ),

            .bus_addr  (bus_addr ),
            .bus_w_rb  (bus_w_rb ),
            .bus_acc   (bus_acc  ),
            .bus_rdata (bus_rdata),
            .bus_wdata (bus_wdata),
            .bus_req   (bus_req  ),
            .bus_resp  (bus_resp )
        );

        qspinor_controller qspinor_controller (
            .clk         (clk         ),
            .nor_rstn    (nor_rstn    ),
            .qspinor_rstn(qspinor_rstn),

            .nor_addr (bus_addr[`NOR_VA_WIDTH-1:0]),
            .nor_w_rb (bus_w_rb                   ),
            .nor_acc  (bus_acc                    ),
            .nor_rdata(bus_rdata                  ),
            .nor_wdata(bus_wdata                  ),
            .nor_req  (bus_req                    ),
            .nor_resp (bus_resp                   ),

            .nor_fault(nor_fault),

            .qspinor_addr (dbus_addr[`QSPINOR_VA_WIDTH-1:0]),
            .qspinor_w_rb (dbus_w_rb                       ),
            .qspinor_acc  (dbus_acc                        ),
            .qspinor_wdata(dbus_wdata                      ),
            .qspinor_rdata(dbus_qspinor_rdata              ),
            .qspinor_req  (dbus_qspinor_req                ),
            .qspinor_resp (dbus_qspinor_resp               ),

            .qspinor_fault(qspinor_fault),

            .qspi_csb (ior_qspi_csb ),
            .qspi_sclk(ior_qspi_sclk),
            .qspi_dir (ior_qspi_dir ),
            .qspi_mosi(ior_qspi_mosi),
            .qspi_miso(ior_qspi_miso)
        );
    end

    // gpio
    gpio_controller gpio_controller (
        .clk (clk      ),
        .rstn(gpio_rstn),

        .dir(ior_gpio_dir),
        .i  (ior_gpio_i  ),
        .o  (ior_gpio_o  ),

        .addr (dbus_addr[`GPIO_VA_WIDTH-1:0]),
        .w_rb (dbus_w_rb                    ),
        .acc  (dbus_acc                     ),
        .wdata(dbus_wdata                   ),
        .rdata(dbus_gpio_rdata              ),
        .req  (dbus_gpio_req                ),
        .resp (dbus_gpio_resp               ),

        .fault(gpio_fault)
    );

    // uart
    uart_controller uart_controller (
        .clk (clk      ),
        .rstn(uart_rstn),

        .rx(ior_uart_rx),
        .tx(ior_uart_tx),

        .addr (dbus_addr[`UART_VA_WIDTH-1:0]),
        .w_rb (dbus_w_rb                    ),
        .acc  (dbus_acc                     ),
        .wdata(dbus_wdata                   ),
        .rdata(dbus_uart_rdata              ),
        .req  (dbus_uart_req                ),
        .resp (dbus_uart_resp               ),

        .fault(uart_fault)
    );

    // timer
    timer_controller timer_controller (
        .clk (clk     ),
        .rstn(tmr_rstn),

        .addr (dbus_addr[`TMR_VA_WIDTH-1:0]),
        .w_rb (dbus_w_rb                   ),
        .acc  (dbus_acc                    ),
        .wdata(dbus_wdata                  ),
        .rdata(dbus_tmr_rdata              ),
        .req  (dbus_tmr_req                ),
        .resp (dbus_tmr_resp               ),

        .fault(tmr_fault)
    );

    // eic
    extint_controller extint_controller (
        .clk (clk      ),
        .rstn(core_rstn),

        .ext_int_trigger(ext_int_trigger),
        .ext_int_handled(ext_int_handled),

        .ext_int_from(ext_int_from),

        .addr (dbus_addr[`EIC_VA_WIDTH-1:0]),
        .w_rb (dbus_w_rb                   ),
        .acc  (dbus_acc                    ),
        .wdata(dbus_wdata                  ),
        .rdata(dbus_eic_rdata              ),
        .req  (dbus_eic_req                ),
        .resp (dbus_eic_resp               ),

        .fault(eic_fault)
    );

    // reset
    rst_controller rst_controller (
        .clk (clk),

        .rst_ib(rstn    ),
        .rst_ob(rstn_vec),

        .addr (dbus_addr[`RST_VA_WIDTH-1:0]),
        .w_rb (dbus_w_rb                   ),
        .acc  (dbus_acc                    ),
        .wdata(dbus_wdata                  ),
        .rdata(dbus_rst_rdata              ),
        .req  (dbus_rst_req                ),
        .resp (dbus_rst_resp               ),

        .fault(rst_fault)
    );

endmodule

module bus_mux(
    input wire  clk,
    input wire  rstn,

    // data bus interface
    input wire[`XLEN-1:0]                   dbus_addr, // byte addr
    input wire                              dbus_w_rb,
    input wire[$clog2(`BUS_ACC_CNT)-1:0]    dbus_acc,
    output reg[`BUS_WIDTH-1:0]              dbus_rdata,
    input wire[`BUS_WIDTH-1:0]              dbus_wdata,
    input wire                              dbus_req,
    output reg                              dbus_resp,

    // instruction bus interface
    input wire[`XLEN-1:0]                   ibus_addr, // byte addr
    input wire                              ibus_w_rb,
    input wire[$clog2(`BUS_ACC_CNT)-1:0]    ibus_acc,
    output reg[`BUS_WIDTH-1:0]              ibus_rdata,
    input wire[`BUS_WIDTH-1:0]              ibus_wdata,
    input wire                              ibus_req,
    output reg                              ibus_resp,

    // memory bus interface
    output reg[`XLEN-1:0]                   bus_addr, // byte addr
    output reg                              bus_w_rb,
    output reg[$clog2(`BUS_ACC_CNT)-1:0]    bus_acc,
    input wire[`BUS_WIDTH-1:0]              bus_rdata,
    output reg[`BUS_WIDTH-1:0]              bus_wdata,
    output reg                              bus_req,
    input wire                              bus_resp
);
    wire[`XLEN-1:0] ibus_req_addr;
    wire    ibus_req_w_rb;
    wire[$clog2(`BUS_ACC_CNT)-1:0]  ibus_req_acc;
    wire[`BUS_WIDTH-1:0]    ibus_req_wdata;
    dff #(
        .WIDTH(`XLEN+$clog2(`BUS_ACC_CNT)+`BUS_WIDTH),
        .VALID("async")
    ) ibus_req_info_dff (
        .clk(clk                                          ),
        .vld(ibus_req                                     ),
        .in ({ibus_addr, ibus_acc, ibus_wdata}            ),
        .out({ibus_req_addr, ibus_req_acc, ibus_req_wdata})
    );
    assign  ibus_req_w_rb=1'b0;

    wire[`XLEN-1:0] dbus_req_addr;
    wire    dbus_req_w_rb;
    wire[$clog2(`BUS_ACC_CNT)-1:0]  dbus_req_acc;
    wire[`BUS_WIDTH-1:0]    dbus_req_wdata;
    dff #(
        .WIDTH(`XLEN+1+$clog2(`BUS_ACC_CNT)+`BUS_WIDTH),
        .VALID("async")
    ) dbus_req_info_dff (
        .clk(clk                                                         ),
        .vld(dbus_req                                                    ),
        .in ({dbus_addr, dbus_w_rb, dbus_acc, dbus_wdata}                ),
        .out({dbus_req_addr, dbus_req_w_rb, dbus_req_acc, dbus_req_wdata})
    );

    // state control
    wire    ibus_access_ongoing;
    dff #(
        .VALID("sync"),
        .RESET("sync")
    ) ibus_req_dff (
        .clk (clk                 ),
        .rstn(rstn                ),
        .vld (ibus_req | ibus_resp),
        .in  (ibus_req            ),
        .out (ibus_access_ongoing )
    );

    wire    dbus_access_ongoing;
    dff #(
        .VALID("sync"),
        .RESET("sync")
    ) dbus_req_dff (
        .clk (clk                 ),
        .rstn(rstn                ),
        .vld (dbus_req | dbus_resp),
        .in  (dbus_req            ),
        .out (dbus_access_ongoing )
    );

    localparam  N = 0,
                I = 1,
                D = 2;
    reg[7:0] state, next_state;
    always @ (posedge clk) begin
        if (~rstn) begin
            state <= N;
        end else begin
            state <= next_state;
        end
    end

    always @ (*) case (state)
        default:
            if (dbus_req)
                next_state = D;
            else if (ibus_req)
                next_state = I;
            else
                next_state = N;
        I:
            if (~bus_resp)
                next_state = I;
            else if (dbus_req | dbus_access_ongoing)
                next_state = D;
            else if (ibus_req)
                next_state = I;
            else
                next_state = N;
        D:
            if (~bus_resp)
                next_state = D;
            else if (ibus_req | ibus_access_ongoing)
                next_state = I;
            else if (dbus_req)
                next_state = D;
            else
                next_state = N;
    endcase

    // signal dispatcher
    always @ (*) case (state)
        default: bus_req = ibus_req | dbus_req;
        I:       bus_req = bus_resp & (dbus_req | dbus_access_ongoing | ibus_req);
        D:       bus_req = bus_resp & (ibus_req | ibus_access_ongoing | dbus_req);
    endcase

    always @ (*) case (next_state)
        default: begin
            bus_addr = {`XLEN{1'bx}};
            bus_w_rb = 1'bx;
            bus_acc = {$clog2(`BUS_ACC_CNT){1'bx}};
            bus_wdata = {`BUS_WIDTH{1'bx}};
        end
        I: begin
            bus_addr = ibus_req_addr;
            bus_w_rb = ibus_req_w_rb;
            bus_acc = ibus_req_acc;
            bus_wdata = ibus_req_wdata;
        end
        D: begin
            bus_addr = dbus_req_addr;
            bus_w_rb = dbus_req_w_rb;
            bus_acc = dbus_req_acc;
            bus_wdata = dbus_req_wdata;
        end
    endcase

    always @ (*) case (state)
        default: begin
            dbus_resp = 1'b0;
            dbus_rdata = {`BUS_WIDTH{1'bx}};
            ibus_resp = 1'b0;
            ibus_rdata = {`BUS_WIDTH{1'bx}};
        end
        I: begin
            dbus_resp = 1'b0;
            dbus_rdata = {`BUS_WIDTH{1'bx}};
            ibus_resp = bus_resp;
            ibus_rdata = bus_rdata;
        end
        D: begin
            dbus_resp = bus_resp;
            dbus_rdata = bus_rdata;
            ibus_resp = 1'b0;
            ibus_rdata = {`BUS_WIDTH{1'bx}};
        end
    endcase
endmodule
