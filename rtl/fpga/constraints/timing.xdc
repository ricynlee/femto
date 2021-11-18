## SRAM
create_clock -name SRAM_CLK -period 41.667
set_input_delay -clock [get_clocks SRAM_CLK] -min 0.034 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks SRAM_CLK] -max 5.334 [get_ports {sram_data[*]}]

set_output_delay -clock [get_clocks SRAM_CLK] -min -2 [get_ports {sram_data[*]}]
set_output_delay -clock [get_clocks SRAM_CLK] -max  2 [get_ports {sram_data[*]}]
set_output_delay -clock [get_clocks SRAM_CLK] -min -2 [get_ports {sram_addr[*]}]
set_output_delay -clock [get_clocks SRAM_CLK] -max  2 [get_ports {sram_addr[*]}]

## QSPI
create_clock -name QSPI_SCK -period 41.667
set_output_delay -clock [get_clocks QSPI_SCK] -min -3 [get_ports qspi_sck]
set_output_delay -clock [get_clocks QSPI_SCK] -max  2 [get_ports qspi_sck]
set_output_delay -clock [get_clocks QSPI_SCK] -min -3 [get_ports {qspi_sio[*]}]
set_output_delay -clock [get_clocks QSPI_SCK] -max  2 [get_ports {qspi_sio[*]}]
set_output_delay -clock [get_clocks QSPI_SCK] -min -3 [get_ports qspi_csb]
set_output_delay -clock [get_clocks QSPI_SCK] -max  2 [get_ports qspi_csb]

set_input_delay -clock [get_clocks QSPI_SCK] -min -0.5 [get_ports {qspi_sio[*]}]
set_input_delay -clock [get_clocks QSPI_SCK] -max 5.75 [get_ports {qspi_sio[*]}]

## False path: from Femto's clock
set_false_path -from [get_clocks -of_objects [get_nets clk]] -to [get_clocks SRAM_CLK]
set_false_path -from [get_clocks -of_objects [get_nets clk]] -to [get_clocks QSPI_SCK]
