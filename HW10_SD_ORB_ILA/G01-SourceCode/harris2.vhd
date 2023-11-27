----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    13:59:22 03/01/2018
-- Design Name:
-- Module Name:    harris - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity harris2 is

port(
    clk : in std_logic;
    rst : in std_logic;
    video_clk      : in std_logic;
    	    pepi: OUT std_logic_vector(0 downto 0);

    video_data : in std_logic_vector(7 downto 0);
    vga_hs_cnt : in integer range 0 to 857;
    vga_vs_cnt : in integer range 0 to 524;
    threshold  : in std_logic_vector (43 downto 0);
    harris_out2 : out std_logic;
    TRACKHARRIS : IN std_logic_vector(39 downto 0);
    harris_x2 : out integer;
    harris_y2 : out integer;
--    pepiclk  : out integer;
    TRACKX : IN integer;
    TRACKY : IN integer;
    TRACKSQ : IN integer

--      SB_buf_0_data_1  : in std_logic_vector(7 downto 0);
--      SB_buf_0_data_2  : in std_logic_vector(7 downto 0);
--      SB_buf_0_data_3  : in std_logic_vector(7 downto 0);
--      SB_buf_1_data_1  : in std_logic_vector(7 downto 0);
--      SB_buf_1_data_2  : in std_logic_vector(7 downto 0);
--      SB_buf_1_data_3  : in std_logic_vector(7 downto 0);
--      SB_buf_2_data_1  : in std_logic_vector(7 downto 0);
--      SB_buf_2_data_2  : in std_logic_vector(7 downto 0);
--      SB_buf_2_data_3  : in std_logic_vector(7 downto 0)

 );


end harris2;

architecture Behavioral of harris2 is

    ---------------------|
    --SB = Sobel Buffer--|
    ---------------------|
    type Array_Sobel_buf is array (integer range 0 to 719) of std_logic_vector (7 downto 0);
    signal SB_buf_0 : Array_Sobel_buf;
    signal SB_buf_0_data_1 : std_logic_vector(7 downto 0):="00000000";
    signal SB_buf_0_data_2 : std_logic_vector(7 downto 0):="00000000";
    signal SB_buf_0_data_3 : std_logic_vector(7 downto 0):="00000000";

    signal SB_buf_1 : Array_Sobel_buf;
    signal SB_buf_1_data_1 : std_logic_vector(7 downto 0):="00000000";
    signal SB_buf_1_data_2 : std_logic_vector(7 downto 0):="00000000";
    signal SB_buf_1_data_3 : std_logic_vector(7 downto 0):="00000000";

    signal SB_buf_2 : Array_Sobel_buf;
    signal SB_buf_2_data_1 : std_logic_vector(7 downto 0):="00000000";
    signal SB_buf_2_data_2 : std_logic_vector(7 downto 0):="00000000";
    signal SB_buf_2_data_3 : std_logic_vector(7 downto 0):="00000000";



    type Array_I_buf is array (integer range 0 to 719) of signed (10 downto 0);
    signal S_ix_buf_0 : Array_I_buf;
    signal S_ix_buf_1 : Array_I_buf;
    signal S_ix_buf_2 : Array_I_buf;

    signal S_iy_buf_0 : Array_I_buf;
    signal S_iy_buf_1 : Array_I_buf;
    signal S_iy_buf_2 : Array_I_buf;

    signal s_ix_buf_0_data_1 : signed(10 downto 0):=(others => '0');
    signal s_ix_buf_0_data_2 : signed(10 downto 0):=(others => '0');
    signal s_ix_buf_0_data_3 : signed(10 downto 0):=(others => '0');
    signal s_ix_buf_1_data_1 : signed(10 downto 0):=(others => '0');
    signal s_ix_buf_1_data_2 : signed(10 downto 0):=(others => '0');
    signal s_ix_buf_1_data_3 : signed(10 downto 0):=(others => '0');
    signal s_ix_buf_2_data_1 : signed(10 downto 0):=(others => '0');
    signal s_ix_buf_2_data_2 : signed(10 downto 0):=(others => '0');
    signal s_ix_buf_2_data_3 : signed(10 downto 0):=(others => '0');

    signal s_iy_buf_0_data_1 : signed(10 downto 0):=(others => '0');
    signal s_iy_buf_0_data_2 : signed(10 downto 0):=(others => '0');
    signal s_iy_buf_0_data_3 : signed(10 downto 0):=(others => '0');
    signal s_iy_buf_1_data_1 : signed(10 downto 0):=(others => '0');
    signal s_iy_buf_1_data_2 : signed(10 downto 0):=(others => '0');
    signal s_iy_buf_1_data_3 : signed(10 downto 0):=(others => '0');
    signal s_iy_buf_2_data_1 : signed(10 downto 0):=(others => '0');
    signal s_iy_buf_2_data_2 : signed(10 downto 0):=(others => '0');
    signal s_iy_buf_2_data_3 : signed(10 downto 0):=(others => '0');



    signal GS_ix2_sum :signed(25 downto 0):= (others => '0');
    signal GS_iy2_sum :signed(25 downto 0):= (others => '0');
    signal GS_ixy_sum :signed(25 downto 0):= (others => '0');

    signal det_m     :signed(43 downto 0):= (others => '0');

    signal trace_m2  :signed(45 downto 0):= (others => '0');
    --signal R  :signed(39 downto 0):= (others => '0');

    signal R_threshold :signed(43 downto 0):= (others => '0');

