library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RotatingLEDBanner is
    port (
        i_clk : in std_logic;
        i_enable: in std_logic;
        i_direction: in std_logic;
		
        o_select: out std_logic_vector(3 downto 0);
        o_sevenSegment: out std_logic_vector(7 downto 0)
	);
end RotatingLEDBanner;

architecture arch of RotatingLEDBanner is
	constant UPDATE_DELAY_CLOCK : positive := 50_000;
	constant SHIFT_DELAY_CLOCK : positive := 12_000_000;
	type character_T is array (natural range<>) of std_logic_vector(6 downto 0);
	constant STR : character_T(0 to 9) := (
		"1000000",
		"1111001",
		"0100100",
		"0110000",
		"0011001",
		"0010010",
		"0000010",
		"1111000",
		"0000000",
		"0010000"
	);
	
	type updateState_T is (Update, UpdateDelay);
	type shiftState_T is (Shift, ShiftDelay);
	signal updateState : updateState_T;
	signal shiftState : shiftState_T := ShiftDelay;
	
	signal sel : std_logic_vector(o_select'RANGE) := "0111";
	
	signal updateCounter : natural range 0 to UPDATE_DELAY_CLOCK-1 := 0;
	signal shiftCounter : natural range 0 to SHIFT_DELAY_CLOCK-1 := 0;
	signal enable : std_logic := '1';
	signal direction : std_logic := '1';
	
	type buttonState_T is (Idle, Pushed, Released);
	signal enableButtonState : buttonState_T;
	signal enableButtonCounter : natural := 0;
	
	signal directionButtonState : buttonState_T;
	signal directionButtonCounter : natural := 0;
	
	signal display : character_T(0 to 3) := (STR(0), STR(1), STR(2), STR(3));
	signal updateIndex : natural range 0 to 3 := 0;
	signal index : natural range 0 to 9 := 0;
begin
	o_select <= sel;
	o_sevenSegment(7) <= '1';
	
	process (i_clk)	
		variable index_var : natural range 0 to 9 := 0;
	begin
		if rising_edge(i_clk) then
			case updateState is
				when Update =>
					o_sevenSegment(6 downto 0) <= display(updateIndex);
					sel <= (others => '1');
					sel(3-updateIndex) <= '0';
					
					if updateIndex >= display'LENGTH - 1 then
						updateIndex <= 0;
					else
						updateIndex <= updateIndex + 1;
					end if;
					
					updateState <= UpdateDelay;

				when UpdateDelay =>
					updateCounter <= updateCounter + 1;
					
					if UPDATE_DELAY_CLOCK-1 <= updateCounter then
						updateState <= Update;
						updateCounter <= 0;
					end if;
			end case;
		end if;
	end process;
	
	process (i_clk)	
		variable index_var : natural range 0 to 9 := 0;
	begin
		if rising_edge(i_clk) then
			case shiftState is
				when Shift =>
					if enable = '1' then
						if direction = '0' then
							index <= index - 1;
							if index <= 0 then
								index <= 9;
							end if;

							if index = 0 then
								index_var := 9;
							else
								index_var := index - 1;
							end if;
							
							display <= STR(index_var) & display(display'LEFT to display'RIGHT-1);
							
							
						else
							index <= index + 1;
							if index >= 9 then
								index <= 0;
							end if;
							
							if index >=6 then
								index_var := index + 4 - 10;
							else
								index_var := index + 4;
							end if;
							
							display <= display(display'LEFT+1 to display'RIGHT) & STR(index_var);
							
						end if;
						
						shiftState <= ShiftDelay;
					end if;
					
				when ShiftDelay =>
					shiftCounter <= shiftCounter + 1;
					
					if SHIFT_DELAY_CLOCK-1 <= shiftCounter then
						shiftState <= Shift;
						shiftCounter <= 0;
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
