`include "timescale.vh"
`include "femto.vh"

(* keep_hierarchy = "yes" *)
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
    wire[`RST_WIDTH-1:0]    rstn_v; // rstn vector
    wire    core_rstn    =  rstn_v[`RST_CORE],
            rom_rstn     =  rstn_v[`RST_ROM ],
            tcm_rstn     =  rstn_v[`RST_TCM ],
            sram_rstn    =  rstn_v[`RST_SRAM],
            nor_rstn     =  rstn_v[`RST_NOR ],
            gpio_rstn    =  rstn_v[`RST_GPIO],
            uart_rstn    =  rstn_v[`RST_UART],
            qspinor_rstn =  rstn_v[`RST_QSPI],
            tmr_rstn     =  rstn_v[`RST_TMR ];

    // core
    wire[`XLEN-1:0]                 bus_addr;
    wire                            bus_w_rb;
    wire[$clog2(`BUS_ACC_CNT)-1:0]  bus_acc;
    wire[`BUS_WIDTH-1:0]            bus_rdata, bus_wdata;
    wire                            bus_req, bus_resp;
    core core (
        .clk (clk      ),
        .rstn(core_rstn),

        .core_fault   (core_fault),
        .core_fault_pc(),

        .bus_addr (bus_addr ),
        .bus_w_rb (bus_w_rb ),
        .bus_acc  (bus_acc  ),
        .bus_rdata(bus_rdata),
        .bus_wdata(bus_wdata),
        .bus_req  (bus_req  ),
        .bus_resp (bus_resp )
    );

    // fault latch
    dff #(
        .VALID("sync")
    ) req_acc_dff (
        .clk(clk    ),
        .vld(bus_req),
        .in (|{core_fault, bus_fault, rom_fault, tcm_fault, sram_fault, nor_fault, gpio_fault, uart_fault, qspinor_fault, tmr_fault, rst_fault}),
        .out(fault  )
    );

    // module selection
    wire    rom_req_sel     = (bus_addr & `ROM_SEL_MASK)==`ROM_ADDR,
            tcm_req_sel     = (bus_addr & `TCM_SEL_MASK)==`TCM_ADDR,
            sram_req_sel    = (bus_addr & `SRAM_SEL_MASK)==`SRAM_ADDR,
            nor_req_sel     = (bus_addr & `NOR_SEL_MASK)==`NOR_ADDR,
            gpio_req_sel    = (bus_addr & `GPIO_SEL_MASK)==`GPIO_ADDR,
            uart_req_sel    = (bus_addr & `UART_SEL_MASK)==`UART_ADDR,
            qspinor_req_sel = (bus_addr & `QSPINOR_SEL_MASK)==`QSPINOR_ADDR,
            tmr_req_sel     = (bus_addr & `TMR_SEL_MASK)==`TMR_ADDR,
            rst_req_sel     = (bus_addr & `RST_SEL_MASK)==`RST_ADDR;

    wire    rom_resp_sel    ,
            tcm_resp_sel    ,
            sram_resp_sel   ,
            nor_resp_sel    ,
            gpio_resp_sel   ,
            uart_resp_sel   ,
            qspinor_resp_sel,
            tmr_resp_sel    ,
            rst_resp_sel    ;

    dff # (
        .WIDTH(9     ),
        .VALID("sync")
    ) bus_resp_sel_dff (
        .clk (clk    ),
        .vld (bus_req),
        .in  ({rom_req_sel, tcm_req_sel, sram_req_sel, nor_req_sel, gpio_req_sel, uart_req_sel, qspinor_req_sel, tmr_req_sel, rst_req_sel}),
        .out ({rom_resp_sel, tcm_resp_sel, sram_resp_sel, nor_resp_sel, gpio_resp_sel, uart_resp_sel, qspinor_resp_sel, tmr_resp_sel, rst_resp_sel})
    );

    // bus fault
    assign bus_fault = bus_req & ~|{rom_req_sel, tcm_req_sel, sram_req_sel, nor_req_sel, gpio_req_sel, uart_req_sel, qspinor_req_sel, tmr_req_sel, rst_req_sel};

    // req, resp and rdata
    wire    rom_req     = bus_req & rom_req_sel    ,
            tcm_req     = bus_req & tcm_req_sel    ,
            sram_req    = bus_req & sram_req_sel   ,
            nor_req     = bus_req & nor_req_sel    ,
            gpio_req    = bus_req & gpio_req_sel   ,
            uart_req    = bus_req & uart_req_sel   ,
            qspinor_req = bus_req & qspinor_req_sel,
            tmr_req     = bus_req & tmr_req_sel    ,
            rst_req     = bus_req & rst_req_sel    ;

    wire    rom_resp    ,
            tcm_resp    ,
            sram_resp   ,
            nor_resp    ,
            gpio_resp   ,
            uart_resp   ,
            qspinor_resp,
            tmr_resp    ,
            rst_resp    ;

    wire[`BUS_WIDTH-1:0]    rom_rdata    ,
                            tcm_rdata    ,
                            sram_rdata   ,
                            nor_rdata    ,
                            gpio_rdata   ,
                            uart_rdata   ,
                            qspinor_rdata,
                            tmr_rdata    ,
                            rst_rdata    ;

    assign  bus_resp = fault ? 1'b0 : |{rom_resp, tcm_resp, sram_resp, nor_resp, gpio_resp, uart_resp, qspinor_resp, tmr_resp, rst_resp};
    assign  bus_rdata = rom_resp_sel     ? rom_rdata     :
                        tcm_resp_sel     ? tcm_rdata     :
                        sram_resp_sel    ? sram_rdata    :
                        nor_resp_sel     ? nor_rdata     :
                        gpio_resp_sel    ? gpio_rdata    :
                        uart_resp_sel    ? uart_rdata    :
                        qspinor_resp_sel ? qspinor_rdata :
                        tmr_resp_sel     ? tmr_rdata     :
                        rst_resp_sel     ? rst_rdata     : {`BUS_WIDTH{1'bx}};

    // ioring
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

    // rom
    rom_controller rom_controller (
        .clk (clk     ),
        .rstn(rom_rstn),

        .addr (bus_addr ),
        .w_rb (bus_w_rb ),
        .acc  (bus_acc  ),
        .wdata(bus_wdata),
        .rdata(rom_rdata),
        .req  (rom_req  ),
        .resp (rom_resp ),
        .fault(rom_fault)
    );

    // tcm
    tcm_controller tcm_controller (
        .clk (clk     ),
        .rstn(tcm_rstn),

        .addr (bus_addr ),
        .w_rb (bus_w_rb ),
        .acc  (bus_acc  ),
        .wdata(bus_wdata),
        .rdata(tcm_rdata),
        .req  (tcm_req  ),
        .resp (tcm_resp ),
        .fault(tcm_fault)
    );

    // sram
    sram_controller sram_controller (
        .clk (clk      ),
        .rstn(sram_rstn),

        .addr (bus_addr  ),
        .w_rb (bus_w_rb  ),
        .acc  (bus_acc   ),
        .wdata(bus_wdata ),
        .rdata(sram_rdata),
        .req  (sram_req  ),
        .resp (sram_resp ),
        .fault(sram_fault),

        .sram_ce_bar  (ior_sram_ce_bar  ),
        .sram_oe_bar  (ior_sram_oe_bar  ),
        .sram_we_bar  (ior_sram_we_bar  ),
        .sram_data_dir(ior_sram_data_dir),
        .sram_data_in (ior_sram_data_in ),
        .sram_data_out(ior_sram_data_out),
        .sram_addr    (ior_sram_addr    )
    );

    // nor & qspinor (bus read/ip access)
    qspinor_controller qspinor_controller (
        .clk         (clk         ),
        .nor_rstn    (nor_rstn    ),
        .qspinor_rstn(qspinor_rstn),

        .nor_addr (bus_addr ),
        .nor_w_rb (bus_w_rb ),
        .nor_acc  (bus_acc  ),
        .nor_wdata(bus_wdata),
        .nor_rdata(nor_rdata),
        .nor_req  (nor_req  ),
        .nor_resp (nor_resp ),
        .nor_fault(nor_fault),

        .qspinor_addr (bus_addr     ),
        .qspinor_w_rb (bus_w_rb     ),
        .qspinor_acc  (bus_acc      ),
        .qspinor_wdata(bus_wdata    ),
        .qspinor_rdata(qspinor_rdata),
        .qspinor_req  (qspinor_req  ),
        .qspinor_resp (qspinor_resp ),
        .qspinor_fault(qspinor_fault),

        .qspi_csb (ior_qspi_csb ),
        .qspi_sclk(ior_qspi_sclk),
        .qspi_dir (ior_qspi_dir ),
        .qspi_mosi(ior_qspi_mosi),
        .qspi_miso(ior_qspi_miso)
    );
    
    // gpio
    gpio_controller gpio_controller (
        .clk (clk      ),
        .rstn(gpio_rstn),

        .dir(ior_gpio_dir),
        .i  (ior_gpio_i  ),
        .o  (ior_gpio_o  ),

        .addr (bus_addr  ),
        .w_rb (bus_w_rb  ),
        .acc  (bus_acc   ),
        .wdata(bus_wdata ),
        .rdata(gpio_rdata),
        .req  (gpio_req  ),
        .resp (gpio_resp ),
        .fault(gpio_fault)
    );

    // uart
    uart_controller uart_controller (
        .clk (clk      ),
        .rstn(uart_rstn),

        .rx(ior_uart_rx),
        .tx(ior_uart_tx),

        .addr (bus_addr  ),
        .w_rb (bus_w_rb  ),
        .acc  (bus_acc   ),
        .wdata(bus_wdata ),
        .rdata(uart_rdata),
        .req  (uart_req  ),
        .resp (uart_resp ),
        .fault(uart_fault)
    );

    // timer
    timer_controller timer_controller (
        .clk (clk     ),
        .rstn(tmr_rstn),

        .addr (bus_addr ),
        .w_rb (bus_w_rb ),
        .acc  (bus_acc  ),
        .wdata(bus_wdata),
        .rdata(tmr_rdata),
        .req  (tmr_req  ),
        .resp (tmr_resp ),
        .fault(tmr_fault)
    );

    // reset
    rst_controller rst_controller (
        .clk (clk),

        .rst_ib(rstn  ),
        .rst_ob(rstn_v),

        .addr (bus_addr ),
        .w_rb (bus_w_rb ),
        .acc  (bus_acc  ),
        .wdata(bus_wdata),
        .rdata(rst_rdata),
        .req  (rst_req  ),
        .resp (rst_resp ),
        .fault(rst_fault)
    );

endmodule
