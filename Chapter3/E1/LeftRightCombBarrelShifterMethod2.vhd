library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Utilities.all;
use ieee.math_real.all;

entity LeftRightCombBarrelShifterMethod2 is
	generic (
		bitCount : integer := 32
	);
	port (
		input : in std_logic_vector(bitCount-1 downto 0);
		amount : in std_logic_vector(natural(log2(real(bitCount)))-1 downto 0);
		lr : in std_logic; -- 0 means left, 1 means right
		
		output : out std_logic_vector(bitCount-1 downto 0)
	);
end LeftRightCombBarrelShifterMethod2;

architecture Behavioral of LeftRightCombBarrelShifterMethod2 is
	signal preReverseOutput : std_logic_vector(output'RANGE);
	signal rightShifterInput : std_logic_vector(output'RANGE);
	signal rightShiftOutput : std_logic_vector(output'RANGE);
	signal postReverseOutput : std_logic_vector(output'RANGE);
begin
	preReverse:
	for i in input'RANGE generate
		preReverseOutput(input'LENGTH-1 - i) <= input(i);
	end generate;
	
	rightShifterInput <= 	input 				when lr = '1' else
							preReverseOutput 	when lr = '0' else
							(others => 'X');
							
	rightShiftOutput <= rightShifterInput(input'RIGHT+toint(amount)-1 downto input'RIGHT) & rightShifterInput(input'LEFT downto input'RIGHT+toint(amount)) when toint(amount) /= 0 else
						rightShifterInput;
	
	postReverse:
	for i in input'RANGE generate
		postReverseOutput(input'LENGTH-1 - i) <= rightShiftOutput(i);
	end generate;
	
	output <= 	postReverseOutput when lr = '0' else
				rightShiftOutput when lr = '1' else
				(others => 'X');
end Behavioral;

