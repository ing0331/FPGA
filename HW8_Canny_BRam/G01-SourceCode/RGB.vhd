library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity RGB is
    Port (
     clk             : in std_logic;
     switch         : in std_logic_vector(3 downto 0);
     img_a         : in std_logic_vector(11 downto 0);
     img_b         : in std_logic_vector(11 downto 0);
     img_c         : in std_logic_vector(11 downto 0);     
     img_d         : in std_logic_vector(11 downto 0);
     img_e         : in std_logic_vector(11 downto 0);
     img_f         : in std_logic_vector(11 downto 0);
     img_g        : in std_logic;
     ena             : in std_logic;       
     Rout           : out std_logic_vector(3 downto 0); --
     Gout           : out std_logic_vector(3 downto 0); --
     Bout           : out std_logic_vector(3 downto 0) --     
    );
end RGB;

architecture Behavioral of RGB is

signal cn_reg,CN_SB,CN_NMS : std_logic := '0';

begin
process(clk)
begin
    if rising_edge(clk)then        
        cn_reg  <= img_g;     
    end if;
end process;
process(clk,ena)
begin
    if rising_edge(clk) then
        if ena = '1' then
            case switch is                
                when "0000" =>--ori
                    Rout<= img_a(11 downto 8);
                    Gout<= img_a(7 downto 4);
                    Bout<= img_a(3 downto 0);            
                when "0001" =>--bila
                    Rout<= img_b(11 downto 8);
                    Gout<= img_b(7 downto 4);
                    Bout<= img_b(3 downto 0);            
                when "0010" =>--gaussian
                    Rout<= img_c(11 downto 8);
                    Gout<= img_c(7 downto 4);
                    Bout<= img_c(3 downto 0);
                when "0011"=>--sobel
                    Rout<= img_d(11 downto 8);
                    Gout<= img_d(7 downto 4);
                    Bout<= img_d(3 downto 0);
                when "0100"=>--nms
                    Rout<= img_e(11 downto 8);
                    Gout<= img_e(7 downto 4);
                    Bout<= img_e(3 downto 0);
                when "0101"=>--bin
                    Rout<= img_f(11 downto 8);
                    Gout<= img_f(7 downto 4);
                    Bout<= img_f(3 downto 0);
                when "0111" =>--hy
                    Rout<= cn_reg & cn_reg & cn_reg & cn_reg;
                    Gout<= cn_reg & cn_reg & cn_reg & cn_reg;
                    Bout<= cn_reg & cn_reg & cn_reg & cn_reg;	
                when others =>
                    Rout<= (others => '0');
                    Gout<= (others => '1');
                    Bout<= (others => '0');
            end case;
        else
            Bout<=(others=>'0');
            Gout<=(others=>'0');
            Rout<=(others=>'0');
       end if;
   end if;
end process;
end Behavioral;
