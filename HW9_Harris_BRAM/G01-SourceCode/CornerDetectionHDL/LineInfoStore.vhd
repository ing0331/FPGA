-- -------------------------------------------------------------
-- 
-- File Name: hdlsrc\CornerDetectionHDL\LineInfoStore.vhd
-- Created: 2023-06-21 14:30:32
-- 
-- Generated by MATLAB 9.14 and HDL Coder 4.1
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: LineInfoStore
-- Source Path: CornerDetectionHDL/HDL Corner Algorithm/Corner Detector/LineBuffer/LineInfoStore
-- Hierarchy Level: 3
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY LineInfoStore IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        hStartIn                          :   IN    std_logic;
        Unloading                         :   IN    std_logic;
        frameEnd                          :   IN    std_logic;
        lineStartV                        :   OUT   std_logic_vector(1 DOWNTO 0)  -- ufix2
        );
END LineInfoStore;


ARCHITECTURE rtl OF LineInfoStore IS

  -- Signals
  SIGNAL zeroConstant                     : std_logic;
  SIGNAL InputMuxOut                      : std_logic;
  SIGNAL reg_switch_delay                 : std_logic;  -- ufix1
  SIGNAL lineStart2                       : std_logic;
  SIGNAL reg_switch_delay_1               : std_logic;  -- ufix1
  SIGNAL lineStart3                       : std_logic;
  SIGNAL lineStartV_tmp                   : unsigned(1 DOWNTO 0);  -- ufix2

BEGIN
  zeroConstant <= '0';

  
  InputMuxOut <= hStartIn WHEN Unloading = '0' ELSE
      zeroConstant;

  reg_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        reg_switch_delay <= '0';
      ELSIF enb = '1' THEN
        IF frameEnd = '1' THEN
          reg_switch_delay <= '0';
        ELSIF hStartIn = '1' THEN
          reg_switch_delay <= InputMuxOut;
        END IF;
      END IF;
    END IF;
  END PROCESS reg_process;

  
  lineStart2 <= '0' WHEN frameEnd = '1' ELSE
      reg_switch_delay;

  reg_1_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        reg_switch_delay_1 <= '0';
      ELSIF enb = '1' THEN
        IF frameEnd = '1' THEN
          reg_switch_delay_1 <= '0';
        ELSIF hStartIn = '1' THEN
          reg_switch_delay_1 <= lineStart2;
        END IF;
      END IF;
    END IF;
  END PROCESS reg_1_process;

  
  lineStart3 <= '0' WHEN frameEnd = '1' ELSE
      reg_switch_delay_1;

  lineStartV_tmp <= unsigned'(lineStart3 & lineStart2);

  lineStartV <= std_logic_vector(lineStartV_tmp);

END rtl;
