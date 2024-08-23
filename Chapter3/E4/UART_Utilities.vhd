library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.Utilities.all;

package UART_Utilities is
	type UARTDurationRepresentation_T is (UARTBit, Clock);
	type UARTDuration_T is record
		value : positive;
		representation : UARTDurationRepresentation_T;
	end record UARTDuration_T;  
	
	-- ** Start of User parameters **
	-- Clock frequency of system in Hz
	constant CLK_FREQ : positive := 24_000_000;
	
	---- Receive:
	constant DATA_LENGTH_RECEIVE : positive := 8;
	constant BUAD_RATE_RECEIVE : positive := 115_200;
	
	-- Length of start bit in clocks or UART Bit
	constant START_BIT_COUNT_RECEIVE : UARTDuration_T := (1, UARTBit);
	
	-- Length of stop bit only in UART Bit, it can be zero
	-- If length of stop bit is more than 0, stop bit(s) will be checked to be 1 after receiving a frame
	-- If length of stop bit is 0, frameError port will always be 0
	constant STOP_BIT_COUNT_RECEIVE : natural := 1;
	
	
	-- If USE_RECEIVE_PARAMETERS_FOR_TRANSMIT is true, ignore the rest of parameters
	-- If stop bit in receive is 0 and USE_RECEIVE_PARAMETERS_FOR_TRANSMIT is true,
	-- stop bit in transmit will be 1 clock
	constant USE_RECEIVE_PARAMETERS_FOR_TRANSMIT : boolean := true;
	-- Give a valid value to below parameters if USE_RECEIVE_PARAMETERS_FOR_TRANSMIT is false
	---- Send:
	constant DATA_LENGTH_TRANSMIT : positive := 14;
	constant BUAD_RATE_TRANSMIT : positive := DATA_LENGTH_RECEIVE;
	constant START_BIT_COUNT_TRANSMIT : UARTDuration_T := (1, UARTBit);
	constant STOP_BIT_COUNT_TRANSMIT : UARTDuration_T := (1, Clock);
	-- ** End of User parameters **
	
	function NormalizeUARTDuration (
		startBitCount : UARTDuration_T;
		buadRate : positive
	) return positive;
	
	function CheckPriority_dataLength (parameter : positive) return positive;
	function CheckPriority_baudRate (parameter : positive) return positive;
	function CheckPriority_startBitCount (parameter : UARTDuration_T) return UARTDuration_T;
	function CheckPriority_stopBitCount (parameter : UARTDuration_T) return UARTDuration_T;
end UART_Utilities;

package body UART_Utilities is
	-- Convert UARTBit to clock if duration represented in UARTBit, else return value unchanged
	function NormalizeUARTDuration (
		bitCount : UARTDuration_T;
		buadRate : positive
	) return positive is
		variable result : positive;
	begin
		if bitCount.representation = Clock then
			result := bitCount.value;
		elsif bitCount.representation = UARTBit then
			result := CLK_FREQ/buadRate * bitCount.value;
		end if;
		
		return result;
	end NormalizeUARTDuration;
	
	-- CheckPriority functions return value of corresponding receive parameter if USE_RECEIVE_PARAMETERS_FOR_TRANSMIT is true
	-- if USE_RECEIVE_PARAMETERS_FOR_TRANSMIT is flase, this functions return given parameter unchanged
	function CheckPriority_dataLength (parameter : positive) return positive is
		variable result : positive;
	begin
		if USE_RECEIVE_PARAMETERS_FOR_TRANSMIT then
			result := DATA_LENGTH_RECEIVE;
		else
			result := parameter;
		end if;
		
		return result;
	end CheckPriority_dataLength;
	
	function CheckPriority_baudRate (parameter : positive) return positive is
		variable result : positive;
	begin
		if USE_RECEIVE_PARAMETERS_FOR_TRANSMIT then
			result := BUAD_RATE_RECEIVE;
		else
			result := parameter;
		end if;
		
		return result;
	end CheckPriority_baudRate;
	
	function CheckPriority_startBitCount (parameter : UARTDuration_T) return UARTDuration_T is
		variable result : UARTDuration_T;
	begin
		if USE_RECEIVE_PARAMETERS_FOR_TRANSMIT then
			result := START_BIT_COUNT_RECEIVE;
		else
			result := parameter;
		end if;
		
		return result;
	end CheckPriority_startBitCount;
	
	function CheckPriority_stopBitCount (parameter : UARTDuration_T) return UARTDuration_T is
		variable result : UARTDuration_T;
	begin
		if USE_RECEIVE_PARAMETERS_FOR_TRANSMIT then
			-- Receive stop bit can be 0, but transmit stop bit must be at least 1
			result.value 			:= maximum(1, STOP_BIT_COUNT_RECEIVE);
			result.representation 	:= UARTBit;
		else
			result := parameter;
		end if;
		
		return result;
	end CheckPriority_stopBitCount;
end UART_Utilities;
