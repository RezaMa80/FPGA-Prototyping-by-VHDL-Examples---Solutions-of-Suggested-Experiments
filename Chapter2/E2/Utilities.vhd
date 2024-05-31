library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_std.all;

package Utilities is

	function toslv (
		int : integer;
		len : natural;
		sign : boolean := false
	) return std_logic_vector;
	
	function toint (
		slv : std_logic_vector;
		sign : boolean := false
	) return integer;
	
	-- To String
	function tostr (int	: integer) 		return string;
	
	function tostr (sl 	: std_logic) 	return string;
	
	function tostr (
		slv : std_logic_vector;
		sign : boolean := false
	) return string;
	
	procedure EndSim ;

end Utilities;

package body Utilities is
	function toslv (
		int : integer;
		len : natural;
		sign : boolean := false
	) return std_logic_vector is
	begin
		if sign then
			return std_logic_vector(to_signed(int, len));
		else
			return std_logic_vector(to_unsigned(int, len));
		end if;
	end toslv;
	
	function toint (
		slv : std_logic_vector;
		sign : boolean := false
	) return integer is
	begin
		if sign then
			return to_integer(signed(slv));
		else
			return to_integer(unsigned(slv));
		end if;
	end toint;
	
	function tostr (int : integer) return string is
	begin
		return integer'image(int);
	end tostr;
	
	function tostr (
		slv : std_logic_vector;
		sign : boolean := false
	) return string is
	begin
		if sign then
			return integer'image(to_integer(signed(slv)));
		else
			return integer'image(to_integer(unsigned(slv)));
		end if;
	end tostr;
	
	function tostr (sl : std_logic) return string is
	begin
		return std_logic'image(sl);
	end tostr;
	
	procedure EndSim is
	begin
		report "This isn't a real failure, end of the simulation." severity failure;
	end EndSim;
 
end Utilities;
