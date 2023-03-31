library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

entity Test_Pattern_Gen is
  generic (
    g_VIDEO_WIDTH : integer := 3;
    g_TOTAL_COLS  : integer := 800;
    g_TOTAL_ROWS  : integer := 525;
    g_ACTIVE_COLS : integer := 640;
    g_ACTIVE_ROWS : integer := 480
    );
  port (
    i_Clk     : in std_logic;
    i_Pattern : in std_logic_vector(3 downto 0);
    i_HSync   : in std_logic;
    i_VSync   : in std_logic;
    ---
    o_HSync     : out std_logic := '0';
    o_VSync     : out std_logic := '0';
    o_Red_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
    o_Grn_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
    o_Blu_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0)
    );
end entity Test_Pattern_Gen;

architecture RTL of Test_Pattern_Gen is

  component Sync_To_Count is
    generic (
      g_TOTAL_COLS : integer;
      g_TOTAL_ROWS : integer
      );
    port (
      i_Clk   : in std_logic;
      i_HSync : in std_logic;
      i_VSync : in std_logic;
      o_HSync     : out std_logic;
      o_VSync     : out std_logic;
      o_Col_Count : out std_logic_vector(9 downto 0);
      o_Row_Count : out std_logic_vector(9 downto 0)
      );
  end component Sync_To_Count;

  signal w_VSync : std_logic;
  signal w_HSync : std_logic;
  
  -- Create a type that contains all Test Patterns.
  -- Patterns have 16 indexes (0 to 15) and can be g_VIDEO_WIDTH bits wide
  type t_Patterns is array (0 to 15) of std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
  signal Pattern_Red : t_Patterns;
  signal Pattern_Grn : t_Patterns;
  signal Pattern_Blu : t_Patterns;
  -- Make these unsigned counters (always positive)
  signal w_Col_Count : std_logic_vector(9 downto 0);
  signal w_Row_Count : std_logic_vector(9 downto 0);

  signal w_Bar_Width  : integer range 0 to g_ACTIVE_COLS/8;
  signal w_Bar_Select : integer range 0 to 7;  -- Color Bars
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

  signal sec : integer range 0 to 60;
  signal minite : integer range 0 to 60;
  signal hour : integer range 0 to 60;
--  signal row_draw_signed : signed range "00000000" to "11111111" ;   --y
begin

