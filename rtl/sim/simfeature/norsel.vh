    // nor sel via timer_controller addr space
    always @ (posedge top.clk) if (top.femto.sram_wrapper.sram_controller.req) begin
        if (
            top.femto.sram_wrapper.sram_controller.addr==19'h40000 && /* 256K, in the middle of SRAM */
            top.femto.sram_wrapper.sram_controller.wdata=="D2PI"
        )
            norflash_sel <= DPI_SEL;
        else if (
            top.femto.sram_wrapper.sram_controller.addr==19'h40000 && /* 256K, in the middle of SRAM */
            top.femto.sram_wrapper.sram_controller.wdata=="Q4PI"
        )
            norflash_sel <= QPI_SEL;
        else
            norflash_sel <= SPI_SEL;
    end
