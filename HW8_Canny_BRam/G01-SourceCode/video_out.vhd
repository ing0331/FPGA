library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg.all;
use work.const_def.all;

entity video_out is port(
   clk             : in std_logic;
   reset           : in std_logic;
   rx                : in std_logic;   
   switch         : in std_logic_vector(3 downto 0);
   tx                : out std_logic;   
   Rout            : out std_logic_vector(3 downto 0); --
   Gout            : out std_logic_vector(3 downto 0); --
   Bout            : out std_logic_vector(3 downto 0); -- 
   hsync           : out std_logic;
   vsync           : out std_logic;
   led_test : out std_logic_vector(2 downto 0));
end video_out;

architecture module of video_out is

--component Transmission_module is 
--    Port ( 
--            i_clk   :  in std_logic;
--            i_rst   :  in std_logic;
--            i_rx   :  in std_logic;
--    --
--            i_fifo_wr : in std_logic;    
--            i_vs_cnt : in integer range 0 to vertical_resolution;
--            i_hs_cnt : in integer range 0 to horizontal_resolution;     
--            i_data : in std_logic;            
--    --
--            o_data : out std_logic_vector(7 downto 0);
--            o_done : out std_logic;
--            o_addr  : out std_logic_vector(18 downto 0);
--            o_tx  : out std_logic;
--            o_txen  : out std_logic;
--            o_finished : out std_logic;
--            o_full : out std_logic;
--            o_empty : out std_logic
--    );
--end component;

component Preprocess_modlue is
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
        i_img_data           :  in std_logic_vector(7 downto 0);
        o_BF_img            : out std_logic_vector(7 downto 0);
        o_GF_img            : out std_logic_vector(7 downto 0);      
        o_preprocess_img : out std_logic;
    --debug           
        CN_SB_data_out : out std_logic_vector(7 downto 0);
        CN_NMS_data_out : out std_logic_vector(7 downto 0);
        o_double : out std_logic_vector(7 downto 0);
        CN_NMS_BIN_IMG : out std_logic_vector(11 downto 0)
    );
end component;

component blk_mem_gen_0 is port (
    clka   : in std_logic;                                 --時脈輸入
    ena    : in std_logic;                                 --致能輸入，高位元致能
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    addra  : in std_logic_vector(18 downto 0);             --位址輸入    =>total addr = img_width * img_height 
    douta  : out std_logic_vector(7 downto 0));    --數據輸出    
end component;

component addr_controller is Port (                                --決定圖片顯示位置，bram addra
    clk             : in std_logic;
    reset           : in std_logic;    
    vga_vs_cnt : in integer range 0 to vertical_resolution;
    vga_hs_cnt : in integer range 0 to horizontal_resolution;  
    en               : out std_logic;
    addra          : out std_logic_vector (18 downto 0));
end component;
component divider is Port (                                --50MHz
    clk              : in std_logic;
    reset           : in std_logic;
    div_clk        : out std_logic);
end component;
component vga is port(
    clk                     : in std_logic;
    rst                      : in std_logic;
    video_start_en     : in std_logic;
    vga_vs_cnt : out integer range 0 to vertical_resolution;
    vga_hs_cnt : out integer range 0 to horizontal_resolution;  
    hsync                 : out std_logic;
    vsync                 : out std_logic);
end component;
component RGB is Port (
     clk             : in std_logic;
     switch          : in std_logic_vector(3 downto 0);
     img_a           : in std_logic_vector(11 downto 0);
     img_b         : in std_logic_vector(11 downto 0);
     img_c         : in std_logic_vector(11 downto 0);     
     img_d  : in std_logic_vector(11 downto 0);
     img_e : in std_logic_vector(11 downto 0);
     img_f : in std_logic_vector(11 downto 0);
     img_g        : in std_logic;
     ena              : in std_logic;    
     Rout            : out std_logic_vector(3 downto 0);
     Gout            : out std_logic_vector(3 downto 0);
     Bout            : out std_logic_vector(3 downto 0));
end component;

signal vga_vs_cnt : integer range 0 to vertical_resolution;
signal vga_hs_cnt : integer range 0 to horizontal_resolution;

