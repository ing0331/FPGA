--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
--Date        : Sat Dec  3 13:16:18 2022
--Host        : ACER-GLRMI5LB running 64-bit major release  (build 9200)
--Command     : generate_target VGA_pong_design_wrapper.bd
--Design      : VGA_pong_design_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity VGA_pong_design_wrapper is
end VGA_pong_design_wrapper;

architecture STRUCTURE of VGA_pong_design_wrapper is
  component VGA_pong_design is
  end component VGA_pong_design;
begin
VGA_pong_design_i: component VGA_pong_design
 ;
end STRUCTURE;
