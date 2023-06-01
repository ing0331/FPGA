library ieee;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;

entity VGA_BRAM_top is
 port (
   -- Main Clock (100 MHz)
   clock         : in std_logic;
   rst           : in std_logic;
   btn1           : in std_logic_vector(1 downto 0);
   btn2           : in std_logic_vector(1 downto 0);
   -- VGA
   o_VGA_HSync : out std_logic;
   o_VGA_VSync : out std_logic;
   o_VGA_Red : out std_logic_vector(2 downto 0);
   o_VGA_Grn : out std_logic_vector(2 downto 0);
   o_VGA_Blu : out std_logic_vector(1 downto 0)
   );
end VGA_BRAM_top;

architecture Behavioral of VGA_BRAM_top is
-- VGA Constants to set Frame Size
 constant c_VIDEO_WIDTH : integer := 3;
 constant c_TOTAL_COLS  : integer := 800;
 constant c_TOTAL_ROWS  : integer := 525;
 constant c_ACTIVE_COLS : integer := 640;
 constant c_ACTIVE_ROWS : integer := 480;

 -- Common VGA Signals
 signal w_HSync_VGA       : std_logic;
 signal w_VSync_VGA       : std_logic;
 signal w_HSync_Porch     : std_logic;
 signal w_VSync_Porch     : std_logic;
 
 -- VGA Test Pattern Signals
 signal w_HSync_TP     : std_logic;
 signal w_VSync_TP     : std_logic;
 signal w_Red_Video_TP : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
 signal w_Grn_Video_TP : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
 signal w_Blu_Video_TP : std_logic_vector(c_VIDEO_WIDTH-1-1 downto 0);  
 
 signal clk_cnt :std_logic_vector(2 downto 0) := "001";
 signal i_Clk : std_logic;

begin
   clk_divide: process(clock)
   begin    
     if rising_edge(clock) then
        clk_cnt <= clk_cnt + 1;
      end if;
   end process;
   i_Clk <= clk_cnt(1);

VGA_Sync_Pulses_inst : entity work.VGA_Sync_Pulses 
generic map ( g_TOTAL_COLS => c_TOTAL_COLS,
     g_TOTAL_ROWS  => c_TOTAL_ROWS,
     g_ACTIVE_COLS => c_ACTIVE_COLS,
     g_ACTIVE_ROWS => c_ACTIVE_ROWS
     )
   port map (
     i_Clk       => i_Clk,
     o_HSync     => w_HSync_VGA,
     o_VSync     => w_VSync_VGA,
     o_Col_Count => open,        --metastable
     o_Row_Count => open
     );

 Bram_Gen_inst : entity work.RGB_Gen
   generic map (                 --compo Sync_To_Count, FSM_VGA
     g_Video_Width => c_VIDEO_WIDTH,
     g_TOTAL_COLS  => c_TOTAL_COLS,
     g_TOTAL_ROWS  => c_TOTAL_ROWS,
     g_ACTIVE_COLS => c_ACTIVE_COLS,
     g_ACTIVE_ROWS => c_ACTIVE_ROWS
     )
   port map (
     i_Clk       => i_Clk,
     rst         => rst,
     btn1       => btn1,
     btn2       => btn2,
     i_HSync     => w_HSync_VGA,
     i_VSync     => w_VSync_VGA,
     --
     o_HSync     => w_HSync_TP,
     o_VSync     => w_VSync_TP,
     o_Red_Video => w_Red_Video_TP,
     o_Blu_Video => w_Blu_Video_TP,
     o_Grn_Video => w_Grn_Video_TP
     );
  
 VGA_Sync_Porch_Inst : entity work.VGA_Sync_Porch
   generic map (                        --compo Sync_To_Count    
     g_Video_Width => c_VIDEO_WIDTH,
     g_TOTAL_COLS  => c_TOTAL_COLS,
     g_TOTAL_ROWS  => c_TOTAL_ROWS,
     g_ACTIVE_COLS => c_ACTIVE_COLS,
     g_ACTIVE_ROWS => c_ACTIVE_ROWS 
     )
   port map (
     i_Clk       => i_Clk,
     i_HSync     => w_HSync_VGA,
     i_VSync     => w_VSync_VGA,
     i_Red_Video => w_Red_Video_TP,
     i_Grn_Video => w_Grn_Video_TP,
     i_Blu_Video => w_Blu_Video_TP,
     --
     o_HSync     => w_HSync_Porch,
     o_VSync     => w_VSync_Porch,
     o_Red_Video => o_VGA_Red,
     o_Grn_Video => o_VGA_Grn,
     o_Blu_Video => o_VGA_Blu
     );
      
 o_VGA_HSync <= w_HSync_Porch;
 o_VGA_VSync <= w_VSync_Porch;
      
 end Behavioral;
