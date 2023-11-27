library IEEE;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity erosion is
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
END erosion;

ARCHITECTURE erosion_a OF erosion IS
	type Array_erosion_buf_1D is array (integer range 0 to (array_y-1)) of std_logic_vector((10-1) downto 0);
	type Array_erosion_buf_2D is array (integer range 0 to (array_x-1)) of Array_erosion_buf_1D;
	signal erosion_buf  : Array_erosion_buf_2D;
	signal erosion_buf1 : Array_erosion_buf_2D;

	signal ero_check    : std_logic_vector(9 downto 0):="0000000000";--Array_erosion_buf;
	signal ero_cnt      : integer range 0 to 719:=0;
--------------------------------------------------------------------------
begin
--dilation buffer set
give_data:
for k in 1 to (array_x-1) generate
	process(video_clk)
	begin
		if rising_edge(video_clk) then
			if SB_buf_012_en = '1' then
				if buf_data_state(0) = '1' then
					erosion_buf1(k-1)(ero_cnt) <= erosion_buf(k)(array_y-1);
				end if;
			end if;
		end if;
	end process;
end generate give_data;
ero_buffer_x:
for i in (array_x-1) downto 0 generate
ero_buffer_y:
for j in (array_y-1) downto 1 generate
	process(rst,video_clk)
	begin
		if rst = '0' then
			ero_cnt <= 0;
		elsif rising_edge(video_clk) then
			if SB_buf_012_en = '1' then
				if buf_data_state(0) = '0' then
					if j= (array_y-1) then
						erosion_buf(i)(array_y-1) <= erosion_buf1(i)(ero_cnt);
					end if;
					erosion_buf(i)(j-1) <= erosion_buf(i)(j);
				else
--						erosion_buf1(i-1)(ero_cnt) <= erosion_buf(i)(array_y-1);-- in give_data
					erosion_buf1(array_x-1)(ero_cnt) <= "000000000" & in_ero_data;
					if ero_cnt = (array_x-1) then
						ero_cnt <= ero_cnt;
					else
						ero_cnt <= ero_cnt + 1;
					end if;
				end if;
			else
				ero_cnt <= 0;
			end if;
		end if;
	end process;
end generate ero_buffer_y;
end generate ero_buffer_x;

--erosion
process(rst,video_clk,erosion_buf)   --sum array's data
	variable a : std_logic_vector(9 downto 0):= "0000000000";
	variable b : std_logic_vector(9 downto 0):= "0000000000";
begin
	if rst = '0' then
		ero_check <= "0000000000";
	else
		for i in 0 to array_x loop
			for j in 0 to (array_y - 1) loop
				if i = array_x then
					if j= 0 then
						ero_check <= a;
						a := "0000000000";
					end if;
				else
					a := a + erosion_buf(i)(j);
				end if;
			end loop;
		end loop;
	end if;
end process;

process(rst,video_clk,buf_ero_en,buf_data_state)
begin
	if rst = '0' then
		ero_data <= '0';
	elsif rising_edge(video_clk) then
		if buf_ero_en = '1' then
			if buf_data_state(0) = '0' then
				if (((integral_sw = '1' and open_sw = '0' and close_sw = '1') or integral_sw = '0') and ero_check > array_limit) or ero_inte_data > array_limit then
					ero_data <= '1';
				else
					ero_data <= '0';
				end if;
			end if;
		else
			ero_data <= '0';
		end if;
	end if;
end process;

end erosion_a;