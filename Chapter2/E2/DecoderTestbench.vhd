LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.math_real.ALL;

use work.Utilities.all;

ENTITY DecoderTestbench IS
END DecoderTestbench;
 
ARCHITECTURE behavior OF DecoderTestbench IS
	type modules_T is (TwoBit, ThreeBit, FourBit);
	
	function moduleLength (module : modules_T) 
		return natural is
	begin
		if module = TwoBit then
			return 2;
		elsif module = ThreeBit then
			return 3;
		elsif module = FourBit then
			return 4;
		end if;
	end moduleLength;
	
	constant module : modules_T := FourBit;
	constant stepTime : time := 10 ns;

	constant inputLength : integer := moduleLength(module);
	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT Decoder2to4
		PORT(
			enable : IN  std_logic;
			input : IN  std_logic_vector(inputLength-1 downto 0);
			output : OUT  std_logic_vector(2**inputLength-1 downto 0)
		);
	END COMPONENT;
	
	COMPONENT Decoder3to8
		PORT(
			enable : IN  std_logic;
			input : IN  std_logic_vector(inputLength-1 downto 0);
			output : OUT  std_logic_vector(2**inputLength-1 downto 0)
		);
	END COMPONENT;
	
	COMPONENT Decoder4to16
		PORT(
			enable : IN  std_logic;
			input : IN  std_logic_vector(inputLength-1 downto 0);
			output : OUT  std_logic_vector(2**inputLength-1 downto 0)
		);
	END COMPONENT;
	
	constant enableInit : std_logic := '0';
	
	-- Inputs
	signal enable : std_logic := enableInit;
	signal input : std_logic_vector(inputLength-1 downto 0) := (others => '0');

	-- Outputs
	signal output : std_logic_vector(2**inputLength-1 downto 0);
	
	constant one : std_logic_vector(input'range) := (others => '1');
BEGIN
	-- Instantiate the Unit Under Test (UUT)
	chooseModule:
	if module = TwoBit generate
		uut: Decoder2to4
		PORT MAP (
			enable => enable,
			input => input,
			
			output => output
		);
	elsif module = ThreeBit generate
		uut: Decoder3to8
		PORT MAP (
			enable => enable,
			input => input,
			
			output => output
		);
	elsif module = FourBit generate
		uut: Decoder4to16
		PORT MAP (
			enable => enable,
			input => input,
			
			output => output
		);
	else generate
	end generate;

	-- Drive inputs
	driveInputs_proc:
	process
		variable input_var : natural := 0;
	begin
		input <= toslv(input_var, input'length); 
		
		wait for stepTime;
		input_var := input_var + 1;
		
		if (input = one) then
			input_var := 0;
			
			if enable = not enableInit then
				EndSim;
			end if;
			
			enable <= not enable;
		end if;
	end process;
	
	-- Check outputs
	checkOutputs_proc:
	process
		variable errorCount : natural := 0;
		variable error : boolean := false;
	begin		
		wait for stepTime/2;
		
		loop
			error := false;
			
			if enable = '0' then
				if toint(output) /= 0 then
					report "Invalid result for: Enable=" & tostr(enable) severity warning;
					errorCount := errorCount + 1;
				end if;
			else
				for i in output'range loop
					if i = toint(input) then
						if output(i) /= '1' then
							error := true;
						end if;
					else
						if output(i) /= '0' then
							error := true;
						end if;
					end if;
				end loop;
			end if;
			
			if error then
				report "Invalid result for: Input=" & tostr(input) & ", output=" & tostr(output) severity warning;
				errorCount := errorCount + 1;
			end if;
			
			if input = one and enable = not enableInit then
				report "Number of invalid results: " & tostr(errorCount);
			end if;
			
			wait for stepTime;
		end loop;
	end process;
END;
