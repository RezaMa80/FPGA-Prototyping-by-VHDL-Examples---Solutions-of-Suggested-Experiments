library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TwoBitGreaterThan is
	port (
		A : in STD_LOGIC_VECTOR(1 downto 0);
		B : in STD_LOGIC_VECTOR(1 downto 0);
		AIsGreaterThanB : out STD_LOGIC
	);
end TwoBitGreaterThan;

architecture FPGA of TwoBitGreaterThan is
begin
	AIsGreaterThanB <= 	(A(1) and (not B(1))) or (A(0) and (not B(1)) and (not B(0))) or (A(0) and A(1) and (not B(0)));
end FPGA;

