-- -------------------------------------------------------------
-- 
-- File Name: hdlsrc\CornerDetectionHDL\HDL_Corner_Algorithm_pkg.vhd
-- Created: 2023-06-21 14:30:33
-- 
-- Generated by MATLAB 9.14 and HDL Coder 4.1
-- 
-- -------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
--library work;

PACKAGE HDL_Corner_Algorithm_pkg IS
  TYPE vector_of_std_logic_vector8 IS ARRAY (NATURAL RANGE <>) OF std_logic_vector(7 DOWNTO 0);
  TYPE vector_of_unsigned8 IS ARRAY (NATURAL RANGE <>) OF unsigned(7 DOWNTO 0);
  TYPE vector_of_unsigned16 IS ARRAY (NATURAL RANGE <>) OF unsigned(15 DOWNTO 0);
  TYPE vector_of_unsigned24 IS ARRAY (NATURAL RANGE <>) OF unsigned(23 DOWNTO 0);
  TYPE vector_of_std_logic_vector20 IS ARRAY (NATURAL RANGE <>) OF std_logic_vector(19 DOWNTO 0);
  TYPE vector_of_signed20 IS ARRAY (NATURAL RANGE <>) OF signed(19 DOWNTO 0);
  TYPE vector_of_signed22 IS ARRAY (NATURAL RANGE <>) OF signed(21 DOWNTO 0);
  TYPE vector_of_signed38 IS ARRAY (NATURAL RANGE <>) OF signed(37 DOWNTO 0);
  TYPE vector_of_signed23 IS ARRAY (NATURAL RANGE <>) OF signed(22 DOWNTO 0);
  TYPE vector_of_signed39 IS ARRAY (NATURAL RANGE <>) OF signed(38 DOWNTO 0);
  TYPE vector_of_signed36 IS ARRAY (NATURAL RANGE <>) OF signed(35 DOWNTO 0);
  TYPE vector_of_signed10 IS ARRAY (NATURAL RANGE <>) OF signed(9 DOWNTO 0);
  TYPE vector_of_signed42 IS ARRAY (NATURAL RANGE <>) OF signed(41 DOWNTO 0);
  TYPE vector_of_signed44 IS ARRAY (NATURAL RANGE <>) OF signed(43 DOWNTO 0);
  TYPE vector_of_signed21 IS ARRAY (NATURAL RANGE <>) OF signed(20 DOWNTO 0);
END HDL_Corner_Algorithm_pkg;
