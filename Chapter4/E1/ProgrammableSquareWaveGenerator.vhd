library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Utilities.All;

entity ProgrammableSquareWaveGenerator is
	port (
		clk : in std_logic;
		m, n : in std_logic_vector(3 downto 0);
		s : out std_logic
	);
end ProgrammableSquareWaveGenerator;

architecture Behavioral of ProgrammableSquareWaveGenerator is
	-- User parameters:
	constant MINIMUM_DURATION_NS : positive := 100;
	
	-- Constant parameters:
	constant CLK_PERIOD_NS : positive := 20;
	
	constant MINIMUM_DURATION_CLK : positive := MINIMUM_DURATION_NS/CLK_PERIOD_NS;
	
	signal counter : natural range 0 to 15*MINIMUM_DURATION_CLK := 0;
	signal mInt : natural range 0 to 15 := 0;
	signal nInt : natural range 0 to 15 := 0;
	
	type state_T is (Low, High);
	signal state : state_t;

  -- Checking periods
	function check_constants return integer is
    begin
        if MINIMUM_DURATION_CLK*CLK_PERIOD_NS /= MINIMUM_DURATION_NS then
			report "The entered period can't be generated" severity failure;
		end if;
		
		return 0;
	end function;
	constant dummy : integer := check_constants;
begin
	mInt <= toint(m);
	nInt <= toint(n);
	
	process (clk)
	begin
		if (rising_edge(clk)) then
			case state is
				when Low =>
					s <= '0';
					counter <= counter + 1;
					
					if counter >= nInt*MINIMUM_DURATION_CLK-1 then
						counter <= 0;
						
						if mInt /= 0 then
							state <= High;
						end if;
					end if;
					
				when High =>
					s <= '1';
					counter <= counter + 1;
					
					if counter >= mInt*MINIMUM_DURATION_CLK-1 then
						counter <= 0;
						
						if nInt /= 0 then
							state <= Low;
						end if;
					end if;
			end case;
		end if;
	end process;
end Behavioral;

