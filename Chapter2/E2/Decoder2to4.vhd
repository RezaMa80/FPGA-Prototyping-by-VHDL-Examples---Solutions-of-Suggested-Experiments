library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Decoder2to4 is
	port (
		enable: in std_logic;
		input : in std_logic_vector(1 downto 0);
		
		output: out std_logic_vector(3 downto 0)
	);
end Decoder2to4;

architecture Behavioral of Decoder2to4 is
begin
	output(0) <= enable and ((not 	input(1))	and (not 	input(0)));
	output(1) <= enable and ((not 	input(1)) 	and 		input(0));
	output(2) <= enable and (		input(1) 	and (not 	input(0)));
	output(3) <= enable and (		input(1) 	and 		input(0));
end Behavioral;

