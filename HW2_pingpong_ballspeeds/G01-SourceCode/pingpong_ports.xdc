set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVCMOS33} [get_ports clock]

set_property -dict {PACKAGE_PIN F22 IOSTANDARD LVCMOS33} [get_ports reset]	 
#switch 0

set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {bottom1}]	
#btn down
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports {bottom2}]	
#btn up
	#score1 GPIO to seg1
set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS33} [get_ports {score1_out[6]}] 
set_property -dict {PACKAGE_PIN T6 IOSTANDARD LVCMOS33} [get_ports {score1_out[5]}]
set_property -dict {PACKAGE_PIN R6 IOSTANDARD LVCMOS33} [get_ports {score1_out[4]}]
set_property -dict {PACKAGE_PIN AA4 IOSTANDARD LVCMOS33} [get_ports {score1_out[3]}]
set_property -dict {PACKAGE_PIN Y4 IOSTANDARD LVCMOS33} [get_ports {score1_out[2]}] 
set_property -dict {PACKAGE_PIN AB6 IOSTANDARD LVCMOS33} [get_ports {score1_out[1]}] 
set_property -dict {PACKAGE_PIN Y10 IOSTANDARD LVCMOS33} [get_ports {score1_out[0]}] 

	#score2 GPIO to seg2   from GPIO 10
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS33} [get_ports {score2_out[6]}]
set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS33} [get_ports {score2_out[5]}]
set_property -dict {PACKAGE_PIN AA7 IOSTANDARD LVCMOS33} [get_ports {score2_out[4]}]
set_property -dict {PACKAGE_PIN AB2 IOSTANDARD LVCMOS33} [get_ports {score2_out[3]}]
set_property -dict {PACKAGE_PIN AB1 IOSTANDARD LVCMOS33} [get_ports {score2_out[2]}]
set_property -dict {PACKAGE_PIN AB5 IOSTANDARD LVCMOS33} [get_ports {score2_out[1]}]
set_property -dict {PACKAGE_PIN AB7 IOSTANDARD LVCMOS33} [get_ports {score2_out[0]}]  


set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {led_out[7]}]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {led_out[6]}]
set_property -dict {PACKAGE_PIN W22 IOSTANDARD LVCMOS33} [get_ports {led_out[5]}]
set_property -dict {PACKAGE_PIN V22 IOSTANDARD LVCMOS33} [get_ports {led_out[4]}]
set_property -dict {PACKAGE_PIN U21 IOSTANDARD LVCMOS33} [get_ports {led_out[3]}]
set_property -dict {PACKAGE_PIN U22 IOSTANDARD LVCMOS33} [get_ports {led_out[2]}]
set_property -dict {PACKAGE_PIN T21 IOSTANDARD LVCMOS33} [get_ports {led_out[1]}]
set_property -dict {PACKAGE_PIN T22 IOSTANDARD LVCMOS33} [get_ports {led_out[0]}]