----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/05/11 22:07:03
-- Design Name: 
-- Module Name: Hysteresis_tb - Behavioral
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
use IEEE.std_logic_textio.ALL;
use IEEE.numeric_std.all;
library STD;
use STD.textio.ALL;
use work.pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Canny_tb is
--  Port ( );
end Canny_tb;

architecture Behavioral of Canny_tb is
component Canny is
Generic(
    upper_thresh : integer range 0 to 1023 := 170;
    lower_thresh : integer range 0 to 1023 := 50);
Port ( 
            i_clk      :  in STD_LOGIC;
            i_rst      :  in STD_LOGIC;                  
            i_img_data :  in STD_LOGIC_VECTOR(7 downto 0);
            i_enable : in std_logic;                   
            o_img_data :out std_logic;
     --debug
          CN_SB_data_out : out std_logic_vector(7 downto 0);
          CN_NMS_data_out : out std_logic_vector(7 downto 0);
          o_double : out std_logic_vector(7 downto 0);
          CN_NMS_BIN_IMG : out std_logic_vector(11 downto 0)
     --           
  );
end component;
signal i_clk : std_logic;
signal i_rst : std_logic;
signal i_enable : std_logic;
signal i_img_data: std_logic_vector(7 downto 0);
signal o_img_data: std_logic;
signal o_debug: std_logic_vector(7 downto 0);
signal CN_SB_data_out,CN_NMS_data_out,o_double : std_logic_vector(7 downto 0);
signal CN_NMS_BIN_IMG: std_logic_vector(11 downto 0);
signal cnt : integer;
constant clk_period : time := 10 ns;
begin
u1 : Canny
    port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_enable => i_enable,
        i_img_data => i_img_data,
        o_img_data => o_img_data,
        CN_SB_data_out => CN_SB_data_out,
        CN_NMS_data_out => CN_NMS_data_out,
        CN_NMS_BIN_IMG => CN_NMS_BIN_IMG,
        o_double => o_double
    );
clk_process :process
begin
    i_clk <= '0';
    wait for clk_period/2;
    i_clk <= '1';
    wait for clk_period/2;
end process;
process
begin
    i_rst <= '1';
    i_enable <= '0';
    wait for clk_period/2;
    i_rst <= '0';  
    i_enable <= '1';  
    wait for 1000000000 * clk_period;
end process;
cnt_process:process(i_clk,i_rst)
begin
    if i_rst = '1' then 
        cnt <= 0;
    elsif rising_edge(i_clk)then
        if cnt < img_width*img_height then
            cnt <= cnt +1;
        end if;
    end if;
end process;
  -- Data source for gradient
  gradient_input: process
    file input_file : text;
    variable l: LINE;
    variable read_data: integer;
  begin
    file_open(input_file, "C:\Users\abc78\lab\project\FPGA_Canny\Canny.srcs\input_data.txt", read_mode);
      while not endfile(input_file) loop
          readline(input_file, l);
          if endfile(input_file) then
            exit;
          end if;
          wait for clk_period/2;
          read(l, read_data);
          i_img_data <= std_logic_vector(to_unsigned(read_data,8));
          wait for clk_period/2;
      end loop;
      file_close(input_file);
  end process;
--output_data
output_process:process
    file output_file : text;
    variable l : line;
    variable write_data : integer;
    variable data : integer;
begin
    file_open(output_file, "C:\Users\abc78\lab\project\FPGA_Canny\Canny.srcs\output_data.txt", write_mode);
    while True loop
        if cnt = img_width*img_height then
            file_close(output_file);
        else
            wait for clk_period/2;
            if o_img_data = '1' then
                            data := 255;
            else
                            data := 0;
            end if;
            write(output_file, integer'image(data));
            write(output_file, ",");
            writeline(output_file, l);
            wait for clk_period/2;        
        end if;
    end loop;    
end process;
--debug
Sobel_process:process
    file output_file : text;
    variable l : line;
    variable write_data : integer;
begin
    file_open(output_file, "C:\Users\abc78\lab\project\FPGA_Canny\Canny.srcs\Sobel_data.txt", write_mode);
    while True loop
        if cnt = img_width*img_height then
            file_close(output_file);
        else
            wait for clk_period/2;        
            write(output_file, integer'image(to_integer(unsigned(CN_SB_data_out))));
            write(output_file, ",");
            writeline(output_file, l);
            wait for clk_period/2;        
        end if;
    end loop;    
end process;
NMS_process:process
    file output_file : text;
    variable l : line;
    variable write_data : integer;
begin
    file_open(output_file, "C:\Users\abc78\lab\project\FPGA_Canny\Canny.srcs\NMS_data.txt", write_mode);
    while True loop
        if cnt = img_width*img_height then
            file_close(output_file);
        else
            wait for clk_period/2;        
            write(output_file, integer'image(to_integer(unsigned(CN_NMS_data_out))));
            write(output_file, ",");
            writeline(output_file, l);
            wait for clk_period/2;        
        end if;
    end loop;    
end process;
end Behavioral;
