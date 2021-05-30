create_clock -period 83.333 -name SYSCLK -waveform {0.000 41.667} -add [get_ports sysclk]

## SRAM
# create_generated_clock -name SRAM_CLK -source [get_pins clk_gen/clk_out] -divide_by 2 [get_ports sram_we_bar]; # this clock doesn't actually exist dunno if it works
create_generated_clock -name SRAM_CLK -source [get_ports sysclk] -divide_by 2 [get_ports sram_we_bar]; # this clock doesn't actually exist dunno if it works

set_input_delay -clock [get_clocks SRAM_CLK] -min 0.034 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks SRAM_CLK] -max 5.334 [get_ports {sram_data[*]}]
