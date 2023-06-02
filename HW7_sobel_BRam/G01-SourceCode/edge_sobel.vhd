library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity edge_sobel is
	generic (
		DATA_WIDTH	: integer := 8 );
    port ( 
		pclk_i		: in std_logic;
		hsync_i		: in std_logic;
		vsync_i		: in std_logic;
		btn_threshold: in std_logic_vector(1 downto 0);
		pData1 		: in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
		pData2 		: in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
		pData3 		: in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
		pData4 		: in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
		pData5 		: in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);    -- unconect
		pData6 		: in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
		pData7 		: in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
		pData8 		: in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
		pData9 		: in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
		
		hsync_o		: out std_logic;
		vsync_o		: out std_logic;
		pdata_o		: out std_logic_vector(DATA_WIDTH-1 downto 0) );
end entity edge_sobel;

architecture Behavioral of edge_sobel is
	signal summax, summay : std_logic_vector(10 downto 0);
	signal summa1, summa2 : std_logic_vector(10 downto 0);
	signal summa          : std_logic_vector(10 downto 0);
	
	signal btn_cnt : std_logic_vector(14 downto 0) := (others => '0');
	signal threshold : std_logic_vector(7 downto 0) := "01111111";
begin											-- threshold = 127 

btn_delay: process(pclk_i)
begin
	if (pclk_i'event and pclk_i = '1') then
		case btn_threshold is
		   when "10" |"01" =>
				btn_cnt <= btn_cnt + '1';
		   when others =>
				btn_cnt <= btn_cnt;
		end case;
	end if;
end process;

process(btn_cnt)
begin	
	if rising_edge(btn_cnt(14)) then
	   case threshold is
	     when "00000000" =>
	          case btn_threshold is
				   when "10" =>
					   threshold <= threshold + 1;
				   when others =>
					   threshold <= threshold;
	           end case;
	     when "11111111" =>
	          case btn_threshold is
					when "01" =>
						threshold <= threshold - 1;
					when others =>
						threshold <= threshold;
				end case;
	     when others =>
			case btn_threshold is
               when "10" =>
                   threshold <= threshold + 1;
               when "01" =>
                   threshold <= threshold - 1;						
               when others =>
                   threshold <= threshold;
		     end case;
         end case;
	end if;
end process;
		
edge_sobel: process (pclk_i)
begin  
	if (pclk_i'event and pclk_i = '1') then 
		hsync_o <= hsync_i;
		vsync_o <= vsync_i;

--		if hsync_i = '1' then			
--			if vsync_i = '1' then			
															-- x2
				summax<=("000" & pData3)+("00" & pData6 & '0')+("000" & pData9)
					-("000" & pData1)-("00" & pData4 & '0')-("000" & pData7);
															-- x2
				summay<=("000" & pData7)+("00" & pData8 & '0')+("000" & pData9)
					-("000" & pData1)-("00" & pData2 & '0')-("000" & pData3);
				
				-- Here is computed the absolute value of the numbers
				if summax(10)='1' then
					summa1<= not summax+1;
				else
					summa1<= summax;				
				end if;

				if summay(10)='1' then
					summa2<= not summay+1;
				else
					summa2<= summay;
				end if;
				
				summa<= summa1+summa2;

				-- if summa(7 downto 0) > threshold then			
					-- pdata_o<=(others => '1');
				-- else 
					-- pdata_o<=summa(DATA_WIDTH-	1 downto 0);
				-- end if;
				
--			END IF;
--		end if;
	end if;  -- pclk_i
end process edge_sobel;
	
end Behavioral;