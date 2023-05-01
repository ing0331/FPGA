set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVCMOS33} [get_ports i_Clk]
#set_property -dict {PACKAGE_PIN F22 IOSTANDARD LVCMOS33} [get_ports {rst}]	
#switch 0
#set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS33} [get_ports {SW[0]}]	
#set_property -dict {PACKAGE_PIN H22 IOSTANDARD LVCMOS33} [get_ports {SW[1]}]

#pin37
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS33} [get_ports {HSync}]
set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS33} [get_ports {VSync}]

set_property -dict {PACKAGE_PIN AA7 IOSTANDARD LVCMOS33} [get_ports {o_Red_Video[0]}] 
set_property -dict {PACKAGE_PIN AB2 IOSTANDARD LVCMOS33} [get_ports {o_Red_Video[1]}] 
set_property -dict {PACKAGE_PIN AB1 IOSTANDARD LVCMOS33} [get_ports {o_Red_Video[2]}] 

set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS33} [get_ports {o_Grn_Video[0]}]
set_property -dict {PACKAGE_PIN AB9 IOSTANDARD LVCMOS33} [get_ports  {o_Grn_Video[1]}]
set_property -dict {PACKAGE_PIN AA6 IOSTANDARD LVCMOS33} [get_ports  {o_Grn_Video[2]}] 

set_property -dict {PACKAGE_PIN Y4 IOSTANDARD LVCMOS33} [get_ports  {o_Blu_Video[0]}]
set_property -dict {PACKAGE_PIN AA4 IOSTANDARD LVCMOS33} [get_ports {o_Blu_Video[1]}]
#set_property -dict {PACKAGE_PIN R6 IOSTANDARD LVCMOS33} [get_ports  {o_Blu_Video[2]}] 
