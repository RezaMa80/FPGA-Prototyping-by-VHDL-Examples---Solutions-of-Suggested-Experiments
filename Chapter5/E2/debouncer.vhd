library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debouncer is
	port(
		i_clk 				: in std_logic;
		i_reset 			: in std_logic;
		i_button 			: in std_logic;
		o_debouncedButton 	: out std_logic
	);
end debouncer;

architecture Behavioral of debouncer is
	constant CLK_FREQ_MHz : positive := 25;
	constant WAIT_TIME_us : positive := 20_000;
	
	type state_T is (Zero, Wait1, One, Wait0);
	signal state : state_T;
	
	signal counter : natural range 0 to CLK_FREQ_MHz*WAIT_TIME_us - 1 := 0;
begin
	process (i_clk)
	begin
		if rising_edge(i_clk) then
			if i_reset = '1' then
				state <= Zero;
				o_debouncedButton <= '0';
			else
				case state is
					when Zero =>
						o_debouncedButton <= '0';
						if i_button = '1' then
							state <= Wait1;
							o_debouncedButton <= '1';
						end if;
						
					when Wait1 =>
						counter <= counter + 1;
						if counter >= CLK_FREQ_MHz * WAIT_TIME_us - 2 then
							state <= One;
							counter <= 0;
						end if;
						
					when One =>
						o_debouncedButton <= '1';
						if i_button = '0' then
							state <= Wait0;
							o_debouncedButton <= '0';
						end if;
						
					when Wait0 =>
						counter <= counter + 1;
						if counter >= CLK_FREQ_MHz * WAIT_TIME_us - 2 then
							state <= Zero;
							counter <= 0;
						end if;
				end case;
			end if;
		end if;
	end process;

end Behavioral;

