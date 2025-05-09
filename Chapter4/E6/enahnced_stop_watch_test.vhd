library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity enahnced_stop_watch_test is
    port (
        i_clk : in std_logic;
        btn: in std_logic_vector(3 downto 0);
        an: out std_logic_vector(3 downto 0);
        sseg: out std_logic_vector(7 downto 0)
    );
end enahnced_stop_watch_test;

architecture arch of enahnced_stop_watch_test is
	signal d3, d2, d1, d0: std_logic_vector(3 downto 0);
	signal btnNot: std_logic_vector(3 downto 0);
	
	type buttonState_T is (Idle, Pushed, Released);
	signal directionButtonState : buttonState_T;
	signal directionButtonCounter : natural := 0;
	
	signal direction : std_logic;
begin
	disp_unit : entity work.disp_hex_mux
        port map (
            clk=>i_clk, reset => '0',
            hex3=>d3, hex2=>d2,
            hex1=>d1, hex0=>d0,
            dp_in=>"0101", an=>an, sseg=>sseg
		);
		
	watch_unit: entity work.enhanced_stop_watch(cascade_arch)
		port map(
			clk=>i_clk, i_direction=>direction, go=>btn(1), clr=>btn(0),
			d3=>d3, d2=>d2, d1=>d1, d0=>d0 );
			
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
				buttonPin => btn(2), 
				output => direction,
				state => directionButtonState,
				counter => directionButtonCounter
			);
		end if;
	end process;
end arch;
