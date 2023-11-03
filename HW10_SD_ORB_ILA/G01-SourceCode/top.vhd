
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity top is

port(
    --
		data_rom : in std_logic_vector(7 downto 0);
		rot_data_rom : in std_logic_vector(7 downto 0);
        --
--        sample_xy :out std_logic_vector(31 downto 0);    --blkA
--        match_xy :out std_logic_vector(31 downto 0);     --blkB
         sample_x :out std_logic_vector(9 downto 0);    --ILA
         sample_y :out std_logic_vector(9 downto 0);    --ILA
         match_x :out std_logic_vector(9 downto 0);     --match_data(19 downto 10)
         match_y :out std_logic_vector(9 downto 0);     --match_data(9 downto 0)
        ---
		clk:in std_logic;
		rst:in std_logic;
		button_1:in std_logic;		--k d
----------------vga-----------------------------
		r_out : out std_logic_vector(3 downto 0);
		g_out : out std_logic_vector(3 downto 0);
		b_out : out std_logic_vector(3 downto 0);
		hsync : out std_logic;
		vsync : out std_logic
--		o_grwy : out std_logic_vector(7 downto 0)
);
end top;

architecture Behavioral of top is

component vga 
port (

			clk : in std_logic;
			rst : in std_logic;			
			vga_hs_cnt : out integer range 0 to 857;
			vga_vs_cnt : out integer range 0 to 524;
			hsync : out std_logic;
			vsync : out std_logic
		  );
end component;


signal vga_hs_cnt :integer range 0 to 857;
signal vga_vs_cnt :integer range 0 to 524;

component harris 

port(
        clk : in std_logic;
        rst : in std_logic;
        video_data : in std_logic_vector(7 downto 0);
        vga_hs_cnt : in integer range 0 to 857;
        vga_vs_cnt : in integer range 0 to 524;
        threshold  : in std_logic_vector (43 downto 0);
        harris_out : out std_logic
 );
end component;

signal threshold  : std_logic_vector (43 downto 0);


signal video_data:std_logic_vector(7 downto 0);
signal harris_out:std_logic;
signal save_en:std_logic;
component orb 

port(
    clk : in std_logic;
    rst : in std_logic;	
    kp_en : in std_logic;
    save_en: in std_logic;
    vga_hs_cnt:in integer range 0 to 857;
    vga_vs_cnt:in integer range 0 to 524;
    addrb_1:in std_logic_vector(7 downto 0);
    doutb_1:out std_logic_vector(83 downto 0);
    addrb_2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    doutb_2 : OUT STD_LOGIC_VECTOR(83 DOWNTO 0);
    ping_pong_out_2_out: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    video_data:in std_logic_vector(7 downto 0)
 );
end component;

signal addrb_1:std_logic_vector(7 downto 0);
signal doutb_1:std_logic_vector(83 downto 0);
signal addrb_2:std_logic_vector(7 downto 0);
signal doutb_2:std_logic_vector(83 downto 0);

component number_8_8  --��8 �e40
Generic(set_left : integer range 0 to 719 :=0; --�����Z��
        set_top  : integer range 0 to 480 :=0);--�W���Z��
Port ( 
        number_8_8_in : STD_LOGIC_VECTOR (15 downto 0);
        Hex_Dec        : STD_LOGIC; --0�Q�i�� 1�Q���i��
        
        cnt_h_sync_vga :in integer range 0 to 857;
        cnt_v_sync_vga :in integer range 0 to 524;
        
        number_8_8_display_area :out std_logic;
        number_8_8_out :out std_logic
);
end component;

signal number_8_8_out_0,number_display_area_0:std_logic;
signal number_8_8_out_1,number_display_area_1:std_logic;
signal number_8_8_out_2,number_display_area_2:std_logic;
signal number_8_8_out_3,number_display_area_3:std_logic;
signal number_8_8_out_4,number_display_area_4:std_logic;
signal number_8_8_out_5,number_display_area_5:std_logic;

signal clkdiv:std_logic_vector(22 downto 0);

signal r,g,b:std_logic_vector(7 downto 0);

signal harris_sum:std_logic_vector(15 downto 0);
signal harris_sum_r:std_logic_vector(15 downto 0);
signal harris_sum_en:std_logic;

--COMPONENT rom240x240x300
--generic(				--one pixel one address 
--    data_depth : integer    :=  240*240*300;		--1440
--    data_bits  : integer    :=  8 		--64
--);
--port
--(
--    rclk  : in std_logic;
--    raddr : in std_logic_vector(25-1 downto 0); --25 bytes
--    rdata : out std_logic_vector(data_bits-1 downto 0)
--);
--END COMPONENT;

