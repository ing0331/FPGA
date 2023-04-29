library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity pong_player2 is
  Port (
  reset : in std_logic;
  clock : in std_logic;
  bottom2 : in std_logic;
  led2_out : out std_logic_vector ( 8 downto 0);
  tri_led : inout std_logic         -- '1' leftsh , '0' rightsh
  );
end pong_player2;
-- ver2  +漏接/搶拍

architecture Behavioral of pong_player2 is
    signal clk_div : STD_LOGIC;
	signal clk_cnt : STD_LOGIC_VECTOR (25 downto 0);
    signal dir2: std_logic;

	-- type sta_type is (S0, led2, led1);
	-- signal sta : sta_type := S0;
	signal sta : STD_LOGIC_VECTOR (1 downto 0);
	
	signal led2_cnt : integer range 0 to 8;
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
	
	fsm: process(clk_div, reset, bottom2, led2_cnt, r_led_cnt)
	begin
        if reset = '0' then
            sta <= "10";	--ply1 來回
        elsif clk_div'event and clk_div = '1' then 
            case sta is
				when "00" =>		--歸零
					if(tri_led = '1') then	--接到ply1 的右盡頭
						sta <= "01";
					end if;
				when "01" =>	   --右移
				
					if( r_led_cnt = 1 and led2_cnt = 0 ) then	--ply2右道底部
						sta <= "10";			
					else
						case (dir2) is
					      when '1' =>
                             if(led2_cnt /= 8 and bottom2 = '1') or r_led_cnt = 8 then --搶拍or漏接
							sta <= "11";
						end if;
							when others =>
								sta <= sta;
						end case;
					end if;
					
				when "10" =>	
					if(tri_led = '1') then	--led2_cnt = 0
						sta <= "01";
					end if;
					
				when "11" =>
					if(r_led_cnt = 8 and bottom2 = '1') then
						sta <= "01"; 	
					end if;
					
				when others =>
					sta <= sta;
			end case;
        end if;
    end process;
	
	tri_led <= '1' when ( r_led_cnt = 2 and led2_cnt = 1 )	--左盡頭 
	else 'Z' when (r_led_cnt = 0 and led2_cnt = 0)
	else '0' when (sta = "01");
	
	direct: process (clk_div, reset, sta)
	begin
		if reset = '0' then
			dir2 <= '1';
		elsif clk_div'event and clk_div = '1' then 		
			case sta is
				when "00" =>
					dir2 <= '1';
				when "01" =>
					case(led2_cnt) is
						when 8 =>
							if(bottom2 = '1') then
								dir2 <= '0';
							end if;
						when others =>
							dir2 <= dir2;
                    end case;
				when "10" =>    --轉態後轉向
					dir2 <= '1';		
					
				when "11" =>				
					case(r_led_cnt) is
						when 0 =>		--漏接
							dir2 <= '0';
						when 8 =>		--漏接
							dir2 <= '0';		
						when others =>		--搶拍
							dir2 <= '1';
                    end case;			
					
				when others =>
					dir2 <= dir2;				
			end case;
		end if;
	end process;		
		
	led_move: process(clk_div, reset, sta, dir2)
	begin
		if reset = '0' then
			r_led_cnt <= 0;
			led2_cnt <= 0;
		elsif clk_div'event and clk_div = '1' then 		
			r_led_cnt <= led2_cnt;
			case sta is
				when "00" =>
					led2_cnt <= 0;
				when "01" =>
					case(dir2) is
						when '0' =>
							led2_cnt <= led2_cnt - 1;
						when '1' =>
							led2_cnt <= led2_cnt + 1;
						when others =>
							led2_cnt <= led2_cnt;
                    end case;
				when "10" =>
					led2_cnt <= 0;
				
				when "11" =>
					case dir2 is
						when '1' =>		--搶拍 等落地
							if(r_led_cnt = 8) then 	--7, 8, 0, 8
								led2_cnt <= 8;
							else
								if (led2_cnt /= 0) then
								    led2_cnt <= led2_cnt + 1;
                                end if;
							end if;
						when '0' =>		--漏接落地面
							led2_cnt <= 8;		--8, 0, 8
						when others =>
							led2_cnt <= led2_cnt;
					end case;

				when others =>
					led2_cnt <= led2_cnt;				
			end case;
		end if;
	end process;
	
	led_out: process( clk_div, reset, led2_cnt) 
	begin		
		if reset = '0' then
			led2_out <= (others => '0');
			led2_out(led2_cnt) <= '1';
		elsif clk_div'event and clk_div = '1' then 	
			led2_out <= (others => '0');
			led2_out(led2_cnt) <= '1';
		end if;
	end process;

end Behavioral;
