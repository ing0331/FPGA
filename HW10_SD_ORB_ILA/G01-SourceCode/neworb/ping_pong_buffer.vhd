library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.numeric_std.ALL;

entity ping_pong_buffer is


port(
        clk : in std_logic;
        rst : in std_logic;	
		video_data:in std_logic_vector(7 downto 0);
		vga_hs_cnt :in integer range 0 to 857;	
		vga_vs_cnt :in integer range 0 to 524;
		ping_pong_out_8:out std_logic_vector(7 downto 0);
		ping_pong_out_7:out std_logic_vector(7 downto 0);
		ping_pong_out_6:out std_logic_vector(7 downto 0);
		ping_pong_out_5:out std_logic_vector(7 downto 0);
		ping_pong_out_4:out std_logic_vector(7 downto 0);
		ping_pong_out_3:out std_logic_vector(7 downto 0);
		ping_pong_out_2:out std_logic_vector(7 downto 0);
		ping_pong_out_1:out std_logic_vector(7 downto 0)
 );


end ping_pong_buffer;
  
architecture Behavioral of ping_pong_buffer is

COMPONENT ram720x1x8
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    clkb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

signal line_address:STD_LOGIC_VECTOR(9 DOWNTO 0);
signal  line_data_in_0, line_data_in_1, line_data_in_2, line_data_in_3, line_data_in_4, line_data_in_5, line_data_in_6, line_data_in_7, line_data_in_8:STD_LOGIC_VECTOR(7 DOWNTO 0);
signal line_data_out_0,line_data_out_1,line_data_out_2,line_data_out_3,line_data_out_4,line_data_out_5,line_data_out_6,line_data_out_7,line_data_out_8:STD_LOGIC_VECTOR(7 DOWNTO 0);
signal wea:STD_LOGIC_VECTOR(8 DOWNTO 0);
signal ping_pong_state:STD_LOGIC_VECTOR(3 DOWNTO 0);
begin

ram720x1x8_0: ram720x1x8  
  port map (
    clka =>clk,
    wea(0)  =>wea(0),
    addra=>line_address,
    dina =>line_data_in_0,
    clkb =>clk,
    addrb =>line_address,
    doutb =>line_data_out_0
  );
ram720x1x8_1: ram720x1x8
  port map (
    clka =>clk,
    wea(0)  =>wea(1),
    addra=>line_address,
    dina =>line_data_in_1,
    clkb =>clk,
    addrb =>line_address,
    doutb =>line_data_out_1
  );
 ram720x1x8_2: ram720x1x8
  port map (
    clka =>clk,
    wea(0)  =>wea(2),
    addra=>line_address,
    dina =>line_data_in_2,
    clkb =>clk,
    addrb =>line_address,
    doutb =>line_data_out_2
  );
ram720x1x8_3: ram720x1x8
  port map (
    clka =>clk,
    wea(0)  =>wea(3),
    addra=>line_address,
    dina =>line_data_in_3,
    clkb =>clk,
    addrb =>line_address,
    doutb =>line_data_out_3
  );
ram720x1x8_4: ram720x1x8
  port map (
    clka =>clk,
    wea(0)  =>wea(4),
    addra=>line_address,
    dina =>line_data_in_4,
    clkb =>clk,
    addrb =>line_address,
    doutb =>line_data_out_4
  );
 ram720x1x8_5: ram720x1x8
  port map (
    clka =>clk,
    wea(0)  =>wea(5),
    addra=>line_address,
    dina =>line_data_in_5,
    clkb =>clk,
    addrb =>line_address,
    doutb =>line_data_out_5
  );
ram720x1x8_6: ram720x1x8
  port map (
    clka =>clk,
    wea(0)  =>wea(6),
    addra=>line_address,
    dina =>line_data_in_6,
    clkb =>clk,
    addrb =>line_address,
    doutb =>line_data_out_6
  );
ram720x1x8_7: ram720x1x8
  port map (
    clka =>clk,
    wea(0)  =>wea(7),
    addra=>line_address,
    dina =>line_data_in_7,
    clkb =>clk,
    addrb =>line_address,
    doutb =>line_data_out_7
  );
 ram720x1x8_8: ram720x1x8
  port map (
    clka =>clk,
    wea(0)  =>wea(8),
    addra=>line_address,
    dina =>line_data_in_8,
    clkb =>clk,
    addrb =>line_address,
    doutb =>line_data_out_8
  );

line_address<=std_logic_vector(to_unsigned(vga_hs_cnt,10));  
process(clk,rst)
begin
if rst='0'then
	
	wea<=(others=>'0');
	line_data_in_0<=(others=>'0');
	line_data_in_1<=(others=>'0');
	line_data_in_2<=(others=>'0');
	line_data_in_3<=(others=>'0');
	line_data_in_4<=(others=>'0');
	line_data_in_5<=(others=>'0');
	line_data_in_6<=(others=>'0');
	line_data_in_7<=(others=>'0');
	line_data_in_8<=(others=>'0');
	
	ping_pong_out_8<=(others=>'0');
	ping_pong_out_7<=(others=>'0');
	ping_pong_out_6<=(others=>'0');
	ping_pong_out_5<=(others=>'0');
	ping_pong_out_4<=(others=>'0');
	ping_pong_out_3<=(others=>'0');
	ping_pong_out_2<=(others=>'0');
	ping_pong_out_1<=(others=>'0');
	
	
