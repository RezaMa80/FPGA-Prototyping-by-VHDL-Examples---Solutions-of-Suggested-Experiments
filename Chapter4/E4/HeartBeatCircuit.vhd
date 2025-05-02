library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HeartBeatCircuit is
    port (
        i_clk : in std_logic;

        o_select: out std_logic_vector(3 downto 0);
        o_sevenSegment: out std_logic_vector(7 downto 0)
	);
end HeartBeatCircuit;

architecture arch of HeartBeatCircuit is
	constant CLK_FREQ : positive := 50_000_000;
	constant HEART_BEAT_FREQ : positive := 72;
	
	constant HEART_BEAT_CLK : positive := CLK_FREQ/HEART_BEAT_FREQ/3;
	
	signal state : std_logic_vector(2 downto 0) := "100";
	
	signal side : std_logic := '0';
	signal stateCounter : natural range 0 to HEART_BEAT_CLK-1 := 0;
	signal sideSwitchCounter : natural range 0 to 50_000-1 := 0;
begin
	process (i_clk)
	begin
		if rising_edge(I_clk) then
			if state(0) = '1' then
				if side = '0' then
					o_select <= "1011";
					o_sevenSegment <= "11111001";
				else
					o_select <= "1101";
					o_sevenSegment <= "11001111";
				end if;
			end if;
			
			if state(1) = '1' then
				if side = '0' then
					o_select <= "1011";
					o_sevenSegment <= "11001111";
				else
					o_select <= "1101";
					o_sevenSegment <= "11111001";
				end if;
			end if;
			
			if state(2) = '1' then
				if side = '0' then
					o_select <= "0111";
					o_sevenSegment <= "11001111";
				else
					o_select <= "1110";
					o_sevenSegment <= "11111001";
				end if;
			end if;
			
			-- To meet 7segment or any transistor hold/setup time, a delay added
			sideSwitchCounter <= sideSwitchCounter + 1;
			if sideSwitchCounter >= 50_000-1 then
				side <= not side;
				sideSwitchCounter <= 0;
			end if;
		end if;
	end process;
	
	process (i_clk)
	begin
		if rising_edge(i_clk) then
			stateCounter <= stateCounter + 1;
			if stateCounter >= HEART_BEAT_CLK-1 then
				state <= state(1 downto 0) & state(2);
				stateCounter <= 0;
			end if;
		end if;
	end process;
end arch;
