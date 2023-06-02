library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clkDiv is
Port ( 		
    i_clk   : in std_logic;
	rst 	: in std_logic;
    clk_div : out std_logic );
end entity clkDiv;

architecture Behavioral of clkDiv is
    signal clk_cnt : std_logic_vector(2 downto 0);
begin

process (i_clk, rst)
begin
    if rst = '0' then
        clk_cnt <= (others => '0');
	elsif rising_edge(i_clk) then
		clk_cnt <= clk_cnt + 1;
	end if;
end process;
clk_div <= clk_cnt(1);

end Behavioral;
