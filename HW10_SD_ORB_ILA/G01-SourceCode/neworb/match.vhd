----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:41:29 05/16/2018 
-- Design Name: 
-- Module Name:    match - Behavioral 
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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity match is
generic
(
	max_address_1:std_logic_vector(7 downto 0):="00111111";
	max_address_2:std_logic_vector(7 downto 0):="00111111";
	save_address :std_logic_vector(7 downto 0):="00111111"
);
port(
	rst:in std_logic;
	clk:in std_logic;
	video_clk      : in std_logic;
	match_en:in std_logic;
	brief_addrb_1:out std_logic_vector(7 downto 0);
	brief_addrb_2:out std_logic_vector(7 downto 0);
	a:in std_logic_vector(83 downto 0);
	b:in std_logic_vector(83 downto 0);
	addrb:in std_logic_vector(7 downto 0);
	doutb:out std_logic_vector(39 downto 0);
	match_P : OUT std_logic;
	   -- pepi: OUT std_logic_vector(0 downto 0);

    MATE_D:out std_logic_vector(39 downto 0);
	MATE_D1:out std_logic_vector(39 downto 0);
	MATE_D2:out std_logic_vector(39 downto 0);
	MATE_D3:out std_logic_vector(39 downto 0);
	MATE_D4:out std_logic_vector(39 downto 0);
	MATE_D5:out std_logic_vector(39 downto 0);
	MATE_D6:out std_logic_vector(39 downto 0);
	MATE_D7:out std_logic_vector(39 downto 0)
);
end match;

architecture Behavioral of match is

-- 
--COMPONENT ram_200x40
--    PORT (
--        clka : IN STD_LOGIC;
--        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--        addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--        dina : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
--        clkb : IN STD_LOGIC;
--        addrb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--        doutb : OUT STD_LOGIC_VECTOR(39 DOWNTO 0)
--    );
--END COMPONENT;

signal read_en :STD_LOGIC;
signal round_en :STD_LOGIC;
signal match_data:std_logic_vector(39 downto 0);
signal match_d_cnt:std_logic_vector(6 downto 0);
signal MATE_D_s,MATE_D1_s,MATE_D2_s,MATE_D3_s,MATE_D4_s,MATE_D5_s,MATE_D6_s,MATE_D7_s:std_logic_vector(39 downto 0);

signal addra:std_logic_vector(7 downto 0);
signal dina:std_logic_vector(39 downto 0);
signal wea:std_logic_vector(0 downto 0);
signal count_33554431 : std_logic_vector(18 downto 0);
signal addrb_1,addrb_2:std_logic_vector(7 downto 0);

begin


brief_addrb_1<=addrb_1;
brief_addrb_2<=addrb_2;

MATE_D      <= MATE_D_s;
MATE_D1     <= MATE_D1_s;
MATE_D2     <= MATE_D2_s;
MATE_D3     <= MATE_D3_s;
MATE_D4     <= MATE_D4_s;
MATE_D5     <= MATE_D5_s;
MATE_D6     <= MATE_D6_s;
MATE_D7     <= MATE_D7_s;
--- address control

process(clk,rst)
begin
    if(rst = '0')then
        count_33554431 <= "0000000000000000000";
    elsif rising_edge(video_clk)then
        if(count_33554431 <   "1111111111111111111")then
            count_33554431 <= count_33554431 + '1';
        else
            count_33554431 <= "0000000000000000000";
        end if;
    end if;
end process;
--data matching 
process(clk,rst,a,b)
variable d_cnt:std_logic_vector(6 downto 0);
begin
if rst= '0' then
--    match_P <= '0';
	d_cnt:=(others=>'0');	
	match_data<=(others=>'0'); --??

--	MATE_D_s    <= (others => '0');
--	MATE_D1_s   <= (others => '0');
--	MATE_D2_s   <= (others => '0');
--	MATE_D3_s   <= (others => '0');
--	MATE_D4_s   <= (others => '0');
--	MATE_D5_s   <= (others => '0');
--	MATE_D6_s   <= (others => '0');
--	MATE_D7_s   <= (others => '0');
elsif rising_edge(video_clk)then
	-- 0
	d_cnt:=(others=>'0');
	
--	if read_en='1' then
	
		--xor compare 
		for i in 0 to 83 loop
	
			if (a(i) xor b(i)) ='1' then 
			       --
				if(count_33554431 = "1111111111111111111" )then
				    d_cnt:=d_cnt+"0000001";  -- can count 64 timimg 
		            MATE_D_s  <=a(19 downto 0) & b(19 downto 0);
		            MATE_D1_s <= MATE_D_s ;
		            MATE_D2_s <= MATE_D1_s;
		            MATE_D3_s <= MATE_D2_s;
		            MATE_D4_s <= MATE_D3_s;
		            MATE_D5_s <= MATE_D4_s;
		            MATE_D6_s <= MATE_D5_s;
		            MATE_D7_s <= MATE_D6_s;
		        else
		            null;
		        end if;	
		    end if;		
		end loop;
		
end if;	
end process;


end Behavioral;