rolling_delta : process(i_Clk)
    variable cnt : integer := 0;
    begin    
        if(rising_edge(i_Clk)) then
            if(cnt < 25000000) then      --sec >= 2
                cnt := cnt + 1;     --­¡±a
            else                 --1 second past
                sec <= sec + 1;
                cnt := 0;
            end if; 
            if sec >= 60 then 
                sec <= 0;
                minite <= minite + 1;
			end if;
			if minite >= 60 then
				minite <= 0;
				hour <= hour + 1;
			end if;
			if hour >= 60 then
				hour <= 0;
			end if;
        end if;

    end process;
    
  Sync_To_Count_inst : Sync_To_Count
    generic map (   
      g_TOTAL_COLS => g_TOTAL_COLS,     
      g_TOTAL_ROWS => g_TOTAL_ROWS
      )
    port map (
      i_Clk       => i_Clk,
      i_HSync     => i_HSync,
      i_VSync     => i_VSync,
      o_HSync     => w_HSync,
      o_VSync     => w_VSync,
      o_Col_Count => w_Col_Count,
      o_Row_Count => w_Row_Count
      );
  
  -- Register syncs to align with output data.
  p_Reg_Syncs : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      o_VSync <= w_VSync;
      o_HSync <= w_HSync;
    end if;
  end process p_Reg_Syncs; 

  -----------------------------------------------------------------------------
  -- Pattern 0: Disables the Test Pattern Generator
  -----------------------------------------------------------------------------
  Pattern_Red(0) <= (others => '0');
  Pattern_Grn(0) <= (others => '0');
  Pattern_Blu(0) <= (others => '0');
  -----------------------------------------------------------------------------
  -- Pattern 1: All Red
  -----------------------------------------------------------------------------                                                                        --1000*rate    
  Pattern_Red(1) <= (others => '1') when (  ( (to_integer(unsigned(w_Col_Count))- 320)**2 + (to_integer(unsigned(w_Row_Count))- 240)**2 <= 10000 ) and ( ( (sec/= 0 and sec /= 15 and sec < 30) and to_integer(unsigned(w_Col_Count)) >= 320 and to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240)*tan(sec)/1000 + 1 
                                        and to_integer(unsigned(w_Col_Count))- 320 >= (to_integer(unsigned(w_Row_Count))-240)*tan(sec)/1000 - 1 )
                                       --up/down sh
                                        or ( (sec/= 0 and sec /= 15 and sec < 30) and ( ( to_integer(unsigned(w_Col_Count)) >= 320 and to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240+1)*tan(sec)/1000
                                        and to_integer(unsigned(w_Col_Count))- 320 >= (to_integer(unsigned(w_Row_Count))-240 - 1)*tan(sec)/1000 ) or ( to_integer(unsigned(w_Col_Count)) >= 320 and to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240-1)*tan(sec)/1000
                                        and to_integer(unsigned(w_Col_Count))- 320 >= (to_integer(unsigned(w_Row_Count))-240 + 1)*tan(sec)/1000 ) ) )
                                        
                                       
                                        or ( (sec /= 45 and sec > 30) and to_integer(unsigned(w_Col_Count)) <= 320 and to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240)*tan(sec mod 30)/1000 + 1 
                                        and to_integer(unsigned(w_Col_Count))- 320 >= (to_integer(unsigned(w_Row_Count))-240)*tan(sec mod 30)/1000 - 1)
                                        
                                        or ( (sec /= 45 and sec > 30) and to_integer(unsigned(w_Col_Count)) <= 320 and ( ( to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240+1)*tan(sec mod 30)/1000 
                                        and to_integer(unsigned(w_Col_Count))- 320 >= (to_integer(unsigned(w_Row_Count))-240-1)*tan(sec mod 30)/1000) or (to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240-1)*tan(sec mod 30)/1000 
                                        and to_integer(unsigned(w_Col_Count))- 320 >= (to_integer(unsigned(w_Row_Count))-240+1)*tan(sec mod 30)/1000) ) )
                                        --left/right sh
                                        or ( to_integer(unsigned(w_row_Count)) <= 240 and sec = 0 and to_integer(unsigned(w_Col_Count)) = 320)
                                        or ( to_integer(unsigned(w_row_Count)) = 240 and sec = 15 and to_integer(unsigned(w_Col_Count)) >= 320)
                                        or ( to_integer(unsigned(w_row_Count)) >= 240 and sec = 30 and to_integer(unsigned(w_Col_Count)) = 320)
                                        or ( to_integer(unsigned(w_row_Count)) = 240 and sec = 45 and to_integer(unsigned(w_Col_Count)) <= 320)
                                         ) )
                     else (others => '0');
  Pattern_Grn(1) <= (others => '1') when (  ( (to_integer(unsigned(w_Col_Count))- 320)**2 + (to_integer(unsigned(w_Row_Count))- 240)**2 <= 8100 ) and ( ( (minite/= 0 and minite /= 15 and minite < 30) and to_integer(unsigned(w_Col_Count)) >= 320 and to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240)*tan(minite)/1000 + 1 
                                 and to_integer(unsigned(w_Col_Count))- 320 >= (to_integer(unsigned(w_Row_Count))-240)*tan(minite)/1000 - 1 )
                                --up/down sh
                                 or ( (minite/= 0 and minite /= 15 and minite < 30) and ( ( to_integer(unsigned(w_Col_Count)) >= 320 and to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240+1)*tan(minite)/1000
                                 and to_integer(unsigned(w_Col_Count))- 320 >= (to_integer(unsigned(w_Row_Count))-240 - 1)*tan(minite)/1000 ) or ( to_integer(unsigned(w_Col_Count)) >= 320 and to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240-1)*tan(minite)/1000
                                 and to_integer(unsigned(w_Col_Count))- 320 >= (to_integer(unsigned(w_Row_Count))-240 + 1)*tan(minite)/1000 ) ) )
                                 
                                
                                 or ( (minite /= 45 and minite > 30) and to_integer(unsigned(w_Col_Count)) <= 320 and to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240)*tan(minite mod 30)/1000 + 1 
                                 and to_integer(unsigned(w_Col_Count))- 320 >= (to_integer(unsigned(w_Row_Count))-240)*tan(minite mod 30)/1000 - 1)
                                 
                                 or ( (minite /= 45 and minite > 30) and to_integer(unsigned(w_Col_Count)) <= 320 and ( ( to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240+1)*tan(minite mod 30)/1000 
                                 and to_integer(unsigned(w_Col_Count))- 320 >= (to_integer(unsigned(w_Row_Count))-240-1)*tan(minite mod 30)/1000) or (to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240-1)*tan(minite mod 30)/1000 
                                 and to_integer(unsigned(w_Col_Count))- 320 >= (to_integer(unsigned(w_Row_Count))-240+1)*tan(minite mod 30)/1000) ) )
                                 --left/right sh
                                 or ( to_integer(unsigned(w_row_Count)) <= 240 and minite = 0 and to_integer(unsigned(w_Col_Count)) = 320)
                                 or ( to_integer(unsigned(w_row_Count)) = 240 and minite = 15 and to_integer(unsigned(w_Col_Count)) >= 320)
                                 or ( to_integer(unsigned(w_row_Count)) >= 240 and minite = 30 and to_integer(unsigned(w_Col_Count)) = 320)
                                 or ( to_integer(unsigned(w_row_Count)) = 240 and minite = 45 and to_integer(unsigned(w_Col_Count)) <= 320)
                                 )  )
                                 else (others => '0');
  Pattern_Blu(1) <= (others => '1') when ( (to_integer(unsigned(w_Col_Count))- 320)**2 + (to_integer(unsigned(w_Row_Count))- 240)**2 <= 115**2 and ( (to_integer(unsigned(w_Col_Count))- 320)**2 + (to_integer(unsigned(w_Row_Count))- 240)**2 >= 110**2) )
  or ( (  ( (to_integer(unsigned(w_Col_Count))- 320)**2 + (to_integer(unsigned(w_Row_Count))- 240)**2 <= 8100 ) and ( ( (hour/= 0 and hour /= 15 and hour < 30) and to_integer(unsigned(w_Col_Count)) >= 320 and to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240)*tan(hour)/1000 + 1 
                                   and to_integer(unsigned(w_Col_Count))- 320 >= (to_integer(unsigned(w_Row_Count))-240)*tan(hour)/1000 - 1 )
                                  --up/down sh
                                   or ( (hour/= 0 and hour /= 15 and hour < 30) and ( ( to_integer(unsigned(w_Col_Count)) >= 320 and to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240+1)*tan(hour)/1000
                                   and to_integer(unsigned(w_Col_Count))- 320 >= (to_integer(unsigned(w_Row_Count))-240 - 1)*tan(hour)/1000 ) or ( to_integer(unsigned(w_Col_Count)) >= 320 and to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240-1)*tan(hour)/1000
                                   and to_integer(unsigned(w_Col_Count))- 320 >= (to_integer(unsigned(w_Row_Count))-240 + 1)*tan(hour)/1000 ) ) )
                                   
                                  
                                   or ( (hour /= 45 and hour > 30) and to_integer(unsigned(w_Col_Count)) <= 320 and to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240)*tan(hour mod 30)/1000 + 1 
                                   and to_integer(unsigned(w_Col_Count))- 320 >= (to_integer(unsigned(w_Row_Count))-240)*tan(hour mod 30)/1000 - 1)
                                   
                                   or ( (hour /= 45 and hour > 30) and to_integer(unsigned(w_Col_Count)) <= 320 and ( ( to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240+1)*tan(hour mod 30)/1000 
                                   and to_integer(unsigned(w_Col_Count))- 320 >= (to_integer(unsigned(w_Row_Count))-240-1)*tan(hour mod 30)/1000) or (to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240-1)*tan(hour mod 30)/1000 
                                   and to_integer(unsigned(w_Col_Count))- 320 >= (to_integer(unsigned(w_Row_Count))-240+1)*tan(hour mod 30)/1000) ) )
                                   --left/right sh
                                   or ( to_integer(unsigned(w_row_Count)) <= 240 and hour = 0 and to_integer(unsigned(w_Col_Count)) = 320)
                                   or ( to_integer(unsigned(w_row_Count)) = 240 and hour = 15 and to_integer(unsigned(w_Col_Count)) >= 320)
                                   or ( to_integer(unsigned(w_row_Count)) >= 240 and hour = 30 and to_integer(unsigned(w_Col_Count)) = 320)
                                   or ( to_integer(unsigned(w_row_Count)) = 240 and hour = 45 and to_integer(unsigned(w_Col_Count)) <= 320)
                                   )  ) )
  else (others => '0');

  -----------------------------------------------------------------------------
  -- Pattern 2: All Green
  -----------------------------------------------------------------------------
  Pattern_Red(2) <= (others => '0');                                    --left sh
  Pattern_Grn(2) <= (others => '1') when ( 
                                         ( (to_integer(unsigned(w_Col_Count)))-320 >= (to_integer(unsigned(w_Row_Count))-240)*integer(tan(1))/1000 -1 and 
                                          (to_integer(unsigned(w_Col_Count)))-320 <= (to_integer(unsigned(w_Row_Count))-240)*integer(tan(1))/1000 +1)   --right sh
                                                                       --up sh 
                                        or ( ( (to_integer(unsigned(w_Col_Count)))-320 >= (to_integer(unsigned(w_Row_Count))-240 +1)*integer(tan(1))/1000 and 
                                          (to_integer(unsigned(w_Col_Count)))-320 <= (to_integer(unsigned(w_Row_Count))-240 -1)*integer(tan(1))/1000 ) ) 
                                           )
                                    else (others => '0');
  Pattern_Blu(2) <= (others => '0');
  -----------------------------------------------------------------------------
  -- Pattern 3: All Blue
  -----------------------------------------------------------------------------
  Pattern_Red(3) <= (others => '0');
  Pattern_Grn(3) <= (others => '0');
  Pattern_Blu(3) <= (others => '1') when (to_integer(unsigned(w_Col_Count)) < g_ACTIVE_COLS and 
                                          to_integer(unsigned(w_Row_Count)) < g_ACTIVE_ROWS) else
                    (others => '0');
  -----------------------------------------------------------------------------
  -- Pattern 4: Checkerboard white/black
  -----------------------------------------------------------------------------
  Pattern_Red(4) <= (others => '1') when (w_Col_Count(5) = '0' xor
                                          w_Row_Count(5) = '1') else
                    (others => '0');
  Pattern_Grn(4) <= Pattern_Red(4);
  Pattern_Blu(4) <= Pattern_Red(4);
  -----------------------------------------------------------------------------
  -- Pattern 5: Color Bars
  -- Divides active area into 8 Equal Bars and colors them accordingly
  -- Colors Each According to this Truth Table:
  -- R G B  w_Bar_Select  Ouput Color
  -- 0 0 0       0        Black
  -- 0 0 1       1        Blue
  -- 0 1 0       2        Green
  -- 0 1 1       3        Turquoise
  -- 1 0 0       4        Red
  -- 1 0 1       5        Purple
  -- 1 1 0       6        Yellow
  -- 1 1 1       7        White
  -----------------------------------------------------------------------------
  w_Bar_Width <= g_ACTIVE_COLS/8;  
  w_Bar_Select <= 0 when unsigned(w_Col_Count) < w_Bar_Width*1 else
                  1 when unsigned(w_Col_Count) < w_Bar_Width*2 else
                  2 when unsigned(w_Col_Count) < w_Bar_Width*3 else
                  3 when unsigned(w_Col_Count) < w_Bar_Width*4 else
                  4 when unsigned(w_Col_Count) < w_Bar_Width*5 else
                  5 when unsigned(w_Col_Count) < w_Bar_Width*6 else
                  6 when unsigned(w_Col_Count) < w_Bar_Width*7 else
                  7;

  -- Implement Truth Table above with Conditional Assignments
  Pattern_Red(5) <= (others => '1') when (w_Bar_Select = 4 or w_Bar_Select = 5 or
                                          w_Bar_Select = 6 or w_Bar_Select = 7) else
                    (others => '0');

  Pattern_Grn(5) <= (others => '1') when (w_Bar_Select = 2 or w_Bar_Select = 3 or
                                          w_Bar_Select = 6 or w_Bar_Select = 7) else
                    (others => '0');

  Pattern_Blu(5) <= (others => '1') when (w_Bar_Select = 1 or w_Bar_Select = 3 or
                                          w_Bar_Select = 5 or w_Bar_Select = 7) else
                    (others => '0');
  -----------------------------------------------------------------------------
  -- Pattern 6: Ball With White Border
  -----------------------------------------------------------------------------
