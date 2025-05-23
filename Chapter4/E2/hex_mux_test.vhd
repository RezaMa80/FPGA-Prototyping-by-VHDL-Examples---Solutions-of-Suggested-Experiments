library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity hex_mux_test is
    port (
        clk: in std_logic;
        sw: in std_logic_vector(7 downto 0);
        an: out std_logic_vector(3 downto 0);
        sseg: out std_logic_vector(7 downto 0)
    );
end hex_mux_test;

architecture arch of hex_mux_test is
	constant DUTY_CYCLE : std_logic_vector(3 downto 0) := "0001";
    signal a, b: unsigned(7 downto 0);
    signal sum: std_logic_vector(7 downto 0);
begin
    disp_unit : entity work.disp_hex_mux
        port map (
            clk=>clk, reset => '0',
            hex3=>sum(7 downto 4), hex2=>sum(3 downto 0),
            hex1=>sw(7 downto 4), hex0=>sw(3 downto 0),
            dp_in=>"1011", an=>an, sseg=>sseg,
			
			i_w => DUTY_CYCLE
		);
	a <= "0000" & unsigned(sw(3 downto 0));
    b <= "0000" & unsigned(sw(7 downto 4));
    sum <= std_logic_vector(a + b);
end arch;
