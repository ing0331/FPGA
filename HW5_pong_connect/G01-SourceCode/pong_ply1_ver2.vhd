library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity led_game is
      Port (
            clock : in std_logic;
            reset : in std_logic;
            bottom1 : in std_logic;
            led1_out : out std_logic_vector ( 8 downto 0);
			tri_led : inout std_logic 	-- '1' leftsh , '0' rightsh
			);
end led_game;
-- ver2  +�|��/�m��

architecture Behavioral of led_game is
    signal clk_div : STD_LOGIC;
	signal clk_cnt : STD_LOGIC_VECTOR (24 downto 0);
    signal dir_1: std_logic;

	-- type sta_type is (S0, led2, led1, dir_over);
	-- signal sta : sta_type := S0;
	signal sta : STD_LOGIC_VECTOR (1 downto 0);
	
	signal led1_cnt : integer range 0 to 8;
	signal r_led_cnt : integer range 0 to 8;
begin
    process(reset, clock)       -- clk_divide
	begin
        if reset = '0' then
            clk_cnt <= (others => '0');
        elsif clock'event and clock = '1' then 
            clk_cnt <= clk_cnt + 1;
        end if;
    end process;
	clk_div <= clk_cnt(23); --100M Hz/ 2^26 per Led_spark
	
	fsm: process(clk_div, reset, bottom1, led1_cnt, r_led_cnt)
	begin
        if reset = '0' then
            sta <= "00";
        elsif clk_div'event and clk_div = '1' then 
            case sta is
				when "00" =>		--�k�s
					if(bottom1 = '1') then	--�o�y
						sta <= "01";
					end if;
				when "01" =>	--�k��
					if(r_led_cnt = 1 and led1_cnt = 0) then	--�k�D����
						sta <= "10";
					else 
					   case (dir_1) is
					      when '1' =>
                             if(led1_cnt /= 8 and bottom1 = '1') or r_led_cnt = 8 then --�m��or�|��
                                sta <= "11";
                             end if;
                          when others =>
                            sta <= sta;
                       end case;
                    end if;
					
				when "10" => 	--ply2
					if(tri_led = '1') then	--led2_cnt = 0
						sta <= "01";
					end if;
					
				when "11" =>	--�m��B�|��
						
					if(r_led_cnt = 8 and bottom1 = '1') then		--�����o�y
						sta <= "01";
					end if;
					
				when others =>
					sta <= sta;
			end case;
        end if;
    end process;
	
	tri_led <= '1' when (r_led_cnt = 2 and led1_cnt = 1)	--�k���Y 
	else 'Z' when (r_led_cnt = 0 and led1_cnt = 0)	
	else '0' when (sta = "01");
	
	direct: process (clk_div, reset, sta)
	begin
		if reset = '0' then
			dir_1 <= '0';
		elsif clk_div'event and clk_div = '1' then 		
			case sta is
				when "00" =>
					dir_1 <= '0';
				when "01" =>
					case(led1_cnt) is      -- r_led_cnt
						when 8 => 
							if(bottom1 = '1') then	
								dir_1 <= '0';
							end if;
                        when others =>
							dir_1 <= dir_1;
						end case;
				when "10" =>	--��A����V
					dir_1 <= '1';
					
				when "11" =>
				
					case(r_led_cnt) is     --r_led_cnt = 8
					    when 0 => 
					       dir_1 <= '0'; 
						when 8 =>		--�|��
							dir_1 <= '0';
						when others =>		--�m��
							dir_1 <= '1';
                    end case;	
				
				when others =>
					dir_1 <= dir_1;				
			end case;
		end if;
	end process;		
		
	led_move: process(clk_div, reset, sta, dir_1)
	begin
		if reset = '0' then
			r_led_cnt <= 8;
			led1_cnt <= 8;
		elsif clk_div'event and clk_div = '1' then 		
			r_led_cnt <= led1_cnt;
			case sta is
				when "00" =>
					led1_cnt <= 8;
				when "01" =>
					case(dir_1) is
						when '0' =>
							led1_cnt <= led1_cnt - 1;
						when '1' =>
							led1_cnt <= led1_cnt + 1;
						when others =>
							led1_cnt <= led1_cnt;
						end case;
				when "10" =>
					led1_cnt <= 0;
					
				when "11" =>        	--dir = '1'
					case dir_1 is
						when '1' =>
							if(r_led_cnt = 8 ) then      -- and led_cnt = 0
							    led1_cnt <= 8;
							else
                                if(led1_cnt /= 0) then
                                    led1_cnt <= led1_cnt + 1;
                                end if;
							end if;
						when '0' =>       -- 0-->8
							led1_cnt <= 8;
						when others =>
							led1_cnt <= led1_cnt;
					end case;
						
				when others =>
					led1_cnt <= led1_cnt;				
			end case;
		end if;
	end process;
	
	led_out: process( clk_div, reset, led1_cnt) 
	begin		
		if reset = '0' then
			led1_out <= (others => '0');
			led1_out(led1_cnt) <= '1';
		elsif clk_div'event and clk_div = '1' then 	
			led1_out <= (others => '0');
			led1_out(led1_cnt) <= '1';
		end if;
	end process;

end Behavioral;