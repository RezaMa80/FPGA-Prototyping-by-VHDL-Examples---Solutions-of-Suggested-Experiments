library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FourBitGreaterThan is
	port (
		A : in STD_LOGIC_VECTOR(3 downto 0);
		B : in STD_LOGIC_VECTOR(3 downto 0);
		AIsGreaterThanB : out STD_LOGIC
	);
end FourBitGreaterThan;

architecture FPGA of FourBitGreaterThan is
	component TwoBitGreaterThan
		port (
			A : in STD_LOGIC_VECTOR(1 downto 0);
			B : in STD_LOGIC_VECTOR(1 downto 0);
			AIsGreaterThanB : out STD_LOGIC
		);
	end component;
	
	component TwoBitEquality
		port (
			A : in STD_LOGIC_VECTOR(1 downto 0);
			B : in STD_LOGIC_VECTOR(1 downto 0);
			AIsEqualToB : out STD_LOGIC
		);
	end component;
	
	signal MSBIsEqual : std_logic;
	signal MSBIsGreater : std_logic;
	signal LSBIsGreater : std_logic;
begin
	MSBEquality: TwoBitEquality
	port map (
		A => A(3 downto 2),
		B => B(3 downto 2),
		
		AIsEqualToB => MSBIsEqual
	);
	
	MSBGreaterThan: TwoBitGreaterThan
	port map (
		A => A(3 downto 2),
		B => B(3 downto 2),
		
		AIsGreaterThanB => MSBIsGreater
	);
	
	LSBGreaterThan: TwoBitGreaterThan
	port map (
		A => A(1 downto 0),
		B => B(1 downto 0),
		
		AIsGreaterThanB => LSBIsGreater
	);
	
	AIsGreaterThanB <= 	'1' when (MSBIsGreater or (MSBIsEqual and LSBIsGreater)) = '1' else
						'0';
end FPGA;
