----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/04/13 11:21:45
-- Design Name: 
-- Module Name: Newton_method - Behavioral
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

entity Newton_method is
    generic(
        iteration  :integer :=4;
        data_bits  :integer := 8;
        quantization  :integer := 15
    );
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_x : in std_logic_vector(data_bits -1 downto 0);
        i_d : in std_logic_vector(data_bits -1 downto 0);
        o_q : out std_logic_vector(data_bits -1 downto 0)
    );
end Newton_method;

architecture Behavioral of Newton_method is
constant two : std_logic_vector(data_bits+quantization-1 downto 0) := (quantization+1 => '1' , others => '0');

type int_reg   is array(iteration*2 downto 0) of std_logic_vector(data_bits-1 downto 0);
type fixed_reg is array(iteration downto 0) of std_logic_vector(data_bits+quantization-1 downto 0);

signal x_reg , d_reg : int_reg;
signal m_latch,m_reg,m_delay : fixed_reg;
begin
    d_register : process(i_clk , i_rst)
    begin
        if i_rst = '1'then
            d_reg <= (others => (others => '0'));
        elsif rising_edge(i_clk)then
            d_reg(0)<=  i_d;
            for i in 1 to iteration*2 loop
                d_reg(i) <= d_reg(i-1);
            end loop;
        end if;
    end process;
    x_register : process(i_clk , i_rst)
    begin
        if i_rst = '1'then
            x_reg <= (others => (others => '0'));
        elsif rising_edge(i_clk)then
            x_reg(0) <=  i_x;                   
            for i in 1 to iteration*2 loop
                x_reg(i) <= x_reg(i-1);
            end loop;
        end if;
    end process;
    latch : process(i_rst,i_clk,m_reg,d_reg)
    begin
        if i_rst = '1' then
            m_latch <= (others => (others => '0'));
        elsif rising_edge(i_clk)then                    
            for i in 0 to iteration loop
                m_latch(i) <= std_logic_vector(to_unsigned(to_integer(unsigned(two))  - to_integer(unsigned(m_reg(i))) * to_integer(unsigned(d_reg(2*i))),data_bits+quantization));
            end loop;
        end if;
    end process;
  delay : process(i_rst , i_clk,m_reg)
  begin
    if i_rst = '1' then
        m_delay <= (others => (others => '0'));
    elsif rising_edge(i_clk)then                   
        for i in 0 to iteration loop
            m_delay(i) <= m_reg(i);
        end loop;    
    end if;
  end process;
    m_register : process(i_clk , i_rst,i_d,m_reg,d_reg,m_latch,m_delay)
    begin
        if i_rst = '1'then
            m_reg <= (others => (others => '0'));           
        elsif rising_edge(i_clk)then
            for i in 0 to iteration loop
                if i = 0 then
                    case to_integer(unsigned(i_d))is
                        when    0 to   9 => --0.1
                            m_reg(i)(quantization-1 downto quantization-5) <= "00011";   
                            m_reg(i)(quantization-6 downto 0) <= (others => '0');
                        when   10 to   99 => --0.01
                            m_reg(i)(quantization-1 downto quantization-8) <= "00000011";
                            m_reg(i)(quantization-9 downto 0) <= (others => '0');
                        when  100 to  999 =>--0.001
                            m_reg(i)(quantization-1 downto quantization-10) <= "0000000001";
                            m_reg(i)(quantization-11 downto 0) <= (others => '0');                        
                        when 1000 to 9999 =>--0.0001
                            m_reg(i)(quantization-1 downto quantization-13) <= "0000000000001";
                            m_reg(i)(quantization-14 downto 0) <= (others => '0');                                
                        when others => NULL;
                    end case;
                else
                    m_reg(i) <=to_stdlogicvector(to_bitvector(std_logic_vector(to_unsigned(to_integer(unsigned(m_delay(i-1))) * to_integer(unsigned(m_latch(i-1))),data_bits+quantization))) srl quantization);
                end if;
            end loop;
        end if;
    end process;      
    q_process : process(i_rst , i_clk,x_reg,m_reg)
    variable m : std_logic_vector(data_bits+quantization-1 downto 0);
    begin
        if i_rst = '1' then
            o_q <= (others => '0');
        elsif rising_edge(i_clk)then
            m := std_logic_vector(to_unsigned(to_integer(unsigned(x_reg(iteration*2)) * to_integer(unsigned(m_reg(iteration)))),data_bits+quantization));
            if m(quantization-1) = '1' then
                o_q <= std_logic_vector(to_unsigned(to_integer(unsigned(m(data_bits-1+quantization downto quantization))) + 1,data_bits));
            else
                o_q <= m(data_bits-1+quantization downto quantization);
            end if;
        end if;
    end process;
end Behavioral;
