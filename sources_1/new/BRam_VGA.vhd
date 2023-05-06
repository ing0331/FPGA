library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

entity BRam_VGA is
  port (
    i_Clk     : in std_logic;	--100M Hz
    rst : in std_logic;
    ---
    btn1 : in std_logic_vector (1 downto 0);		--up, down
    btn2 : in std_logic_vector (1 downto 0);
    HSync     : out std_logic;
    VSync     : out std_logic;
    o_Red_Video : out std_logic_vector(2 downto 0);
    o_Grn_Video : out std_logic_vector(2 downto 0);
    o_Blu_Video : out std_logic_vector(1 downto 0)
    );
end entity BRam_VGA;

architecture RTL of BRam_VGA is

    constant g_VIDEO_WIDTH : integer := 8;
    constant g_TOTAL_COLS  : integer := 800;
    constant g_TOTAL_ROWS  : integer := 525;
    constant g_ACTIVE_COLS : integer := 640;
    constant g_ACTIVE_ROWS : integer := 480;

    constant data_length : integer := 140;	
    constant data_width : integer := 38;
  	constant pad_length : integer := 32;
    constant pad_width : integer := 160;
    
  signal RAM_EN : std_logic := '0';
  component blk_number is
  Port ( 
    clka : in std_logic;
    ena : in std_logic;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 12 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 7 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 7 downto 0 )
  );
  end component blk_number;
  
  component Sync_To_Count is
    generic (
      g_TOTAL_COLS : integer;
      g_TOTAL_ROWS : integer;
      g_ACTIVE_COLS : integer;
      g_ACTIVE_ROWS : integer   --;
                
--      h_front_porch : integer;
--      h_sync_pulse : integer;
--      h_back_porch : integer;
--      v_front_porch : integer;
--      v_sync_pulse : integer;
--      v_back_porch : integer
      );
    port (
      i_Clk   : in std_logic;
      o_HSync     : out std_logic;
      o_VSync     : out std_logic;
      o_Col_Count : out std_logic_vector(9 downto 0);
      o_Row_Count : out std_logic_vector(9 downto 0)
      );
  end component Sync_To_Count;

--  component BRam is	--ball_draw
--	generic(			
--    data_length : integer;		
--    data_width : integer;
--    data_bits  : integer 
--	);
--	port(
--    rclk  : in std_logic;
--    raddrx : in integer range 0 to data_length-1;
--	raddry : in integer range 0 to data_width-1;
--    rdata : out std_logic_vector(data_bits-1 downto 0)
--	);
--  end component BRam;
  
  component paddle_BRAM is
	generic(			
    pad_length : integer;		
    pad_width : integer;
    data_bits  : integer 
	);
	port(
    rclk  : in std_logic;
    raddrx : in integer;
	raddry : in integer;
    rdata : out std_logic_vector(data_bits-1 downto 0)
	);
end component paddle_BRAM;
	
component FSM_VGA is
  generic (
    g_TOTAL_COLS  : integer;
    g_TOTAL_ROWS  : integer;
	
	ball_leng : integer;
	ball_width : integer;
	pad_leng : integer;
	pad_width : integer	
    );
  port (
	i_clk : in std_logic;
	move_clk : in std_logic;
	rst : in std_logic;
	btn1 : in std_logic_vector (1 downto 0);		--up, down
	btn2 : in std_logic_vector (1 downto 0);
	
    scan_x : in integer range 0 to g_TOTAL_COLS-1;
    scan_y : in integer range 0 to g_TOTAL_ROWS-1;
	
	pad_addr_x : out integer range 0 to g_TOTAL_ROWS-1-pad_width := g_TOTAL_ROWS/2- pad_width/2;
    pad_addr_y : out integer range 0 to g_TOTAL_ROWS-1-pad_width := g_TOTAL_ROWS/2- pad_width/2;
    ball_addr_x : out integer range -2*ball_leng to g_TOTAL_COLS-1;
    ball_addr_y : out integer range 0 to g_TOTAL_ROWS-1 -2*ball_width;	
			-- bound at g_TOTAL_ROWS-1-pad_width
	o_pad2_y : out integer range 0 to g_TOTAL_ROWS-1-pad_width := g_TOTAL_ROWS/2- pad_width/2;
	o_pad1_y : out integer range 0 to g_TOTAL_ROWS-1-pad_width := g_TOTAL_ROWS/2- pad_width/2;
    
    o_ball_x : out integer range -2*ball_leng to g_TOTAL_COLS-1;
    o_ball_y : out integer range 0 to g_TOTAL_ROWS-1 -2*ball_width
	);
end component FSM_VGA;

  signal clk_cnt : std_logic_vector (2 downto 0) := "001";
  signal clk_div : std_logic;
  signal T_frame : integer range 0 to 800*525/2 := 0;
  signal move_clk : std_logic := '1';
  
  signal w_x_cnt : std_logic_vector (9 downto 0);
  signal w_y_cnt : std_logic_vector (9 downto 0);
  signal int_x_cnt : integer range 0 to g_TOTAL_COLS -1;
  signal int_y_cnt : integer range 0 to g_TOTAL_ROWS -1;
  
  signal ball_x :  integer range -(2*data_length) to g_TOTAL_COLS-1;
  signal ball_y :  integer range 0 to g_TOTAL_ROWS-1 -2*data_width;
  signal ball_x_cnt : integer range 0 to data_length-1;
  signal ball_y_cnt : integer range 0 to data_width-1;
  signal w_rdata : std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
  
  signal pad1_x : integer := 0;
  signal pad1_y : integer range 0 to g_TOTAL_ROWS-1-pad_width :=  g_TOTAL_ROWS/2- pad_width/2;
  signal pad2_x : integer := g_TOTAL_COLS-1 -pad_length;
  signal pad2_y : integer range 0 to g_TOTAL_ROWS-1-pad_width := g_TOTAL_ROWS/2- pad_width/2; 
  signal pad_x_cnt : integer range 0 to pad_length-1;
  signal pad_y_cnt : integer range 0 to pad_width-1;  
  signal w_pad_rdata : std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
  
  signal addr_numDraw : std_logic_vector(12 downto 0);
  signal w_number_bmp : std_logic_vector(7 downto 0);