-- 	  	  Pattern_Red(6) <= (others => '1') when ( (sec /= 15 and sec < 30) and ( ( to_integer(unsigned(w_Col_Count)) >= 320 and to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240)*tan(sec)/1000 + 1     and to_integer(unsigned(w_Col_Count))-320 >= (to_integer(unsigned(w_Row_Count))-240)*tan(sec)/1000 - 1) or ( (to_integer(unsigned(w_Col_Count)))-320 >= (to_integer(unsigned(w_Row_Count))-240 +1)*integer(tan(sec))/1000 and 
--                                      (to_integer(unsigned(w_Col_Count)))-320 <= (to_integer(unsigned(w_Row_Count))-240 -1)*integer(tan(sec))/1000 ) )                                 
                                   
--           or ( (sec /= 45 and sec >= 30) and ( (to_integer(unsigned(w_Col_Count)) <= 320 and to_integer(unsigned(w_Col_Count))-320 <= (to_integer(unsigned(w_Row_Count))-240)*tan(sec mod 30)/1000 + 1 )
--                                    and to_integer(unsigned(w_Col_Count))- 320 >= (to_integer(unsigned(w_Row_Count))-240)*tan(sec mod 30)/1000 - 1) or ( (to_integer(unsigned(w_Col_Count)))-320 >= (to_integer(unsigned(w_Row_Count))-240 +1)*integer(tan(sec mod 30))/1000 and 
--                                      (to_integer(unsigned(w_Col_Count)))-320 <= (to_integer(unsigned(w_Row_Count))-240 -1)*integer(tan(sec mod 30))/1000 ) ) )
                                    
