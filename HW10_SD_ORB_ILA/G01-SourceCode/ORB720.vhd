library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

entity top is

port(
    reset          : in std_logic;
    video_clk            :in std_logic;
--------set---------------------------------
    mode_sw        : in std_logic;	--888, 8
    star_up_sw     : in std_logic;
------------video in i2c---------------------------------
    video_gray_out : in std_logic_vector(7 downto 0);	--AXI
	delay_video_data : in std_logic_vector(7 downto 0);	--AXI
------------vga---------------------------------
    rout           : out std_logic_vector(3 downto 0); --
    gout           : out std_logic_vector(3 downto 0); --
    bout           : out std_logic_vector(3 downto 0); --
	o_video_minus  : out STD_LOGIC_VECTOR(7 DOWNTO 0);
-----------------------------------------------------------------------------
	o_vga_hs_cnt	:out std_logic_vector(9 downto 0);	--integer range 0 to 720;
	o_vga_vs_cnt	:out std_logic_vector(9 downto 0);	--integer range 0 to 480;	--
	-- SB_CRB_data_8_buf: : out std_logic_vector(7 downto 0);
	-- ero_data      : out std_logic;
	-- ero_data1     : out std_logic;
	-- dila_data 	  : out std_logic ;
	o_match_data	:out std_logic_vector(39 downto 0);
    signal_test    : out std_logic
);
end top;

architecture Behavioral of top is

component vga_act_cnt
    generic(
        horizontal_resolution : integer :=720 ;
        horizontal_front_porch: integer :=  48 ;
        horizontal_sync_pulse : integer := 112 ;
        horizontal_back_porch : integer := 248 ;
        h_sync_polarity       :std_logic:= '1' ;
        vertical_resolution   : integer :=480 ;
        vertical_front_porch  : integer :=   1 ;
        vertical_sync_pulse   : integer :=   3 ;
        vertical_back_porch   : integer :=  38 ;
        v_sync_polarity       :std_logic:= '1' 
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        video_start_en : in std_logic;
        vga_hs_cnt : out integer ;
        vga_vs_cnt : out integer 
        -- hsync : out std_logic;
        -- vsync : out std_logic
    );
end component;

--------D:\GSlab_git_NAS\HW11_Host_DDR\G01-SourceCode----------ram---------------------------

-- component blk_mem_gen_345600
    -- port(
        -- clka : IN STD_LOGIC;
        -- ena : IN STD_LOGIC;
        -- wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        -- addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
        -- dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        -- clkb : IN STD_LOGIC;
        -- enb : IN STD_LOGIC;
        -- addrb : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
        -- doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    -- );
-- end component;
component blk_mem_gen_345600	--delay_video_minus
    port(
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
        dina : IN STD_LOGIC;--_VECTOR(7 DOWNTO 0);
        clkb : IN STD_LOGIC;
        enb : IN STD_LOGIC;
        addrb : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
        doutb : OUT STD_LOGIC --_VECTOR(7 DOWNTO 0)
    );
end component;

COMPONENT sobel
	port(
	 rst                  : in  std_logic;
	 video_clk            : in  std_logic;
	 video_data           : in  std_logic_vector(7 downto 0);
	 SB_buf_012_en        : in  std_logic;
	 buf_sobel_cc_en      : in  std_logic;
	 buf_data_state       : in  std_logic_vector(1 downto 0);
	 SB_CRB_data          : out std_logic;
	 SB_CRB_data_8        : out std_logic_vector(7 downto 0)
	);
end component;
	
	signal SB_CRB_data    : std_logic:='0';   --sobel data
    signal in_ero_data    : std_logic:='0';
	signal ero_inte_data  : std_logic_vector(9 downto 0);
	signal ero_data       : std_logic:='0';   --erosion data
	signal ero_data_1       : std_logic:='0';   --erosion data

	signal in_inte_data   : std_logic:='0';   --integral data
	signal inte_check     : std_logic_vector(15 downto 0);
	signal inte_check1    : std_logic_vector(15 downto 0);	
	
component dilation 
	generic (
	array_x : integer;
	array_y : integer
	);
port(
	 rst            : in  std_logic;
	 video_clk      : in  std_logic;
	 in_dila_data   : in  std_logic;
	 dila_inte_data : in  std_logic_vector(9 downto 0);
	 integral_sw    : in  std_logic;
	 open_sw        : in  std_logic;
	 close_sw       : in  std_logic;
	 SB_buf_012_en  : in  std_logic;
	 buf_dila_en    : in  std_logic;
	 buf_data_state : in  std_logic_vector(1 downto 0);
	 dila_data      : out std_logic
 );
end component;


component erosion 
	generic (
	array_x     : integer;
	array_y     : integer;
   array_limit : std_logic_vector((10-1) downto 0)
	);
port(
	 rst            : in  std_logic;
	 video_clk      : in  std_logic;
	 in_ero_data    : in  std_logic;
	 ero_inte_data  : in  std_logic_vector(9 downto 0);
	 integral_sw    : in  std_logic;
	 open_sw        : in  std_logic;
	 close_sw       : in  std_logic;
	 SB_buf_012_en  : in  std_logic;
	 buf_ero_en     : in  std_logic;
	 buf_data_state : in  std_logic_vector(1 downto 0);
	 ero_data       : out std_logic
 );
end component;

	signal range_total_cnt    : integer range 0 to 729;	--1289:=0;
	signal buf_sobel_cc_delay : integer range 0 to 3   :=0;
	signal range_total_cnt_en : std_logic:='0';
	signal buf_Y_temp_en      : std_logic:='0';
	signal SB_buf_012_en      : std_logic:='0';
	signal buf_sobel_cc_en    : std_logic:='0';
	signal SBB_buf_en         : std_logic:='0';
	signal buf_ero_en         : std_logic:='0';
	signal buf_dila_en        : std_logic:='0';
	signal buf_inte_en        : std_logic:='0';
	signal buf_data_state     : std_logic_vector(1 downto 0):="00";

	signal in_dila_data   : std_logic:='0';
	signal dila_inte_data : std_logic_vector(9 downto 0);
	signal dila_inte_data_1 : std_logic_vector(9 downto 0);
	signal dila_data      : std_logic:='0';   --dilation data
 
	signal dila_data_1      : std_logic:='0';   --dilation data
    signal in_dila_data2   : std_logic:='0';
	signal dila_data2      : std_logic:='0';   --dilation data
	signal count_33554431 : std_logic_vector(21 downto 0);
	-- signal count_268435456 : std_logic_vector(27 downto 0);
		
component harris 

port(
    clk : in std_logic;
    rst : in std_logic;
    video_clk      : in std_logic;
    video_data : in std_logic_vector(7 downto 0);
    vga_hs_cnt : in integer range 0 to 857;
    vga_vs_cnt : in integer range 0 to 524;
    threshold  : in std_logic_vector (43 downto 0);
    harris_out : out std_logic;
    TRACKHARRIS : IN std_logic_vector(39 downto 0);
    harris_x : out integer;
    harris_y : out integer;
    TRACKX : IN integer;
    TRACKY : IN integer;
	--pepi  :  OUT std_logic_vector(0 downto 0);

    TRACKSQ : IN integer
 );
end component;

component harris2 

port(
    clk : in std_logic;
    rst : in std_logic;
    video_clk      : in std_logic;
    video_data : in std_logic_vector(7 downto 0);
    vga_hs_cnt : in integer range 0 to 857;
    vga_vs_cnt : in integer range 0 to 524;
    threshold  : in std_logic_vector (43 downto 0);
    harris_out2 : out std_logic;
    TRACKHARRIS : IN std_logic_vector(39 downto 0);
    harris_x2 : out integer;
    harris_y2 : out integer;
    TRACKX : IN integer;
    TRACKY : IN integer;
    TRACKSQ : IN integer
 );
end component;


component orb 
port(
    clk : in std_logic;
    rst : in std_logic;	
    video_clk      : in std_logic;
    kp_en : in std_logic;
    save_en: in std_logic;
    --pepi: OUT std_logic_vector(0 downto 0);
    vga_hs_cnt:in integer range 0 to 857;
    vga_vs_cnt:in integer range 0 to 524;
    BOUT_1 : out std_logic_vector(83 downto 0);
    ping_pong_out_2_out: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    video_data:in std_logic_vector(7 downto 0);
    TRACKORB : IN std_logic_vector(39 downto 0);
    TRACKX : IN integer;
    TRACKY : IN integer;
    TRACKSQ : IN integer
 );
end component;

component orb2 
port(
    clk : in std_logic;
    rst : in std_logic;	
    video_clk      : in std_logic;
    kp_en : in std_logic;
    save_en: in std_logic;
    vga_hs_cnt:in integer range 0 to 857;
    vga_vs_cnt:in integer range 0 to 524;
    BOUT_2 : OUT STD_LOGIC_VECTOR(83 DOWNTO 0);
    ping_pong_out_2_out: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    video_data:in std_logic_vector(7 downto 0);
    TRACKORB : IN std_logic_vector(39 downto 0);
    TRACKX : IN integer;
    TRACKY : IN integer;
    TRACKSQ : IN integer
 );
end component;

COMPONENT match
port(
	rst:in std_logic;
	clk:in std_logic;
	match_en:in std_logic;
	video_clk      : in std_logic;
	brief_addrb_1:out std_logic_vector(7 downto 0);
	brief_addrb_2:out std_logic_vector(7 downto 0);
	a:in std_logic_vector(83 downto 0);
	b:in std_logic_vector(83 downto 0);
	addrb:in std_logic_vector(7 downto 0);
	doutb:out std_logic_vector(39 downto 0);
	match_p : OUT std_logic;
	--pepi  :  OUT std_logic_vector(0 downto 0);
	MATE_D:out std_logic_vector(39 downto 0);
	MATE_D1:out std_logic_vector(39 downto 0);
	MATE_D2:out std_logic_vector(39 downto 0);
	MATE_D3:out std_logic_vector(39 downto 0);
	MATE_D4:out std_logic_vector(39 downto 0);
	MATE_D5:out std_logic_vector(39 downto 0);
	MATE_D6:out std_logic_vector(39 downto 0);
	MATE_D7:out std_logic_vector(39 downto 0)
);
END COMPONENT;
signal zs_cnt:integer;


signal brief_addrb_1:std_logic_vector(7 downto 0);
signal brief_addrb_2:std_logic_vector(7 downto 0);
signal match_en:std_logic;
signal breif_data_1:std_logic_vector(83 downto 0);
signal breif_data_2:std_logic_vector(83 downto 0);
signal match_addr:std_logic_vector(7 downto 0);
--signal match_data:std_logic_vector(39 downto 0);
signal state:std_logic_vector(1 downto 0);

signal test_data:std_logic_vector(7 downto 0);
signal ping_pong_out_2:std_logic_vector(7 downto 0);
--signal video_gray_out : std_logic_vector(7 downto 0);
signal video_r_out    : std_logic_vector(7 downto 0);
signal video_g_out    : std_logic_vector(7 downto 0);
signal video_b_out    : std_logic_vector(7 downto 0);
signal r : std_logic_vector(7 downto 0);
signal g : std_logic_vector(7 downto 0);
signal b : std_logic_vector(7 downto 0);
----------------------------------------vga---------------------------
signal vga_vs_cnt : integer ;
signal vga_hs_cnt : integer ;
signal vs_cnt : integer ;
signal hs_cnt : integer ;
signal frame_id         : std_logic ;
signal rst         : std_logic ;
signal enaa,enbb,encc        : std_logic ;
signal video_start_en_s : std_logic ;
------------------------------------------------ram-------------------------
signal  ena :  STD_LOGIC;
signal  wea :  STD_LOGIC_VECTOR(0 DOWNTO 0);
signal  dina :  STD_LOGIC_VECTOR(7 DOWNTO 0);
signal  clkb :  STD_LOGIC;
signal  enb :  STD_LOGIC;
signal  doutb :  STD_LOGIC_VECTOR(7 DOWNTO 0);
signal  image_cnta   : std_logic_vector(17 downto 0);
signal  image_cnt0   : std_logic_vector(15 downto 0);
signal  image_cnt1  : std_logic_vector(16 downto 0);
signal  image_cntb: std_logic_vector(17 downto 0);
signal  image_cntc: std_logic_vector(18 downto 0);
signal  data_rom:std_logic_vector(7 downto 0);
signal  data_romf:std_logic_vector(7 downto 0);
signal  h,v,TRACKSQ,harris_x,harris_y,harris_x2,harris_y2 : integer;
signal TRACKX  : integer range 64 to 656;
signal TRACKY  : integer range 48 to 432;
signal  pepiclk : integer ;
signal  pepiclks :std_logic_vector(59 downto 0);
--signal  pepi : std_logic_vector(0 downto 0);
signal  videout : std_logic_vector(7 downto 0);
SIGNAL TRACKORB : std_logic_vector(39 downto 0);
SIGNAL TRACKHARRIS : std_logic_vector(39 downto 0);
SIGNAL TRACKMATCHING : std_logic_vector(39 downto 0);
SIGNAL TRACKSTART: std_logic;
SIGNAL TRACKSIGN: std_logic;
signal TRACKstate:std_logic_vector(1 downto 0);
signal addrb_1:std_logic_vector(7 downto 0);
signal doutb_1:std_logic_vector(83 downto 0);
signal addrb_2:std_logic_vector(7 downto 0);
signal doutb_2:std_logic_vector(83 downto 0);
signal clkdiv:std_logic_vector(22 downto 0);
signal harris_sum:std_logic_vector(15 downto 0);
signal harris_sum_r:std_logic_vector(15 downto 0);
signal harris_sum_en:std_logic;
signal addra_rom:std_logic_vector(18 downto 0);
signal data_romb:std_logic_vector(7 downto 0);
signal addra_rom_r:std_logic_vector(16 downto 0);
signal data_romb_r:std_logic_vector(7 downto 0);
signal threshold  : std_logic_vector (43 downto 0);
signal video_data:std_logic_vector(7 downto 0);
signal harris_out:std_logic;
signal harris_out2:std_logic;
signal harris_out4:std_logic;
signal harris_out5:std_logic;
signal save_en:std_logic;
signal point :std_logic_vector(83 downto 0);
signal video_minus : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal video_minus2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal harris_sq  : STD_LOGIC_VECTOR(3 DOWNTO 0) ;
signal harris_P  : STD_LOGIC ;
signal harris_sq2  : STD_LOGIC_VECTOR(3 DOWNTO 0) ;
signal harris_P2   : STD_LOGIC ;
signal harris_output  : STD_LOGIC ;
signal matchr ,matchrp ,uvd : STD_LOGIC ;
signal uv ,deltax,deltay,tox,toy,UVTOTO : integer ;
signal romstate : STD_LOGIC_VECTOR(1 DOWNTO 0) ;
SIGNAL    RX1_UV , Ry1_UV , RX2_UV , Ry2_UV   : std_logic_vector(9 downto 0);
      signal video_rom : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL    data_rom1,data_rom2,data_rom3    : std_logic_vector(7 downto 0);