--COMPONENT rom240x240x300_rot
--generic(				--one pixel one address 
--    data_depth : integer    :=  240*240*300;		--1440
--    data_bits  : integer    :=  8 		--64
--);
--port
--(
--    rclk  : in std_logic;
--    raddr : in std_logic_vector(25-1 downto 0); --25 bytes
--    rdata : out std_logic_vector(data_bits-1 downto 0)
--);
--END COMPONENT;

----signal addra_rom:std_logic_vector(16 downto 0);
signal addra_rom:std_logic_vector(25-1 downto 0);
--signal data_rom:std_logic_vector(7 downto 0);

--COMPONENT rom240x240x300_rot
--  PORT (
--    clka : IN STD_LOGIC;
--    addra : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
--    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
--  );
--END COMPONENT;
--signal addra_rom_r:std_logic_vector(16 downto 0);
signal addra_rom_r:std_logic_vector(25-1 downto 0);
--signal data_rom_r:std_logic_vector(7 downto 0);

COMPONENT match
port(
	rst:in std_logic;
	clk:in std_logic;
	match_en:in std_logic;
	brief_addrb_1:out std_logic_vector(7 downto 0);
	brief_addrb_2:out std_logic_vector(7 downto 0);
	a:in std_logic_vector(83 downto 0);
	b:in std_logic_vector(83 downto 0);
	addrb:in std_logic_vector(7 downto 0);
	doutb:out std_logic_vector(39 downto 0)
	
);
END COMPONENT;

signal brief_addrb_1:std_logic_vector(7 downto 0);
signal brief_addrb_2:std_logic_vector(7 downto 0);
signal match_en:std_logic;
signal breif_data_1:std_logic_vector(83 downto 0);
signal breif_data_2:std_logic_vector(83 downto 0);
signal match_addr:std_logic_vector(7 downto 0);
signal match_data:std_logic_vector(39 downto 0);

--@@@@@@@@@@@@@@@@@@@@@@@@@@@	num_VGA
signal w_number_8_8_in : std_logic_vector(15 downto 0) := "00000000" & match_addr;  --
signal w_number_8_8_in1 : std_logic_vector(15 downto 0) := "000000"& match_data(9 downto 0);

signal w_number_8_8_in4 : std_logic_vector(15 downto 0) := "000000"& match_data(29 downto 20);

signal w_number_8_8_in8 : std_logic_vector(15 downto 0) := "000000"& match_data(39 downto 30);

signal state:std_logic_vector(1 downto 0);
signal test_data:std_logic_vector(7 downto 0);
signal ping_pong_out_2:std_logic_vector(7 downto 0);

signal CLK50mhz  :std_logic;
begin

--@@@@@@@@@@

--sample_xy <= "000000"& match_data(19 downto 10)&"000000"& match_data(9 downto 0);
--match_xy	 	<=  "000000"& match_data(39 downto 30)&"000000"& match_data(29 downto 20);

 sample_y  <= match_data(19 downto 10);
 sample_x  <= match_data(9 downto 0);
 match_y   <= match_data(39 downto 30);
 match_x   <= match_data(29 downto 20);

--@@@@@@@@@@@@@
--o_grwy <= r;--@@@@@@@@

r_out<=r(7 downto 4);
g_out<=g(7 downto 4);
b_out<=b(7 downto 4);

match_0:match
port map
(
	rst=>rst,
	clk=>CLK50MHz,
	match_en=>match_en,
	brief_addrb_1=>brief_addrb_1,
	brief_addrb_2=>brief_addrb_2,
	a=>breif_data_1,
	b=>breif_data_2,
	addrb=>match_addr,
	doutb=>match_data
);
orb_0 :orb
port map(
	   clk=>CLK50MHz,
		rst=>rst,
		save_en=>save_en,
		kp_en =>harris_out,
		vga_hs_cnt=>vga_hs_cnt,
		vga_vs_cnt=>vga_vs_cnt,
		addrb_1=>brief_addrb_1,
		--addrb_1=>match_addr,		
		doutb_1=>breif_data_1,
		addrb_2=>brief_addrb_2,
		doutb_2=>breif_data_2,
		ping_pong_out_2_out=>ping_pong_out_2,		
		video_data=>test_data

 );

