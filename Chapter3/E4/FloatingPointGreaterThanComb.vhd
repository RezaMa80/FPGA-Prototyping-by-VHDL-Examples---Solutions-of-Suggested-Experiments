library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FloatingPointGreaterThanComb is
	port (
		sign1, sign2 	: in std_logic; 
		exp1, exp2 		: in std_logic_vector(3 downto 0); 
		frac1, frac2 	: in std_logic_vector(7 downto 0); 
		
		output			: out std_logic
	);
end FloatingPointGreaterThanComb;

architecture fpga of FloatingPointGreaterThanComb is

begin
	process(sign1, sign2, exp1, exp2, frac1, frac2)
	begin
		output <= '0';

		if sign1 < sign2 then
			output <= '1';
		end if;
		
		if sign1 = sign2 then
			if exp1 & frac1 > exp2 & frac2 then
				output <= not sign1;
			else
				output <= sign1;
			end if;
		end if;
	end process;
end fpga;

