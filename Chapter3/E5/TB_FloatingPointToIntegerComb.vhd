LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use std.textio.all;
use ieee.math_real.all;
USE ieee.fixed_pkg.ALL;
use work.Utilities.ALL;
 
ENTITY TB_FloatingPointToIntegerComb IS
END TB_FloatingPointToIntegerComb;
 
ARCHITECTURE sim OF TB_FloatingPointToIntegerComb IS 
	constant sampleCount : positive := 100;
	constant stepTime : time := 10 ns;
		
	-- Component Declaration for the Unit Under Test (UUT)
	component FloatingPointToIntegerComb is
		port (
			float 		: in 	std_logic_vector(12 downto 0);
			int 		: out 	std_logic_vector(7 	downto 0);
			underflow	: out 	std_logic;
			overflow 	: out 	std_logic
		);
	end component;
	
	file bitsFile : text open read_mode is "random01.txt";
	
	--Input
	signal float : std_logic_vector(12 downto 0) := (others => '0'); 
	alias sign : std_logic is float(12);
	alias exp : std_logic_vector(11 downto 8) is float(11 downto 8);
	alias frac : std_logic_vector(7 downto 0) is float(7 downto 0);
	
	--Output
	signal int : std_logic_vector(7 downto 0);
	signal underflow, overflow : std_logic;
	
	signal sampleCounter : natural := 0;
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: FloatingPointToIntegerComb
	PORT MAP (
		float 		=> float,
		int 		=> int,
		underflow 	=> underflow,
		overflow 	=> overflow
	);
	
	driveInputs_proc:
	process
		variable temp : std_logic_vector(6 downto 0);
	begin
		while sampleCounter < sampleCount loop
			sign <= readSLV(bitsFile, 1)(0);
			exp <= readSLV(bitsFile, exp'LENGTH);
			temp := readSLV(bitsFile, temp'LENGTH);
			
			if temp = "0000000" then
				frac <= (others => '0');
				exp <= (others => '0'); 
			else
				frac <= '1' & temp;
			end if;
			
			wait for stepTime;
				
			sampleCounter <= sampleCounter + 1;
		end loop;
		
		EndSim;
	end process;

	checkOutputs_proc:
	process
		variable errorCount : natural := 0;
		variable currentSampleError : boolean := false;
		
		variable intReal : real := 0.0;
		variable floatReal : real := 0.0;
		variable mantissa : real := 0.0;
		variable mantissaF : sFixed(0 downto -8);
		variable calculatedUnderflow, calculatedOverflow : std_logic;
	begin		
		wait for stepTime/2;
		
		loop
			currentSampleError := false;
			calculatedUnderflow := '0';
			calculatedOverflow := '0';
			
			-- mantissa = 0.frac
			mantissaF := to_sFixed('0' & frac, 0, -8);
			mantissa := to_real(mantissaF);
			floatReal := ((-1.0)**toint(sign))*mantissa*(2.0**toint(exp));
			
			intReal := to_real(to_sFixed(int, 7, 0));
			
			if ((floatReal > 0.0) and (floatReal < 1.0)) or ((floatReal < 0.0) and (floatReal > -1.0)) then
				calculatedUnderflow := '1';
			elsif (floatReal > 127.0) or (floatReal < -128.0) then
				calculatedOverflow := '1';
			end if;
			
			if (calculatedUnderflow /= underflow) or (calculatedOverflow /= overflow) then
				currentSampleError := true;
				errorCount := errorCount + 1;
			end if;
			
			if not currentSampleError then
				if ((underflow = '0') and (overflow = '0')) and (trunc(floatReal) /= intReal) then
					currentSampleError := true;
					errorCount := errorCount + 1;
				end if;
			end if;
			
			if currentSampleError then
				report "Invalid result:"
					& " <-{float=" & tostr(float, false, true)
					& "}, ->{[int=" & tostr(int, true) & "], [Expected int=" & tostr(int, true) & "]"
					& "}, ->{[underflow=" & tostr(underflow) & "], [Expected underflow=" & tostr(calculatedUnderflow) & "]"
					& "}, ->{[overflow=" & tostr(overflow) & "], [Expected overflow=" & tostr(calculatedOverflow) & "]"
					& "}"
					severity warning;
			end if;
			
			if sampleCounter = sampleCount then
				report "Number of invalid results: " & tostr(errorCount);
			end if;
		
			wait for stepTime;
		end loop;
	end process;
END;


