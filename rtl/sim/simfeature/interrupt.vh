    // interrupt
    logic[3:0] ext_int_from = 4'd0;
    always @ (posedge top.clk) begin
        if (top.femto.dbus_tmr_req && top.femto.dbus_wdata[31:8]=="INT")
            ext_int_from <= top.femto.dbus_wdata[3:0];
        else
            ext_int_from <= 4'd0;
    end
    assign top.femto.ext_int_from = ext_int_from;
