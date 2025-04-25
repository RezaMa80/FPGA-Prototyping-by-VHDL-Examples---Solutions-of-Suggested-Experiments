library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Utilities.All;

entity PWM4Bit is
	port (
		i_clk : in std_logic;
		i_w : in std_logic_vector(3 downto 0);
		o_pwm : out std_logic
	);
end PWM4Bit;

architecture Behavioral of PWM4Bit is
	signal counter : natural range 0 to 15 := 0;
	signal wInt : natural range 0 to 15 := 0;
	
	type state_T is (Low, High);
	signal state : state_t;
begin
	wInt <= toint(i_w);
	
	process (i_clk)
	begin
		if (rising_edge(i_clk)) then
			case state is
				when High =>
					o_pwm <= '1';
					counter <= counter + 1;
					
					if counter >= wInt-1 then
						state <= Low;
					end if;
					
				when Low =>
					o_pwm <= '0';
					counter <= counter + 1;
					
					if counter >= 16-1 then
						counter <= 0;
						
						if wInt /= 0 then
							state <= High;
						end if;
					end if;
			end case;
		end if;
	end process;
end Behavioral;
