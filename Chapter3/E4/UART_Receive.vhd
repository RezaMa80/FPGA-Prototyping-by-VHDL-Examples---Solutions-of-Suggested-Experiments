library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.UART_Utilities.ALL;
use work.Utilities.ALL;

entity UART_Receive is
	port (
		i_clk : in std_logic;
		i_rx : in std_logic;
		
		o_data	: out std_logic_vector(DATA_LENGTH_RECEIVE-1 downto 0);
		o_dataValid : out std_logic;
		o_frameError  : out std_logic
	);
end UART_Receive;

architecture fpga of UART_Receive is
	constant DATA_LENGTH 		: positive 			:= DATA_LENGTH_RECEIVE;
	constant BUAD_RATE 			: positive 			:= BUAD_RATE_RECEIVE;
	constant START_BIT_COUNT 	: UARTDuration_T 	:= START_BIT_COUNT_RECEIVE;
	constant STOP_BIT_COUNT 	: natural 			:= STOP_BIT_COUNT_RECEIVE;
	
	constant START_BIT_COUNT_NORMALIZED : positive := NormalizeUARTDuration(START_BIT_COUNT, BUAD_RATE);
	
	constant CLK_PER_BIT : integer := CLK_FREQ/BUAD_RATE;
	
	type state_T is (Idle, StartBit, DataBit, StopBit, WaitForIdle);
	signal state : state_T;
	
	signal dataCounter : natural range 0 to maximum(STOP_BIT_COUNT, DATA_LENGTH-1) := 0;
	
	signal counter : natural range 0 to maximum(CLK_PER_BIT-1, START_BIT_COUNT_NORMALIZED/2-1):= 0;
	
	signal data : std_logic_vector(DATA_LENGTH-1 downto 0);
begin
	process (i_clk)
		variable frameError : boolean := false;
	begin
		if (rising_edge(i_clk)) then
			case state is
				when Idle =>
					frameError := false;
					
					o_frameError <= '0';
					o_dataValid <= '0';

					if i_rx = '0' then
						-- Switching cases will take 1 clock, so if start bit length is 1 clock,
						-- we should bypass StartBit state
						if START_BIT_COUNT_NORMALIZED <= 1 then
							state <= DataBit;
						else
							state <= StartBit;
						end if;
					end if;
					
				when StartBit =>
					counter <= counter + 1;
					
					if counter >= START_BIT_COUNT_NORMALIZED/2-1 then
						state <= DataBit;
						counter <= 0;
					end if;
					
				when DataBit =>
					counter <= counter + 1;

					if counter >= CLK_PER_BIT-1 then
						counter <= 0;
						
						if DATA_LENGTH > 1 then
							data <= i_rx & data(DATA_LENGTH-1 downto 1);
						else
							data(0) <= i_rx;
						end if;

						if dataCounter >= DATA_LENGTH-1 then
							dataCounter <= 0;
							state <= StopBit;
						else
							dataCounter <= dataCounter + 1;
						end if;
					end if;
				
				when StopBit =>					
					counter <= counter + 1;
					
					if dataCounter < STOP_BIT_COUNT then
						if counter >= CLK_PER_BIT-1 then
							counter <= 0;
							dataCounter <= dataCounter + 1;
							
							if i_rx = '0' then
								frameError := true;
							end if;
						end if;
					else
						counter <= 0;
						dataCounter <= 0;
						
						o_frameError <= tosl(frameError);
						
						if not frameError then
							o_data <= data;
							o_dataValid <= '1';
						end if;
						
						-- If current value if rx is '1', go to idle already
						if i_rx = '1' then
							state <= Idle;
						else
							state <= WaitForIdle;
						end if;
					end if;
					
				when WaitForIdle =>
					o_frameError <= '0';
					o_dataValid <= '0';
					if i_rx = '1' then
						state <= Idle;
					end if;
			end case;
		end if;
	end process;
end fpga;