begin                                  
clk_divide: process(i_Clk, rst)
    begin
      if rst = '0' then
         clk_cnt <= (others => '0');
      elsif rising_edge(i_Clk) then
        clk_cnt <= clk_cnt + '1';
		T_frame <= T_frame + 1;
		if T_frame = 800*525*2 then	
			move_clk <= not move_clk;--	move_clk <= clk_cnt(20);
			T_frame <= 0;
		end if;
	  end if;
    end process;
    clk_div <= clk_cnt(1);
	
  Sync_To_Count_inst : Sync_To_Count
    generic map(
        g_TOTAL_COLS => 800,
        g_TOTAL_ROWS => 525,
        g_ACTIVE_COLS => 640,
        g_ACTIVE_ROWS => 480    --,
--        h_front_porch => 16,
--        h_sync_pulse  => 96,
--        h_back_porch  => 48,
--        v_front_porch => 10,
--        v_sync_pulse  => 2,
--        v_back_porch  => 33
    )
    port map(
        i_Clk       => clk_div,
        o_HSync     => HSync,
        o_VSync     => VSync,
        o_Col_Count => w_x_cnt,
        o_Row_Count => w_y_cnt
      );
  
--  Ball_Bram : BRam
--	generic map (				--one pixel one address 
--		data_length => data_length,	--1440
--		data_width => data_width,
--		data_bits => g_VIDEO_WIDTH 		--3
--	)
--	port map (
--		rclk  => clk_div,
--		raddrx => ball_x_cnt,
--		raddry => ball_y_cnt,
--		rdata => w_rdata
--	);

	int_x_cnt <= to_integer(unsigned(w_x_cnt));
	int_y_cnt <= to_integer(unsigned(w_y_cnt));
	
	pong_FSM: FSM_VGA
	generic map (
		g_TOTAL_COLS => g_TOTAL_COLS,
		g_TOTAL_ROWS => g_TOTAL_ROWS,
		ball_leng => data_length,
		ball_width => data_width,
		pad_leng => pad_length,
		pad_width => pad_width
		)
	port map (
		i_clk => clk_div,
		move_clk => move_clk,
		rst => rst,
		btn1 => btn1,		--up, down
		btn2 => btn2,
		scan_x  => int_x_cnt,
		scan_y  => int_y_cnt,
		pad_addr_x   => pad_x_cnt,
		pad_addr_y   => pad_y_cnt,
		ball_addr_x  => ball_x_cnt,
		ball_addr_y  => ball_y_cnt,
		
		o_ball_x => ball_x,
		o_ball_y => ball_y,
		o_pad1_y => pad1_y,
		o_pad2_y => pad2_y
		);
		
	 RAM_draw: process (int_x_cnt, int_y_cnt, ball_x, ball_y, ball_y_cnt, ball_x_cnt)
	 begin
		 if (int_x_cnt >= ball_x and int_x_cnt <= ball_x + data_length -1) and (int_y_cnt >= ball_y and int_y_cnt <= ball_y + data_width -1) then
			 RAM_EN <= '1';
		 else  
             RAM_EN <= '0';
		 end if;	
	 end process; 
	drawBRam: process (w_x_cnt, w_y_cnt)
	begin
--		if (int_x_cnt >= ball_x and int_x_cnt <= ball_x + data_length -1) and (int_y_cnt >= ball_y and int_y_cnt <= ball_y + data_width -1) then
--			o_Red_Video <= w_rdata(2 downto 0);
--			o_Grn_Video <= w_rdata(5 downto 3);
--			o_Blu_Video <= w_rdata(7 downto 6);
		 if (int_x_cnt >= ball_x and int_x_cnt <= ball_x + data_length -1) and (int_y_cnt >= ball_y and int_y_cnt <= ball_y + data_width -1) then
			 o_Red_Video <= w_number_bmp(2 downto 0);
			 o_Grn_Video <= w_number_bmp(5 downto 3);
			 o_Blu_Video <= w_number_bmp(7 downto 6);
		
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
	
	 paddle_x2: paddle_BRAM
	 generic map (				--one pixel one address 
		 pad_length => pad_length,	--1440
		 pad_width => pad_width,
		 data_bits => g_VIDEO_WIDTH 		--3
	 )
	 port map (
		 rclk  => clk_div,
		 raddrx => pad_x_cnt,
		 raddry => pad_y_cnt,
		 rdata => w_pad_rdata
	 );
	
	addr_numDraw <= std_logic_vector(to_unsigned(ball_y_cnt*data_length + ball_x_cnt, addr_numDraw'length));
	bmp2bin: blk_number
	Port map ( 
    clka => clk_div,
    ena => RAM_EN,  --'1', 	--
    wea  => (others => '0'),
    addra => addr_numDraw,		--ball_x_cnt + ball_y_cnt*data_length
    dina => (others => 'Z'),
    douta => w_number_bmp
  );
  
end RTL;