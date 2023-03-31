
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

entity VGA_line_60 is
	generic(  
	          clk_div : integer := 25000000; --1 sec
		      g_ACTIVE_COLS : integer := 320;	--half of active area
		      g_ACTIVE_ROWS : integer := 240; 
		      radios : integer := 10000
		      );
    Port ( 
           i_col_count : in std_logic_vector(9 downto 0);
           i_row_count : in std_logic_vector(9 downto 0);
           i_clk : in STD_LOGIC;
           o_line : out STD_LOGIC 
              );
end VGA_line_60;

architecture Behavioral of VGA_line_60 is
                             --tan(sec)/1000
    constant tan0 : integer := 0;
    constant tan6 : integer := 105;--real := 0.105*10.0;  --(sqrt(5.0-2.0*sqrt(5.0))-sqrt(3.0)/3.0)/(1.0+sqrt(3.0)+sqrt(3.0)/3.0*sqrt(5.0-2.0*sqrt(5.0)))*10.0;
    constant tan12 : integer := 212;--real := 0.212*10.0;    --(tan6+tan6)/(1.0-(tan6*tan6))*10.0;
    constant tan18 : integer := 324;--real := 0.324*10.0;    --(tan12+tan6)/(1.0-(tan12*tan6))*10.0;
    constant tan24 : integer := 445;--real := 0.445*10.0;    --(tan18+tan6)/(1.0-(tan18*tan6))*10.0;
    constant tan30 : integer := 577;--real := 0.577*10.0;    --(tan24+tan6)/(1.0-(tan24*tan6))*10.0;
    constant tan36 : integer := 726;--real := 0.726*10.0;    --(tan30+tan6)/(1.0-(tan30*tan6))*10.0;
    constant tan42 : integer := 900;--real := 0.9004*10.0;    --(tan36+tan6)/(1.0-(tan36*tan6))*10.0;
    constant tan48 : integer := 1110;--real := 1.1106*10.0;    --(tan42+tan6)/(1.0-(tan42*tan6))*10.0;
    constant tan54 : integer := 1376;--real := 1.376*10.0;    --(tan48+tan6)/(1.0-(tan48*tan6))*10.0;
    constant tan60 : integer := 1732;--real := 1.732*10.0;    --(tan54+tan6)/(1.0-(tan54*tan6))*10.0;
    constant tan66 : integer := 2246;--real := 2.246*10.0;    --(tan60+tan6)/(1.0-(tan60*tan6))*10.0;
    constant tan72 : integer := 3077;--real := 3.077*10.0;    --(tan66+tan6)/(1.0-(tan66*tan6))*10.0;
    constant tan78 : integer := 4704;--real := 4.704*10.0;    --(tan72+tan6)/(1.0-(tan72*tan6))*10.0;
    constant tan84 : integer := 9514;--real := 9.514*10.0;    --(tan78+tan6)/(1.0-(tan78*tan6))*10.0;
    constant tan90 : integer := 0;--real := 0.0;    --sec = 15 or 45
    constant tan96 : integer := -9514;--real := -9.514*10.0;    -- (tan48+tan48)/(1.0-(tan48*tan48))*10.0;
    constant tan102 : integer := -4704;--real := -4.704*10.0;    --(tan96+tan6)/(1.0-(tan96*tan6))*10.0;
    constant tan108 : integer := -3077;--real := -3.077*10.0;    --(tan102+tan6)/(1.0-(tan102*tan6))*10.0;
    constant tan114 : integer := -2246;--real := -2.246*10.0;    --(tan108+tan6)/(1.0-(tan108*tan6))*10.0;
    constant tan120 : integer := -1732;--real := -1.732*10.0;    --(tan114+tan6)/(1.0-(tan114*tan6))*10.0;
    constant tan126 : integer := -1376;--real := -1.376*10.0;    --(tan120+tan6)/(1.0-(tan120*tan6))*10.0;
    constant tan132 : integer := -1110;--real := -1.1106*10.0;    --(tan126+tan6)/(1.0-(tan126*tan6))*10.0;
    constant tan138 : integer := -900;--real := -0.9004*10.0;    --(tan132+tan6)/(1.0-(tan132*tan6))*10.0;
    constant tan144 : integer := -726;--real := -0.726*10.0;    --(tan138+tan6)/(1.0-(tan138*tan6))*10.0;
    constant tan150 : integer := -557;--real := -0.577*10.0;    --(tan144+tan6)/(1.0-(tan144*tan6))*10.0;
    constant tan156 : integer := -445;--real := -0.445*10.0;    --(tan150+tan6)/(1.0-(tan150*tan6))*10.0;
    constant tan162 : integer := -324;--real := -0.324*10.0;    --(tan156+tan6)/(1.0-(tan156*tan6))*10.0;
    constant tan168 : integer := -212;--real := -0.212*10.0;    --(tan162+tan6)/(1.0-(tan162*tan6))*10.0;
    constant tan174 : integer := -105;--real := -0.105*10.0;    --(tan168+tan6)/(1.0-(tan168*tan6))*10.0;
    constant tan180 : integer := 0;--real := 0.0;
    type tan_div is array (integer range 0 to 30) of integer;
    constant tan : tan_div := (tan180, tan174,tan168,tan162,tan156,tan150,tan144,tan138,tan132,tan126,tan120,tan114,tan108,tan102,tan96, tan90, tan84, tan78, tan72, tan66, tan60, tan54, tan48,tan42,tan36, tan30,tan24,tan18,tan12,tan6, tan0);
    
	signal sec : integer := 0;
