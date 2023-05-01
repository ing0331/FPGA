library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

entity BRam_VGA is
  generic (
    g_VIDEO_WIDTH : integer := 8;
    g_TOTAL_COLS  : integer := 800;
    g_TOTAL_ROWS  : integer := 525;
    g_ACTIVE_COLS : integer := 640;
    g_ACTIVE_ROWS : integer := 480;
	pad_length : integer := 32;
    pad_width : integer := 160
	);
  port (
    i_Clk     : in std_logic;
    ---
    HSync     : out std_logic := '0';
    VSync     : out std_logic := '0';
    o_Red_Video : out std_logic_vector(2 downto 0);
    o_Grn_Video : out std_logic_vector(2 downto 0);
    o_Blu_Video : out std_logic_vector(1 downto 0)
    );
end entity BRam_VGA;

architecture RTL of BRam_VGA is

  component Sync_To_Count is
    generic (
      g_TOTAL_COLS : integer;
      g_TOTAL_ROWS : integer;
      g_ACTIVE_COLS : integer;
      g_ACTIVE_ROWS : integer;
                
      h_front_porch : integer;
      h_sync_pulse : integer;
      h_back_porch : integer;
      
      v_front_porch : integer;
      v_sync_pulse : integer;
      v_back_porch : integer
      );
    port (
      i_Clk   : in std_logic;
      o_HSync     : out std_logic;
      o_VSync     : out std_logic;
      o_Col_Count : out std_logic_vector(9 downto 0);
      o_Row_Count : out std_logic_vector(9 downto 0)
      );
  end component Sync_To_Count;
  
  constant data_length : integer := 20;	
  constant data_width : integer := 20;
  component Read_BRAM is
	generic(			
    data_length : integer;		
    data_width : integer;
    data_bits  : integer 
	);
	port(
    rclk  : in std_logic;
    xaddr : in integer range 0 to data_length-1;
	yaddr : in integer range 0 to data_width-1;
    rdata : out std_logic_vector(data_bits-1 downto 0)
	);
end component Read_BRAM;
  
  component paddle_BRAM is
	generic(			
    data_length : integer;		
    data_width : integer;
    data_bits  : integer 
	);
	port(
    rclk  : in std_logic;
    xaddr : in integer;
	yaddr : in integer;
    rdata : out std_logic_vector(data_bits-1 downto 0)
	);
end component paddle_BRAM;  
  
  signal clk_cnt : std_logic_vector (1 downto 0);
  signal clk_div : std_logic;
  
  signal w_x_cnt : std_logic_vector (9 downto 0);
  signal w_y_cnt : std_logic_vector (9 downto 0);
  signal int_x_cnt : integer range 0 to g_TOTAL_COLS;
  signal int_y_cnt : integer range 0 to g_TOTAL_ROWS;
  
  signal ball_x :  integer range 0 to g_ACTIVE_COLS-1 := 320;
  signal ball_y :  integer range 0 to g_ACTIVE_ROWS-1 := 240;
  signal ball_x_cnt : integer range 0 to data_length-1;
  signal ball_y_cnt : integer range 0 to data_width-1;
  signal w_rdata : std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
  
  signal pad1_x : integer := 0;
  signal pad1_y : integer range 0 to g_TOTAL_ROWS-1 := 360;
  signal pad2_x : integer := g_TOTAL_COLS-1-pad_length;
  signal pad2_y : integer range 0 to g_TOTAL_ROWS-1 := 360; 
  signal pad_x_cnt : integer range 0 to pad_length-1;
  signal pad_y_cnt : integer range 0 to pad_width-1;  
  signal w_pad_rdata : std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
  
