library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

entity FSM_VGA is
  generic (
    g_TOTAL_COLS  : integer;
    g_TOTAL_ROWS  : integer;
	
	ball_leng : integer;
	ball_width : integer;
	pad_leng : integer;
	pad_width : integer	
    );
  port (
	i_clk : in std_logic;
	move_clk : in std_logic;
	rst : in std_logic;
								--up, down
	btn1 : in std_logic_vector (1 downto 0);	
	btn2 : in std_logic_vector (1 downto 0);

			--bound at g_TOTAL_ROWS-1-pad_width
    o_pad1_y : out integer range 0 to g_TOTAL_ROWS-1-pad_width := g_TOTAL_ROWS/2- pad_width/2;
	o_pad2_y : out integer range 0 to g_TOTAL_ROWS-1-pad_width := g_TOTAL_ROWS/2- pad_width/2;

    o_ball_x : out std_logic_vector(9 downto 0);
    o_ball_y : out std_logic_vector(9 downto 0)
	);
end entity FSM_VGA;

architecture RTL of FSM_VGA is
    constant c_TOTAL_COLS  : integer := 800;
    constant c_TOTAL_ROWS  : integer := 525;
    constant c_ACTIVE_COLS : integer := 640;
    constant c_ACTIVE_ROWS : integer := 480;
    constant ball_length : integer := 140;  ---378
    constant ball_wid : integer := 38;    
    
    constant pad_length : integer := 32;
    constant pad_wid : integer := 160;
    constant pad1_x : integer := 0;
    constant pad2_x : integer := c_ACTIVE_COLS-1 -pad_leng -2;      -----

	signal pad1_y : integer := g_TOTAL_ROWS/2- pad_width/2;
    signal pad2_y : integer := g_TOTAL_ROWS/2- pad_width/2;
	signal sta : std_logic_vector(1 downto 0) := "00";
    signal ball_x : integer range -ball_length to g_TOTAL_COLS-1 := pad_length;
    signal ball_y : integer range 0 to g_TOTAL_ROWS-1 -ball_width := g_TOTAL_ROWS/2 - ball_wid/2;

	signal ballDirx : std_logic := 'Z';
	signal ballDiry : std_logic := 'Z';	
	signal Dir_en : std_logic := 'Z';
begin
FSM_pong: process(i_clk, rst, btn1, btn2)
	begin
		if rst = '0' then
			sta <= "00";
		elsif rising_edge(i_clk) then
			case sta is 
				when "00" =>
					if btn1(1) = '1' or btn1(0) = '1' then	
						sta <= "01";
				    else
				        sta <= sta;
					end if;   					
				when "01" =>		--	--->|			
					if ball_x >= c_ACTIVE_COLS-1-pad_leng-ball_leng then
						if (ball_y > pad2_y - ball_wid and ball_y < pad2_y+pad_width) then 
							sta <= "10";
						else
							sta <= "11";
						end if;
					end if;		
				when "10" =>		--	|<---
					if ball_x <= pad_leng then
						if (ball_y > pad1_y - ball_wid and ball_y < pad1_y+pad_width) then 
							sta <= "01";
						else
							sta <= "11";
						end if;
					end if;
				when "11" =>							
					case ball_x is						
						when c_ACTIVE_COLS-1-pad_length-ball_length => 		--	O___
							if Dir_en = '0' and(btn2(1) = '1' or btn2(0) = '1') then	-- |			--
								sta <= "10";    --	<--           --   |_____    
							end if;                             
						when pad_length =>
							if Dir_en = '0' and (btn1(1) = '1' or btn1(0) = '1') then		--
								sta <= "01";	-->
							end if;
						when others =>
							sta <= sta;
					end case;
				when others =>
					sta <= sta;
			end case;		
		end if;
	end process;
	
process(i_clk, rst)	
begin
	if rst = '0' then
		Dir_en <= '0';
	elsif rising_edge(i_clk) then	
		case sta is
			when "00" =>
				Dir_en <= '0';
			when "01"|"10" =>
				Dir_en <= '1';
			when "11" =>
				case ball_x is
					when c_ACTIVE_COLS-1 => 		-- __o/
						Dir_en <= '0';					
					when -ball_length =>
						Dir_en <= '0';					
					when others =>
						Dir_en <= Dir_en;					
				end case;
			when others =>
				Dir_en <= Dir_en;			
		end case;
	end if;
end process;