SIGNAL    i_TX_Byte  ,  i_TX_ByteO     : std_logic_vector(7 downto 0);
SIGNAL    o_TX_Active   : std_logic;
SIGNAL    i_TX_DV   : std_logic;
SIGNAL    o_TX_Done     :  std_logic;
SIGNAL    i_Clk         :  std_logic;      
SIGNAL    o_RX_DV   :  std_logic;
SIGNAL    o_RX_Byte     :  std_logic_vector(7 downto 0);

SIGNAL    wearray :  std_logic_vector(0 downto 0);
SIGNAL    enarray :  std_logic;
SIGNAL    array_cnt     : std_logic_vector(8 downto 0);
SIGNAL    brray_cnt     : std_logic_vector(8 downto 0);
signal harris_ripple    : std_logic;

SIGNAL    uv_8bitin, uv_8bitout ,uv_8bitinO, uv_8bitoutO   : std_logic_vector(7 downto 0);
--------------AFTER------

signal Y_vector_singal   : std_logic;
signal X_vector_singal   : std_logic;
signal delta_x            : integer;
signal delta_y            : integer;
signal delta_x1           : integer;
signal delta_y1           : integer;
signal delta_x2           : integer;
signal delta_y2           : integer;
signal delta_x3           : integer;
signal delta_y3           : integer;
signal delta_x4           : integer;
signal delta_y4           : integer;
signal delta_x5           : integer;
signal delta_y5           : integer;
signal delta_x6           : integer;
signal delta_y6           : integer;
signal delta_x7           : integer;
signal delta_y7           : integer;
signal turn_right_singal : std_logic;
signal image_cnt345600   : std_logic_vector(18 downto 0);
-- signal delay_video_minus : std_logic_vector( 7 downto 0);  
signal delay_video_minus : std_logic;  
signal turn_right_singal_buffer : std_logic_vector(3 downto 0);
signal signal_turn_right : std_logic;
signal minus_x           : integer;
signal minus_y           : integer;
signal x1_buf            : integer;
signal y1_buf            : integer;
signal harris_x3         : integer;
signal harris_y3         : integer;
signal harris_x4         : integer;
signal harris_y4         : integer;
signal harris_x5         : integer;
signal harris_y5         : integer;
signal harris_out3       : std_logic;
signal harris_sq3        : STD_LOGIC_VECTOR(3 DOWNTO 0);
signal harris_P3         : std_logic;
signal harris_trak_signal         : std_logic;
signal harris_trak_signal_cnt     : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal count8                     : std_logic_vector(2 downto 0);
signal x1,x1_2,y1,y1_2:integer;
signal x2,x2_2,y2,y2_2:integer;
signal x3,x3_2,y3,y3_2:integer;
signal x4,x4_2,y4,y4_2:integer;
signal x5,x5_2,y5,y5_2:integer;
signal x6,x6_2,y6,y6_2:integer;
signal x7,x7_2,y7,y7_2:integer;
signal x8,x8_2,y8,y8_2:integer;
signal xt,xt_2,yt,yt_2:integer;
signal x_select,y_select:integer;
signal orb_kp,orb_kp2 :std_logic;
signal harris_ripple2  : std_logic;
signal match_data,match_data1,match_data2,match_data3,match_data4,match_data5,match_data6,match_data7:std_logic_vector(39 downto 0);
signal video_minus_buf : std_logic_vector(7 downto 0);
signal SB_CRB_data_8_buf: std_logic_vector(7 downto 0);
signal video_minus_s: std_logic_vector(7 downto 0);
signal minus_data   : std_logic;
signal erotion_data  :std_logic_vector(7 downto 0);
signal erotion_data_1  :std_logic_vector(7 downto 0);
signal dilation_data  :std_logic_vector(7 downto 0);
signal turn_right_s       : std_logic;
signal turn_right_s_buf   : std_logic;
signal turn_left_s        : std_logic;
signal turn_left_s_buf    : std_logic;


type STATE_VGA is (start, ready, turn_right, turn_left, up, down, voice_up, voice_down, enlarge, shrink, close); 
signal vga_state : STATE_VGA ;
-------------------------------------方塊的產生點-----------------
signal square_h_start    : integer ; 
signal square_h_end      : integer ; 
signal square_v_start    : integer ; 
signal square_v_end      : integer ; 
signal enlarge_bit_cnt   : integer range 0 to 5 ; 

------------------------------------音量鍵的產生點----------------
signal voice_h_start   : integer ; 
signal voice_h_end     : integer ; 
signal voice_v_start   : integer ; 
signal voice_v_end     : integer ; 
signal voice_down_en   : std_logic;
signal voice_up_en     : std_logic;
--------------------------------------Vga顏色改變訊號-------------
signal blue_signal    : std_logic;
signal green_signal   : std_logic;
signal yellow_signal  : std_logic;
signal purple_signal  : std_logic;
--------------------------------------除頻電路訊號----------------
signal cnt            : integer;
-- signal CLK1K          : std_logic;
-- signal divcount : std_logic_vector(23 downto 0);
signal cnt1           : integer;
signal cnt2           : integer;
signal count100_cnt   : integer;

signal    turn_right_sw  :  std_logic;
signal    turn_left_sw   :  std_logic;
signal	  up_sw          :  std_logic;
signal	  down_sw        :  std_logic;
signal	  voice_up_sw    :  std_logic;
signal	  voice_down_sw  :  std_logic;
signal	  enlarge_sw     :  std_logic;
signal	  shrink_sw      :  std_logic;
signal	  close_sw       :  std_logic;
signal    turn_up_s_buf  :  std_logic;
signal    turn_down_s_buf    : std_logic;


begin
-------------------------------------------- 
o_video_minus <= video_minus;
o_vga_hs_cnt <= std_logic_vector(to_unsigned(vga_hs_cnt, 10));
o_vga_vs_cnt <= std_logic_vector(to_unsigned(vga_vs_cnt, 10));
o_match_data <= match_data;
--------------------------------------------
rst <= not reset;
----------------------------------ram----------------------------
--turn_left_sw  <= '0';
--up_sw         <= '0';
--down_sw       <= '0';
voice_up_sw   <= '0';
voice_down_sw <= '0';
enlarge_sw    <= '0';
shrink_sw     <= '0';

	sobel_0:sobel
 PORT MAP(
		rst             => rst,
		video_clk       => video_clk,
		video_data      => video_minus,
		SB_buf_012_en   => '1',
		buf_sobel_cc_en => '1',
		buf_data_state  => buf_data_state,
		SB_CRB_data     => SB_CRB_data,
		SB_CRB_data_8   => SB_CRB_data_8_buf
	);
	

--EROSION
erosion_0:erosion
 generic MAP(
	array_x     => 9,
	array_y     => 9,
	array_limit => "0000011000"
	)
 PORT MAP(
		rst             => rst,
		video_clk       => video_clk,
		in_ero_data     => minus_data ,
		ero_inte_data   => ero_inte_data,
		integral_sw     => '0',
		open_sw         => '1',
		close_sw        => '0',
		SB_buf_012_en   => '1',
		buf_ero_en      => '1',
		buf_data_state  => buf_data_state,
		ero_data        => ero_data
	);
	
	erosion_1:erosion
 generic MAP(
	array_x     => 9,
	array_y     => 9,
	array_limit => "0000011000"
	)
 PORT MAP(
		rst             => rst,
		video_clk       => video_clk,
		in_ero_data     => delay_video_minus ,
		ero_inte_data   => ero_inte_data,
		integral_sw     => '0',
		open_sw         => '1',
		close_sw        => '0',
		SB_buf_012_en   => '1',
		buf_ero_en      => '1',
		buf_data_state  => buf_data_state,
		ero_data        => ero_data_1
	);
	
	
--DILATION
dilation_0:dilation
 generic MAP(
	array_x => 3,
	array_y => 3
	)
 PORT MAP(
		rst             => rst,
		video_clk       => video_clk,
		in_dila_data    => minus_data,
		dila_inte_data  => dila_inte_data,
		integral_sw     => '0',
		open_sw         => '1',
		close_sw        => '0',
		SB_buf_012_en   => '1',
		buf_dila_en     => '1',
		buf_data_state  => buf_data_state,
		dila_data       => dila_data
	);

--dilation_1:dilation
-- generic MAP(
--	array_x => 3,
--	array_y => 3
--	)
-- PORT MAP(
--		rst             => rst,
--		video_clk       => video_clk,
--		in_dila_data    => dila_data,
--		dila_inte_data  => dila_inte_data_1,
--		integral_sw     => '0',
--		open_sw         => '1',
--		close_sw        => '0',
--		SB_buf_012_en   => '1',
--		buf_dila_en     => '1',
--		buf_data_state  => buf_data_state,
--		dila_data       => dila_data_1
--	);
    
-- blk_mem_gen_345600_0: blk_mem_gen_345600
    -- port map
    -- (
    -- clka  => video_clk,
    -- ena   => '1',
    -- wea   => "1",
    -- addra => image_cnt345600,
    -- dina  => video_gray_out,
    -- clkb  => video_clk,
    -- enb   => '1',
    -- addrb => image_cnt345600,
    -- doutb => delay_video_data
    -- );
blk_mem_gen_345600_1: blk_mem_gen_345600
    port map
    (
    clka  => video_clk,
    ena   => '1',
    wea   => "1",
    addra => image_cnt345600,
    dina  => video_minus(0),
    clkb  => video_clk,
    enb   => '1',
    addrb => image_cnt345600,
    doutb => delay_video_minus
    );
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    --BRAM1_0: BRAM1 -- front
--  PORT map
--  (
--    clka =>video_clk,
----    ena => '1',
--    addra =>image_cnta,
--    douta =>data_rom1
--  );
--
--BRAM2_0: BRAM2 --after
--  PORT map
--  (
--    clka =>video_clk,
----    ena => '1',
--    addra =>image_cnta,
--    douta =>data_rom2
--
--  );
------
--array_bram_0: array_bram
--  PORT map
--  (
--    clka => video_clk,
--    ena =>'1' ,
--    wea =>wearray,
--    addra =>array_cnt,
--    dina =>uv_8bitin,
--    clkb => video_clk,
--    enb =>'1' ,
--    addrb =>brray_cnt,
--    doutb =>uv_8bitout
--);
--
--arry_bramO_0: arry_bramO
--  PORT map
--  (
--    clka => video_clk,
----    ena =>'1' ,
--    wea =>wearray,
--    addra =>array_cnt,
--    dina =>uv_8bitinO,
--    clkb => video_clk,
----    enb =>'1' ,
--    addrb =>brray_cnt,
--    doutb =>uv_8bitoutO
--);
----------------------------------------敶勗??---------------------------

vga_1: vga_act_cnt
    generic map(
	
        horizontal_resolution => 720 ,
        horizontal_front_porch=>  16 ,
        horizontal_sync_pulse =>  62 ,
        horizontal_back_porch =>  59 ,
        h_sync_polarity       => '1' ,
        vertical_resolution   => 480 ,
        vertical_front_porch  =>   9 ,
        vertical_sync_pulse   =>   6 ,
        vertical_back_porch   =>  29 ,
        v_sync_polarity       => '1' 
    )
    port map(
        clk =>video_clk ,
        rst =>rst,
        video_start_en =>'1',
        vga_hs_cnt =>vga_hs_cnt,
        vga_vs_cnt =>vga_vs_cnt
        -- hsync      =>hsync,
        -- vsync      =>vsync_s
    );

rout<=r(7 downto 4);
gout<=g(7 downto 4);
bout<=b(7 downto 4);

match_0:match
port map
(
	rst=>rst,
	video_clk => video_clk,
	clk=>video_clk,
	match_en=>match_en,
	brief_addrb_1=>brief_addrb_1,
	brief_addrb_2=>brief_addrb_2,
	a=>breif_data_1,
	b=>breif_data_2,
	addrb=>match_addr,
	--pepi=>pepi,
	MATE_D  =>match_data,
	MATE_D1 =>match_data1,
	MATE_D2 =>match_data2,
	MATE_D3 =>match_data3,
	MATE_D4 =>match_data4,
	MATE_D5 =>match_data5,
	MATE_D6 =>match_data6,
	MATE_D7 =>match_data7
	
);
orb_0 :orb
port map(
	   clk=>video_clk,
	   video_clk        => video_clk,
		rst=>rst,
		save_en=>save_en,
		kp_en =>harris_out2,
		vga_hs_cnt=>vga_hs_cnt,
		vga_vs_cnt=>vga_vs_cnt,
		BOUT_1=>breif_data_1,
		ping_pong_out_2_out=>ping_pong_out_2,		
		video_data=>video_gray_out,
		TRACKORB => match_data,
        TRACKX =>TRACKX,
        TRACKY =>TRACKY,
        TRACKSQ =>TRACKSQ
 );

orb2_0 :orb2
port map(
	   clk=>video_clk,
	   video_clk        => video_clk,
		rst=>rst,
		save_en=>save_en,
		kp_en =>harris_out3,
		vga_hs_cnt=>vga_hs_cnt,
		vga_vs_cnt=>vga_vs_cnt,
		BOUT_2=>breif_data_2,
		ping_pong_out_2_out=>ping_pong_out_2,		
		video_data=>delay_video_data,
		TRACKORB => match_data,
        TRACKX =>TRACKX,
        TRACKY =>TRACKY,
        TRACKSQ =>TRACKSQ
 );


harris_0:harris
port map(
	clk=>video_clk,
	rst=>rst,
	video_clk => video_clk,
	video_data=>video_minus,
	vga_hs_cnt=>vga_hs_cnt,
	vga_vs_cnt=>vga_vs_cnt,
	threshold=>(25=>'1' ,others=>'0'),
	--threshold=>threshold,
	harris_out=>harris_out,
	harris_x => harris_x,
	harris_y => harris_y,
	TRACKHARRIS => match_data,
	TRACKX =>TRACKX,
	TRACKY =>TRACKY,
	TRACKSQ =>TRACKSQ
);

