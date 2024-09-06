library IEEE;
-- In this design you can set 2 numbers using UART and receive an answer if number1 is greater than number2 (0x01 means true and 0x00 means false)
use IEEE.STD_LOGIC_1164.ALL;
use work.UART_UTILITIES.ALL;
use work.UTILITIES.ALL;

-- Warnings Explanation:
---- Data to transmit is only 1 bit but must be send in UART with 8 bit data.
---- This will cause some warnings about some signal being constant.

---- Using <uartTransmit/o_busy> and <uartReceive/o_frameError> was not necessary in this design and they were not used.
---- So there is warnings about not using these ports

entity FloatingPointGreaterThanCombTestingCircuit is
	port (
		i_clk : in std_logic;
		i_rx : in std_logic;
		o_tx : out std_logic
	);
end FloatingPointGreaterThanCombTestingCircuit;

architecture Behavioral of FloatingPointGreaterThanCombTestingCircuit is
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

	component FloatingPointGreaterThanComb is
		port (
			sign1, sign2 	: in std_logic; 
			exp1, exp2 		: in std_logic_vector(3 downto 0); 
			frac1, frac2 	: in std_logic_vector(7 downto 0); 
			
			output			: out std_logic
		);
	end component FloatingPointGreaterThanComb;
	
	signal UARTReceive_dataValid, UARTTransmit_dataValid : std_logic;
	signal UARTReceive_data, UARTTransmit_data : std_logic_vector(DATA_LENGTH_RECEIVE-1 downto 0) := (others => '0');
	
	-- FloatingPointGreaterThanComb_L signals
	type numbers_T is array (natural range <>) of std_logic_vector(12 downto 0);
	signal numbers : numbers_T(0 to 1);
	signal output : std_logic;
	
	
	-- Handling received data
	signal numberSelect : natural range 0 to 1;
	type dataState_T is (CommandAndPart1, Part2);
	signal dataState : dataState_T;
begin
	UARTTransmit_data(0) <= output;
	
	FloatingPointGreaterThanComb_L: FloatingPointGreaterThanComb
	port map (
		sign1 => numbers(0)(12),
		sign2 => numbers(1)(12),
		exp1 => numbers(0)(11 downto 8),
		exp2 => numbers(1)(11 downto 8),
		frac1 => numbers(0)(7 downto 0),
		frac2 => numbers(1)(7 downto 0),
		
		output => output
	);
		
	uartTransmit: UART_Transmit
	port map (
		i_clk => i_clk,
		o_tx => o_tx,
		
		i_data => UARTTransmit_data,
		i_dataValid => UARTTransmit_dataValid,
		o_busy => open
	);
	
	uartReceive: UART_Receive
	port map (
		i_clk => i_clk,
		i_rx => i_rx,
		
		o_data => UARTReceive_data,
		o_dataValid => UARTReceive_dataValid,
		o_frameError => open
	);
	
	-- Setting a number:
	---- First byte: 	00 | Number Select (1) | Sign (1) | Exponential Part (4)
	---- Second byte: 	Fractional Part (8)
	process (i_clk)
		variable numberSelectVar : natural range 0 to 1;
	begin
		if rising_edge(i_clk) then
			UARTTransmit_dataValid <= '0';
			
			if UARTReceive_dataValid = '1' then
				case dataState is
					when CommandAndPart1 =>
						if UARTReceive_data(7 downto 6) = "00" then
							numberSelectVar := toint(UARTReceive_data(5));
							
							numbers(numberSelectVar)(12 downto 8) <= UARTReceive_data(4 downto 0);
							numberSelect <= numberSelectVar;
							
							dataState <= Part2;
						end if;
					
					when Part2 =>
						numbers(numberSelect)(7 downto 0) <= UARTReceive_data;
						
						dataState <= CommandAndPart1;
				end case;
				
				UARTTransmit_dataValid <= '1';
			end if;
		end if;
	end process;
end Behavioral;
