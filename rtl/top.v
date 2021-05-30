`include "sim/timescale.vh"
`include "femto.vh"

module top(
    input wire                  sysclk,
    input wire                  sysrst,
    output wire                 fault,

    inout wire [`GPIO_DBW-1:0]  gpio,

    input wire                  uart_rx,
    output wire                 uart_tx,

    output wire                 sram_ce_bar,
    output wire                 sram_oe_bar,
    output wire                 sram_we_bar,
    inout wire  [7:0]           sram_data  ,
    output wire [18:0]          sram_addr  ,

    output wire                 qspi_sck,
    output wire                 qspi_csb,
    inout wire [3:0]            qspi_data
);
    // wire clk;
    // clk_gen clk_gen
    // (
    //     .clk_out(clk),
    //     .clk_in(sysclk)
    // );
    wire clk = sysclk;
    
    localparam RST_WIDTH         = 8,
               RST_INDEX_CORE    = 0,
               RST_INDEX_BUS     = 1,
               RST_INDEX_ROM     = 2,
               RST_INDEX_TCM     = 3,
               RST_INDEX_SRAM    = 4,
               RST_INDEX_QSPINOR = 5,
               RST_INDEX_GPIO    = 6,
               RST_INDEX_UART    = 7;

    wire [RST_WIDTH-1:0] rstn;
    syncrst_controller #(
        .RST_WIDTH(RST_WIDTH),
        .IN_POLAR (1),
        .OUT_POLAR(0)
    ) syncrst_controller (
        .clk    (clk   ),
        .rst_in (sysrst),
        .rst_out(rstn  )
    );

    wire core_fault, bus_fault;
    assign fault = core_fault | bus_fault;

    wire [`XLEN-1:0]                bus_addr; // req from core
    wire                            bus_w_rb;
    wire [$clog2(`BUS_ACC_CNT)-1:0] bus_acc;
    wire [`BUS_WIDTH-1:0]           bus_rdata;
    wire [`BUS_WIDTH-1:0]           bus_wdata;
    wire                            bus_req;
    wire                            bus_resp_raw;
    wire                            bus_resp = fault ? 1'b0 : bus_resp_raw;

    core core (
        .clk          (clk                 ),
        .rstn         (rstn[RST_INDEX_CORE]),
        .core_fault   (core_fault          ),
        .core_fault_pc(                    ),
        .bus_addr     (bus_addr            ),
        .bus_w_rb     (bus_w_rb            ),
        .bus_acc      (bus_acc             ),
        .bus_rdata    (bus_rdata           ),
        .bus_wdata    (bus_wdata           ),
        .bus_req      (bus_req             ),
        .bus_resp     (bus_resp            )
    );

    wire [`ROM_ABW-1:0]             bus_rom_addr ;
    wire                            bus_rom_wr_b ;
    wire [$clog2(`BUS_ACC_CNT)-1:0] bus_rom_acc  ;
    wire [`BUS_WIDTH-1:0]           bus_rom_rdata;
    wire [`BUS_WIDTH-1:0]           bus_rom_wdata;
    wire                            bus_rom_req  ;
    wire                            bus_rom_resp ; 
    wire                            bus_rom_fault;

    wire [`TCM_ABW-1:0]             bus_tcm_addr ;
    wire                            bus_tcm_wr_b ;
    wire [$clog2(`BUS_ACC_CNT)-1:0] bus_tcm_acc  ;
    wire [`BUS_WIDTH-1:0]           bus_tcm_rdata;
    wire [`BUS_WIDTH-1:0]           bus_tcm_wdata;
    wire                            bus_tcm_req  ;
    wire                            bus_tcm_resp ;
    wire                            bus_tcm_fault;

    wire [`SRAM_ABW-1:0]            bus_sram_addr ;
    wire                            bus_sram_wr_b ;
    wire [$clog2(`BUS_ACC_CNT)-1:0] bus_sram_acc  ;
    wire [`BUS_WIDTH-1:0]           bus_sram_rdata;
    wire [`BUS_WIDTH-1:0]           bus_sram_wdata;
    wire                            bus_sram_req  ;
    wire                            bus_sram_resp ;
    wire                            bus_sram_fault;

    wire [`QSPINOR_ABW:0]           bus_qspinor_addr ;
    wire                            bus_qspinor_wr_b ;
    wire [$clog2(`BUS_ACC_CNT)-1:0] bus_qspinor_acc  ;
    wire [`BUS_WIDTH-1:0]           bus_qspinor_rdata;
    wire [`BUS_WIDTH-1:0]           bus_qspinor_wdata;
    wire                            bus_qspinor_req  ;
    wire                            bus_qspinor_resp ;
    wire                            bus_qspinor_fault;

    wire [0:0]                      bus_gpio_addr ;
    wire                            bus_gpio_wr_b ;
    wire [$clog2(`BUS_ACC_CNT)-1:0] bus_gpio_acc  ;
    wire [`BUS_WIDTH-1:0]           bus_gpio_rdata;
    wire [`BUS_WIDTH-1:0]           bus_gpio_wdata;
    wire                            bus_gpio_req  ;
    wire                            bus_gpio_resp ;
    wire                            bus_gpio_fault;

    wire [1:0]                      bus_uart_addr ;
    wire                            bus_uart_wr_b ;
    wire [$clog2(`BUS_ACC_CNT)-1:0] bus_uart_acc  ;
    wire [`BUS_WIDTH-1:0]           bus_uart_rdata;
    wire [`BUS_WIDTH-1:0]           bus_uart_wdata;
    wire                            bus_uart_req  ;
    wire                            bus_uart_resp ;
    wire                            bus_uart_fault;

    bus bus (
        .clk           (clk                ),
        .rstn          (rstn[RST_INDEX_BUS]),
        .bus_fault     (bus_fault          ),
        .bus_fault_addr(                   ),
        .bus_addr      (bus_addr           ), // req from core
        .bus_w_rb      (bus_w_rb           ),
        .bus_acc       (bus_acc            ),
        .bus_rdata     (bus_rdata          ),
        .bus_wdata     (bus_wdata          ),
        .bus_req       (~fault & bus_req   ),
        .bus_resp      (bus_resp_raw       ),

        .rom_addr (bus_rom_addr ),
        .rom_wr_b (bus_rom_wr_b ),
        .rom_acc  (bus_rom_acc  ),
        .rom_rdata(bus_rom_rdata),
        .rom_wdata(bus_rom_wdata),
        .rom_req  (bus_rom_req  ),
        .rom_resp (bus_rom_resp ),
        .rom_fault(bus_rom_fault),

        .tcm_addr (bus_tcm_addr ), // internal tcm
        .tcm_wr_b (bus_tcm_wr_b ),
        .tcm_acc  (bus_tcm_acc  ),
        .tcm_rdata(bus_tcm_rdata),
        .tcm_wdata(bus_tcm_wdata),
        .tcm_req  (bus_tcm_req  ),
        .tcm_resp (bus_tcm_resp ),
        .tcm_fault(bus_tcm_fault),

        .sram_addr (bus_sram_addr ), // external sram
        .sram_wr_b (bus_sram_wr_b ),
        .sram_acc  (bus_sram_acc  ),
        .sram_rdata(bus_sram_rdata),
        .sram_wdata(bus_sram_wdata),
        .sram_req  (bus_sram_req  ),
        .sram_resp (bus_sram_resp ),
        .sram_fault(bus_sram_fault),

        .qspinor_addr (bus_qspinor_addr ), // external qspi nor
        .qspinor_wr_b (bus_qspinor_wr_b ),
        .qspinor_acc  (bus_qspinor_acc  ),
        .qspinor_rdata(bus_qspinor_rdata),
        .qspinor_wdata(bus_qspinor_wdata),
        .qspinor_req  (bus_qspinor_req  ),
        .qspinor_resp (bus_qspinor_resp ),
        .qspinor_fault(bus_qspinor_fault),

        .gpio_addr (bus_gpio_addr ),
        .gpio_wr_b (bus_gpio_wr_b ),
        .gpio_acc  (bus_gpio_acc  ),
        .gpio_rdata(bus_gpio_rdata),
        .gpio_wdata(bus_gpio_wdata),
        .gpio_req  (bus_gpio_req  ),
        .gpio_resp (bus_gpio_resp ),
        .gpio_fault(bus_gpio_fault),

        .uart_addr (bus_uart_addr ),
        .uart_wr_b (bus_uart_wr_b ),
        .uart_acc  (bus_uart_acc  ),
        .uart_rdata(bus_uart_rdata),
        .uart_wdata(bus_uart_wdata),
        .uart_req  (bus_uart_req  ),
        .uart_resp (bus_uart_resp ),
        .uart_fault(bus_uart_fault)
    );

    rom_controller #(
        .BYTE_ADDR_WIDTH(`ROM_ABW)
    ) rom_controller (
        .clk  (clk                ),
        .rstn (rstn[RST_INDEX_ROM]),
        .addr (bus_rom_addr       ),
        .wr_b (bus_rom_wr_b       ),
        .acc  (bus_rom_acc        ),
        .rdata(bus_rom_rdata      ),
        .wdata(bus_rom_wdata      ),
        .req  (bus_rom_req        ),
        .resp (bus_rom_resp       ),
        .fault(bus_rom_fault      )
    );

    tcm_controller #(
        .BYTE_ADDR_WIDTH(`TCM_ABW)
    ) tcm_controller (
        .clk  (clk                ), // <=100MHz
        .rstn (rstn[RST_INDEX_TCM]), // sync
        .req  (bus_tcm_req        ),
        .resp (bus_tcm_resp       ),
        .wr_b (bus_tcm_wr_b       ),
        .acc  (bus_tcm_acc        ),
        .addr (bus_tcm_addr       ),
        .wdata(bus_tcm_wdata      ),
        .rdata(bus_tcm_rdata      ),
        .fault(bus_tcm_fault      )
    );

    sram_controller sram_controller (
        .clk  (clk                 ), // <=100MHz
        .rstn (rstn[RST_INDEX_SRAM]), // sync
        .req  (bus_sram_req        ),
        .resp (bus_sram_resp       ),
        .wr_b (bus_sram_wr_b       ),
        .acc  (bus_sram_acc        ),
        .addr (bus_sram_addr       ),
        .wdata(bus_sram_wdata      ),
        .rdata(bus_sram_rdata      ),
        .fault(bus_sram_fault      ),

        .sram_ce_bar(sram_ce_bar),
        .sram_oe_bar(sram_oe_bar),
        .sram_we_bar(sram_we_bar),
        .sram_data  (sram_data  ),
        .sram_addr  (sram_addr  )
    );

    qspinor_controller qspinor_controller(
        .clk     (clk                               ), // <=100MHz
        .rstn    (rstn[RST_INDEX_QSPINOR]           ), // sync
        .req     (bus_qspinor_req                   ),
        .resp    (bus_qspinor_resp                  ),
        .wr_b    (bus_qspinor_wr_b                  ),
        .acc     (bus_qspinor_acc                   ),
        .ctrl_sel(bus_qspinor_addr[`QSPINOR_ABW]    ),
        .addr    (bus_qspinor_addr[`QSPINOR_ABW-1:0]),
        .wdata   (bus_qspinor_wdata                 ),
        .rdata   (bus_qspinor_rdata                 ),
        .fault   (bus_qspinor_fault                 ),

        .qspi_sck (qspi_sck ),
        .qspi_csb (qspi_csb ),
        .qspi_data(qspi_data)
    );

    gpio_controller gpio_controller(
        .clk  (clk                 ),
        .rstn (rstn[RST_INDEX_GPIO]),
        .addr (bus_gpio_addr       ),
        .wr_b (bus_gpio_wr_b       ),
        .acc  (bus_gpio_acc        ),
        .rdata(bus_gpio_rdata      ),
        .wdata(bus_gpio_wdata      ),
        .req  (bus_gpio_req        ),
        .resp (bus_gpio_resp       ),
        .fault(bus_gpio_fault      ),

        .io   (gpio)
    );

    uart_controller uart_controller(
        .clk  (clk                 ),
        .rstn (rstn[RST_INDEX_UART]),
        .req  (bus_uart_req        ),
        .resp (bus_uart_resp       ),
        .wr_b (bus_uart_wr_b       ),
        .acc  (bus_uart_acc        ),
        .addr (bus_uart_addr       ),
        .wdata(bus_uart_wdata      ),
        .rdata(bus_uart_rdata      ),
        .fault(bus_uart_fault      ),

        .rx(uart_rx),
        .tx(uart_tx)
    );
endmodule

module bus(
    input wire                              clk,
    input wire                              rstn,
    output reg                              bus_fault,
    output reg [`XLEN-1:0]                  bus_fault_addr,
    input wire [`XLEN-1:0]                  bus_addr, // req from core
    input wire                              bus_w_rb,
    input wire [$clog2(`BUS_ACC_CNT)-1:0]   bus_acc,
    output wire [`BUS_WIDTH-1:0]            bus_rdata,
    input wire [`BUS_WIDTH-1:0]             bus_wdata,
    input wire                              bus_req,
    output wire                             bus_resp,

    output wire [`ROM_ABW-1:0]              rom_addr,
    output wire                             rom_wr_b,
    output wire [$clog2(`BUS_ACC_CNT)-1:0]  rom_acc,
    input wire [`BUS_WIDTH-1:0]             rom_rdata,
    output wire [`BUS_WIDTH-1:0]            rom_wdata,
    output wire                             rom_req,
    input wire                              rom_resp,
    input wire                              rom_fault,

    output wire [`TCM_ABW-1:0]              tcm_addr, // internal tcm
    output wire                             tcm_wr_b,
    output wire [$clog2(`BUS_ACC_CNT)-1:0]  tcm_acc,
    input wire [`BUS_WIDTH-1:0]             tcm_rdata,
    output wire [`BUS_WIDTH-1:0]            tcm_wdata,
    output wire                             tcm_req,
    input wire                              tcm_resp,
    input wire                              tcm_fault,

    output wire [`SRAM_ABW-1:0]             sram_addr, // external sram
    output wire                             sram_wr_b,
    output wire [$clog2(`BUS_ACC_CNT)-1:0]  sram_acc,
    input wire [`BUS_WIDTH-1:0]             sram_rdata,
    output wire [`BUS_WIDTH-1:0]            sram_wdata,
    output wire                             sram_req,
    input wire                              sram_resp,
    input wire                              sram_fault,

    output wire [`QSPINOR_ABW:0]            qspinor_addr, // external qspi
    output wire                             qspinor_wr_b,
    output wire [$clog2(`BUS_ACC_CNT)-1:0]  qspinor_acc,
    input wire [`BUS_WIDTH-1:0]             qspinor_rdata,
    output wire [`BUS_WIDTH-1:0]            qspinor_wdata,
    output wire                             qspinor_req,
    input wire                              qspinor_resp,
    input wire                              qspinor_fault,

    output wire [0:0]                       gpio_addr,
    output wire                             gpio_wr_b,
    output wire [$clog2(`BUS_ACC_CNT)-1:0]  gpio_acc,
    input wire [`BUS_WIDTH-1:0]             gpio_rdata,
    output wire [`BUS_WIDTH-1:0]            gpio_wdata,
    output wire                             gpio_req,
    input wire                              gpio_resp,
    input wire                              gpio_fault,

    output wire [1:0]                       uart_addr,
    output wire                             uart_wr_b,
    output wire [$clog2(`BUS_ACC_CNT)-1:0]  uart_acc,
    input wire [`BUS_WIDTH-1:0]             uart_rdata,
    output wire [`BUS_WIDTH-1:0]            uart_wdata,
    output wire                             uart_req,
    input wire                              uart_resp,
    input wire                              uart_fault
);
    assign bus_resp = rom_resp | tcm_resp | sram_resp | qspinor_resp | gpio_resp | uart_resp;

    assign     rom_addr = bus_addr[`ROM_ABW-1:0];
    assign     tcm_addr = bus_addr[`TCM_ABW-1:0];
    assign    sram_addr = bus_addr[`SRAM_ABW-1:0];
    assign qspinor_addr = {bus_addr[24],bus_addr[`QSPINOR_ABW-1:0]};
    assign    gpio_addr = bus_addr[2];
    assign    uart_addr = bus_addr[1:0];

    assign     rom_wr_b = bus_w_rb;
    assign     tcm_wr_b = bus_w_rb;
    assign    sram_wr_b = bus_w_rb;
    assign qspinor_wr_b = bus_w_rb;
    assign    gpio_wr_b = bus_w_rb;
    assign    uart_wr_b = bus_w_rb;

    assign     rom_acc = bus_acc;
    assign     tcm_acc = bus_acc;
    assign    sram_acc = bus_acc;
    assign qspinor_acc = bus_acc;
    assign    gpio_acc = bus_acc;
    assign    uart_acc = bus_acc;

    assign     rom_wdata = bus_wdata;
    assign     tcm_wdata = bus_wdata;
    assign    sram_wdata = bus_wdata;
    assign qspinor_wdata = bus_wdata;
    assign    gpio_wdata = bus_wdata;
    assign    uart_wdata = bus_wdata;

    wire [$clog2(`BUS_NDEV):0] req_dev_index =
        bus_addr[`XLEN-1:`ROM_ABW]==20'h00000 ? `BUS_IDEV_ROM : // ROM 00000000
        bus_addr[`XLEN-1:`TCM_ABW]==20'h10000 ? `BUS_IDEV_TCM : // TCM 10000000
        bus_addr[`XLEN-1:`SRAM_ABW]==13'h0400 ? `BUS_IDEV_SRAM : // SRAM 20000000
        bus_addr[`XLEN-1:`QSPINOR_ABW]==(32'h30000000 >> `QSPINOR_ABW) ? `BUS_IDEV_QSPINOR : // QSPINOR READ 30000000
       (bus_addr[`XLEN-1:2]==30'h0c400000 && bus_addr[0]==1'd0) ? `BUS_IDEV_QSPINOR : // QSPINOR REG 31000000/31000002
        bus_addr[`XLEN-1:2]==30'h0c400001 ? `BUS_IDEV_QSPINOR : // QSPINOR REG 31000004~31000007
       (bus_addr[`XLEN-1:3]==29'h08000000 && bus_addr[1:0]==2'd0) ? `BUS_IDEV_GPIO : // GPIO 40000000 & 40000004
        bus_addr[`XLEN-1:2]==30'h14000000 ? `BUS_IDEV_UART : // UART 50000000~50000003
        `BUS_NDEV;

    wire [$clog2(`BUS_NDEV)-1:0] resp_dev_index;
    dff # (
        .WIDTH($clog2(`BUS_NDEV)),
        .CLEAR("none")
    )cs_dff(
        .clk (clk           ),
        .rstn(rstn          ),
        .in  (bus_req ? req_dev_index[$clog2(`BUS_NDEV)-1:0] : resp_dev_index),
        .out (resp_dev_index)
    );

    assign bus_rdata =
        resp_dev_index==`BUS_IDEV_ROM ? rom_rdata  :
        resp_dev_index==`BUS_IDEV_TCM ? tcm_rdata :
        resp_dev_index==`BUS_IDEV_SRAM ? sram_rdata :
        resp_dev_index==`BUS_IDEV_QSPINOR ? qspinor_rdata :
        resp_dev_index==`BUS_IDEV_GPIO ? gpio_rdata :
        /* bresp_dev_index==`BUS_IDEV_UART */ uart_rdata ;

    assign     rom_req = bus_req && req_dev_index==`BUS_IDEV_ROM;
    assign     tcm_req = bus_req && req_dev_index==`BUS_IDEV_TCM;
    assign    sram_req = bus_req && req_dev_index==`BUS_IDEV_SRAM;
    assign qspinor_req = bus_req && req_dev_index==`BUS_IDEV_QSPINOR;
    assign    gpio_req = bus_req && req_dev_index==`BUS_IDEV_GPIO;
    assign    uart_req = bus_req && req_dev_index==`BUS_IDEV_UART;

    // bus fault ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    wire invld_addr = bus_req && req_dev_index==`BUS_NDEV; // bus interface's invld addr
    wire invld_acc = bus_req & ((bus_acc==`BUS_ACC_2B && bus_addr[0]) || (bus_acc==`BUS_ACC_4B && bus_addr[1:0])); // bus interface's invld acc
    wire invld_wr = 0; // bus interface's invld wr - not gonna happen
    wire invld_d = 0; // bus interface's invld data - not gonan happen

    wire module_fault = rom_fault | tcm_fault | sram_fault | qspinor_fault | gpio_fault | uart_fault;

    always @ (posedge clk) begin
        if (rstn==0) begin
            bus_fault <= 0;
        end else if (invld_addr | invld_acc | invld_wr | invld_d | module_fault) begin
            bus_fault <= 1;
            bus_fault_addr <= bus_addr;
        end
    end
endmodule
