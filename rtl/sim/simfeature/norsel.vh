    // nor sel via timer_controller addr space
    always @ (posedge top.clk) if (top.femto.dbus_tmr_req) begin
        if (top.femto.dbus_wdata=="D2PI")
            norflash_sel = DPI_SEL;
        else if (top.femto.dbus_wdata=="Q4PI")
            norflash_sel = QPI_SEL;
        else
            norflash_sel = SPI_SEL;
    end
