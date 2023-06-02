library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity edge_sobel_wrapper is
	generic (
		DATA_WIDTH	: integer := 8 
	);
    Port ( 
           clk : in  STD_LOGIC;
		   w_btn : in STD_LOGIC_VECTOR(1 downto 0);
           fsync_in : in  STD_LOGIC;
           rsync_in : in  STD_LOGIC;
           pdata_in : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
		   col_cnt_in : in STD_LOGIC_VECTOR(9 downto 0);
		   row_cnt_in : in STD_LOGIC_VECTOR(9 downto 0);
           fsync_out : out  STD_LOGIC;
           rsync_out : out  STD_LOGIC;
           Sobel_out : out  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0) );
end entity edge_sobel_wrapper;

architecture RTL of edge_sobel_wrapper is

SIGNAL pdata_int1 :  std_logic_vector(DATA_WIDTH-1 downto 0);	
SIGNAL pdata_int2 :  std_logic_vector(DATA_WIDTH-1 downto 0); 
SIGNAL pdata_int3 :  std_logic_vector(DATA_WIDTH-1 downto 0); 
SIGNAL pdata_int4 :  std_logic_vector(DATA_WIDTH-1 downto 0);  
SIGNAL pdata_int5 :  std_logic_vector(DATA_WIDTH-1 downto 0);
SIGNAL pdata_int6 :  std_logic_vector(DATA_WIDTH-1 downto 0);
SIGNAL pdata_int7 :  std_logic_vector(DATA_WIDTH-1 downto 0);
SIGNAL pdata_int8 :  std_logic_vector(DATA_WIDTH-1 downto 0);
SIGNAL pdata_int9 :  std_logic_vector(DATA_WIDTH-1 downto 0);
SIGNAL fsynch_int :  std_logic := '1';
SIGNAL rsynch_int :  std_logic := '1'; 

begin
		
CacheSystem : entity work.CacheSystem 
	GENERIC MAP (
		DATA_WIDTH => DATA_WIDTH,
		WINDOW_SIZE	=> 3,
		ROW_BITS => 10,
		COL_BITS => 10,
		NO_OF_ROWS => 480,
		NO_OF_COLS => 640 )
	PORT MAP(
		clk	   => clk, 
		fsync_in => fsync_in, 
		rsync_in => rsync_in, 
		pdata_in  => pdata_in, 
		
		w_col_cnt => col_cnt_in,
		w_row_cnt => row_cnt_in,			 
		
		fsync_out => fsynch_int, 
		rsync_out => rsynch_int, 
		pdata_out1 => pdata_int1, 
		pdata_out2 => pdata_int2, 
		pdata_out3 => pdata_int3, 
		pdata_out4 => pdata_int4, 
		pdata_out5 => pdata_int5, 
		pdata_out6 => pdata_int6, 
		pdata_out7 => pdata_int7, 
		pdata_out8 => pdata_int8, 
		pdata_out9 => pdata_int9
		);
			
--		fsync_out <= fsynch_int;
--		rsync_out <= rsynch_int;
krnl: entity work.edge_sobel 
	GENERIC MAP ( 
	DATA_WIDTH	=>  DATA_WIDTH)
	PORT MAP(
		pclk_i => clk,
		hsync_i => fsync_in,--fsynch_int
		vsync_i => rsync_in,--rsynch_int
		btn_threshold => w_btn,
		
		pData1 => pdata_int1,
		pData2 => pdata_int2,
		pData3 => pdata_int3,
		pData4 => pdata_int4,
		pData5 => pdata_int5,
		pData6 => pdata_int6,
		pData7 => pdata_int7,
		pData8 => pdata_int8,
		pData9 => pdata_int9,
		hsync_o => fsync_out,  --fsync_out,
		vsync_o => rsync_out,  --rsync_out,
		pdata_o => Sobel_out
	);
	
end RTL;