--rom240x240_1: rom240x240 
--  PORT map
--  (
--    clka =>clk,
--    addra =>addra_rom(15 downto 0),
--    douta =>data_rom
--  );
--rom240x240_0: rom_240x240_r 
--  PORT map
--  (
--    clka =>clk,
--    addra =>addra_rom_r(15 downto 0),
--    douta =>data_rom_r
--  );
--  rom240x240_0: rom240x240x300
--generic map(				--one pixel one address 
--    data_depth => 240*240*300,		--1440
--    data_bits => 8 		
--  )
--  PORT map
--  (
--    rclk  =>clk,
--    raddr  =>addra_rom(25-1 downto 0),
--    rdata  =>data_rom
--  );
--    rom240x240_1: rom240x240x300_rot
--generic map(				--one pixel one address 
--    data_depth => 240*240*300,		--1440
--    data_bits => 8 		
--  )
--  PORT map
--  (
--    rclk  =>clk,
--    raddr  =>addra_rom(25-1 downto 0),
--    rdata  =>data_rom_r
--  );
vga_0:vga
port map(
	clk=>CLK50MHz,
	rst=>rst,
	vga_hs_cnt=>vga_hs_cnt,
	vga_vs_cnt=>vga_vs_cnt,
	hsync=>hsync,
	vsync=>vsync
);

harris_0:harris
port map(
	clk=>CLK50MHz,
	rst=>rst,
	video_data=>ping_pong_out_2,
	vga_hs_cnt=>vga_hs_cnt,
	vga_vs_cnt=>vga_vs_cnt,
	--threshold=>(25=>'1',others=>'0'),
	threshold=>threshold,
	harris_out=>harris_out
);


number_8_8_2 :number_8_8
GENERIC MAP(
    set_left => 10,
    set_top  => 292
)
PORT MAP(
    number_8_8_in  => w_number_8_8_in,
    Hex_Dec        => '0',
    cnt_h_sync_vga => vga_hs_cnt,
    cnt_v_sync_vga => vga_vs_cnt,
    number_8_8_display_area => number_display_area_2,
    number_8_8_out => number_8_8_out_2
);

number_8_8_0 :number_8_8
GENERIC MAP(
    set_left => 10,
    set_top  => 308
)
PORT MAP(
    number_8_8_in  => harris_sum,
    Hex_Dec        => '0',
    cnt_h_sync_vga => vga_hs_cnt,
    cnt_v_sync_vga => vga_vs_cnt,
    number_8_8_display_area => number_display_area_0,
    number_8_8_out => number_8_8_out_0
); 

number_8_8_1 :number_8_8
GENERIC MAP(
    set_left => 10,
    set_top  => 300
)
PORT MAP(
    number_8_8_in  => w_number_8_8_in1,
    Hex_Dec        => '0',
    cnt_h_sync_vga => vga_hs_cnt,
    cnt_v_sync_vga => vga_vs_cnt,
    number_8_8_display_area => number_display_area_1,
    number_8_8_out => number_8_8_out_1
);

number_8_8_3 :number_8_8
GENERIC MAP(
    set_left => 10,
    set_top  => 316
)
PORT MAP(
    number_8_8_in  =>harris_sum_r,
    Hex_Dec        => '0',
    cnt_h_sync_vga => vga_hs_cnt,
    cnt_v_sync_vga => vga_vs_cnt,
    number_8_8_display_area => number_display_area_3,
    number_8_8_out => number_8_8_out_3
);

number_8_8_4 :number_8_8
GENERIC MAP(
    set_left => 10,
    set_top  => 324
)
PORT MAP(
    number_8_8_in  => w_number_8_8_in4,
    Hex_Dec        => '0',
    cnt_h_sync_vga => vga_hs_cnt,
    cnt_v_sync_vga => vga_vs_cnt,
    number_8_8_display_area => number_display_area_4,
    number_8_8_out => number_8_8_out_4
);

number_8_8_5 :number_8_8
GENERIC MAP(
    set_left => 10,
    set_top  => 332
)
PORT MAP(
    number_8_8_in  => w_number_8_8_in8,
    Hex_Dec        => '0',
    cnt_h_sync_vga => vga_hs_cnt,
    cnt_v_sync_vga => vga_vs_cnt,
    number_8_8_display_area => number_display_area_5,
    number_8_8_out => number_8_8_out_5
);

