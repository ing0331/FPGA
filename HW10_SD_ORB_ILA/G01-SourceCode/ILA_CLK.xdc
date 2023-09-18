

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------
set_property IOSTANDARD LVCMOS33 [get_ports PL_CLK]
set_property PACKAGE_PIN Y9 [get_ports PL_CLK]
set_property CLOCK_DEDICATED_ROUTE TRUE [get_nets PL_CLK]

set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports btn_rst_0]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports button_1_0]
#BTNU PL T18
#BTNR PL R18
#BTND PL R16
#BTNC PL P16
#BTNL PL N15
#SW0 F22
#SW1 G22
#SW2 H22
#SW3 F21
#SW4 H19
#SW5 H18
#SW6 H17
#SW7 M15
#----------------------------------------------------------------------------------------------

# "VGA-HS" #
set_property IOSTANDARD LVCMOS33 [get_ports hsync]
set_property PACKAGE_PIN AA19 [get_ports hsync]
# "VGA-VS" #
set_property IOSTANDARD LVCMOS33 [get_ports vsync]
set_property PACKAGE_PIN Y19 [get_ports vsync]

# "VGA-B1" #
set_property IOSTANDARD LVCMOS33 [get_ports {b_out[0]}]
set_property PACKAGE_PIN Y21 [get_ports {b_out[0]}]
# "VGA-B2" #
set_property IOSTANDARD LVCMOS33 [get_ports {b_out[1]}]
set_property PACKAGE_PIN Y20 [get_ports {b_out[1]}]
# "VGA-B3" #0
set_property IOSTANDARD LVCMOS33 [get_ports {b_out[2]}]
set_property PACKAGE_PIN AB20 [get_ports {b_out[2]}]
# "VGA-B4" #
set_property IOSTANDARD LVCMOS33 [get_ports {b_out[3]}]
set_property PACKAGE_PIN AB19 [get_ports {b_out[3]}]
# "VGA-G1" #
set_property IOSTANDARD LVCMOS33 [get_ports {g_out[0]}]
set_property PACKAGE_PIN AB22 [get_ports {g_out[0]}]
# "VGA-G2" #
set_property IOSTANDARD LVCMOS33 [get_ports {g_out[1]}]
set_property PACKAGE_PIN AA22 [get_ports {g_out[1]}]
# "VGA-G3" #
set_property IOSTANDARD LVCMOS33 [get_ports {g_out[2]}]
set_property PACKAGE_PIN AB21 [get_ports {g_out[2]}]
# "VGA-G4" #
set_property IOSTANDARD LVCMOS33 [get_ports {g_out[3]}]
set_property PACKAGE_PIN AA21 [get_ports {g_out[3]}]
# "VGA-R1" #
set_property IOSTANDARD LVCMOS33 [get_ports {r_out[0]}]
set_property PACKAGE_PIN V20 [get_ports {r_out[0]}]
# "VGA-R2" #
set_property IOSTANDARD LVCMOS33 [get_ports {r_out[1]}]
set_property PACKAGE_PIN U20 [get_ports {r_out[1]}]
# "VGA-R3" #
set_property IOSTANDARD LVCMOS33 [get_ports {r_out[2]}]
set_property PACKAGE_PIN V19 [get_ports {r_out[2]}]
# "VGA-R4" #
set_property IOSTANDARD LVCMOS33 [get_ports {r_out[3]}]
set_property PACKAGE_PIN V18 [get_ports {r_out[3]}]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 2 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 16384 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list PL_CLK_IBUF_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 8 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {design_1_i/top_0/rot_data_rom[0]} {design_1_i/top_0/rot_data_rom[1]} {design_1_i/top_0/rot_data_rom[2]} {design_1_i/top_0/rot_data_rom[3]} {design_1_i/top_0/rot_data_rom[4]} {design_1_i/top_0/rot_data_rom[5]} {design_1_i/top_0/rot_data_rom[6]} {design_1_i/top_0/rot_data_rom[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {design_1_i/blk_mem_gen_1/doutb[0]} {design_1_i/blk_mem_gen_1/doutb[1]} {design_1_i/blk_mem_gen_1/doutb[2]} {design_1_i/blk_mem_gen_1/doutb[3]} {design_1_i/blk_mem_gen_1/doutb[4]} {design_1_i/blk_mem_gen_1/doutb[5]} {design_1_i/blk_mem_gen_1/doutb[6]} {design_1_i/blk_mem_gen_1/doutb[7]} {design_1_i/blk_mem_gen_1/doutb[8]} {design_1_i/blk_mem_gen_1/doutb[9]} {design_1_i/blk_mem_gen_1/doutb[10]} {design_1_i/blk_mem_gen_1/doutb[11]} {design_1_i/blk_mem_gen_1/doutb[12]} {design_1_i/blk_mem_gen_1/doutb[13]} {design_1_i/blk_mem_gen_1/doutb[14]} {design_1_i/blk_mem_gen_1/doutb[15]} {design_1_i/blk_mem_gen_1/doutb[16]} {design_1_i/blk_mem_gen_1/doutb[17]} {design_1_i/blk_mem_gen_1/doutb[18]} {design_1_i/blk_mem_gen_1/doutb[19]} {design_1_i/blk_mem_gen_1/doutb[20]} {design_1_i/blk_mem_gen_1/doutb[21]} {design_1_i/blk_mem_gen_1/doutb[22]} {design_1_i/blk_mem_gen_1/doutb[23]} {design_1_i/blk_mem_gen_1/doutb[24]} {design_1_i/blk_mem_gen_1/doutb[25]} {design_1_i/blk_mem_gen_1/doutb[26]} {design_1_i/blk_mem_gen_1/doutb[27]} {design_1_i/blk_mem_gen_1/doutb[28]} {design_1_i/blk_mem_gen_1/doutb[29]} {design_1_i/blk_mem_gen_1/doutb[30]} {design_1_i/blk_mem_gen_1/doutb[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 12 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {design_1_i/blk_mem_gen_1/addrb[2]} {design_1_i/blk_mem_gen_1/addrb[3]} {design_1_i/blk_mem_gen_1/addrb[4]} {design_1_i/blk_mem_gen_1/addrb[5]} {design_1_i/blk_mem_gen_1/addrb[6]} {design_1_i/blk_mem_gen_1/addrb[7]} {design_1_i/blk_mem_gen_1/addrb[8]} {design_1_i/blk_mem_gen_1/addrb[9]} {design_1_i/blk_mem_gen_1/addrb[10]} {design_1_i/blk_mem_gen_1/addrb[11]} {design_1_i/blk_mem_gen_1/addrb[12]} {design_1_i/blk_mem_gen_1/addrb[13]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 40 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {design_1_i/top_0/U0/match_0/U0/doutb[0]} {design_1_i/top_0/U0/match_0/U0/doutb[1]} {design_1_i/top_0/U0/match_0/U0/doutb[2]} {design_1_i/top_0/U0/match_0/U0/doutb[3]} {design_1_i/top_0/U0/match_0/U0/doutb[4]} {design_1_i/top_0/U0/match_0/U0/doutb[5]} {design_1_i/top_0/U0/match_0/U0/doutb[6]} {design_1_i/top_0/U0/match_0/U0/doutb[7]} {design_1_i/top_0/U0/match_0/U0/doutb[8]} {design_1_i/top_0/U0/match_0/U0/doutb[9]} {design_1_i/top_0/U0/match_0/U0/doutb[10]} {design_1_i/top_0/U0/match_0/U0/doutb[11]} {design_1_i/top_0/U0/match_0/U0/doutb[12]} {design_1_i/top_0/U0/match_0/U0/doutb[13]} {design_1_i/top_0/U0/match_0/U0/doutb[14]} {design_1_i/top_0/U0/match_0/U0/doutb[15]} {design_1_i/top_0/U0/match_0/U0/doutb[16]} {design_1_i/top_0/U0/match_0/U0/doutb[17]} {design_1_i/top_0/U0/match_0/U0/doutb[18]} {design_1_i/top_0/U0/match_0/U0/doutb[19]} {design_1_i/top_0/U0/match_0/U0/doutb[20]} {design_1_i/top_0/U0/match_0/U0/doutb[21]} {design_1_i/top_0/U0/match_0/U0/doutb[22]} {design_1_i/top_0/U0/match_0/U0/doutb[23]} {design_1_i/top_0/U0/match_0/U0/doutb[24]} {design_1_i/top_0/U0/match_0/U0/doutb[25]} {design_1_i/top_0/U0/match_0/U0/doutb[26]} {design_1_i/top_0/U0/match_0/U0/doutb[27]} {design_1_i/top_0/U0/match_0/U0/doutb[28]} {design_1_i/top_0/U0/match_0/U0/doutb[29]} {design_1_i/top_0/U0/match_0/U0/doutb[30]} {design_1_i/top_0/U0/match_0/U0/doutb[31]} {design_1_i/top_0/U0/match_0/U0/doutb[32]} {design_1_i/top_0/U0/match_0/U0/doutb[33]} {design_1_i/top_0/U0/match_0/U0/doutb[34]} {design_1_i/top_0/U0/match_0/U0/doutb[35]} {design_1_i/top_0/U0/match_0/U0/doutb[36]} {design_1_i/top_0/U0/match_0/U0/doutb[37]} {design_1_i/top_0/U0/match_0/U0/doutb[38]} {design_1_i/top_0/U0/match_0/U0/doutb[39]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets PL_CLK_IBUF_BUFG]
