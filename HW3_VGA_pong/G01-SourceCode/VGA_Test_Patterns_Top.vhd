library ieee;
use ieee.std_logic_1164.all;
 
entity VGA_Test_Patterns_Top is
  port (
    -- Main Clock (25 MHz)
    i_Clk         : in std_logic;
 
    -- UART Data
    i_UART_RX : in  std_logic;
    o_UART_TX : out std_logic;
     
    -- Segment1 is upper digit, Segment2 is lower digit
    o_Segment1_A : out std_logic;
    o_Segment1_B : out std_logic;
    o_Segment1_C : out std_logic;
    o_Segment1_D : out std_logic;
    o_Segment1_E : out std_logic;
    o_Segment1_F : out std_logic;
    o_Segment1_G : out std_logic;
     
    o_Segment2_A : out std_logic;
    o_Segment2_B : out std_logic;
    o_Segment2_C : out std_logic;
    o_Segment2_D : out std_logic;
    o_Segment2_E : out std_logic;
    o_Segment2_F : out std_logic;
    o_Segment2_G : out std_logic;
     
    -- VGA
    o_VGA_HSync : out std_logic;
    o_VGA_VSync : out std_logic;
    o_VGA_Red_0 : out std_logic;
    o_VGA_Red_1 : out std_logic;
    o_VGA_Red_2 : out std_logic;
    o_VGA_Grn_0 : out std_logic;
    o_VGA_Grn_1 : out std_logic;
    o_VGA_Grn_2 : out std_logic;
    o_VGA_Blu_0 : out std_logic;
    o_VGA_Blu_1 : out std_logic;
    o_VGA_Blu_2 : out std_logic
    );
end entity VGA_Test_Patterns_Top;
 
architecture RTL of VGA_Test_Patterns_Top is
 
  signal w_RX_DV     : std_logic;
  signal w_RX_Byte   : std_logic_vector(7 downto 0);
  signal w_TX_Active : std_logic;
  signal w_TX_Serial : std_logic;
   
  signal w_Segment1_A, w_Segment2_A : std_logic;
  signal w_Segment1_B, w_Segment2_B : std_logic;
  signal w_Segment1_C, w_Segment2_C : std_logic;
  signal w_Segment1_D, w_Segment2_D : std_logic;
  signal w_Segment1_E, w_Segment2_E : std_logic;
  signal w_Segment1_F, w_Segment2_F : std_logic;
  signal w_Segment1_G, w_Segment2_G : std_logic;
 
  -- VGA Constants to set Frame Size
  constant c_VIDEO_WIDTH : integer := 3;
  constant c_TOTAL_COLS  : integer := 800;
  constant c_TOTAL_ROWS  : integer := 525;
  constant c_ACTIVE_COLS : integer := 640;
  constant c_ACTIVE_ROWS : integer := 480;
   
  signal r_TP_Index        : std_logic_vector(3 downto 0) := (others => '0');
 
  -- Common VGA Signals
  signal w_HSync_VGA       : std_logic;
  signal w_VSync_VGA       : std_logic;
  signal w_HSync_Porch     : std_logic;
  signal w_VSync_Porch     : std_logic;
  signal w_Red_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Grn_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Blu_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
 
  -- VGA Test Pattern Signals
  signal w_HSync_TP     : std_logic;
  signal w_VSync_TP     : std_logic;
  signal w_Red_Video_TP : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Grn_Video_TP : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Blu_Video_TP : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);  
   