---
harris2_0:harris2
port map(
	clk=>video_clk,
	rst=>rst,
	video_clk => video_clk,
    video_data=>erotion_data,
	vga_hs_cnt=>vga_hs_cnt,
	vga_vs_cnt=>vga_vs_cnt,
	threshold=>(35 =>'1',others=>'0'),
	--threshold=>threshold,
	harris_out2=>harris_out2,
	harris_x2 => harris_x2,
	harris_y2 => harris_y2,
	TRACKHARRIS => match_data,
	TRACKX =>TRACKX,
	TRACKY =>TRACKY,
	TRACKSQ =>TRACKSQ
);

---------
harris_3:harris2
port map(
	clk=>video_clk,
	rst=>rst,
	video_clk => video_clk,
	video_data=> erotion_data_1,
	vga_hs_cnt=>vga_hs_cnt,
	vga_vs_cnt=>vga_vs_cnt,
	threshold=>(35 =>'1',others=>'0'),
	--threshold=>threshold,
	harris_out2 =>harris_out3,
	harris_x2   => harris_x3,
	harris_y2   => harris_y3,
	TRACKHARRIS => match_data,
	TRACKX =>TRACKX,
	TRACKY =>TRACKY,
	TRACKSQ =>TRACKSQ
);


harris2_gray:harris2
port map(
	clk=>video_clk,
	rst=>rst,
	video_clk => video_clk,
    video_data=>erotion_data,
	vga_hs_cnt=>vga_hs_cnt,
	vga_vs_cnt=>vga_vs_cnt,
	threshold=>(24=>'1',others=>'0'),
	--threshold=>threshold,
	harris_out2=>harris_out4,
	harris_x2 => harris_x4,
	harris_y2 => harris_y4,
	TRACKHARRIS => match_data,
	TRACKX =>TRACKX,
	TRACKY =>TRACKY,
	TRACKSQ =>TRACKSQ
);
---------
harris_gray:harris2
port map(
	clk=>video_clk,
	rst=>rst,
		

	video_clk => video_clk,
	video_data=> erotion_data_1,
	vga_hs_cnt=>vga_hs_cnt,
	vga_vs_cnt=>vga_vs_cnt,
	threshold=>(24=>'1',others=>'0'),
	--threshold=>threshold,
	harris_out2 =>harris_out5,
	harris_x2   => harris_x5,
	harris_y2   => harris_y5,
	TRACKHARRIS => match_data,
	TRACKX =>TRACKX,
	TRACKY =>TRACKY,
	TRACKSQ =>TRACKSQ
);


------------------front_back-----------------------------2/26

PROCESS(video_clk ,rst)
    BEGIN
    IF(RST='0')THEN
        video_minus_s <= "00000000";
        ELSIF rising_edge(video_clk)THEN
           if(delay_video_data < video_gray_out )then
                video_minus_s<="00000000";
            else  
                video_minus_s <= delay_video_data - video_gray_out;                   
            end if;
--                minus_x <= vga_hs_cnt;
--                minus_y <= vga_vs_cnt;
    end if;
END PROCESS;

PROCESS(video_clk ,rst)
    BEGIN
    IF(RST='0')THEN
        video_minus <= "00000000";
        minus_data  <= '0';
        ELSIF rising_edge(video_clk)THEN
           if(delay_video_data < 50)then
               if( video_minus_s > 6  and  video_minus_s < 160)then
                   video_minus <= "11111111";
                   minus_data  <= '1';
               else
                   video_minus <= "00000000";
                   minus_data  <= '0';
               end if;
           elsif(delay_video_data > 50 and delay_video_data < 100)then
               if( (video_minus_s > 10 and video_minus_s < 75)  )then
                   video_minus <= "11111111";
                   minus_data  <= '1';
               else
                   video_minus <= "00000000";
                   minus_data  <= '0';
               end if; 
           elsif(delay_video_data > 100 and delay_video_data < 150)then
               if( (video_minus_s > 15 and video_minus_s < 35)  )then
                   video_minus <= "11111111";
                   minus_data  <= '1';
               else
                   video_minus <= "00000000";
                   minus_data  <= '0';
               end if;
           elsif(delay_video_data > 150 and delay_video_data < 200)then
               if( (video_minus_s > 15 and video_minus_s < 60) )then
                   video_minus <= "11111111";
                   minus_data  <= '1';
               else
                   video_minus <= "00000000";
                   minus_data  <= '0';
               end if;
           elsif(delay_video_data > 200 )then
               if( (video_minus_s < 100 and video_minus_s > 25 ) )then
                   video_minus <= "11111111";
                   minus_data  <= '1';
               else
                   video_minus <= "00000000";
                   minus_data  <= '0';
               end if;
           end if;
    end if;
END PROCESS;
-------------------------------------------------------------------
X1        <=CONV_INTEGER(match_data(9 downto 0));
X1_2      <=CONV_INTEGER(match_data(29 downto 20));
Y1        <=CONV_INTEGER(match_data(19 downto 10));
Y1_2      <=CONV_INTEGER(match_data(39 downto 30));

X2        <=CONV_INTEGER(match_data1(9 downto 0));
X2_2      <=CONV_INTEGER(match_data1(29 downto 20));
Y2        <=CONV_INTEGER(match_data1(19 downto 10));
Y2_2      <=CONV_INTEGER(match_data1(39 downto 30));

X3        <=CONV_INTEGER(match_data2(9 downto 0));
X3_2      <=CONV_INTEGER(match_data2(29 downto 20));
Y3        <=CONV_INTEGER(match_data2(19 downto 10));
Y3_2      <=CONV_INTEGER(match_data2(39 downto 30));

X4        <=CONV_INTEGER(match_data3(9 downto 0));
X4_2      <=CONV_INTEGER(match_data3(29 downto 20));
Y4        <=CONV_INTEGER(match_data3(19 downto 10));
Y4_2      <=CONV_INTEGER(match_data3(39 downto 30));

X5        <=CONV_INTEGER(match_data4(9 downto 0));
X5_2      <=CONV_INTEGER(match_data4(29 downto 20));
Y5        <=CONV_INTEGER(match_data4(19 downto 10));
Y5_2      <=CONV_INTEGER(match_data4(39 downto 30));

X6        <=CONV_INTEGER(match_data5(9 downto 0));
X6_2      <=CONV_INTEGER(match_data5(29 downto 20));
Y6        <=CONV_INTEGER(match_data5(19 downto 10));
Y6_2      <=CONV_INTEGER(match_data5(39 downto 30));

X7        <=CONV_INTEGER(match_data6(9 downto 0));
X7_2      <=CONV_INTEGER(match_data6(29 downto 20));
Y7        <=CONV_INTEGER(match_data6(19 downto 10));
Y7_2      <=CONV_INTEGER(match_data6(39 downto 30));

X8        <=CONV_INTEGER(match_data7(9 downto 0));
X8_2      <=CONV_INTEGER(match_data7(29 downto 20));
Y8        <=CONV_INTEGER(match_data7(19 downto 10));
Y8_2      <=CONV_INTEGER(match_data7(39 downto 30));


----------------------------------------------------------------------

----------------------CHANG MATCHING
--X1<=CONV_INTEGER(match_data(9 downto 0));
--X2<=CONV_INTEGER(match_data(29 downto 20));
--Y1<=CONV_INTEGER(match_data(19 downto 10));
--Y2<=CONV_INTEGER(match_data(39 downto 30));
-- deltax <= X1 - X2 ;
-- deltay <= y1 - y2 ;


--------------------X正負號判斷-------------------------
--
--process(RST,VIDEO_clk)
--begin
--	if(rst = '0')then
--		X_vector_singal <= '0';
--	elsif rising_edge(video_clk)then
--		if(X1 > X1_2)then
--			X_vector_singal <= '1'; ---------向右
--		elsif(X1 < X1_2)then
--			X_vector_singal <= '0'; ---------向左
--		else
--			null;
--		end if;
--	end if;
--end process;

-------------------------------------------------

--------------------Y正負號判斷-------------------------
--
--process(RST,VIDEO_clk)
--begin
--	if(rst = '0')then
--		Y_vector_singal <= '0';
--	elsif rising_edge(video_clk)then
--		if(Y1 > Y1_2)then
--			Y_vector_singal <= '1'; -------向下
--		elsif(Y1 < Y1_2)then
--			Y_vector_singal <= '0'; -------向上
--		else
--			null;
--		end if;
--	end if;
--end process;

-- process(clk,rst)
-- begin
    -- if(rst = '0')then
        -- count_268435456 <= "0000000000000000000000000000";
    -- elsif rising_edge(video_clk)then
        -- if(count_268435456 <   "1111111111111111111111111111")then
            -- count_268435456 <= count_268435456 + '1';
        -- else
            -- count_268435456 <= "0000000000000000000000000000";
        -- end if;
    -- end if;
-- end process;

-------------------------------------------------
-- process(rst,video_clk,x_select,y_select)
-- begin
    -- if(rst = '0')then
        -- turn_right_s_buf <= '0';
    -- elsif rising_edge(video_clk)then
        -- if(x_select > 590 and y_select > 100 and y_select < 380)then
            -- turn_right_s_buf <= '1';
        -- else
            -- turn_right_s_buf <= '0';
        -- end if;
    -- end if;

-- end process;

-- process(rst,video_clk,tox,toy)
-- begin
    -- if(rst = '0')then
        -- turn_right_sw <= '0';
    -- elsif rising_edge(video_clk)then
        -- if(turn_right_s_buf = '1')then
            -- if(count_268435456 = "1111111111111111111111111111")then
                -- turn_right_sw <= '1';
            -- else
                -- turn_right_sw <= '0';
            -- end if;  
        -- else
            -- turn_right_sw <= '0';
        -- end if;
    -- end if;
-- end process;

-- process(rst,video_clk,x_select,y_select)
-- begin
    -- if(rst = '0')then
        -- turn_left_s_buf <= '0';
    -- elsif rising_edge(video_clk)then
        -- if(x_select < 150 and y_select > 100 and y_select < 380)then
            -- turn_left_s_buf <= '1';
        -- else
            -- turn_left_s_buf <= '0';
        -- end if;
    -- end if;

-- end process;

-- process(rst,video_clk,tox,toy)
-- begin
    -- if(rst = '0')then
        -- turn_left_sw <= '0';
    -- elsif rising_edge(video_clk)then
        -- if(turn_left_s_buf = '1')then
            -- if(count_268435456 = "1111111111111111111111111111")then
                -- turn_left_sw <= '1';
            -- else
                -- turn_left_sw <= '0';
            -- end if;  
        -- else
            -- turn_left_sw <= '0';
        -- end if;
    -- end if;
-- end process;

-- process(rst,video_clk,x_select,y_select)
-- begin
    -- if(rst = '0')then
        -- turn_up_s_buf <= '0';
    -- elsif rising_edge(video_clk)then
        -- if(x_select > 50 and x_select < 670 and y_select < 115 )then
            -- turn_up_s_buf <= '1';
        -- else
            -- turn_up_s_buf <= '0';
        -- end if;
    -- end if;

-- end process;

-- process(rst,video_clk,tox,toy)
-- begin
    -- if(rst = '0')then
        -- up_sw <= '0';
    -- elsif rising_edge(video_clk)then
        -- if(turn_up_s_buf = '1')then
            -- if(count_268435456 = "1111111111111111111111111111")then
                -- up_sw <= '1';
            -- else
                -- up_sw <= '0';
            -- end if;  
        -- else
            -- up_sw <= '0';
        -- end if;
    -- end if;
-- end process;

-- process(rst,video_clk,x_select,y_select)
-- begin
    -- if(rst = '0')then
        -- turn_down_s_buf <= '0';
    -- elsif rising_edge(video_clk)then
        -- if(x_select > 50 and x_select < 670 and y_select > 365 )then
            -- turn_down_s_buf <= '1';
        -- else
            -- turn_down_s_buf <= '0';
        -- end if;
    -- end if;

--end process;

-- process(rst,video_clk,tox,toy)
-- begin
    -- if(rst = '0')then
        -- down_sw <= '0';
    -- elsif rising_edge(video_clk)then
        -- if(turn_down_s_buf = '1')then
            -- if(count_268435456 = "1111111111111111111111111111")then
                -- down_sw <= '1';
            -- else
                -- down_sw <= '0';
            -- end if;  
        -- else
            -- down_sw <= '0';
        -- end if;
    -- end if;
-- end process;
--process(rst,video_clk,tox,toy)
--begin
--    if(rst = '0')then
--        turn_left_s_buf <= '0';
--    else
--        if(tox < 140 and toy > 100 and toy < 380)then
--            turn_left_s_buf <= '1';
--        else
--            turn_left_s_buf <= '0';
--        end if;
--    end if;
--
--end process;
--
--process(rst,video_clk,tox,toy)
--begin
--    if(rst = '0')then
--        turn_left_s <= '0';
--    else
--        if(turn_left_s_buf = '1')then
--            if(count_268435456 = "11111111111111111111111111111")then
--                turn_left_s <= '1';
--            else
--                null;
--            end if;  
--        else
--            turn_left_s <= '0';
--        end if;
--    end if;
--end process;

------------------harris_point--------------------
process(rst,VIDEO_clk)
begin
    if(rst = '0')then
        harris_ripple <= '0';
    elsif rising_edge(video_clk)then
--        if(  harris_out2 = '1' and harris_out3 = '1')then
--            harris_ripple <= '0';
        if(harris_out4 = '0' and harris_out2 = '1')then
            harris_ripple <= '1';
        else 
            harris_ripple <= '0';
        end if;
    end if;
end process;

------------------harris_point--------------------
process(rst,VIDEO_clk)
begin
    if(rst = '0')then
        harris_ripple2 <= '0';
    elsif rising_edge(video_clk)then
        if( harris_out3 = '1' and harris_out5 = '0' )then
            harris_ripple2 <= '1';
        else
            harris_ripple2 <= '0';
        end if;
    end if;
end process;


------------------turn_right_singal----------------

--process(RST,VIDEO_clk)
--begin
--	if(rst = '0')then
--		turn_right_singal <= '0';
--	elsif rising_edge(video_clk)then
--		if (X_vector_singal = '1' and delta_x < 24 and delta_x > 5 and delta_y < 10) then
--			turn_right_singal <= '1';
--		else
--			turn_right_singal <= '0';
--		end if;
--	end if;
--end process;

