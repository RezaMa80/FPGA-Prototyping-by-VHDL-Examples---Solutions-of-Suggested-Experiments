library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Stack_Test is
	port (
		i_clk : in std_logic;
		i_button : in std_logic_vector(2 downto 0);
		i_switch : in std_logic_vector(2 downto 0);
		o_LED : out std_logic_vector(7 downto 0)
	);
end Stack_Test;

architecture Behavioral of Stack_Test is
	signal push, pop, reset : std_logic;
	
	type buttonState_T is (Idle, Pushed, Released);
	signal pushButtonState : buttonState_T;
	signal pushButtonCounter : natural := 0;
	signal popButtonState : buttonState_T;
	signal popButtonCounter : natural := 0;
	signal resetButtonState : buttonState_T;
	signal resetButtonCounter : natural := 0;
	
	signal notButton : std_logic_vector(2 downto 0);
begin
	notButton <= not i_button;
	o_LED(5 downto 3) <= (others => '0');
	
	stack_unit : entity work.Stack
	generic map (
		BIT_COUNT => 3,
		ELEMENT_COUNT => 16
	)
	port map (
		i_clk => i_clk,
		i_reset => reset,
		i_push => push,
		i_pop => pop,
		i_pushData => i_switch,
		o_popData => o_LED(2 downto 0),
		o_full => o_LED(7),
		o_empty => o_LED(6)
	);
	
	process (i_clk)
		procedure Button (
			signal buttonPin : in std_logic; 
			signal output : inout std_logic;
			signal state : inout buttonState_T;
			signal counter : inout natural) is
		begin
			case state is
				when Idle =>
					if buttonPin = '0' then
						output <= '1';
						state <= Pushed;
					end if;
					
				when Pushed =>
					output <= '0';
					counter <= counter + 1;
					
					if counter > 1_000_000 then
						
						if buttonPin = '1' then
							state <= Released;
							counter <= 0;
						end if;
					end if;
				
				when Released =>
					counter <= counter + 1;
					
					if counter > 1_000_000 then
						state <= Idle;
						counter <= 0;
					end if;
			end case;
		end procedure;
	begin
		if rising_edge(i_clk) then
			Button(
				buttonPin => notButton(0), 
				output => push,
				state => pushButtonState,
				counter => pushButtonCounter
			);
			
			Button(
				buttonPin => notButton(1), 
				output => pop,
				state => popButtonState,
				counter => popButtonCounter
			);
			
			Button(
				buttonPin => notButton(2), 
				output => reset,
				state => resetButtonState,
				counter => resetButtonCounter
			);
		end if;
	end process;
end Behavioral;

