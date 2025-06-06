LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use std.textio.all;
use work.Utilities.ALL;
 
ENTITY TB_debouncer IS
END TB_debouncer;
 
ARCHITECTURE sim OF TB_debouncer IS 
	-- User Parameters
	constant CLOCK_PEROID : time := 40 ns;
	constant WAIT_TIME : time := 20 ms;
	constant SAMPLE_COUNT : positive := 1;
	
	
	constant SEED1 : positive := 12345;  -- initial seeds 1
	constant SEED2 : positive := 12345;  -- initial seeds 2
		
	-- Component Declaration for the Unit Under Test (UUT)
	component debouncer is
		port (
			i_reset 			: in std_logic;
			i_clk 				: in std_logic;
			i_button 			: in std_logic;
			o_debouncedButton 	: out std_logic
		);
	end component;
	
	file bitsFile : text open read_mode is "random01.txt";
		
	--Input
	signal clk : std_logic := '0';
	signal reset : std_logic := '0';
	signal button : std_logic := '0';
	
	--Output
	signal debouncedButton : std_logic;
	
	signal endOfSimulation : boolean := false;
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: debouncer
	PORT MAP (
		i_clk 				=> clk,
		i_reset 			=> reset,
		i_button 			=> button,
		o_debouncedButton 	=> debouncedButton
	);

	
	clk_proc:
	process
	begin
		wait for CLOCK_PEROID/2;
		clk <= not clk;
	end process;
	
	driveInputs_proc:
	process
		variable sampleCounter : natural := 0;
		
		variable seed1_var : integer := seed1;
		variable seed2_var : integer := seed2;
		variable waitTime : INTEGER;
		variable bounceCount : INTEGER;
	begin
		while sampleCounter < SAMPLE_COUNT loop
			wait for CLOCK_PEROID;
			
			button <= readSLV(bitsFile, 1)(0);
			
			randomInteger(waitTime, 20, 100, seed1_var, seed2_var);
			wait for waitTime * 1 ms;
			
			randomInteger(bounceCount, 0, 10, seed1_var, seed2_var);
			for i in 0 to bounceCount loop
				button <= not button;
				
				randomInteger(waitTime, 0, 15, seed1_var, seed2_var);
				wait for waitTime * 1 ms;
			end loop;

			sampleCounter := sampleCounter + 1;
		end loop;
		
		endOfSimulation <= true;
		wait;
	end process;

	checkOutputs_proc:
	process
		variable errorCount : natural := 0;
		variable currentSampleError : boolean := false;
		
		variable lastEventTime : time := 0 ns;
		variable lastButton : std_logic;
		variable calculatedDebouncedButton : std_logic;
	begin		
		loop
			wait until rising_edge(clk);
			
			currentSampleError := false;
			calculatedDebouncedButton := button;
			
			wait until falling_edge(clk);
			if (now - lastEventTime) > WAIT_TIME then
				if button /= lastButton then
					if calculatedDebouncedButton /= debouncedButton then
						errorCount := errorCount + 1;
						currentSampleError := true;
					end if;
					
					lastEventTime := now;
				end if;
				lastButton := button;
			end if;
				
			if currentSampleError then
				report "Invalid result:"
					& " <-{button=" & tostr(button)
					& "}, ->{[Debounced Button=" & tostr(debouncedButton) & "], [Expected Debounced Button=" & tostr(calculatedDebouncedButton) & "]"
					& "}"
					severity warning;
			end if;
			
			if endOfSimulation then
				report "Number of invalid results: " & tostr(errorCount);
				EndSim;
			end if;
		end loop;
	end process;
END;
