    // endsim via timer_controller addr space
    always @ (posedge top.clk) begin
        if (top.femto.dbus_tmr_req && top.femto.dbus_wdata=="PASS") begin
            $display("PASS");
            $finish(0);
        end else if (top.femto.dbus_tmr_req && top.femto.dbus_wdata=="FAIL") begin
            $display("FAIL");
            $finish(0);
        end
    end
