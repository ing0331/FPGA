 library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Bram_dout is
   Port ( 
       i_clk : IN STD_LOGIC;
	   i_SW		: IN STD_LOGIC;
       i_Col_Count : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
       i_Row_Count : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
       
       o_img : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) );
end Bram_dout;

architecture RTL of Bram_dout is
	constant line_width : integer := 5;    --draw net

   constant ball_x : integer := 0;
   constant ball_y : integer := 0;
   constant ball_leng : integer := 640;
   constant ball_width : integer := 480;
   
   signal img_road : std_logic_vector(7 downto 0);
   signal img_rect : std_logic_vector(7 downto 0);
   
   signal w_ena : std_logic;
   signal r_addr : std_logic_vector(19 DOWNTO 0);
   signal increase_cost : unsigned(7 downto 0) := "00000000";

--   component blk_road is
--    PORT (
--     clka : IN STD_LOGIC;
--     ena : IN STD_LOGIC;
--     wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--     addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
--     dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--     douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
--    );
-- END component blk_road;

   component blk_mem_road is       --gray
 PORT (
  clka : IN STD_LOGIC;
  ena : IN STD_LOGIC;
  wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
  addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
  dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
 );
END component blk_mem_road;

begin

   RamEN : process(i_clk)
   begin
       if rising_edge(i_clk) then
           if (i_Col_Count >= ball_x and i_Col_Count <= ball_x+ball_leng) and (i_Row_Count >= ball_y and i_Row_Count < ball_y+ball_width) then
               w_ena <= '1';
           else
               w_ena <= '0';
           end if;
       end if;
     end process RamEN; 
     
r_addr_sync : process (i_clk) is
 begin
   if rising_edge(i_clk) then  --640  "1010000000"
     r_addr <= i_Row_Count(9 downto 0)*std_logic_vector(to_unsigned(640, 10)) + i_Col_Count;
   end if;
 end process r_addr_sync;
               
   draw_rectangle: process(i_clk, i_Col_Count, i_Row_Count)
       variable RGB_en : std_logic;
   begin
--     if i_Col_Count(3) = '1' and i_Row_Count(3) = '1' then   --even
--         RGB_en := '1';
--     else
--         RGB_en := '0';       
--     end if;
--     if RGB_en = '1' then
        if i_Col_Count >= 200 and i_Col_Count <= 400 and i_Row_Count >= 200 and i_Row_Count <= 400 then
         img_rect <= (others => '1');
         else    
             img_rect <= (others => '0');
         end if;
--      end if;
  end process;
               
--  draw_rectangle: process(i_clk, i_Col_Count, i_Row_Count)
--      variable x_cnt_en, y_cnt_en : std_logic;
----	  variable increase_cost : unsigned(7 downto 0) := "00000000";
--	  variable focus : integer := 320;
--  begin
--	if rising_edge(i_clk) then
--		increase_cost <= increase_cost(6 downto 0) & '1';
--		if increase_cost = "11111111" then
--			increase_cost <= (others => '0');
--			focus := 320;
--		end if;
--		focus := focus - TO_INTEGER(increase_cost);
		
--		if i_Col_Count >= focus - to_integer(increase_cost) or i_Col_Count >= 640-(focus - to_integer(increase_cost)) - line_width then
--			x_cnt_en := '1';
--		else
--			x_cnt_en := '0';
--		end if;
		
--		if i_Row_Count >= (focus - to_integer(increase_cost))*2/3 -line_width or i_Row_Count < (focus - to_integer(increase_cost))*2/3 +line_width then
--			y_cnt_en := '1';
--		elsif i_Row_Count >= 480- ((focus - to_integer(increase_cost))*2/3 -line_width) or i_Row_Count < 480 -((focus - to_integer(increase_cost))*2/3 +line_width) then
--			y_cnt_en := '1';
--		else
--			y_cnt_en := '0';
--		end if;
--	end if;
	
--    if y_cnt_en = '1' and x_cnt_en = '1' then
--        img_rect <= (others => '1');    
		
--    elsif i_Col_Count >= to_integer(unsigned(i_Row_Count))*3/2 -line_width and  i_Col_Count <= to_integer(unsigned(i_Row_Count))*3/2 +line_width then  				--drawline
--		img_rect <= (others => '1');
--	elsif i_Col_Count + to_integer(unsigned(i_Row_Count))*3/2 >= 640 -line_width and  i_Col_Count + to_integer(unsigned(i_Row_Count))*3/2 <= 640+line_width then  			--drawline
--		img_rect <= (others => '1');
    
--	else    
--        img_rect <= (others => '0');
--    end if;

-- end process;   
			   
road: blk_mem_road      --gray
   PORT MAP(
     clka  => i_Clk,
     ena   => w_ena,
     wea   => (others => '0'),
     addra => r_addr(18 DOWNTO 0),
     dina  => (others => 'Z'),
     douta => img_road
   );
   
   o_img <= img_road when i_SW = '1'
   else	img_rect;
    
end architecture RTL ;