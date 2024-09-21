library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Numeric_std.ALL;
use work.Utilities.ALL;

entity IntegerToFloatingPointComb is
	port (
		int : in std_logic_vector(7 downto 0);
		float : out std_logic_vector(12 downto 0)
	);
end IntegerToFloatingPointComb;

architecture Behavioral of IntegerToFloatingPointComb is
	signal twosCom : std_logic_vector(6 downto 0);
	
	signal magnitude : std_logic_vector(6 downto 0);
begin
	float(12) <= int(7);
	
	twosCom <= std_logic_vector(-signed(int(6 downto 0)));
	
	with int(7)
	select magnitude <= int(6 downto 0) when '0',
						twosCom 		when others;
						
	process (magnitude)
		variable exp : natural := 0;
	begin
		exp := 0;
		
		for index in magnitude'RANGE loop
			if magnitude(index) = '1' then
				exit;
			end if;
			exp := exp + 1;
		end loop;
		
		float(11 downto 8) <= std_logic_vector(to_unsigned(7-exp, 4));
		float(7 downto 1) <= magnitude sll exp;
	end process;
	
	float(0) <= '0';
end Behavioral;

