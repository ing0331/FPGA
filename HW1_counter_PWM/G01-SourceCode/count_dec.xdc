#set_property PACKAGE_PIN Y9 [get_ports {clock}];  # "GCLK"
set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVCMOS33} [get_ports clock]

#set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {counter_output[7]}]
#set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {counter_output[6]}]
#set_property -dict {PACKAGE_PIN W22 IOSTANDARD LVCMOS33} [get_ports {counter_output[5]}]
#set_property -dict {PACKAGE_PIN V22 IOSTANDARD LVCMOS33} [get_ports {counter_output[4]}]
set_property -dict {PACKAGE_PIN U21 IOSTANDARD LVCMOS33} [get_ports {counter_output[3]}]
set_property -dict {PACKAGE_PIN U22 IOSTANDARD LVCMOS33} [get_ports {counter_output[2]}]
set_property -dict {PACKAGE_PIN T21 IOSTANDARD LVCMOS33} [get_ports {counter_output[1]}]
set_property -dict {PACKAGE_PIN T22 IOSTANDARD LVCMOS33} [get_ports {counter_output[0]}]

set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports reset]
set_property -dict {PACKAGE_PIN F22 IOSTANDARD LVCMOS33} [get_ports sel]

#//segment
set_property -dict {PACKAGE_PIN U10 IOSTANDARD LVCMOS33} [get_ports {out_segment[6]}]
set_property -dict {PACKAGE_PIN U9 IOSTANDARD LVCMOS33} [get_ports {out_segment[5]}]
set_property -dict {PACKAGE_PIN AA12 IOSTANDARD LVCMOS33} [get_ports {out_segment[4]}]
set_property -dict {PACKAGE_PIN W12 IOSTANDARD LVCMOS33} [get_ports {out_segment[3]}]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {out_segment[2]}]
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports {out_segment[1]}]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {out_segment[0]}]

