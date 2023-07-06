library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity addr_controller is
    Port (
        clk             : in std_logic;
        reset           : in std_logic;      
        vga_vs_cnt      : in std_logic_vector(9 downto 0);
        vga_hs_cnt      : in std_logic_vector(9 downto 0);  
        en              : out std_logic;
        addra           : out std_logic_vector (18 downto 0));
end addr_controller;

architecture Behavioral of addr_controller is
constant center_x   : integer := 320;
constant center_y   : integer := 240;
constant img_width  :  integer := 640;
constant img_height :  integer := 480;
signal cnt_addr : std_logic_vector (19 downto 0) := (others => '0');
signal ena : std_logic;

begin
r_addr_sync : process (reset, clk) is
 begin
   if reset = '0' then
        cnt_addr <= (others => '0'); 
   elsif rising_edge(clk) then  --640  "1010000000"
     cnt_addr <= vga_vs_cnt(9 downto 0)*std_logic_vector(to_unsigned(640, 10)) + vga_hs_cnt;
   end if;
 end process;
 addra <= cnt_addr(18 downto 0);
-- process(clk,reset,cnt_addr,ena )
-- begin
--    if (reset = '0') then
--        cnt_addr <= (others => '0');
--    elsif rising_edge(clk) and ena = '1' then    
--        if (vga_vs_cnt = 0) and (vga_hs_cnt = 0) then
--            cnt_addr <= (others => '0');
--        elsif (vga_vs_cnt < 480) and (vga_hs_cnt < 640) then
--            cnt_addr <= cnt_addr + '1';  
--        elsif vga_vs_cnt >= 480 -1 then
--            cnt_addr <= (others => '0');
----        elsif vga_hs_cnt > 640 -1 then
----            cnt_addr <= cnt_addr;    
--        else
--            cnt_addr <= cnt_addr;    
            
--        end if;
----        if cnt_addr < img_height*img_width-1 then 
----            cnt_addr <= cnt_addr + '1';  
----        else
----            cnt_addr <= (others => '0');                       
----        end if;
--     end if; 
-- end process;
--  process( reset , clk ,vga_vs_cnt,vga_hs_cnt)
-- begin
--    if reset = '0' then
--        ena <= '0';
--    elsif rising_edge(clk)then
--        if cnt_addr < img_height*img_width-1 then
--            ena <= '1';
--        else 
--            ena <= '0';
--        end if;
--    end if;
--end process;
        
 process( reset , clk ,vga_vs_cnt,vga_hs_cnt)
 begin
    if reset = '0' then
        ena <= '0';
    elsif rising_edge(clk)then
         if ( to_integer(unsigned(vga_vs_cnt)) >= (center_y-(img_height/2))) and (to_integer(unsigned(vga_vs_cnt)) < (center_y+(img_height/2))) and
            (to_integer(unsigned(vga_hs_cnt)) >= (center_x-(img_width/2))) and (to_integer(unsigned(vga_hs_cnt)) <(center_x+(img_width/2))) then 
            ena <= '1';
         else
            ena <= '0';
         end if;
     end if;
 end process;
 en <= ena;
 
end Behavioral;
