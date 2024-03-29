library	IEEE;
	use	IEEE.STD_LOGIC_1164.ALL;
	use	IEEE.STD_LOGIC_ARITH.ALL;
	use	IEEE.STD_LOGIC_UNSIGNED.ALL;
	
entity CacheSystem is
	generic (
		DATA_WIDTH	: integer := 8;
		WINDOW_SIZE	: integer := 3;
		ROW_BITS    : integer := 10;  --9
		COL_BITS    : integer := 10;
		NO_OF_ROWS	: integer := 480;
		NO_OF_COLS	: integer := 640 );
	port(
		clk         : in std_logic;
		fsync_in    : in std_logic;
		rsync_in	: in std_logic;
		pdata_in 	: in std_logic_vector(DATA_WIDTH -1 downto 0);
		
		w_col_cnt   : in std_logic_vector(9 downto 0);
		w_row_cnt   : in std_logic_vector(9 downto 0);			 
		
		fsync_out  : out std_logic;       -- to edge_Sobel
		rsync_out  : out std_logic;
		pdata_out1  : out std_logic_vector(DATA_WIDTH -1 downto 0);
		pdata_out2  : out std_logic_vector(DATA_WIDTH -1 downto 0);
		pdata_out3  : out std_logic_vector(DATA_WIDTH -1 downto 0);
		pdata_out4  : out std_logic_vector(DATA_WIDTH -1 downto 0);
		pdata_out5  : out std_logic_vector(DATA_WIDTH -1 downto 0);
		pdata_out6  : out std_logic_vector(DATA_WIDTH -1 downto 0);
		pdata_out7  : out std_logic_vector(DATA_WIDTH -1 downto 0);
		pdata_out8  : out std_logic_vector(DATA_WIDTH -1 downto 0);
		pdata_out9  : out std_logic_vector(DATA_WIDTH -1 downto 0) );
end CacheSystem;

architecture Behavioral of CacheSystem is

	COMPONENT DoubleFiFOLineBuffer is
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
			LBF_out3	: buffer std_logic_vector(DATA_WIDTH -1 downto 0) 			);
	end COMPONENT;
		 
	 COMPONENT SyncSignalsDelayer
		 generic (
			 ROW_BITS  : integer);
		 port(
			 clk : IN  std_logic;
			 fsync_in : IN  std_logic;
			 rsync_in : IN  std_logic;
			 col_count_in : IN std_logic_vector(9 downto 0);
			 row_count_in : IN std_logic_vector(9 downto 0);
			 fsync_out : OUT  std_logic;
			 rsync_out : OUT  std_logic );
	 end component;

	signal RowsCounterOut : STD_LOGIC_VECTOR(9 downto 0);  --ROW_BITS
	signal ColsCounterOut : STD_LOGIC_VECTOR(9 downto 0);  --COL_BITS
	signal dout1	: std_logic_vector(DATA_WIDTH -1 downto 0);
	signal dout2	: std_logic_vector(DATA_WIDTH -1 downto 0);
	signal dout3	: std_logic_vector(DATA_WIDTH -1 downto 0);
	signal fsync_temp, rsync_temp : std_logic := '1';
	
	-- pixel elements caches
	-- |----------------------------------|
	-- | z9-z6-z3 | z8-z5-z2   | z7-z4-z1 |
	-- |----------------------------------|
	-- 23       16|15         8|7         0
	-- shared variable cache1 : std_logic_vector((WINDOW_SIZE*DATA_WIDTH) -1 downto 0);
	-- shared variable cache2 : std_logic_vector((WINDOW_SIZE*DATA_WIDTH) -1 downto 0);
	-- shared variable cache3 : std_logic_vector((WINDOW_SIZE*DATA_WIDTH) -1 downto 0);
	signal cache1 : std_logic_vector((WINDOW_SIZE*DATA_WIDTH) -1 downto 0);
	signal cache2 : std_logic_vector((WINDOW_SIZE*DATA_WIDTH) -1 downto 0);
	signal cache3 : std_logic_vector((WINDOW_SIZE*DATA_WIDTH) -1 downto 0);	
	
begin

	DoubleLineBuffer: DoubleFiFOLineBuffer 
	GENERIC MAP (
		DATA_WIDTH => DATA_WIDTH,
		NO_OF_COLS => NO_OF_COLS )
	PORT MAP (
          clk => clk,
          fsync => fsync_in,
          rsync => rsync_in,
          pdata_in => pdata_in,
          LBF_out1 => dout1,
          LBF_out2 => dout2,
          LBF_out3 => dout3 );
		  
