library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Parking_Lot_Occupancy_Counter is
	port (
        clk 	: in  std_logic;
        i_btn 	: in  std_logic_vector(1 downto 0);
        an 		: out std_logic_vector(3 downto 0);
        sseg 	: out std_logic_vector(7 downto 0)
    );
end Parking_Lot_Occupancy_Counter;

architecture Behavioral of Parking_Lot_Occupancy_Counter is
	signal counter : std_logic_vector(15 downto 0);
	signal newEnter : std_logic;
	signal newExit : std_logic;
	
	signal notBtn : std_logic_vector(i_btn'RANGE);
	signal debouncedButton : std_logic_vector(i_btn'RANGE);
begin
	notBtn <= not i_btn;
	
	Disp_Unit : entity work.disp_hex_mux
	port map (
		clk 	=> clk,
		reset 	=> '0',
		hex3 	=> counter(15 downto 12),
		hex2 	=> counter(11 downto 8),
		hex1 	=> counter(7 downto 4),
		hex0 	=> counter(3 downto 0),
		dp_in 	=> "1111",
		an 		=> an,
		sseg 	=> sseg
	);
	
	Counter_Unit : entity work.Counter16
	port map (
		i_clk 	=> clk,
		i_inc 	=> newEnter,
		i_dec 	=> newExit,
		o_count => counter
	);
	
	Traffic_Checker_Unit : entity work.Traffic_Cheker
	port map (
		i_clk 	=> clk,
		i_a 	=> debouncedButton(0),
		i_b 	=> debouncedButton(1),
		o_enter => newEnter,
		o_exit 	=> newExit
	);
	
	Button0_Debouncer : entity work.db_fsm
	port map (
		clk 	=> clk,
		reset 	=> '0',
		sw 	=> notBtn(0),
		db 	=> debouncedButton(0)
	);
	
	Button1_Debouncer : entity work.db_fsm
	port map (
		clk 	=> clk,
		reset 	=> '0',
		sw 	=> notBtn(1),
		db 	=> debouncedButton(1)
	);
end Behavioral;

