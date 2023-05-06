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
	
    scan_x : in integer range 0 to g_TOTAL_COLS-1;
    scan_y : in integer range 0 to g_TOTAL_ROWS-1;
	pad_addr_x : out integer range 0 to pad_leng-1;
    pad_addr_y : out integer range 0 to pad_width-1;

    ball_addr_x : out integer range 0 to ball_leng-1;
    ball_addr_y : out integer range 0 to ball_width-1;
			--bound at g_TOTAL_ROWS-1-pad_width
	o_pad2_y : out integer range 0 to g_TOTAL_ROWS-1-pad_width := g_TOTAL_ROWS/2- pad_width/2;
    o_pad1_y : out integer range 0 to g_TOTAL_ROWS-1-pad_width := g_TOTAL_ROWS/2- pad_width/2;

    o_ball_x : out integer;
    o_ball_y : out integer
	);
end entity FSM_VGA;

architecture RTL of FSM_VGA is
    constant c_TOTAL_COLS  : integer := 800;
    constant c_TOTAL_ROWS  : integer := 525;

    constant pad1_x : integer := 0;
    constant pad2_x : integer := c_TOTAL_COLS-1 -pad_leng;
    constant pad_length : integer := 32;
    constant pad_wid : integer := 160;
	
    constant ball_length : integer := 140;
    constant ball_wid : integer := 38;    

	signal sta : std_logic_vector(1 downto 0) := "00";
	signal ballDirx : std_logic := 'Z';
	signal ballDiry : std_logic := 'Z';
	
	signal pad1_y : integer := g_TOTAL_ROWS/2- pad_width/2 ;
    signal pad2_y : integer := g_TOTAL_ROWS/2- pad_width/2;
    signal ball_x : integer range -ball_leng to g_TOTAL_COLS-1 := pad_length;
    signal ball_y : integer range 0 to g_TOTAL_ROWS-1 -ball_width := g_TOTAL_ROWS/2 - ball_wid;
begin

FSM_pong: process(i_clk)
	begin
		if rst = '0' then
			sta <= "00";
		elsif rising_edge(i_clk) then
			case sta is 
				when "00" =>
					if btn1(1) = '1' or btn1(0) = '1' then	
						sta <= "01";
					end if;   					
				when "01" =>		--	--->|			
					if ball_x + ball_length > c_TOTAL_COLS-1-pad_leng then
						if ball_y > pad2_y - ball_wid and  ball_y < pad2_y+pad_width then 
							sta <= "10";
						else
							sta <= "11";
						end if;
					end if;		
				when "10" =>		--	|<---
					if ball_x <= pad_leng then
						if ball_y > pad1_y - ball_wid and  ball_y < pad1_y+pad_width then 
							sta <= "01";
						else
							sta <= "11";
						end if;
					end if;
				when "11" =>							
					case ball_x is						
						when c_TOTAL_COLS-1-pad_length => 		--	O___
							if btn2(1) = '1' or btn2(0) = '1' then	-- |	
								sta <= "10";    --	<--           --   |_____    
							end if;                             
						when pad_length =>
							if btn1(1) = '1' or btn1(0) = '1' then
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
	
sta_ballDir: process(i_clk)
	begin
		if rst = '0' then
			ballDirx <= 'Z';
			ballDiry <= 'Z';
		elsif rising_edge(i_clk) then	
			case ball_y is 
				when c_TOTAL_ROWS-1 -ball_wid =>	--__o__
					ballDiry <= '0';		-- ____
				when 0 =>					--  O
					ballDiry <= '1';
				when c_TOTAL_ROWS/2-pad_wid/2 =>			
					ballDiry <= '1';
				when others =>
					ballDiry <= ballDiry;
			end case;				
			case sta is 
				when "01" =>			
					case ball_x is 		-->
						when 0 to pad_length => 	--btn1
							ballDirx <= '1';
						when c_TOTAL_COLS-1 -pad_length to c_TOTAL_COLS-1  =>
							ballDirx <= '0';
						when others =>
							ballDirx <= ballDirx;
					end case;
					-- case ball_y is 
						-- when c_TOTAL_ROWS-1 -ball_wid =>	--__o__
							-- ballDiry <= '0';		-- ____
						-- when 0 =>					--  O
							-- ballDiry <= '1';
						-- when c_TOTAL_ROWS/2-pad_wid/2 =>			
							-- ballDiry <= '1';
						-- when others =>
							-- ballDiry <= ballDiry;
					-- end case;				
				when "10" =>		--	<---
					case ball_x is 		--
						when c_TOTAL_ROWS -pad_length -ball_length to c_TOTAL_COLS-1 =>	--btn2
							ballDirx <= '0';
						when 0 to pad_length =>
							ballDirx <= '1';
						when others =>
							ballDirx <= ballDirx;
					end case;
					-- case ball_y is 
						-- when c_TOTAL_ROWS-1 -ball_wid =>	--__o__
							-- ballDiry <= '0';		-- ____
						-- when 0 =>					--  O
							-- ballDiry <= '1';
						-- when others =>
							-- ballDiry <= ballDiry;
					-- end case;					
				when "11" =>	--over
					case ball_x is
						when c_TOTAL_COLS-1 => 		-- __o/
							ballDirx <= 'Z';
							ballDiry <= 'Z';							
						when -ball_length =>
							ballDirx <= 'Z';
							ballDiry <= 'Z';							
						when others =>
							ballDirx <= ballDirx;
							ballDiry <= ballDiry;
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
				-- when c_TOTAL_COLS-1 -ball_length =>
					-- ballDirx <= '0';
				-- when 0 =>
					-- ballDirx <= '1';
				-- when others =>
					-- ballDirx <= ballDirx;
			-- end case;
			-- case ball_y is 
				-- when c_TOTAL_ROWS-1 -ball_wid =>
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
			if ball_x >= c_TOTAL_COLS-1 then  --__o|
				ball_x <= c_TOTAL_COLS-1-pad_length-ball_length;
			elsif ball_x <= -ball_length then
				ball_x <= pad_length;
			end if;
			case ballDirx is 
				when '0' =>
					ball_x <= ball_x - 1;
				when '1' =>
					ball_x <= ball_x + 1;
				when others =>
					ball_x <= c_TOTAL_COLS-1-pad_length-ball_length;
			end case;					
		end if;
	end process;
	
