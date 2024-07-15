library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Utilities.ALL;

entity BCDIncrementor is
	generic(
		DIGIT_COUNT : positive := 3
	);
	port (
		input : in std_logic_vector(DIGIT_COUNT*4-1 downto 0);
		output : out std_logic_vector(DIGIT_COUNT*4-1 downto 0)
	);
end BCDIncrementor;

architecture fpga of BCDIncrementor is
begin
	process(input)
		variable add : boolean := true;
	begin
		add := true;
		for i in 0 to DIGIT_COUNT-1 loop
			if add then
				output((1+i)*4-1 downto i*4) <= std_logic_vector(unsigned(input((1+i)*4-1 downto i*4))+1);
			else
				output((1+i)*4-1 downto i*4) <= input((1+i)*4-1 downto i*4);
			end if;
			
			if input((1+i)*4-1 downto i*4) = toSLV(9, 4) then
				output((1+i)*4-1 downto i*4) <= (others => '0');
				add := true;
			else
				add := false;
			end if;
		end loop;
	end process;
end fpga;

