-- -------------------------------------------------------------
-- 
-- File Name: hdlsrc\CornerDetectionHDL\GateProcessData_block2.vhd
-- Created: 2023-06-21 14:30:33
-- 
-- Generated by MATLAB 9.14 and HDL Coder 4.1
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: GateProcessData_block2
-- Source Path: CornerDetectionHDL/HDL Corner Algorithm/Corner Detector/HarrisCore/HarrisFilterC/LineBuffer/GateProcessData
-- Hierarchy Level: 5
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY GateProcessData_block2 IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        processDataIn                     :   IN    std_logic;
        validIn                           :   IN    std_logic;
        dumping                           :   IN    std_logic;
        outputData                        :   IN    std_logic;
        processData                       :   OUT   std_logic;
        dumpOrValid                       :   OUT   std_logic
        );
END GateProcessData_block2;


ARCHITECTURE rtl OF GateProcessData_block2 IS

  -- Signals
  SIGNAL processNull                      : std_logic;
  SIGNAL validREG                         : std_logic;
  SIGNAL validOrDumping                   : std_logic;
  SIGNAL processValid                     : std_logic;

BEGIN
  processNull <= '0';

  reg_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        validREG <= '0';
      ELSIF enb = '1' THEN
        validREG <= validIn;
      END IF;
    END IF;
  END PROCESS reg_process;


  validOrDumping <= validREG OR dumping;

  processValid <= processDataIn AND validOrDumping;

  
  processData <= processNull WHEN outputData = '0' ELSE
      processValid;

  dumpOrValid <= validOrDumping;

END rtl;

