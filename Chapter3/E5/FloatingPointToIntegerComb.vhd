library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Numeric_std.ALL;
use work.Utilities.ALL;

entity FloatingPointToIntegerComb is
	port (
		float 		: in 	std_logic_vector(12 downto 0);
		int 		: out 	std_logic_vector(7 	downto 0);
		underflow	: out 	std_logic;
		overflow 	: out 	std_logic
	);
end FloatingPointToIntegerComb;

architecture Behavioral of FloatingPointToIntegerComb is
	signal twosCom : std_logic_vector(6 downto 0);
	
	signal magnitude : std_logic_vector(6 downto 0) := (others => '0');
begin
	process (float(11 downto 0))
		variable temp : std_logic_vector(14+7 downto 0);
	begin	
		temp := (others => '0');
		temp(7 downto 0) := float(7 downto 0);
		
		temp := temp sll toint(float(11 downto 8));
		
		magnitude <= temp(14 downto 8);
	end process;
	
	process (float(11 downto 0))
	begin
		underflow <= '0';
		
		if toint(float(11 downto 8)) = 0 then
			if toint(float(7 downto 0)) /= 0 then
				underflow <= '1';
			end if;
		end if;
	end process;
	
	process (float(11 downto 8))
	begin
		overflow <= '0';
		
		if toint(float(11 downto 8)) > 7 then
			overflow <= '1';
		end if;
	end process;

	with float(12)
	select int <= 	'0' & magnitude 							when '0',
					std_logic_vector(-signed('0' & magnitude)) 	when others;
end Behavioral;

