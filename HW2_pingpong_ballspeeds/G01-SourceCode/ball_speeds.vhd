library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity ball_speeds is
  Port ( reset : in std_logic;
        clock : in std_logic;
        led_out : out std_logic_vector ( 7 downto 0) );
end ball_speeds;

architecture Behavioral of ball_speeds is
    signal clk_div : STD_LOGIC;
	signal clk_cnt : STD_LOGIC_VECTOR (26 downto 0);   
	
		--CRC5
	signal data: bit := '0';
	signal crcOut: bit_vector(4 downto 0);
	signal crcIn: bit_vector(4 downto 0);
	signal crc_clk: bit_vector(1 downto 0);
	
	signal led_dir : STD_LOGIC;
	signal led_cnt : STD_LOGIC_VECTOR (3 downto 0); 
begin
	process( clock, reset, clk_div)	-- reset
	begin
		if reset = '0' then 
			clk_cnt <= (others => '0');
		elsif rising_edge(clock) then
			clk_cnt <= clk_cnt + '1';
        end if;
    end process;
	
--	   crcIn(4) <= crcOut(3);
--	   crcIn(3) <= crcOut(2);
--	   crcIn(2) <= crcOut(1);
--	   crcIn(1) <= crcOut(0);
--	   crcIn(0) <= crcOut(4); 
--	process ( data, crcIn )	-- crc5
--	begin	
--	if reset = '0' then 
--        crcOut <= (others => '0');
--    elsif rising_edge(clk_cnt(5)) then       --the longer clock for crc
--            crcOut(0) <= ( crcOut(4) xor data );
--            crcOut(1) <= crcOut(0);
--            crcOut(2) <= ( crcOut(4) xor crcOut(1));
--            crcOut(3) <= crcOut(2);
--            crcOut(4) <= crcOut(3);
--    end if;
--	end process;
--       crc_clk(0) <= crcOut(2);
--       crc_clk(1) <= crcOut(4);

--	crc_clk_div: process (led_cnt, crc_clk) -- clk_div_sel
--	begin	
--        case crc_clk is 
--            when "00" => clk_div <= clk_cnt(4);	--crc_out sel clk_div
--            when "01" => clk_div <= clk_cnt(3);
--            when "10" => clk_div <= clk_cnt(2);
--            when "11" => clk_div <= clk_cnt(1);
--        end case;
--	end process;    
	    	
	process(led_cnt)
	begin
        case led_cnt is
         when "0001" =>
            clk_div <= clk_cnt(22);
         when "0011" =>
            clk_div <= clk_cnt(21);
         when "0101" =>
            clk_div <= clk_cnt(25);
         when "0111" =>
            clk_div <= clk_cnt(24);
         when others => 
           clk_div <= clk_cnt(23);
        end case;
	end process;
	
	process( reset, clk_div )
	begin
		if reset = '0' then
			led_dir <= '1';	--initial direction
		elsif clk_div'event and clk_div = '1' then
			if led_dir = '1' and led_cnt = "0111" then 	--direction
				led_dir <= '0';
			elsif led_dir = '0' and led_cnt = "0010" then 
				led_dir <= '1';
			end if;
		end if;
	end process;
	
	led_move: process ( clk_div, led_dir, led_cnt)
	begin				
		if reset = '0' then
			led_cnt <= "0001";
		elsif clk_div'event and clk_div = '1' then 
            if led_dir = '0' then
                led_cnt <= led_cnt - '1';
            else    --if led_dir = '1'
                led_cnt <= led_cnt + '1';
            end if;
		end if;
	end process;
	
	process (led_cnt)
	begin
		case led_cnt is
           when "0001" => led_out <= "00000001";
           when "0010" => led_out <= "00000010";
           when "0011" => led_out <= "00000100";
           when "0100" => led_out <= "00001000";
           when "0101" => led_out <= "00010000";
           when "0110" => led_out <= "00100000";
           when "0111" => led_out <= "01000000";
           when "1000" => led_out <= "10000000";
           when others => led_out <= "00000000";
       end case;
   end process;
   
end Behavioral;