--     signal  h,v,X1,Y1,X2,Y2 : integer;

begin
----------------
--X1<=CONV_INTEGER(TRACKHARRIS(9 downto 0));
--X2<=CONV_INTEGER(TRACKHARRIS(29 downto 20));
--Y1<=CONV_INTEGER(TRACKHARRIS(19 downto 10));
--Y2<=CONV_INTEGER(TRACKHARRIS(39 downto 30));
-------------------------------------------------
--PROCESS(TRACKIN,RST)
--BEGIN
--    if rst='0'then
--            TRACKX <= 360;
--            TRACKY <= 240;       
--    elsif rising_edge(clk)then
--        IF TRACKIN = '1' THEN
--            TRACKX <= 360;
--            TRACKY <= 240;
--        ELSE
--            TRACKX <= X1;
--            TRACKY <= Y1;
--        END IF;
--    end if;
--END PROCESS;

-------------------------------------------------------
process(clk,rst)
    variable ix_buf_0_data_1  :std_logic_vector(8 downto 0):= (others => '0');
    variable ix_buf_0_data_2  :std_logic_vector(8 downto 0):= (others => '0');
    variable ix_buf_0_data_3  :std_logic_vector(8 downto 0):= (others => '0');
    variable ix_buf_1_data_1  :std_logic_vector(8 downto 0):= (others => '0');
    variable ix_buf_1_data_2  :std_logic_vector(8 downto 0):= (others => '0');
    variable ix_buf_1_data_3  :std_logic_vector(8 downto 0):= (others => '0');
    variable ix_buf_2_data_1  :std_logic_vector(8 downto 0):= (others => '0');
    variable ix_buf_2_data_2  :std_logic_vector(8 downto 0):= (others => '0');
    variable ix_buf_2_data_3  :std_logic_vector(8 downto 0):= (others => '0');


    variable iy_buf_0_data_1  :std_logic_vector(8 downto 0):= (others => '0');
    variable iy_buf_0_data_2  :std_logic_vector(8 downto 0):= (others => '0');
    variable iy_buf_0_data_3  :std_logic_vector(8 downto 0):= (others => '0');
    variable iy_buf_1_data_1  :std_logic_vector(8 downto 0):= (others => '0');
    variable iy_buf_1_data_2  :std_logic_vector(8 downto 0):= (others => '0');
    variable iy_buf_1_data_3  :std_logic_vector(8 downto 0):= (others => '0');
    variable iy_buf_2_data_1  :std_logic_vector(8 downto 0):= (others => '0');
    variable iy_buf_2_data_2  :std_logic_vector(8 downto 0):= (others => '0');
    variable iy_buf_2_data_3  :std_logic_vector(8 downto 0):= (others => '0');

    variable sum_ix  :signed(10 downto 0):= (others => '0');
    variable sum_iy  :signed(10 downto 0):= (others => '0');

    variable R  :signed(43 downto 0):= (others => '0');

    variable ix2_buf_0_data_1  :signed(21 downto 0):= (others => '0');
    variable ix2_buf_0_data_2  :signed(21 downto 0):= (others => '0');
    variable ix2_buf_0_data_3  :signed(21 downto 0):= (others => '0');
    variable ix2_buf_1_data_1  :signed(21 downto 0):= (others => '0');
    variable ix2_buf_1_data_2  :signed(21 downto 0):= (others => '0');
    variable ix2_buf_1_data_3  :signed(21 downto 0):= (others => '0');
    variable ix2_buf_2_data_1  :signed(21 downto 0):= (others => '0');
    variable ix2_buf_2_data_2  :signed(21 downto 0):= (others => '0');
    variable ix2_buf_2_data_3  :signed(21 downto 0):= (others => '0');

    variable iy2_buf_0_data_1  :signed(21 downto 0):= (others => '0');
    variable iy2_buf_0_data_2  :signed(21 downto 0):= (others => '0');
    variable iy2_buf_0_data_3  :signed(21 downto 0):= (others => '0');
    variable iy2_buf_1_data_1  :signed(21 downto 0):= (others => '0');
    variable iy2_buf_1_data_2  :signed(21 downto 0):= (others => '0');
    variable iy2_buf_1_data_3  :signed(21 downto 0):= (others => '0');
    variable iy2_buf_2_data_1  :signed(21 downto 0):= (others => '0');
    variable iy2_buf_2_data_2  :signed(21 downto 0):= (others => '0');
    variable iy2_buf_2_data_3  :signed(21 downto 0):= (others => '0');

    variable ixy_buf_0_data_1  :signed(21 downto 0):= (others => '0');
    variable ixy_buf_0_data_2  :signed(21 downto 0):= (others => '0');
    variable ixy_buf_0_data_3  :signed(21 downto 0):= (others => '0');
    variable ixy_buf_1_data_1  :signed(21 downto 0):= (others => '0');
    variable ixy_buf_1_data_2  :signed(21 downto 0):= (others => '0');
    variable ixy_buf_1_data_3  :signed(21 downto 0):= (others => '0');
    variable ixy_buf_2_data_1  :signed(21 downto 0):= (others => '0');
    variable ixy_buf_2_data_2  :signed(21 downto 0):= (others => '0');
    variable ixy_buf_2_data_3  :signed(21 downto 0):= (others => '0');

    begin
        if rst = '0' then

            SB_buf_0_data_3 <=(others=>'0');
            SB_buf_0_data_2 <=(others=>'0');
            SB_buf_0_data_1 <=(others=>'0');
            SB_buf_1_data_3 <=(others=>'0');
            SB_buf_1_data_2 <=(others=>'0');
            SB_buf_1_data_1 <=(others=>'0');
            SB_buf_2_data_3 <=(others=>'0');
            SB_buf_2_data_2 <=(others=>'0');
            SB_buf_2_data_1 <=(others=>'0');
