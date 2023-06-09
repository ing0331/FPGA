library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.pkg.all;
use work.const_def.all;
entity Gaussian_Filter is
    generic(
		ksize : integer := 5;
		adder_bits : integer := 16;
		quanzation_spatial : integer := 6
    );
    port ( 
            i_clk      :  in std_logic;     
            i_rst      :  in std_logic;
            i_enable   :  in std_logic;
            i_img_data :  in std_logic_vector(width_t-1 downto 0);
            o_img_data : out std_logic_vector(width_t-1 downto 0)      
    );
end Gaussian_Filter;

architecture Behavioral of Gaussian_Filter is
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

type m_reg is array (ksize**2 -1 downto 0) of integer;
type adder_tree is array (adder_num_count(ksize)-1 downto 0) of unsigned(adder_bits-1 downto 0);
type weight_array is array (ksize**2 -1 downto 0) of integer;
signal gaussian_kernel : std_logic_vector(adder_bits-1 downto 0);
signal matrix:out_matrix(0 to ksize-1 , 0 to ksize-1);
signal adder : adder_tree;
signal m : m_reg;
signal weight : weight_array :=(1, 2, 2, 2, 1, 2, 3, 4, 3, 2, 2, 4, 4, 4, 2, 2, 3, 4, 3, 2, 1, 2, 2, 2, 1);
begin
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ stage 1
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
matrix_reg_process : process(i_rst , i_clk)
begin
    if i_rst = '1' then
        m <= (others =>  0);
    elsif rising_edge(i_clk)then
        for index_col in 0 to (ksize - 1 )loop
            for index_row in 0 to (ksize - 1 )loop
                m(index_col*ksize + index_row) <= to_integer(unsigned(matrix(index_col , index_row))) * weight(index_col*ksize + index_row);
            end loop;
        end loop;
    end if;
end process;
adder_tree_process : process(i_rst , i_clk)
begin
    if i_rst = '1' then
        adder <= (others => (others => '0'));
    elsif rising_edge(i_clk)then     
        --fix
			adder(0) <= to_unsigned(m(0) + m(1),adder_bits);
			adder(1) <= to_unsigned(m(2) + m(3),adder_bits);
			adder(2) <= to_unsigned(m(4) + m(5),adder_bits);
			adder(3) <= to_unsigned(m(6) + m(7),adder_bits);
			adder(4) <= to_unsigned(m(8) + m(9),adder_bits);
			adder(5) <= to_unsigned(m(10) + m(11),adder_bits);
			adder(6) <= to_unsigned(m(12) + m(13),adder_bits);
			adder(7) <= to_unsigned(m(14) + m(15),adder_bits);
			adder(8) <= to_unsigned(m(16) + m(17),adder_bits);
			adder(9) <= to_unsigned(m(18) + m(19),adder_bits);
			adder(10) <= to_unsigned(m(20) + m(21),adder_bits);
			adder(11) <= to_unsigned(m(22) + m(23) + m(24),adder_bits);
			adder(12) <= adder(0) + adder(1);
			adder(13) <= adder(2) + adder(3);
			adder(14) <= adder(4) + adder(5);
			adder(15) <= adder(6) + adder(7);
			adder(16) <= adder(8) + adder(9);
			adder(17) <= adder(10) + adder(11);
			adder(18) <= adder(12) + adder(13);
			adder(19) <= adder(14) + adder(15);
			adder(20) <= adder(16) + adder(17);
			adder(21) <= adder(18) + adder(19) + adder(20);
	end if;
end process;
process(i_enable,i_clk,adder)
begin
    if i_enable = '1' then
		o_img_data <= std_logic_vector(adder(adder_num_count(ksize)-1)(quanzation_spatial+7 downto quanzation_spatial));
    else
        o_img_data <= (others => '0');
    end if;
end process;
end Behavioral;