sta_ballDir: process(i_clk, rst)
	begin
		if rst = '0' then
			ballDirx <= 'Z';
			ballDiry <= 'Z';
		elsif rising_edge(i_clk) then	
			-- case ball_y is 
				-- when c_ACTIVE_ROWS-1 -ball_wid =>	--__o__
					-- ballDiry <= '0';		-- ____
				-- when 0 =>					--  O
					-- ballDiry <= '1';
				-- when c_ACTIVE_ROWS/2-ball_wid/2 =>		--左發 
				    -- if ball_x = ball_leng and btn1 = "01" then	    
    					-- ballDiry <= '1';
				    -- elsif ball_x = ball_leng and btn1 = "10" then	    
    					-- ballDiry <= '0';	 
                    -- end if;
				-- when others =>
					-- ballDiry <= ballDiry;
			-- end case;				
			case sta is 
			    when "00" =>         ---
			         ballDirx <= 'Z';
                     ballDiry <= 'Z';    
				when "01" =>			
					case ball_x is 		-->
						when pad_length => 		--btn1		--"11"後重發
                            ballDirx <= '1';
							
						 -- when c_ACTIVE_COLS-1 -pad_length to c_ACTIVE_COLS-1  =>		
							 -- ballDirx <= '0';
							 
						when others =>
							ballDirx <= ballDirx;
					end case;
					case ball_y is 
						when c_ACTIVE_ROWS-1 -ball_wid =>	--__o__
							ballDiry <= '0';		-- ____
						when 0 =>					--  O
							ballDiry <= '1';
							
						when others => --when c_ACTIVE_ROWS/2-ball_wid/2 =>		--左發 
							if ball_x = pad_leng and btn1 = "01" then	    
								ballDiry <= '1';
							elsif ball_x = pad_leng and btn1 = "10" then	    
								ballDiry <= '0';
							else
								ballDiry  <= ballDiry;
							end if;
						-- when others =>
							-- ballDiry <= ballDiry;
					end case;						
				when "10" =>		--	<---
					case ball_x is 				--sta <= "01"
					
						when c_ACTIVE_COLS-1 -pad_length -ball_length to c_ACTIVE_COLS-1 => --=>
							ballDirx <= '0';
							
						 -- when 0 to pad_length =>
							 -- ballDirx <= '1';
						when others =>
							ballDirx <= ballDirx;
					end case;
					case ball_y is 
						when c_ACTIVE_ROWS-1 -ball_wid =>	--__o__
							ballDiry <= '0';		-- ____
						when 0 =>					--  O
							ballDiry <= '1';
						when others => -- when c_ACTIVE_ROWS/2-ball_wid/2 =>	--右發
							if ball_x = c_ACTIVE_COLS-1-pad_leng -ball_length and btn2 = "01" then	    
								ballDiry <= '1';
							elsif ball_x = c_ACTIVE_COLS-1-pad_leng -ball_length and btn2 = "10" then	    
								ballDiry <= '0';	 
							else
								ballDiry <= ballDiry;
							end if;
						-- when others =>
							-- ballDiry <= ballDiry;
					end case;								
				when "11" =>	--over
					case ball_x is
						when c_ACTIVE_COLS-1 -pad_length-ball_length to c_ACTIVE_COLS-1 -1 =>
							ballDirx <= ballDirx;
							if ball_y = c_ACTIVE_ROWS-1 or ball_y = pad2_y - ball_wid then
								ballDiry <= '0';
							elsif ball_y = pad2_y + pad_wid then
								ballDiry <= '1';
							else
								ballDiry  <= ballDiry;
							end if;
						when -(ball_length)+2 to pad_length =>
							
							ballDirx <= ballDirx;
							if ball_y = pad1_y - ball_wid or ball_y = c_ACTIVE_ROWS-1 then
								ballDiry <= '0';
							elsif ball_y = 0 or ball_y = pad1_y + pad_wid then
								ballDiry <= '1';
							else
								ballDiry  <= ballDiry;
							end if;						
			
						-- when c_ACTIVE_COLS-1 => 		-- __o/
							-- ballDirx <= 'Z';
							-- ballDiry <= 'Z';					
						-- when -ball_length =>
							-- ballDirx <= 'Z';
							-- ballDiry <= 'Z';				
							
						when others =>
							-- ballDirx <= 'Z';
							-- ballDiry <= 'Z';
							if ball_y = c_ACTIVE_ROWS-1 -ball_wid then
								ballDiry <= '0';
							elsif ball_y = 0 then
								ballDiry <= '1';
							end if;
					end case;
				when others =>
					ballDirx <= ballDirx;
					ballDiry <= ballDiry;
			end case; 
		end if;
	end process;
	
-- ballDir: process(i_clk)		--no FSM
	-- begin
		-- if rst = '0' then
			-- ballDirx <= '1';
			-- ballDiry <= '1';
		-- elsif rising_edge(i_clk) then	
			-- case ball_x is 
				-- when c_ACTIVE_COLS-1 -ball_length =>
					-- ballDirx <= '0';
				-- when 0 =>
					-- ballDirx <= '1';
				-- when others =>
					-- ballDirx <= ballDirx;
			-- end case;
			-- case ball_y is 
				-- when c_ACTIVE_ROWS-1 -ball_wid =>
					-- ballDiry <= '0';
				-- when 0 =>
					-- ballDiry <= '1';
				-- when others =>
					-- ballDiry <= ballDiry;
			-- end case;		
		-- end if;
	-- end process;
	
