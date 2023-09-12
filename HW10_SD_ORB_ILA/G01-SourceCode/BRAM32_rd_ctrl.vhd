library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity BRAM32_ctrl is
  Port (
	-- clk_ORB: IN STD_LOGIC;    ----25M
  
    clkb : IN STD_LOGIC;    ----50M
    rstb : out STD_LOGIC;
    enb : out STD_LOGIC;
    web : out STD_LOGIC_VECTOR(3 DOWNTO 0);
    addrb : out STD_LOGIC_VECTOR(31 DOWNTO 0);
    dinb : out STD_LOGIC_VECTOR(31 DOWNTO 0);
    doutb : in STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    pixel : out STD_LOGIC_VECTOR(7 DOWNTO 0) 
    );
end BRAM32_ctrl;

architecture Behavioral of BRAM32_ctrl is
signal addr : STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '0');
signal pixelC : std_logic_vector(2 downto 0) := "000";
signal clkCnt : std_logic_vector(1 downto 0) := "00";

constant refresh_threshold : INTEGER := 240 * 240 * 249;

signal refresh : BOOLEAN := false;
signal up_count : integer range 0 to refresh_threshold := 0;

begin

rstb  <= '0';
enb   <= '1';
web   <= (others =>'0');
dinb  <= (others =>'Z');
 addrb<= addr;
 
process(clkb)
begin
    if rising_edge(clkb) then
		clkCnt <= clkCnt + 1;
    end if;
end process;
-- clkCnt(0) <= clkCnt(0);

--@@@@@@@@@
process(clkb)
begin
	if rising_edge(clkb) then
		if up_count = refresh_threshold then
			addr <= (others => '0'); -- Refresh address
			refresh <= true;
		else
			refresh <= false;
		end if;
	end if;
end process;
--@@@@@@@@@
 
process(clkCnt(0))
begin
    if rising_edge(clkCnt(0)) then
        if (pixelC = "100") then
			addr <= addr + 1;
			pixelC <= (others => '0');
		end if;
		case pixelC is 
			when "00" =>
				pixel <= doutb(7 downto 0);
			when "01" =>
				pixel <= doutb(15 downto 8);
			when "10" =>
				pixel <= doutb(23 downto 16);
			when "11" =>
				pixel <= doutb(31 downto 24);
			when others =>
				pixel <= pixel;
		end case;
		pixelC <=  pixelC + 1;

end process;

end Behavioral;