-----------------------turn_right_singal_buffer-----------------------------
--process(RST,VIDEO_clk)
--begin
--	if(rst = '0')then
--		turn_right_singal_buffer <= "0000";
--	elsif rising_edge(video_clk)then
--	    
--		    turn_right_singal_buffer <= turn_right_singal_buffer(2 downto 0) &  turn_right_singal;
--		
--	end if;
--end process;
----------------------------------------------------

-----------------------turn_right_singal_buffer-----------------------------
--process(RST,VIDEO_clk)
--begin
--	if(rst = '0')then
--		signal_turn_right <= '0';
--	elsif rising_edge(video_clk)then
--		if(turn_right_singal_buffer = "1111")then
--		    signal_turn_right <= '1';
--		else 
--		    signal_turn_right <= '0'; 
--		end if;		    
--	end if;
--end process;
----------------------------------------------------
--signal_test <= signal_turn_right;
-------------------------------------


----------------------------------------------------

--PROCESS(RST,TRACKSIGN,video_clk)
--BEGIN
--    if rst='0'then
--           tox <= 0;     
--           toy <= 0;
--    elsif rising_edge(video_clk)then
--
--        if uv >= 20 then
--           tox <= X1;     
--           toy <= Y1; 
--        ELSE
--           tox <= tox;     
--           toy <= toy; 
--
--        END IF;
--        
--    end if;
--END PROCESS;
------------------------
PROCESS(RST,TRACKSIGN,video_clk)
BEGIN
    if rst='0'then
           TRACKstate <= "00";     
    elsif rising_edge(video_clk)then
        IF TRACKstate < "10" THEN 
            IF  X1 > 296  and X1 < 424 and Y1 > 176 and Y1 < 302 THEN
               TRACKstate <= TRACKstate + "01";
            END IF;
        ELSE
            TRACKstate <= "10";
        END IF;
    end if;
END PROCESS;
---------------TRACK FSM ------------------
-----------
process(rst,video_clk)
begin
if rst = '0' then
    TRACKSIGN  <= '0';
    TRACKSTART <= '0';
    TRACKX <= 360;
    TRACKY <= 240;	
elsif video_clk'event and video_clk= '1' then
	case TRACKstate is 
		when "00"=>
			null;				
		when "01"=>
			null;		
		when "10"=>
			TRACKX <= tox;
            TRACKY <= toy;
--            if(delta_x < 90 and delta_y < 50 and delta_x > 5 and delta_y > 5)then
--                tox <= x1;
--                toy <= y1;
--            else 
--                NULL;
--            end if;			
		when others=>
			null;		
	end case;
end if;
end process;

TRACKSQ <= 72 ;

--
tox <= x_select;
toy <= y_select;

--tox <= x1;
--toy <= y1;

--process(rst,video_clk)
--begin
--if rst = '0' then
--    tox <= 360;
--    toy <= 240;
--elsif video_clk'event and video_clk = '1' then
--	if ( (delta_x < 90 and delta_y < 50 and delta_x > 5 and delta_y > 5)
--	       or (delta_x < 50 and delta_y < 90 and delta_x > 5 and delta_y > 5)) then
--           tox <= X1;     
--           toy <= Y1;
--    else
--        tox <= tox;
--        toy <= toy;
--    end if;
--end if;
--end process;


--------------------------前後張相減---------------------

----------------------------------
--process( rst , video_clk,vga_hs_cnt , vga_vs_cnt ,harris_sq)
--begin
--if rst = '0' then
--    r <= "00000000";
--    g <= "00000000";
--    b <= "00000000";
--elsif video_clk'event and video_clk = '1' then
--
--	if (vga_hs_cnt >0  and vga_hs_cnt <720 
--	and vga_vs_cnt>=0 and vga_vs_cnt<480) then  	
--	                r <=  ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data;         
--                    g <=  ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data;       
--                    b <=  ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data;
--	                r <=  SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data;         
--                    g <=  SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data;       
--                    b <=  SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data;
--        pepi <= '0';
    --		
--        IF( harris_out4 = '1')then
--            r <= "11111111"; 
--            g <= "00000000";
--            b <= "00000000";
--        elsif(harris_out2 = '1')then
--            r <= "00000011"; 
--            g <= "11111111";
--            b <= "00000000";
--        elsif
--    vga_hs_cnt > X1-3  and vga_vs_cnt < Y1+3 
--		   and vga_hs_cnt < X1+3  and vga_vs_cnt > Y1-3 then
--			 r <= "00000000";
--			 g <= "11111111";
--			 b <= "00000000";
------             matchr <= '1';
--       vga_hs_cnt > X1-10  and vga_vs_cnt < Y1+10 
--		   and vga_hs_cnt < X1+10  and vga_vs_cnt > Y1-10 then
--			 r <= "00000000";
--			 g <= "11111111";
--			 b <= "00000000";
------------------orb_test--------
--		 if
--		   harris_ripple = '1' then
--			 r <= "11110000";
--			 g <= "00000000";
--			 b <= "00001111";
--		elsif( harris_ripple2  = '1')then
--		     r <= "00000000";
--			 g <= "11100000";
--			 b <= "00000000";
--	    elsif(orb_kp = '0')then
--	         r <= "00000000";
--			 g <= "00000000";
--			 b <= "11110000";
		---------------------can_see_matching--------------
--		elsif(vga_hs_cnt > tox - 3 and vga_hs_cnt < tox + 3 and vga_vs_cnt > toy - 3 and vga_vs_cnt < toy + 3)then
--		     r <= "00000000";
--			 g <= "11110000";
--			 b <= "00000000";
--        elsif(vga_hs_cnt > x8 - 2  and vga_hs_cnt < x8 + 2    and vga_vs_cnt > y8 - 2   and vga_vs_cnt < y8 + 2)then	
--			 r <= "11100000";
--			 g <= "00000000";
--			 b <= "00000000";
--		elsif(vga_hs_cnt > x8_2 - 2 and vga_hs_cnt < x8_2 + 2 and vga_vs_cnt > y8_2 - 2 and vga_vs_cnt < y8_2 + 2)then
--			 r <= "11100000";
--			 g <= "00000000";
--			 b <= "00000000";
--		elsif(vga_hs_cnt > x7 - 3  and vga_hs_cnt < x7 + 3    and vga_vs_cnt > y7 - 3   and vga_vs_cnt < y7 + 3)then	
--			 r <= "11110000";
--			 g <= "11110000";
--			 b <= "11110000";
--		elsif(vga_hs_cnt > x7_2 - 3 and vga_hs_cnt < x7_2 + 3 and vga_vs_cnt > y7_2 - 3 and vga_vs_cnt < y7_2 + 3)then
--			 r <= "11110000";
--			 g <= "11110000";
--			 b <= "11110000";
--		elsif(vga_hs_cnt > x6 - 4  and vga_hs_cnt < x6 + 4    and vga_vs_cnt > y6 - 4   and vga_vs_cnt < y6 + 4)then	
--			 r <= "00000000";
--			 g <= "00000000";
--			 b <= "10000000";
--		elsif(vga_hs_cnt > x6_2 - 4 and vga_hs_cnt < x6_2 + 4 and vga_vs_cnt > y6_2 - 4 and vga_vs_cnt < y6_2 + 4)then
--			 r <= "00000000";
--			 g <= "00000000";
--			 b <= "10000000";
--	    elsif(vga_hs_cnt > x5 - 5  and vga_hs_cnt < x5 + 5    and vga_vs_cnt > y5 - 5   and vga_vs_cnt < y5 + 5)then	
--			 r <= "00000000";
--			 g <= "01000000";
--			 b <= "00100000";
--		elsif(vga_hs_cnt > x5_2 - 5 and vga_hs_cnt < x5_2 + 5 and vga_vs_cnt > y5_2 - 5 and vga_vs_cnt < y5_2 + 5)then
--			 r <= "00000000";
--			 g <= "01000000";
--			 b <= "00100000";
--		elsif(vga_hs_cnt > x4 - 6  and vga_hs_cnt < x4 + 6    and vga_vs_cnt > y4 - 6   and vga_vs_cnt < y4 + 6)then	
--			 r <= "00000000";
--			 g <= "01000000";
--			 b <= "00000000";
--		elsif(vga_hs_cnt > x4_2 - 6 and vga_hs_cnt < x4_2 + 6 and vga_vs_cnt > y4_2 - 6 and vga_vs_cnt < y4_2 + 6)then
--			 r <= "00000000";
--			 g <= "01000000";
--			 b <= "00000000";
--	    elsif(vga_hs_cnt > x3 - 7  and vga_hs_cnt < x3 + 7    and vga_vs_cnt > y3 - 7   and vga_vs_cnt < y3 + 7)then	
--			 r <= "10000000";
--			 g <= "10000000";
--			 b <= "00000000";
--		elsif(vga_hs_cnt > x3_2 - 7 and vga_hs_cnt < x3_2 + 7 and vga_vs_cnt > y3_2 - 7 and vga_vs_cnt < y3_2 + 7)then
--			 r <= "10000000";
--			 g <= "10000000";
--			 b <= "00000000";
--		elsif(vga_hs_cnt > x2 - 8 and vga_hs_cnt < x2 + 8 and vga_vs_cnt > y2 - 8 and vga_vs_cnt < y2 + 8)then	
--			 r <= "00000000";
--			 g <= "10000000";
--			 b <= "10000000";
--		elsif(vga_hs_cnt > x2_2 - 8 and vga_hs_cnt < x2_2 + 8 and vga_vs_cnt > y2_2 - 8 and vga_vs_cnt < y2_2 + 8)then
--			 r <= "00000000";
--			 g <= "10000000";
--			 b <= "10000000";
--	   elsif(vga_hs_cnt > x1 - 9 and vga_hs_cnt < x1 + 9 and vga_vs_cnt > y1 - 9 and vga_vs_cnt < y1 + 9)then	
--			 r <= "10000000";
--			 g <= "00000000";
--			 b <= "10000000" ;
--		elsif(vga_hs_cnt > x1_2 - 9 and vga_hs_cnt < x1_2 + 9 and vga_vs_cnt > y1_2 - 9 and vga_vs_cnt < y1_2 + 9)then
--			 r <= "10000000";
--			 g <= "00000000";
--			 b <= "10000000";
		 
--		      vga_hs_cnt < TRACKX - TRACKSQ  and vga_hs_cnt > TRACKX - TRACKSQ - 5
--		  and vga_hs_cnt > TRACKX + TRACKSQ  and vga_hs_cnt < TRACKX + TRACKSQ + 5
--	      and vga_vs_cnt < TRACKY - TRACKSQ  and vga_vs_cnt > TRACKY - TRACKSQ - 3
--	      and vga_vs_cnt > TRACKY + TRACKSQ  and vga_vs_cnt < TRACKY + TRACKSQ + 3 then
--			 r <= "11100000";
--			 g <= "11000000";
--			 b <= "11011111";	      
--		 elsif
--		  vga_hs_cnt > X2-3  and vga_vs_cnt < Y2+3 
--		       and vga_hs_cnt < X2+3  and vga_vs_cnt > Y2-3 then
--			 r <= "11100000";
--			 g <= "00000000";
--			 b <= "11111111";
--
--		 elsif vga_hs_cnt > X1-3  and vga_vs_cnt < Y1+3 
--		   and vga_hs_cnt < X1+3  and vga_vs_cnt > Y1-3   then
--			 r <= "00011111";
--			 g <= "10010010";
--			 b <= "10010000";
-----------------------------------------------------
--        elsif(signal_turn_right = '1')then
--            if( vga_hs_cnt >0  and vga_hs_cnt <720 
--                and vga_vs_cnt>=0 and vga_vs_cnt<480 )then
--                r <= "11100000";
--                g <= "00100000";
--                b <= "01000000";
--            else
--               null;
--            end if;
--		 elsif vga_hs_cnt > X1-7 and vga_vs_cnt < Y1+7 
--		   and vga_hs_cnt < X1+7 and vga_vs_cnt > Y1-7
--		   AND uv >= 60	THEN 
--			 r <= "11111110";
--			 g <= "00000000";
--			 b <= "00001100";
--		 elsif  vga_vs_cnt > harris_y-30 
--            and vga_vs_cnt < harris_y+30 
--            and vga_hs_cnt > harris_x-30 
--            and vga_hs_cnt < harris_x+30 AND  harris_sw='0'	THEN 
--			 r <= "00000000";
--			 g <= "00011110";
--			 b <= "00000000";		  	 
--		 elsif   vga_hs_cnt > TRACKX - TRACKSQ  
--             and vga_hs_cnt < TRACKX + TRACKSQ 
--             and vga_vs_cnt > TRACKY - TRACKSQ 
--             and vga_vs_cnt < TRACKY + TRACKSQ   
--             and harris_out='1' and harris_sw='0'then
--			 r <= "11111111";
--			 g <= "00000000";
--			 b <= "00000000";
--		 elsif   vga_hs_cnt > TRACKX - TRACKSQ + 8  
--             and vga_hs_cnt < TRACKX + TRACKSQ - 8
--             and vga_vs_cnt > TRACKY - TRACKSQ + 8
--             and vga_vs_cnt < TRACKY + TRACKSQ - 8 
--             and harris_out2='1' and harris_sw='0'then
--             r <= "00011111";
--			 g <= "11100000";
--			 b <= "00000000";
--	   elsif (vga_hs_cnt >0  and vga_hs_cnt <720 
--	and vga_vs_cnt>=0 and vga_vs_cnt<480 and harris_out3 = '1') then
--	         r <= "00011111";
--			 g <= "11000000";
--			 b <= "11100000";		
----------------------------------harris----------
--            (harris_trak_signal = '1')then
--                 r <= "00001111";
--			     g <= "00001111";
--			     b <= "11111111";            
--            elsif
--            (harris_out3 = '1')then
--            
--                 r <= "00001111";
--			     g <= "11111111";
--			     b <= "00001111";
--			     
--			 elsif 
--			 (harris_out2 = '1' )then
--			     r <= "11111111";
--			     g <= "00001111";
--			     b <= "00001111";
--------------------------------------------------	
--            if (vga_hs_cnt = minus_x and vga_vs_cnt = minus_y) then
--              r <= "11110000";
--		        g <= "00000000";
--		        b <= "00000000";	
--------------------------------------------------
-------------------recognize-------------------
--         elsif(turn_right_s <= '1')then	 
--            	if(vga_hs_cnt > 360  )then	
--            	    r <= "00000000";
--                    g <= "00000000";
--                    b <= "11111111";
--            	else
--            	    r <= video_gray_out;
--                    g <= video_gray_out;
--                    b <= video_gray_out;
--            	end if; 	
         		 
