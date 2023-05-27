library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

entity RGB_Gen is
  generic (
    g_VIDEO_WIDTH : integer := 3;
    g_TOTAL_COLS  : integer := 800;
    g_TOTAL_ROWS  : integer := 525;
    g_ACTIVE_COLS : integer := 640;
    g_ACTIVE_ROWS : integer := 480
    );
  port (
    i_Clk     : in std_logic;
    rst       : in std_logic;    
    btn1      : in std_logic_vector(1 downto 0);
    btn2      : in std_logic_vector(1 downto 0);
	i_HSync   : in std_logic;
    i_VSync   : in std_logic;
    ---
    o_HSync     : out std_logic := '0';
    o_VSync     : out std_logic := '0';
    o_Red_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
    o_Grn_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
    o_Blu_Video : out std_logic_vector(g_VIDEO_WIDTH-1-1 downto 0)
    );
end entity RGB_Gen;

architecture RTL of RGB_Gen is

  component Sync_To_Count is
    generic (
      g_TOTAL_COLS : integer;
      g_TOTAL_ROWS : integer
      );
    port (
      i_Clk   : in std_logic;
      i_HSync : in std_logic;
      i_VSync : in std_logic;
      o_HSync     : out std_logic;
      o_VSync     : out std_logic;
      o_Col_Count : out std_logic_vector(9 downto 0);
      o_Row_Count : out std_logic_vector(9 downto 0)
      );
  end component Sync_To_Count;
  
  constant ball_leng  : integer := 140;		--;140
  constant ball_width : integer := 38;		--;38
   component blk_number IS
   PORT (
     clka : IN STD_LOGIC;
     ena : IN STD_LOGIC;
     wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
     addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
     dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
     douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
   );
   end component blk_number;
component blk_mona IS
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END component blk_mona;
  
	constant pad_leng : integer := 32;
	constant pad_width : integer := 160;
  component FSM_VGA is
  generic (
    g_TOTAL_COLS  : integer;
    g_TOTAL_ROWS  : integer;
	ball_leng : integer;
	ball_width : integer;
	pad_leng : integer;
	pad_width : integer	
    );
	port(	
	i_clk : in std_logic;
    move_clk : in std_logic;
	rst : in std_logic;			--up, down
	btn1 : in std_logic_vector (1 downto 0);	
	btn2 : in std_logic_vector (1 downto 0);
			--bound at g_TOTAL_ROWS-1-pad_width
    o_pad1_y : out integer range 0 to g_TOTAL_ROWS-1-pad_width := g_TOTAL_ROWS/2- pad_width/2;
    o_pad2_y : out integer range 0 to g_TOTAL_ROWS-1-pad_width := g_TOTAL_ROWS/2- pad_width/2;
    o_ball_x : out std_logic_vector(9 downto 0);--out integer range -ball_leng to g_TOTAL_COLS-1;  
    o_ball_y : out std_logic_vector(9 downto 0) --out integer range 0 to g_TOTAL_ROWS-1 -ball_width
	);
end component FSM_VGA;
  signal clk_cnt : std_logic_vector(23 downto 0) := (others => '0');
  signal move_clk : std_logic := '1';
  signal w_VSync : std_logic;
  signal w_HSync : std_logic;
  -- Make these unsigned counters (always positive)
  signal w_Col_Count : std_logic_vector(9 downto 0);
  signal w_Row_Count : std_logic_vector(9 downto 0);
  
  signal ball_x : std_logic_vector(9 downto 0) := "0010000100";
  signal ball_y : std_logic_vector(9 downto 0) := "0000110100";
  signal ball_addr_x : std_logic_vector(9 downto 0) := (others => '0');
  signal ball_addr_y : std_logic_vector(9 downto 0) := (others => '0');
  signal w_ena : std_logic := '0';
  signal r_addr : std_logic_vector(17 downto 0);	--13
  signal w_dout :  std_logic_vector(7 downto 0);
  
  signal pad1_y : integer range 0 to g_TOTAL_ROWS-1-pad_width :=  g_TOTAL_ROWS/2- pad_width/2;
  signal pad2_y : integer range 0 to g_TOTAL_ROWS-1-pad_width := g_TOTAL_ROWS/2- pad_width/2; 
  
begin
  Sync_To_Count_inst : Sync_To_Count
    generic map (   
      g_TOTAL_COLS => g_TOTAL_COLS,     
      g_TOTAL_ROWS => g_TOTAL_ROWS
      )
    port map (
      i_Clk       => i_Clk,
      i_HSync     => i_HSync,
      i_VSync     => i_VSync,
      o_HSync     => w_HSync,
      o_VSync     => w_VSync,
      o_Col_Count => w_Col_Count,
      o_Row_Count => w_Row_Count
      );
  process(i_Clk, rst, clk_cnt, move_clk)
  begin
	if rst = '0' then
		clk_cnt <= (others => '0');
	elsif rising_edge (i_Clk) then
		clk_cnt <= clk_cnt + '1';
		 if clk_cnt = 8*525/2 then     --tb
