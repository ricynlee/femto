    // endsim via timer_controller addr space
    always @ (posedge top.clk) begin
        if (
            top.femto.sram_wrapper.sram_controller.req &&
            top.femto.sram_wrapper.sram_controller.addr==19'h40000 && /* 256K, in the middle of SRAM */
            top.femto.sram_wrapper.sram_controller.wdata=="PASS"
        ) begin
            $display("PASS");
            $finish(0);
        end else if (
            top.femto.sram_wrapper.sram_controller.req &&
            top.femto.sram_wrapper.sram_controller.addr==19'h40000 && /* 256K, in the middle of SRAM */
            top.femto.sram_wrapper.sram_controller.wdata=="FAIL"
        ) begin
            $display("FAIL");
            $finish(0);
        end
    end
