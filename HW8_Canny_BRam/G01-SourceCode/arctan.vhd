library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;
entity cordic is
	generic(
        w1             : integer ; --x,y位元
        w2             : integer ; --角度位元
        iteration_time : integer --迭代次數
    );
	port(
        i_clk    :  in std_logic;
        i_rst    :  in std_logic;
        i_enable :  in std_logic;
        i_x      :  in std_logic_vector(w1-1 downto 0);
        i_y      :  in std_logic_vector(w1-1 downto 0);
        o_angle  : out std_logic_vector(w2-1 downto 0)
);
end cordic;

architecture beha of cordic is

constant signal_bits : integer := 2*w1;

type reg is array (iteration_time downto 0) of std_logic_vector(signal_bits-1 downto 0);            --pipeline_x,y
type reg_phi is array (iteration_time downto 0) of std_logic_vector(w2+8 downto 0);                 --pipeline_z
type ANGLE is ARRAY(NATURAL range <>) of INTEGER;                                                   --preset_angle
type state is (s0,s1);
constant z : ANGLE(0 to 14):=(11520,6801,3593,1824,916,458,229,115,57,29,14,7,4,2,1);
signal phi : reg_phi;
signal x0,y0 : reg;
signal im,re : reg;

signal Cstate : state := s0;
begin
	process(y0,x0)
	begin
	   for i in 0 to iteration_time loop
            im(i) <= to_stdlogicvector(to_bitvector(y0(i)) sra i);
            re(i) <= to_stdlogicvector(to_bitvector(x0(i)) sra i);
        end loop;
	end process;
	
process(i_clk,i_rst , i_enable , y0)
begin
	if i_rst='1' then
		phi <= (others =>(others => '0'));
		x0 <= (others =>(others => '0'));
		y0 <= (others =>(others => '0'));
	elsif rising_edge(i_clk) then
		for i in 1 to iteration_time loop
			case Cstate is
				when s0 =>
					if i_enable ='1' and i_x > 0 and i_y > 0 then
						Cstate <= s1;
						phi(0) <= (others => '0');
						x0(0) <= sxt(i_x,signal_bits);
						y0(0) <= sxt(i_y,signal_bits);
					end if;
				when s1 =>
						phi(0) <= (others => '0');
						x0(0) <= sxt(i_x,signal_bits);
						y0(0) <= sxt(i_y,signal_bits);		    
						if signed(y0(0))=0 then
							x0(i) <= x0(i);
							y0(i) <= y0(i);
							phi(i) <= phi(i-1);
						elsif (y0(i-1)(signal_bits-1)) = '1' then
							x0(i) <= x0(i-1) - im(i-1);
							y0(i) <= y0(i-1) + re(i-1);
							phi(i) <= phi(i-1) - z(i-1);
						else
							x0(i) <= x0(i-1) + im(i-1);
							y0(i) <= y0(i-1) - re(i-1);
							phi(i) <= phi(i-1) + z(i-1);
						end if;
				when others => Cstate <= s0;
			end case;
		end loop;			
	end if;
end process;
o_angle <= phi(iteration_time)(16 downto 8);
end beha;