--			 elsif 
--			 (vga_hs_cnt >0  
--             and vga_hs_cnt < 720 
--             and vga_vs_cnt >= 0
--             and vga_vs_cnt < 480 
--             and color_sw='1')then
--             r <= video_minus;
--			 g <= video_minus;
--			 b <= video_minus;
  	 
--         elsif 
--         (vga_hs_cnt > 0  
--             and vga_hs_cnt < 720 
--             and vga_vs_cnt >= 0 
--             and vga_vs_cnt < 480 
--             and color_sw='0')then     
--	                r <=  dila_data & dila_data & dila_data & dila_data & dila_data & dila_data & dila_data & dila_data;         
--                    g <=  dila_data & dila_data & dila_data & dila_data & dila_data & dila_data & dila_data & dila_data;       
--                    b <=  dila_data & dila_data & dila_data & dila_data & dila_data & dila_data & dila_data & dila_data;
                    
--                    r <=  ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data;         
--                    g <=  ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data;       
--                    b <=  ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data;
--                    r <= video_gray_out;
--                    g <= video_gray_out;
--                    b <= video_gray_out;
                    
--                    r <= video_minus;
--                    g <= video_minus;
--                    b <= video_minus;
--                    
--         else
--	                r <=  ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data;         
--                    g <=  ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data;       
--                    b <=  ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data;
--	                r <=  SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data;         
--                    g <=  SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data;       
--                    b <=  SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data & SB_CRB_data;
--                    r <= video_gray_out;
--                    g <= video_gray_out;
--                    b <= video_gray_out;
--                if(turn_right_s = '1')then
--                   if(vga_hs_cnt > 450 )then 
--                      r <= "00000000";
--		              g <= "00000000";
--		              b <= "11100000";
--		           end if;
--		        else
--		            r <= video_gray_out;
--                    g <= video_gray_out;
--                    b <= video_gray_out;
--                end if;
--		 end if;
--	else
--		 r <= "00000000";
--		 g <= "00000000";
--		 b <= "00000000";	
--	end if;
--end if;
--end process;

erotion_data  <= ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data & ero_data;
erotion_data_1  <= ero_data_1 & ero_data_1 & ero_data_1 & ero_data_1 & ero_data_1 & ero_data_1 & ero_data_1 & ero_data_1;

dilation_data <= dila_data & dila_data & dila_data & dila_data & dila_data & dila_data & dila_data & dila_data;
---------------------------------------------------------------
--process(rst,video_clk,harris_sq)
--begin
--if rst = '0' then
--    harris_sq <= "0000" ;
--elsif video_clk'event and video_clk = '1' then
--	if (     vga_vs_cnt > harris_y-15 
--         and vga_vs_cnt < harris_y+15 
--         and vga_hs_cnt > harris_x-15 
--         and vga_hs_cnt < harris_x+15 )then     
--	     harris_sq <= harris_sq + 1 ;
--    ELSE
--	     harris_sq <= "0000";
--	END IF;	
--end if;
--end process;

--process(rst,video_clk,harris_P)
--begin
--if rst = '0' then
--    harris_P <= '0' ;
--elsif video_clk'event and video_clk = '1' then
--	if ( harris_sq > 5 and harris_out = '1')then     
--	     harris_P <= '1';  
--    ELSE
--	     harris_P <= '0';
--	END IF;	
--end if;
--end process;
--------------------------------------
--process(rst,video_clk,harris_sq2)
--begin
--if rst = '0' then
--    harris_sq2 <= "0000" ;
--elsif video_clk'event and video_clk = '1' then
--	if  (    vga_vs_cnt > harris_y2 - 60 
--         and vga_vs_cnt < harris_y2 + 60 
--         and vga_hs_cnt > harris_x2 - 60 
--         and vga_hs_cnt < harris_x2 + 60 )then     
--	     harris_sq2 <= harris_sq2 + 1 ;
--    ELSE
--	     harris_sq2 <= "0000";                                                                     
--	END IF;
--end if;	                                                                                                                                                         
--end process;
--
--process(rst,video_clk,harris_sq3,harris_out3)
--begin
--if rst = '0' then
--    harris_P2 <= '0' ;
--elsif video_clk'event and video_clk = '1' then
--	if ( harris_sq2 > 3 and harris_out2 = '1')then     
--	     harris_P2 <= '1';  
--    ELSE
--	     harris_P2 <= '0';
--	END IF;	
--end if;
--end process;
--
--process(rst,video_clk,harris_sq)
--begin
--if rst = '0' then
--    harris_sq3 <= "0000" ;
--elsif video_clk'event and video_clk = '1' then
--	if (     vga_vs_cnt > harris_y3 - 60 
--         and vga_vs_cnt < harris_y3 + 60 
--         and vga_hs_cnt > harris_x3 - 60 
--         and vga_hs_cnt < harris_x3 + 60 )then     
--	     harris_sq3 <= harris_sq3 + 1 ;
--    ELSE
--	     harris_sq3 <= "0000";
--	END IF;	
--end if;
--end process;
--
--process(rst,video_clk,harris_sq3,harris_out3)
--begin
--if rst = '0' then
--    harris_P3 <= '0' ;
--elsif video_clk'event and video_clk = '1' then
--	if ( harris_sq3 > 3 and harris_out3 = '1')then     
--	     harris_P3 <= '1';  
--    ELSE
--	     harris_P3 <= '0';
--	END IF;	
--end if;
--end process;

-------------------div_cnt----------------------------------------------
--process(rst,clk,clkdiv)
--begin
--if rst = '0' then
--       clkdiv<="00000000000000000000000";
--elsif clk'event and clk = '1' then
--       clkdiv<=clkdiv+"00000000000000000000001";
--end if;
--end process;

-------------------div_cnt----------------------------------------------
process(video_clk,rst)
begin
    if(rst = '0')then
        count_33554431 <= "0000000000000000000000";
    elsif rising_edge(video_clk)then
        if(count_33554431 <   "1111111111111111111111")then
            count_33554431 <= count_33554431 + '1';
        else
            count_33554431 <= "0000000000000000000000";
        end if;
    end if;
end process;

---------------div_cnt-----------------------------

PROCESS(video_clk ,rst,image_cnta)
BEGIN
IF(rst='0')THEN
    image_cnt345600 <= "0000000000000000000";
elsif video_clk'event and video_clk = '1' then
--if swstop = '0' then 
    IF(h< 720 )THEN
		IF(v < 480)THEN
		  image_cnt345600 <= std_logic_vector(to_unsigned(h + 720*v,19)); 
         ELSE 
            image_cnt345600 <= "0000000000000000000";      
         END IF;
     END IF; 
END IF;
END PROCESS;

---------------mor_state--------------------

Buf_state:process(rst, video_clk,  vga_vs_cnt)
begin
	if rst = '0' then
		range_total_cnt    <= 0;
		buf_sobel_cc_delay <= 0;
		range_total_cnt_en <= '0';
		buf_Y_temp_en      <= '0';
		SB_buf_012_en      <= '0';
		buf_sobel_cc_en    <= '0';
		SBB_buf_en         <= '0';
		buf_ero_en         <= '0';
		buf_dila_en        <= '0';
		buf_inte_en        <= '0';
		buf_data_state     <= "00";
	elsif rising_edge(video_clk) then
			if buf_data_state = "11" then
				buf_data_state <= "00";
			else
				buf_data_state <= buf_data_state + '1';
			end if;
			if ( vga_vs_cnt < 220) then
				if range_total_cnt_en = '0' then
					if buf_data_state = "11" then
						range_total_cnt_en <= '1';
						SBB_buf_en         <= '1';
						SB_buf_012_en      <= '1';
						buf_sobel_cc_en    <= '1';
						buf_ero_en         <= '1';
						buf_dila_en        <= '1';
						buf_inte_en        <= '1';
					end if;
				else
					if range_total_cnt < 720 then	--1280
						SBB_buf_en      <= '1';
						SB_buf_012_en   <= '1';
						buf_sobel_cc_en <= '1';
						buf_ero_en      <= '1';
						buf_dila_en     <= '1';
						buf_inte_en     <= '1';
					else
						SBB_buf_en      <= '0';
						SB_buf_012_en   <= '0';
						buf_sobel_cc_en <= '0';
						buf_ero_en      <= '0';
						buf_dila_en     <= '0';
						buf_inte_en     <= '0';
					end if;
					if range_total_cnt = 729 then	--1289 then
						range_total_cnt <= 729;	--1289;
					else
						range_total_cnt <= range_total_cnt + 1;
					end if;
				end if;
			else
			if vga_vs_cnt > 220 then
					buf_sobel_cc_delay <= 0;
				end if;
				range_total_cnt    <= 0;
				range_total_cnt_en <= '0';
				SB_buf_012_en      <= '0';
				buf_sobel_cc_en    <= '0';
				SBB_buf_en         <= '0';
				buf_ero_en         <= '0';
				buf_dila_en        <= '0';
				buf_inte_en        <= '0';
			end if;
		
	end if;
end process Buf_state;
--------------------------------------------------------------
---------------------delta_compare-------------------
process(rst,video_clk)
begin
    if(rst = '0')then
        x_select <= 360 ;
        y_select <= 240 ;
    elsif rising_edge(video_clk)then
        if(count_33554431 = "1111111111111111111111")then
            if( delta_x + delta_y > delta_x1 + delta_y1
            and delta_x + delta_y > delta_x2 + delta_y2
            and delta_x + delta_y > delta_x3 + delta_y3
            and delta_x + delta_y > delta_x4 + delta_y4
            and delta_x + delta_y > delta_x5 + delta_y5
            and delta_x + delta_y > delta_x6 + delta_y6
            and delta_x + delta_y > delta_x7 + delta_y7)then
                x_select <= x1 ;
                y_select <= y1 ;
            elsif (delta_x1 + delta_y1 > delta_x + delta_y
            and    delta_x1 + delta_y1 > delta_x2 + delta_y2
            and    delta_x1 + delta_y1 > delta_x3 + delta_y3
            and    delta_x1 + delta_y1 > delta_x4 + delta_y4
            and    delta_x1 + delta_y1 > delta_x5 + delta_y5
            and    delta_x1 + delta_y1 > delta_x6 + delta_y6
            and    delta_x1 + delta_y1 > delta_x7 + delta_y7)then
                x_select <= x2 ;
                y_select <= y2 ;
            elsif (delta_x2 + delta_y2 > delta_x + delta_y
            and    delta_x2 + delta_y2 > delta_x1 + delta_y1
            and    delta_x2 + delta_y2 > delta_x3 + delta_y3
            and    delta_x2 + delta_y2 > delta_x4 + delta_y4
            and    delta_x2 + delta_y2 > delta_x5 + delta_y5
            and    delta_x2 + delta_y2 > delta_x6 + delta_y6
            and    delta_x2 + delta_y2 > delta_x7 + delta_y7)then
                x_select <= x3 ;
                y_select <= y3 ;
            elsif (delta_x3 + delta_y3 > delta_x + delta_y
            and    delta_x3 + delta_y3 > delta_x1 + delta_y1
            and    delta_x3 + delta_y3 > delta_x2 + delta_y2
            and    delta_x3 + delta_y3 > delta_x4 + delta_y4
            and    delta_x3 + delta_y3 > delta_x5 + delta_y5
            and    delta_x3 + delta_y3 > delta_x6 + delta_y6
            and    delta_x3 + delta_y3 > delta_x7 + delta_y7)then
                x_select <= x4 ;
                y_select <= y4 ;
            elsif (delta_x4 + delta_y4 > delta_x + delta_y
            and    delta_x4 + delta_y4 > delta_x1 + delta_y1
            and    delta_x4 + delta_y4 > delta_x2 + delta_y2
            and    delta_x4 + delta_y4 > delta_x3 + delta_y3
            and    delta_x4 + delta_y4 > delta_x5 + delta_y5
            and    delta_x4 + delta_y4 > delta_x6 + delta_y6
            and    delta_x4 + delta_y4 > delta_x7 + delta_y7)then
                x_select <= x5 ;
                y_select <= y5 ;
            elsif (delta_x5 + delta_y5 > delta_x + delta_y
            and    delta_x5 + delta_y5 > delta_x1 + delta_y1
            and    delta_x5 + delta_y5 > delta_x2 + delta_y2
            and    delta_x5 + delta_y5 > delta_x3 + delta_y3
            and    delta_x5 + delta_y5 > delta_x4 + delta_y4
            and    delta_x5 + delta_y5 > delta_x6 + delta_y6
            and    delta_x5 + delta_y5 > delta_x7 + delta_y7)then
                x_select <= x6 ;
                y_select <= y6 ;
            elsif (delta_x6 + delta_y6 > delta_x + delta_y
            and    delta_x6 + delta_y6 > delta_x1 + delta_y1
            and    delta_x6 + delta_y6 > delta_x2 + delta_y2
            and    delta_x6 + delta_y6 > delta_x3 + delta_y3
            and    delta_x6 + delta_y6 > delta_x4 + delta_y4
            and    delta_x6 + delta_y6 > delta_x5 + delta_y5
            and    delta_x6 + delta_y6 > delta_x7 + delta_y7)then
                x_select <= x7 ;
                y_select <= y7 ;
            elsif (delta_x7 + delta_y7 > delta_x + delta_y
            and    delta_x7 + delta_y7 > delta_x1 + delta_y1
            and    delta_x7 + delta_y7 > delta_x2 + delta_y2
            and    delta_x7 + delta_y7 > delta_x3 + delta_y3
            and    delta_x7 + delta_y7 > delta_x4 + delta_y4
            and    delta_x7 + delta_y7 > delta_x5 + delta_y5
            and    delta_x7 + delta_y7 > delta_x6 + delta_y6)then
                x_select <= x8 ;
                y_select <= y8 ;
            else
                x_select <= x_select;
                y_select <= y_select;
            
            end if;
        else
            null;
        end if;
    end if;
end process;
----------------------delta_x------------------------

