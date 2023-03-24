----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:37:05 11/16/2022 
-- Design Name: 
-- Module Name:    count_lim_dir - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity count_lim_dir is

	Port ( reset : in STD_LOGIC;
			 clock : in STD_LOGIC;
			 top : in STD_LOGIC_VECTOR(3 downto 0);
			 bottom : in STD_LOGIC_VECTOR(3 downto 0);
			 dir : in STD_LOGIC;
			 counter_output : out STD_LOGIC_VECTOR (3 downto 0) );
end count_lim_dir;

architecture Behavioral of count_lim_dir is
	signal clk_div : STD_LOGIC;
	signal cnt : STD_LOGIC_VECTOR (25 downto 0); 
	signal count : STD_LOGIC_VECTOR (3 downto 0);
	
	begin
		
	process(reset, clock)
	begin
			if reset = '0' then
				cnt <= (others => '0');
			elsif clock'event and clock = '1' then 
				cnt <= cnt + 1;
			end if;
		end process;
	clk_div <= cnt(23); 
		
	process(reset, clk_div, dir, top, bottom)
	begin
			if reset = '0' then
				count <= bottom;
			elsif clk_div'event and clk_div = '1' then 
				if dir = '1' then
					count <= count + 1;
					if count >= top then
						count <= bottom;
					end if;
				else
					count <= count - 1;
					if count <= bottom then 
						count <= top;
				end if;
			end if;
		end if;
	end process;
	counter_output <= count;

end Behavioral;

