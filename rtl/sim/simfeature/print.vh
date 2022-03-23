    // print via timer_controller addr space
    always @ (posedge top.clk) begin
        if (top.femto.dbus_tmr_req && top.femto.dbus_wdata[31:8]=="PRN") begin
            $write("%c", top.femto.dbus_wdata[7:0]);
        end
    end
