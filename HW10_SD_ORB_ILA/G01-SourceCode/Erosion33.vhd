library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Erosion33 is

   port(
   		clk_video  : IN  std_logic;
        rst_system : IN  std_logic;
--**
        data_video: in std_logic_vector ((8-1) downto 0);
--**        
        image_data_enable : in  std_logic;
        cnt_h_sync_vga :in integer range 0 to 857;
        cnt_v_sync_vga :in integer range 0 to 524;
        buf_vga_Y_out_cnt :in integer range 0 to 639;
        
        Erosion_data_out_vga :out std_logic

        );
		  
		  
end Erosion33;
 
architecture Behavioral of Erosion33 is


type Array_Erosion_buf is array (integer range 0 to 639) of std_logic_vector ((8-1) downto 0);
signal Erosion_buf_0 : Array_Erosion_buf;
signal Erosion_buf_0_data_1 : std_logic_vector((10-1) downto 0):="0000000000";
signal Erosion_buf_0_data_2 : std_logic_vector((10-1) downto 0):="0000000000";
signal Erosion_buf_0_data_3 : std_logic_vector((10-1) downto 0):="0000000000";


signal Erosion_buf_1 : Array_Erosion_buf;
signal Erosion_buf_1_data_1 : std_logic_vector((10-1) downto 0):="0000000000";
signal Erosion_buf_1_data_2 : std_logic_vector((10-1) downto 0):="0000000000";
signal Erosion_buf_1_data_3 : std_logic_vector((10-1) downto 0):="0000000000";


signal Erosion_buf_2 : Array_Erosion_buf;
signal Erosion_buf_2_data_1 : std_logic_vector((10-1) downto 0):="0000000000";
signal Erosion_buf_2_data_2 : std_logic_vector((10-1) downto 0):="0000000000";
signal Erosion_buf_2_data_3 : std_logic_vector((10-1) downto 0):="0000000000";

signal Erosion_buf_in_data : std_logic_vector((8-1) downto 0):="00000000";
signal Erosion_buf_cnt : integer range 0 to 639:=0;
signal Erosion_buf_cnt_max : integer range 0 to 639:=639; --0~639

signal Erosion_SUN : std_logic_vector((10-1) downto 0):="0000000000";

--signal Erosion_data_out_vga : std_logic:='0';
----------|
--Erosion End--|
----------|

begin






--Erosion-----------------------------------------------
process(rst_system, clk_video)
begin
if rst_system = '0' then
-------------------- Return to begin--------------------
	Erosion_buf_0_data_1 <= "0000000000";
	Erosion_buf_0_data_2 <= "0000000000";
	Erosion_buf_0_data_3 <= "0000000000";
		
	Erosion_buf_1_data_1 <= "0000000000";
	Erosion_buf_1_data_2 <= "0000000000";
	Erosion_buf_1_data_3 <= "0000000000";
	
	Erosion_buf_2_data_1 <= "0000000000";
	Erosion_buf_2_data_2 <= "0000000000";
	Erosion_buf_2_data_3 <= "0000000000";
	
-------------------- Return to begin--------------------	
	Erosion_SUN <= "0000000000";
	
	Erosion_data_out_vga <= '0';
-------------------- Return to begin--------------------	

elsif rising_edge(clk_video) then
		if ( cnt_h_sync_vga >= 0 and cnt_h_sync_vga < 640 and cnt_v_sync_vga >= 0 and cnt_v_sync_vga < 480) then
-- 01 02 03
-- 11 12 13
-- 21 22 (23)   >>(now_data)		 		    				    
					
--------------------GET IN data------------------	
						
						Erosion_buf_0_data_3 <= "00" & Erosion_buf_1(buf_vga_Y_out_cnt);
						Erosion_buf_0_data_2 <= Erosion_buf_0_data_3;
						Erosion_buf_0_data_1 <= Erosion_buf_0_data_2;

						Erosion_buf_1_data_3 <= "00" & Erosion_buf_2(buf_vga_Y_out_cnt);
						Erosion_buf_1_data_2 <= Erosion_buf_1_data_3;
					    Erosion_buf_1_data_1 <= Erosion_buf_1_data_2;

					    -----------****--data in--****---------------------------- 
					    Erosion_buf_2_data_3 <= "00" & "0000000"&data_video(0);
					    -----------****--data in--****----------------------------
					    Erosion_buf_2_data_2 <= "00" &Erosion_buf_2(buf_vga_Y_out_cnt + 1);
					    Erosion_buf_2_data_1 <= "00" &Erosion_buf_2(buf_vga_Y_out_cnt + 2);

	
						Erosion_buf_0(buf_vga_Y_out_cnt) <= Erosion_buf_1(buf_vga_Y_out_cnt);
						Erosion_buf_1(buf_vga_Y_out_cnt) <= Erosion_buf_2(buf_vga_Y_out_cnt);
						-----------****--data in--****----------------------------
						Erosion_buf_2(buf_vga_Y_out_cnt) <= "0000000"&data_video(0);
						-----------****--data in--****----------------------------
						
--------------------GET IN data------------------	
---------------------- Operation Point Weights--------------------
Erosion_SUN <=      Erosion_buf_0_data_1 + Erosion_buf_0_data_2 + Erosion_buf_0_data_3+
					Erosion_buf_1_data_1 + Erosion_buf_1_data_2 + Erosion_buf_1_data_3+
					Erosion_buf_2_data_1 + Erosion_buf_2_data_2 + Erosion_buf_2_data_3;
				
---------------------- Operation Point Weights--------------------

--------------------critical result------------------					    				    
					if Erosion_SUN > "0000001000"  then
						Erosion_data_out_vga <= '1';
					else
						Erosion_data_out_vga <= '0';
					end if;		    				
--------------------critical result------------------
		elsif image_data_enable = '0' then --range outside
-------------------- Return to begin--------------------		
	Erosion_buf_0_data_1 <= "0000000000";
	Erosion_buf_0_data_2 <= "0000000000";
	Erosion_buf_0_data_3 <= "0000000000";
		
	Erosion_buf_1_data_1 <= "0000000000";
	Erosion_buf_1_data_2 <= "0000000000";
	Erosion_buf_1_data_3 <= "0000000000";
	
	Erosion_buf_2_data_1 <= "0000000000";
	Erosion_buf_2_data_2 <= "0000000000";
	Erosion_buf_2_data_3 <= "0000000000";			
-------------------- Return to begin--------------------
	Erosion_SUN <= "0000000000";
	
	Erosion_data_out_vga <= '0';		
-------------------- Return to begin--------------------
		end if;
end if;
end process;
--Erosion-----------------------------------------------


end architecture;