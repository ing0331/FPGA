library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity divider is
    Port (
        clk             : in std_logic;
        reset           : in std_logic;
        div_clk        : out std_logic);
end divider;

architecture Behavioral of divider is
signal CLK50mhz  :std_logic;
begin
process(clk,reset)begin
    if (reset = '1') then
        CLK50MHz <= '1';
    elsif (clk'event and clk = '1') then
        CLK50MHz<= not CLK50MHz;
    end if;  
end process;
div_clk <= CLK50MHz;



end Behavioral;
