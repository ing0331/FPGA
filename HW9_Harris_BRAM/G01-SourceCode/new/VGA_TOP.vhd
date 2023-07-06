library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA_TOP is 
port(
		clock     : in std_logic;
		rst 	  : in std_logic;
		btn_threshold		: in std_logic_vector(1 downto 0);   --'1' ++, '0' --
		SW_Harris  	: in std_logic;  --'1' Harris, '0' img_gray
		
		o_VGA_HSync : out std_logic;--horizontal synchro signal					
		o_VGA_VSync	: out std_logic;	-- verical synchro signal 
        o_VGA_gray  : out std_logic_vector(7 downto 0)
	);
end entity VGA_TOP;

architecture arch of VGA_TOP is 

	constant c_TOTAL_COLS  : integer := 800;
	constant c_TOTAL_ROWS  : integer := 600;
	constant c_ACTIVE_COLS : integer := 640;
	constant c_ACTIVE_ROWS : integer := 480;
	
	component clkDiv is port(
        i_clk   : in std_logic;
        rst     : in std_logic;
        clk_div : out std_logic;
        clk_btn : out std_logic 
        );
    end component;
	component blk_mem_moun is port (
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
        vga_vs_cnt       : in std_logic_vector(9 downto 0);
        vga_hs_cnt       : in std_logic_vector(9 downto 0);  
        en               : out std_logic;
        addra          : out std_logic_vector (18 downto 0));
    end component;
     signal dout : std_logic_vector(7 downto 0);
     signal rd_addr : std_logic_vector(18 downto 0);
    signal vga_hs_cnt : std_logic_vector(9 downto 0);  
    signal vga_vs_cnt : std_logic_vector(9 downto 0);  
 component Harris is
     port(
         clk : in std_logic;
         rst : in std_logic;
         video_data : in std_logic_vector(7 downto 0);
         vga_hs_cnt : in integer range 0 to 640; --
         vga_vs_cnt : in integer range 0 to 480;
         threshold  : in std_logic_vector (43 downto 0);
         harris_out : out std_logic
         );
     end component;  
     signal threshold : std_logic_vector( 43 downto 0);
    signal w_Harris : std_logic_vector(7 downto 0);
    component VGA_Sync_Porch is
       generic (
         g_VIDEO_WIDTH : integer;
         g_TOTAL_COLS  : integer;
         g_TOTAL_ROWS  : integer;
         g_ACTIVE_COLS : integer;
         g_ACTIVE_ROWS : integer
         );
       port (
         i_Clk       : in std_logic;
         i_HSync     : in std_logic;
         i_VSync     : in std_logic;
         i_Red_Video : in std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
         i_Grn_Video : in std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
         i_Blu_Video : in std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
         --
         o_HSync     : out std_logic;
         o_VSync     : out std_logic;
         o_Red_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
         o_Grn_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
         o_Blu_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0) ); 
     end component;
         
    signal pixel_clk : std_logic;
    signal rd_en : std_logic;
    signal Harris_point : std_logic;
	signal Harris_out : std_logic_vector(7 downto 0);
	
	 -- Common VGA Signals
	 signal w_HSync_VGA       : std_logic;
	 signal w_VSync_VGA       : std_logic;
    signal w_HSync_Porch     : std_logic;
    signal w_VSync_Porch     : std_logic;
	
	signal w_Col_Count : STD_LOGIC_VECTOR(9 DOWNTO 0);	
	signal w_Row_Count : STD_LOGIC_VECTOR(9 DOWNTO 0);	
	signal btn_clk : std_logic;