--                                    or ( (sec = 15 or sec = 45) and to_integer(unsigned(w_row_Count)) = 240 ) )
--                 else (others => '0');

--                    --line( y(x)        10+8bits        +9.000
--row_draw_signed <= (signed(w_col_Count))*"01001000";
----y                                                                       --x count
--    ((signed(w_Row_Count)&"000") < row_draw_signed + "00000"&to_signed(241, 10)&"000" and (signed(w_Row_Count)&"000") < row_draw_signed + "00000"&to_signed(239, 10)&"000" and (sec < 15 or (sec < 45 and sec > 30) ) )   --right shift ini
--   or ((signed(w_Row_Count)&"000") < row_draw_signed + "10000"&to_signed(241, 10)&"000" and (signed(w_Row_Count)&"000") < row_draw_signed + "10000"&to_signed(239, 10)&"000" and (sec > 45  or (sec < 30 and sec > 15) ) )
                                   
  Pattern_Grn(6) <= Pattern_Red(6);
  Pattern_Blu(6) <= Pattern_Red(6);
  -----------------------------------------------------------------------------
  -- Select between different test patterns
  -----------------------------------------------------------------------------
  p_TP_Select : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      case i_Pattern is
        when "0000" =>
          o_Red_Video <= Pattern_Red(0);
          o_Grn_Video <= Pattern_Grn(0);
          o_Blu_Video <= Pattern_Blu(0);
        when "0001" =>
          o_Red_Video <= Pattern_Red(1);
          o_Grn_Video <= Pattern_Grn(1);
          o_Blu_Video <= Pattern_Blu(1);
        when "0010" =>
          o_Red_Video <= Pattern_Red(2);
          o_Grn_Video <= Pattern_Grn(2);
          o_Blu_Video <= Pattern_Blu(2);
        when "0011" =>
          o_Red_Video <= Pattern_Red(3);
          o_Grn_Video <= Pattern_Grn(3);
          o_Blu_Video <= Pattern_Blu(3);
        when "0100" =>
          o_Red_Video <= Pattern_Red(4);
          o_Grn_Video <= Pattern_Grn(4);
          o_Blu_Video <= Pattern_Blu(4);
        when "0101" =>
          o_Red_Video <= Pattern_Red(5);
          o_Grn_Video <= Pattern_Grn(5);
          o_Blu_Video <= Pattern_Blu(5);
        when "0110" =>
          o_Red_Video <= Pattern_Red(6);
          o_Grn_Video <= Pattern_Grn(6);
          o_Blu_Video <= Pattern_Blu(6);   
        when others =>              --default
          o_Red_Video <= Pattern_Red(0);
          o_Grn_Video <= Pattern_Grn(0);
          o_Blu_Video <= Pattern_Blu(0);
      end case;
    end if;
  end process p_TP_Select;

end architecture RTL;
