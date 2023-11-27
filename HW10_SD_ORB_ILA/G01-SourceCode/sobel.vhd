library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sobel is
	port(
	 rst             : in  std_logic;
	 video_clk       : in  std_logic;
	 video_data      : in  std_logic_vector(7 downto 0);
	 SB_buf_012_en   : in  std_logic;
	 buf_sobel_cc_en : in  std_logic;
	 buf_data_state  : in  std_logic_vector(1 downto 0);
	 SB_CRB_data     : out std_logic;
	 SB_CRB_data_8     : out std_logic_vector(7 downto 0)
	);
END sobel;

ARCHITECTURE sobel_a OF sobel IS

    signal SB_CRB_data_buf : std_logic;
	type Array_Sobel_buf is array (integer range 0 to 719) of std_logic_vector ((10-1) downto 0);
	signal SB_buf_0        : Array_Sobel_buf;
	signal SB_buf_0_data_1 : std_logic_vector((10-1) downto 0):="0000000000";
	signal SB_buf_0_data_2 : std_logic_vector((10-1) downto 0):="0000000000";
	signal SB_buf_0_data_3 : std_logic_vector((10-1) downto 0):="0000000000";
	
	signal SB_buf_1        : Array_Sobel_buf;
	signal SB_buf_1_data_1 : std_logic_vector((10-1) downto 0):="0000000000";
	signal SB_buf_1_data_2 : std_logic_vector((10-1) downto 0):="0000000000";
	signal SB_buf_1_data_3 : std_logic_vector((10-1) downto 0):="0000000000";
	
	signal SB_buf_2        : Array_Sobel_buf;
	signal SB_buf_2_data_1 : std_logic_vector((10-1) downto 0):="0000000000";
	signal SB_buf_2_data_2 : std_logic_vector((10-1) downto 0):="0000000000";
	signal SB_buf_2_data_3 : std_logic_vector((10-1) downto 0):="0000000000";
	
	signal SB_buf_in_data  : std_logic_vector(( 8-1) downto 0):="00000000";
	signal SB_buf_cnt      : integer range 0 to 719:=0;
	signal SB_buf_cnt_max  : integer range 0 to 719:=719; --0~639
	
	signal SB_XSCR         : std_logic_vector((10-1) downto 0):="0000000000";
	signal SB_YSCR         : std_logic_vector((10-1) downto 0):="0000000000";

begin

SB_CRB_data_8 <= SB_CRB_data_buf & SB_CRB_data_buf & SB_CRB_data_buf & SB_CRB_data_buf & SB_CRB_data_buf & SB_CRB_data_buf & SB_CRB_data_buf & SB_CRB_data_buf;

--SOBEL-Buffer set
sobel_buffer:process(rst, video_clk, SB_buf_012_en, buf_data_state)
begin
	if rst = '0' then
		SB_buf_0_data_1 <= "0000000000";
		SB_buf_0_data_2 <= "0000000000";
		SB_buf_0_data_3 <= "0000000000";
		SB_buf_1_data_1 <= "0000000000";
		SB_buf_1_data_2 <= "0000000000";
		SB_buf_1_data_3 <= "0000000000";
		SB_buf_2_data_1 <= "0000000000";
		SB_buf_2_data_2 <= "0000000000";
		SB_buf_2_data_3 <= "0000000000";
		SB_buf_cnt      <= 0;
	elsif rising_edge(video_clk) then
		if SB_buf_012_en = '1' then
			if buf_data_state(0) = '0' then
				SB_buf_0_data_3 <= SB_buf_0(SB_buf_cnt);
				SB_buf_0_data_2 <= SB_buf_0_data_3;
				SB_buf_0_data_1 <= SB_buf_0_data_2;
				
				SB_buf_1_data_3 <= SB_buf_1(SB_buf_cnt);
				SB_buf_1_data_2 <= SB_buf_1_data_3;
				SB_buf_1_data_1 <= SB_buf_1_data_2;
				
				SB_buf_2_data_3 <= SB_buf_2(SB_buf_cnt);
				SB_buf_2_data_2 <= SB_buf_2_data_3;
				SB_buf_2_data_1 <= SB_buf_2_data_2;
			else
				
				SB_buf_0(SB_buf_cnt) <= SB_buf_1(SB_buf_cnt);
				SB_buf_1(SB_buf_cnt) <= SB_buf_2(SB_buf_cnt);
				SB_buf_2(SB_buf_cnt) <= "00" & video_data;
				if SB_buf_cnt = SB_buf_cnt_max then
					SB_buf_cnt <= SB_buf_cnt_max;
				else
					SB_buf_cnt <= SB_buf_cnt + 1;
				end if;	
			end if;
		else
			SB_buf_0_data_1 <= "0000000000";
			SB_buf_0_data_2 <= "0000000000";
			SB_buf_0_data_3 <= "0000000000";
			SB_buf_1_data_1 <= "0000000000";
			SB_buf_1_data_2 <= "0000000000";
			SB_buf_1_data_3 <= "0000000000";
			SB_buf_2_data_1 <= "0000000000";
			SB_buf_2_data_2 <= "0000000000";
			SB_buf_2_data_3 <= "0000000000";
			SB_buf_cnt      <= 0;
		end if;
	end if;