begin                                  
clk_divide: process(i_Clk)
    begin
        if rising_edge(i_Clk) then
           clk_cnt <= clk_cnt + '1';
        end if;
    end process;
    clk_div <= clk_cnt(1);
	
  Sync_To_Count_inst : Sync_To_Count
    generic map(
        g_TOTAL_COLS => 800,
        g_TOTAL_ROWS => 525,
        g_ACTIVE_COLS => 640,
        g_ACTIVE_ROWS => 480,
        
        h_front_porch => 18,
        h_sync_pulse => 92,
        h_back_porch => 50,
               
        v_front_porch=> 10,
        v_sync_pulse => 12,
        v_back_porch => 33
    )
    port map(
        i_Clk       => clk_div,
        o_HSync     => VSync,
        o_VSync     => HSync,
        o_Col_Count => w_x_cnt,
        o_Row_Count => w_y_cnt
      );
  
  Ball_Bram : Read_BRAM
	generic map (				--one pixel one address 
		data_length => data_length,	--1440
		data_width => data_width,
		data_bits => g_VIDEO_WIDTH 		--3
	)
	port map (
		rclk  => clk_div,
		xaddr => ball_x_cnt,
		yaddr => ball_y_cnt,
		rdata => w_rdata
	);

	int_x_cnt <= to_integer(unsigned(w_x_cnt));
	int_y_cnt <= to_integer(unsigned(w_y_cnt));
	
	-----
	ball_draw: process (int_x_cnt, int_y_cnt, ball_x, ball_y, int_x_cnt, int_y_cnt, ball_y_cnt, ball_x_cnt)
	begin
		if (int_x_cnt >= ball_x and int_x_cnt <= ball_x + data_length -1) and (int_y_cnt >= ball_y and int_y_cnt <= ball_y + data_width -1) then
			ball_x_cnt <= int_x_cnt - ball_x;
			ball_y_cnt <= int_y_cnt - ball_y;
		end if;	
	end process; 
	
	pad_draw: process (int_x_cnt, int_y_cnt, ball_x, ball_y, int_x_cnt, int_y_cnt, ball_y_cnt, ball_x_cnt)
	begin
		if (int_x_cnt >= pad1_x and int_x_cnt <= ball_x + data_length -1) and (int_y_cnt >= ball_y and int_y_cnt <= ball_y + data_width -1) then
            pad_x_cnt <= int_x_cnt - pad1_x;
            pad_y_cnt <= int_y_cnt - pad1_y;
		end if;	
	end process; 

	drawBRam: process (w_x_cnt, w_y_cnt)
	begin
		if (int_x_cnt >= ball_x and int_x_cnt <= ball_x + data_length -1) and (int_y_cnt >= ball_y and int_y_cnt <= ball_y + data_width -1) then
			o_Red_Video <= w_rdata(2 downto 0);
			o_Grn_Video <= w_rdata(5 downto 3);
			o_Blu_Video <= w_rdata(7 downto 6);
		elsif (int_x_cnt >= pad1_x and int_x_cnt <= pad1_x + pad_length -1) and (int_y_cnt >= pad1_y and int_y_cnt <= pad1_y + pad_width -1) then
			o_Red_Video <= w_pad_rdata(2 downto 0);
			o_Grn_Video <= w_pad_rdata(5 downto 3);
			o_Blu_Video <= w_pad_rdata(7 downto 6);
		elsif (int_x_cnt >= pad2_x and int_x_cnt <= pad2_x + pad_length -1) and (int_y_cnt >= pad2_y and int_y_cnt <= pad2_y + pad_width -1) then
			o_Red_Video <= w_pad_rdata(2 downto 0);
			o_Grn_Video <= w_pad_rdata(5 downto 3);
			o_Blu_Video <= w_pad_rdata(7 downto 6);
		else
			o_Red_Video <= (others => '0');
			o_Grn_Video <= (others => '0');
			o_Blu_Video <= (others => '0');
		end if;	
	end process;
	
	paddle1: paddle_BRAM
	generic map (				--one pixel one address 
		data_length => pad_length,	--1440
		data_width => pad_width,
		data_bits => g_VIDEO_WIDTH 		--3
	)
	port map (
		rclk  => clk_div,
		xaddr => pad_x_cnt,
		yaddr => pad_y_cnt,
		rdata => w_pad_rdata
	);
	
	-- pong_FSM: FSM_VGA
	-- generic (
		-- g_TOTAL_COLS => g_TOTAL_COLS;
		-- g_TOTAL_ROWS => g_TOTAL_ROWS;
		
		-- ball_r => ball_r;
		-- pad_leng : pad_leng;
		-- pad_width : pad_width
		-- );
	-- port (
		-- i_clk => clk_div;
		-- rst => rst;
		-- -- btn1 => ;		--up, down
		-- -- btn2 => ;

		-- scan_x  => ;
		-- scan_y  => ;

		-- ball_x => ;
		-- ball_y => ;
		-- pad1_y => ;
		-- pad2_y => 
		-- );

end RTL;