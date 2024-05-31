library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Decoder4to16 is
	port (
		enable: in std_logic;
		input : in std_logic_vector(3 downto 0);
		
		output: out std_logic_vector(15 downto 0)
	);
end Decoder4to16;

architecture Behavioral of Decoder4to16 is
	component Decoder2to4
		port (
			enable: in std_logic;
			input : in std_logic_vector(1 downto 0);
			
			output: out std_logic_vector(3 downto 0)
		);
	end component;
	
	signal layer0Enables : std_logic_vector((output'LEFT+1)/4-1 downto 0);
begin
	Layer1Decoder2to4: Decoder2to4
	port map (
		enable => enable,
		input => input(input'left downto input'left-1),
		
		output => layer0Enables
	);
	
	Layer0Decoder2to4:
	for X in 0 to (output'LEFT+1)/4-1 generate
		Layer0NibbleXDecoder2to4: Decoder2to4
		port map (
			enable => layer0Enables(X),
			input => input(1 downto 0),
			
			output => output(3+4*X downto 0+4*X)
		);
	end generate;
end Behavioral;

