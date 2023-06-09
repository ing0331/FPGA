----------------------------------------------------------------------------------
-- Company: NKUST
-- Engineer: RFA
-- 
-- Create Date: 2022/11/13 21:50:25
-- Design Name: 
-- Module Name: bilateralfilter - Behavioral
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

entity bilateralfilter is
    generic(
		ksize : integer := 3;
		adder_bits : integer := 35;
		iteration : integer := 6;
		quantization_spatial : integer := 4;
		quantization_range : integer := 10
	);
    port(
        i_clk      :  in STD_LOGIC;
        i_rst      :  in STD_LOGIC;
        i_enable   :  in STD_LOGIC;     
        i_img_data :  in STD_LOGIC_VECTOR (width_t - 1 downto 0);
        o_img_data : out STD_LOGIC_VECTOR (width_t - 1 downto 0)
    );
end bilateralfilter;

architecture Behavioral of bilateralfilter is

function adder_num_count(ksize : in integer) return integer is
begin
    case ksize is
        when 3 => return 7;
        when 5 => return 22;
        when 7 => return 46;
        when 9 => return 78;
        when 11 => return 115;
        when 13 => return 165;
        when 15 => return 220;
        when others => return 0;
    end case;    
end function;
function weight_range_lut(gray_diff : in integer) return integer is
    type weight_array is array(0 to 255) of integer range 0 to((2**quantization_range));
	constant weight_range : weight_array := (1024, 1022, 1015, 1004, 988, 969, 945, 918, 888, 855, 820, 783, 744, 703, 662, 621, 580, 539, 498, 459, 421, 384, 349, 316, 285, 255, 228, 203, 179, 158, 139, 121, 105, 91, 78, 67, 57, 49, 41, 35, 29, 24, 20, 17, 14, 11, 9, 8, 6, 5, 4, 3, 3, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
begin
    return weight_range(gray_diff);
end function;
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

component Newton_method
    generic(
        iteration  :integer ;
        data_bits  :integer ;
        quantization  :integer 
    );
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;    
        i_x : in std_logic_vector(data_bits -1 downto 0);
        i_d : in std_logic_vector(data_bits -1 downto 0);
        o_q : out std_logic_vector(data_bits -1 downto 0)
    );
end component;

constant newton_bits : integer := adder_bits-(quantization_range);
type adder_tree    is array(adder_num_count(ksize)-1 downto 0) of unsigned(adder_bits-1 downto 0);
type gray_diff_in  is array(ksize**2 -1 downto 0) of integer range 0 to (2**8)-1;
type weight_array  is array(ksize**2 -1 downto 0) of integer;
type conv          is array(ksize**2 -1 downto 0) of integer;



signal gray_diff  : gray_diff_in;
constant weight_spatial : weight_array := (6, 10, 6, 10, 16, 10, 6, 10, 6);
signal m,w,weight : conv;

signal matrix:out_matrix(0 to ksize-1 , 0 to ksize-1);

--bilaterafilter_kernel
signal adder, weight_adder  : adder_tree;
signal normalize : std_logic_vector(newton_bits-1 downto 0);
--
-- pipeline
signal matrix_reg_0,matrix_reg_1: out_matrix(0 to ksize-1 , 0 to ksize-1);
--
signal newton_x , newton_d : std_logic_vector(adder_bits-1 downto 0);
--

begin
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ stage 1 (line buffer)
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
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ stage 2 (gray diff)
range_domain_process : process(i_rst,i_clk)
begin
    if i_rst = '1'  then
        gray_diff <= (others => 0);        
    elsif rising_edge(i_clk) and i_enable = '1' then
        for index_col in 0 to (ksize - 1 )loop
            for index_row in 0 to (ksize - 1 )loop
                if matrix((ksize-1)/2,(ksize-1)/2) > matrix(index_col,index_row) then
                    gray_diff(index_col*ksize + index_row) <=( to_integer(unsigned(matrix((ksize-1)/2,(ksize-1)/2))) - to_integer(unsigned(matrix(index_col,index_row))));
                else
                    gray_diff(index_col*ksize + index_row) <= (to_integer(unsigned(matrix(index_col,index_row))) - to_integer(unsigned(matrix((ksize-1)/2,(ksize-1)/2))));
                end if;
            end loop;
        end loop;
    end if;
end process;
matrix_delay_0: process(i_rst,i_clk)
begin
    if i_rst = '1' then
        matrix_reg_0 <= (others => ( others => (others => '0')));
    elsif rising_edge(i_clk)then
        matrix_reg_0 <= matrix;
    end if;
