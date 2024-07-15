LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use std.textio.all;
use ieee.math_real.all;

use work.Utilities.ALL;
 
ENTITY TB_BCDIncrementor IS
END TB_BCDIncrementor;
 
ARCHITECTURE sim OF TB_BCDIncrementor IS 
	constant sampleCount : positive := 10;
	constant stepTime : time := 10 ns;
	
	constant DIGIT_COUNT : positive := 3;
	
	-- Component Declaration for the Unit Under Test (UUT)
	component BCDIncrementor is
		generic(
			DIGIT_COUNT : positive
		);
		port (
			input : in std_logic_vector(DIGIT_COUNT*4-1 downto 0);
			output : out std_logic_vector(DIGIT_COUNT*4-1 downto 0)
		);
	end component;
	
	file bitsFile : text open read_mode is "random01.txt";
	
	--Input
	signal input : std_logic_vector(DIGIT_COUNT*4-1 downto 0);

	--Output
	signal output : 	std_logic_vector(DIGIT_COUNT*4-1 downto 0);
	
	signal sampleCounter : natural := 0;
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: BCDIncrementor
	GENERIC MAP (
		DIGIT_COUNT => DIGIT_COUNT
	)
	PORT MAP (
		input => input,
		output => output
	);
	
	driveInputs_proc:
	process
		variable randomBit : std_logic;
		variable inputVar : natural := 0;
		
		variable validValue : boolean := false;
	begin
		while sampleCounter < sampleCount loop
			-- Generate (read) a random value between 0 and 9 with uniform distribution
			while validValue loop
				inputVar := toint(readSLV(bitsFile, input'LENGTH));
				
				if inputVar /= 15 then
					validValue := true;
					
					if inputVar > 9 then
						inputVar := (inputVar-10)*2 + toint(readSLV(bitsFile, 1));
					end if;
				else
					validValue := false;
				end if;
			end loop;
			
			input <= toslv(inputVar, input'LENGTH);
			wait for stepTime;
				
			sampleCounter <= sampleCounter + 1;
		end loop;
		
		EndSim;
	end process;

	checkOutputs_proc:
	process
		variable errorCount : natural := 0;
		
		variable calculatedOutputInteger : natural := 0;
		variable calculatedOutput : STD_LOGIC_VECTOR(output'RANGE) := (others => '0');
		
		variable inputNumber : natural := 0;
		variable placeValue : natural := 0;
		
		variable digit : STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
		
		variable digitInteger : natural := 0;
		variable removedLSDs : natural := 0;
	begin		
		wait for stepTime/2;
		
		loop
			inputNumber := 0;

			for digitNum in 0 to DIGIT_COUNT-1 loop
				placeValue := 10**digitNum;
				digit := input((digitNum+1)*4-1 downto digitNum*4);
				
				inputNumber := inputNumber + placeValue*toint(digit);
			end loop;
			
			calculatedOutputInteger := inputNumber + 1;
			
			for digitNum in 0 to DIGIT_COUNT-1 loop
				placeValue := 10**(digitNum);
				-- LSD: Least-significant digit 
				removedLSDs := calculatedOutputInteger/placeValue;
				digitInteger := removedLSDs - removedLSDs/10*10;
				
				calculatedOutput((digitNum+1)*4-1 downto digitNum*4) := toslv(digitInteger, 4);
			end loop;
			
			if calculatedOutput /= output then
				report "Invalid result: <-{Input=" & tostr(input, false, true) & "}, ->{[output=" & tostr(output, false, true) & "], [Expected output=" & tostr(calculatedOutput, false, true) & "]}" severity warning;
				errorCount := errorCount + 1;
			end if;
			
			if sampleCounter = sampleCount then
				report "Number of invalid results: " & tostr(errorCount);
			end if;
		
			wait for stepTime;
		end loop;
	end process;
END;


