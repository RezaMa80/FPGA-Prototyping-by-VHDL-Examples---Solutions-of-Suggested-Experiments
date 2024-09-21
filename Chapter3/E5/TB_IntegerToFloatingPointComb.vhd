LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use std.textio.all;
use ieee.math_real.all;
USE ieee.fixed_pkg.ALL;
use work.Utilities.ALL;
 
ENTITY TB_IntegerToFloatingPointComb IS
END TB_IntegerToFloatingPointComb;
 
ARCHITECTURE sim OF TB_IntegerToFloatingPointComb IS 
	constant sampleCount : positive := 10;
	constant stepTime : time := 10 ns;
		
	-- Component Declaration for the Unit Under Test (UUT)
	component IntegerToFloatingPointComb is
		port (
			int : in std_logic_vector(7 downto 0);
			float : out std_logic_vector(12 downto 0)
		);
	end component;
	
	file bitsFile : text open read_mode is "random01.txt";
	
	--Input
	signal int : std_logic_vector(7 downto 0); 
	
	--Output
	signal float : std_logic_vector(12 downto 0);
	
	signal sampleCounter : natural := 0;
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: IntegerToFloatingPointComb
	PORT MAP (
		int 	=> int,
		float 	=> float
	);
	
	driveInputs_proc:
	process
		variable temp1, temp2 : std_logic_vector(6 downto 0);
	begin
		while sampleCounter < sampleCount loop
			int <= readSLV(bitsFile, 8);
			
			wait for stepTime;
				
			sampleCounter <= sampleCounter + 1;
		end loop;
		
		EndSim;
	end process;

	checkOutputs_proc:
	process
		variable errorCount : natural := 0;
		
		variable intReal : real := 0.0;
		variable floatReal : real := 0.0;
		variable mantissa : real := 0.0;
		variable mantissaF : sFixed(0 downto -8);
	begin		
		wait for stepTime/2;
		
		loop
			-- mantissa = 0.frac
			mantissaF := to_sFixed('0' & float(7 downto 0), 0, -8);
			mantissa := to_real(mantissaF);
			floatReal := ((-1.0)**toint(float(12)))*mantissa*(2.0**toint(float(11 downto 8)));
			
			intReal := to_real(to_sFixed(int, 7, 0));
			
			if floatReal /= intReal then
				report "Invalid result:"
					& " <-{int=" & tostr(int, true, true)
					& "}, ->{output=" & tostr(float, false, true) & "}"
					severity warning;
				errorCount := errorCount + 1;
			end if;
			
			if sampleCounter = sampleCount then
				report "Number of invalid results: " & tostr(errorCount);
			end if;
		
			wait for stepTime;
		end loop;
	end process;
END;


