library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Utilities.ALL;

entity DualPriorityComb is
	port (
		input : in std_logic_vector(12-1 downto 0);
		
		first : out std_logic_vector(4-1 downto 0);
		second : out std_logic_vector(4-1 downto 0)
	);
end DualPriorityComb;

architecture Behavioral of DualPriorityComb is
	signal priorityOr : std_logic_vector(input'RANGE);
begin
	priorityOr(priorityOr'LEFT) <= input(input'LEFT);
	
	priorityOr_gen:
	for i in priorityOr'LEFT-1 downto priorityOr'RIGHT generate
		priorityOr(i) <= priorityOr(i+1) or input(i);
	end generate;
	
	first <= 	toslv(input'LEFT+1, first'LENGTH) when input(input'LEFT) = '1' else
				toslv(input'LEFT+1-1, first'LENGTH) when input(input'LEFT-1) = '1' else
				toslv(input'LEFT+1-2, first'LENGTH) when input(input'LEFT-2) = '1' else
				toslv(input'LEFT+1-3, first'LENGTH) when input(input'LEFT-3) = '1' else
				toslv(input'LEFT+1-4, first'LENGTH) when input(input'LEFT-4) = '1' else
				toslv(input'LEFT+1-5, first'LENGTH) when input(input'LEFT-5) = '1' else
				toslv(input'LEFT+1-6, first'LENGTH) when input(input'LEFT-6) = '1' else
				toslv(input'LEFT+1-7, first'LENGTH) when input(input'LEFT-7) = '1' else
				toslv(input'LEFT+1-8, first'LENGTH) when input(input'LEFT-8) = '1' else
				toslv(input'LEFT+1-9, first'LENGTH) when input(input'LEFT-9) = '1' else
				toslv(input'LEFT+1-10, first'LENGTH) when input(input'LEFT-10) = '1' else
				toslv(input'LEFT+1-11, first'LENGTH) when input(input'LEFT-11) = '1' else
				(others => '0');

	
	second <= 	toslv(input'LEFT+1-1, first'LENGTH) when input(input'LEFT-1) = '1' and priorityOr(input'LEFT) = '1' else
				toslv(input'LEFT+1-2, first'LENGTH) when input(input'LEFT-2) = '1' and priorityOr(input'LEFT-1) = '1' else
				toslv(input'LEFT+1-3, first'LENGTH) when input(input'LEFT-3) = '1' and priorityOr(input'LEFT-2) = '1' else
				toslv(input'LEFT+1-4, first'LENGTH) when input(input'LEFT-4) = '1' and priorityOr(input'LEFT-3) = '1' else
				toslv(input'LEFT+1-5, first'LENGTH) when input(input'LEFT-5) = '1' and priorityOr(input'LEFT-4) = '1' else
				toslv(input'LEFT+1-6, first'LENGTH) when input(input'LEFT-6) = '1' and priorityOr(input'LEFT-5) = '1' else
				toslv(input'LEFT+1-7, first'LENGTH) when input(input'LEFT-7) = '1' and priorityOr(input'LEFT-6) = '1' else
				toslv(input'LEFT+1-8, first'LENGTH) when input(input'LEFT-8) = '1' and priorityOr(input'LEFT-7) = '1' else
				toslv(input'LEFT+1-9, first'LENGTH) when input(input'LEFT-9) = '1' and priorityOr(input'LEFT-8) = '1' else
				toslv(input'LEFT+1-10, first'LENGTH) when input(input'LEFT-10) = '1' and priorityOr(input'LEFT-9) = '1' else
				toslv(input'LEFT+1-11, first'LENGTH) when input(input'LEFT-11) = '1' and priorityOr(input'LEFT-10) = '1' else
				(others => '0');
				
end Behavioral;
