set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVCMOS33} [get_ports clock]
#switch 0
set_property -dict {PACKAGE_PIN F22 IOSTANDARD LVCMOS33} [get_ports {rst}]	
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS33} [get_ports {SW_img}]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports {SW_Harris}]
#U L R D
#set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {btn1[1]}]
#set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports {btn1[0]}]	

#pin37
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS33} [get_ports {o_VGA_HSync}]
set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS33} [get_ports {o_VGA_VSync}]

#LSB
set_property -dict {PACKAGE_PIN AA7 IOSTANDARD LVCMOS33} [get_ports {o_corner[0]}] 
set_property -dict {PACKAGE_PIN AB2 IOSTANDARD LVCMOS33} [get_ports {o_corner[1]}] 
set_property -dict {PACKAGE_PIN AB1 IOSTANDARD LVCMOS33} [get_ports {o_corner[2]}] 

set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS33} [get_ports {o_corner[3]}]
set_property -dict {PACKAGE_PIN AB9 IOSTANDARD LVCMOS33} [get_ports  {o_corner[4]}]
set_property -dict {PACKAGE_PIN AA6 IOSTANDARD LVCMOS33} [get_ports  {o_corner[5]}] 

set_property -dict {PACKAGE_PIN Y4 IOSTANDARD LVCMOS33} [get_ports  {o_corner[6]}]
set_property -dict {PACKAGE_PIN AA4 IOSTANDARD LVCMOS33} [get_ports {o_corner[7]}] 
#MSB
