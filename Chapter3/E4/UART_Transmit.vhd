library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.UART_Utilities.ALL;
use work.Utilities.ALL;

entity UART_Transmit is
	port (
		i_clk : in std_logic;
		o_tx : out std_logic;
		
		i_data	: in std_logic_vector(CheckPriority_dataLength(DATA_LENGTH_TRANSMIT)-1 downto 0);
		i_dataValid : in std_logic;
		o_busy  : out std_logic
	);
end UART_Transmit;

architecture fpga of UART_Transmit is
	constant DATA_LENGTH 		: positive 			:= CheckPriority_dataLength(DATA_LENGTH_TRANSMIT);
	constant BUAD_RATE 			: positive 			:= CheckPriority_baudRate(BUAD_RATE_TRANSMIT);
	constant START_BIT_COUNT 	: UARTDuration_T 	:= CheckPriority_startBitCount(START_BIT_COUNT_TRANSMIT);
	constant STOP_BIT_COUNT 	: UARTDuration_T 	:= CheckPriority_stopBitCount(STOP_BIT_COUNT_TRANSMIT);
	
	constant START_BIT_COUNT_NORMALIZED : positive := NormalizeUARTDuration(START_BIT_COUNT_TRANSMIT, BUAD_RATE);
	constant STOP_BIT_COUNT_NORMALIZED : positive := NormalizeUARTDuration(STOP_BIT_COUNT_TRANSMIT, BUAD_RATE);
	
	constant CLK_PER_BIT : integer := CLK_FREQ/BUAD_RATE;
	
	type state_T is (Idle, StartBit, DataBit, StopBit);
	signal state : state_T;
	
	signal dataCounter : natural range 0 to DATA_LENGTH-1 := 0;
	
	signal counter : natural range 0 to maximum(CLK_PER_BIT-1, maximum(STOP_BIT_COUNT_NORMALIZED-1, START_BIT_COUNT_NORMALIZED-1)):= 0;
	
	signal data_r : std_logic_vector(DATA_LENGTH-1 downto 0);
begin
	process (i_clk)
	begin
		if (rising_edge(i_clk)) then
			case state is
				when Idle =>
					o_tx <= '1';
					o_busy <= '0';
					
					if i_dataValid = '1' then
						-- Switching cases will take 1 clock, so if start bit length is 1 clock,
						-- we should bypass StartBit state
						if START_BIT_COUNT_NORMALIZED <= 1 then
							state <= DataBit;
						else
							state <= StartBit;
						end if;
						
						data_r <= i_data;
						o_busy <= '1';
						o_tx <= '0';
					end if;
					
				when StartBit =>
					o_tx <= '0';
					
					counter <= counter + 1;
					
					if counter >= START_BIT_COUNT_NORMALIZED-2 then
						state <= DataBit;
						counter <= 0;
					end if;
					
				when DataBit =>
					o_tx <= data_r(dataCounter);
					counter <= counter + 1;

					if counter >= CLK_PER_BIT-1 then
						counter <= 0;

						if dataCounter >= DATA_LENGTH-1 then
							dataCounter <= 0;
							state <= StopBit;
						else
							dataCounter <= dataCounter + 1;
						end if;
					end if;
				
				when StopBit =>
					o_tx <= '1';
					counter <= counter + 1;
					
					if counter >= STOP_BIT_COUNT_NORMALIZED-1 then
						counter <= 0;
						state <= Idle;
					end if;
			end case;
		end if;
	end process;
end fpga;

