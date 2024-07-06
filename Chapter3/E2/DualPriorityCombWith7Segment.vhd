library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DualPriorityCombWith7Segment is
	port (
		clk : in std_logic;
		input : in std_logic_vector(12-1 downto 0);
		
		sel : out std_logic_vector(1 downto 0);
		output : out std_logic_vector (6 downto 0)
	);
end DualPriorityCombWith7Segment;

architecture fpga of DualPriorityCombWith7Segment is
	constant DELAY : integer := 50_000;
	
	component DualPriorityComb is
		port (
			input : in std_logic_vector(12-1 downto 0);
			
			first : out std_logic_vector(4-1 downto 0);
			second : out std_logic_vector(4-1 downto 0)
		);
	end component DualPriorityComb;

	component Segment7 is 
		generic(
			activeHIGH : boolean
		);
		port(
			input : in std_logic_vector (3 downto 0);
			output : out std_logic_vector (6 downto 0)
		);
	end component Segment7;
	
	signal first : std_logic_vector(4-1 downto 0);
	signal second : std_logic_vector(4-1 downto 0);
	
	signal firstOutput : std_logic_vector(6 downto 0);
	signal secondOutput : std_logic_vector(6 downto 0);
	
	type state_T is (First7Segment, Second7Segment);
	signal state, nextState : state_T;
	
begin
	DualPriorityComb_L: DualPriorityComb
	port map (
		input => input,
		first => first,
		second => second
	);
	
	first7Segment_L: Segment7
	generic map(
		activeHIGH => false
	)
	port map (
		input => first,
		output => firstOutput
	);
	
	second7Segment_L: Segment7
	generic map(
		activeHIGH => false
	)
	port map (
		input => second,
		output => secondOutput
	);
	
	process (clk)
	begin
		if rising_edge(clk) then
			case state is
				when First7Segment =>
					nextState <= Second7Segment;
					
					sel <= "10";
					output <= firstOutput;
					
				when Second7Segment =>
					nextState <= First7Segment;
					
					sel <= "01";
					output <= secondOutput;
			end case;
		end if;
	end process;
	
	process (clk)
		variable counter : natural := 0;
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

