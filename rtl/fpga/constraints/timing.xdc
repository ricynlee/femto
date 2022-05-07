## SRAM ##########################################################################################################
create_clock -name sram_drv_clk -period 41.667
create_generated_clock -name sram_addr0_clk  -source [get_pins clk_gen/clk_out] -divide_by 1 [get_ports {sram_addr[0]} ]
create_generated_clock -name sram_addr1_clk  -source [get_pins clk_gen/clk_out] -divide_by 1 [get_ports {sram_addr[1]} ]
create_generated_clock -name sram_addr2_clk  -source [get_pins clk_gen/clk_out] -divide_by 1 [get_ports {sram_addr[2]} ]
create_generated_clock -name sram_addr3_clk  -source [get_pins clk_gen/clk_out] -divide_by 1 [get_ports {sram_addr[3]} ]
create_generated_clock -name sram_addr4_clk  -source [get_pins clk_gen/clk_out] -divide_by 1 [get_ports {sram_addr[4]} ]
create_generated_clock -name sram_addr5_clk  -source [get_pins clk_gen/clk_out] -divide_by 1 [get_ports {sram_addr[5]} ]
create_generated_clock -name sram_addr6_clk  -source [get_pins clk_gen/clk_out] -divide_by 1 [get_ports {sram_addr[6]} ]
create_generated_clock -name sram_addr7_clk  -source [get_pins clk_gen/clk_out] -divide_by 1 [get_ports {sram_addr[7]} ]
create_generated_clock -name sram_addr8_clk  -source [get_pins clk_gen/clk_out] -divide_by 1 [get_ports {sram_addr[8]} ]
create_generated_clock -name sram_addr9_clk  -source [get_pins clk_gen/clk_out] -divide_by 1 [get_ports {sram_addr[9]} ]
create_generated_clock -name sram_addr10_clk -source [get_pins clk_gen/clk_out] -divide_by 1 [get_ports {sram_addr[10]}]
create_generated_clock -name sram_addr11_clk -source [get_pins clk_gen/clk_out] -divide_by 1 [get_ports {sram_addr[11]}]
create_generated_clock -name sram_addr12_clk -source [get_pins clk_gen/clk_out] -divide_by 1 [get_ports {sram_addr[12]}]
create_generated_clock -name sram_addr13_clk -source [get_pins clk_gen/clk_out] -divide_by 1 [get_ports {sram_addr[13]}]
create_generated_clock -name sram_addr14_clk -source [get_pins clk_gen/clk_out] -divide_by 1 [get_ports {sram_addr[14]}]
create_generated_clock -name sram_addr15_clk -source [get_pins clk_gen/clk_out] -divide_by 1 [get_ports {sram_addr[15]}]

# setup required = 0
# hold required = 10
set_output_delay -clock [get_clocks sram_drv_clk] -min -10 [get_ports {sram_data[*]}]
set_output_delay -clock [get_clocks sram_drv_clk] -max   0 [get_ports {sram_data[*]}]
set_output_delay -clock [get_clocks sram_drv_clk] -min -10 [get_ports {sram_addr[*]}]
set_output_delay -clock [get_clocks sram_drv_clk] -max   0 [get_ports {sram_addr[*]}]
set_output_delay -clock [get_clocks sram_drv_clk] -min -10 [get_ports {sram_we_bar }]
set_output_delay -clock [get_clocks sram_drv_clk] -max   0 [get_ports {sram_we_bar }]

