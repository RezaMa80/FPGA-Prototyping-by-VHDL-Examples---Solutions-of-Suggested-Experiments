library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TwoBitEquality is
	port (
		A : in STD_LOGIC_VECTOR(1 downto 0);
		B : in STD_LOGIC_VECTOR(1 downto 0);
		AIsEqualToB : out STD_LOGIC
	);
end TwoBitEquality;

architecture FPGA of TwoBitEquality is
begin
	AIsEqualToB  <= '1' when A=B else
					'0';
end FPGA;

