library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity BRam is
generic (				--one pixel one address 
    data_length : integer;		--1440
    data_width : integer;
    data_bits  : integer :=  8 		--64
);
port
(
    rclk  : in std_logic;
    raddrx : in integer range 0 to data_length-1;
    raddry : in integer range 0 to data_width-1;
    rdata : out std_logic_vector(data_bits-1 downto 0)
);
end BRam;

architecture rtl of BRam is
----------------------------------------
constant ball_length : integer := 20;	--data_length
constant ball_width : integer := 20;    -- data_width 

type type_bram is array (integer range 0 to data_length-1, integer range 0 to data_width-1) of std_logic_vector(data_bits-1 downto 0);
signal bram : type_bram := (others => (others => (others => '0')));		--array width of depth
signal xCnt : integer := 0;
signal yCnt : integer := 0;
signal wen : std_logic := '1';
---------------------------------------- ---------------------------------------- ----------------------------------------
begin
---------------------------------------- ----------------------------------------
w_cnt: process(rclk)
begin
    if falling_edge(rclk) then
		if wen = '1' then
			case yCnt is
				when ball_width =>
					xCnt <= 0;      -- return < ^
					yCnt <= 0;
					wen <= '0';
				when others =>
					case xCnt is
						when ball_length =>
							xCnt <= 0;
							yCnt <= yCnt + 1;
                        when others =>
							xCnt <= xCnt + 1;
					end case;
			end case;
		end if;
    end if;
end process;
                    
process(rclk)
    begin
    if falling_edge(rclk) then
        if wen = '1' then
            if (xCnt-10)**2 + (yCnt-10)**2 <= (ball_length/2)**2 then
                bram(raddrx, raddry) <= (others => '1');
            else    
                bram(raddrx, raddry) <= (others => '0');
            end if;
        end if;
    end if;
end process;
----------------------------------------
process (rclk)
	begin
	if rising_edge(rclk) then
		rdata <= bram(raddrx, raddry);
	end if;
end process;
---------------------------------------- ---------------------------------------- ----------------------------------------
end rtl;