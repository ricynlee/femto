`include "timescale.vh"

module uart_host(
    input wire  dut_uart_txd,
    output reg  dut_uart_rxd
);

    time bit_duration = 1000000000.0 / 57600;
    initial begin
        dut_uart_rxd = 1'b1;
        #200000;
        send(8'hc3);
    end

    task automatic send(input[7:0] octet);
        integer i;
        begin
            dut_uart_rxd = 1'b0;
            #bit_duration;
            for (i=0; i<8; i=i+1) begin
                dut_uart_rxd = octet[i];
                #bit_duration;
            end
            dut_uart_rxd = 1'b1;
            #bit_duration;
        end
    endtask

endmodule
