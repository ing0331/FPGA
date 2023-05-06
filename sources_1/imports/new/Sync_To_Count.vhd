-- This module will take incoming horizontal and veritcal sync pulses and
-- create Row and Column counters based on these syncs.
-- It will align the Row/Col counters to the output Sync pulses.
-- Useful for any module that needs to keep track of which Row/Col position we
-- are on in the middle of a frame.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Sync_To_Count is
  generic (
     g_TOTAL_COLS : integer;
     g_TOTAL_ROWS : integer;
     g_ACTIVE_COLS : integer;
     g_ACTIVE_ROWS : integer    --;
               
--     h_front_porch : integer ;
--     h_sync_pulse  : integer ;
--     h_back_porch  : integer ;
                             
--     v_front_porch : integer ;
--     v_sync_pulse  : integer ;
--     v_back_porch  : integer 
    );
  port (
    i_Clk     : in std_logic;
    o_HSync     : out std_logic;
    o_VSync     : out std_logic;
    o_Col_Count : out std_logic_vector(9 downto 0);
    o_Row_Count : out std_logic_vector(9 downto 0)
    );
end entity Sync_To_Count;

architecture RTL of Sync_To_Count is

  constant h_front_porch: integer  := 16;
  constant h_sync_pulse : integer  := 96 ;
  constant h_back_porch : integer  := 48 ;
  constant v_front_porch: integer  := 10 ;
  constant v_sync_pulse : integer :=  2 ;
  constant v_back_porch : integer :=  33;
  signal i_HSync   : std_logic;
  signal i_VSync   : std_logic;
    
  signal r_VSync       : std_logic;
  signal r_HSync       : std_logic;
  signal w_Frame_Start : std_logic;
  
  -- Make these unsigned counters (always positive)
  signal r_Col_Count : unsigned(9 downto 0) := (others => '0');
  signal r_Row_Count : unsigned(9 downto 0) := (others => '0');
begin

  gen_sync: process(r_Col_Count)
  begin
    if (TO_INTEGER(r_Col_Count)>g_ACTIVE_COLS-1 + h_front_porch) and (TO_INTEGER(r_Col_Count) < g_TOTAL_COLS-h_back_porch) then 
      i_HSync <= '0';
    else    
      i_HSync <= '1';
    end if;
end process;
  
  gen_vsync: process(r_Row_Count)
begin
  if (TO_INTEGER(r_Row_Count) > g_ACTIVE_ROWS-1 + v_front_porch) and (TO_INTEGER(r_Row_Count) < g_ACTIVE_ROWS + v_front_porch + v_sync_pulse) then 
    i_VSync <= '0'; 
  else  
    i_VSync <= '1';
  end if;
end process;

  p_Reg_HSyncs : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      r_HSync <= i_HSync;
    end if;
  end process p_Reg_HSyncs; 

  -- Register syncs to align with output data.
  p_Reg_VSyncs : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      r_VSync <= i_VSync;
    end if;
  end process p_Reg_VSyncs; 

  -- Keep track of Row/Column counters.
  p_Col_Count : process (i_Clk) is
  begin
--      if rising_edge(i_Clk) then
          if w_Frame_Start = '1' then
            r_Col_Count <= (others => '0');
          elsif rising_edge(i_Clk) then
              if r_Col_Count = to_unsigned(g_TOTAL_COLS-1, r_Col_Count'length) then
--                  if r_Row_Count = to_unsigned(g_TOTAL_ROWS-1, r_Row_Count'length) then
--                    r_Row_Count <= (others => '0');
--                  else
--                    r_Row_Count <= r_Row_Count + 1;
--                  end if;
                  r_Col_Count <= (others => '0');
              else
                 r_Col_Count <= r_Col_Count + 1;
              end if;
          end if;
--      end if;
  end process p_Col_Count;
  
    -- Keep track of Row/Column counters.
  p_Row_Count : process (i_Clk) is
  begin
        if rising_edge(i_Clk) then
              if r_Col_Count = to_unsigned(g_TOTAL_COLS-1, r_Col_Count'length) then
                  if r_Row_Count = to_unsigned(g_TOTAL_ROWS-1, r_Row_Count'length) then
                    r_Row_Count <= (others => '0');
                  else
                    r_Row_Count <= r_Row_Count + 1;
                  end if;
--                  r_Col_Count <= (others => '0');
--              else
--                 r_Col_Count <= r_Col_Count + 1;
              end if;
          end if;
--      end if;
  end process p_Row_Count;
  
  -- Look for rising edge on Vertical Sync to reset the counters
  w_Frame_Start <= '1' when r_VSync = '0' and i_VSync = '1' 
  else '0';
  
  o_VSync <= r_VSync;
  o_HSync <= r_HSync;

  o_Row_Count <= std_logic_vector(r_Row_Count);
  o_Col_Count <= std_logic_vector(r_Col_Count);
  
end architecture RTL;