process(RST,VIDEO_clk)
begin
	if(rst = '0')then
		delta_x <= 0;
	elsif rising_edge(video_clk)then
    if( vga_hs_cnt > TRACKX - TRACKSQ and vga_hs_cnt < TRACKX + TRACKSQ 
	and vga_vs_cnt > TRACKY - TRACKSQ and vga_vs_cnt < TRACKY + TRACKSQ
	and vga_hs_cnt > 64 and vga_hs_cnt < 656
	and vga_vs_cnt > 32 and vga_vs_cnt < 448 )then
            if(X1 > X1_2)then
                delta_x <= X1 - X1_2; ---------向右
            elsif(X1 < X1_2)then
                delta_x <= X1_2 - X1; ---------向左
            else
                null;
            end if;
        end if;
	end if;
end process;

-----------------------------------------------------
---------------------delta_y------------------------
process(RST,VIDEO_clk)
begin
	if(rst = '0')then
		delta_y <= 0;
	elsif rising_edge(video_clk)then
    if( vga_hs_cnt > TRACKX - TRACKSQ and vga_hs_cnt < TRACKX + TRACKSQ 
	and vga_vs_cnt > TRACKY - TRACKSQ and vga_vs_cnt < TRACKY + TRACKSQ
	and vga_hs_cnt > 64 and vga_hs_cnt < 656
	and vga_vs_cnt > 32 and vga_vs_cnt < 448 )then
            if(Y1 > Y1_2)then
                delta_y <= Y1 - Y1_2; -------向下
            elsif(Y1 < Y1_2)then
                delta_y <= Y1_2 - Y1; -------向上
            else
                null;
            end if;
        end if;
	end if;
end process;
----------------------------------------------------
----------------------delta_x1------------------------

process(RST,VIDEO_clk)
begin
	if(rst = '0')then
		delta_x1 <= 0;
	elsif rising_edge(video_clk)then
    if( vga_hs_cnt > TRACKX - TRACKSQ and vga_hs_cnt < TRACKX + TRACKSQ 
	and vga_vs_cnt > TRACKY - TRACKSQ and vga_vs_cnt < TRACKY + TRACKSQ
	and vga_hs_cnt > 64 and vga_hs_cnt < 656
	and vga_vs_cnt > 32 and vga_vs_cnt < 448 )then
            if(X2 > X2_2)then
                delta_x1 <= X2 - X2_2; ---------向右
            elsif(X2 < X2_2)then
                delta_x1 <= X2_2 - X2; ---------向左
            else
                null;
            end if;
        end if;
	end if;
end process;

-----------------------------------------------------
---------------------delta_y1------------------------
process(RST,VIDEO_clk)
begin
	if(rst = '0')then
		delta_y1 <= 0;
	elsif rising_edge(video_clk)then
    if( vga_hs_cnt > TRACKX - TRACKSQ and vga_hs_cnt < TRACKX + TRACKSQ 
	and vga_vs_cnt > TRACKY - TRACKSQ and vga_vs_cnt < TRACKY + TRACKSQ
	and vga_hs_cnt > 64 and vga_hs_cnt < 656
	and vga_vs_cnt > 32 and vga_vs_cnt < 448 )then
            if(Y2 > Y2_2)then
                delta_y1 <= Y2 - Y2_2; -------向下
            elsif(Y2 < Y2_2)then
                delta_y1 <= Y2_2 - Y2; -------向上
            else
                null;
            end if;
        end if;
	end if;
end process;
----------------------------------------------------
----------------------delta_x2------------------------

process(RST,VIDEO_clk)
begin
	if(rst = '0')then
		delta_x2 <= 0;
	elsif rising_edge(video_clk)then
    if( vga_hs_cnt > TRACKX - TRACKSQ and vga_hs_cnt < TRACKX + TRACKSQ 
	and vga_vs_cnt > TRACKY - TRACKSQ and vga_vs_cnt < TRACKY + TRACKSQ
	and vga_hs_cnt > 64 and vga_hs_cnt < 656
	and vga_vs_cnt > 32 and vga_vs_cnt < 448 )then
            if(X3 > X3_2)then
                delta_x2 <= X3 - X3_2; ---------向右
            elsif(X3 < X3_2)then
                delta_x2 <= X3_2 - X3; ---------向左
            else
                null;
            end if;
        end if;
	end if;
end process;

-----------------------------------------------------
---------------------delta_y2------------------------
process(RST,VIDEO_clk)
begin
	if(rst = '0')then
		delta_y2 <= 0;
	elsif rising_edge(video_clk)then
    if( vga_hs_cnt > TRACKX - TRACKSQ and vga_hs_cnt < TRACKX + TRACKSQ 
	and vga_vs_cnt > TRACKY - TRACKSQ and vga_vs_cnt < TRACKY + TRACKSQ
	and vga_hs_cnt > 64 and vga_hs_cnt < 656
	and vga_vs_cnt > 32 and vga_vs_cnt < 448 )then
            if(Y3 > Y3_2)then
                delta_y2 <= Y3 - Y3_2; -------向下
            elsif(Y3 < Y3_2)then
                delta_y2 <= Y3_2 - Y3; -------向上
            else
                null;
            end if;
        end if;
	end if;
end process;
----------------------------------------------------
----------------------delta_x3------------------------

process(RST,VIDEO_clk)
begin
	if(rst = '0')then
		delta_x3 <= 0;
	elsif rising_edge(video_clk)then
    if( vga_hs_cnt > TRACKX - TRACKSQ and vga_hs_cnt < TRACKX + TRACKSQ 
	and vga_vs_cnt > TRACKY - TRACKSQ and vga_vs_cnt < TRACKY + TRACKSQ
	and vga_hs_cnt > 64 and vga_hs_cnt < 656
	and vga_vs_cnt > 32 and vga_vs_cnt < 448 )then
            if(X4 > X4_2)then
                delta_x3 <= X4 - X4_2; ---------向右
            elsif(X4 < X4_2)then
                delta_x3 <= X4_2 - X4; ---------向左
            else
                null;
            end if;
        end if;
	end if;
end process;

-----------------------------------------------------
---------------------delta_y3------------------------
process(RST,VIDEO_clk)
begin
	if(rst = '0')then
		delta_y3 <= 0;
	elsif rising_edge(video_clk)then
    if( vga_hs_cnt > TRACKX - TRACKSQ and vga_hs_cnt < TRACKX + TRACKSQ 
	and vga_vs_cnt > TRACKY - TRACKSQ and vga_vs_cnt < TRACKY + TRACKSQ
	and vga_hs_cnt > 64 and vga_hs_cnt < 656
	and vga_vs_cnt > 32 and vga_vs_cnt < 448 )then
            if(Y4 > Y4_2)then
                delta_y3 <= Y4 - Y4_2; -------向下
            elsif(Y4 < Y4_2)then
                delta_y3 <= Y4_2 - Y4; -------向上
            else
                null;
            end if;
        end if;
	end if;
end process;
----------------------------------------------------
----------------------delta_x4------------------------

process(RST,VIDEO_clk)
begin
	if(rst = '0')then
		delta_x4 <= 0;
	elsif rising_edge(video_clk)then
    if( vga_hs_cnt > TRACKX - TRACKSQ and vga_hs_cnt < TRACKX + TRACKSQ 
	and vga_vs_cnt > TRACKY - TRACKSQ and vga_vs_cnt < TRACKY + TRACKSQ
	and vga_hs_cnt > 64 and vga_hs_cnt < 656
	and vga_vs_cnt > 32 and vga_vs_cnt < 448 )then
            if(X5 > X5_2)then
                delta_x4 <= X5 - X5_2; ---------向右
            elsif(X5 < X5_2)then
                delta_x4 <= X5_2 - X5; ---------向左
            else
                null;
            end if;
        end if;
	end if;
end process;

-----------------------------------------------------
---------------------delta_y4------------------------
process(RST,VIDEO_clk)
begin
	if(rst = '0')then
		delta_y4 <= 0;
	elsif rising_edge(video_clk)then
    if( vga_hs_cnt > TRACKX - TRACKSQ and vga_hs_cnt < TRACKX + TRACKSQ 
	and vga_vs_cnt > TRACKY - TRACKSQ and vga_vs_cnt < TRACKY + TRACKSQ
	and vga_hs_cnt > 64 and vga_hs_cnt < 656
	and vga_vs_cnt > 32 and vga_vs_cnt < 448 )then
            if(Y5 > Y5_2)then
                delta_y4 <= Y5 - Y5_2; -------向下
            elsif(Y5 < Y5_2)then
                delta_y4 <= Y5_2 - Y5; -------向上
            else
                null;
            end if;
        end if;
	end if;
end process;
----------------------------------------------------
----------------------delta_x5------------------------

process(RST,VIDEO_clk)
begin
	if(rst = '0')then
		delta_x5 <= 0;
	elsif rising_edge(video_clk)then
    if( vga_hs_cnt > TRACKX - TRACKSQ and vga_hs_cnt < TRACKX + TRACKSQ 
	and vga_vs_cnt > TRACKY - TRACKSQ and vga_vs_cnt < TRACKY + TRACKSQ
	and vga_hs_cnt > 64 and vga_hs_cnt < 656
	and vga_vs_cnt > 32 and vga_vs_cnt < 448 )then
            if(X6 > X6_2)then
                delta_x5 <= X6 - X6_2; ---------向右
            elsif(X6 < X6_2)then
                delta_x5 <= X6_2 - X6; ---------向左
            else
                null;
            end if;
        end if;
	end if;
end process;

-----------------------------------------------------
---------------------delta_y5------------------------
process(RST,VIDEO_clk)
begin
	if(rst = '0')then
		delta_y5 <= 0;
	elsif rising_edge(video_clk)then
    if( vga_hs_cnt > TRACKX - TRACKSQ and vga_hs_cnt < TRACKX + TRACKSQ 
	and vga_vs_cnt > TRACKY - TRACKSQ and vga_vs_cnt < TRACKY + TRACKSQ
	and vga_hs_cnt > 64 and vga_hs_cnt < 656
	and vga_vs_cnt > 32 and vga_vs_cnt < 448 )then
            if(Y6 > Y6_2)then
                delta_y5 <= Y6 - Y6_2; -------向下
            elsif(Y6 < Y6_2)then
                delta_y5 <= Y6_2 - Y6; -------向上
            else
                null;
            end if;
        end if;
	end if;
end process;
----------------------------------------------------
----------------------delta_x6------------------------

process(RST,VIDEO_clk)
begin
	if(rst = '0')then
		delta_x6 <= 0;
	elsif rising_edge(video_clk)then
    if( vga_hs_cnt > TRACKX - TRACKSQ and vga_hs_cnt < TRACKX + TRACKSQ 
	and vga_vs_cnt > TRACKY - TRACKSQ and vga_vs_cnt < TRACKY + TRACKSQ
	and vga_hs_cnt > 64 and vga_hs_cnt < 656
	and vga_vs_cnt > 32 and vga_vs_cnt < 448 )then
            if(X7 > X7_2)then
                delta_x6 <= X7 - X7_2; ---------向右
            elsif(X7 < X7_2)then
                delta_x6 <= X7_2 - X7; ---------向左
            else
                null;
            end if;
        end if;
	end if;
end process;

-----------------------------------------------------
---------------------delta_y6------------------------
process(RST,VIDEO_clk)
begin
	if(rst = '0')then
		delta_y6 <= 0;
	elsif rising_edge(video_clk)then
    if( vga_hs_cnt > TRACKX - TRACKSQ and vga_hs_cnt < TRACKX + TRACKSQ 
	and vga_vs_cnt > TRACKY - TRACKSQ and vga_vs_cnt < TRACKY + TRACKSQ
	and vga_hs_cnt > 64 and vga_hs_cnt < 656
	and vga_vs_cnt > 32 and vga_vs_cnt < 448 )then
            if(Y7 > Y7_2)then
                delta_y6 <= Y7 - Y7_2; -------向下
            elsif(Y7 < Y7_2)then
                delta_y6 <= Y7_2 - Y7; -------向上
            else
                null;
            end if;
        end if;
	end if;
end process;
----------------------------------------------------
----------------------delta_x7------------------------

process(RST,VIDEO_clk)
begin
	if(rst = '0')then
		delta_x7 <= 0;
	elsif rising_edge(video_clk)then
    if( vga_hs_cnt > TRACKX - TRACKSQ and vga_hs_cnt < TRACKX + TRACKSQ 
	and vga_vs_cnt > TRACKY - TRACKSQ and vga_vs_cnt < TRACKY + TRACKSQ
	and vga_hs_cnt > 64 and vga_hs_cnt < 656
	and vga_vs_cnt > 32 and vga_vs_cnt < 448 )then
            if(X8 > X8_2)then
                delta_x7 <= X8 - X8_2; ---------向右
            elsif(X8 < X8_2)then
                delta_x7 <= X8_2 - X8; ---------向左
            else
                null;
            end if;
        end if;
	end if;
end process;

-----------------------------------------------------
---------------------delta_y7------------------------
process(RST,VIDEO_clk)
begin
	if(rst = '0')then
		delta_y7 <= 0;
	elsif rising_edge(video_clk)then
    if( vga_hs_cnt > TRACKX - TRACKSQ and vga_hs_cnt < TRACKX + TRACKSQ 
	and vga_vs_cnt > TRACKY - TRACKSQ and vga_vs_cnt < TRACKY + TRACKSQ
	and vga_hs_cnt > 64 and vga_hs_cnt < 656
	and vga_vs_cnt > 32 and vga_vs_cnt < 448 )then
            if(Y8 > Y8_2)then
                delta_y7 <= Y8 - Y8_2; -------向下
            elsif(Y8 < Y8_2)then
                delta_y7 <= Y8_2 - Y8; -------向上
            else
                null;
            end if;
        end if;
	end if;
end process;
----------------------------------------------------



