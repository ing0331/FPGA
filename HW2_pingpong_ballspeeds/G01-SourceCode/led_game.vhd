library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity led_game is
  Port (reset : in std_logic;
        clock : in std_logic;
        bottom1 : in std_logic;
        bottom2 : in std_logic;
        score1_out : out std_logic_vector ( 6 downto 0);
        score2_out : out std_logic_vector ( 6 downto 0);
        led_out : out std_logic_vector ( 7 downto 0) );
end led_game;

architecture Behavioral of led_game is
    signal clk_div : STD_LOGIC;
	signal clk_cnt : STD_LOGIC_VECTOR (25 downto 0);
    signal score1 : STD_LOGIC_VECTOR ( 3 downto 0);
    signal score2 : STD_LOGIC_VECTOR ( 3 downto 0);
    signal score1_reg : STD_LOGIC_VECTOR ( 3 downto 0);
    signal score2_reg : STD_LOGIC_VECTOR ( 3 downto 0);
    
	signal led_dir : STD_LOGIC;
	signal led : STD_LOGIC_VECTOR (9 downto 0);
	
	signal sta : STD_LOGIC_VECTOR ( 1 downto 0);
	signal dir_over: std_logic_vector (1 downto 0);
begin
    process(reset, clock)       -- clk_divide
	begin
        if reset = '0' then
            clk_cnt <= (others => '0');
        elsif clock'event and clock = '1' then 
            clk_cnt <= clk_cnt + 1;
        end if;
    end process;
	clk_div <= clk_cnt(24); --100M Hz/ 2^26 per Led_spark
	
	FSM_sta: process( reset, clk_div, led, bottom1, bottom2 )
	begin	
		if reset = '0' then
			sta <= "00";	-- reset
		elsif clock'event and clock = '1' then    --clock?
			case sta is 	
				when "00" => 	-- reset --led(8) = '1'
					if (bottom1 = '1') then
						sta <= "01";
					end if;
				when "01" =>		-- right shift				
					if (led(1) = '1' and bottom2 = '1') then
						sta <= "10";	-- left shift
					elsif ( (led(1) = '0' and bottom2 = '1') or led(0) = '1')then --if 右移時 2搶拍 or 晚接 
						sta <= "11";	-- 已漏接
					end if;
				when "10" => 		-- left shift				
					if (led(8) = '1' and bottom1 = '1') then	--左擊中 or 發球
						sta <= "01";	-- right shift
					elsif ( (led(8) = '0' and bottom1 = '1') or led(9) = '1') then	--if 左移時 1搶拍 or 晚接 
						sta <= "11";	-- 
					end if;
				when "11" =>	-- keep direct stop at led(0) or led(9)
					if(dir_over = "01") then 	-- 2搶拍 or 漏接	
							if(bottom2 = '1') then	-- 之後 2發球
								if led(0) = '1'then 	--過頭才能發球
									sta <= "10";	--擊球左移
								end if;
							end if;
					elsif (dir_over = "10") then 
							if (bottom1 = '1') then	-- 後1發球	--此時 led(8) <= led(9)
								if led(9) = '1' then	
									sta <= "01";	
								end if;
							end if;
					end if;
			end case;
	    end if;
	end process;
	
	sta11_dir: process( reset, clk_div, led, bottom1, bottom2, sta)
	begin
		if reset = '0' then 
	   	   dir_over <= "00";
		elsif clock'event and clock = '1' then
			case sta is
				when "00" => dir_over <= "00";
				when "01" =>
					if ( (led(1) = '0' and bottom2 = '1') or led(0) = '1' )then --if 右移時 2搶拍 or 漏接
						dir_over <= "01";
					end if;
				when "10" =>
					if ( (led(8) = '0' and bottom1 = '1') or led(9) = '1' ) then	--if 左移時 1搶拍 or 漏接
						dir_over <= "10";	--from "00" to "10"
					end if;	
				when "11" => 
				        dir_over <= dir_over;
			end case;
		end if;
	end process;
	
	sta_led_move: process( reset, clk_div, sta, bottom1, bottom2)
	begin
		if reset = '0' then
			led <= (others => '0');	
			led(8) <= '1';		
		elsif clk_div'event and clk_div = '1' then
			case sta is 
				when "00" => 	-- reset
					led <= (others => '0');	
					led(8) <= '1';
				when "01" =>		      -- the leftest led right shift --推過頭 == 漏接
					led( 8 downto 0) <= led( 9 downto 1); --initial led(8) = '1'
					led(9) <= '0';	
				when "10" => 		-- left shift
					led( 9 downto 1 ) <= led(8 downto 0);
					led(0) <= '0';
				when "11" =>
				if (dir_over = "10") then	--if 左移時 1漏接, 
					if (led(9) = '0') then		-- shift to most left
						led( 9 downto 2 ) <= led( 8 downto 1 );
						led(1) <= '0';		--elsif led(9) = '1'
				    elsif (bottom1 = '1') then	-- --等球到最左，不再左移 ，1決定發球
						led(8) <= '1'; --持球
						led(9) <= '0';
                    end if;
				elsif (dir_over = "01") then  --if 右移時 2漏接, 	
                    if (led(0) = '0') then		 -- shift to most right
                        led(7 downto 0) <= led( 8 downto 1); 
                        led(8) <= '0';	
                    elsif (bottom2 = '1') then	--等球到最右	
                        led(1) <= '1';	
                        led(0) <= '0';
                    end if;
               end if;
			end case;
		end if;
	end process;
	led_out <= led(8 downto 1);
    	
	sta_score1: process( reset, clk_div, sta, led, bottom2 )
	begin
		if reset = '0' then
			score1 <= (others => '0');
			score1_reg <= (others => '0');
		elsif clock'event and clock = '1' then    --clock ? 
			case sta is
				when "00" =>
					score1 <= (others => '0');
		  	       	score1_reg <= (others => '0');
				when "01" =>	-- right shift
	               	score1 <= score1 ;		
	               	score1_reg <= score1;
				when "10" =>	-- left shift
					score1 <= score1 ;	
	               	score1_reg <= score1;	
				when "11" => 	-- 漏接
		          	if ( dir_over = "10" and score1_reg = score1)then  --add score, sta <= "11"
