library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY counter_dec_test IS
END counter_dec_test;
 
ARCHITECTURE behavior OF counter_dec_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT counter_dec
    PORT(
         reset : IN  std_logic;
         clock : IN  std_logic;
         sel : IN  std_logic;
         counter_output : OUT  std_logic_vector(3 downto 0);
	   	out_segment : out STD_LOGIC_VECTOR (6 downto 0) );
    END COMPONENT;
    
   --Inputs
   signal reset : std_logic := '0';
   signal clock : std_logic := '0';
   signal sel : std_logic := '0';

 	--Outputs
   signal counter_output : std_logic_vector(3 downto 0);
    signal out_segment : STD_LOGIC_VECTOR (6 downto 0);


   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
	-- Instantiate the Unit Under Test (UUT)
   uut: counter_dec PORT MAP (
          reset => reset,
          clock => clock,
          sel => sel,
          counter_output => counter_output,
	      out_segment => out_segment
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;

	-- Stimulus process
   stim_proc: process
   begin		
      -- hold reset stat
      wait for 20 ns;	
		reset <= '1';

      wait for 220 ns;	
		sel <= '1';

      wait for clock_period*10;

      -- insert stimulus here 
		
      wait;
   end process;

END;