process( rst , video_clk    ,vga_hs_cnt , vga_vs_cnt ,blue_signal,green_signal,mode_sw,vga_state)
begin
	if rst = '0' then
		r <= "00000000";
		g <= "00000000";
		b <= "00000000";
	elsif rising_edge(video_clk) then
		case vga_state is
		    when start =>
				if (vga_hs_cnt < 720  and vga_vs_cnt < 480 ) then
					if (mode_sw='1') then   
						r <= video_r_out;         
						g <= video_g_out;         
						b <= video_b_out;         
					else
						r <= video_gray_out;         
						g <= video_gray_out;         
						b <= video_gray_out;
					end if;
				else
					r <= "00000000";
					g <= "00000000";
					b <= "00000000";
				end if;
			when others =>
				if (vga_hs_cnt < 720  and vga_vs_cnt < 480)then
					if(( vga_hs_cnt > tox - 5  and vga_hs_cnt < tox + 5 and vga_vs_cnt > toy - 5 and vga_vs_cnt < toy + 5))then
					    r <= "00001111";
						g <= "00000000";
						b <= "11110000";
					elsif(    (vga_hs_cnt > 594 and vga_hs_cnt < 650 and vga_vs_cnt > 320 and vga_vs_cnt < 324)    
						or (vga_hs_cnt > 594 and vga_hs_cnt < 650 and vga_vs_cnt > 366 and vga_vs_cnt < 370) 
						or (vga_hs_cnt > 594 and vga_hs_cnt < 598 and vga_vs_cnt > 320 and vga_vs_cnt < 370)
						or (vga_hs_cnt > 646 and vga_hs_cnt < 650 and vga_vs_cnt > 320 and vga_vs_cnt < 370)			
						or (vga_hs_cnt > 390 and vga_hs_cnt < 446 and vga_vs_cnt > 320 and vga_vs_cnt < 324)
						or (vga_hs_cnt > 390 and vga_hs_cnt < 446 and vga_vs_cnt > 366 and vga_vs_cnt < 370)
						or (vga_hs_cnt > 390 and vga_hs_cnt < 394 and vga_vs_cnt > 320 and vga_vs_cnt < 370)
						or (vga_hs_cnt > 442 and vga_hs_cnt < 446 and vga_vs_cnt > 320 and vga_vs_cnt < 370)
						or (vga_hs_cnt > 492 and vga_hs_cnt < 548 and vga_vs_cnt > 420 and vga_vs_cnt < 424)
						or (vga_hs_cnt > 492 and vga_hs_cnt < 548 and vga_vs_cnt > 466 and vga_vs_cnt < 470)
						or (vga_hs_cnt > 492 and vga_hs_cnt < 496 and vga_vs_cnt > 420 and vga_vs_cnt < 470)
						or (vga_hs_cnt > 544 and vga_hs_cnt < 548 and vga_vs_cnt > 420 and vga_vs_cnt < 470)
						or (vga_hs_cnt > 492 and vga_hs_cnt < 548 and vga_vs_cnt > 220 and vga_vs_cnt < 224)
						or (vga_hs_cnt > 492 and vga_hs_cnt < 548 and vga_vs_cnt > 266 and vga_vs_cnt < 270)
						or (vga_hs_cnt > 492 and vga_hs_cnt < 496 and vga_vs_cnt > 220 and vga_vs_cnt < 270)
						or (vga_hs_cnt > 544 and vga_hs_cnt < 548 and vga_vs_cnt > 220 and vga_vs_cnt < 270)
						or (vga_hs_cnt > voice_h_start and vga_hs_cnt < voice_h_end 
						and vga_vs_cnt > voice_v_start and vga_vs_cnt < voice_v_end)
						or (vga_hs_cnt > square_h_start - enlarge_bit_cnt and vga_hs_cnt < square_h_end + enlarge_bit_cnt 
						and vga_vs_cnt > square_v_start - enlarge_bit_cnt and vga_vs_cnt < square_v_end + enlarge_bit_cnt)
						or harris_out2 = '1') then
						r <= "11111111";
						g <= "00000000";
						b <= "00000000";
					elsif ((vga_hs_cnt > 594 and vga_hs_cnt < 650 and vga_vs_cnt > 320 and vga_vs_cnt < 370)) then
						if (blue_signal = '1')then
							r <= "00000000";         
							g <= "00000000";         
							b <= "11111111";
						else
							if (mode_sw='1') then   
								r <= video_r_out;         
								g <= video_g_out;         
								b <= video_b_out;         
							else
								r <= video_gray_out;         
								g <= video_gray_out;         
								b <= video_gray_out;
							end if;
						end if;
					elsif (vga_hs_cnt > 390 and vga_hs_cnt < 446 and vga_vs_cnt > 320 and vga_vs_cnt < 370) then
						if (green_signal = '1')then
							r <= "00000000";         
							g <= "11111111";         
							b <= "00000000";
						else
							if (mode_sw='1') then   
								r <= video_r_out;         
								g <= video_g_out;         
								b <= video_b_out;         
							else
								r <= video_gray_out;         
								g <= video_gray_out;         
								b <= video_gray_out;
							end if;
						end if;
					elsif (vga_hs_cnt > 492 and vga_hs_cnt < 548 and vga_vs_cnt > 220 and vga_vs_cnt < 270) then
						if (yellow_signal = '1')then
							r <= "11111111";         
							g <= "11111111";         
							b <= "00000000";
						else
							if (mode_sw='1') then   
								r <= video_r_out;         
								g <= video_g_out;         
								b <= video_b_out;         
							else
								r <= video_gray_out;         
								g <= video_gray_out;         
								b <= video_gray_out;
							end if;	
						end if;
					elsif (vga_hs_cnt > 492 and vga_hs_cnt < 548 and vga_vs_cnt > 420 and vga_vs_cnt < 470) then		
						if (purple_signal = '1')then
							r <= "10100000";         
							g <= "00100000";         
							b <= "11110000";
						else
							if (mode_sw='1') then   
								r <= video_r_out;         
								g <= video_g_out;         
								b <= video_b_out;         
							else
								r <= video_gray_out;         
								g <= video_gray_out;         
								b <= video_gray_out;
							end if;
						end if;		
					else
						if (mode_sw='1') then   
							r <= video_r_out;         
							g <= video_g_out;         
							b <= video_b_out;         
						else
							r <= video_gray_out;         
							g <= video_gray_out;         
							b <= video_gray_out;
						end if;
					end if;
				else
					r <= "00000000";
					g <= "00000000";
					b <= "00000000";
				end if;
		end case;	
	end if;
end process;

--type STATE_VGA is (start, ready, turn_right, turn_left, up, down, voice_up, voice_down, enlarge, shrink, finish); 
--signal vga_state : STATE_VGA ;
--FSM

process(video_clk, rst, square_h_start, square_v_start, star_up_sw, turn_right_sw, turn_left_sw, up_sw, voice_up_sw,
        voice_up_en, voice_down_en, voice_v_start, voice_down_sw, down_sw, enlarge_sw, enlarge_bit_cnt)
begin
	if rst = '0' then
		vga_state  <= start;
	elsif rising_edge(video_clk) then
		case vga_state is 
			when start => 
				if(star_up_sw = '1')then
					vga_state <= ready;
				else
					vga_state <= start;
				end if;                
			when ready => 
				if (turn_right_sw = '1') then 
					vga_state <= turn_right;
				elsif (turn_left_sw = '1') then
					vga_state <= turn_left;	
                elsif (up_sw = '1')then
					vga_state <= up;
				elsif (down_sw = '1')then
					vga_state <= down;
				elsif (voice_up_sw = '1') then
					vga_state <= voice_up;
				elsif (voice_down_sw = '1')then
				    vga_state <= voice_down;
				elsif (enlarge_sw = '1')then
					vga_state <= enlarge;
				elsif (shrink_sw = '1')then
					vga_state <= shrink;
				elsif (close_sw = '1')then
					vga_state <= close;
				else
					vga_state <= ready;
				end if;
			when turn_right =>
				if (square_h_start = 618) then
					vga_state <= ready;
				else
					null;
				end if;
			when turn_left =>
				if (square_h_start = 414) then
					vga_state <= ready;
				else
					null;
				end if;
			when up =>
				if (square_v_start = 241) then
					vga_state <= ready;
				end if;
			when down =>
				if (square_v_start = 441) then
					vga_state <= ready;
				end if;
			when voice_up =>
				-- if (voice_v_start = 145)then  -------可以正常上升
					-- vga_state <= ready;
				-- end if;
				if (voice_v_start = 145 and voice_up_en = '0')then 
					vga_state <= ready;
				else
					if (voice_v_start = 155 and voice_up_en = '1')then
						vga_state <= ready;
					else
						if (voice_v_start = 165 and voice_up_en = '0')then
							vga_state <= ready;
						else
							if (voice_v_start = 175 and voice_up_en = '1')then
								vga_state <= ready;
							else
								if (voice_v_start = 185 and voice_up_en = '0')then
									vga_state <= ready;
								else
									if (voice_v_start = 195 and voice_up_en = '1')then
										vga_state <= ready;
									else
										if (voice_v_start = 205 and voice_up_en = '0')then
											vga_state <= ready;
										else
											if (voice_v_start = 215 and voice_up_en = '1')then
												vga_state <= ready;
											else
												if (voice_v_start = 225 and voice_up_en = '0')then
													vga_state <= ready;
												else
													if (voice_v_start = 235 and voice_up_en = '1')then
														vga_state <= ready;
													end if;
												end if ;
											end if ;
										end if;
									end if;
								end if;
							end if;
						end if;
					end if;
				end if;	
			when voice_down =>
				if (voice_v_start = 245)then
					vga_state <= ready;
				else
					if (voice_v_start = 235 and voice_down_en = '1')then
						vga_state <= ready;
					else
						if (voice_v_start = 225 and voice_down_en = '0')then
							vga_state <= ready;
						else
							if (voice_v_start = 215 and voice_down_en = '1')then
								vga_state <= ready;
							else
								if (voice_v_start = 205 and voice_down_en = '0')then
									vga_state <= ready;
								else
									if (voice_v_start = 195 and voice_down_en = '1')then
										vga_state <= ready;
									else
										if (voice_v_start = 185 and voice_down_en = '0')then
											vga_state <= ready;
										else
											if (voice_v_start = 175 and voice_down_en = '1')then
												vga_state <= ready;
											else
												if (voice_v_start = 165 and voice_down_en = '0')then
													vga_state <= ready;
												else
													if (voice_v_start = 155 and voice_down_en = '1')then
														vga_state <= ready;
													else
														if (voice_v_start = 145 and voice_down_en = '0')then
															vga_state <= ready;
														end if;
													end if ;
												end if ;
											end if;
										end if;
									end if;
								end if;
							end if;
						end if;
					end if;	
				end if;
			when enlarge =>
				if (enlarge_bit_cnt = 5)then
					vga_state <= ready;
				else
					if (enlarge_bit_cnt = 4)then
						vga_state <= ready;
					else
						if (enlarge_bit_cnt = 3)then
							vga_state <= ready;
						else
							if (enlarge_bit_cnt = 2)then
								vga_state <= ready;
							else
								if (enlarge_bit_cnt = 1)then
									vga_state <= ready;
								end if;
							end if ;
						end if;
					end if;
				end if;
			when shrink =>
				if (enlarge_bit_cnt = 0)then
					vga_state <= ready;
				else
					if (enlarge_bit_cnt = 1)then
						vga_state <= ready;
					else
						if (enlarge_bit_cnt = 2)then
							vga_state <= ready;
						else
							if (enlarge_bit_cnt = 3)then
								vga_state <= ready;
							else
								if (enlarge_bit_cnt = 4)then
									vga_state <= ready;
								end if;
							end if ;
						end if;
					end if;
				end if;	
			when close =>
				vga_state <= start;
			when others =>
			    null;
		 end case ;
	end if;
end process;

------------------------------------------------
------------方塊的四個角產生座標----------------
------------square_h_start----------------------

process(video_clk, rst, vga_state, cnt, cnt2, turn_right_sw, turn_left_sw ,down_sw, up_sw)
begin
	if rst = '0' then
		square_h_start <= 516;
	elsif rising_edge(video_clk) then
		case vga_state is 
			when start =>
				square_h_start <= 516;
			when ready =>
				null;
			when turn_right => 
				if (square_h_start < 618) then
					IF(cnt = 100000)THEN
						square_h_start <= square_h_start + 1 ;	
					end if;
				end if;
			when turn_left => 
				if (square_h_start > 414) then
					IF(cnt = 100000)THEN
						square_h_start <= square_h_start - 1 ;	
					end if;
				end if;
			when up =>
                square_h_start <= 516 ;
			when down =>
                square_h_start <= 516 ;
			when voice_up =>
				null;
			when voice_down =>
				null;
			when enlarge =>
				null;
			when shrink =>
				null;
			when others => 
				square_h_start <= 516;
		end case ;
	end if;
end process;


------------square_h_end----------------------

process(video_clk, rst, vga_state, cnt, cnt2, turn_right_sw, turn_left_sw ,down_sw, up_sw)
begin
if rst = '0' then
    square_h_end <= 524;
elsif rising_edge(video_clk) then
    case vga_state is
        when start =>
			square_h_end <= 524;
		when ready =>
			null;
        when turn_right => 
			if (square_h_end < 626) then
				IF(cnt = 100000)THEN
					square_h_end <= square_h_end + 1 ;
				end if;
            end if;
        when turn_left => 
			if (square_h_end > 422) then
				IF(cnt = 100000)THEN
					square_h_end <= square_h_end - 1 ;
				end if;
            end if;
	    when up =>
			square_h_end <= 524 ;
	    when down =>
			square_h_end <= 524 ;
		when voice_up =>
			null;
		when voice_down =>
			null;
		when enlarge =>
			null;	
		when shrink =>
			null;
        when others => 
            square_h_end <= 524;
    end case ;
end if;
end process;

------------square_v_start----------------------

process(video_clk, rst, vga_state, cnt, cnt2, turn_right_sw, turn_left_sw ,down_sw, up_sw)
begin
if rst = '0' then
    square_v_start <= 341;
elsif rising_edge(video_clk) then
    case vga_state is 
		when start =>
			square_v_start <= 341;
		when ready => 
			null;
        when turn_right => 
            square_v_start <= 341 ;
        when turn_left =>  
            square_v_start <= 341 ;
		when up =>
		    if (square_v_start > 241) then
			    if (cnt = 100000) then
				    square_v_start <= square_v_start - 1 ;
				end if;
			end if;
		when down =>
		    if (square_v_start < 441) then
			    if (cnt = 100000) then
				    square_v_start <= square_v_start + 1 ;
				end if;
			end if;
		when voice_up =>
			null;
		when voice_down =>
			null;
		when enlarge =>
			null;
		when shrink =>
			null;
        when others => 
            square_v_start <= 341;
    end case ;
end if;
end process;

------------square_v_end----------------------

process(video_clk, rst, vga_state, cnt, cnt2, turn_right_sw, turn_left_sw ,down_sw, up_sw)
begin
if rst = '0' then
    square_v_end <= 349;