begin

rolling_delta : process(i_clk)
    variable cnt : integer := 0;
    begin    
        if(rising_edge(i_clk)) then
            if(cnt < clk_div) then      --sec >= 2
                cnt := cnt + 1;     --­¡±a
            else                 --1 second past
                cnt := 0;
                sec <= sec + 1;
            end if; 
        end if;
        if sec > 60 then 
            sec <= 0;
        end if;
    end process;

	o_line	<= '1' when (  ( (to_integer(unsigned(i_Col_Count))- 320)**2 + (to_integer(unsigned(i_Row_Count))- 240)**2 <= radios) and ( ( (sec/= 0 and sec /= 15 and sec < 30) and to_integer(unsigned(i_col_count)) >= g_ACTIVE_COLS and to_integer(unsigned(i_col_count))-g_ACTIVE_COLS <= (to_integer(unsigned(i_row_count))-g_ACTIVE_ROWS)*tan(sec)/1000 + 1 
                                        and to_integer(unsigned(i_col_count))- g_ACTIVE_COLS >= (to_integer(unsigned(i_row_count))-g_ACTIVE_ROWS)*tan(sec)/1000 - 1 )
                                       --up/down sh
                                        or ( (sec/= 0 and sec /= 15 and sec < 30) and ( ( to_integer(unsigned(i_col_count)) >= g_ACTIVE_COLS and to_integer(unsigned(i_col_count))-g_ACTIVE_COLS <= (to_integer(unsigned(i_row_count))-g_ACTIVE_ROWS+1)*tan(sec)/1000
                                        and to_integer(unsigned(i_col_count))- g_ACTIVE_COLS >= (to_integer(unsigned(i_row_count))-g_ACTIVE_ROWS - 1)*tan(sec)/1000 ) or ( to_integer(unsigned(i_col_count)) >= g_ACTIVE_COLS and to_integer(unsigned(i_col_count))-g_ACTIVE_COLS <= (to_integer(unsigned(i_row_count))-g_ACTIVE_ROWS-1)*tan(sec)/1000
                                        and to_integer(unsigned(i_col_count))- g_ACTIVE_COLS >= (to_integer(unsigned(i_row_count))-g_ACTIVE_ROWS + 1)*tan(sec)/1000 ) ) )
                                        
                                       
                                        or ( (sec /= 45 and sec > 30) and to_integer(unsigned(i_col_count)) <= g_ACTIVE_COLS and to_integer(unsigned(i_col_count))-g_ACTIVE_COLS <= (to_integer(unsigned(i_row_count))-g_ACTIVE_ROWS)*tan(sec mod 30)/1000 + 1 
                                        and to_integer(unsigned(i_col_count))- g_ACTIVE_COLS >= (to_integer(unsigned(i_row_count))-g_ACTIVE_ROWS)*tan(sec mod 30)/1000 - 1)
                                        
                                        or ( (sec /= 45 and sec > 30) and to_integer(unsigned(i_col_count)) <= g_ACTIVE_COLS and ( ( to_integer(unsigned(i_col_count))-g_ACTIVE_COLS <= (to_integer(unsigned(i_row_count))-g_ACTIVE_ROWS+1)*tan(sec mod 30)/1000 
                                        and to_integer(unsigned(i_col_count))- g_ACTIVE_COLS >= (to_integer(unsigned(i_row_count))-g_ACTIVE_ROWS-1)*tan(sec mod 30)/1000) or (to_integer(unsigned(i_col_count))-g_ACTIVE_COLS <= (to_integer(unsigned(i_row_count))-g_ACTIVE_ROWS-1)*tan(sec mod 30)/1000 
                                        and to_integer(unsigned(i_col_count))- g_ACTIVE_COLS >= (to_integer(unsigned(i_row_count))-g_ACTIVE_ROWS+1)*tan(sec mod 30)/1000) ) )
                                        --left/right sh
                                        or ( to_integer(unsigned(i_row_count)) <= g_ACTIVE_ROWS and sec = 0 and to_integer(unsigned(i_col_count)) = g_ACTIVE_COLS)
                                        or ( to_integer(unsigned(i_row_count)) = g_ACTIVE_ROWS and sec = 15 and to_integer(unsigned(i_col_count)) >= g_ACTIVE_COLS)
                                        or ( to_integer(unsigned(i_row_count)) >= g_ACTIVE_ROWS and sec = 30 and to_integer(unsigned(i_col_count)) = g_ACTIVE_COLS)
                                        or ( to_integer(unsigned(i_row_count)) = g_ACTIVE_ROWS and sec = 45 and to_integer(unsigned(i_col_count)) <= g_ACTIVE_COLS)
                                         ) )
                     else '0';

end Behavioral;
