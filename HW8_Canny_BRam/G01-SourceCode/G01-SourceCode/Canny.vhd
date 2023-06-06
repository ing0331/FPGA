----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2022/11/28 13:09:18
-- Design Name: 
-- Module Name: Canny - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.all;
use work.pkg.all;
use work.const_def.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Canny is
Generic(
    upper_thresh : integer range 0 to 1023 := 200;
    lower_thresh : integer range 0 to 1023 := 20);
Port ( 
            i_clk      :  in STD_LOGIC;
            i_rst      :  in STD_LOGIC;                  
            i_img_data :  in STD_LOGIC_VECTOR(width_t - 1 downto 0);
          vga_vs_cnt : in integer range 0 to vertical_resolution;
          vga_hs_cnt : in integer range 0 to horizontal_resolution;                  
          o_img_data :out std_logic;
     --debug
          CN_SB_data_out : out std_logic_vector(7 downto 0);
          CN_NMS_data_out : out std_logic_vector(7 downto 0);
          o_double : out std_logic_vector(7 downto 0);
          CN_NMS_BIN_IMG : out std_logic_vector(11 downto 0)
     --           
  );
end Canny;

architecture Behavioral of Canny is

component sobel_33 is
    generic( 
            iteration_time : integer 
    );
    port (
            i_clk      :  in std_logic;
            i_rst      :  in std_logic;
            i_enable   :  in std_logic;
            i_img_data :  in std_logic_vector(width_t-1 downto 0);
            o_angle    : out std_logic_vector(8 downto 0); 
            o_gradient : out std_logic_vector(10 downto 0);
      --debug
            SB_IMG       : out std_logic_vector(7 downto 0)
    );
end component;

signal SB_gradient_out : std_logic_vector(10 downto 0);
signal SB_angle_out : std_logic_vector(8 downto 0);
signal bin,pipe_bin : std_logic_vector(1 downto 0);
signal pipe_SB_gradient : std_logic_vector(10 downto 0);
signal pipe_SB_angle : std_logic_vector(8 downto 0);


component NMS_33
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
end component;

signal NMS_gradient_out : std_logic_vector(10 downto 0);
signal pipe_NMS_gradient : std_logic_vector(10 downto 0);

component hysteresis
    generic(
            upper_thresh : integer;
            lower_thresh : integer
    );
    port (
            i_clk      : in  std_logic;
            i_rst      : in  std_logic;
            i_enable   : in  std_logic;
            i_gradient : in std_logic_vector (10 downto 0);
            o_double_thresholding : out std_logic_vector(7 downto 0);        
            o_img_data :out std_logic
    );
end component;

component IP_enable is
    generic(
            latency_h : integer range 0 to 100;
            latency_v : integer range 0 to 100
    );
    port (
            i_clk    :  in std_logic;
            i_rst    :  in std_logic;     
            vga_vs_cnt : in integer range 0 to vertical_resolution;
            vga_hs_cnt : in integer range 0 to horizontal_resolution; 
            o_enable : out std_logic
    );
end component;

signal cn_en,sb_en,nms_en,hy_en: std_logic;
signal pipe_data_in : std_logic_vector(7 downto 0);
signal SB_IMG ,NMS_IMG: std_logic_vector(7 downto 0);
begin               
CN_NMS_data_out <= NMS_IMG;

SB_enable : IP_enable
    generic map(
        latency_h => 45, --19
        latency_v => 16  --4
    )
    port map(
        i_clk => i_clk,
        i_rst => i_rst,      
        vga_vs_cnt => vga_vs_cnt,
        vga_hs_cnt => vga_hs_cnt,
        o_enable => sb_en
    );         
Sobel_1 : sobel_33
    generic map(
        iteration_time => 5
    )
    Port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_enable => sb_en,
        i_img_data => pipe_data_in,
        o_angle => SB_angle_out,        
        o_gradient => SB_gradient_out,
        SB_img => SB_IMG
    );    
process(nms_en)
begin
    if i_rst = '1' then
        CN_SB_data_out <= (others =>'0');
    elsif nms_en = '1' then
        CN_SB_data_out <= SB_IMG;
    else
        CN_SB_data_out <= (others =>'0');
    end if;
end process;
----------------------------------    
--sobel stage : 11
--matrix_row_delay: kernel 3x3 = 3
--matrix_col_delay: kernel 3x3 = 2
--total_delay : 
--latency_h : 59
--latency_v : 18
----------------------------------    
NMS_enable : IP_enable
    generic map(
        latency_h => 59, --32
        latency_v => 18 --6
    )
    port map(
        i_clk            => i_clk,
        i_rst          => i_rst,      
        vga_vs_cnt     => vga_vs_cnt,
        vga_hs_cnt     => vga_hs_cnt,
        o_enable             => nms_en
    );         
nms : NMS_33 --stage 3
    port map (
        i_clk => i_clk,
        i_rst => i_rst,    
        i_gradient => pipe_SB_gradient,
        i_angle => pipe_SB_angle,
        i_enable => nms_en,
        o_gradient => NMS_gradient_out,
        NMS_IMG => NMS_IMG,
        NMS_BIN_IMG => CN_NMS_BIN_IMG
    );	
----------------------------------    
--NMS stage : 3
--matrix_row_delay: kernel 3x3 = 3
--matrix_col_delay: kernel 3x3 = 2
--total_delay : 
--latency_h : 65
--latency_v : 20
----------------------------------        
HY_enable : IP_enable
    generic map(
        latency_h => 65,
        latency_v => 20
    )
    port map(
        i_clk            => i_clk,
        i_rst          => i_rst,      
        vga_vs_cnt     => vga_vs_cnt,
        vga_hs_cnt     => vga_hs_cnt,
        o_enable             => hy_en
    );                         
hysteresis_1 : hysteresis   --stage 2 
    generic map(
        upper_thresh => upper_thresh,
        lower_thresh => lower_thresh)
    port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_enable => hy_en,      --hy_en
        i_gradient => pipe_NMS_gradient,
        o_double_thresholding =>o_double,  
        o_img_data => o_img_data
    ); 
----------------------------------    
--Hysteresis stage : 6
--matrix_row_delay: kernel 3x3 = 3
--matrix_col_delay: kernel 3x3 = 2
--total_delay : 
--latency_h : 74
--latency_v : 22
----------------------------------       


pipeline_process : process(i_rst , i_clk)
begin
    if i_rst = '1' then
        pipe_SB_angle     <= (others => '0');
        pipe_SB_gradient  <= (others => '0');
        pipe_NMS_gradient <= (others => '0');        
        pipe_data_in <= (others => '0');
    elsif rising_edge(i_clk)then
        pipe_data_in <= i_img_data;
        pipe_SB_gradient  <= SB_gradient_out;
        pipe_SB_angle     <= SB_angle_out;
        pipe_NMS_gradient <= NMS_gradient_out;        
    end if;
end process;

end Behavioral;