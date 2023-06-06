library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.const_def.all;
entity addr_controller is
    Port (
        clk             : in std_logic;
        reset           : in std_logic;      
        vga_vs_cnt : in integer range 0 to vertical_resolution;
        vga_hs_cnt : in integer range 0 to horizontal_resolution;  
        en              : out std_logic;
        addra           : out std_logic_vector (18 downto 0));
end addr_controller;

architecture Behavioral of addr_controller is

signal cnt_addr : std_logic_vector (18 downto 0);
signal ena : std_logic;


begin
addra     <= cnt_addr;
 process(clk,reset,cnt_addr,ena )
 begin
    if (reset = '1') then
        cnt_addr <= (others => '0');
    elsif rising_edge(clk) and ena = '1' then                               
        if cnt_addr < (img_height*img_width)-1 then 
            cnt_addr <= cnt_addr + 1;  
        else
            cnt_addr <= (others => '0');                       
        end if;
     end if; 
 end process;
 
 process( reset , clk ,vga_vs_cnt,vga_hs_cnt)
 begin
    if reset = '1' then
        ena <= '0';
    elsif rising_edge(clk)then
         if (vga_vs_cnt >= (center_y-(img_height/2))) and (vga_vs_cnt < (center_y+(img_height/2))) and
            (vga_hs_cnt >= (center_x-(img_width/2))) and (vga_hs_cnt <(center_x+(img_width/2))) then 
            ena <= '1';
         else
            ena <= '0';
         end if;
     end if;
 end process;
 en <= ena;
end Behavioral;
