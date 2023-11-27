----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/11/27 09:55:12
-- Design Name: 
-- Module Name: arctan - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

USE IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cordic is
    Generic(iteration_time : integer:=7;
            mode : integer:=0);-- mode0 : Combinatorial logic  mode1 : pipline 
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        x_in : in STD_LOGIC_VECTOR(14 downto 0);
        y_in : in STD_LOGIC_VECTOR(14 downto 0);
        x_out : out STD_LOGIC_VECTOR(17 downto 0);--square-root (x^2+y^2)^0.5 
        y_out : out STD_LOGIC_VECTOR(17 downto 0);
        z_out : out STD_LOGIC_VECTOR(7 downto 0)  --arctan  angle range : 90~0
--        enable : out STD_LOGIC
     );
end cordic;

architecture Behavioral of cordic is



type ANGLE is ARRAY(NATURAL range <>) of INTEGER;
constant tan_array : ANGLE(0 to 14):=(11520,6801,3593,1824,916,458,229,115,57,29,14,7,4,2,1);



type SIGNED_ARRAY is ARRAY(NATURAL range <>) of SIGNED(17 downto 0);
signal z_array : ANGLE(0 to iteration_time-1):= (others=>0); 
signal x_array : SIGNED_ARRAY(0 to iteration_time-1):= (others=>(others=>'0'));
signal y_array : SIGNED_ARRAY(0 to iteration_time-1):= (others=>(others=>'0'));
                                             
begin
process(clk,rst)

variable z_array_v : ANGLE(0 to iteration_time-1):= (others=>0); 
variable x_array_v : SIGNED_ARRAY(0 to iteration_time-1):= (others=>(others=>'0'));
variable y_array_v : SIGNED_ARRAY(0 to iteration_time-1):= (others=>(others=>'0'));  

variable x_out_tran :SIGNED(17 downto 0);
begin
    if mode = 0 then
        if rst = '0' then
            x_array_v := (others=>(others=>'0'));
            y_array_v := (others=>(others=>'0'));
            z_array_v := (others=>0);
        elsif rising_edge(clk) then		  

            for i in 0 to iteration_time-1 loop
				if i=0 then
						x_array_v(0) := resize('0'& signed(x_in),18) + resize(signed('0'& y_in),18);
						y_array_v(0) := resize('0'& signed(y_in),18) - resize(signed('0'& x_in),18);
						z_array_v(0) := tan_array(0);				
				else
					if y_array_v(i-1) >= "0" then
						x_array_v(i) := x_array_v(i-1) + resize( y_array_v(i-1)(17 downto i),18);
						y_array_v(i) := y_array_v(i-1) - resize( x_array_v(i-1)(17 downto i),18);
						z_array_v(i) := z_array_v(i-1) + tan_array(i);
					else
						x_array_v(i) := x_array_v(i-1) - resize( y_array_v(i-1)(17 downto i),18);
						y_array_v(i) := y_array_v(i-1) + resize( x_array_v(i-1)(17 downto i),18);
						z_array_v(i) := z_array_v(i-1) - tan_array(i);
					end if;
				end if;	
            end loop; 
				
				
			--  x * 0.607252938003573  ||   0.607252938003573  2¶i¨î=  1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 
			x_out_tran :=   resize(x_array_v(iteration_time-1)(17 downto  1),18)
			--            +   resize(x_array_v(iteration_time-1)(17 downto  2),18) 
			--            +   resize(x_array_v(iteration_time-1)(17 downto  3),18)
							+   resize(x_array_v(iteration_time-1)(17 downto  4),18) 
							+   resize(x_array_v(iteration_time-1)(17 downto  5),18)
			--            +   resize(x_array_v(iteration_time-1)(17 downto  6),18)
							+   resize(x_array_v(iteration_time-1)(17 downto  7),18) 
							+   resize(x_array_v(iteration_time-1)(17 downto  8),18) 
			--            +   resize(x_array_v(iteration_time-1)(17 downto  9),18)
							+   resize(x_array_v(iteration_time-1)(17 downto 10),18) ;				
								
			x_out<=std_logic_vector(x_out_tran);
				
			y_out <= std_logic_vector(y_array_v(iteration_time-1)(17 downto 0));

			
			if z_array_v(iteration_time-1) < 0 then
				z_out<=(others=>'0');	
			else
				z_out <= std_logic_vector(to_signed(z_array_v(iteration_time-1),16)(15 downto 8)); 
			end if;
            			
				
        end if;
    else
        -- if rst = '0' then
            -- x_array <= (others=>(others=>'0'));
            -- y_array <= (others=>(others=>'0'));
            -- z_array <= (others=>0);
        -- elsif rising_edge(clk) then
            -- x_array(x_array'low) <= signed(x_in) + signed('0' & y_in);
            -- y_array(y_array'low) <= signed(y_in) - signed('0' & x_in);
            -- z_array(z_array'low) <= tan_array(0);
            -- for i in 1 to iteration_time-1 loop
                -- if y_array(i-1) > to_signed(0,14) then
                    -- x_array(i) <= x_array(i-1) + (y_array(i-1)(15 downto i));
                    -- y_array(i) <= y_array(i-1) - (x_array(i-1)(15 downto i));
                    -- z_array(i) <= z_array(i-1) + tan_array(i);
                -- else
                    -- x_array(i) <= x_array(i-1) - (y_array(i-1)(15 downto i));
                    -- y_array(i) <= y_array(i-1) + (x_array(i-1)(15 downto i));
                    -- z_array(i) <= z_array(i-1) - tan_array(i);
                -- end if;
            -- end loop; 
			-- x_out_tran := "0" & (x_array(iteration_time-1)(14 downto 1) + x_array(iteration_time-1)(14 downto 4) + 
                      -- x_array(iteration_time-1)(14 downto 5) + x_array(iteration_time-1)(14 downto 6));
			-- x_out <= std_logic_vector(x_out_tran(14 downto 0));
            -- y_out <= std_logic_vector(y_array(iteration_time-1)(14 downto 0));
            -- z_out <= std_logic_vector(to_signed(z_array(iteration_time-1),16)(15 downto 8));       
        -- end if;    
    end if;
end process;
end Behavioral;
