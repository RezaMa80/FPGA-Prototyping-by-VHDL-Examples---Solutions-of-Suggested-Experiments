library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DualEdge_Detector_Mealy is
	port (
		i_clk : in std_logic;
		i_input : in std_logic;
		o_output : out std_logic := '0'
	);
end DualEdge_Detector_Mealy;

architecture Behavioral of DualEdge_Detector_Mealy is
	type state_T is (Zero, One);
	signal state, state_r : state_T;
begin
	o_output <= '1' when (state_r = Zero and state = One) else
				'1' when (state_r = One and state = Zero) else
				'0';
				
	process (i_clk)
	begin
		if rising_edge(i_clk) then
			state_r <= state;
			case state is
				when Zero =>
					if i_input = '1' then
						state <= One;
					end if;
					
				when One =>
					if i_input = '0' then
						state <= Zero;
					end if;
			end case;
		end if;
	end process;
end Behavioral;
