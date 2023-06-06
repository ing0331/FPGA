----------------------------------------------------------------------------------
-- Company: NKUST
-- Engineer: RFA
-- 
-- Create Date: 2022/12/01 13:46:49
-- Design Name: 
-- Module Name: Preprocess_modlue - Behavioral
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
use work.const_def.all;
use work.pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Preprocess_modlue is
    Generic(
            CN_upper_thresh : integer range 0 to 1023;
            CN_lower_thresh : integer range 0 to 1023
    );
    Port ( 
            i_clk                      :  in std_logic;
            i_rst                       :  in std_logic;
            i_enable                :  in std_logic;      
            vga_vs_cnt : in integer range 0 to vertical_resolution;
            vga_hs_cnt : in integer range 0 to horizontal_resolution;                        
            i_img_data            :  in std_logic_vector(7 downto 0);
            o_BF_img            : out std_logic_vector(7 downto 0);
            o_GF_img            : out std_logic_vector(7 downto 0);
            o_CN_img            : out std_logic;
            o_preprocess_img : out std_logic;
            --debug
            o_double : out std_logic_vector(7 downto 0);
            CN_SB_data_out : out std_logic_vector(7 downto 0);
            CN_NMS_data_out : out std_logic_vector(7 downto 0);
            CN_NMS_BIN_IMG : out std_logic_vector(11 downto 0)          
    );
end Preprocess_modlue;

architecture Behavioral of Preprocess_modlue is


component RGB2GRAY is 
    Port (
            RGB_in          : in std_logic_vector(11 downto 0);
            en                  : in std_logic;
            rst                 : in std_logic;
            clk                : in std_logic;
            GRAY_out    : out std_logic_vector(width_t-1 downto 0)
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

component bilateralfilter is
    port ( 
            i_clk      :  in STD_LOGIC;
            i_rst      :  in STD_LOGIC;
            i_enable   :  in STD_LOGIC;
            i_img_data :  in STD_LOGIC_VECTOR (width_t - 1 downto 0);
            o_img_data : out STD_LOGIC_VECTOR (width_t - 1 downto 0)
    );
end component;

component Gaussian_Filter is
    port ( 
            i_clk      :  in std_logic;     
            i_rst      :  in std_logic;
            i_enable   :  in std_logic;
            i_img_data :  in std_logic_vector(width_t-1 downto 0);
            o_img_data : out std_logic_vector(width_t-1 downto 0)     
    );
end component;
component Canny is
    generic(
        upper_thresh : integer range 0 to 1023 ;
        lower_thresh : integer range 0 to 1023 
    );
    port ( 
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
      );
end component;
--
signal GR_en   : std_logic;
signal GR_img : std_logic_vector(7 downto 0);
--
-- BF_sig
signal BF_en   : std_logic;
signal BF_img : std_logic_vector(7 downto 0);
--
-- GF_sig
signal GF_en  : std_logic;
signal GF_img : std_logic_vector(7 downto 0);
--
--CNIsing
signal CN_img ,SB_IMG,NMS_IMG: std_logic;
--
--Morphology_sig
--
--pipeline_sig
signal pipe_img_in : std_logic_vector(7 downto 0);
signal pipe_GR_img : std_logic_vector(7 downto 0);
signal pipe_BF_img : std_logic_vector(7 downto 0);
signal pipe_GF_img : std_logic_vector(7 downto 0);
--

signal CN_SB_IMG ,CN_NMS_IMG: std_logic_vector(width_t - 1 downto 0);
begin
--debug
CN_SB_data_out <= CN_SB_IMG;
CN_NMS_data_out <= CN_NMS_IMG;

BF_enable : IP_enable
    generic map(
        latency_h => 0, 
        latency_v => 0
    )
    port map(
        i_clk     => i_clk,
        i_rst     => i_rst,      
        vga_vs_cnt => vga_vs_cnt,
        vga_hs_cnt => vga_hs_cnt,
        o_enable   => BF_en
    );
Bilatera_Filter_1 : bilateralfilter
    Port map( 
        i_clk      => i_clk,
        i_rst      => i_rst,
        i_enable   => BF_en,
        i_img_data => i_img_data,
        o_img_data => BF_img
    );
----------------------------------    
--bilateral filter stage : 21       
--matrix_row_delay: kernel 13x13 = 13
--matrix_col_delay: kernel 13x13 = 12
--total_delay : 
--latency_h : 34
--latency_v : 12
----------------------------------
process(i_rst , i_clk)
begin
    if i_rst = '1' then
        o_BF_img <= (others => '0');
    elsif GF_en = '1' then
        o_BF_img <= BF_img;
    else
        o_BF_img <= (others => '0');
    end if;
end process;
GF_enable : IP_enable
    generic map(
        latency_h => 34,
        latency_v => 12
    )
    port map(
        i_clk     => i_clk,
        i_rst     => i_rst,      
        vga_vs_cnt => vga_vs_cnt,
        vga_hs_cnt => vga_hs_cnt,
        o_enable   => GF_en
    );
Gaussian_Filter_1 : Gaussian_Filter     --stage 4
    Port map( 
        i_clk     => i_clk,
        i_rst     => i_rst,
        i_enable   => GF_en,
        i_img_data => pipe_BF_img,
        o_img_data => GF_img
    );
----------------------------------    
--gaussian filter stage : 6
--matrix_row_delay: kernel 5x5 = 5
--matrix_col_delay: kernel 5x5 = 4
--total_delay : 
--latency_h : 45
--latency_v : 16
----------------------------------    
o_GF_img <=GF_img; 
canny_1 : Canny
    GENERIC MAP(
        upper_thresh        => CN_upper_thresh,        
    	lower_thresh        => CN_lower_thresh
    )
    PORT MAP(
        i_clk          => i_clk,
        i_rst          => i_rst,  
        i_img_data     => pipe_GF_img,
        vga_vs_cnt     => vga_vs_cnt,
        vga_hs_cnt     => vga_hs_cnt,              
        o_img_data      => o_preprocess_img,
        CN_SB_data_out  => CN_SB_IMG,
        CN_NMS_data_out => CN_NMS_IMG,
        o_double => o_double,
        CN_NMS_BIN_IMG  => CN_NMS_BIN_IMG
    );

pipeline_process : process(i_clk,i_rst,i_img_data,GR_img,BF_img,GF_img)
begin
    if i_rst = '1' then
        pipe_img_in <= (others => '0');
        pipe_BF_img <= (others => '0');
        pipe_GF_img <= (others => '0');   
    elsif rising_edge(i_clk)then
        pipe_img_in <= i_img_data;
        pipe_BF_img <= BF_img;
        pipe_GF_img <= GF_img;
    end if;
end process;
end Behavioral;