--	  Delayer: SyncSignalsDelayer 
--	  GENERIC MAP (
--		 ROW_BITS => ROW_BITS )
--	  PORT MAP (
--           clk => clk,
--           fsync_in => fsync_in,
--           rsync_in => rsync_in,
--           col_count_in => w_col_cnt,
--           row_count_in => w_row_cnt,
--           fsync_out => fsync_temp,
--           rsync_out => rsync_temp);
		  
	RowsCounterOut <= w_col_cnt;
	ColsCounterOut <= w_row_cnt;
	
--    fsync_temp <= fsync_in;   
	fsync_out <= fsync_in; 	--fsync_temp;
	rsync_out <= '0' when w_row_cnt >= NO_OF_ROWS --and w_row_cnt < NO_OF_ROWS + 2	
	else '1';
	
	
	padding_Process : process (clk)
	begin
		if clk'event and clk='1' then
				-- the pixel in the middle part is copied into the low part
				cache1(DATA_WIDTH -1 downto 0)<=cache1(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-2)*DATA_WIDTH) );
				cache2(DATA_WIDTH -1 downto 0)<=cache2(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-2)*DATA_WIDTH) );
				cache3(DATA_WIDTH -1 downto 0)<=cache3(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-2)*DATA_WIDTH) );
				-- the pixel in the high part is copied into the middle part
				cache1(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-2)*DATA_WIDTH) )<=cache1((WINDOW_SIZE*DATA_WIDTH) -1 downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
				cache2(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-2)*DATA_WIDTH) )<=cache2((WINDOW_SIZE*DATA_WIDTH) -1 downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
				cache3(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-2)*DATA_WIDTH) )<=cache3((WINDOW_SIZE*DATA_WIDTH) -1 downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
				-- the output of the ram is put in the high part of the variable
				cache1((WINDOW_SIZE*DATA_WIDTH) -1 downto ((WINDOW_SIZE-1)*DATA_WIDTH) )<=dout1;
				cache2((WINDOW_SIZE*DATA_WIDTH) -1 downto ((WINDOW_SIZE-1)*DATA_WIDTH) )<=dout2;
				cache3((WINDOW_SIZE*DATA_WIDTH) -1 downto ((WINDOW_SIZE-1)*DATA_WIDTH) )<=dout3;			
		end if; -- clk
	end process padding_Process;
	
	EmittingProcess : process (RowsCounterOut,ColsCounterOut,fsync_temp)
	begin
		if fsync_temp = '1' then 
			if RowsCounterOut="0000000000" and ColsCounterOut="0000000000" then --1
				pdata_out1<= (others => '0');
				pdata_out2<= (others => '0');
				pdata_out3<= (others => '0');
				pdata_out4<= (others => '0');
				pdata_out5<= cache2(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-2)*DATA_WIDTH) );
				pdata_out6<= cache2(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) ); 
				pdata_out7<= (others => '0');
				pdata_out8<= cache1(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-2)*DATA_WIDTH) );
				pdata_out9<= cache1(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
				
				-- counter2>0 and counter2<639
			elsif RowsCounterOut="0000000000" and ColsCounterOut>"0000000000" and ColsCounterOut<"1001111111" then --2
				pdata_out1<= (others => '0');	
				pdata_out2<= (others => '0');
				pdata_out3<= (others => '0');
				pdata_out4<= cache2((DATA_WIDTH - 1) downto 0 ); 
				pdata_out5<= cache2(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
				pdata_out6<= cache2(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
				pdata_out7<= cache1((DATA_WIDTH - 1) downto 0 );
				pdata_out8<= cache1(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
				pdata_out9<= cache1(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
				
				-- counter2=639
			elsif RowsCounterOut="0000000000" and ColsCounterOut="1001111111" then --3
				pdata_out1<= (others => '0');	
				pdata_out2<= (others => '0');	
				pdata_out3<= (others => '0');	
				pdata_out4<= cache2((DATA_WIDTH - 1) downto 0 ); 
				pdata_out5<= cache2(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
				pdata_out6<= (others => '0');	
				pdata_out7<= cache1((DATA_WIDTH - 1) downto 0 );
				pdata_out8<= cache1(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
				pdata_out9<= (others => '0');
				
				-- row>0 and row<479
			elsif RowsCounterOut>"0000000000" and RowsCounterOut<"0111011111" and ColsCounterOut="0000000000" then --4
				pdata_out1<= (others => '0');	
				pdata_out2<= cache3(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
				pdata_out3<= cache3(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
				pdata_out4<= (others => '0');	
				pdata_out5<= cache2(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
				pdata_out6<= cache2(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
				pdata_out7<= (others => '0');	
				pdata_out8<= cache1(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
				pdata_out9<= cache1(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
				
				-- row>0 and row<479 and counter2>0 and counter2<639
			elsif RowsCounterOut>"0000000000" and RowsCounterOut<"0111011111" and ColsCounterOut>"0000000000" and ColsCounterOut<"1001111111" then --5
				pdata_out1<= cache3((DATA_WIDTH - 1) downto 0 );	
				pdata_out2<= cache3(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
				pdata_out3<= cache3(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
				pdata_out4<= cache2((DATA_WIDTH - 1) downto 0 );
				pdata_out5<= cache2(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
				pdata_out6<= cache2(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
				pdata_out7<= cache1((DATA_WIDTH - 1) downto 0 );	
				pdata_out8<= cache1(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
				pdata_out9<= cache1(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
				
				-- row>0 and row<479 and counter2>0 and counter2=639
			elsif RowsCounterOut>"0000000000" and RowsCounterOut<"0111011111" and ColsCounterOut="1001111111" then --6
				pdata_out1<= cache3((DATA_WIDTH - 1) downto 0 );
				pdata_out2<= cache3(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
				pdata_out3<= (others => '0');
				pdata_out4<= cache2((DATA_WIDTH - 1) downto 0 );
				pdata_out5<= cache2(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
				pdata_out6<= (others => '0');
				pdata_out7<= cache1((DATA_WIDTH - 1) downto 0 );
				pdata_out8<= cache1(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
				pdata_out9<= (others => '0');
				
				-- row=479 and counter2=0
			elsif RowsCounterOut="0111011111" and ColsCounterOut="0000000000" then --7
				pdata_out1<= (others => '0');
				pdata_out2<= cache3(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
				pdata_out3<= cache3(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
				pdata_out4<= (others => '0');
				pdata_out5<= cache2(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
				pdata_out6<= cache2(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
				pdata_out7<= (others => '0');	
				pdata_out8<= (others => '0');
				pdata_out9<= (others => '0');
				
				-- row=479 and counter2>0 and counter2<639
			elsif RowsCounterOut="0111011111" and ColsCounterOut>"0000000000" and ColsCounterOut<"1001111111" then --8
				pdata_out1<= cache3((DATA_WIDTH - 1) downto 0 );
				pdata_out2<= cache3(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
				pdata_out3<= cache3(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
				pdata_out4<= cache2((DATA_WIDTH - 1) downto 0 );
				pdata_out5<= cache2(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
				pdata_out6<= cache2(((WINDOW_SIZE)*DATA_WIDTH - 1) downto ((WINDOW_SIZE-1)*DATA_WIDTH) );
				pdata_out7<= (others => '0');
				pdata_out8<= (others => '0');
				pdata_out9<= (others => '0');
				
				-- row=479 and counter2=639
			elsif RowsCounterOut="0111011111" and ColsCounterOut="1001111111" then --9
				pdata_out1<= cache3((DATA_WIDTH - 1) downto 0 );
				pdata_out2<= cache3(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
				pdata_out3<= (others => '0');
				pdata_out4<= cache2((DATA_WIDTH - 1) downto 0 );
				pdata_out5<= cache2(((WINDOW_SIZE-1)*DATA_WIDTH - 1) downto DATA_WIDTH );
				pdata_out6<= (others => '0');
				pdata_out7<= (others => '0');
				pdata_out8<= (others => '0');
				pdata_out9<= (others => '0');
            else
                 pdata_out1<=(others => '0') ;
                 pdata_out2<=(others => '0') ;
                 pdata_out3<=(others => '0') ;
                 pdata_out4<=(others => '0') ;
                 pdata_out5<=(others => '0') ;
                 pdata_out6<=(others => '0') ;
                 pdata_out7<=(others => '0') ;
                 pdata_out8<=(others => '0') ;
                 pdata_out9<=(others => '0') ;
				
			end if; -- RowsCounterO_ouut and ColsCounterOut
		end if; --rsync_temp	   
	end process EmittingProcess; 
	
end Behavioral;

