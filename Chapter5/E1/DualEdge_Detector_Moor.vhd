library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DualEdge_Detector_Moor is
	port (
		i_clk : in std_logic;
		i_input : in std_logic;
		o_output : out std_logic := '0'
	);
end DualEdge_Detector_Moor;

architecture Behavioral of DualEdge_Detector_Moor is
	type state_T is (Zero, RisingEdge, FallingEdge, One);
	signal state : state_T;
begin
	o_output <= '0' when state = Zero else
				'1' when state = RisingEdge else
				'1' when state = FallingEdge else
				'0';
				
	process (i_clk)
	begin
		if rising_edge(i_clk) then
			case state is
				when Zero =>
					if i_input = '1' then
						state <= RisingEdge;
					end if;
					
				when RisingEdge =>
					if i_input = '1' then
						state <= One;
					else
						state <= FallingEdge;
					end if;
					
				when FallingEdge =>
					if i_input = '1' then
						state <= RisingEdge;
					else
						state <= Zero;
					end if;
					
				when One =>
					if i_input = '0' then
						state <= FallingEdge;
					end if;
			end case;
		end if;
	end process;
end Behavioral;
