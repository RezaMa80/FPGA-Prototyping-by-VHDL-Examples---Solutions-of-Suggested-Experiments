library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Decoder3to8 is
	port (
		enable: in std_logic;
		input : in std_logic_vector(2 downto 0);
		
		output: out std_logic_vector(7 downto 0)
	);
end Decoder3to8;

architecture Behavioral of Decoder3to8 is
	component Decoder2to4
		port (
			enable: in std_logic;
			input : in std_logic_vector(1 downto 0);
			
			output: out std_logic_vector(3 downto 0)
		);
	end component;
	
	signal LSBEnable : std_logic;
	signal MSBEnable : std_logic;
begin
	LSBEnable <= enable and not input(input'left);
	MSBEnable <= enable and input(input'left);
	
	LSBDecoder2to4: Decoder2to4
	port map (
		enable => LSBEnable,
		input => input(input'left-1 downto 0),
		
		output => output((output'left+1)/2-1 downto 0)
	);
	
	MSBDecoder2to4: Decoder2to4
	port map (
		enable => MSBEnable,
		input => input(input'left-1 downto 0),
		
		output => output(output'left downto (output'left+1)/2)
	);

end Behavioral;

