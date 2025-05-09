library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity enhanced_stop_watch is
    port (
        clk: in std_logic;
        go, clr, i_direction: in std_logic;
        d3, d2, d1, d0: out std_logic_vector(3 downto 0)
    );
end enhanced_stop_watch;

architecture cascade_arch of enhanced_stop_watch is
    constant DVSR : integer:=5000000;

    signal ms_reg, ms_next: unsigned(22 downto 0);
	
    signal d3_reg, d1_reg, d0_reg: unsigned(3 downto 0);
    signal d2_reg: unsigned(2 downto 0);
	
    signal d3_next, d1_next, d0_next: unsigned(3 downto 0);
    signal d2_next: unsigned(2 downto 0);
	
    signal ms_tick, d0_tick, d1_tick, d2_tick: std_logic;
    signal d0_en, d1_en, d2_en, d3_en: std_logic;
begin
    -- register
    process(clk)
    begin
        if (clk'event and clk='1') then
            ms_reg <= ms_next;
            d0_reg <= d0_next;
            d1_reg <= d1_next;
            d2_reg <= d2_next;
            d3_reg <= d3_next;
        end if;
    end process;
	
	-- next-state logic
    -- 0.1 second tick generator: mod-5000000
    ms_next <= 
		(others => '0') when clr='1' or
							(ms_reg=DVSR and go='1') else
         ms_reg + 1 when go = '1' else
         ms_reg;
    ms_tick <= '1' when ms_reg=DVSR else '0';
    -- 0.1 second counter
    d0_en <= '1' when ms_tick='1' else '0';
    d0_next <= 
		"0000" when (clr='1') or (d0_en='1' and d0_reg=9 and i_direction = '0') else
		"1001" when d0_en='1' and d0_reg=0 and i_direction = '1' and (not (d1_reg = 0 and d2_reg = 0 and d3_reg = 0)) else
        d0_reg + 1 when d0_en='1' and i_direction = '0' else
        d0_reg - 1 when d0_en='1' and i_direction = '1' and (not (d0_reg=0 and d1_reg = 0 and d2_reg = 0 and d3_reg = 0)) else
        d0_reg;

    d0_tick <=	'1' when d0_reg=9 and i_direction = '0' else
				'1' when d0_reg=0 and i_direction = '1' and (not (d1_reg = 0 and d2_reg = 0 and d3_reg = 0)) else '0';
				
	-- 1 second counter
    d1_en <= '1' when ms_tick='1' and d0_tick='1' else '0';
    d1_next <= 
		"0000" when clr='1' or (d1_en='1' and d1_reg=9 and i_direction = '0') else
		"1001" when d1_en='1' and d1_reg=0 and i_direction = '1' else
         d1_reg + 1 when d1_en='1' and i_direction = '0' else
         d1_reg - 1 when d1_en='1' and i_direction = '1' else
         d1_reg;
		 
	d1_tick <=	'1' when d1_reg=9 and i_direction = '0' else
				'1' when d1_reg=0 and i_direction = '1' else '0';
				
	-- 10 second counter
    d2_en <=
		'1' when ms_tick='1' and d0_tick='1' and d1_tick='1' else
		'0';
    d2_next <=
		"000" when clr='1' or (d2_en='1' and d2_reg=5 and i_direction = '0') else
		"101" when d2_en='1' and d2_reg=0 and i_direction = '1' else
        d2_reg + 1 when d2_en='1' and i_direction = '0' else
        d2_reg - 1 when d2_en='1' and i_direction = '1' else
        d2_reg;
	
	d2_tick <=	'1' when d2_reg=5 and i_direction = '0' else
				'1' when d2_reg=0 and i_direction = '1' else '0';
	
	-- Minute counter
    d3_en <=
		'1' when ms_tick='1' and d0_tick='1' and d1_tick='1' and d2_tick='1' else
		'0';
    d3_next <=
		"0000" when clr='1' or (d3_en='1' and d3_reg=9 and i_direction = '0') else
        d3_reg + 1 when d3_en='1' and i_direction = '0' else
        d3_reg - 1 when d3_en='1' and i_direction = '1' else
        d3_reg;
		
    -- output logic
    d0 <= std_logic_vector(d0_reg);
    d1 <= std_logic_vector(d1_reg);
    d2 <= '0' & std_logic_vector(d2_reg);
    d3 <= std_logic_vector(d3_reg);
end cascade_arch;