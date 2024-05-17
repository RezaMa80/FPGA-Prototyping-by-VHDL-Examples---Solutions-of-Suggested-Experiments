LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
use work.Utilities.all;
 
ENTITY GreaterThanTestbench IS
END GreaterThanTestbench;
 
ARCHITECTURE Simulation OF GreaterThanTestbench IS 
	type modules_T is (TwoBit, FourBit);
	
	function moduleLength (module : modules_T) 
		return natural is
	begin
		if module = TwoBit then
			return 2;
		elsif module = FourBit then
			return 4;
		end if;
	end moduleLength;
	
	constant module : modules_T := FourBit;
	constant stepTime : time := 10 ns;
	
	constant inputLength : integer := moduleLength(module);
	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT TwoBitGreaterThan
	PORT(
		 A : IN  std_logic_vector(inputLength-1 downto 0);
		 B : IN  std_logic_vector(inputLength-1 downto 0);
		 AIsGreaterThanB : OUT  std_logic
		);
	END COMPONENT;
	
	COMPONENT FourBitGreaterThan
	PORT(
		 A : IN  std_logic_vector(inputLength-1 downto 0);
		 B : IN  std_logic_vector(inputLength-1 downto 0);
		 AIsGreaterThanB : OUT  std_logic
		);
	END COMPONENT;


	--Inputs
	signal A : std_logic_vector(inputLength-1 downto 0) := (others => '0');
	signal B : std_logic_vector(inputLength-1 downto 0) := (others => '0');

	--Outputs
	signal AIsGreaterThanB : std_logic;
	
	constant one : std_logic_vector(A'range) := (others => '1');
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
	chooseModule:
	if module = FourBit generate
		uut: FourBitGreaterThan
		PORT MAP (
			A => A,
			B => B,
			AIsGreaterThanB => AIsGreaterThanB
		);
	elsif module = TwoBit generate
		uut: FourBitGreaterThan
		PORT MAP (
			A => A,
			B => B,
			AIsGreaterThanB => AIsGreaterThanB
		);
	end generate;

	-- Stimulus process
	drive_inputs:
	process
		variable a_int, b_int : natural := 0;
	begin
		a <= nat2slv(a_int, a'length);
		b <= nat2slv(b_int, b'length);

		wait for stepTime;
		b_int := b_int + 1;

		if b = one then
			b_int := 0;
			a_int := a_int + 1;
			if a = one then
				EndSim;
			end if;
		end if;
	end process;
	
	check_outputs:
	process 
		variable errorCount : natural := 0;
	begin
		wait for stepTime/2;
		loop

			if (a > b) then
				if (AIsGreaterThanB = '0') then
					report "Invalid result for: A=" & uslv2str(a) & ", B=" & uslv2str(b) severity warning;
				end if;
			end if;
			
			if (AIsGreaterThanB = '1') then
				if (a < b) then
					report "Invalid result for: A=" & uslv2str(a) & ", B=" & uslv2str(b) severity warning;
				end if;
			end if;
			
			if (a = one) and (b = one) then
				report "Number of invalid results: " & int2str(errorCount);
			end if;
			wait for stepTime;
		end loop;
	end process;
END;
