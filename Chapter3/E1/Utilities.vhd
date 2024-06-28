library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_std.all;
use std.textio.all;
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
		sign : boolean := false;
		bitwise : boolean := false
	) return string;
	
	procedure EndSim ;
	
	-- This function takes a file generated by GeneratorRandom01.do script and returns
	-- one character of the file each time it's called
	impure function readSLV (file bitsFile : text; len : positive) return STD_LOGIC_VECTOR;
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
		sign : boolean := false;
		bitwise : boolean := false
	) return string is
	variable bitwiseString : string(slv'LENGTH downto 1);
	begin
		if bitwise then
			for i in bitwiseString'range loop
				bitwiseString(i) := tostr(slv(i-1))(1);
			end loop;
			return bitwiseString;
		else
			if sign then
				return integer'image(to_integer(signed(slv)));
			else
				return integer'image(to_integer(unsigned(slv)));
			end if;
		end if;
	end tostr;
	
	function tostr (sl : std_logic) return string is
		variable slstr : string(1 to 1);
	begin
		slstr := std_logic'image(sl)(2 to 2);
		return slstr;
	end tostr;
	
	procedure EndSim is
	begin
		report "This isn't a real failure, end of the simulation." severity failure;
	end EndSim;
 
	impure function readSLV (file bitsFile : text; len : positive) return STD_LOGIC_VECTOR is
		variable bitLine : line;
		variable slv : std_logic_vector(len-1 downto 0);
	begin
		for i in len-1 downto 0 loop
			readline(bitsFile, bitLine);
			
			if bitLine(1) = '0' then
				slv(i) := '0';
			elsif bitLine(1) = '1' then
				slv(i) := '1';
			else
				report "The character read is not 0 or 1." severity failure;
			end if;
		end loop;
		
		return slv;
	end readslv;
end Utilities;