begin	
	clockDiv_50M : clkDiv
		Port map ( 		
			i_clk   => clock,
			rst 	=> rst,
			clk_div => pixel_clk, 
			clk_btn => btn_clk);
	
	VGA_Sync_Pulses_inst : entity work.VGA_Sync_Pulses 
		generic map ( 
		 g_TOTAL_COLS  => c_TOTAL_COLS,
		 g_TOTAL_ROWS  => c_TOTAL_ROWS,
		 g_ACTIVE_COLS => c_ACTIVE_COLS,
		 g_ACTIVE_ROWS => c_ACTIVE_ROWS
		 )
	   port map (
		 i_Clk       => pixel_clk,
		 o_HSync     => w_HSync_VGA,      --w_HSync_VGA	11...00
		 o_VSync     => w_VSync_VGA,      --w_VSync_VGA
		 o_Col_Count => open,        --metastable
		 o_Row_Count => open
		 );	
		 
	 Sync_To_Count_inst : entity work.Sync_To_Count
		generic map (   
		  g_TOTAL_COLS => c_TOTAL_COLS,     
		  g_TOTAL_ROWS => c_TOTAL_ROWS
		  )
		port map (
		  i_Clk       => pixel_clk,
		  i_HSync     => w_HSync_VGA,
		  i_VSync     => w_VSync_VGA,
		  
		  o_HSync     => open,
		  o_VSync     => open,
		  o_Col_Count => w_Col_Count,
		  o_Row_Count => w_Row_Count
		  );		
		  
  addr :addr_controller 
    port map(
      clk            => pixel_clk,
      reset          => rst,      
      vga_vs_cnt     => w_Row_Count,
      vga_hs_cnt     => w_Col_Count,
      en             => rd_en,    --out
      addra          => rd_addr );
	BR: blk_mem_moun
		Port map ( 
          clka  => pixel_clk,
          ena   => rd_en,
          wea   => "0",
          dina  => (others => 'Z'),
          addra => rd_addr,
          douta => dout
          );
--      vga_hs_cnt <= TO_INTEGER(unsigned(w_Col_Count));
--      vga_vs_cnt <= TO_INTEGER(unsigned(w_Row_Count));
thres_adp: process(rst, btn_clk)
begin
    if rst = '0' then
        threshold <= std_logic_vector(to_unsigned(1000_0000, 44));
    elsif rising_edge(clock) then
        case btn_threshold is 
           when "01" =>
                threshold <= threshold - "1000";
           when "10" =>
                threshold <= threshold + "1000";
           when others =>
                threshold <= threshold;
        end case;
    end if;
end process;              
Harris_corner: Harris 
      PORT map( 
        clk        =>  pixel_clk,
        rst        =>  rst,
        video_data =>  dout,
        vga_hs_cnt =>  TO_INTEGER(unsigned(w_Col_Count)),
        vga_vs_cnt =>  TO_INTEGER(unsigned(w_Row_Count)),
        threshold  =>  threshold,
        harris_out =>  Harris_point
     );
     Harris_out <= (others => Harris_point);    --white point
    w_Harris <= Harris_out when SW_Harris = '1'
          else dout;          
    sync: VGA_Sync_Porch
          generic map (
          g_VIDEO_WIDTH => 8,
          g_TOTAL_COLS  => c_TOTAL_COLS,
          g_TOTAL_ROWS  => c_TOTAL_ROWS,
          g_ACTIVE_COLS => c_ACTIVE_COLS,
          g_ACTIVE_ROWS => c_ACTIVE_ROWS
          )
        port map(
          i_Clk       => pixel_clk,
          i_HSync     => w_HSync_VGA,
          i_VSync     => w_VSync_VGA,
          i_Red_Video => w_Harris,
          i_Grn_Video => w_Harris,
          i_Blu_Video => w_Harris,

          o_HSync     => w_HSync_Porch ,    --11...00..11
          o_VSync     => w_VSync_Porch ,
          o_Red_Video => o_VGA_gray,
          o_Grn_Video => open,
          o_Blu_Video => open
          );

      o_VGA_HSync <= w_HSync_Porch ;  
      o_VGA_VSync <= w_VSync_Porch ;
	
end architecture;