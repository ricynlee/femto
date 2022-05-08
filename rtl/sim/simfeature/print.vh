    // print via timer_controller addr space
    always @ (posedge top.clk) begin
        if (
            top.femto.sram_wrapper.sram_controller.req &&
            top.femto.sram_wrapper.sram_controller.addr==19'h40000 && /* 256K, in the middle of SRAM */
            top.femto.sram_wrapper.sram_controller.wdata[31:8]=="PRN"
        ) begin
            $write("%c", top.femto.sram_wrapper.sram_controller.wdata[7:0]);
        end
    end