--@@@@@@@@
process(clk,rst)begin
    if (rst = '0') then
        CLK50MHz <= '1';
    elsif (clk'event and clk = '1') then
        CLK50MHz<= not CLK50MHz;
    end if;  
end process;
-- clk <= CLK50MHz;

process( rst , CLK50MHz,vga_hs_cnt , vga_vs_cnt )
begin
if rst = '0' then
    test_data<= "00000000";

elsif CLK50MHz'event and CLK50MHz = '1' then
	if  vga_vs_cnt <240 then  
		test_data<=data_rom;
	else
		test_data<=rot_data_rom;
	end if;
end if;
end process;


process( rst , CLK50MHz,vga_hs_cnt , vga_vs_cnt )
begin
if rst = '0' then
    r <= "00000000";
    g <= "00000000";
    b <= "00000000";
elsif CLK50MHz'event and CLK50MHz = '1' then
	if vga_hs_cnt<720 and vga_vs_cnt <480 then  
--		 if std_logic_vector(to_unsigned(vga_hs_cnt,10))=breif_data_1(9 downto 0) or std_logic_vector(to_unsigned(vga_vs_cnt,10))=breif_data_1(19 downto 10)then
--			 r <= "00000000";
--			 g <= "11111111";
--			 b <= "00000000";		
	
		 if std_logic_vector(to_unsigned(vga_hs_cnt,10))=match_data(9 downto 0) or std_logic_vector(to_unsigned(vga_vs_cnt,10))=match_data(19 downto 10)then
			 r <= "00000000";
			 g <= "11111111";
			 b <= "00000000";	
		 elsif std_logic_vector(to_unsigned(vga_hs_cnt,10))=match_data(29 downto 20) or std_logic_vector(to_unsigned(vga_vs_cnt,10))=match_data(39 downto 30)then
			 r <= "00000000";
			 g <= "00000000";
			 b <= "11111111";			 
		 elsif harris_out='1' then
			 r <= "11111111";
			 g <= "00000000";
			 b <= "00000000";			 
		 elsif ( number_display_area_0 = '1' ) then
			  if(number_8_8_out_0 ='1')then
					r <= "00000000";g <= "11111111";b <= "00000000";
			  else
					r <= "00000000";g <= "00000000";b <= "00000000";
			  end if;
		 elsif ( number_display_area_1 = '1' ) then
			  if(number_8_8_out_1 ='1')then
					r <= "11111111";g <= "11111111";b <= "11111111";
			  else
					r <= "00000000";g <= "00000000";b <= "00000000";
			  end if;
		 elsif ( number_display_area_2 = '1' ) then
			  if(number_8_8_out_2 ='1')then
					r <= "11111111";g <= "11111111";b <= "11111111";
			  else
					r <= "00000000";g <= "00000000";b <= "00000000";
			  end if;
		 elsif ( number_display_area_3 = '1' ) then
			  if(number_8_8_out_3 ='1')then
					r <= "11111111";g <= "00000000";b <= "00000000";
			  else
					r <= "00000000";g <= "00000000";b <= "00000000";
			  end if;	
		 elsif ( number_display_area_4 = '1' ) then
			  if(number_8_8_out_4 ='1')then
					r <= "11111111";g <= "11111111";b <= "11111111";
			  else
					r <= "00000000";g <= "00000000";b <= "00000000";
			  end if;	
		 elsif ( number_display_area_5 = '1' ) then
			  if(number_8_8_out_5 ='1')then
					r <= "11111111";g <= "11111111";b <= "11111111";
			  else
					r <= "00000000";g <= "00000000";b <= "00000000";
			  end if;				  
		 elsif (vga_hs_cnt >60  and vga_hs_cnt <300 and vga_vs_cnt>=0 and vga_vs_cnt<240 )then
			 r <= data_rom;
			 g <= data_rom;
			 b <= data_rom;			 
		 else
			 r <= rot_data_rom;
			 g <= rot_data_rom;
			 b <= rot_data_rom;				
		 end if;
	else
		 r <= "00000000";
		 g <= "00000000";
		 b <= "00000000";	
	end if;
end if;
end process;

--
--process( rst , CLK50MHz,vga_hs_cnt , vga_vs_cnt ) 
--begin 
--if rst = '0' then 
-- video_data<="00000000"; 
--elsif CLK50MHz'event and CLK50MHz = '1' then 
-- if ( vga_hs_cnt /64 mod 2 = 1 ) xor ( vga_vs_cnt /64 mod 2 = 1 ) then 
-- video_data<="11111111"; 
-- else 
-- video_data<="00000000"; 
-- end if; 
--end if;
--end process;


process(rst,clk,clkdiv)
begin
if rst = '0' then
       clkdiv<="00000000000000000000000";
elsif clk'event and clk = '1' then
       clkdiv<=clkdiv+"00000000000000000000001";
end if;
end process;


process(rst,CLK50MHz)
begin
if rst = '0' then
	addra_rom<=(others=>'0');
elsif CLK50MHz'event and CLK50MHz= '1' then

	if (vga_hs_cnt >60  and vga_hs_cnt <300 and vga_vs_cnt>=0 and vga_vs_cnt<240 )then		
--		addra_rom<=  (std_logic_vector(to_unsigned(vga_vs_cnt,10))&"0000000")
--						+("0"&std_logic_vector(to_unsigned(vga_vs_cnt,10))&"000000")
--						+("00"&std_logic_vector(to_unsigned(vga_vs_cnt,10))&"00000")
--						+("000"&std_logic_vector(to_unsigned(vga_vs_cnt,10))&"0000")
--						+("0000000"&std_logic_vector(to_unsigned(vga_hs_cnt-60,10)));
        addra_rom <= addra_rom + 1;
	
	elsif (vga_hs_cnt >60  and vga_hs_cnt <300 and vga_vs_cnt>=240 and vga_vs_cnt<480 )then	
--		addra_rom_r<=  (std_logic_vector(to_unsigned(vga_vs_cnt-240,10))&"0000000")
--						+("0"&std_logic_vector(to_unsigned(vga_vs_cnt-240,10))&"000000")
--						+("00"&std_logic_vector(to_unsigned(vga_vs_cnt-240,10))&"00000")
--						+("000"&std_logic_vector(to_unsigned(vga_vs_cnt-240,10))&"0000")
--						+("0000000"&std_logic_vector(to_unsigned(vga_hs_cnt-60,10)));
        addra_rom_r <= addra_rom_r + 1;
        ----
	elsif (addra_rom > 240*240*249) then
		addra_rom<=(others=>'0');
		addra_rom_r<=(others=>'0');
        ----
    else
        addra_rom<= addra_rom;
		addra_rom_r<= addra_rom_r;
	end if;
    
end if;
end process;


process(rst,CLK50MHz)
begin
if rst = '0' then
	harris_sum<=(others=>'0');
	harris_sum_r<=(others=>'0');
elsif CLK50MHz'event and CLK50MHz= '1' then

	if (vga_hs_cnt >60  and vga_hs_cnt <300 and vga_vs_cnt>=0 and vga_vs_cnt<240 )then	
			if harris_out='1' then
				harris_sum<=harris_sum+1;
			end if;
	elsif (vga_hs_cnt >60  and vga_hs_cnt <300 and vga_vs_cnt>=240 and vga_vs_cnt<480 )then
			if harris_out='1' then
				harris_sum_r<=harris_sum_r+1;
			end if;		
	elsif vga_hs_cnt=857 and vga_vs_cnt=524 then
		
		harris_sum<=(others=>'0');
		harris_sum_r<=(others=>'0');
	else	
		harris_sum<=harris_sum;
		harris_sum_r<=harris_sum_r;
	end if;

end if;
end process;

--fsm
process(rst,CLK50MHz)
begin
if rst = '0' then
	state<="00";
	threshold<=(25=>'1',others=>'0');
elsif CLK50MHz'event and CLK50MHz= '1' then

	if state<"11"then
		if (vga_hs_cnt=857   and vga_vs_cnt=524 )then
		
				if state="00"then
					if harris_sum<="11111010000"then
						state<=state+"01";	
					else
						threshold<=threshold(42 downto 0)&'0';
					end if;		
				else			
					state<=state+"01";	
				end if;
		end if;
	else
		state<="11";
	end if;

end if;
end process;

process(rst,CLK50MHz)
begin
if rst = '0' then
save_en<='0';
match_en<='0';
elsif CLK50MHz'event and CLK50MHz= '1' then
	case state is 
		when "00"=>
			save_en<='0';
			match_en<='0';				
		when "01"=>
			save_en<='1';
			match_en<='0';		
		when "10"=>
			save_en<='0';
			match_en<='1';				
		when others=>
			save_en<='0';
			match_en<='0';			
	end case;
end if;
end process;


process(rst,clk)
begin
if rst = '0' then
       
	match_addr<=(others=>'0');
elsif clkdiv(21)'event and clkdiv(21) = '1' then

			if button_1='0' then
					if state="11" then
						if match_addr<"10111011100"then
							match_addr<=match_addr+"00000001";
						else
							match_addr<=(others=>'0');
						end if;
					end if;			
			else
			
				match_addr<=match_addr;
			end if;
end if;
end process;



end Behavioral;