--					      score1_reg <= score1;
					   score1 <= score1 + 1;     --add once, sta "01" to "11"  
					end if;					
			end case;
		end if;
	end process;
	
	sta_score2: process( reset, clk_div, sta, led, bottom1 )
	begin
		if reset = '0' then
			score2 <= (others => '0');
			score2_reg <= (others => '0');
		elsif clock'event and clock = '1' then
			case sta is
				when "00" =>
					score2 <= (others => '0');
		          	score2_reg <= (others => '0');					
				when "01" =>	-- right shift
					score2 <= score2 ;
					score2_reg <= score2;
				when "10" =>	-- left shift
					score2 <= score2;
					score2_reg <= score2;
				when "11" => 	-- 漏接
                    if ( dir_over = "01" and score2_reg = score2 )then 
--					    score2_reg <= score2;
                      score2 <= score2 + 1;	
					end if;		
			end case;
		end if;
	end process;
	
	score1_seg: process(score1)
	begin
	   case score1 is 
	   when "0000" => score1_out <= "0000001";
	   when "0001" => score1_out <= "1001111";
	   when "0010" => score1_out <= "0010010";
	   when "0011" => score1_out <= "0000110"; -- "3" 
	   when "0100" => score1_out <= "1001100"; -- "4" 
	   when "0101" => score1_out <= "0100100"; -- "5" 
	   when "0110" => score1_out <= "0100000"; -- "6" 
	   when "0111" => score1_out <= "0001111"; -- "7" 
	   when "1000" => score1_out <= "0000000"; -- "8"     
	   when "1001" => score1_out <= "0000100"; -- "9" 
	   when others => score1_out <= "0011000"; -- "p"
	   end case;
	end process;
	
	score2_seg: process(score2)
	begin
	   case score2 is 
	   when "0000" => score2_out <= "0000001";
	   when "0001" => score2_out <= "1001111";
	   when "0010" => score2_out <= "0010010";
	   when "0011" => score2_out <= "0000110"; -- "3" 
	   when "0100" => score2_out <= "1001100"; -- "4" 
	   when "0101" => score2_out <= "0100100"; -- "5" 
	   when "0110" => score2_out <= "0100000"; -- "6" 
	   when "0111" => score2_out <= "0001111"; -- "7" 
	   when "1000" => score2_out <= "0000000"; -- "8"     
	   when "1001" => score2_out <= "0000100"; -- "9" 
	   when others => score2_out <= "0011000"; -- "p"
	   end case;
	end process;   
	   
end Behavioral;
