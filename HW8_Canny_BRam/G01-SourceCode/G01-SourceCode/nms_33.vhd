----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2022/11/29 19:00:54
-- Design Name: 
-- Module Name: NMS_33 - Behavioral
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
use IEEE.numeric_std.all;
use work.const_def.all;
use work.pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity NMS_33 is
    generic(
            ksize : integer := 3;
            angle_bits : integer := 9;
            gradient_bits : integer := 11
    );
    port (
            i_clk      :  in STD_LOGIC;
            i_rst      :  in STD_LOGIC;
            i_enable   :  in STD_LOGIC;        
            i_angle    :  in STD_LOGIC_VECTOR(8 downto 0);         
            i_gradient :  in STD_LOGIC_VECTOR(10 downto 0);
            o_gradient : out STD_LOGIC_VECTOR(10 downto 0);
            NMS_IMG        : out std_logic_vector(7 downto 0);
            NMS_BIN_IMG : out std_logic_vector(11 downto 0)
    );
end NMS_33;

architecture Behavioral of NMS_33 is

component matrix_nxn is
	generic(
		ksize  : integer;
		data_bits : integer 
	);
	port (
            i_clk    :    in STD_LOGIC;
            i_rst    :    in STD_LOGIC;
            i_enable :    in STD_LOGIC;
            i_data   :    in STD_LOGIC_VECTOR(data_bits-1 downto 0);
            o_data   : inout out_matrix
	);
end component;
type arr is array (0 to 2 , 0 to 2) of std_logic_vector(12 downto 0);
signal gradient_matrix_dithering : arr;
signal gradient_matrix_reg :out_matrix(0 to ksize-1 , 0 to ksize-1);
signal gradient_matrix:out_matrix(0 to ksize-1 , 0 to ksize-1);
signal angle_matrix:out_matrix(0 to ksize-1 , 0 to ksize-1);
signal bin_choose ,pipe_bin: integer range 0 to 4;
signal int_angle : integer range 0 to 360;
signal NMS_gradient : std_logic_vector(10 downto 0);
begin
matrix_G  : matrix_nxn
    generic map(
        data_bits =>  gradient_bits,
        ksize => ksize
    )
    port map(
        i_clk =>i_clk,
        i_rst =>i_rst,
        i_enable => i_enable,
        i_data =>  i_gradient,
        o_data  =>  gradient_matrix);
matrix_A :matrix_nxn  
    generic map(
        data_bits => angle_bits,
        ksize => ksize
    )
    port map(
        i_clk =>i_clk,
        i_rst =>i_rst,
        i_enable => i_enable,
        i_data =>  i_angle,
        o_data  =>  angle_matrix);        
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ stage 1
int_angle_process : process(i_rst,angle_matrix,i_clk)
begin
    if i_rst = '1' then
        int_angle <= 0;
    else
        if to_integer(unsigned(angle_matrix(1,1))) > 360 then
            int_angle <= to_integer(unsigned(angle_matrix(1,1))) - 360 ;
        elsif to_integer(unsigned(angle_matrix(1,1))) < 0 then
            int_angle <= -to_integer(unsigned(angle_matrix(1,1)));
        else
            int_angle <= to_integer(unsigned(angle_matrix(1,1)));
        end if;
    end if;
end process;
Angle_process : process(i_rst , i_clk ,i_enable)
begin
    if i_rst = '1' then
        bin_choose <= 1;
    elsif rising_edge(i_clk) then
        if i_enable = '1' then
            case int_angle is
                when   0 to  22 | 158 to 202 | 338 to 360 => bin_choose <= 1;
                when  23 to  67 | 203 to 247              => bin_choose <= 2;
                when  68 to 112 | 248 to 292              => bin_choose <= 3;
                when 113 to 157 | 293 to 337              => bin_choose <= 4;
                when others => bin_choose <= 0 ;
            end case;
        else
            bin_choose <= 0;
        end if;
    end if;
end process;
pipeline : process(i_rst , i_clk)
begin
    if i_rst = '1' then
        gradient_matrix_reg <= (others => (others => (others => '0')));
    elsif rising_edge(i_clk)then
        if i_enable = '1' then
            gradient_matrix_reg <= gradient_matrix;
        end if;
    end if;
end process;
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ stage 2
process(i_rst , i_clk)
begin
    if i_rst = '1' then
        NMS_BIN_IMG <= (others => '0');
    elsif rising_edge(i_clk)then
        if i_enable = '1' then
            case bin_choose is 
                when 1 => NMS_BIN_IMG <= "111100000000";                                 
                when 2 => NMS_BIN_IMG <= "000011110000";                                  
                when 3 => NMS_BIN_IMG <= "000000001111";                                   
                when 4 => NMS_BIN_IMG <= "111111110000";                                   
                when others =>NMS_BIN_IMG <= (others => '0'); 
            end case;
        else
            NMS_BIN_IMG <= (others => '0');
        end if;
    end if;
