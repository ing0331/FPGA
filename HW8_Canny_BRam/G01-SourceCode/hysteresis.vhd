----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2022/11/29 18:40:18
-- Design Name: 
-- Module Name: hysteresis - Behavioral
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
use IEEE.numeric_std.all;
use work.pkg.all;
use work.const_def.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity hysteresis is
    generic(    
        upper_thresh : integer range 0 to 1023:=200;
        lower_thresh : integer range 0 to 1023:=20;
        data_bits : integer := 11;
        ksize : integer := 3
    );
    port (
        i_clk      : in  std_logic;
        i_rst      : in  std_logic;
        i_enable   : in  std_logic;
        i_gradient : in std_logic_vector (10 downto 0);
        o_double_thresholding : out std_logic_vector(7 downto 0);
        o_img_data :out std_logic;
        o_pre:out std_logic
    );
end hysteresis;

architecture Behavioral of hysteresis is

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
component FIFO_RTL is
    generic (
            g_WIDTH : integer;
            g_DEPTH : integer
    );
    port (
            i_rst   :  in STD_LOGIC;
            i_clk   :  in STD_LOGIC;   
            i_wr_en :  in STD_LOGIC;    
            i_rd_en :  in STD_LOGIC;
            i_data  :  in STD_LOGIC_VECTOR(g_WIDTH-1 downto 0);
            o_data  : out STD_LOGIC_VECTOR(g_WIDTH-1 downto 0);
            o_full  : out STD_LOGIC;    
            o_empty : out STD_LOGIC
    );
end component;
type row_data is array(2 downto 0) of std_logic;
type delay_double is array(1 downto 0) of std_logic_vector(7 downto 0);
signal double_thresholding_reg : delay_double;
type delay_edge is array(1 downto 0) of std_logic;
signal edge_track_reg: delay_edge;

signal matrix   :out_matrix(0 to ksize-1 , 0 to ksize-1);
signal edge_track,pre_edge_track ,correct_connected: std_logic;
signal pre_row_edge_track : row_data;
signal rd_cnt,wr_cnt : integer range 0 to img_width;
signal rd_en ,wr_en: std_logic;
signal double_thresholding : std_logic_vector(7 downto 0);
signal upper : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(upper_thresh,11));
signal lower : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(lower_thresh,11)); 
signal fifo_in : std_logic;

begin
o_pre <= fifo_in;
matrix_1 :matrix_nxn  
    generic map ( 
        ksize => ksize,
        data_bits => data_bits         
    )  
    port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_enable => i_enable,
        i_data => i_gradient,
        o_data => matrix
    );       
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ stage 1(double threshold)
upper <= std_logic_vector(to_unsigned(upper_thresh,11));
lower <= std_logic_vector(to_unsigned(lower_thresh,11));
double_thresholding_process : process(i_rst , i_clk,upper,lower,matrix,i_enable,edge_track,pre_row_edge_track)
begin
    if i_rst = '1' then
        edge_track <= '0';
        double_thresholding <= (others => '0');
    elsif rising_edge(i_clk) then
        if i_enable = '1' then
            if matrix(1,1) >= upper then
                double_thresholding <= (others => '1');
                edge_track <= '1';
            elsif matrix(1,1) < lower then
                double_thresholding <= (others => '0');
                edge_track <= '0';
            else
                if matrix(0,0) >= upper or 
                   matrix(0,1) >= upper or 
                   matrix(0,2) >= upper or 
                   matrix(1,0) >= upper or 
                   matrix(1,2) >= upper or
                   matrix(2,0) >= upper or 
                   matrix(2,1) >= upper or 
                   matrix(2,2) >= upper 
                   then
                    edge_track <= '1';
                else
                    edge_track <= '0';
                end if;
                double_thresholding <= "01001011";
            end if;
        else
            double_thresholding <= (others => '0');
        end if;
    end if;
end process;
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ stage 2,3,4(delay)
row_edge_track : process(i_rst , i_clk,pre_edge_track,pre_row_edge_track)
begin
    if i_rst = '1' then
        pre_row_edge_track <= (others => '0');
    elsif rising_edge(i_clk)then
        pre_row_edge_track(0) <= pre_edge_track;
        for i in 1 to ksize-1 loop
            pre_row_edge_track(i) <= pre_row_edge_track(i-1);    
        end loop;
    end if;
end process;
delay : process(i_rst,i_clk,double_thresholding,edge_track,edge_track_reg,double_thresholding_reg)
begin
    if i_rst = '1' then
        double_thresholding_reg <= (others => (others => '0'));
        edge_track_reg <= (others => '0'); 
    elsif rising_edge(i_clk)then
        double_thresholding_reg(0) <= double_thresholding;
        edge_track_reg(0) <= edge_track;
        for i in 1 to 1 loop
            edge_track_reg(i) <= edge_track_reg(i-1);
            double_thresholding_reg(i) <= double_thresholding_reg(i-1);
        end loop;  
    end if;
end process;
correct_connected_process: process(i_rst, i_clk,double_thresholding_reg,edge_track_reg,i_enable,correct_connected,pre_row_edge_track)
begin
    if i_rst = '1' then        
        correct_connected <= '0';
        o_img_data <= '0';
        o_double_thresholding <= (others => '0');        
    elsif rising_edge(i_clk) then
        if i_enable = '1' then
            o_double_thresholding <= double_thresholding_reg(1);
            case double_thresholding_reg(1) is
                when "01001011" =>
                    if edge_track_reg(1) = '1' or correct_connected = '1' or to_integer(unsigned(pre_row_edge_track)) > 0 then
                        o_img_data <= '1';
                        correct_connected <= '1';
                    else
                        o_img_data <= '0';
                        correct_connected <= '0';                        
                    end if;
                when "11111111" =>
                    o_img_data <= '1';
                    correct_connected <= '0';
                when others =>
                    o_img_data <= '0';
                    correct_connected <= '0';
            end case;
        end if;
    end if;
end process;
rd_enable_process : process(i_rst ,i_clk,i_enable,rd_cnt)
begin
    if i_rst = '1'then
        rd_cnt <= 0;
        rd_en <= '0';
    elsif rising_edge(i_clk)then
        if i_enable = '1' then
            if rd_cnt < img_width then
                rd_cnt <= rd_cnt + 1;
                rd_en <= '0';
            else
                rd_en <= '1';            
            end if;
        else
            rd_en <= '0';
        end if;
    end if;
end process;
wr_enable_process : process(i_rst ,i_clk,i_enable,wr_cnt)
begin
    if i_rst = '1'then
        wr_cnt <= 0;
        wr_en <= '0';
    elsif rising_edge(i_clk)then
        if i_enable = '1' then
            if wr_cnt < 3 then
                wr_cnt <= wr_cnt + 1;
                wr_en <= '0';
            else
                wr_en <= '1';            
            end if;
        else
            wr_en <= '0';
        end if;
    end if;
end process;
fifo_in <= correct_connected;
label_fifo: FIFO_RTL
    generic map(
        g_WIDTH  => 1,
        g_DEPTH  => img_width+100
    )
    port map(
        i_clk     =>  i_clk,
        i_rst     =>  i_rst,                
        i_wr_en   =>  wr_en,
        i_rd_en   =>  rd_en,
        i_data(0) =>  fifo_in,
        o_data(0) =>  pre_edge_track
    );
end Behavioral;