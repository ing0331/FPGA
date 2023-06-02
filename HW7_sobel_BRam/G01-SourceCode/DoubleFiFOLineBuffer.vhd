library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DoubleFiFOLineBuffer is
generic (
		DATA_WIDTH	: integer := 8;
		NO_OF_COLS	: integer := 640 );
	port(
		clk 		   : in std_logic;
		fsync   		: in std_logic;
		rsync			: in std_logic;
		pdata_in 	: in std_logic_vector(DATA_WIDTH -1 downto 0);
		LBF_out1	: out std_logic_vector(DATA_WIDTH -1 downto 0);
		LBF_out2	: buffer std_logic_vector(DATA_WIDTH -1 downto 0);
		LBF_out3	: buffer std_logic_vector(DATA_WIDTH -1 downto 0) );
end DoubleFiFOLineBuffer;

architecture Behavioral of DoubleFiFOLineBuffer is

	component FIFOLineBuffer is
	generic (
        DATA_WIDTH	: integer := 8;
        NO_OF_COLS	: integer := 640 );
	port(
		clk 		   : in std_logic;
		fsync   		: in std_logic;
		rsync			: in std_logic;
		pdata_in 	: in std_logic_vector(DATA_WIDTH -1 downto 0);
		pdata_out	: buffer std_logic_vector(DATA_WIDTH -1 downto 0));
	end component;
	
begin

	LineBuffer1 : FIFOLineBuffer 
	generic map (DATA_WIDTH => DATA_WIDTH, NO_OF_COLS => NO_OF_COLS) 
    port map(
        clk      => clk, 
        fsync    => fsync,
        rsync    => rsync,
        pdata_in => pdata_in, 
        pdata_out => LBF_out2);
										  
	LineBuffer2 : FIFOLineBuffer 
	generic map (DATA_WIDTH => DATA_WIDTH, NO_OF_COLS => NO_OF_COLS) 
    port map(
        clk      => clk, 
        fsync    => fsync,
        rsync    => rsync,
        pdata_in => LBF_out2, 
        pdata_out => LBF_out3 );    
	LBF_out1 <= pdata_in;
	
end Behavioral;
