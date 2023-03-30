library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

entity Project10_Pong_Top is
  port (
    -- Main Clock (100 MHz)
    clock         : in std_logic;
 
        -- UART Data
--    i_UART_RX : in std_logic;
    Game_Start_btn : in std_logic;        --serving ball btn
 
    -- Push Buttons
    i_Switch_1 : in std_logic;
    i_Switch_2 : in std_logic;
    i_Switch_3 : in std_logic;
    i_Switch_4 : in std_logic;

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
end entity Project10_Pong_Top;
 
architecture RTL of Project10_Pong_Top is
--  signal w_RX_DV : std_logic;
   
  -- VGA Constants to set Frame Size
  constant c_VIDEO_WIDTH : integer := 3;
  constant c_TOTAL_COLS  : integer := 800;
  constant c_TOTAL_ROWS  : integer := 525;
  constant c_ACTIVE_COLS : integer := 640;
  constant c_ACTIVE_ROWS : integer := 480;
   
  -- Common VGA Signals
  signal w_HSync_VGA       : std_logic;
  signal w_VSync_VGA       : std_logic;
  signal w_Red_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Grn_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Blu_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
 
  signal start_debounce : std_logic;
  signal w_Switch_1 : std_logic;
  signal w_Switch_2 : std_logic;
  signal w_Switch_3 : std_logic;
  signal w_Switch_4 : std_logic;
   
  -- Pong Signals
  signal w_HSync_Pong     : std_logic;
  signal w_VSync_Pong     : std_logic;
  signal w_Red_Video_Pong : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Grn_Video_Pong : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Blu_Video_Pong : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);  
  
  signal clock_cnt : STD_LOGIC_VECTOR (2 downto 0);
  signal i_CLK : STD_LOGIC;     --clk_div
begin
 
     PROCESS(clock)
        begin
            if clock'event and clock = '1' then 
               if clock_cnt >= "111" then
                   clock_cnt <= (others => '0');
               else 
                   clock_cnt <= clock_cnt + 1;
               end if;
            end if;
        end process;
        i_Clk <= clock_cnt(1);      -- clock /  2 = 50M hz 
 
--  UART_RX_Inst : entity work.UART_RX
--    generic map (
--      g_CLKS_PER_BIT => 217)            -- 25,000,000 / 115,200
--    port map (
--      i_Clk       => i_Clk,
--      i_RX_Serial => i_UART_RX,
--      o_RX_DV     => w_RX_DV,
--      o_RX_Byte   => open);
 
  VGA_Sync_Pulses_inst : entity work.VGA_Sync_Pulses
    generic map (
      g_TOTAL_COLS  => c_TOTAL_COLS,
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
  Debounce_Switch_start: entity work.Debounce_Switch
    port map (
    i_Clk    => i_Clk,
    i_Switch => Game_Start_btn,       --input
    o_Switch => start_debounce);         
  Debounce_Switch_1: entity work.Debounce_Switch
    port map (
      i_Clk    => i_Clk,
      i_Switch => i_Switch_1,       --input
      o_Switch => w_Switch_1);      --wire
  Debounce_Switch_2: entity work.Debounce_Switch
    port map (
      i_Clk    => i_Clk,
      i_Switch => i_Switch_2,
      o_Switch => w_Switch_2);
  Debounce_Switch_3: entity work.Debounce_Switch
    port map (
      i_Clk    => i_Clk,
      i_Switch => i_Switch_3,
      o_Switch => w_Switch_3);
  Debounce_Switch_4: entity work.Debounce_Switch
    port map (
      i_Clk    => i_Clk,
      i_Switch => i_Switch_4,
      o_Switch => w_Switch_4);
   
  Pong_Top_1: entity work.Pong_Top
    generic map (
      g_Video_Width => c_VIDEO_WIDTH,
      g_Total_Cols  => c_TOTAL_COLS, 
      g_Total_Rows  => c_TOTAL_ROWS, 
      g_Active_Cols => c_ACTIVE_COLS,
      g_Active_Rows => c_ACTIVE_ROWS) 
    port map (
      i_Clk          => i_Clk,
      i_HSync        => w_HSync_VGA,
      i_VSync        => w_VSync_VGA,
--      i_Game_Start   => w_RX_DV,
      i_Game_Start => start_debounce,   --signal => btn
      i_Paddle_Up_P1 => w_Switch_1,
      i_Paddle_Dn_P1 => w_Switch_2,
      i_Paddle_Up_P2 => w_Switch_3,
      i_Paddle_Dn_P2 => w_Switch_4,
      o_HSync        => w_HSync_Pong,
      o_VSync        => w_VSync_Pong,
      o_Red_Video    => w_Red_Video_Pong,
      o_Blu_Video    => w_Blu_Video_Pong,
      o_Grn_Video    => w_Grn_Video_Pong);
       
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
      i_HSync     => w_HSync_Pong,
      i_VSync     => w_VSync_Pong,
      i_Red_Video => w_Red_Video_Pong,
      i_Grn_Video => w_Blu_Video_Pong,
      i_Blu_Video => w_Grn_Video_Pong,
      --
      o_HSync     => o_VGA_HSync,
      o_VSync     => o_VGA_VSync,
      o_Red_Video => w_Red_Video_Porch,
      o_Grn_Video => w_Blu_Video_Porch,
      o_Blu_Video => w_Grn_Video_Porch
      );    
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