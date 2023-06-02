library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BRam_sobel_VGA is 
port(
		clock     : in std_logic;
		rst 	  : in std_logic;
		btn1     : in std_logic_vector(1 downto 0);		--threshold
		SW_img		: in std_logic;   --'1' road, '0' net
		SW_sobel  	: in std_logic;  --'1' sobel, '0' img_gray
		
		o_VGA_HSync : out std_logic;--horizontal synchro signal					
		o_VGA_VSync	: out std_logic;	-- verical synchro signal 
		o_VGA_Red	: out std_logic_vector(2 downto 0); 	-- final color
		o_VGA_Grn	: out std_logic_vector(2 downto 0);		-- outputs
		o_VGA_Blu	: out std_logic_vector(1 downto 0)
	);
end entity BRam_sobel_VGA;

architecture arch of BRam_sobel_VGA is 

	constant c_TOTAL_COLS  : integer := 800;
	constant c_TOTAL_ROWS  : integer := 525;
	constant c_ACTIVE_COLS : integer := 640;
	constant c_ACTIVE_ROWS : integer := 480;
	
	signal pixel_clk : std_logic;
	signal w_img : std_logic_vector(7 downto 0);
	signal Sobel_out : std_logic_vector(7 downto 0);
	
	 -- Common VGA Signals
	 signal w_HSync_VGA       : std_logic;
	 signal w_VSync_VGA       : std_logic;
	  signal w_HSync_Porch     : std_logic;
	  signal w_VSync_Porch     : std_logic;
	
	signal w_Col_Count : STD_LOGIC_VECTOR(9 DOWNTO 0);	
	signal w_Row_Count : STD_LOGIC_VECTOR(9 DOWNTO 0);	
	
	SIGNAL w_hsync_SOBEL : STD_LOGIC;
	SIGNAL w_vsync_SOBEL : STD_LOGIC;
	
	SIGNAL DATA_FOR_VGA : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
begin	
	clockDiv_50M : entity work.clkDiv
		Port map ( 		
			i_clk   => clock,
			rst 	=> rst,
			clk_div => pixel_clk );
	
	VGA_Sync_Pulses_inst : entity work.VGA_Sync_Pulses 
		generic map ( 
		 g_TOTAL_COLS  => c_TOTAL_COLS,
		 g_TOTAL_ROWS  => c_TOTAL_ROWS,
		 g_ACTIVE_COLS => c_ACTIVE_COLS,
		 g_ACTIVE_ROWS => c_ACTIVE_ROWS
		 )
	   port map (
		 i_Clk       => pixel_clk,
		 o_HSync     => w_HSync_VGA,      --w_HSync_VGA
		 o_VSync     => w_VSync_VGA,      --w_VSync_VGA
		 o_Col_Count => open,        --metastable
		 o_Row_Count => open
		 );	
		 
	 Sync_To_Count_inst : entity work.Sync_To_Count
		generic map (   
		  g_TOTAL_COLS => c_TOTAL_COLS,     
		  g_TOTAL_ROWS => c_TOTAL_ROWS
		  )
		port map (
		  i_Clk       => pixel_clk,
		  i_HSync     => w_HSync_VGA,
		  i_VSync     => w_VSync_VGA,
		  
		  o_HSync     => open,
		  o_VSync     => open,
		  o_Col_Count => w_Col_Count,
		  o_Row_Count => w_Row_Count
		  );		
		  
	img_in: entity work.Bram_dout
		Port map ( 
			i_clk => pixel_clk,
            i_SW => SW_img,
			i_Col_Count => w_Col_Count,
			i_Row_Count => w_Row_Count,
			
			o_img => w_img );
			
	edge : entity work.edge_sobel_wrapper
		Port map ( 
			clk 		=> pixel_clk,
			w_btn		=> btn1,
			fsync_in 	=> w_HSync_VGA,
			rsync_in 	=> w_VSync_VGA, 
			pdata_in 	=> w_img,
			
			col_cnt_in => w_Col_Count,
			row_cnt_in => w_Row_Count,
			
			fsync_out 	=> w_hsync_SOBEL,	--w_hsync_SOBEL,
			rsync_out 	=> w_vsync_SOBEL,	--w_vsync_SOBEL,
			Sobel_out 	=> Sobel_out
		);
		
		sync: entity work.VGA_Sync_Porch
		  generic map (
          g_VIDEO_WIDTH => 3,
          g_TOTAL_COLS  => c_TOTAL_COLS,
          g_TOTAL_ROWS  => c_TOTAL_ROWS,
          g_ACTIVE_COLS => c_ACTIVE_COLS,
          g_ACTIVE_ROWS => c_ACTIVE_ROWS
          )
        port map(
          i_Clk       => pixel_clk,
          i_HSync     => w_hsync_SOBEL,
          i_VSync     => w_vsync_SOBEL,
          i_Red_Video => Sobel_out(2 downto 0),
          i_Grn_Video => Sobel_out(5 downto 3),
          i_Blu_Video => Sobel_out(7 downto 6),

          o_HSync     => w_HSync_Porch ,
          o_VSync     => w_VSync_Porch ,
          o_Red_Video => DATA_FOR_VGA(2 downto 0),
          o_Grn_Video => DATA_FOR_VGA(5 downto 3),
          o_Blu_Video => DATA_FOR_VGA(7 downto 6)
          );
          
          o_VGA_HSync <= w_HSync_Porch ;     --w_hsync_SOBEL
          o_VGA_VSync <= w_VSync_Porch ;     --w_hsync_SOBEL
		
	o_VGA_Red <= DATA_FOR_VGA(7 DOWNTO 5) when SW_sobel = '1'
	else w_img(2 downto 0);
	o_VGA_Grn <= DATA_FOR_VGA(7 DOWNTO 5) when SW_sobel = '1'
	else w_img(5 downto 3);
	o_VGA_Blu <= DATA_FOR_VGA(7 DOWNTO 6) when SW_sobel = '1'
	else w_img(7 downto 6);	
	
end architecture;