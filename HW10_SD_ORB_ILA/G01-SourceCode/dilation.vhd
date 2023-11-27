library IEEE;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dilation is
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
END dilation;

ARCHITECTURE dilation_a OF dilation IS
	type Array_dilation_buf_1D is array (integer range 0 to (array_y-1)) of std_logic_vector ((10-1) downto 0);
	type Array_dilation_buf_2D is array (integer range 0 to (array_x-1)) of Array_dilation_buf_1D;
	signal dilation_buf  : Array_dilation_buf_2D;
	signal dilation_buf1 : Array_dilation_buf_2D;

	signal dila_check    : std_logic_vector(9 downto 0):="0000000000";--Array_dilation_buf;
	signal dila_cnt      : integer range 0 to 719:=0;
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
					dilation_buf1(k-1)(dila_cnt) <= dilation_buf(k)(array_y-1);
				end if;
			end if;
		end if;
	end process;
end generate give_data;
dila_buffer_x:
for i in (array_x-1) downto 0 generate
dila_buffer_y:
for j in (array_y-1) downto 1 generate
	process(rst,video_clk)
	begin
		if rst = '0' then
			dila_cnt <= 0;
		elsif rising_edge(video_clk) then
			if SB_buf_012_en = '1' then
				if buf_data_state(0) = '0' then
					if j= (array_y-1) then
						dilation_buf(i)(array_y-1) <= dilation_buf1(i)(dila_cnt);
					end if;
					dilation_buf(i)(j-1) <= dilation_buf(i)(j);
				else
--						dilation_buf1(i-1)(dila_cnt) <= dilation_buf(i)(array_y-1);-- in give_data
					dilation_buf1(array_x-1)(dila_cnt) <= "000000000" & in_dila_data;
					if dila_cnt = (array_x-1) then
						dila_cnt <= dila_cnt;
					else
						dila_cnt <= dila_cnt + 1;
					end if;
				end if;
			else
				dila_cnt <= 0;
			end if;
		end if;
	end process;
end generate dila_buffer_y;
end generate dila_buffer_x;

--dilation
process(rst,video_clk,dilation_buf)   --sum array's data
	variable a : std_logic_vector(9 downto 0):= "0000000000";
	variable b : std_logic_vector(9 downto 0):= "0000000000";
begin
	if rst = '0' then
		dila_check <= "0000000000";
	else
		for i in 0 to array_x loop
			for j in 0 to (array_y - 1) loop
				if i = array_x then
					if j= 0 then
						dila_check <= a;
						a := "0000000000";
					end if;
				else
					a := a + dilation_buf(i)(j);
				end if;
			end loop;
		end loop;
	end if;
end process;

process(rst,video_clk,buf_dila_en,buf_data_state)
begin
	if rst = '0' then
		dila_data <= '0';
	elsif rising_edge(video_clk) then
		if buf_dila_en = '1' then
			if buf_data_state(0) = '0' then
				if (((integral_sw = '1' and open_sw = '1' and close_sw = '0') or integral_sw = '0') and dila_check > "0000000001") or dila_inte_data > "0000000001" then
					dila_data <= '1';
				else
					dila_data <= '0';
				end if;
			end if;
		else
			dila_data <= '0';
		end if;
	end if;
end process;

end dilation_a;