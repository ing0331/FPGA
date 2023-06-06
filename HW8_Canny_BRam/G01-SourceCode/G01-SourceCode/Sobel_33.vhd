----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2022/11/28 13:20:52
-- Design Name: 
-- Module Name: Sobel_33 - Behavioral
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
use ieee.numeric_std.all;
use work.pkg.all;
use work.const_def.all;
entity sobel_33 is
    generic(
        iteration_time : integer;
        ksize : integer := 3;
        data_bits : integer := 8;
        adder_bits : integer := 14
    );
    Port (
        i_clk      :  in std_logic;
        i_rst      :  in std_logic;
        i_enable   :  in std_logic;
        i_img_data :  in std_logic_vector(width_t-1 downto 0);
        o_angle    : out std_logic_vector(8 downto 0); 
        o_gradient : out std_logic_vector(10 downto 0);
    --debug
        SB_IMG       : out std_logic_vector(7 downto 0)
    );
end sobel_33;
architecture Behavioral of sobel_33 is

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
component cordic is
	generic(
        w1             : integer ; --x,y位元
        w2             : integer ; --角度位元
        iteration_time : integer   --迭代次數
    );
	port(
        i_clk    :  in std_logic;
        i_rst    :  in std_logic;
        i_enable :  in std_logic;
        i_x      :  in std_logic_vector(w1-1 downto 0);
        i_y      :  in std_logic_vector(w1-1 downto 0);
        o_angle  : out std_logic_vector(w2-1 downto 0)
    );
end component;

signal Gx,Gy,Gx1,Gx3,Gy1,Gy3    :std_logic_vector(adder_bits-1 downto 0);
signal matrix:out_matrix(0 to ksize-1 , 0 to ksize-1);
signal Gx1adder,Gx3adder,Gy1adder,Gy3adder,Gx1multiple,Gx3multiple,Gy1multiple,Gy3multiple : unsigned(adder_bits-1 downto 0);
signal G_int                                   :integer; 

signal Gx_isneg , Gy_isneg : std_logic;

--arctan
type gradient_symbol_reg_array is array(iteration_time downto 0) of std_logic;
type G_reg_array is array(iteration_time downto 0) of std_logic_vector(10 downto 0);
signal Gx_isneg_reg , Gy_isneg_reg : gradient_symbol_reg_array;
signal angle       : std_logic_vector(8 downto 0):=(others=>'0');
signal angle_shift       : std_logic_vector(8 downto 0):=(others=>'0');
signal int_angle : integer;
signal G : std_logic_vector(adder_bits downto 0);
signal G_reg : G_reg_array;
signal gradient : std_logic_vector(10 downto 0);
--

begin
matrix_1 :matrix_nxn  
    generic map ( 
        ksize => ksize,
        data_bits => width_t
    )  
    port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_enable => i_enable,
        i_data => i_img_data,
        o_data => matrix
    );  
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ stage 1
adder_tree_process : process(i_rst,i_clk,matrix,i_enable)
begin
    if i_rst = '1' then
        Gx1 <= (others=>'0');
		Gx3 <= (others=>'0');
		Gy1 <= (others=>'0');
		Gy3 <= (others=>'0');
		Gx1adder <= (others => '0');
		Gx3adder <= (others => '0');
		Gy1adder <= (others => '0');
		Gy3adder <= (others => '0');
		Gx1multiple <= (others => '0');
		Gx3multiple <= (others => '0');
		Gy1multiple <= (others => '0');
		Gy3multiple <= (others => '0');		
    elsif rising_edge(i_clk) then
        if i_enable = '1' then
            --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ stage 2
            Gx1adder <= resize(unsigned(matrix(0,0)) + unsigned(matrix(2,0)),adder_bits);
            Gx3adder <= resize(unsigned(matrix(0,2)) + unsigned(matrix(2,2)),adder_bits);
            Gy1adder <= resize(unsigned(matrix(0,0)) + unsigned(matrix(0,2)),adder_bits);
            Gy3adder <= resize(unsigned(matrix(2,0)) + unsigned(matrix(2,2)),adder_bits);                  
            Gx1multiple <= resize(unsigned(matrix(1,0)) & "0",adder_bits);
            Gx3multiple <= resize(unsigned(matrix(1,2)) & "0",adder_bits);
            Gy1multiple <= resize(unsigned(matrix(0,1)) & "0",adder_bits);
            Gy3multiple <= resize(unsigned(matrix(2,1)) & "0",adder_bits);        
            --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ stage 3 
            Gx1 <= std_logic_vector(Gx1adder + Gx1multiple);
            Gx3 <= std_logic_vector(Gx3adder + Gx3multiple);
            Gy1 <= std_logic_vector(Gy1adder + Gy1multiple);
            Gy3 <= std_logic_vector(Gy3adder + Gy3multiple);            
        end if;
    end if;