--		if clk_cnt = 800*525/2 then   	--FPGA
		  move_clk <= not move_clk;
		  clk_cnt <= (others => '0');
		end if;
	end if;
  end process;
  
  -- Register syncs to align with output data.
  p_Reg_Syncs : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      o_VSync <= w_VSync;
      o_HSync <= w_HSync;
    end if;
  end process p_Reg_Syncs; 
 ---------------------------
 ---------------------up/down sh
	objAddrx : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
		if (w_Col_Count >= ball_x and w_Col_Count < ball_x+ball_leng) and (w_ROW_Count >= ball_y and w_ROW_Count < ball_y+ball_width) then
			ball_addr_x <= ball_addr_x + '1';
		elsif (w_Col_Count = ball_x+ball_leng) and (w_ROW_Count >= ball_y and w_ROW_Count <= ball_y + ball_width) then
			ball_addr_x <= (others => '0');
	    else
	       ball_addr_x <= ball_addr_x;
        end if;
    end if;  
  end process objAddrx; 
objAddry : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
		if (w_Col_Count = ball_x+ball_leng) and (w_ROW_Count >= ball_y and w_ROW_Count < ball_y + ball_width) then
			ball_addr_y <= ball_addr_y + '1';
		elsif w_ROW_Count > ball_y + ball_width then
			ball_addr_y <= (others =>'0');
		else	
			ball_addr_y <= ball_addr_y;
		end if;
    end if;  
  end process objAddry; 
-- Select between different data
r_addr_sync : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
	  r_addr <= std_logic_vector(to_unsigned(TO_INTEGER(unsigned(ball_addr_y))*ball_leng+ TO_INTEGER(unsigned(ball_addr_x)), r_addr'length));
    end if;
  end process r_addr_sync;
RamEN : process(i_Clk)
begin
	if rising_edge(i_Clk) then
		if (w_Col_Count >= ball_x and w_Col_Count <= ball_x+ball_leng) and (w_Row_Count >= ball_y and w_Row_Count < ball_y+ball_width) then
			w_ena <= '1';
		else
			w_ena <= '0';
		end if;
    end if;
  end process RamEN; 

 BramBall: blk_number 
   PORT MAP(
     clka  =>  i_Clk,
     ena   =>  w_ena,
     wea   =>  (others => '0'),
     addra =>  r_addr(12 downto 0),
     dina  =>  (others => 'Z'),
     douta =>  w_dout
   );
  -------------------------
--  QR: blk_mona 
--  PORT MAP(
--    clka  => i_Clk,
--    ena   => w_ena,
--    wea   => (others => '0'),
--    addra => r_addr(17 DOWNTO 0),
--    dina  => (others => 'Z'),
--    douta => w_dout
--  );
  
  	pong_FSM: FSM_VGA
	generic map (
		g_TOTAL_COLS => g_TOTAL_COLS,
		g_TOTAL_ROWS => g_TOTAL_ROWS,
		ball_leng => ball_leng,
		ball_width =>ball_width,
		pad_leng => pad_leng,
		pad_width => pad_width
		)
	port map (
		i_clk => i_Clk,
		move_clk => move_clk,
		rst => rst,
		btn1 => btn1,		--up, down
		btn2 => btn2,
		o_pad1_y => pad1_y,
		o_pad2_y => pad2_y,
		o_ball_x => ball_x,
		o_ball_y => ball_y
		);
  -------------------------
  p_TP_Select : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
        if (w_Col_Count >= ball_x and w_Col_Count <= ball_x+ball_leng) and (w_Row_Count >= ball_y and w_Row_Count <= ball_y+ball_width) then
            o_Red_Video <= w_dout(2 downto 0);
            o_Grn_Video <= w_dout(5 downto 3);
            o_Blu_Video <= w_dout(7 downto 6);
		elsif (w_Col_Count < pad_leng) and w_Row_Count >= pad1_y and w_Row_Count < pad1_y + pad_width then
			 o_Red_Video <= (others => '1');  
			 o_Grn_Video <= (others => '1');  
			 o_Blu_Video <= (others => '1');
		elsif (w_Col_Count < g_ACTIVE_COLS-1 and w_Col_Count > g_ACTIVE_COLS-1 - pad_leng) and w_Row_Count >= pad2_y and w_Row_Count < pad2_y + pad_width then
			 o_Red_Video <= (others => '1');
			 o_Grn_Video <= (others => '1');
			 o_Blu_Video <= (others => '1');
        else		--black
            o_Red_Video <= (others => '0');  
            o_Grn_Video <= (others => '0');  
            o_Blu_Video <= (others => '0');
        end if; 
	end if;
  end process p_TP_Select;

end architecture RTL;
