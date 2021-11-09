create_generated_clock -name FEMTO_CLK -source [get_ports sysclk] -multiply_by 2 [get_pins femto/clk]

## SRAM
create_generated_clock -name SRAM_CLK -source [get_pins femto/clk] -divide_by 1 [get_ports sram_we_bar]
set_input_delay -clock [get_clocks SRAM_CLK] -min 0.034 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks SRAM_CLK] -max 5.334 [get_ports {sram_data[*]}]

## QSPI
create_generated_clock -name QSPI_SCK -source [get_pins femto/clk] -divide_by 1 [get_ports qspi_sck]
set_output_delay -clock [get_clocks QSPI_SCK] -min -3 [get_ports qspi_sck]
set_output_delay -clock [get_clocks QSPI_SCK] -max  2 [get_ports qspi_sck]
set_output_delay -clock [get_clocks QSPI_SCK] -min -3 [get_ports {qspi_sio[*]}]
set_output_delay -clock [get_clocks QSPI_SCK] -max  2 [get_ports {qspi_sio[*]}]
set_output_delay -clock [get_clocks QSPI_SCK] -min -3 [get_ports qspi_csb]
set_output_delay -clock [get_clocks QSPI_SCK] -max  2 [get_ports qspi_csb]
set_input_delay -clock [get_clocks QSPI_SCK] -min -0.5 [get_ports {qspi_sio[*]}]
set_input_delay -clock [get_clocks QSPI_SCK] -max 5.75 [get_ports {qspi_sio[*]}]