ballMoveY: process(rst, move_clk, ballDiry, ballDirx)
        begin
            if rst = '0' then
                ball_y <= c_TOTAL_ROWS/2-ball_wid/2;
            elsif rising_edge(move_clk) then 
                if  ball_x >= c_TOTAL_COLS-1 then  --__o|                                  
                    ball_y <= pad2_y + pad_wid/2 -ball_wid/2;                                   --    /         
                elsif ball_x <= -ball_length then
                    ball_y <= pad1_y + pad_wid/2 -ball_wid/2;
                end if;
                case ballDiry is 
                    when '0' =>
                        ball_y <= ball_y - 1;
                    when '1' =>
                        ball_y <= ball_y + 1;
                    when others =>
                        ball_y <= pad2_y + pad_wid/2 -ball_wid/2;
                end case;              
            end if;
        end process;
	
pad1_move: process(move_clk)
	begin
		if rst = '0' then
            pad1_y <= c_TOTAL_ROWS/2-pad_wid/2;
		elsif rising_edge(move_clk) then
		  if pad1_y > 0 and pad1_y < c_TOTAL_ROWS-pad_wid then
			case btn1 is 
				when "10" =>
					pad1_y <= pad1_y + 1;
				when "01" =>
					pad1_y <= pad1_y - 1;
				when others =>
					pad1_y <= pad1_y;
			end case;
		  end if;
		end if;
	end process;
	
pad2_move: process(move_clk)
	begin
		if rst = '0' then
            pad2_y <= c_TOTAL_ROWS/2-pad_wid/2;
		elsif rising_edge(move_clk) then
          if pad2_y > 0 and pad2_y < c_TOTAL_ROWS-pad_wid then
			case btn2 is 
				when "10" =>
					pad2_y <= pad2_y + 1;
				when "01" =>
					pad2_y <= pad2_y - 1;
				when others =>
					pad2_y <= pad2_y;
			end case;
		  end if;
		end if;
	end process;
	
	ball_addr_x <= scan_x - ball_x when scan_x - ball_x >= 0 and scan_x <= ball_x + ball_leng -1;
	ball_addr_y <= scan_y - ball_y when (scan_y >= ball_y and scan_y <= ball_y + ball_width -1) ;
	-- ball_draw: process (scan_x, scan_y, ball_x, ball_y, scan_x, scan_y)
	-- begin
	-- if rising_edge(i_clk) then
        -- if (scan_x >= ball_x and scan_x <= ball_x + ball_leng -1) and (scan_y >= ball_y and scan_y <= ball_y + ball_width -1) then
            -- ball_addr_x <= scan_x - ball_x;
            -- ball_addr_y <= scan_y - ball_y;
        -- end if;	
	-- end if;
	-- end process; 
	
	pad_draw: process (scan_x, scan_y, ball_x, ball_y, scan_x, scan_y)
	begin
	if rising_edge(i_clk) then
		if (scan_x >= pad1_x and scan_x <= ball_x + ball_leng -1) and (scan_y >= pad1_y and scan_y <= pad1_y + pad_width -1) then
            pad_addr_x <= scan_x - pad1_x;
            pad_addr_y <= scan_y - pad1_y;
		elsif (scan_x >= g_TOTAL_COLS-1-pad_length and scan_x <= g_TOTAL_COLS-1) and (scan_y >= pad2_y and scan_y <= pad2_y + pad_width -1) then
            pad_addr_x <= scan_x - pad2_x;
            pad_addr_y <= scan_y - pad2_y;
		end if;			
	end if;
	end process; 

	o_ball_x <= ball_x;
	o_ball_y <= ball_y;
	o_pad1_y <= pad1_y;
	o_pad2_y <= pad2_y;

end RTL;