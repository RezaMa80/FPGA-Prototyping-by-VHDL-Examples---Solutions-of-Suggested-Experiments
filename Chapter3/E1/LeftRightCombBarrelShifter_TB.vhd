LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use std.textio.all;
use ieee.math_real.all;

use work.Utilities.ALL;
 
ENTITY LeftRightCombBarrelShifter_TB IS
END LeftRightCombBarrelShifter_TB;
 
ARCHITECTURE behavior OF LeftRightCombBarrelShifter_TB IS 
	type modules_T is (Method1, Method2);
	
	-- User Parameters
	constant module : modules_T := Method2;
	constant inputLength : integer := 16;
	
	constant sampleCount : positive := 10;
	constant stepTime : time := 10 ns;
	constant lrInit : std_logic := '0';
	
	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT LeftRightCombBarrelShifterMethod1
		generic (
			bitCount : integer := inputLength
		);
		PORT(
			input : IN  std_logic_vector(inputLength-1 downto 0);
			amount : IN  std_logic_vector(natural(log2(real(bitCount)))-1 downto 0);
			lr : IN  std_logic;
			output : OUT  std_logic_vector(inputLength-1 downto 0)
		);
	END COMPONENT;
	
	COMPONENT LeftRightCombBarrelShifterMethod2
		generic (
			bitCount : integer := inputLength
		);
		PORT(
			input : IN  std_logic_vector(inputLength-1 downto 0);
			amount : IN  std_logic_vector(natural(log2(real(bitCount)))-1 downto 0);
			lr : IN  std_logic;
			output : OUT  std_logic_vector(inputLength-1 downto 0)
		);
	END COMPONENT;
	
	file bitsFile : text open read_mode is "random01.txt";
	
	--Inputs
	signal input : std_logic_vector(inputLength-1 downto 0) := (others => '0');
	signal amount : std_logic_vector(natural(log2(real(inputLength)))-1 downto 0) := (others => '0');
	signal lr : std_logic := lrInit;

	--Outputs
	signal output : std_logic_vector(inputLength-1 downto 0);
	
	
	signal sampleCounter : natural := 0;
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	chooseModule:
	if module = Method1 generate
		uut: LeftRightCombBarrelShifterMethod1
		GENERIC MAP (
			bitCount => inputLength
		)
		PORT MAP (
			input => input,
			amount => amount,
			lr => lr,
			output => output
		);
	elsif module = Method2 generate
		uut: LeftRightCombBarrelShifterMethod2
		GENERIC MAP (
			bitCount => inputLength
		)
		PORT MAP (
			input => input,
			amount => amount,
			lr => lr,
			output => output
		);
	end generate;
	
	driveInputs_proc:
	process
		variable amount_var : natural := 0;
		variable lr_var : std_logic := lrInit;
		
		variable checkCurrentInput : boolean;
	begin
		while sampleCounter < sampleCount loop
			input <= readSLV(bitsFile, input'LENGTH);
			
			checkCurrentInput := true;
			
			-- For this input, check all posible values for amount and lr
			while checkCurrentInput loop
				amount <= toslv(amount_var, amount'LENGTH);
				lr <= lr_var;
				
				wait for stepTime;
				
				amount_var := amount_var + 1;
				
				-- if amount is all 1, it means we iterated through all of amount possible values
				if (toint(not amount) = 0) then 
					amount_var := 0;
					lr_var  := not lr_var;
					
					-- if lr is not to it's initial value, it means we iterated both lr possible values
					if lr = not lrInit then
						checkCurrentInput := false;
						sampleCounter <= sampleCounter + 1;
					end if;
				end if;
			end loop;
		end loop;
		
		EndSim;
	end process;

	checkOutputs_proc:
	process
		variable errorCount : natural := 0;
		variable error : boolean := false;
		
		variable shiftCounter : natural := 0;
		variable shiftedValue : std_logic_vector(output'RANGE);
	begin		
		wait for stepTime/2;
		
		loop
			if toint(amount) = 0 then
				shiftedValue := input;
			else
				if lr = '0' then -- Left
					shiftedValue := input(input'LEFT-toint(amount) downto input'RIGHT) & input(input'LEFT downto input'LEFT-toint(amount)+1);
				elsif lr = '1' then -- Right
					shiftedValue := input(input'RIGHT+toint(amount)-1 downto input'RIGHT) & input(input'LEFT downto input'RIGHT+toint(amount));
				end if;
			end if;
			
			if shiftedValue /= output then
				report "Invalid result: <-{Input=" & tostr(input, false, true) & "}, <-{amount=" & tostr(amount)& "}, <-{lr=" & tostr(lr) & "}, ->{[output=" & tostr(output, false, true)  & "], [Expected Output=" & tostr(shiftedValue, false, true) & "]}" severity warning;
				errorCount := errorCount + 1;
			end if;
			
			if sampleCounter = sampleCount and toint(not amount) = 0 and lr = not lrInit then
				report "Number of invalid results: " & tostr(errorCount);
			end if;
		
			wait for stepTime;
		end loop;
	end process;
END;