end process;
Gx_Gy_process : process(i_rst,i_clk,i_enable,Gx1,Gx3,Gy1,Gy3)
begin
    if i_rst = '1' then
        Gx <= (others =>'0');
        Gy <= (others =>'0');
        Gx_isneg <= '0';
        Gy_isneg <= '0';
    elsif rising_edge(i_clk)  then
        if i_enable = '1' then
            --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ stage 4
            if Gx1 > Gx3 then 
                Gx <= std_logic_vector(unsigned(Gx1)- unsigned(Gx3));
                Gx_isneg <= '1';
            elsif Gx1 <= Gx3 then
                Gx <= std_logic_vector(unsigned(Gx3)- unsigned(Gx1));
                Gx_isneg <= '0';
            end if;
            if Gy1 >= Gy3 then 
                Gy <= std_logic_vector(unsigned(Gy1)- unsigned(Gy3));
                Gy_isneg <= '0';
            elsif Gy1 < Gy3 then
                Gy <= std_logic_vector(unsigned(Gy3)- unsigned(Gy1));
                Gy_isneg <= '1';                      
            end if;
        end if;
    end if;
end process;
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ stage 5 +  iteration_time 5 => stage 10
arctan_1 :cordic
	generic map(
        w1             => adder_bits,
        w2             =>  9,
        iteration_time => iteration_time
    )
	port map(
        i_clk    => i_clk,
        i_rst    => i_rst,
        i_enable => '1',
        i_x      => Gx,
        i_y      => Gy,
        o_angle  => angle
    );
process(i_rst, i_clk,i_enable,Gx,Gy)
begin
    if i_rst = '1' then
        G_reg <= (others =>(others =>'0'));
    elsif rising_edge(i_clk) then
        if i_enable = '1' then
            G_reg(0) <= std_logic_vector(resize(unsigned(Gx)+(unsigned(Gy)),11));
            for i in 1 to iteration_time loop
                G_reg(i) <= G_reg(i-1);
            end loop;
        end if;
    end if;
end process;
process(i_rst, i_clk)
begin
    if i_rst = '1' then
        Gx_isneg_reg <= (others =>'0');
        Gy_isneg_reg <= (others =>'0');
    elsif rising_edge(i_clk) then
        if i_enable = '1' then
            Gx_isneg_reg(0) <= Gx_isneg;
            Gy_isneg_reg(0) <= Gy_isneg;
            for i in 1 to iteration_time loop
                Gx_isneg_reg(i) <= Gx_isneg_reg(i-1);
                Gy_isneg_reg(i) <= Gy_isneg_reg(i-1);
            end loop;
        end if;
    end if;
end process;
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ stage 11
angle_process : process(i_rst ,i_clk , Gx_isneg_reg , Gy_isneg_reg , i_enable)
begin
    if i_rst = '1' then
        o_angle <= (others => '0');
    elsif rising_edge(i_clk)  then
        if i_enable = '1' then
            if Gy_isneg_reg(iteration_time) = Gx_isneg_reg(iteration_time)  then           
                o_angle <= angle;
            else
                o_angle <= std_logic_vector(to_unsigned(360 - to_integer(unsigned(angle)),9));
            end if;
        else
            o_angle <= (others => '0');
        end if;
    end if;
end process;
gradient_process : process(i_rst,i_clk , i_enable)
begin
    if i_rst = '1' then
        o_gradient <= (others => '0');
        SB_IMG <=(others => '0');
    elsif rising_edge(i_clk)  then
        if i_enable = '1' then
            if to_integer(unsigned(matrix(1,1))) = 0 then
                SB_IMG <= (others => '0');
            else
                if  to_integer(unsigned(G_reg(iteration_time))) >= 255 then
                    SB_IMG <= (others => '1');
                else
                    SB_IMG <= G_reg(iteration_time)(7 downto 0);
                end if;
            end if;          
            o_gradient <= G_reg(iteration_time);
        else
            o_gradient <= (others => '0');
            SB_IMG <=(others => '0');
        end if;
    end if;
end process;
end Behavioral;