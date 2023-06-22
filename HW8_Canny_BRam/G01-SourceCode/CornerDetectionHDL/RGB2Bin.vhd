-- -------------------------------------------------------------
-- 
-- File Name: hdlsrc\CornerDetectionHDL\RGB2Bin.vhd
-- Created: 2023-06-21 14:30:32
-- 
-- Generated by MATLAB 9.14 and HDL Coder 4.1
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: RGB2Bin
-- Source Path: CornerDetectionHDL/HDL Corner Algorithm/RGB2Bin
-- Hierarchy Level: 1
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.HDL_Corner_Algorithm_pkg.ALL;

ENTITY RGB2Bin IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        pixelIn                           :   IN    vector_of_std_logic_vector8(0 TO 2);  -- uint8 [3]
        ctrlIn_hStart                     :   IN    std_logic;
        ctrlIn_hEnd                       :   IN    std_logic;
        ctrlIn_vStart                     :   IN    std_logic;
        ctrlIn_vEnd                       :   IN    std_logic;
        ctrlIn_valid                      :   IN    std_logic;
        SliceLevel                        :   IN    std_logic_vector(7 DOWNTO 0);  -- uint8
        pixelOut                          :   OUT   std_logic_vector(7 DOWNTO 0);  -- uint8
        ctrlOut_hStart                    :   OUT   std_logic;
        ctrlOut_hEnd                      :   OUT   std_logic;
        ctrlOut_vStart                    :   OUT   std_logic;
        ctrlOut_vEnd                      :   OUT   std_logic;
        ctrlOut_valid                     :   OUT   std_logic
        );
END RGB2Bin;


ARCHITECTURE rtl OF RGB2Bin IS

  -- Component Declarations
  COMPONENT Color_Space_Converter
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          in0                             :   IN    vector_of_std_logic_vector8(0 TO 2);  -- uint8 [3]
          in1_hStart                      :   IN    std_logic;
          in1_hEnd                        :   IN    std_logic;
          in1_vStart                      :   IN    std_logic;
          in1_vEnd                        :   IN    std_logic;
          in1_valid                       :   IN    std_logic;
          out0                            :   OUT   std_logic_vector(7 DOWNTO 0);  -- uint8
          out1_hStart                     :   OUT   std_logic;
          out1_hEnd                       :   OUT   std_logic;
          out1_vStart                     :   OUT   std_logic;
          out1_vEnd                       :   OUT   std_logic;
          out1_valid                      :   OUT   std_logic
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : Color_Space_Converter
    USE ENTITY work.Color_Space_Converter(rtl);

  -- Signals
  SIGNAL Color_Space_Converter_out1       : std_logic_vector(7 DOWNTO 0);  -- ufix8
  SIGNAL Color_Space_Converter_out2_hStart : std_logic;
  SIGNAL Color_Space_Converter_out2_hEnd  : std_logic;
  SIGNAL Color_Space_Converter_out2_vStart : std_logic;
  SIGNAL Color_Space_Converter_out2_vEnd  : std_logic;
  SIGNAL Color_Space_Converter_out2_valid : std_logic;
  SIGNAL Color_Space_Converter_out1_unsigned : unsigned(7 DOWNTO 0);  -- uint8
  SIGNAL SliceLevel_unsigned              : unsigned(7 DOWNTO 0);  -- uint8
  SIGNAL Relational_Operator_relop1       : std_logic;
  SIGNAL Constant1_out1                   : unsigned(7 DOWNTO 0);  -- uint8
  SIGNAL Constant_out1                    : unsigned(7 DOWNTO 0);  -- uint8
  SIGNAL Switch_out1                      : unsigned(7 DOWNTO 0);  -- uint8

BEGIN
  u_Color_Space_Converter : Color_Space_Converter
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              in0 => pixelIn,  -- uint8 [3]
              in1_hStart => ctrlIn_hStart,
              in1_hEnd => ctrlIn_hEnd,
              in1_vStart => ctrlIn_vStart,
              in1_vEnd => ctrlIn_vEnd,
              in1_valid => ctrlIn_valid,
              out0 => Color_Space_Converter_out1,  -- uint8
              out1_hStart => Color_Space_Converter_out2_hStart,
              out1_hEnd => Color_Space_Converter_out2_hEnd,
              out1_vStart => Color_Space_Converter_out2_vStart,
              out1_vEnd => Color_Space_Converter_out2_vEnd,
              out1_valid => Color_Space_Converter_out2_valid
              );

  Color_Space_Converter_out1_unsigned <= unsigned(Color_Space_Converter_out1);

  SliceLevel_unsigned <= unsigned(SliceLevel);

  
  Relational_Operator_relop1 <= '1' WHEN Color_Space_Converter_out1_unsigned > SliceLevel_unsigned ELSE
      '0';

  Constant1_out1 <= to_unsigned(16#00#, 8);

  Constant_out1 <= to_unsigned(16#FF#, 8);

  
  Switch_out1 <= Constant1_out1 WHEN Relational_Operator_relop1 = '0' ELSE
      Constant_out1;

  pixelOut <= std_logic_vector(Switch_out1);

  ctrlOut_hStart <= Color_Space_Converter_out2_hStart;

  ctrlOut_hEnd <= Color_Space_Converter_out2_hEnd;

  ctrlOut_vStart <= Color_Space_Converter_out2_vStart;

  ctrlOut_vEnd <= Color_Space_Converter_out2_vEnd;

  ctrlOut_valid <= Color_Space_Converter_out2_valid;

END rtl;

