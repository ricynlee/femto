python3 bus_conn.py ibus_conn rom dbgtcm tcm sram nor
python3 bus_conn.py dbus_conn rom dbgtcm tcm sram nor qspi bridge
python3 bus_conn.py pbus_conn eic uart gpio tmr rst
python3 bus_split.py 10 REM aligned with RST_WIDTH
python3 bus_merge.py 2 REM aligned with RST_WIDTH

move *.v ..\imp\integration
