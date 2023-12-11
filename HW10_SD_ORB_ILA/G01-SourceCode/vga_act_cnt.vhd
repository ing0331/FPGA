library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;

-- uncomment the following library declaration if instantiating
-- any xilinx primitives in this code.
--library unisim;
--use unisim.vcomponents.all;

entity vga_act_cnt is
    generic (
        horizontal_resolution : integer :=720 ;--Ëß???êÂ∫¶
        horizontal_front_porch: integer :=  48 ;
        horizontal_sync_pulse : integer := 112 ;
        horizontal_back_porch : integer := 248 ;
        h_sync_polarity         :std_logic:= '1' ;---polarlityÊ•µÊ??
        vertical_resolution   : integer :=480 ;--Ëß???êÂ∫¶
        vertical_front_porch  : integer :=   1 ;
        vertical_sync_pulse   : integer :=   3 ;
        vertical_back_porch   : integer :=  38 ;
        v_sync_polarity         :std_logic:= '1' 
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        video_start_en : in std_logic;
        vga_hs_cnt : out integer;
        vga_vs_cnt : out integer
        -- hsync : out std_logic;
        -- vsync : out std_logic
    );

end vga_act_cnt;

architecture behavioral of vga_act_cnt is

signal vga_hs_cnt_s : integer;
signal vga_vs_cnt_s : integer;

begin

--?Öß?É®Ë®äË?üÊé•?à∞Â§ñÈÉ®----
vga_hs_cnt <= vga_hs_cnt_s;
vga_vs_cnt <= vga_vs_cnt_s;
------------------

--vga_act_cnt h Ë®àÊï∏
h_cnt : process(clk ,rst, vga_hs_cnt_s ,video_start_en)
begin
    if rst = '0' then
         vga_hs_cnt_s <= 0;
    elsif video_start_en = '1' then 
         if rising_edge(clk) then
             if vga_hs_cnt_s < (horizontal_resolution) then-- + horizontal_front_porch + horizontal_sync_pulse + horizontal_back_porch
                 vga_hs_cnt_s <= vga_hs_cnt_s + 1;
             else
                 vga_hs_cnt_s <= 0;
             end if;
         end if;
    else
        vga_hs_cnt_s <= 0;
    end if;
end process;
--vga_act_cnt v Ë®àÊï∏
v_cnt : process(clk , rst , vga_hs_cnt_s ,vga_vs_cnt_s,video_start_en)
begin
    if rst = '0' then
         vga_vs_cnt_s <= 0;
    elsif video_start_en = '1' then 
         if rising_edge(clk) then
              if vga_hs_cnt_s = (horizontal_resolution) then
                  if vga_vs_cnt_s < (vertical_resolution) then
                        vga_vs_cnt_s <= vga_vs_cnt_s + 1;
                  else
                        vga_vs_cnt_s <= 0;
                  end if;
              end if;
         end if;
    else
        vga_vs_cnt_s <= 0;
    end if;
end process;

-- -- h sync
-- h_sync : process(clk , vga_hs_cnt_s,rst,video_start_en)
-- begin
-- if rst = '0' then
    -- hsync <= '1';
-- else
    -- if clk'event and clk = '1' then
        -- if video_start_en = '1' then
            -- if vga_hs_cnt_s >= (horizontal_resolution + horizontal_front_porch) and vga_hs_cnt_s < (horizontal_resolution + horizontal_front_porch + horizontal_sync_pulse) then
                -- hsync <=     h_sync_polarity;
            -- else
                -- hsync <= not h_sync_polarity;
            -- end if;
        -- end if;
    -- end if;
-- end if;
-- end process;

-- -- v sync
-- v_sync : process(clk ,rst,vga_vs_cnt_s,video_start_en)
-- begin
-- if rst = '0' then
    -- vsync <= '1';
-- else
    -- if clk'event and clk = '1' then
        -- if video_start_en = '1' then
            -- if vga_vs_cnt_s >= (vertical_resolution + vertical_front_porch) and vga_vs_cnt_s < (vertical_resolution + vertical_front_porch + vertical_sync_pulse) then
               -- vsync <=     v_sync_polarity;
            -- else       
               -- vsync <= not v_sync_polarity;
            -- end if;
        -- end if;
    -- end if;
-- end if;
-- end process;

end behavioral;


