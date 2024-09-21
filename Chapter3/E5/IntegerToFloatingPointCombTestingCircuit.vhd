library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.UART_UTILITIES.ALL;
use work.UTILITIES.ALL;

entity IntegerToFloatingPointCombTestingCircuit is
	port (
		i_clk : in std_logic;
		i_rx : in std_logic;
		o_tx : out std_logic
	);
end IntegerToFloatingPointCombTestingCircuit;

architecture Behavioral of IntegerToFloatingPointCombTestingCircuit is
	component UART_Receive is
		port (
			i_clk : in std_logic;
			i_rx : in std_logic;
			
			o_data	: out std_logic_vector(DATA_LENGTH_RECEIVE-1 downto 0);
			o_dataValid : out std_logic;
			o_frameError  : out std_logic
		);
	end component UART_Receive;
	
	component UART_Transmit is
		port (
			i_clk : in std_logic;
			o_tx : out std_logic;
			
			i_data	: in std_logic_vector(CheckPriority_dataLength(DATA_LENGTH_TRANSMIT)-1 downto 0);
			i_dataValid : in std_logic;
			o_busy  : out std_logic
		);
	end component UART_Transmit;

	component IntegerToFloatingPointComb is
		port (
			int : in std_logic_vector(7 downto 0);
			float : out std_logic_vector(12 downto 0)
		);
	end component IntegerToFloatingPointComb;
	
	signal uartTransmit_busy : std_logic;
	signal UARTReceive_dataValid, UARTTransmit_dataValid : std_logic;
	signal UARTReceive_data, UARTTransmit_data : std_logic_vector(DATA_LENGTH_RECEIVE-1 downto 0) := (others => '0');
	
	-- uut signals
	signal float : std_logic_vector(12 downto 0);
	signal int : std_logic_vector(7 downto 0);
	
	-- Handling received data
	type state_T is (waitForRec, TransmitPart1, TransmitPart2);
	signal state : state_T;
begin

	uut: IntegerToFloatingPointComb
	PORT MAP (
		int 	=> int,
		float 	=> float
	);
		
	uartTransmit: UART_Transmit
	port map (
		i_clk => i_clk,
		o_tx => o_tx,
		
		i_data => UARTTransmit_data,
		i_dataValid => UARTTransmit_dataValid,
		o_busy => uartTransmit_busy
	);
	
	uartReceive: UART_Receive
	port map (
		i_clk => i_clk,
		i_rx => i_rx,
		
		o_data => UARTReceive_data,
		o_dataValid => UARTReceive_dataValid,
		o_frameError => open
	);
	
	-- Reading a number:
	---- First byte: 	00 | Sign (1) | Exponential Part (4) | Fractional Part[7] (1)
	---- Second byte: 	1 | Fractional Part[6 downto 0] (7)
	process (i_clk)
		variable numberSelectVar : natural range 0 to 1;
	begin
		if rising_edge(i_clk) then
			case state is
				when waitForRec =>
					UARTTransmit_dataValid <= '0';
					
					if UARTReceive_dataValid = '1' then
						int <= UARTReceive_data;
						
						state <= TransmitPart1; 
					end if;
				
				when TransmitPart1 =>
					if uartTransmit_busy = '0' then
						UARTTransmit_dataValid <= '1';
						UARTTransmit_data <= "00" & float(12 downto 7);
						
						state <= TransmitPart2; 
					end if;

				when TransmitPart2 =>
					UARTTransmit_dataValid <= '0';
					
					if uartTransmit_busy = '0' then
						UARTTransmit_dataValid <= '1';
						UARTTransmit_data <= '1' & float(6 downto 0);
						
						state <= waitForRec; 
					end if;
			end case;
		end if;
	end process;
end Behavioral;
