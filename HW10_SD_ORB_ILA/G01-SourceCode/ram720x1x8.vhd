library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity ram720x1x8 is
generic(				
    data_depth : integer    :=  720;		--1440
    data_bits  : integer    :=  8 		--64
);
  PORT (
  clka : IN STD_LOGIC;
  wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
  addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);	--720-1
  dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  clkb : IN STD_LOGIC;
  addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
  doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
);
end ram720x1x8;

architecture rtl of ram720x1x8 is
----------------------------------------
type type_bram is array (integer range 0 to data_depth-1) of std_logic_vector(data_bits-1 downto 0);
signal bram : type_bram := (others=> (others => '0'));		--array width of depth
---------------------------------------- ---------------------------------------- ----------------------------------------
begin
---------------------------------------- ----------------------------------------
--a_write_add:process(clka)
--begin			
--	if rising_edge(clka) then                         --RGB(8bits)
--		bram(conv_integer(addra)) <= dina; 
--	end if;
--end process;

b_write_add:process(clkb)
begin			
	if rising_edge(clkb) then                         --RGB(8bits)
		bram(conv_integer(addrb)) <= dina; 
	end if;
end process;
----------------------------------------
process (clkb)
	begin
	if rising_edge(clkb) then
		doutb <= bram(conv_integer(addra));
	end if;
end process;
---------------------------------------- ---------------------------------------- ----------------------------------------
end rtl;