library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
	use	IEEE.STD_LOGIC_ARITH.ALL;
	use	IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SyncSignalsDelayer is
	generic (
		ROW_BITS	   : integer := 10 );
	port(
			clk : in std_logic;
			fsync_in : in std_logic;
			rsync_in : in std_logic;
			col_count_in : in std_logic_vector(9 downto 0);
			row_count_in : in std_logic_vector(9 downto 0);
			fsync_out : out std_logic;
			rsync_out : out std_logic );
end SyncSignalsDelayer;

architecture Behavioral of SyncSignalsDelayer is

	signal rowsDelayCounterRising : std_logic_vector(9 downto 0);
	signal rowsDelayCounterFalling : std_logic_vector(9 downto 0);
	signal rsync2 : std_logic;
	signal rsync1 : std_logic;
	signal fsync_temp : std_logic;
	
--	COMPONENT Counter is
--		 generic (n : POSITIVE);
--		 Port ( clk : in  STD_LOGIC;
--				  en : in  STD_LOGIC;
--				  reset : in  STD_LOGIC;			-- Active Low
--				  output : out  STD_LOGIC_VECTOR(n-1 downto 0));
--	end COMPONENT;

-- component Sync_To_Count is
--   generic (
--     g_TOTAL_COLS : integer;
--     g_TOTAL_ROWS : integer
--     );
--   port (
--     i_Clk   : in std_logic;
--     i_HSync : in std_logic;
--     i_VSync : in std_logic;
--     o_HSync     : out std_logic;
--     o_VSync     : out std_logic;
--     o_Col_Count : out std_logic_vector(9 downto 0);
--     o_Row_Count : out std_logic_vector(9 downto 0)
--     );
-- end component Sync_To_Count;

begin
	-- Step 2
--	RowsCounteComp : Counter generic map(ROW_BITS) 
-- port map(rsync2, fsync_in,fsync_in,rowsDelayCounterRising);
	rowsDelayCounterRising <= row_count_in;
	
-- Step 1
p1 : process(clk)
begin
	if clk'event and clk='1' then
		-- Step 1 - delay of two clock cycles
		rsync1 <= rsync_in;
		rsync2 <= rsync1;
	end if;
end process p1;

-- Steps 3 and 5
p2 : process(rowsDelayCounterRising)
begin
	-- rows2 = 2
	if rowsDelayCounterRising = "0000000010" then
		fsync_temp <= '1';
	elsif rowsDelayCounterFalling = "0000000000" then
		fsync_temp <= '0';
    else
        fsync_temp <= fsync_temp;
	end if;
end process p2;

	rsync_out <= rsync2;
	fsync_out <= fsync_temp;

-- Step 4
p3 : process(rsync2, rowsDelayCounterFalling)
begin
	if rsync2'event and rsync2 = '0' then
		if fsync_temp = '1' then
			-- 479
			if rowsDelayCounterFalling < "111011111" then
				rowsDelayCounterFalling <= rowsDelayCounterFalling + 1;
			else
				rowsDelayCounterFalling <= (others => '0');
			end if;
		else
			rowsDelayCounterFalling <= (others => '0');
		end if;
	end if;
end process p3;

end Behavioral;