--vga_hs_cnt >X1-10  and vga_hs_cnt <X1+10 and vga_vs_cnt>Y1-10 and vga_vs_cnt<Y1+10
--vga_hs_cnt >TRACKX-TRACKSQ  
--             and vga_hs_cnt < TRACKX+TRACKSQ 
--             and vga_vs_cnt > TRACKY-TRACKSQ 
--             and vga_vs_cnt < TRACKY+TRACKSQ
-------------------trak---------
        elsif rising_edge(video_clk) then
            if (vga_hs_cnt > TRACKX - TRACKSQ and vga_hs_cnt < TRACKX + TRACKSQ
	        and vga_vs_cnt > TRACKY - TRACKSQ and vga_vs_cnt < TRACKY + TRACKSQ) then
---------------------------------------------------------
--        elsif rising_edge(video_clk) then
--            if (vga_hs_cnt >64  and vga_hs_cnt < 656 
--	and vga_vs_cnt>=64 and vga_vs_cnt< 416) then
             
                        pepi <= "0";
                ---------------------------------------------------------line buffer
                SB_buf_0(vga_hs_cnt) <= SB_buf_1(vga_hs_cnt);
                SB_buf_1(vga_hs_cnt) <= SB_buf_2(vga_hs_cnt);
                SB_buf_2(vga_hs_cnt) <= video_data;
                
                ---------------------------------------------------------kernel buffer
                SB_buf_0_data_3 <= SB_buf_1(vga_hs_cnt);
                SB_buf_0_data_2 <= SB_buf_0_data_3;
                SB_buf_0_data_1 <= SB_buf_0_data_2;
                     
                SB_buf_1_data_3 <= SB_buf_2(vga_hs_cnt);
                SB_buf_1_data_2 <= SB_buf_1_data_3;
                SB_buf_1_data_1 <= SB_buf_1_data_2;
                     
                SB_buf_2_data_3 <= video_data;
                SB_buf_2_data_2 <= SB_buf_2_data_3;
                SB_buf_2_data_1 <= SB_buf_2_data_2;

                ---------------------------------------------------------Sobel multiplication
                ix_buf_0_data_1:='0'&SB_buf_0_data_1;
                ix_buf_0_data_2:=(others=>'0');
                ix_buf_0_data_3:='0'&SB_buf_0_data_3;

                ix_buf_1_data_1:=SB_buf_1_data_1&'0';
                ix_buf_1_data_2:=(others=>'0');
                ix_buf_1_data_3:=SB_buf_1_data_3&'0';

                ix_buf_2_data_1:='0'&SB_buf_2_data_1;
                ix_buf_2_data_2:=(others=>'0');
                ix_buf_2_data_3:='0'&SB_buf_2_data_3;



                iy_buf_0_data_1:='0'&SB_buf_0_data_1;
                iy_buf_0_data_2:=SB_buf_0_data_2&'0';
                iy_buf_0_data_3:='0'&SB_buf_0_data_3;

                iy_buf_1_data_1:= (others=>'0');
                iy_buf_1_data_2:= (others=>'0');
                iy_buf_1_data_3:= (others=>'0');

                iy_buf_2_data_1:='0'&SB_buf_2_data_1;
                iy_buf_2_data_2:=SB_buf_2_data_2 &'0';
                iy_buf_2_data_3:='0'&SB_buf_2_data_3;
                
                ---------------------------------------------------------Sobel addition
                ----------sum ix ---------------------------
                sum_ix:=signed(
                        "00"&
                         ix_buf_0_data_3
                        +ix_buf_1_data_3
                        +ix_buf_2_data_3

                        -ix_buf_0_data_1
                        -ix_buf_1_data_1
                        -ix_buf_2_data_1

                                );
                ----------sum iy ---------------------------
                sum_iy:=signed(
                        "00"&
                         iy_buf_2_data_1
                        +iy_buf_2_data_2
                        +iy_buf_2_data_3

                        -iy_buf_0_data_1
                        -iy_buf_0_data_2
                        -iy_buf_0_data_3
                                );
                                
                ---------------------------------------------------------line buffer Gx
                S_ix_buf_0(vga_hs_cnt) <= S_ix_buf_1(vga_hs_cnt);
                S_ix_buf_1(vga_hs_cnt) <= S_ix_buf_2(vga_hs_cnt);
                S_ix_buf_2(vga_hs_cnt) <= sum_ix;
                
                ---------------------------------------------------------kernel buffer Gx
                s_ix_buf_0_data_3 <= s_ix_buf_1(vga_hs_cnt);
                s_ix_buf_0_data_2 <= s_ix_buf_0_data_3;
                s_ix_buf_0_data_1 <= s_ix_buf_0_data_2;
                
                s_ix_buf_1_data_3 <= s_ix_buf_2(vga_hs_cnt);
                s_ix_buf_1_data_2 <= s_ix_buf_1_data_3;
                s_ix_buf_1_data_1 <= s_ix_buf_1_data_2;
                
                s_ix_buf_2_data_3 <= sum_ix;
                s_ix_buf_2_data_2 <= s_ix_buf_2_data_3;
                s_ix_buf_2_data_1 <= s_ix_buf_2_data_2;
                
                ---------------------------------------------------------line buffer Gy
                S_iy_buf_0(vga_hs_cnt) <= S_iy_buf_1(vga_hs_cnt);
                S_iy_buf_1(vga_hs_cnt) <= S_iy_buf_2(vga_hs_cnt);
                S_iy_buf_2(vga_hs_cnt) <= sum_iy;
                
                ---------------------------------------------------------kernel buffer Gy
                S_iy_buf_0_data_3 <= s_iy_buf_1(vga_hs_cnt);
                S_iy_buf_0_data_2 <= s_iy_buf_0_data_3;
                S_iy_buf_0_data_1 <= s_iy_buf_0_data_2;
                
                S_iy_buf_1_data_3 <= s_iy_buf_2(vga_hs_cnt);
                S_iy_buf_1_data_2 <= s_iy_buf_1_data_3;
                S_iy_buf_1_data_1 <= s_iy_buf_1_data_2;
                
                S_iy_buf_2_data_3 <= sum_iy;
                S_iy_buf_2_data_2 <= S_iy_buf_2_data_3;
                S_iy_buf_2_data_1 <= S_iy_buf_2_data_2;
                
                --------------------------------------------------------- Gx^2
                ix2_buf_0_data_3 :=  s_ix_buf_0_data_3*s_ix_buf_0_data_3;
                ix2_buf_0_data_2 :=  s_ix_buf_0_data_2*s_ix_buf_0_data_2;
                ix2_buf_0_data_1 :=  s_ix_buf_0_data_1*s_ix_buf_0_data_1;
                ix2_buf_1_data_3 :=  s_ix_buf_1_data_3*s_ix_buf_1_data_3;
                ix2_buf_1_data_2 :=  s_ix_buf_1_data_2*s_ix_buf_1_data_2;
                ix2_buf_1_data_1 :=  s_ix_buf_1_data_1*s_ix_buf_1_data_1;
                ix2_buf_2_data_3 :=  s_ix_buf_2_data_3*s_ix_buf_2_data_3;
                ix2_buf_2_data_2 :=  s_ix_buf_2_data_2*s_ix_buf_2_data_2;
                ix2_buf_2_data_1 :=  s_ix_buf_2_data_1*s_ix_buf_2_data_1;
                
                --------------------------------------------------------- Gy^2
                iy2_buf_0_data_3 :=  s_iy_buf_0_data_3*s_iy_buf_0_data_3;
                iy2_buf_0_data_2 :=  s_iy_buf_0_data_2*s_iy_buf_0_data_2;
                iy2_buf_0_data_1 :=  s_iy_buf_0_data_1*s_iy_buf_0_data_1;
                iy2_buf_1_data_3 :=  s_iy_buf_1_data_3*s_iy_buf_1_data_3;
                iy2_buf_1_data_2 :=  s_iy_buf_1_data_2*s_iy_buf_1_data_2;
                iy2_buf_1_data_1 :=  s_iy_buf_1_data_1*s_iy_buf_1_data_1;
                iy2_buf_2_data_3 :=  s_iy_buf_2_data_3*s_iy_buf_2_data_3;
                iy2_buf_2_data_2 :=  s_iy_buf_2_data_2*s_iy_buf_2_data_2;
                iy2_buf_2_data_1 :=  s_iy_buf_2_data_1*s_iy_buf_2_data_1;

                --------------------------------------------------------- Gy*Gx
                ixy_buf_0_data_3 :=  s_ix_buf_0_data_3*s_iy_buf_0_data_3;
                ixy_buf_0_data_2 :=  s_ix_buf_0_data_2*s_iy_buf_0_data_2;
                ixy_buf_0_data_1 :=  s_ix_buf_0_data_1*s_iy_buf_0_data_1;
                ixy_buf_1_data_3 :=  s_ix_buf_1_data_3*s_iy_buf_1_data_3;
                ixy_buf_1_data_2 :=  s_ix_buf_1_data_2*s_iy_buf_1_data_2;
                ixy_buf_1_data_1 :=  s_ix_buf_1_data_1*s_iy_buf_1_data_1;
                ixy_buf_2_data_3 :=  s_ix_buf_2_data_3*s_iy_buf_2_data_3;
                ixy_buf_2_data_2 :=  s_ix_buf_2_data_2*s_iy_buf_2_data_2;
                ixy_buf_2_data_1 :=  s_ix_buf_2_data_1*s_iy_buf_2_data_1;
                
                --------------------------------------------------------- gaussian filter
                GS_ix2_sum<= resize(("0000"&ix2_buf_0_data_1),26)
                            +resize((ix2_buf_0_data_2&"0"   ),26)
                            +resize((ix2_buf_0_data_3       ),26)
                            +resize((ix2_buf_1_data_1&"0"   ),26)
                            +resize((ix2_buf_1_data_2&"00"  ),26)
                            +resize((ix2_buf_1_data_3&"0"   ),26)
                            +resize((ix2_buf_2_data_1       ),26)
                            +resize((ix2_buf_2_data_2&"0"   ),26)
                            +resize((ix2_buf_2_data_3       ),26)
                            ;

                GS_iy2_sum<= resize(("0000"&iy2_buf_0_data_1),26)
                            +resize((iy2_buf_0_data_2&"0"   ),26)
                            +resize((iy2_buf_0_data_3       ),26)
                            +resize((iy2_buf_1_data_1&"0"   ),26)
                            +resize((iy2_buf_1_data_2&"00"  ),26)
                            +resize((iy2_buf_1_data_3&"0"   ),26)
                            +resize((iy2_buf_2_data_1       ),26)
                            +resize((iy2_buf_2_data_2&"0"   ),26)
                            +resize((iy2_buf_2_data_3       ),26)
                            ;

                GS_ixy_sum<= resize(("0000"&ixy_buf_0_data_1),26)
                            +resize((ixy_buf_0_data_2&"0"   ),26)
                            +resize((ixy_buf_0_data_3       ),26)
                            +resize((ixy_buf_1_data_1&"0"   ),26)
                            +resize((ixy_buf_1_data_2&"00"  ),26)
                            +resize((ixy_buf_1_data_3&"0"   ),26)
                            +resize((ixy_buf_2_data_1       ),26)
                            +resize((ixy_buf_2_data_2&"0"   ),26)
                            +resize((ixy_buf_2_data_3       ),26)
                            ;


                -----------Harris result --------------------------------------
                --    | ix2   ixy |
                -- M= |            |    det(M)= ix2*iy2 -ixy*ixy    trace(M)= ix2+iy2
                --     | ixy   iy2 |
                -- R= det(M) - k * trace(M) ^ 2  ,k= 0.04 or 5/128 


                det_m <= ( GS_ix2_sum(25 downto 4) * GS_iy2_sum(25 downto 4) ) - ( GS_ixy_sum(25 downto 4) * GS_ixy_sum(25 downto 4) );
                
                trace_m2 <= ( '0' & GS_ix2_sum(25 downto 4) + GS_iy2_sum(25 downto 4) ) * ( '0' & GS_ix2_sum(25 downto 4) + GS_iy2_sum(25 downto 4) );

                R := resize(det_m,44) - resize( trace_m2(45 downto 7), 44) - resize ( trace_m2(45 downto 7)&"00" ,44);

                if    R > signed(threshold )and vga_hs_cnt > 64 and vga_hs_cnt < 656 and  vga_vs_cnt > 48 and vga_vs_cnt <432 
                and vga_hs_cnt > TRACKX - TRACKSQ + 8 and vga_hs_cnt < TRACKX + TRACKSQ - 8 
	            and vga_vs_cnt > TRACKY - TRACKSQ + 8 + 20  and vga_vs_cnt < TRACKY + TRACKSQ - 8 -20 then
                    harris_out2<='1';
                    harris_x2 <= vga_hs_cnt;
                    harris_y2 <= vga_vs_cnt;
                    --

--                    pepiclk<= 1 ;
                else
                    harris_out2<='0';
                end if;
                
            else

            end if;
        end if;
end process;




end Behavioral;

