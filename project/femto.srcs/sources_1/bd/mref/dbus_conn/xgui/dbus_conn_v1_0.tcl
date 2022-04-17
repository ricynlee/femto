# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "BRIDGE_BASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BRIDGE_SPAN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NOR_BASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NOR_SPAN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "QSPI_BASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "QSPI_SPAN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ROM_BASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ROM_SPAN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SRAM_BASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SRAM_SPAN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TCM_BASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TCM_SPAN" -parent ${Page_0}


}

proc update_PARAM_VALUE.BRIDGE_BASE { PARAM_VALUE.BRIDGE_BASE } {
	# Procedure called to update BRIDGE_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BRIDGE_BASE { PARAM_VALUE.BRIDGE_BASE } {
	# Procedure called to validate BRIDGE_BASE
	return true
}

proc update_PARAM_VALUE.BRIDGE_SPAN { PARAM_VALUE.BRIDGE_SPAN } {
	# Procedure called to update BRIDGE_SPAN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BRIDGE_SPAN { PARAM_VALUE.BRIDGE_SPAN } {
	# Procedure called to validate BRIDGE_SPAN
	return true
}

proc update_PARAM_VALUE.NOR_BASE { PARAM_VALUE.NOR_BASE } {
	# Procedure called to update NOR_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NOR_BASE { PARAM_VALUE.NOR_BASE } {
	# Procedure called to validate NOR_BASE
	return true
}

proc update_PARAM_VALUE.NOR_SPAN { PARAM_VALUE.NOR_SPAN } {
	# Procedure called to update NOR_SPAN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NOR_SPAN { PARAM_VALUE.NOR_SPAN } {
	# Procedure called to validate NOR_SPAN
	return true
}

proc update_PARAM_VALUE.QSPI_BASE { PARAM_VALUE.QSPI_BASE } {
	# Procedure called to update QSPI_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.QSPI_BASE { PARAM_VALUE.QSPI_BASE } {
	# Procedure called to validate QSPI_BASE
	return true
}

proc update_PARAM_VALUE.QSPI_SPAN { PARAM_VALUE.QSPI_SPAN } {
	# Procedure called to update QSPI_SPAN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.QSPI_SPAN { PARAM_VALUE.QSPI_SPAN } {
	# Procedure called to validate QSPI_SPAN
	return true
}

proc update_PARAM_VALUE.ROM_BASE { PARAM_VALUE.ROM_BASE } {
	# Procedure called to update ROM_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ROM_BASE { PARAM_VALUE.ROM_BASE } {
	# Procedure called to validate ROM_BASE
	return true
}

proc update_PARAM_VALUE.ROM_SPAN { PARAM_VALUE.ROM_SPAN } {
	# Procedure called to update ROM_SPAN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ROM_SPAN { PARAM_VALUE.ROM_SPAN } {
	# Procedure called to validate ROM_SPAN
	return true
}

proc update_PARAM_VALUE.SRAM_BASE { PARAM_VALUE.SRAM_BASE } {
	# Procedure called to update SRAM_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SRAM_BASE { PARAM_VALUE.SRAM_BASE } {
	# Procedure called to validate SRAM_BASE
	return true
}

proc update_PARAM_VALUE.SRAM_SPAN { PARAM_VALUE.SRAM_SPAN } {
	# Procedure called to update SRAM_SPAN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SRAM_SPAN { PARAM_VALUE.SRAM_SPAN } {
	# Procedure called to validate SRAM_SPAN
	return true
}

proc update_PARAM_VALUE.TCM_BASE { PARAM_VALUE.TCM_BASE } {
	# Procedure called to update TCM_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TCM_BASE { PARAM_VALUE.TCM_BASE } {
	# Procedure called to validate TCM_BASE
	return true
}

proc update_PARAM_VALUE.TCM_SPAN { PARAM_VALUE.TCM_SPAN } {
	# Procedure called to update TCM_SPAN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TCM_SPAN { PARAM_VALUE.TCM_SPAN } {
	# Procedure called to validate TCM_SPAN
	return true
}


proc update_MODELPARAM_VALUE.ROM_BASE { MODELPARAM_VALUE.ROM_BASE PARAM_VALUE.ROM_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ROM_BASE}] ${MODELPARAM_VALUE.ROM_BASE}
}

proc update_MODELPARAM_VALUE.ROM_SPAN { MODELPARAM_VALUE.ROM_SPAN PARAM_VALUE.ROM_SPAN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ROM_SPAN}] ${MODELPARAM_VALUE.ROM_SPAN}
}

proc update_MODELPARAM_VALUE.TCM_BASE { MODELPARAM_VALUE.TCM_BASE PARAM_VALUE.TCM_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TCM_BASE}] ${MODELPARAM_VALUE.TCM_BASE}
}

proc update_MODELPARAM_VALUE.TCM_SPAN { MODELPARAM_VALUE.TCM_SPAN PARAM_VALUE.TCM_SPAN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TCM_SPAN}] ${MODELPARAM_VALUE.TCM_SPAN}
}

proc update_MODELPARAM_VALUE.SRAM_BASE { MODELPARAM_VALUE.SRAM_BASE PARAM_VALUE.SRAM_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SRAM_BASE}] ${MODELPARAM_VALUE.SRAM_BASE}
}

proc update_MODELPARAM_VALUE.SRAM_SPAN { MODELPARAM_VALUE.SRAM_SPAN PARAM_VALUE.SRAM_SPAN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SRAM_SPAN}] ${MODELPARAM_VALUE.SRAM_SPAN}
}

proc update_MODELPARAM_VALUE.NOR_BASE { MODELPARAM_VALUE.NOR_BASE PARAM_VALUE.NOR_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NOR_BASE}] ${MODELPARAM_VALUE.NOR_BASE}
}

proc update_MODELPARAM_VALUE.NOR_SPAN { MODELPARAM_VALUE.NOR_SPAN PARAM_VALUE.NOR_SPAN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NOR_SPAN}] ${MODELPARAM_VALUE.NOR_SPAN}
}

proc update_MODELPARAM_VALUE.QSPI_BASE { MODELPARAM_VALUE.QSPI_BASE PARAM_VALUE.QSPI_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.QSPI_BASE}] ${MODELPARAM_VALUE.QSPI_BASE}
}

proc update_MODELPARAM_VALUE.QSPI_SPAN { MODELPARAM_VALUE.QSPI_SPAN PARAM_VALUE.QSPI_SPAN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.QSPI_SPAN}] ${MODELPARAM_VALUE.QSPI_SPAN}
}

proc update_MODELPARAM_VALUE.BRIDGE_BASE { MODELPARAM_VALUE.BRIDGE_BASE PARAM_VALUE.BRIDGE_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BRIDGE_BASE}] ${MODELPARAM_VALUE.BRIDGE_BASE}
}

proc update_MODELPARAM_VALUE.BRIDGE_SPAN { MODELPARAM_VALUE.BRIDGE_SPAN PARAM_VALUE.BRIDGE_SPAN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BRIDGE_SPAN}] ${MODELPARAM_VALUE.BRIDGE_SPAN}
}

