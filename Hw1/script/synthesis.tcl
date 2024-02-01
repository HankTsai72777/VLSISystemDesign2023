read_file -format sverilog {../src/top.sv}
current_design top
source ../script/DC.sdc 

check_design
compile -exact_map -map_effort high

report_timing
write -hierarchy -format verilog -output ../syn/top_syn.v
write_sdf -version 2.1 -context verilog -load_delay net ../syn/top_syn.sdf
report_timing > ../syn/timing.log
report_area > ../syn/area.log
report_power > ../syn/power.log
report_qor > ../syn/qor.log
exit