end process;
Gradient_process : process(i_rst ,i_clk ,bin_choose , gradient_matrix_reg)
begin
    if i_rst = '1' then
        o_gradient <= (others => '0');        
    elsif rising_edge(i_clk)  then
        if i_enable = '1' then        
            if to_integer(unsigned(gradient_matrix_reg(1,1))) = 0 then
                o_gradient <= (others=>'0');
            else
                case bin_choose is
                    when 1 =>
                        if  (to_integer(unsigned(gradient_matrix_reg(1,1))) >= to_integer(unsigned(gradient_matrix_reg(1,0)))) 
                        and (to_integer(unsigned(gradient_matrix_reg(1,1))) >= to_integer(unsigned(gradient_matrix_reg(1,2))))then
                            o_gradient <= gradient_matrix_reg(1,1);
                        else
                            o_gradient <= (others=>'0');
                        end if;
                    when 2 =>
                        if  (to_integer(unsigned(gradient_matrix_reg(1,1))) >= to_integer(unsigned(gradient_matrix_reg(0,2)))) 
                        and (to_integer(unsigned(gradient_matrix_reg(1,1))) >= to_integer(unsigned(gradient_matrix_reg(2,0))))then
                            o_gradient <= gradient_matrix_reg(1,1);
                        else
                            o_gradient <= (others=>'0');
                        end if;
                    when 3 =>
                        if  (to_integer(unsigned(gradient_matrix_reg(1,1))) >= to_integer(unsigned(gradient_matrix_reg(0,1)))) 
                        and (to_integer(unsigned(gradient_matrix_reg(1,1))) >= to_integer(unsigned(gradient_matrix_reg(2,1))))then
                            o_gradient <= gradient_matrix_reg(1,1);
                        else
                            o_gradient <= (others=>'0');
                        end if;
                    when 4 =>
                        if  (to_integer(unsigned(gradient_matrix_reg(1,1))) >= to_integer(unsigned(gradient_matrix_reg(0,0)))) 
                        and (to_integer(unsigned(gradient_matrix_reg(1,1))) >= to_integer(unsigned(gradient_matrix_reg(2,2))))then
                            o_gradient <= gradient_matrix_reg(1,1);
                        else
                            o_gradient <= (others=>'0');
                        end if;
                    when others => NULL;
                end case;
            end if;
        end if;
    end if;
end process;
process(i_rst , i_clk)
    variable g : std_logic_vector(7 downto 0);
begin
    if i_rst = '1' then
        NMS_IMG <= (others => '0');
    elsif rising_edge(i_clk)then
        if i_enable = '1' then
            if to_integer(unsigned(gradient_matrix_reg(1,1))) > 255 then
                            g := "11111111";
            else
                            g := gradient_matrix_reg(1,1)(7 downto 0);
            end if;
            case bin_choose is
                when 1 =>
                    if(to_integer(unsigned(gradient_matrix_reg(1,1)))  > to_integer(unsigned(gradient_matrix_reg(1,0)))) 
                    and (to_integer(unsigned(gradient_matrix_reg(1,1))) > to_integer(unsigned(gradient_matrix_reg(1,2))))then
                        NMS_IMG <= g;
                    else                    
                        NMS_IMG <= (others=>'0');
                    end if;
                when 2 =>
                    if(to_integer(unsigned(gradient_matrix_reg(1,1)))  > to_integer(unsigned(gradient_matrix_reg(0,2)))) 
                    and (to_integer(unsigned(gradient_matrix_reg(1,1))) > to_integer(unsigned(gradient_matrix_reg(2,0))))then                    
                        NMS_IMG <= g;
                    else
                        NMS_IMG <= (others=>'0');
                    end if;
                when 3 =>
                    if(to_integer(unsigned(gradient_matrix_reg(1,1)))  > to_integer(unsigned(gradient_matrix_reg(0,1)))) 
                    and (to_integer(unsigned(gradient_matrix_reg(1,1))) > to_integer(unsigned(gradient_matrix_reg(2,1))))then
                        NMS_IMG <= g;
                    else
                        NMS_IMG <= (others=>'0');
                    end if;
                when 4 =>
                    if(to_integer(unsigned(gradient_matrix_reg(1,1)))  > to_integer(unsigned(gradient_matrix_reg(0,0)))) 
                    and (to_integer(unsigned(gradient_matrix_reg(1,1))) > to_integer(unsigned(gradient_matrix_reg(2,2))))then
                        NMS_IMG <= g;
                    else
                        NMS_IMG <= (others=>'0');
                    end if;
                when others => NULL;
            end case;    
        end if;
    end if;
end process; 
end Behavioral;