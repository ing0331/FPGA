set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVCMOS33} [get_ports clock]
set_property -dict {PACKAGE_PIN F22 IOSTANDARD LVCMOS33} [get_ports {rst}]	
#switch 0
#U L R D
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {btn1[1]}]
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports {btn1[0]}]	
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {btn2[1]}]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports {btn2[0]}]	

#pin37
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS33} [get_ports {o_VGA_HSync}]
set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS33} [get_ports {o_VGA_VSync}]

set_property -dict {PACKAGE_PIN AA7 IOSTANDARD LVCMOS33} [get_ports {o_VGA_Red[0]}] 
set_property -dict {PACKAGE_PIN AB2 IOSTANDARD LVCMOS33} [get_ports {o_VGA_Red[1]}] 
set_property -dict {PACKAGE_PIN AB1 IOSTANDARD LVCMOS33} [get_ports {o_VGA_Red[2]}] 

set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS33} [get_ports {o_VGA_Grn[0]}]
set_property -dict {PACKAGE_PIN AB9 IOSTANDARD LVCMOS33} [get_ports  {o_VGA_Grn[1]}]
set_property -dict {PACKAGE_PIN AA6 IOSTANDARD LVCMOS33} [get_ports  {o_VGA_Grn[2]}] 

set_property -dict {PACKAGE_PIN Y4 IOSTANDARD LVCMOS33} [get_ports  {o_VGA_Blu[0]}]
set_property -dict {PACKAGE_PIN AA4 IOSTANDARD LVCMOS33} [get_ports {o_VGA_Blu[1]}]
#set_property -dict {PACKAGE_PIN R6 IOSTANDARD LVCMOS33} [get_ports  {o_VGA_Blu[2]}] 
