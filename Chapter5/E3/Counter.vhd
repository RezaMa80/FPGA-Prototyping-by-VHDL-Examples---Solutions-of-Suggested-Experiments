library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Utilities.ALL;

entity Counter16 is
	port (
		i_clk 	: in std_logic;
		i_inc 	: in std_logic;
		i_dec 	: in std_logic;
		o_count : out std_logic_vector(15 downto 0)
	);
end Counter16;

architecture Behavioral of Counter16 is
	signal count : natural range 0 to 65535 := 0;
begin
	o_count <= toslv(count, 16);
	
	process (i_clk)
	begin
		if rising_edge(i_clk) then
			if i_inc = '1' then
				count <= count + 1;
			end if;
			
			if i_dec = '1' then
				count <= count - 1;
			end if;
			
			if (i_inc = '1') and (i_dec = '1') then
				count <= count;
			end if;
		end if;
	end process;
end Behavioral;

