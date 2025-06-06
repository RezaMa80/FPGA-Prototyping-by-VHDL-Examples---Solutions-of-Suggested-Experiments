library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Traffic_Cheker is
	port (
		i_clk 	: in std_logic;
		i_a 	: in std_logic;
		i_b 	: in std_logic;
		o_enter : out std_logic;
		o_exit 	: out std_logic
	);
end Traffic_Cheker;

architecture Behavioral of Traffic_Cheker is
	type state_T is (Idle, Part1, Part2, Part3);
	signal state : state_T;
	
	signal enter0Exit1 : std_logic;
	signal sensor1 : std_logic;
	signal sensor2 : std_logic;
begin
	sensor1 <= i_a when enter0Exit1 = '0' else i_b;
	sensor2 <= i_a when enter0Exit1 = '1' else i_b;
	
	process (i_clk)
	begin
		if rising_edge(i_clk) then
			o_enter <= '0';
			o_exit <= '0';
			
			case state is 
				when Idle =>
					if i_a = '1' then
						enter0Exit1 <= '0';
						state <= Part1;
					end if;
					
					if i_b = '1' then
						enter0Exit1 <= '1';
						state <= Part1;
					end if;
					
				when Part1 =>
					if sensor1 = '0' then
						state <= Idle;
					end if;
					
					if sensor2 = '1' then
						state <= Part2;
					end if;
					
				when Part2 =>
					if sensor1 = '0' then
						state <= Part3;
					end if;
					
					if sensor2 = '0' then
						state <= Part1;
					end if;
					
				when Part3 =>
					if sensor1 = '1' then
						state <= Part2;
					end if;
					
					if sensor2 = '0' then
						state <= Idle;
						
						if enter0Exit1 = '0' then
							o_enter <= '1';
						else
							o_exit <= '1';
						end if;
					end if;
			end case;
		end if;
	end process;
end Behavioral;

