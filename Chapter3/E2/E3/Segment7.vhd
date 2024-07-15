library ieee;
use ieee.std_logic_1164.all;

entity Segment7 is 
	generic(
		activeHIGH : boolean
	);
	port(
		input : in std_logic_vector (3 downto 0);
		output : out std_logic_vector (6 downto 0)
	);
end Segment7;
	
architecture fpga of Segment7 is
	signal activeHighOutput, activeLowOutput : std_logic_vector(output'RANGE);
begin
	with activeHigh
		select output <= 	activeHighOutput 	when true,
							activeLowOutput 	when others;
		
	activeLowOutput <= not activeHighOutput;
	
	with input
		select activeHighOutput <= 	"0111111" 		when x"0",
									"0000110" 		when x"1",
									"1011011" 		when x"2",
									"1001111" 		when x"3",
									"1100110" 		when x"4",
									"1101101" 		when x"5",
									"1111101" 		when x"6",
									"0000111" 		when x"7",
									"1111111" 		when x"8",
									"1101111" 		when x"9",
									"1110111" 		when x"A",
									"1111100" 		when x"B",
									"0111001" 		when x"C",
									"1011110" 		when x"D",
									"1111001" 		when x"E",
									"1110001" 		when x"F",
									(others => '0') when others ;	
end fpga;