end process sobel_buffer;
--SOBEL
process(rst, video_clk, buf_sobel_cc_en, buf_data_state)
variable sobel_x_cc_1 : std_logic_vector(9 downto 0);
variable sobel_x_cc_2 : std_logic_vector(9 downto 0);
variable sobel_y_cc_1 : std_logic_vector(9 downto 0);
variable sobel_y_cc_2 : std_logic_vector(9 downto 0);
begin
	if rst = '0' then
		SB_XSCR     <= "0000000000";
		SB_YSCR     <= "0000000000";
		SB_CRB_data <= '0';
		SB_CRB_data_buf <= '0';
	elsif rising_edge(video_clk) then
		if buf_sobel_cc_en = '1' then
			if buf_data_state(0) = '1' then
				sobel_x_cc_1 := SB_buf_0_data_1 + SB_buf_0_data_2 + SB_buf_0_data_2 + SB_buf_0_data_3;
				sobel_x_cc_2 := SB_buf_2_data_1 + SB_buf_2_data_2 + SB_buf_2_data_2 + SB_buf_2_data_3;
				sobel_y_cc_1 := SB_buf_0_data_1 + SB_buf_1_data_1 + SB_buf_1_data_1 + SB_buf_2_data_1;
				sobel_y_cc_2 := SB_buf_0_data_3 + SB_buf_1_data_3 + SB_buf_1_data_3 + SB_buf_2_data_3;
				if sobel_x_cc_1 >= sobel_x_cc_2 then
					SB_XSCR <= sobel_x_cc_1 - sobel_x_cc_2;
				else
					SB_XSCR <= sobel_x_cc_2 - sobel_x_cc_1;
				end if;
				if sobel_y_cc_1 >= sobel_y_cc_2 then
					SB_YSCR <= sobel_y_cc_1 - sobel_y_cc_2;
				else
					SB_YSCR <= sobel_y_cc_2 - sobel_y_cc_1;
				end if;
			else
				if   ( ((SB_XSCR > "0000101111" and SB_XSCR < "0000110111") and (SB_YSCR > "0000101111" and SB_YSCR < "0000110111") )
				    or ((SB_XSCR > "0000001111" and SB_XSCR < "0000010100") and (SB_YSCR > "0000001111" and SB_YSCR < "0000010100"))) then   --if two images dirrerent big ,the point is '1'
					SB_CRB_data <= '1';   --catch sobel edge to output--0010000000
					SB_CRB_data_buf <= '1';
				else
					SB_CRB_data <= '0';
					SB_CRB_data_buf <= '0';
				end if;
			end if;
		else
			SB_XSCR     <= "0000000000";
			SB_YSCR     <= "0000000000";
			SB_CRB_data <= '0';
			SB_CRB_data_buf <= '0';
		end if;
	end if;
end process;
end sobel_a;