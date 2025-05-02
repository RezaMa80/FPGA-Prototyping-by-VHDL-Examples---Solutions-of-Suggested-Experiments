library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RotatingSquareCircuit is
    port (
        i_clk : in std_logic;
        i_enable: in std_logic;
        i_direction: in std_logic;
		
        o_select: out std_logic_vector(3 downto 0);
        o_sevenSegment: out std_logic_vector(7 downto 0) := "10011100"
	);
end RotatingSquareCircuit;

architecture arch of RotatingSquareCircuit is
	constant DELAY_CLOCK : positive := 1_000_000;
	constant UP_SQUARE : std_logic_vector(5 downto 0) := "011100";
	
	type state_T is (Set, Delay);
	signal state : state_T;
	
	signal sel : std_logic_vector(o_select'RANGE) := "0111";
	signal upNDown : std_logic := '1';
	
	signal counter : natural range 0 to DELAY_CLOCK-1 := 0;
	signal enable : std_logic := '1';
	signal direction : std_logic := '0';
	
	type buttonState_T is (Idle, Pushed, Released);
	signal enableButtonState : buttonState_T;
	signal enableButtonCounter : natural := 0;
	
	signal directionButtonState : buttonState_T;
	signal directionButtonCounter : natural := 0;
	
	signal upEnd : std_logic;
	signal downEnd : std_logic;
begin
	o_select <= sel;
	o_sevenSegment(7) <= '1';
	o_sevenSegment(6) <= '0';
	
	upEnd <= 	sel(sel'RIGHT) when direction = '1' else
				sel(sel'LEFT);
	downEnd <= 	sel(sel'RIGHT) when direction = '0' else
				sel(sel'LEFT);
				
	process (I_clk)		
		procedure shift (constant upNDownDirection : in std_logic) is
		begin
			if direction = upNDownDirection then
				sel <= '1' & sel(sel'LEFT downto sel'RIGHT+1);
			else
				sel <= sel(sel'LEFT-1 downto sel'RIGHT) & '1';
			end if;
		end procedure;
	begin
		if rising_edge(I_clk) then
			case state is
				when Set =>
					if enable = '1' then
						if upNDown = '1' then
							if upEnd = '0' then
								upNDown <= '0';
								o_sevenSegment(5 downto 0) <= UP_SQUARE;
							else
								shift('1');
							end if;
						else
							if downEnd = '0' then
								upNDown <= '1';
								o_sevenSegment(5 downto 0) <= not UP_SQUARE;
							else
								shift('0');
							end if;
						end if;
						
						state <= Delay;
					end if;
					
				when Delay =>
					counter <= counter + 1;
					
					if DELAY_CLOCK-1 <= counter then
						state <= Set;
						counter <= 0;
					end if;
			end case;
		end if;
	end process;
	
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
						output <= not output;
						state <= Pushed;
					end if;
					
				when Pushed =>
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
				buttonPin => i_enable, 
				output => enable,
				state => enableButtonState,
				counter => enableButtonCounter
			);
			
			Button(
				buttonPin => i_direction, 
				output => direction,
				state => directionButtonState,
				counter => directionButtonCounter
			);
		end if;
	end process;
end arch;
