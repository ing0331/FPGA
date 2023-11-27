1- write a top module(input video_gray_out(7 downto 0), output delay_video_data(7 downto 0)) to component below block ram;
2- write a VHDL test bench for simulate, video_gray_out is upcount 
blk_mem_gen_345600_0: blk_mem_gen_345600
image_cnt345600 upcount with each clk in the top module

    port map
    (
    clka  => video_clk,
    ena   => '1',
    wea   => "1",
    addra => image_cnt345600,
    dina  => video_gray_out,
    clkb  => video_clk,
    enb   => '1',
    addrb => image_cnt345600,
    doutb => delay_video_data
    );
	
	library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top_module is
    Port ( video_gray_out : in  STD_LOGIC_VECTOR(7 downto 0);
           delay_video_data : out STD_LOGIC_VECTOR(7 downto 0));
end top_module;

architecture Behavioral of top_module is
    signal video_clk : STD_LOGIC;
    signal image_cnt345600 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0'; -- Assuming 32-bit address
    signal video_clkb : STD_LOGIC;
	component blk_mem_gen_345600
    port(
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clkb : IN STD_LOGIC;
        enb : IN STD_LOGIC;
        addrb : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
end component;
begin
    -- Instantiate the block RAM component
    blk_mem_gen_345600_inst : blk_mem_gen_345600
        port map
        (
            clka  => video_clk,
            ena   => '1',
            wea   => "1",
            addra => image_cnt345600,
            dina  => video_gray_out,
            clkb  => video_clkb,
            enb   => '1',
            addrb => image_cnt345600,
            doutb => delay_video_data
        );
    process(video_clk)
    begin
        if rising_edge(video_clk) then
            image_cnt345600 <= image_cnt345600 + 1;
        end if;
    end process;

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_top_module is
end tb_top_module;

architecture testbench of tb_top_module is
    signal video_gray_out_tb : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal delay_video_data_tb : STD_LOGIC_VECTOR(7 downto 0);

    signal video_clk_tb : STD_LOGIC := '0';
    signal image_cnt345600_tb : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal video_clkb_tb : STD_LOGIC := '0';

    constant clock_period : time := 10 ns; -- Adjust as needed

begin
    -- Instantiate the DUT (Design Under Test)
    uut : entity work.top_module
        port map
        (
            video_gray_out => video_gray_out_tb,
            delay_video_data => delay_video_data_tb
        );

    -- Provide clock signal
    process
    begin
        wait for clock_period / 2;
        video_clk_tb <= not video_clk_tb;
    end process;

    -- Stimulus process
    stimulus : process
    begin
        -- Generate an up-counting sequence for video_gray_out_tb
        for i in 0 to 255 loop
            video_gray_out_tb <= std_logic_vector(to_unsigned(i, 8));

            -- Wait for a clock cycle
            wait for clock_period;
        end loop;

        -- End simulation
        wait;

    end process;

end testbench;