begin
 
  UART_RX_Inst : entity work.UART_RX
    generic map (
      g_CLKS_PER_BIT => 217)            -- 25,000,000 / 115,200
    port map (
      i_Clk       => i_Clk,
      i_RX_Serial => i_UART_RX,
      o_RX_DV     => w_RX_DV,
      o_RX_Byte   => w_RX_Byte);
 
 
  -- Creates a simple loopback to test TX and RX
  UART_TX_Inst : entity work.UART_TX
    generic map (
      g_CLKS_PER_BIT => 868)               -- 100,000,000 / 115,200 
    port map (
      i_Clk       => i_Clk,
      i_TX_DV     => w_RX_DV,
      i_TX_Byte   => w_RX_Byte,
      o_TX_Active => w_TX_Active,
      o_TX_Serial => w_TX_Serial,
      o_TX_Done   => open
      );
 
  -- Drive UART line high when transmitter is not active
  o_UART_TX <= w_TX_Serial when w_TX_Active = '1' else '1'; -- Binary to 7-Segment Converter for Upper Digit 
  SevenSeg1_Inst : entity work.Binary_To_7Segment 
  port map ( i_Clk => i_Clk,
      i_Binary_Num => w_RX_Byte(7 downto 4),
      o_Segment_A  => w_Segment1_A,
      o_Segment_B  => w_Segment1_B,
      o_Segment_C  => w_Segment1_C,
      o_Segment_D  => w_Segment1_D,
      o_Segment_E  => w_Segment1_E,
      o_Segment_F  => w_Segment1_F,
      o_Segment_G  => w_Segment1_G
      );
   
  o_Segment1_A <= not w_Segment1_A;
  o_Segment1_B <= not w_Segment1_B;
  o_Segment1_C <= not w_Segment1_C;
  o_Segment1_D <= not w_Segment1_D;
  o_Segment1_E <= not w_Segment1_E;
  o_Segment1_F <= not w_Segment1_F;
  o_Segment1_G <= not w_Segment1_G; -- Binary to 7-Segment Converter for Lower Digit 
  SevenSeg2_Inst : entity work.Binary_To_7Segment 
  port map ( i_Clk => i_Clk,
      i_Binary_Num => w_RX_Byte(3 downto 0),
      o_Segment_A  => w_Segment2_A,
      o_Segment_B  => w_Segment2_B,
      o_Segment_C  => w_Segment2_C,
      o_Segment_D  => w_Segment2_D,
      o_Segment_E  => w_Segment2_E,
      o_Segment_F  => w_Segment2_F,
      o_Segment_G  => w_Segment2_G
      );
   
  o_Segment2_A <= not w_Segment2_A;
  o_Segment2_B <= not w_Segment2_B;
  o_Segment2_C <= not w_Segment2_C;
  o_Segment2_D <= not w_Segment2_D;
  o_Segment2_E <= not w_Segment2_E;
  o_Segment2_F <= not w_Segment2_F;
  o_Segment2_G <= not w_Segment2_G;
 
  ------------------------------------------------------------------------------
  -- VGA Test Patterns
  ------------------------------------------------------------------------------
  -- Purpose: Register test pattern from UART when DV pulse is seen
  -- Only least significant 4 bits are needed from whole byte.
  p_TP_Index : process (i_Clk)
  begin
    if rising_edge(i_Clk) then
      if w_RX_DV = '1' then
        r_TP_Index <= w_RX_Byte(3 downto 0); 
        end if; 
        end if; 
        end process p_TP_Index; 
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
      o_Col_Count => open,
      o_Row_Count => open
      );
 
  Test_Pattern_Gen_inst : entity work.Test_Pattern_Gen
    generic map (
      g_Video_Width => c_VIDEO_WIDTH,
      g_TOTAL_COLS  => c_TOTAL_COLS,
      g_TOTAL_ROWS  => c_TOTAL_ROWS,
      g_ACTIVE_COLS => c_ACTIVE_COLS,
      g_ACTIVE_ROWS => c_ACTIVE_ROWS
      )
    port map (
      i_Clk       => i_Clk,
      i_Pattern   => r_TP_Index,
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
    generic map (
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
      i_Grn_Video => w_Blu_Video_TP,
      i_Blu_Video => w_Grn_Video_TP,
      --
      o_HSync     => w_HSync_Porch,
      o_VSync     => w_VSync_Porch,
      o_Red_Video => w_Red_Video_Porch,
      o_Grn_Video => w_Blu_Video_Porch,
      o_Blu_Video => w_Grn_Video_Porch
      );
       
  o_VGA_HSync <= w_HSync_Porch;
  o_VGA_VSync <= w_VSync_Porch;
       
  o_VGA_Red_0 <= w_Red_Video_Porch(0);
  o_VGA_Red_1 <= w_Red_Video_Porch(1);
  o_VGA_Red_2 <= w_Red_Video_Porch(2);
   
  o_VGA_Grn_0 <= w_Grn_Video_Porch(0);
  o_VGA_Grn_1 <= w_Grn_Video_Porch(1);
  o_VGA_Grn_2 <= w_Grn_Video_Porch(2);
 
  o_VGA_Blu_0 <= w_Blu_Video_Porch(0);
  o_VGA_Blu_1 <= w_Blu_Video_Porch(1);
  o_VGA_Blu_2 <= w_Blu_Video_Porch(2);
   
end architecture RTL;