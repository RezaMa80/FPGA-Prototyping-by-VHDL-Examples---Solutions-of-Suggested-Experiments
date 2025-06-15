library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debouncer is
	port(
		i_clk 				: in std_logic;
		i_reset 			: in std_logic;
		i_button 			: in std_logic;
		o_debouncedButton 	: out std_logic;
		o_risingEdge	 	: out std_logic
	);
end debouncer;

architecture Behavioral of debouncer is
	constant CLK_FREQ_MHz : positive := 25;
	constant WAIT_TIME_us : positive := 20_000;
	
	type state_T is (Zero, Wait1, One, Wait0);
	signal state : state_T;
	
	signal counter_next : natural range 0 to CLK_FREQ_MHz*WAIT_TIME_us - 1 := 0;
	signal counter_reg : natural range 0 to CLK_FREQ_MHz*WAIT_TIME_us - 1 := 0;
	
	signal countUp 			: std_logic := '0';
	signal counterFinished 	: std_logic := '0';
	signal counterReset 	: std_logic := '0';
begin
	process (i_clk)
	begin
		if rising_edge(i_clk) then
			if i_reset = '1' then
				state <= Zero;
				o_debouncedButton <= '0';
				o_risingEdge <= '0';
				countUp <= '0';
				counterReset <= '0';
				counter_reg <= 0;
			else
				o_risingEdge <= '0';
				counter_reg <= counter_next;
				
				case state is
					when Zero =>
						counterReset <= '0';
						o_debouncedButton <= '0';
						
						if i_button = '1' then
							state <= Wait1;
							o_debouncedButton <= '1';
						end if;
						
					when Wait1 =>
						countUp <= '1';
						if counterFinished = '1' then
							o_risingEdge <= '1';
							state <= One;
							counterReset <= '1';
						end if;
						
					when One =>
						counterReset <= '0';
						o_debouncedButton <= '1';
						if i_button = '0' then
							state <= Wait0;
							o_debouncedButton <= '0';
						end if;
						
					when Wait0 =>
						countUp <= '1';
						if counterFinished = '1' then
							state <= Zero;
							counterReset <= '1';
						end if;
				end case;
			end if;
		end if;
	end process;
	
	counter_next <= 0 				when counterReset = '1' else
					counter_reg + 1 when countUp = '1' 		else
					counter_reg;
	
	counterFinished <= 	'1' when counter_reg = CLK_FREQ_MHz * WAIT_TIME_us - 2 else
						'0';
end Behavioral;
