library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity FIFO_RTL is
    generic (
        g_WIDTH : integer;
        g_DEPTH : integer
    );
    port (
        i_rst   :  in STD_LOGIC;
        i_clk   :  in STD_LOGIC;   
        i_wr_en :  in STD_LOGIC;    
        i_rd_en :  in STD_LOGIC;
        i_data  :  in STD_LOGIC_VECTOR(g_WIDTH-1 downto 0);
        o_data  : out STD_LOGIC_VECTOR(g_WIDTH-1 downto 0);
        o_full  : out STD_LOGIC;    
        o_empty : out STD_LOGIC
    ); 
end FIFO_RTL;

architecture rtl of FIFO_RTL is
  type t_FIFO_DATA is array (0 to g_DEPTH-1) of std_logic_vector(g_WIDTH-1 downto 0);
  signal r_FIFO_DATA : t_FIFO_DATA ;
  
  
  signal r_WR_INDEX   : integer range 0 to g_DEPTH-1 ;
  signal r_RD_INDEX   : integer range 0 to g_DEPTH-1 ;
 
  -- # Words in FIFO, has extra range to allow for assert conditions
  signal r_FIFO_COUNT : integer range -1 to g_DEPTH+1 ;
 
  signal w_FULL  : std_logic;
  signal w_EMPTY : std_logic;
   
begin
 
  p_CONTROL : process (i_clk,i_rst,i_rd_en,i_wr_en,w_FULL,w_EMPTY,i_data) is
  begin
    if rising_edge(i_clk) then
      if i_rst = '1' then
        r_FIFO_COUNT <= 0;
        r_WR_INDEX   <= 0;
        r_RD_INDEX   <= 0;
      else 
        -- Keeps track of the total number of words in the FIFO
        if (i_wr_en = '1' and i_rd_en = '0') then
          r_FIFO_COUNT <= r_FIFO_COUNT + 1;
        elsif (i_wr_en = '0' and i_rd_en = '1') then
          r_FIFO_COUNT <= r_FIFO_COUNT - 1;
        end if; 
        -- Keeps track of the write index (and controls roll-over)
        if (i_wr_en = '1' and w_FULL = '0') then
          if r_WR_INDEX = g_DEPTH-1 then
            r_WR_INDEX <= 0;
          else
            r_WR_INDEX <= r_WR_INDEX + 1;
          end if;
        end if; 
        -- Keeps track of the read index (and controls roll-over)        
        if (i_rd_en = '1' and w_EMPTY = '0') then
          if r_RD_INDEX = g_DEPTH-1 then
            r_RD_INDEX <= 0;
          else
            r_RD_INDEX <= r_RD_INDEX + 1;
          end if;
        end if; 
        -- Registers the input data when there is a write
        if i_wr_en = '1' then        
            r_FIFO_DATA(r_WR_INDEX) <= i_data;
        end if;
      end if;                           -- sync reset
    end if;                             -- rising_edge(i_clk)    
  end process p_CONTROL;
out_process : process(i_clk,i_rd_en,r_RD_INDEX,r_FIFO_DATA)
begin
    if i_rd_en = '1' then
        o_data <= r_FIFO_DATA(r_RD_INDEX);
    else
        o_data <= (others => '0');
    end if;
end process;
   
w_FULL  <= '1' when r_FIFO_COUNT = g_DEPTH else '0';
w_EMPTY <= '1' when r_FIFO_COUNT = 0       else '0';

o_full  <= w_FULL;
o_empty <= w_EMPTY;
end rtl;