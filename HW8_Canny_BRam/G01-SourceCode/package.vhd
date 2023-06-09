library ieee;
use ieee.std_logic_1164.all;

package pkg is                           
  type out_matrix is array (NATURAL range <> , NATURAL range <>) of std_logic_vector(10 downto 0);
end package;

library ieee;
use ieee.std_logic_1164.all;
package const_def is                        --constant define
constant          DIV_CLK_CONSTANT : integer := 10;
-------------------------------------------------------------------------------------------VGA_const 800X600
-- horizotal
constant        horizontal_resolution        : integer := 800 ;
constant        horizontal_Front_porch    : integer :=  56 ;
constant        horizontal_Sync_pulse      : integer := 120 ;
constant        horizontal_Back_porch    : integer :=  64 ;
constant        h_sync_Polarity               : std_logic:= '1' ;
--
-- vertical
constant        vertical_resolution          : integer := 600 ;
constant        vertical_Front_porch      : integer :=  37 ;
constant        vertical_Sync_pulse       : integer :=   6 ;
constant        vertical_Back_porch      : integer :=  23 ;
constant        v_sync_Polarity             : std_logic:= '1' ;
--

---------------------------------------------------------------------------------------------img_const
--display_center
constant    center_x                     : integer := horizontal_resolution / 2 ;
constant    center_y                     : integer := vertical_resolution / 2 ;
--
--img  
constant    img_width                 : integer := 640;
constant    img_height                : integer := 480;
constant    RGBbits                   : integer := 12;  --  RGB444
--  

--initial latency
constant initial_latency_h : integer := 74;--42  38
constant initial_latency_v : integer := 22;--11  10
--
-------------------------------------------------------------------------------------------kernal_const
constant    width_t                      : integer := 8;  --matrix bits
-------------------------------------------------------------------------------------------
--UART_constant
constant clk_period : integer := 10;
constant bps            :integer  :=115200; 
constant pbclk         :integer := ((10**9)/(bps*clk_period));
end const_def;