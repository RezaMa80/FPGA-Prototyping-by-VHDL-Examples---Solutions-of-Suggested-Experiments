library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity debounce_with_dual_edge_test is
    port (
        clk: in  std_logic;
        i_btn: in  std_logic_vector(3 downto 0);
        an: out std_logic_vector(3 downto 0);
        sseg: out std_logic_vector(7 downto 0)
    );
end debounce_with_dual_edge_test;

architecture arch of debounce_with_dual_edge_test is
    signal q1_reg, q1_next : unsigned(7 downto 0);
    signal q0_reg, q0_next : unsigned(7 downto 0);
    signal b_count, d_count : std_logic_vector(7 downto 0);
    signal btn_reg  : std_logic;
    signal db_tick, btn_tick, clr : std_logic;
	signal btn:   std_logic_vector(3 downto 0);
begin
	btn <= not i_btn;
	-- instantiate debouncing circuit
    db_unit : entity work.debouncer
        port map (
            i_clk=> clk, i_reset=>'0', i_button=> btn(1),
			o_debouncedButton=> open, o_risingEdge=>db_tick
		);
    -- instantiate hex display time-multiplexing unit
    disp_unit : entity work.disp_hex_mux
        port map (
            clk=> clk, reset=>'0',
            hex3=>b_count(7 downto 4),hex2=>b_count(3 downto 0),
            hex1=>d_count(7 downto 4),hex0=>d_count(3 downto 0),
            dp_in=>"1011", an=>an, sseg=>sseg
		);
	

	--=================================================
    -- edge detection circuits
	--=================================================
    process(clk)
    begin
        if (clk'event and clk='1') then
            btn_reg <= btn(1);
        end if;
    end process;
    btn_tick <= (not btn_reg) and btn(1);
	
	--=================================================
	-- two counters
	--=================================================
	clr <= btn(0);
	process(clk)
	begin
		if (clk'event and clk = '1') then
			q1_reg <= q1_next;
			q0_reg <= q0_next;
		end if;
	end process;
	-- next-state logic for counter
	q1_next <= (others => '0') when clr = '1' else
				q1_reg + 1 when btn_tick = '1' else
				q1_reg;

	q0_next <= (others => '0') when clr = '1' else
				q0_reg + 1 when db_tick = '1' else
				q0_reg;

	--output
	b_count <= std_logic_vector(q1_reg);
	d_count <= std_logic_vector(q0_reg);
end arch;