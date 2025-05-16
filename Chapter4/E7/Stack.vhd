library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Stack is
	generic (
		BIT_COUNT : natural := 8;
		ELEMENT_COUNT : natural := 16
	);
	port (
		i_clk : in std_logic;
		i_reset : in std_logic;
		i_push, i_pop : in std_logic;
		i_pushData : in std_logic_vector(BIT_COUNT-1 downto 0);
		o_popData : out std_logic_vector(BIT_COUNT-1 downto 0);
		o_empty, o_full : out std_logic
	);
end Stack;

architecture Behavioral of Stack is
	type registerFile_T is array (0 to ELEMENT_COUNT-1) of std_logic_vector(BIT_COUNT-1 downto 0);
	signal regArray : registerFile_T;
	
	signal indexCounter : natural range 0 to ELEMENT_COUNT := 0;
	
	signal empty, full : std_logic;
begin
	o_full <= full;
	o_empty <= empty;
	
	full <= '1' when indexCounter = ELEMENT_COUNT else '0';
	empty <= '1' when indexCounter = 0 else '0';
	
	process (i_clk)
	begin
		if rising_edge(i_clk) then
			if i_reset = '1' then
				regArray <= (others => (others => '0'));
				o_popData <= (others => '0');
				indexCounter <= 0;
			else
				if i_push = '1' and i_pop = '1' then
					o_popData <= i_pushData;
				else
					if i_push = '1' and full /= '1' then
						regArray(indexCounter) <= i_pushData;
						indexCounter <= indexCounter + 1;
					end if;
					
					if i_pop = '1' and empty /= '1' then
						o_popData <= regArray(indexCounter-1);
						indexCounter <= indexCounter - 1;
					end if;
				end if;
			end if;
		end if;
	end process;
end Behavioral;

