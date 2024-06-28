library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Utilities.all;
use ieee.math_real.all;

entity LeftRightCombBarrelShifterMethod1 is
	generic (
		bitCount : integer := 32
	);
	port (
		input : in std_logic_vector(bitCount-1 downto 0);
		amount : in std_logic_vector(natural(log2(real(bitCount)))-1 downto 0);
		lr : in std_logic; -- 0 means left, 1 means right
		
		output : out std_logic_vector(bitCount-1 downto 0)
	);
end LeftRightCombBarrelShifterMethod1;

architecture Behavioral of LeftRightCombBarrelShifterMethod1 is
	signal leftShiftOutput, rightShiftOutput : std_logic_vector(output'RANGE);
begin
	leftShiftOutput <= 	input(input'LEFT-toint(amount) downto input'RIGHT) & input(input'LEFT downto input'LEFT-toint(amount)+1) when toint(amount) /= 0 else
						input;
	rightShiftOutput <= input(input'RIGHT+toint(amount)-1 downto input'RIGHT) & input(input'LEFT downto input'RIGHT+toint(amount)) when toint(amount) /= 0 else
						input;

	output <= 	leftShiftOutput when lr = '0' else
				rightShiftOutput when lr = '1' else
				(others => 'X');
end Behavioral;