elsif rising_edge(clk)then
	if vga_hs_cnt <720 then
		case ping_pong_state is
			when "0000"=>		
				wea<="000000001";
				line_data_in_0<=video_data;	
				ping_pong_out_8<=line_data_out_8;
				ping_pong_out_7<=line_data_out_7;
				ping_pong_out_6<=line_data_out_6;
				ping_pong_out_5<=line_data_out_5;
				ping_pong_out_4<=line_data_out_4;
				ping_pong_out_3<=line_data_out_3;
				ping_pong_out_2<=line_data_out_2;
				ping_pong_out_1<=line_data_out_1;
				
			when "0001"=>	
				wea<="100000000";
				line_data_in_8<=video_data;
				ping_pong_out_8<=line_data_out_7;
				ping_pong_out_7<=line_data_out_6;
				ping_pong_out_6<=line_data_out_5;
				ping_pong_out_5<=line_data_out_4;
				ping_pong_out_4<=line_data_out_3;
				ping_pong_out_3<=line_data_out_2;
				ping_pong_out_2<=line_data_out_1;
				ping_pong_out_1<=line_data_out_0;				
			when "0010"=>
				wea<="010000000";
				line_data_in_7<=video_data;
				ping_pong_out_8<=line_data_out_6;
				ping_pong_out_7<=line_data_out_5;
				ping_pong_out_6<=line_data_out_4;
				ping_pong_out_5<=line_data_out_3;
				ping_pong_out_4<=line_data_out_2;
				ping_pong_out_3<=line_data_out_1;
				ping_pong_out_2<=line_data_out_0;
				ping_pong_out_1<=line_data_out_8;				
			when "0011"=>
				wea<="001000000";
				line_data_in_6<=video_data;
				ping_pong_out_8<=line_data_out_5;
				ping_pong_out_7<=line_data_out_4;
				ping_pong_out_6<=line_data_out_3;
				ping_pong_out_5<=line_data_out_2;
				ping_pong_out_4<=line_data_out_1;
				ping_pong_out_3<=line_data_out_0;
				ping_pong_out_2<=line_data_out_8;
				ping_pong_out_1<=line_data_out_7;				
			when "0100"=>
				wea<="000100000";
				line_data_in_5<=video_data;
				ping_pong_out_8<=line_data_out_4;
				ping_pong_out_7<=line_data_out_3;
				ping_pong_out_6<=line_data_out_2;
				ping_pong_out_5<=line_data_out_1;
				ping_pong_out_4<=line_data_out_0;
				ping_pong_out_3<=line_data_out_8;
				ping_pong_out_2<=line_data_out_7;
				ping_pong_out_1<=line_data_out_6;				
			when "0101"=>
				wea<="000010000";
				line_data_in_4<=video_data;
				ping_pong_out_8<=line_data_out_3;
				ping_pong_out_7<=line_data_out_2;
				ping_pong_out_6<=line_data_out_1;
				ping_pong_out_5<=line_data_out_0;
				ping_pong_out_4<=line_data_out_8;
				ping_pong_out_3<=line_data_out_7;
				ping_pong_out_2<=line_data_out_6;
				ping_pong_out_1<=line_data_out_5;					
			when "0110"=>
				wea<="000001000";
				line_data_in_3<=video_data;
				ping_pong_out_8<=line_data_out_2;
				ping_pong_out_7<=line_data_out_1;
				ping_pong_out_6<=line_data_out_0;
				ping_pong_out_5<=line_data_out_8;
				ping_pong_out_4<=line_data_out_7;
				ping_pong_out_3<=line_data_out_6;
				ping_pong_out_2<=line_data_out_5;
				ping_pong_out_1<=line_data_out_4;				
			when "0111"=>
				wea<="000000100";
				line_data_in_2<=video_data;
				ping_pong_out_8<=line_data_out_1;
				ping_pong_out_7<=line_data_out_0;
				ping_pong_out_6<=line_data_out_8;
				ping_pong_out_5<=line_data_out_7;
				ping_pong_out_4<=line_data_out_6;
				ping_pong_out_3<=line_data_out_5;
				ping_pong_out_2<=line_data_out_4;
				ping_pong_out_1<=line_data_out_3;					
			when "1000"=>	
				wea<="000000010";
				line_data_in_1<=video_data;
				ping_pong_out_8<=line_data_out_0;
				ping_pong_out_7<=line_data_out_8;
				ping_pong_out_6<=line_data_out_7;
				ping_pong_out_5<=line_data_out_6;
				ping_pong_out_4<=line_data_out_5;
				ping_pong_out_3<=line_data_out_4;
				ping_pong_out_2<=line_data_out_3;
				ping_pong_out_1<=line_data_out_2;					
			when others=>
				wea<=(others=>'0');
				
		end case;
	else
		wea<=(others=>'0');
	end if;

end if;
end process;






process(clk,rst)
begin
if rst='0'then
	ping_pong_state<="0000";
elsif rising_edge(clk)then
	if 	vga_vs_cnt=524 then
		ping_pong_state<="0000";
	elsif  vga_hs_cnt =857 then
		if ping_pong_state="1000" then
			ping_pong_state<="0000";	
		else
			ping_pong_state<=ping_pong_state+"0001";	
		end if;
		
	end if;

end if;
end process;


end Behavioral;