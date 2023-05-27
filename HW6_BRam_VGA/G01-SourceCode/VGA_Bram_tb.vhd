library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VGA_Bram_tb is
--  Port ( );
end VGA_Bram_tb;

architecture Behavioral of VGA_Bram_tb is
	COMPONENT VGA_Bram_top
	  port (
	  clock     : in std_logic;    --100M Hz
	  rst : in std_logic;
	  ---
	  btn1 : in std_logic_vector(1 downto 0);        --up, down
	  btn2 : in std_logic_vector(1 downto 0);
	  o_VGA_HSync : out std_logic;
	  o_VGA_VSync : out std_logic;
	  o_VGA_Red  : out std_logic_vector(2 downto 0);
	  o_VGA_Grn  : out std_logic_vector(2 downto 0);
	  o_VGA_Blu  : out std_logic_vector(1 downto 0)
	  );
   end component VGA_Bram_top;
--Inputs
 signal rst : std_logic := '0';
 signal clock : std_logic := '0';
 signal btn1 : std_logic_vector(1 downto 0) := "01";        --up, down
 signal btn2 : std_logic_vector(1 downto 0) := "01";
     --Outputs
 signal HSync         : std_logic;
 signal VSync         : std_logic;
 signal o_Red_Video   : std_logic_vector(2 downto 0);
 signal o_Grn_Video   : std_logic_vector(2 downto 0);
 signal o_Blu_Video   : std_logic_vector(1 downto 0);
 constant clock_period : time := 10 ns;
    
begin
uut: VGA_Bram_top
 PORT MAP (
   -- Main Clock (100 MHz)
   clock       => clock,
   rst         => rst,
   btn1        => btn1,
   btn2        => btn2,
   -- VGA      
   o_VGA_HSync => HSync,
   o_VGA_VSync => VSync,
   o_VGA_Red   => o_Red_Video,
   o_VGA_Grn   => o_Grn_Video,
   o_VGA_Blu   => o_Blu_Video
   );
   -- Clock process definitions
clock_process :process
begin
    clock <= '0';
    wait for clock_period/2;
    clock <= '1';
    wait for clock_period/2;
end process;

    rst <= '1' after 20ns;
    btn1 <= "01" after 50ms;    
	btn2 <= "10" after 50ms;
--    btn2 <= "01" after 30ms;
---- Stimulus process
--stim_proc: process
--begin
----  wait for 20 ns;    
----    btn2 <= "01";

--  -- insert stimulus here 
--  -- wait;
--end process;

end Behavioral;
