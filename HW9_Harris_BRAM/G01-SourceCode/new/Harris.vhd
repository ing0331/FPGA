
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Harris is
port(
    clk : in std_logic;
    rst : in std_logic;
    video_data : in std_logic_vector(7 downto 0);
    vga_hs_cnt : in integer range 0 to 640; --
    vga_vs_cnt : in integer range 0 to 480;
    threshold  : in std_logic_vector (43 downto 0);
    harris_out : out std_logic

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
end Harris;

architecture Behavioral of Harris is

    ---------------------|
    --SB = Sobel Buffer--|
    ---------------------|
    type Array_Sobel_buf is array (integer range 0 to 639) of std_logic_vector (7 downto 0);
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

    type Array_I_buf is array (integer range 0 to 639) of signed (10 downto 0);
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

begin

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

        elsif rising_edge(clk) then
            if (  vga_hs_cnt < 640 and  vga_vs_cnt < 480) then
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

                if  R > signed(threshold )then
                    harris_out<='1';
                else
                    harris_out<='0';
                end if;
            else
				
            end if;
        end if;
end process;

end Behavioral;
