library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity video_in_process_rgb is
port(
    rst              : in std_logic;
------------video_in_i2c---------------------------------
    video_clk        : in std_logic;
    video_sda        : inout std_logic;
    video_scl        : inout std_logic;
    video_data_i2c   : in std_logic_vector(7 downto 0);
    	    pepi: OUT std_logic_vector(0 downto 0);

------------video_out & vga cnt---------------------------------
    vga_vs_cnt       : out integer;
    vga_hs_cnt       : out integer;
    hsync            : out std_logic;
    vsync            : out std_logic;
    frame_id         : out std_logic;
    video_gray_out   : out std_logic_vector(7 downto 0);
    video_r_out      : out std_logic_vector(7 downto 0);
    video_g_out      : out std_logic_vector(7 downto 0);
    video_b_out      : out std_logic_vector(7 downto 0)
);
end video_in_process_rgb;

architecture behavioral of video_in_process_rgb is
----------------------------------------
signal cb_register, cr_register : std_logic_vector(7 downto 0);
constant ycr_c1 : std_logic_vector(11 downto 0):=x"5a1";--constant1 of yuv convert r, 1.4075(d) * 1024(d) = 5a1(h)
constant ycg_c1 : std_logic_vector(11 downto 0):=x"161";--constant1 of yuv convert g, 0.3455(d) * 1024(d) = 161(h)
constant ycg_c2 : std_logic_vector(11 downto 0):=x"2de";--constant2 of yuv convert g, 0.7169(d) * 1024(d) = 2de(h)
constant ycb_c1 : std_logic_vector(11 downto 0):=x"71d";--constant1 of yuv convert b, 1.7790(d) * 1024(d) = 71d(h)
signal ycr : std_logic_vector(19 downto 0);
signal ycg : std_logic_vector(19 downto 0);
signal ycb : std_logic_vector(19 downto 0);
signal vsync_s : std_logic;
----------------------------------------i2c
component i2c
    port (
        clk : in  std_logic;                   
        rst : in  std_logic;
        sda : inout std_logic;
        scl : inout std_logic
    );
end component;
----------------------------------------vga
signal vga_hs_cnt_s : integer ;
signal vga_vs_cnt_s : integer ;
signal frame_id_s   : std_logic ;
component vga
    generic(
        horizontal_resolution : integer :=1280 ;
        horizontal_front_porch: integer :=  48 ;
        horizontal_sync_pulse : integer := 112 ;
        horizontal_back_porch : integer := 248 ;
        h_sync_polarity       :std_logic:= '1' ;
        vertical_resolution   : integer :=1024 ;
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
        vga_vs_cnt : out integer ;
        hsync : out std_logic;
        vsync : out std_logic
    );
end component;
----------------------------------------
signal video_error : std_logic;
----------------------------------------camera
signal video_start_en : std_logic ;
signal cnt_video_hsync : integer range 0 to 1715;
----------------------------------------
signal buf_vga_state : std_logic_vector(1 downto 0);
signal buf_vga_y_in_cnt : integer range 0 to 719;
----------------------------------------
type array_type_8 is array (integer range 0 to 719) of std_logic_vector(7 downto 0);
signal buf_video_data : array_type_8;
signal buf_vga_r      : array_type_8;
signal buf_vga_g      : array_type_8;
signal buf_vga_b      : array_type_8;
----------------------------------------video_in
component video_in
    port(
        clk : in std_logic;    
        rst : in  std_logic;
        video_data : in std_logic_vector(7 downto 0);
        video_start_en : out std_logic ;
        cnt_video_hsync : out integer range 0 to 1715
    );
end component;
----------------------------------------
begin----------------------------------------
----------------------------------------i2c
i2c_1 :i2c
    port map (
         clk => video_clk,
         rst => video_error,
         sda => video_sda,
         scl => video_scl
    );