elsif rising_edge(video_clk) then
    case vga_state is 
		when start =>
			square_v_end <= 349;
		when ready =>
			null;
        when turn_right => 
            square_v_end <= 349 ;
        when turn_left =>  
            square_v_end <= 349 ;
		when up =>
		    if (square_v_end > 249) then
			    if (cnt = 100000) then
				    square_v_end <= square_v_end - 1 ;
				end if;
			end if;	
		when down =>
		    if (square_v_end < 449) then
			    if (cnt = 100000) then
				    square_v_end <= square_v_end + 1 ;
				end if;
			end if;			
		when voice_up =>
			null;
		when voice_down =>
			null;
		when enlarge =>
			null;
		when shrink =>
			null;
        when others => 
            square_v_end <= 349;
    end case ;
end if;
end process;

-----------------------------------------------
------------音量鍵的四個角座標-----------------
------------voice_h_start----------------------

process(video_clk, rst, vga_state, turn_right_sw, turn_left_sw ,down_sw, up_sw)
begin
	if rst = '0' then
		voice_h_start <= 612;
	elsif rising_edge(video_clk) then
		case vga_state is 
			when start =>
				voice_h_start <= 612;
			when ready =>
				null;
			when turn_right => 
				voice_h_start <= 612;
			when turn_left => 
				voice_h_start <= 612;
			when up =>
                voice_h_start <= 612;
			when down =>
                voice_h_start <= 612;
			when voice_up =>
				voice_h_start <= 612;
			when voice_down =>
				voice_h_start <= 612;
			when enlarge =>
				voice_h_start <= 612;
			when shrink =>
				voice_h_start <= 612;
			when others => 
				voice_h_start <= 612;
		end case ;
	end if;
end process;

------------voice_h_end----------------------

process(video_clk, rst, vga_state, turn_right_sw, turn_left_sw ,down_sw, up_sw)
begin
if rst = '0' then
    voice_h_end <= 632;
elsif rising_edge(video_clk) then
    case vga_state is
        when start =>
			voice_h_end <= 632;
		when ready =>
			null;
        when turn_right => 
			voice_h_end <= 632;
        when turn_left => 
			voice_h_end <= 632;
	    when up =>
			voice_h_end <= 632;
	    when down =>
			voice_h_end <= 632;
		when voice_up =>
			voice_h_end <= 632;
		when voice_down =>
			voice_h_end <= 632;
		when enlarge =>
			voice_h_end <= 632;
		when shrink =>
			voice_h_end <= 632;
        when others => 
			voice_h_end <= 632;
    end case ;
end if;
end process;

------------voice_v_start----------------------

process(video_clk, rst, vga_state, cnt1, turn_right_sw, turn_left_sw ,down_sw, up_sw)
begin
if rst = '0' then
    voice_v_start <= 245;
elsif rising_edge(video_clk) then
    case vga_state is 
		when start =>
			voice_v_start <= 245;
		when ready => 
			null;
        when turn_right => 
			null;
        when turn_left =>  
			null;
		when up =>
			null;
		when down =>
			null;
		when voice_up =>
		    if (voice_v_start > 145) then
			    if (cnt1 = 2000000) then
				    voice_v_start <= voice_v_start - 1 ;
				end if;
			end if;	
		when voice_down =>
			if (voice_v_start < 245)then
			    if (cnt1 = 2000000) then
				    voice_v_start <= voice_v_start + 1 ;
				end if;
			end if;	
        when enlarge =>
			null;
        when shrink =>
			null;
        when others => 
			voice_v_start <= 245;
    end case ;
end if;
end process;

------------voice_v_end----------------------

process(video_clk, rst, vga_state, turn_right_sw, turn_left_sw ,down_sw, up_sw)
begin
if rst = '0' then
    voice_v_end <= 247;
elsif rising_edge(video_clk) then
    case vga_state is 
		when start =>
			voice_v_end <= 247;
		when ready =>
			null;
        when turn_right => 
            voice_v_end <= 247;
        when turn_left =>  
            voice_v_end <= 247;
		when up =>
            voice_v_end <= 247;
		when down =>
            voice_v_end <= 247;
		when voice_up => 
			voice_v_end <= 247;
		when voice_down => 
			voice_v_end <= 247;
		when enlarge => 
			voice_v_end <= 247;
		when shrink => 
			voice_v_end <= 247;
        when others => 
            voice_v_end <= 247;
    end case ;
end if;
end process;
---------------------------------------------
------------顏色改變訊號---------------------
------------blue_signal----------------------

process(video_clk, rst, square_h_start,vga_state, count100_cnt)
begin
if rst = '0' then
    blue_signal <= '0';
elsif rising_edge(video_clk) then
    case vga_state is 
		when start =>
			blue_signal <= '0';
		when ready =>
			if(count100_cnt > 199)then
				blue_signal <= '0';
			end if;
        when turn_right => 
            if (square_h_start = 618 )then
				blue_signal <= '1';
			end if;
        when turn_left =>  
            blue_signal <= '0';
        when up =>  
            blue_signal <= '0';
        when down =>
		    blue_signal <= '0';
		when voice_up =>
			blue_signal <= '0';
		when voice_down =>
			blue_signal <= '0';
		when enlarge =>
			blue_signal <= '0';
		when shrink =>
			blue_signal <= '0';
        when others => 
            blue_signal <= '0';
    end case ;
end if;
end process;

------------green_signal----------------------

process(video_clk, rst, square_h_start,vga_state, count100_cnt)
begin
if rst = '0' then
    green_signal <= '0';
elsif rising_edge(video_clk) then
    case vga_state is 
		when start =>
			green_signal <= '0';
		when ready =>
			if(count100_cnt > 199)then
				green_signal <= '0';
			end if;
        when turn_right => 
                green_signal <= '0';
        when turn_left =>  
            if (square_h_start = 414 )then
				green_signal <= '1';
			else
				green_signal <= '0';
			end if;
		when up =>
            green_signal <= '0';
        when down =>
		    green_signal <= '0';				
		when voice_up =>
			green_signal <= '0';
		when voice_down =>
			green_signal <= '0';
		when enlarge =>
			green_signal <= '0';
		when shrink =>
			green_signal <= '0';
        when others => 
            green_signal <= '0';
    end case ;
end if;

end process;

------------yellow_signal----------------------

process(video_clk, rst, square_v_start, vga_state, count100_cnt )
begin
if rst = '0' then
    yellow_signal <= '0';
elsif rising_edge(video_clk) then
    case vga_state is 
		when start =>
			yellow_signal <= '0';
		when ready =>
			if(count100_cnt > 199)then
				yellow_signal <= '0';
			end if;
        when turn_right => 
                yellow_signal <= '0';
        when turn_left =>  
                yellow_signal <= '0';
		when up =>
            if (square_v_start = 241 )then
				yellow_signal <= '1';
			end if;
        when down =>
		    yellow_signal <= '0';							
		when voice_up =>
			yellow_signal <= '0';
        when voice_down =>
			yellow_signal <= '0';
		when enlarge =>
			yellow_signal <= '0';
		when shrink =>
			yellow_signal <= '0';
		when others => 
            yellow_signal <= '0';
    end case ;
end if;
end process;

------------purple_signal----------------------

process(video_clk, rst, square_v_start, vga_state, count100_cnt)
begin
if rst = '0' then
    purple_signal <= '0';
elsif rising_edge(video_clk) then
    case vga_state is 
		when start =>
			purple_signal <= '0';
		when ready =>
			if(count100_cnt > 199)then
				purple_signal <= '0';
			end if;
        when turn_right => 
            purple_signal <= '0';
        when turn_left =>  
            purple_signal <= '0';
		when up =>
            purple_signal <= '0';
		when down =>
            if (square_v_start = 441 )then
				purple_signal <= '1';
			end if;
		when voice_up =>
			purple_signal <= '0';
        when voice_down =>
			purple_signal <= '0';   
		when enlarge =>
			purple_signal <= '0';
		when shrink =>
			purple_signal <= '0';
		when others => 
            purple_signal <= '0';
    end case ;
end if;
end process;

-------------------------------------------------------
-------------- voice_up_en ------------------------
-------------------------------------------------------

process(video_clk, rst, voice_v_end, vga_state, voice_v_start)
begin
if rst = '0' then
    voice_up_en <= '0';
elsif rising_edge(video_clk) then
    case vga_state is 
		when start =>
			voice_up_en <= '0';
		when ready =>
			null;
        when turn_right => 
            null;
        when turn_left =>  
            null;
		when up =>
            null;
		when down =>
            null;
		when voice_up =>
			if (voice_v_start = 145)then 
				voice_up_en <= '0';
			else
				if (voice_v_start = 155)then
					voice_up_en <= '1';
				else
					if (voice_v_start = 165)then
						voice_up_en <= '0';
					else
						if (voice_v_start = 175)then
        					voice_up_en <= '1';
						else
							if (voice_v_start = 185)then
            					voice_up_en <= '0';
							else
							    if (voice_v_start = 195)then
									voice_up_en <= '1';
								else
								    if (voice_v_start = 205)then
										voice_up_en <= '0';
									else
									    if (voice_v_start = 215)then
											voice_up_en <= '1';
										else
										    if (voice_v_start = 225)then
												voice_up_en <= '0';
											else
											    if (voice_v_start = 235)then
													voice_up_en <=  '1';
												end if;
											end if ;
										end if ;
									end if;
								end if;
							end if;
						end if;
					end if;
				end if;
            end if;
        when voice_down =>	
            null;
        when enlarge =>
			null;
        when shrink =>
			null;
        when others => 
            voice_up_en <= '0';
    end case ;
end if;
end process;

-------------------------------------------------------
-------------- voice_down_en ------------------------
-------------------------------------------------------

process(video_clk, rst, voice_v_end, vga_state, voice_v_start)
begin
if rst = '0' then
    voice_down_en <= '0';
elsif rising_edge(video_clk) then
    case vga_state is 
		when start =>
			voice_down_en <= '0';
		when ready =>
			null;
        when turn_right => 
            null;
        when turn_left =>  
            null;
		when up =>
            null;
		when down =>
            null;
		when voice_up =>
            null;
        when voice_down =>	
			if (voice_v_start = 245)then
				voice_down_en <= '0';
			else
				if (voice_v_start = 235)then 
					voice_down_en <= '1';
				else
					if (voice_v_start = 225)then
						voice_down_en <= '0';
					else
						if (voice_v_start = 215)then
							voice_down_en <= '1';
						else
							if (voice_v_start = 205)then
								voice_down_en <= '0';
							else
								if (voice_v_start = 195)then
									voice_down_en <= '1';
								else
									if (voice_v_start = 185)then
										voice_down_en <= '0';
									else
										if (voice_v_start = 175)then
											voice_down_en <= '1';
										else
											if (voice_v_start = 165)then
												voice_down_en <= '0';
											else
												if (voice_v_start = 155)then
													voice_down_en <= '1';
												else
													if (voice_v_start = 145)then
														voice_down_en <=  '0';
													end if;
												end if ;
											end if ;
										end if;
									end if;
								end if;
							end if;
						end if;
					end if;
				end if;	
			end if;
        when enlarge =>
			null;
        when shrink =>
			null;
        when others => 
            voice_down_en <= '0';
    end case ;
end if;
end process;

------------- enlarge_bit_cnt --------

process(video_clk, rst, vga_state, cnt2)
begin
if rst = '0' then
    enlarge_bit_cnt <= 0;
elsif rising_edge(video_clk) then
    case vga_state is 
		when start =>
			enlarge_bit_cnt <= 0;
		when ready =>
			null;
        when turn_right => 
            null;
        when turn_left =>  
            null;
		when up =>
            null;
		when down =>
            null;
		when voice_up =>
			null;
		when voice_down =>
			null;
		when enlarge =>
			if (cnt2 = 10000000 )then
				if (enlarge_bit_cnt < 4)then
				    enlarge_bit_cnt <= enlarge_bit_cnt + 1;
				else
				    null;	
				end if;
			end if;
		when shrink =>
			if (cnt2 = 10000000)then
			    if (enlarge_bit_cnt > 0)then
				    enlarge_bit_cnt <= enlarge_bit_cnt - 1;
				else
				    null;
				end if;
			end if;
		when others => 
            enlarge_bit_cnt <= 0;
    end case ;
end if;
end process;

--------divclk-ccc-------------

-- process(rst , video_clk) 
-- begin 
	-- if rst='0' then       
		-- divcount <= "000000000000000000000000";
	-- elsif rising_edge(video_clk) then
		-- divcount <= divcount + '1';
	-- end if; 
-- end process;

----------------------------------------------
PROCESS(video_clk,rst)
BEGIN
	IF(rst='0')THEN
		cnt <= 0;
	elsif rising_edge(video_clk) then
		IF(cnt = 100000)THEN
			cnt <= 0;
		ELSE
			cnt <= cnt+1;    
		END IF;
	END IF;
END PROCESS;
----------------------------------------------

PROCESS(video_clk,rst)
BEGIN
	IF(rst='0')THEN
		cnt1 <= 0;
	elsif rising_edge(video_clk) then
		IF(cnt1 = 2000000)THEN
			cnt1 <= 0;
		ELSE
			cnt1 <= cnt1 + 1;    
		END IF;
	END IF;
END PROCESS;

--------------------------------------------

PROCESS(video_clk,rst)
BEGIN
	IF(rst='0')THEN
		cnt2 <= 0;
	elsif rising_edge(video_clk) then
		IF(cnt2 = 10000000)THEN
			cnt2 <= 0;
		ELSE
			cnt2 <= cnt2 + 1;    
		END IF;
	END IF;
END PROCESS;

-----------count100_cnt----顏色延遲-----------------

process(video_clk, rst, vga_state, cnt)
begin
if rst = '0' then
    count100_cnt <= 0;
elsif rising_edge(video_clk) then
    case vga_state is 
		when start =>
			count100_cnt <= 0;
		when ready =>
			if (cnt = 100000)then
				if( count100_cnt < 200 )then
					count100_cnt <= count100_cnt + 1;
				else
					count100_cnt <= 0;
				end if ;
			end if;
        when turn_right => 
            count100_cnt <= 0;
        when turn_left =>  
            count100_cnt <= 0;
		when up =>
            count100_cnt <= 0;
		when down =>
            count100_cnt <= 0;
		when voice_up =>
			count100_cnt <= 0;
		when voice_down =>
			count100_cnt <= 0;
		when enlarge =>
			count100_cnt <= 0;
		when shrink =>
			count100_cnt <= 0;
		when others => 
            count100_cnt <= 0;
    end case ;
end if;
end process;
--------------------------------------------------------------
end Behavioral;