library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BCDIncrementorWith7Segment is
	generic(
		DIGIT_COUNT : positive := 3
	);
	port (
		clk : in std_logic;
		input : in std_logic_vector(DIGIT_COUNT*4-1 downto 0);
		
		sel : out std_logic_vector(DIGIT_COUNT-1 downto 0);
		output : out std_logic_vector (6 downto 0)
	);
end BCDIncrementorWith7Segment;

architecture fpga of BCDIncrementorWith7Segment is
	constant DELAY : integer := 50_000;
	
	component BCDIncrementor is
		generic(
			DIGIT_COUNT : positive
		);
		port (
			input : in std_logic_vector(DIGIT_COUNT*4-1 downto 0);
			output : out std_logic_vector(DIGIT_COUNT*4-1 downto 0)
		);
	end component;

	component Segment7 is 
		generic(
			activeHIGH : boolean
		);
		port(
			input : in std_logic_vector (3 downto 0);
			output : out std_logic_vector (6 downto 0)
		);
	end component Segment7;
	
	signal BCDIncrementor_Output : std_logic_vector(DIGIT_COUNT*4-1 downto 0);
	signal segment7_Output : std_logic_vector(DIGIT_COUNT*7-1 downto 0);
	
	signal state, nextState : integer range 0 to DIGIT_COUNT-1 := 0;
	
begin
	BCDIncrementor_L: BCDIncrementor
	generic map(
		DIGIT_COUNT => DIGIT_COUNT
	)
	port map (
		input => input,
		output => BCDIncrementor_Output
	);
	
	Segment7_gen:
	for x in 0 to DIGIT_COUNT-1 generate
		Segment7_x: Segment7
		generic map(
			activeHIGH => false
		)
		port map (
			input => BCDIncrementor_Output((x+1)*4-1 downto x*4),
			output => segment7_Output((x+1)*7-1 downto x*7)
		);
	end generate;
	
	process (clk)
	begin
		if rising_edge(clk) then
			if state = DIGIT_COUNT-1 then
				nextState <= 0;
			else
				nextState <= state+1;
			end if;
			
			sel <= (others => '1');
			sel(state) <= '0';
			
			output <= segment7_Output((state+1)*7-1 downto state*7);
		end if;
	end process;
	
	process (clk)
		variable counter : natural range 0 to DELAY+1 := 0;
	begin
		if rising_edge(clk) then
			counter := counter + 1;
			if counter >= DELAY+1 then
				counter := 0;

				state <= nextState;
			end if;
		end if;
	end process;
end fpga;