----------------------------------------video_in
video_in_1 :video_in
    port map (
        clk            => video_clk,
        rst            => video_error,
        video_data     => video_data_i2c,
        video_start_en => video_start_en,
        cnt_video_hsync=> cnt_video_hsync
    );
----------------------------------------
process(video_error, video_clk)
begin
if video_error = '0' then
	buf_vga_state <= "00";
	buf_vga_y_in_cnt <= 0;
	
	ycr <= x"00000"; --yuv convert r
	ycg <= x"00000"; --yuv convert g
	ycb <= x"00000"; --yuv convert b
	
	cr_register <= x"00";
	cb_register <= x"00";
else
	if rising_edge(video_clk) then
		if (cnt_video_hsync>=0 and cnt_video_hsync < 1439 and video_start_en = '1') then
			case buf_vga_state(0) is
				when '0' =>	 buf_vga_state <= buf_vga_state + "01"; --the vdata is cb
					if ycr > x"00000" or ycg > x"00000" or ycb > x"00000" then	--the first data has not yet completed calculate
						if ycr(18) = '1' or ycr(19) = '1' then
							buf_vga_r(buf_vga_y_in_cnt) <= "11111111";
						else
							buf_vga_r(buf_vga_y_in_cnt) <= ycr(17 downto 10);
						end if;
						if ycg(18) = '1' or ycg(19) = '1' then
							buf_vga_g(buf_vga_y_in_cnt) <= "11111111";
						else
							buf_vga_g(buf_vga_y_in_cnt) <= ycg(17 downto 10);
						end if;
						if ycb(18) = '1' or ycb(19) = '1' then
							buf_vga_b(buf_vga_y_in_cnt) <= "11111111";
						else
							buf_vga_b(buf_vga_y_in_cnt) <= ycb(17 downto 10);
						end if;

					end if;
					
					--cb
					if buf_vga_state(1)='0' then
						cb_register <= video_data_i2c;
						ycr <= cr_register * ycr_c1;
						ycg <= video_data_i2c * ycg_c1 + cr_register * ycg_c2;
						ycb <= video_data_i2c * ycb_c1;
					--cr
					else
						cr_register <= video_data_i2c;
						ycr <= video_data_i2c * ycr_c1;
						ycg <= cb_register * ycg_c1 + video_data_i2c * ycg_c2;
						ycb <= cb_register * ycb_c1;
					end if;
				when '1' =>		buf_vga_state <= buf_vga_state + "01"; --the vdata is y
					--x"400"   = 1024(d)
					--x"2d0a3" = 1024(d) * 128(d) * 1.4075(d)
					--x"b0e5"  = 1024(d) * 128(d) * 0.3455(d)
					--x"16f0d" = 1024(d) * 128(d) * 0.7169(d)
					--x"38ed9" = 1024(d) * 128(d) * 1.7790(d)
--									ycr <= ycr + vdata * x"400" - x"2d0a3";
--									ycg <= (ycg xor x"fffff") + vdata * x"400" + x"b0e5" + x"16f0d";
--									ycb <= ycb + vdata * x"400" - x"38ed9";

					if ycr + video_data_i2c * x"400" < x"2d0a3" then
						ycr <= x"00000";
					else
						ycr <= ycr + video_data_i2c * x"400" - x"2d0a3";
					end if;
					
					if ycg > video_data_i2c * x"400" + x"b0e5" + x"16f0d" then
						ycg <= x"00000";
					else
						ycg <=  video_data_i2c * x"400" + x"b0e5" + x"16f0d" - ycg;
					end if;
					
					if ycb + video_data_i2c * x"400" < x"38ed9" then
						ycb <= x"00000";
					else
						ycb <= ycb + video_data_i2c * x"400" - x"38ed9";
					end if;
					
					if buf_vga_y_in_cnt = 719 then
						buf_vga_y_in_cnt <= 0;
					else
						buf_vga_y_in_cnt <= buf_vga_y_in_cnt + 1;
					end if;
					buf_video_data(buf_vga_y_in_cnt) <= video_data_i2c;
				when others => null;
			end case;
		else
			buf_vga_state <= "00";
			buf_vga_y_in_cnt <= 0;
			ycr <= x"00000";
			ycg <= x"00000";
			ycb <= x"00000";
		end if;
	end if;
