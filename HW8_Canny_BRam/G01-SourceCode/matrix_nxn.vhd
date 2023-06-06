library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.pkg.all;
use work.const_def.all;

entity matrix_nxn is
    generic(
        ksize : integer;
        data_bits : integer range 0 to 11 := 11
    );    
    port (
        i_clk    :    in STD_LOGIC;
        i_rst    :    in STD_LOGIC;
        i_enable :    in STD_LOGIC;
        i_data   :    in STD_LOGIC_VECTOR(data_bits-1 downto 0);
        o_data   : inout out_matrix(0 to (ksize-1) , 0 to (ksize-1))
    );
end matrix_nxn;

architecture Behavioral of matrix_nxn is
component FIFO_RTL is
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
end component;
type arr          is array((ksize-1) downto 0) of std_logic;
type arr_vector   is array((ksize-1) downto 0) of std_logic_vector(data_bits - 1 downto 0);
signal col_ena: std_logic;
signal cnt_col : integer range 0 to img_height;
signal cnt_row : integer range 0 to img_width;
signal first      : integer range 0 to ksize;
signal pop_en,rd_en,wr_en ,full,empty                 : arr;
signal fifo_out ,fifo_in:arr_vector;

begin
gen : for j in ksize-1 downto 0 generate
    fifo: FIFO_RTL
        generic map(
            g_WIDTH  => data_bits,
            g_DEPTH  => img_width+100
        )
        port map(
            i_clk   =>  i_clk,
            i_rst   =>  i_rst,                
            i_wr_en =>  wr_en(j),
            i_rd_en =>  rd_en(j),
            i_data  =>  fifo_in(j),
            o_data  =>  fifo_out(j),
            o_full  =>  full(j),
            o_empty =>  empty(j)
        );
end generate;
row_cnt :process(i_clk,i_rst,i_enable , cnt_row , first)
begin
    if  i_rst = '1' then
        cnt_row     <= 0;
        col_ena     <= '0';
        first       <= 0;
    elsif i_enable = '1' and rising_edge(i_clk)then
        if cnt_row = img_width-1 then 
            cnt_row <= 0;
            col_ena <= '1';
        else
            cnt_row <= cnt_row + 1;
            col_ena <= '0';
        end if;
        if cnt_row = img_width-1 and first < ksize then 
            first <= first + 1;
        end if;
    end if;
end process;
col_cnt :process(i_clk,i_rst,col_ena,i_enable)
begin
    if  i_rst = '1' then
        cnt_col     <= 0;
    elsif i_enable = '1' and rising_edge(i_clk) and col_ena = '1' then
        if cnt_col = img_height -1 then 
            cnt_col <= 0;
        else
            cnt_col <= cnt_col + 1;
        end if;
    end if;
end process;
fifo_judge     :process(i_data,i_rst,first,i_enable,wr_en,rd_en,pop_en,fifo_out)
begin
    for j in 0 to (ksize-1) loop
        if j = 0 then
            fifo_in(j) <= i_data;
            wr_en(j) <= i_enable;
        else
            fifo_in(j) <= fifo_out(j-1);
            wr_en(j) <= rd_en(j-1);
        end if;
    rd_en(j) <= wr_en(j) and pop_en(j);
    end loop;
end process;
pop_process : process(i_rst , i_clk , first)
begin
    if i_rst = '1' then
        pop_en<= (others=>'0');
    elsif rising_edge(i_clk) and i_enable = '1' then
        if first > 0 then
            pop_en(first-1 downto 0 ) <= (others => '1');
        end if;
    end if;
end process;
o_data_out  :process(i_clk,i_rst,cnt_col,cnt_row,i_enable,empty)
begin
    if i_rst = '1' then
        o_data <= (others => (others => ( others => '0')));
    elsif rising_edge(i_clk)then
        for index_col in 0 to (ksize-1) loop
            for index_row in 0 to (ksize-1) loop
                if to_integer(unsigned(empty)) = 0 then
                    if index_row = (ksize-1) then       -- fifo_data                        
                        o_data(index_col , index_row)(data_bits - 1 downto 0) <= fifo_out((ksize-1) - index_col);
                    else
                        o_data(index_col , index_row) <= o_data(index_col , index_row + 1);                                              
                    end if;
                end if;
            end loop;
        end loop;
    end if;
 end process;

end Behavioral;
