set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVCMOS33} [get_ports clock]
#set_property -dict {PACKAGE_PIN F22 IOSTANDARD LVCMOS33} [get_ports {rst}]	
#switch 0
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS33} [get_ports {SW_pattern[0]}]	
set_property -dict {PACKAGE_PIN H22 IOSTANDARD LVCMOS33} [get_ports {SW_pattern[1]}]	
set_property -dict {PACKAGE_PIN F21 IOSTANDARD LVCMOS33} [get_ports {SW_pattern[2]}]	
set_property -dict {PACKAGE_PIN H19 IOSTANDARD LVCMOS33} [get_ports {SW_pattern[3]}]	

#pin37
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS33} [get_ports {o_VGA_HSync}]
set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS33} [get_ports {o_VGA_VSync}]

set_property -dict {PACKAGE_PIN AA7 IOSTANDARD LVCMOS33} [get_ports {o_VGA_Red_0}] 
set_property -dict {PACKAGE_PIN AB2 IOSTANDARD LVCMOS33} [get_ports {o_VGA_Red_1}] 
set_property -dict {PACKAGE_PIN AB1 IOSTANDARD LVCMOS33} [get_ports {o_VGA_Red_2}] 
#set_property -dict {PACKAGE_PIN AB5 IOSTANDARD LVCMOS33} [get_ports {vga_r[3]}]  
#set_property -dict {PACKAGE_PIN AB4 IOSTANDARD LVCMOS33} [get_ports {vga_r[4]}]

set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS33} [get_ports {o_VGA_Grn_0}]
set_property -dict {PACKAGE_PIN AB9 IOSTANDARD LVCMOS33} [get_ports {o_VGA_Grn_1}]
set_property -dict {PACKAGE_PIN AA6 IOSTANDARD LVCMOS33} [get_ports {o_VGA_Grn_2}] 
#set_property -dict {PACKAGE_PIN Y11 IOSTANDARD LVCMOS33} [get_ports {vga_g[3]}] 
#set_property -dict {PACKAGE_PIN Y10 IOSTANDARD LVCMOS33} [get_ports {vga_g[4]}]  
#set_property -dict {PACKAGE_PIN AB6 IOSTANDARD LVCMOS33} [get_ports {vga_g[5]}]

set_property -dict {PACKAGE_PIN Y4 IOSTANDARD LVCMOS33} [get_ports {o_VGA_Blu_0}]
set_property -dict {PACKAGE_PIN AA4 IOSTANDARD LVCMOS33} [get_ports {o_VGA_Blu_1}]
set_property -dict {PACKAGE_PIN R6 IOSTANDARD LVCMOS33} [get_ports {o_VGA_Blu_2}] 
#set_property -dict {PACKAGE_PIN T6 IOSTANDARD LVCMOS33} [get_ports {vga_b[3]}] 
#set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS33} [get_ports {vga_b[4]}] 