end process;
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ stage 3 (bilateral weight)
weight_mul : process(i_rst , i_clk)
begin
    if i_rst = '1' then
        weight <= (others =>  0);
    elsif rising_edge(i_clk)then
        for index_col in 0 to (ksize - 1 )loop
            for index_row in 0 to (ksize - 1 )loop
                weight(index_col*ksize + index_row) <= weight_range_lut(gray_diff(index_col*ksize + index_row)) * weight_spatial(index_col*ksize + index_row) ;
            end loop;
        end loop;
    end if;
end process;
matrix_delay_1: process(i_rst,i_clk)
begin
    if i_rst = '1' then
        matrix_reg_1 <= (others => ( others => (others => '0')));
    elsif rising_edge(i_clk)then
        matrix_reg_1 <= matrix_reg_0;
    end if;
end process;
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ stage 4 (conv)
matrix_reg_process : process(i_rst , i_clk)
begin
    if i_rst = '1' then
        m <= (others =>  0);
    elsif rising_edge(i_clk)then
        for index_col in 0 to (ksize - 1 )loop
            for index_row in 0 to (ksize - 1 )loop
                m(index_col*ksize + index_row) <= to_integer(unsigned(matrix_reg_1(index_col , index_row))) * weight(index_col*ksize + index_row);
            end loop;
        end loop;
    end if;
end process;
weight_reg_process : process(i_rst , i_clk)
begin
    if i_rst = '1' then
        w <= (others =>  0);
    elsif rising_edge(i_clk)then
        for index_col in 0 to (ksize - 1 )loop
            for index_row in 0 to (ksize - 1 )loop
                w(index_col*ksize + index_row) <= weight(index_col*ksize + index_row);
            end loop;
        end loop;
    end if;
end process;
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ stage 5 (adder_tree)
weight_addertree : process(i_rst , i_clk , w , weight_adder)
begin
 if i_rst = '1' then
        weight_adder <= (others => (others => '1'));
    elsif rising_edge(i_clk) and i_enable = '1' then
        --fix_weight_adder
			weight_adder(0) <= to_unsigned(w(0) + w(1),adder_bits);
			weight_adder(1) <= to_unsigned(w(2) + w(3),adder_bits);
			weight_adder(2) <= to_unsigned(w(4) + w(5),adder_bits);
			weight_adder(3) <= to_unsigned(w(6) + w(7) + w(8),adder_bits);
			weight_adder(4) <= weight_adder(0) + weight_adder(1);
			weight_adder(5) <= weight_adder(2) + weight_adder(3);
			weight_adder(6) <= weight_adder(4) + weight_adder(5);
    end if;    
end process;
conv_addertree : process(i_rst , i_clk , m , adder)
begin
    if i_rst = '1' then
        adder <= (others => (others => '0'));
    elsif rising_edge(i_clk) and i_enable = '1' then
        --fix_adder
			adder(0) <= to_unsigned(m(0) + m(1),adder_bits);
			adder(1) <= to_unsigned(m(2) + m(3),adder_bits);
			adder(2) <= to_unsigned(m(4) + m(5),adder_bits);
			adder(3) <= to_unsigned(m(6) + m(7) + m(8),adder_bits);
			adder(4) <= adder(0) + adder(1);
			adder(5) <= adder(2) + adder(3);
			adder(6) <= adder(4) + adder(5);
    end if;
end process;
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ stage 6 (normalize)
process(i_rst,i_clk,adder,weight_adder)
begin
    if i_rst = '1' then
        newton_x <= (others => '0');
        newton_d <= (others => '0');
    else
        newton_x <= std_logic_vector(adder(adder_num_count(ksize)-1));
        newton_d <= std_logic_vector(weight_adder(adder_num_count(ksize)-1));
    end if;
end process;

divider : Newton_method
    generic map(
        iteration => iteration,
        data_bits => newton_bits,
        quantization => 15
    )
    port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_x => newton_x(adder_bits-1 downto (quantization_range)),
        i_d => newton_d(adder_bits-1 downto (quantization_range)),
        o_q => normalize 
    );
process(i_enable,i_clk,normalize)
begin
    if i_enable = '1' then
        if to_integer(unsigned(normalize)) > 255 then
            o_img_data <= (others => '1');
        else
            o_img_data <= std_logic_vector(normalize(7 downto 0));
        end if;
    else
        o_img_data <= (others => '0');
    end if;
end process;
end Behavioral;