end if;
end process;
----------------------------------------
--h equals 1 always indicates eav.
--
--h equals 0 always indicates sav. 
--
--the alignment of v and f to the line and  field counter varies depending on the standard.
--
--p3 = v xor h
--p2 = f xor h
--p1 = f xor v
--p0 = f xor v xor h
--
--eav and sav sequence
--8-bit data:(msb)d7 d6 d5 d4 d3 d2 d1 d0
--preamble         1  1  1  1  1  1  1  1
--preamble         0  0  0  0  0  0  0  0
--preamble         0  0  0  0  0  0  0  0
--status word      1  f  v  h p3 p2 p1 p0
--
process(rst, video_clk)
begin
if rst = '0' then
    video_error<='0';
else
    if rising_edge(video_clk) then
	 	  if(
	 	         (cnt_video_hsync = 1440 and video_data_i2c   /= x"ff")
            or (cnt_video_hsync = 1441 and video_data_i2c   /= x"00")
--	 	        or (cnt_video_hsync = 1712 and video_data_i2c   /= x"ff")
--            or (cnt_video_hsync = 1713 and video_data_i2c   /= x"00")
--            or (cnt_video_hsync = 1714 and video_data_i2c   /= x"00")
            or (cnt_video_hsync = 1715 and video_data_i2c(5) = '1' and vga_vs_cnt_s < 480)
        ) then
            video_error<='0';
        else
            video_error<='1';
        end if;
    end if;
end if;
end process;
----------------------------------------vga
vga_1: vga
    generic map(
--        horizontal_resolution => 720 ,
--        horizontal_front_porch=>  16 ,
--        horizontal_sync_pulse =>  62 ,
--        horizontal_back_porch =>  59 ,
--        h_sync_polarity       => '1' ,
--        vertical_resolution   => 480 ,
--        vertical_front_porch  =>   9 ,
--        vertical_sync_pulse   =>   6 ,
--        vertical_back_porch   =>  29 ,
--        v_sync_polarity       => '1' 
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
        rst =>video_error,
        video_start_en =>video_start_en,
        vga_hs_cnt =>vga_hs_cnt_s,
        vga_vs_cnt =>vga_vs_cnt_s,
        hsync      =>hsync,
        vsync      =>vsync_s
    );
vsync<=vsync_s;
vga_hs_cnt<=vga_hs_cnt_s;
vga_vs_cnt<=vga_vs_cnt_s;
----------------------------------------
process(video_error , vsync_s)
begin
if video_error = '0' then
    frame_id_s<='0';
else
    if falling_edge(vsync_s) then
        frame_id_s<=not(frame_id_s);
    end if;
end if;
end process;
frame_id<=frame_id_s;
----------------------------------------
process(video_error, video_clk)
begin
if video_error = '0' then
    video_gray_out<="00000000";
    video_r_out   <="00000000";
    video_g_out   <="00000000";
    video_b_out   <="00000000";
else
    if rising_edge(video_clk) then
        if (vga_hs_cnt_s<720 and vga_vs_cnt_s<480 and video_start_en = '1') then
            video_gray_out<=buf_video_data(    vga_hs_cnt_s);

            video_r_out   <=buf_vga_r     (    vga_hs_cnt_s);
            video_g_out   <=buf_vga_g     (    vga_hs_cnt_s);
            video_b_out   <=buf_vga_b     (    vga_hs_cnt_s);
            
        else
            video_gray_out<="00000000";
            video_r_out   <="00000000";
            video_g_out   <="00000000";
            video_b_out   <="00000000";
        end if;
    end if;
end if;
end process;
----------------------------------------
end architecture;