# trace delay = 0.067ns
# max clock to output = 10ns
set_input_delay -clock [get_clocks sram_addr0_clk ] -min  0.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr0_clk ] -max 10.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr1_clk ] -min  0.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr1_clk ] -max 10.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr2_clk ] -min  0.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr2_clk ] -max 10.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr3_clk ] -min  0.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr3_clk ] -max 10.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr4_clk ] -min  0.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr4_clk ] -max 10.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr5_clk ] -min  0.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr5_clk ] -max 10.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr6_clk ] -min  0.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr6_clk ] -max 10.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr7_clk ] -min  0.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr7_clk ] -max 10.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr8_clk ] -min  0.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr8_clk ] -max 10.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr9_clk ] -min  0.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr9_clk ] -max 10.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr10_clk] -min  0.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr10_clk] -max 10.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr11_clk] -min  0.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr11_clk] -max 10.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr12_clk] -min  0.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr12_clk] -max 10.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr13_clk] -min  0.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr13_clk] -max 10.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr14_clk] -min  0.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr14_clk] -max 10.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr15_clk] -min  0.133 [get_ports {sram_data[*]}]
set_input_delay -clock [get_clocks sram_addr15_clk] -max 10.133 [get_ports {sram_data[*]}]

## QSPI ##########################################################################################################

# min cs setup = 5 ns
# min cs hold = 5 ns
# min data setup = 2 ns
# min data hold = 3 ns
# trace delay = 0.333 ns
# max clock to output = 6 ns

create_clock -name qspi_drv_clk -period 41.667
set_output_delay -clock [get_clocks qspi_drv_clk] -min -3 [get_ports {qspi_sio[*]}]
set_output_delay -clock [get_clocks qspi_drv_clk] -max  2 [get_ports {qspi_sio[*]}]
set_output_delay -clock [get_clocks qspi_drv_clk] -min -5 [get_ports qspi_csb]
set_output_delay -clock [get_clocks qspi_drv_clk] -max  5 [get_ports qspi_csb]

create_generated_clock -name qspi_sck -source [get_pins clk_gen/clk_out] -divide_by 2 -invert [get_ports qspi_sck]
set_input_delay -clock [get_clocks qspi_sck] -min 0.667 [get_ports {qspi_sio[*]}]
set_input_delay -clock [get_clocks qspi_sck] -max 6.667 [get_ports {qspi_sio[*]}]

## False path: from Femto's clock ################################################################################
set_false_path -from [get_clocks -of_objects [get_nets clk]] -to [get_clocks sram_drv_clk]

set_false_path -from [get_clocks sram_addr0_clk ] -to [get_clocks sram_drv_clk]
set_false_path -from [get_clocks sram_addr1_clk ] -to [get_clocks sram_drv_clk]
set_false_path -from [get_clocks sram_addr2_clk ] -to [get_clocks sram_drv_clk]
set_false_path -from [get_clocks sram_addr3_clk ] -to [get_clocks sram_drv_clk]
set_false_path -from [get_clocks sram_addr4_clk ] -to [get_clocks sram_drv_clk]
set_false_path -from [get_clocks sram_addr5_clk ] -to [get_clocks sram_drv_clk]
set_false_path -from [get_clocks sram_addr6_clk ] -to [get_clocks sram_drv_clk]
set_false_path -from [get_clocks sram_addr7_clk ] -to [get_clocks sram_drv_clk]
set_false_path -from [get_clocks sram_addr8_clk ] -to [get_clocks sram_drv_clk]
set_false_path -from [get_clocks sram_addr9_clk ] -to [get_clocks sram_drv_clk]
set_false_path -from [get_clocks sram_addr10_clk] -to [get_clocks sram_drv_clk]
set_false_path -from [get_clocks sram_addr11_clk] -to [get_clocks sram_drv_clk]
set_false_path -from [get_clocks sram_addr12_clk] -to [get_clocks sram_drv_clk]
set_false_path -from [get_clocks sram_addr13_clk] -to [get_clocks sram_drv_clk]
set_false_path -from [get_clocks sram_addr14_clk] -to [get_clocks sram_drv_clk]
set_false_path -from [get_clocks sram_addr15_clk] -to [get_clocks sram_drv_clk]

set_false_path -from [get_clocks -of_objects [get_nets clk]] -to [get_clocks qspi_drv_clk]
