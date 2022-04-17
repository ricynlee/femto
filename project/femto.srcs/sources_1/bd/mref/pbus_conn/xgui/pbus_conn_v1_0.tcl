# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "EIC_BASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "EIC_SPAN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "GPIO_BASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "GPIO_SPAN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RST_BASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RST_SPAN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TMR_BASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TMR_SPAN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "UART_BASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "UART_SPAN" -parent ${Page_0}


}

proc update_PARAM_VALUE.EIC_BASE { PARAM_VALUE.EIC_BASE } {
	# Procedure called to update EIC_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.EIC_BASE { PARAM_VALUE.EIC_BASE } {
	# Procedure called to validate EIC_BASE
	return true
}

proc update_PARAM_VALUE.EIC_SPAN { PARAM_VALUE.EIC_SPAN } {
	# Procedure called to update EIC_SPAN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.EIC_SPAN { PARAM_VALUE.EIC_SPAN } {
	# Procedure called to validate EIC_SPAN
	return true
}

proc update_PARAM_VALUE.GPIO_BASE { PARAM_VALUE.GPIO_BASE } {
	# Procedure called to update GPIO_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.GPIO_BASE { PARAM_VALUE.GPIO_BASE } {
	# Procedure called to validate GPIO_BASE
	return true
}

proc update_PARAM_VALUE.GPIO_SPAN { PARAM_VALUE.GPIO_SPAN } {
	# Procedure called to update GPIO_SPAN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.GPIO_SPAN { PARAM_VALUE.GPIO_SPAN } {
	# Procedure called to validate GPIO_SPAN
	return true
}

proc update_PARAM_VALUE.RST_BASE { PARAM_VALUE.RST_BASE } {
	# Procedure called to update RST_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RST_BASE { PARAM_VALUE.RST_BASE } {
	# Procedure called to validate RST_BASE
	return true
}

proc update_PARAM_VALUE.RST_SPAN { PARAM_VALUE.RST_SPAN } {
	# Procedure called to update RST_SPAN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RST_SPAN { PARAM_VALUE.RST_SPAN } {
	# Procedure called to validate RST_SPAN
	return true
}

proc update_PARAM_VALUE.TMR_BASE { PARAM_VALUE.TMR_BASE } {
	# Procedure called to update TMR_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TMR_BASE { PARAM_VALUE.TMR_BASE } {
	# Procedure called to validate TMR_BASE
	return true
}

proc update_PARAM_VALUE.TMR_SPAN { PARAM_VALUE.TMR_SPAN } {
	# Procedure called to update TMR_SPAN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TMR_SPAN { PARAM_VALUE.TMR_SPAN } {
	# Procedure called to validate TMR_SPAN
	return true
}

proc update_PARAM_VALUE.UART_BASE { PARAM_VALUE.UART_BASE } {
	# Procedure called to update UART_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UART_BASE { PARAM_VALUE.UART_BASE } {
	# Procedure called to validate UART_BASE
	return true
}

proc update_PARAM_VALUE.UART_SPAN { PARAM_VALUE.UART_SPAN } {
	# Procedure called to update UART_SPAN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UART_SPAN { PARAM_VALUE.UART_SPAN } {
	# Procedure called to validate UART_SPAN
	return true
}


proc update_MODELPARAM_VALUE.EIC_BASE { MODELPARAM_VALUE.EIC_BASE PARAM_VALUE.EIC_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.EIC_BASE}] ${MODELPARAM_VALUE.EIC_BASE}
}

proc update_MODELPARAM_VALUE.EIC_SPAN { MODELPARAM_VALUE.EIC_SPAN PARAM_VALUE.EIC_SPAN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.EIC_SPAN}] ${MODELPARAM_VALUE.EIC_SPAN}
}

proc update_MODELPARAM_VALUE.UART_BASE { MODELPARAM_VALUE.UART_BASE PARAM_VALUE.UART_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.UART_BASE}] ${MODELPARAM_VALUE.UART_BASE}
}

proc update_MODELPARAM_VALUE.UART_SPAN { MODELPARAM_VALUE.UART_SPAN PARAM_VALUE.UART_SPAN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.UART_SPAN}] ${MODELPARAM_VALUE.UART_SPAN}
}

proc update_MODELPARAM_VALUE.GPIO_BASE { MODELPARAM_VALUE.GPIO_BASE PARAM_VALUE.GPIO_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.GPIO_BASE}] ${MODELPARAM_VALUE.GPIO_BASE}
}

proc update_MODELPARAM_VALUE.GPIO_SPAN { MODELPARAM_VALUE.GPIO_SPAN PARAM_VALUE.GPIO_SPAN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.GPIO_SPAN}] ${MODELPARAM_VALUE.GPIO_SPAN}
}

proc update_MODELPARAM_VALUE.TMR_BASE { MODELPARAM_VALUE.TMR_BASE PARAM_VALUE.TMR_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TMR_BASE}] ${MODELPARAM_VALUE.TMR_BASE}
}

proc update_MODELPARAM_VALUE.TMR_SPAN { MODELPARAM_VALUE.TMR_SPAN PARAM_VALUE.TMR_SPAN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TMR_SPAN}] ${MODELPARAM_VALUE.TMR_SPAN}
}

proc update_MODELPARAM_VALUE.RST_BASE { MODELPARAM_VALUE.RST_BASE PARAM_VALUE.RST_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RST_BASE}] ${MODELPARAM_VALUE.RST_BASE}
}

proc update_MODELPARAM_VALUE.RST_SPAN { MODELPARAM_VALUE.RST_SPAN PARAM_VALUE.RST_SPAN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RST_SPAN}] ${MODELPARAM_VALUE.RST_SPAN}
}

