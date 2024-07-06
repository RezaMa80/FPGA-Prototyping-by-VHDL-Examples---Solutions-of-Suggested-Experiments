LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use std.textio.all;
use ieee.math_real.all;

use work.Utilities.ALL;
 
ENTITY TB_DualPriorityComb IS
END TB_DualPriorityComb;
 
ARCHITECTURE behavior OF TB_DualPriorityComb IS 
	constant sampleCount : positive := 10;
	constant stepTime : time := 10 ns;
	
	-- Component Declaration for the Unit Under Test (UUT)
	component DualPriorityComb is
		port (
			input : in std_logic_vector(12-1 downto 0);
			
			first : out std_logic_vector(4-1 downto 0);
			second : out std_logic_vector(4-1 downto 0)
		);
	end component;
	
	file bitsFile : text open read_mode is "random01.txt";
	
	--Inputs
	signal input : std_logic_vector(12-1 downto 0) := (others => '0');

	--Outputs
	signal first : 	std_logic_vector(4-1 downto 0);
	signal second : std_logic_vector(4-1 downto 0);
	
	signal sampleCounter : natural := 0;
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: DualPriorityComb
	PORT MAP (
		input => input,
		first => first,
		second => second
	);
	
	driveInputs_proc:
	process
		variable checkCurrentInput : boolean;
	begin
		while sampleCounter < sampleCount loop
			input <= readSLV(bitsFile, input'LENGTH);
			
			wait for stepTime;
				
			sampleCounter <= sampleCounter + 1;
		end loop;
		
		EndSim;
	end process;

	checkOutputs_proc:
	process
		variable errorCount : natural := 0;
		
		variable priorityCounter : natural := 0;
		variable calculatedFirst : natural;
		variable calculatedSecond : natural;
	begin		
		wait for stepTime/2;
		
		loop
			calculatedFirst := 0;
			calculatedSecond := 0;
			priorityCounter := 0;
			
			for i in input'RANGE loop
				if input(i) = '1' then
					priorityCounter := priorityCounter + 1;
					
					if priorityCounter = 1 then
						calculatedFirst := i+1;
					elsif priorityCounter = 2 then
						calculatedSecond := i+1;
					end if;
				end if;
			end loop;
		
			if calculatedFirst /= toint(first) then
				report "Invalid result: <-{Input=" & tostr(input, false, true) & "}, ->{[first=" & tostr(first)  & "], [Expected first=" & tostr(calculatedFirst) & "]}" severity warning;
				errorCount := errorCount + 1;
			end if;
			if calculatedSecond /= toint(second) then
				report "Invalid result: <-{Input=" & tostr(input, false, true) & "}, ->{[second=" & tostr(second)  & "], [Expected second=" & tostr(calculatedSecond) & "]}" severity warning;
				errorCount := errorCount + 1;
			end if;
			
			if sampleCounter = sampleCount then
				report "Number of invalid results: " & tostr(errorCount);
			end if;
		
			wait for stepTime;
		end loop;
	end process;
END;


