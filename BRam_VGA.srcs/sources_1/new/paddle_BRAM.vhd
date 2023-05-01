library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity paddle_BRAM is
generic (				--one pixel one address 
    data_length : integer;		--1440
    data_width : integer;
    data_bits  : integer := 8 		--64
);
port
(
    rclk  : in std_logic;
    raddrx : in integer range 0 to data_length-1;
    raddry : in integer range 0 to data_width-1;
    rdata : out std_logic_vector(data_bits-1 downto 0)
);
end paddle_BRAM;

architecture rtl of paddle_BRAM is
----------------------------------------
type type_bram is array (integer range 0 to data_length-1, integer range 0 to data_width-1) of std_logic_vector(data_bits-1 downto 0);
signal bram : type_bram := (others => (others => (others => '1')));		--array width of depth
---------------------------------------- ---------------------------------------- ----------------------------------------
begin
---------------------------------------- ----------------------------------------
----------------------------------------
process (rclk)
	begin
	if rising_edge(rclk) then
		rdata <= bram(raddrx, raddry);
	end if;
end process;
---------------------------------------- ---------------------------------------- ----------------------------------------
end rtl;