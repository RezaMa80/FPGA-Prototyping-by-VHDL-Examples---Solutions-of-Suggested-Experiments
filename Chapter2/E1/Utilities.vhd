library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_std.all;

package Utilities is

	function nat2slv  (int : natural; len : natural) return std_logic_vector;
	function uslv2str  (uslv : std_logic_vector) return string;
	function int2str  (int : natural) return string;
	procedure EndSim ;

end Utilities;

package body Utilities is

	function nat2slv  (int : natural; len : natural) return std_logic_vector is
	begin
		return std_logic_vector(to_unsigned(int, len));
	end nat2slv;
	
	function int2str  (int : natural) return string is
	begin
		return integer'image(int);
	end int2str;
	
	function uslv2str  (uslv : std_logic_vector) return string is
	begin
		return int2str(to_integer(unsigned(uslv)));
	end uslv2str;
	
	
	procedure EndSim  is
	begin
		report "This isn't a real failure, end of the simulation." severity failure;
	end EndSim;
 
end Utilities;
