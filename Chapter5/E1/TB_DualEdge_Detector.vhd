LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use std.textio.all;
use work.Utilities.ALL;
 
ENTITY TB_DualEdge_Detector IS
END TB_DualEdge_Detector;
 
ARCHITECTURE sim OF TB_DualEdge_Detector IS 
	type modules_T is (Moor, Mealy);

	-- User Parameters
	constant MODULE : modules_T := Mealy;
	constant SAMPLE_COUNT : positive := 100;
	constant CLOCK_PEROID : time := 10 ns;
		
	-- Component Declaration for the Unit Under Test (UUT)
	component DualEdge_Detector_Moor is
		port (
			i_clk 		: in std_logic;
			i_input 	: in std_logic;
			o_output 	: out std_logic
		);
	end component;
	
	component DualEdge_Detector_Mealy is
		port (
			i_clk 		: in std_logic;
			i_input 	: in std_logic;
			o_output 	: out std_logic
		);
	end component;
	
	file bitsFile : text open read_mode is "random01.txt";
	
	--Input
	signal clk : std_logic := '0';
	signal input : std_logic := '0';
	
	--Output
	signal output : std_logic;
	
	signal sampleCounter : natural := 0;
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	chooseModule:
	if MODULE = Moor generate
		uut: DualEdge_Detector_Moor
		PORT MAP (
			i_clk 		=> clk,
			i_input 		=> input,
			o_output 	=> output
		);
	elsif MODULE = Mealy generate
		uut: DualEdge_Detector_Mealy
		PORT MAP (
			i_clk 		=> clk,
			i_input 	=> input,
			o_output 	=> output
		);
	end generate;
	
	clk_proc:
	process
	begin
		wait for CLOCK_PEROID/2;
		clk <= not clk;
	end process;
	
	driveInputs_proc:
	process
	begin
		while sampleCounter < SAMPLE_COUNT loop
			wait for CLOCK_PEROID;
			
			input <= readSLV(bitsFile, 1)(0);

			sampleCounter <= sampleCounter + 1;
		end loop;
		
		EndSim;
	end process;

	checkOutputs_proc:
	process
		variable errorCount : natural := 0;
		variable currentSampleError : boolean := false;

		variable lastInput : std_logic := '0';
		variable calculatedOutput : std_logic;
	begin		
		loop
			wait until rising_edge(clk);
			
			currentSampleError := false;
			calculatedOutput := ((not lastInput) and input) or (lastInput and (not input));
			
			lastInput := input;
			
			wait until falling_edge(clk);
			
			if calculatedOutput /= output then
				errorCount := errorCount + 1;
				currentSampleError := true;
			end if;
			
			if currentSampleError then
				report "Invalid result:"
					& " <-{input=" & tostr(input)
					& "}, ->{lastInput=" & tostr(lastInput)
					& "}, ->{[output=" & tostr(output) & "], [Expected output=" & tostr(calculatedOutput) & "]"
					& "}"
					severity warning;
			end if;
			
			if sampleCounter = SAMPLE_COUNT then
				report "Number of invalid results: " & tostr(errorCount);
			end if;
		end loop;
	end process;
END;