signal div_clk,ena ,  preprocess_img  ,CN_img               : std_logic;
signal gray_out,blur_out,bila_out,CN_SB_out,CN_NMS_out,w_double : std_logic_vector (RGBbits-1 downto 0);
signal gray_img  ,blur_img ,bila_img ,o_double                    : std_logic_vector(width_t-1 downto 0);   
signal rd_addr ,wr_addr , bram_addr                                        : std_logic_vector (18 downto 0);
signal douta,doutb : std_logic_vector(width_t -1 downto 0);

signal img_x_count : integer range 0 to img_width-1;

signal out_enable , RTL_BRAM_WEA  : std_logic;
signal bram_wea : std_logic_vector(0 downto 0); 
signal tx_enable : std_logic_vector(0 downto 0);
signal rx_series : std_logic_vector(7 downto 0);

signal NMS_BIN : std_logic_vector(11 downto 0);
signal CN_SB ,CN_NMS: std_logic_vector(width_t-1 downto 0);


signal vga_en : std_logic;

begin

--transmission : Transmission_module
--    Port map(
--        i_clk       => clk,
--        i_rst       => reset,
--        i_rx        => rx,   
--        --
--        i_fifo_wr   => ena,
--        i_vs_cnt    => vga_vs_cnt ,
--        i_hs_cnt    => vga_hs_cnt,
--        i_data      => preprocess_img,
--        --
--        o_tx        => tx,
--        o_done      => RTL_BRAM_WEA,
--        o_addr      => wr_addr,
--        o_data      => rx_series,
--        o_finished  => led_test(0),
--        o_full     => led_test(1),
--        o_empty    => led_test(2)
--    );
 
preprocess : Preprocess_modlue
    Generic map(
        CN_upper_thresh => 200,
        CN_lower_thresh => 20
    )
    Port map( 
        i_clk            => div_clk,
        i_rst            => reset,
        i_enable         => ena, 
        vga_vs_cnt       => vga_vs_cnt,
        vga_hs_cnt       => vga_hs_cnt,
        i_img_data       => douta,
        o_BF_img         => bila_img,
        o_GF_img         => blur_img,       
        o_preprocess_img => preprocess_img,     --
                --debug
        CN_SB_data_out => CN_SB,
        CN_NMS_data_out => CN_NMS,
        o_double => o_double,               --
        CN_NMS_BIN_IMG  => NMS_BIN
    );
div_1 :divider port map(
    clk          => clk,
    reset        => reset,
    div_clk      => div_clk );
 vga_1 :vga port map( 
    clk             => div_clk, --
    rst             => reset,
    video_start_en  => '1',
    vga_hs_cnt      => vga_hs_cnt,
    vga_vs_cnt      => vga_vs_cnt,
    hsync           => hsync,
    vsync           => vsync ); 
addr :addr_controller port map(
    clk            => div_clk,
    reset          => reset,      
    vga_vs_cnt     => vga_vs_cnt,
    vga_hs_cnt     => vga_hs_cnt,
    en             => ena,
    addra          => rd_addr);
    
IP_BRAM :blk_mem_gen_0 port map(
    clka            => div_clk,
    ena             => ena,    
    wea             => "0",
    dina            => (others => 'Z'),     --rx_series,
    addra           => rd_addr,
    douta           => douta );
 

bila_out <= bila_img(7 downto 4) & bila_img(7 downto 4) & bila_img(7 downto 4);
blur_out <= blur_img(7 downto 4) & blur_img(7 downto 4) & blur_img(7 downto 4);
CN_SB_out <= CN_SB(7 downto 4) & CN_SB(7 downto 4) & CN_SB(7 downto 4);
CN_NMS_out <= CN_NMS(7 downto 4) & CN_NMS(7 downto 4) & CN_NMS(7 downto 4);
w_double <= o_double(7 downto 4) &o_double(7 downto 4)&o_double(7 downto 4);


RGB_1 :RGB Port map(
    clk             => div_clk, 
    switch          => switch,
    img_a           => bila_out,
    img_b           => blur_out,
    img_c           => CN_SB_out,
    img_d           => CN_NMS_out,
    img_e           => NMS_BIN,
    img_f           => w_double,
    img_g           => preprocess_img,
    ena             => ena,
    Rout            => Rout,
    Gout            => Gout,
    Bout            => Bout );    

process(reset , clk)
begin
    if reset = '1' then
        bram_addr <= (others => '0');
    else
        if RTL_BRAM_WEA = '1' then
            bram_addr <= wr_addr;
        elsif ena = '1' then
            bram_addr <= rd_addr;
        end if;
    end if;
end process;            

end module;