ballMoveX: process(rst, move_clk, ballDiry, ballDirx)
	begin
		if rst = '0' then
			ball_x <= pad_length;
		elsif rising_edge(move_clk) then 
			case sta is
				when "00" =>
					ball_x <= ball_x;
				-- when "11" =>
					-- if ball_x >= c_ACTIVE_COLS-1 then  --__o|
						-- ball_x <= c_ACTIVE_COLS-1-pad_length-ball_length;
					-- elsif ball_x <= -ball_length then
						-- ball_x <= pad_length;
					-- else
						-- ball_x <= ball_x;
					-- end if;
				when others =>		
					if Dir_en = '1' then
					
						case ballDirx is 
							when '0' =>		--c_ACTIVE_COLS-1 -pad_length-ball_length to c_ACTIVE_COLS-1 -2
								ball_x <= ball_x - 1;
							when '1' =>
								ball_x <= ball_x + 1;
								
							when others =>			--'Z'
								ball_x <= ball_x;
						end case;		
					else
						if ball_x >= c_ACTIVE_COLS-1 -1 then  --__o|
							ball_x <= c_ACTIVE_COLS-1-pad_length-ball_length;
						elsif ball_x <= -ball_length +1 then
							ball_x <= pad_length;
						else
							ball_x <= ball_x;
						end if;
					end if;
			end case;
		end if;
	end process;
	
ballMoveY: process(rst, move_clk, ballDiry, ballDirx)
        begin
            if rst = '0' then
                ball_y <= c_ACTIVE_ROWS/2-ball_wid/2;
            elsif rising_edge(move_clk) then 
				case sta is
					when "00" =>
						ball_y <= ball_y;
					-- when "11" =>
						-- if  ball_x >= c_ACTIVE_COLS-1 then  --__o|                                  
							-- ball_y <= pad2_y + pad_wid/2 -ball_wid/2;                                   --    /         
						-- elsif ball_x <= -ball_length then
							-- ball_y <= pad1_y + pad_wid/2 -ball_wid/2;
						-- else
							-- ball_y <= ball_y;
						-- end if;
					when others =>
						if Dir_en = '1' then
						
							case ballDiry is 
								when '0' =>
									ball_y <= ball_y - 1;
								when '1' =>
									ball_y <= ball_y + 1;
									
								when others =>		--'Z'
									ball_y <= ball_y;
							end case;
						else
							if  ball_x >= c_ACTIVE_COLS-1 -1 then  --__o|                                  
								ball_y <= pad2_y + pad_wid/2 -ball_wid/2;                                   --    /         
							elsif ball_x <= -ball_length+1 then
								ball_y <= pad1_y + pad_wid/2 -ball_wid/2;
							else
								ball_y <= ball_y;
							end if;
						end if;
                end case;
            end if;
        end process;
	
pad1_move: process(rst, move_clk, pad1_y)
	begin
		if rst = '0' then
            pad1_y <= c_ACTIVE_ROWS/2-pad_wid/2;
		elsif rising_edge(move_clk) then
		  if pad1_y >= 0 and pad1_y <= c_ACTIVE_ROWS-pad_wid then
			case btn1 is 
				when "10" =>
					if pad1_y < c_ACTIVE_ROWS-pad_wid-1 then
						pad1_y <= pad1_y + 1;
					end if;
				when "01" =>
					if pad1_y > 0 then
						pad1_y <= pad1_y - 1;
					end if;
				when others =>
					pad1_y <= pad1_y;
			end case;
		  end if;
		end if;
	end process;
	
pad2_move: process(rst, move_clk, pad2_y)
	begin
		if rst = '0' then
            pad2_y <= c_ACTIVE_ROWS/2-pad_wid/2;
		elsif rising_edge(move_clk) then
          if pad2_y >= 0 and pad2_y <= c_ACTIVE_ROWS-pad_wid then
			case btn2 is 
				when "10" =>
					if pad2_y < c_ACTIVE_ROWS-pad_wid-1 then
						pad2_y <= pad2_y + 1;
					end if;	
				when "01" =>
					if pad2_y > 0 then
						pad2_y <= pad2_y - 1;
					end if;
				when others =>
					pad2_y <= pad2_y;
			end case;
		  end if;
		end if;
	end process;

	o_ball_x <= std_logic_vector(to_unsigned(ball_x, o_ball_x'length));
	o_ball_y <= std_logic_vector(to_unsigned(ball_y, o_ball_y'length));
	o_pad1_y <= pad1_y;
	o_pad2_y <= pad2_y;

end RTL;