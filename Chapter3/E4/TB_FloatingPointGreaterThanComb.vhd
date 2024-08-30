LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use std.textio.all;
use ieee.math_real.all;
USE ieee.fixed_pkg.ALL;
use work.Utilities.ALL;
 
ENTITY TB_FloatingPointGreaterThanComb IS
END TB_FloatingPointGreaterThanComb;
 
ARCHITECTURE sim OF TB_FloatingPointGreaterThanComb IS 
	constant sampleCount : positive := 10;
	constant stepTime : time := 10 ns;
		
	-- Component Declaration for the Unit Under Test (UUT)
	component FloatingPointGreaterThanComb is
		port (
			sign1, sign2 	: in std_logic; 
			exp1, exp2 		: in std_logic_vector(3 downto 0); 
			frac1, frac2 	: in std_logic_vector(7 downto 0); 
			
			output			: out std_logic
		);
	end component;
	
	file bitsFile : text open read_mode is "random01.txt";
	
	--Input
	signal sign1, sign2 : std_logic;
	signal exp1, exp2 	: std_logic_vector(3 downto 0);
	signal frac1, frac2 : std_logic_vector(7 downto 0);
	
	--Output
	signal output : 	std_logic;
	
	signal sampleCounter : natural := 0;
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: FloatingPointGreaterThanComb
	PORT MAP (
		sign1 	=> sign1,
		sign2 	=> sign2,
		exp1 	=> exp1,
		exp2 	=> exp2,
		frac1 	=> frac1,
		frac2 	=> frac2,
		
		output 	=> output
	);
	
	driveInputs_proc:
	process
		variable temp1, temp2 : std_logic_vector(6 downto 0);
	begin
		while sampleCounter < sampleCount loop
			sign1 <= readSLV(bitsFile, 1)(0);
			sign2 <= readSLV(bitsFile, 1)(0);
			exp1 <= readSLV(bitsFile, exp1'LENGTH);
			exp2 <= readSLV(bitsFile, exp2'LENGTH);
			temp1 := readSLV(bitsFile, temp1'LENGTH);
			temp2 := readSLV(bitsFile, temp2'LENGTH);
			
			if temp1 = "0000000" then
				frac1 <= (others => '0');
			else
				frac1 <= '1' & temp1;
			end if;
			
			if temp2 = "0000000" then
				frac2 <= (others => '0');
			else
				frac2 <= '1' & temp2;
			end if;
			
			wait for stepTime;
				
			sampleCounter <= sampleCounter + 1;
		end loop;
		
		EndSim;
	end process;

	checkOutputs_proc:
	process
		variable errorCount : natural := 0;
		
		variable input1, input2 : real := 0.0;
		variable mantissa1, mantissa2 : real := 0.0;
		variable mantissaF1, mantissaF2 : sFixed(0 downto -8);
		variable calculatedOutput : STD_LOGIC := '0';
	begin		
		wait for stepTime/2;
		
		loop
			-- mantissa = 0.frac
			mantissaF1 := to_sFixed('0' & frac1, 0, -8);
			mantissaF2 := to_sFixed('0' & frac2, 0, -8);
			
			mantissa1 := to_real(mantissaF1);
			mantissa2 := to_real(mantissaF2);

			input1 := ((-1.0)**toint(sign1))*mantissa1*(2.0**toint(exp1));
			input2 := ((-1.0)**toint(sign2))*mantissa2*(2.0**toint(exp2));
			
			if input1 > input2 then
				calculatedOutput := '1';
			else
				calculatedOutput := '0';
			end if;
			
			if calculatedOutput /= output then
				report "Invalid result:"
					& " <-{sign1=" & tostr(sign1)
					& "}, <-{exp1=" & tostr(exp1)
					& "}, <-{frac1=" & tostr(mantissa1)
					& "}, <-{sign2=" & tostr(sign2)
					& "}, <-{exp2=" & tostr(exp2)
					& "}, <-{frac2=" & tostr(mantissa2)
					& "}, ->{[output=" & tostr(output) & "], [Expected output=" & tostr(calculatedOutput) & "]}"
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
