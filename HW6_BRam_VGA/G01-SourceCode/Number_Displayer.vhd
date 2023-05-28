library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Number_Displayer is
	generic (
			DATA_WIDTH	: integer := 8;
			COL_BITS	: integer := 10 );
	port(
		  clk : in  STD_LOGIC;
		  fsync_in : in  STD_LOGIC;
		  rsync_in : in  STD_LOGIC;
		  col_count : in STD_LOGIC_VECTOR(9 downto 0);
		  row_count : in STD_LOGIC_VECTOR(9 downto 0);	  
		  
		  pos_row : in STD_LOGIC_VECTOR(COL_BITS-1 downto 0);
		  pos_col : in STD_LOGIC_VECTOR(COL_BITS-1 downto 0);
		  score1 : in STD_LOGIC_VECTOR(3 downto 0);		  
		  score2 : in STD_LOGIC_VECTOR(3 downto 0);
		  fsync_out : out  STD_LOGIC;
		  rsync_out : out  STD_LOGIC;
		  data_out : out  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) );
	end Number_Displayer;

architecture Behavioral of Number_Displayer is 
	constant NUMBERS_DIM : integer := 8;
	component Num_Rom is
	port(
			en : in STD_LOGIC;		--'1'
			address : in STD_LOGIC_VECTOR(6 downto 0);
			rd : in STD_LOGIC;		--'1'
			data_out : out STD_LOGIC_VECTOR(0 to NUMBERS_DIM-1) );
	end component;

	signal RowsCounterOut,ColsCounterOut : STD_LOGIC_VECTOR(COL_BITS-1 downto 0);
	signal rowLUT : STD_LOGIC_VECTOR(COL_BITS-1 downto 0) := (others => '0');
	signal colLUT : STD_LOGIC_VECTOR(COL_BITS-1 downto 0) := (others => '0');
	signal FontDataOut : STD_LOGIC_VECTOR(0 to NUMBERS_DIM-1);
	signal FontAddress : STD_LOGIC_VECTOR(6 downto 0);

begin

	RowsCounterOut <= row_count;
	ColsCounterOut <= col_count;
	LUTFont : Num_Rom 
	port map(
		en => '1',
		address => FontAddress,
		rd => '1',
		data_out => FontDataOut
		);
	
	fsync_out <= fsync_in;
	rsync_out <= rsync_in;
	
process(RowsCounterOut,ColsCounterOut,pos_row,pos_col,score1, score2)
begin			
    -- if rising_edge(clk) then
		-- score1
		if(RowsCounterOut >= pos_row and RowsCounterOut <= (pos_row+7) and ColsCounterOut >= (pos_col-1) and ColsCounterOut <= (pos_col+7-1)) then  
			rowLUT <= (RowsCounterOut - pos_row);
			colLUT <= (ColsCounterOut - (pos_col-'1'));
			FontAddress <= (score1 & rowLUT(2 downto 0));
			data_out <= (others => FontDataOut(conv_integer(colLUT(2 downto 0))));
		-- .
		elsif(RowsCounterOut >= pos_row and RowsCounterOut <= (pos_row+7) and ColsCounterOut >= (pos_col+8-1) and ColsCounterOut <= (pos_col+15-1)) then  
			rowLUT <= (RowsCounterOut - pos_row);
			colLUT <= (ColsCounterOut - (pos_col+"0111"));
			FontAddress <= ("1111" & rowLUT(2 downto 0));
			data_out <= (others => FontDataOut(conv_integer(colLUT(2 downto 0))));
		-- score2
		elsif(RowsCounterOut >= pos_row and RowsCounterOut <= (pos_row+7) and ColsCounterOut >= (pos_col+16-1) and ColsCounterOut <= (pos_col+23-1)) then   
			rowLUT <= (RowsCounterOut - pos_row);
			colLUT <= (ColsCounterOut - (pos_col+"1111"));
			FontAddress <= (score2 & rowLUT(2 downto 0));
			data_out <= (others => FontDataOut(conv_integer(colLUT(2 downto 0))));
		-- Original Image
		else
			FontAddress <= (others => '0'); -- Only to not make infer a latch
			data_out <= (others => '0');		--data_in
		end if;
    -- end if;    
end process;
end Behavioral;
