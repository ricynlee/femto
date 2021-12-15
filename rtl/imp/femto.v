`include "timescale.vh"
`include "femto.vh"

(*keep_hierarchy="true"*)
module femto (
    input wire  clk ,
    input wire  rstn,

    inout wire[`GPIO_WIDTH-1:0] gpio,

    input wire  uart_rx,
    output wire uart_tx,

    output wire ada_sck,
    output wire ada_ws,
    input wire  ada_sd,
    output wire ada_lrs
);

    // fault signals
    wire    core_fault,
            bus_fault,
            rom_fault,
            tcm_fault,
            gpio_fault,
            uart_fault,
            tmr_fault,
            ada_fault;

    wire    fault;

    // reset signals
    wire[`RST_WIDTH-1:0]    rstn_v; // rstn vector
    wire    core_rstn    =  rstn_v[`RST_CORE],
            rom_rstn     =  rstn_v[`RST_ROM ],
            tcm_rstn     =  rstn_v[`RST_TCM ],
            gpio_rstn    =  rstn_v[`RST_GPIO],
            uart_rstn    =  rstn_v[`RST_UART],
            tmr_rstn     =  rstn_v[`RST_TMR ],
            ada_rstn     =  rstn_v[`RST_ADA ];

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
        .in (|{core_fault, bus_fault, rom_fault, tcm_fault, gpio_fault, uart_fault, tmr_fault, ada_fault, rst_fault}),
        .out(fault  )
    );

    // module selection
    wire    rom_req_sel     = (bus_addr & `ROM_SEL_MASK)==`ROM_ADDR,
            tcm_req_sel     = (bus_addr & `TCM_SEL_MASK)==`TCM_ADDR,
            gpio_req_sel    = (bus_addr & `GPIO_SEL_MASK)==`GPIO_ADDR,
            uart_req_sel    = (bus_addr & `UART_SEL_MASK)==`UART_ADDR,
            tmr_req_sel     = (bus_addr & `TMR_SEL_MASK)==`TMR_ADDR,
            ada_req_sel     = (bus_addr & `RST_SEL_MASK)==`ADA_ADDR;

    wire    rom_resp_sel ,
            tcm_resp_sel ,
            gpio_resp_sel,
            uart_resp_sel,
            tmr_resp_sel ,
            ada_resp_sel ;

    dff # (
        .WIDTH(7     ),
        .VALID("sync")
    ) bus_resp_sel_dff (
        .clk (clk    ),
        .vld (bus_req),
        .in  ({rom_req_sel, tcm_req_sel, gpio_req_sel, uart_req_sel, tmr_req_sel, ada_req_sel}),
        .out ({rom_resp_sel, tcm_resp_sel, gpio_resp_sel, uart_resp_sel, tmr_resp_sel, ada_resp_sel})
    );

    // bus fault
    assign bus_fault = bus_req & ~|{rom_req_sel, tcm_req_sel, gpio_req_sel, uart_req_sel, tmr_req_sel, ada_req_sel};

    // req, resp and rdata
    wire    rom_req     = bus_req & rom_req_sel ,
            tcm_req     = bus_req & tcm_req_sel ,
            gpio_req    = bus_req & gpio_req_sel,
            uart_req    = bus_req & uart_req_sel,
            tmr_req     = bus_req & tmr_req_sel ,
            ada_req     = bus_req & ada_req_sel ;

    wire    rom_resp ,
            tcm_resp ,
            gpio_resp,
            uart_resp,
            tmr_resp ,
            ada_resp ;

    wire[`BUS_WIDTH-1:0]    rom_rdata ,
                            tcm_rdata ,
                            gpio_rdata,
                            uart_rdata,
                            tmr_rdata ,
                            ada_rdata ;

    assign  bus_resp = fault ? 1'b0 : |{rom_resp, tcm_resp, gpio_resp, uart_resp, tmr_resp, ada_resp};
    assign  bus_rdata = rom_resp_sel     ? rom_rdata     :
                        tcm_resp_sel     ? tcm_rdata     :
                        gpio_resp_sel    ? gpio_rdata    :
                        uart_resp_sel    ? uart_rdata    :
                        tmr_resp_sel     ? tmr_rdata     :
                        ada_resp_sel     ? ada_rdata     : {`BUS_WIDTH{1'bx}};

    // ioring
    wire[`GPIO_WIDTH-1:0]   ior_gpio_dir;
    wire[`GPIO_WIDTH-1:0]   ior_gpio_i  ;
    wire[`GPIO_WIDTH-1:0]   ior_gpio_o  ;

    wire                    ior_uart_rx;
    wire                    ior_uart_tx;

    wire                    ior_ada_sck;
    wire                    ior_ada_ws ;
    wire                    ior_ada_sd ;
    wire                    ior_ada_lrs;

    ioring ioring (
        .gpio_dir(ior_gpio_dir),
        .gpio_i  (ior_gpio_i  ),
        .gpio_o  (ior_gpio_o  ),

        .uart_rx(ior_uart_rx),
        .uart_tx(ior_uart_tx),

        .ada_sck(ior_ada_sck),
        .ada_ws (ior_ada_ws ),
        .ada_sd (ior_ada_sd ),
        .ada_lrs(ior_ada_lrs),

        .pad_gpio(gpio),

        .pad_uart_rx(uart_rx),
        .pad_uart_tx(uart_tx),

        .pad_ada_sck(ada_sck),
        .pad_ada_ws (ada_ws ),
        .pad_ada_sd (ada_sd ),
        .pad_ada_lrs(ada_lrs)
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

    // ada
    audacq_controller ada_controller (
        .clk (clk     ),
        .rstn(ada_rstn),

        .addr (bus_addr ),
        .w_rb (bus_w_rb ),
        .acc  (bus_acc  ),
        .wdata(bus_wdata),
        .rdata(ada_rdata),
        .req  (ada_req  ),
        .resp (ada_resp ),

        .fault(ada_fault),

        .sck(ior_ada_sck),
        .ws (ior_ada_ws ),
        .sd (ior_ada_sd ),
        .lrs(ior_ada_lrs)
    );

    // reset
    rst_controller rst_controller (
        .clk (clk),

        .rst_ib(rstn  ),
        .rst_ob(rstn_v)
    );
endmodule
