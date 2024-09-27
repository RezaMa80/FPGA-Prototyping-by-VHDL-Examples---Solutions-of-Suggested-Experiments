library  ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity fp_adder is
	port (
		sign1, sign2 : in std_logic;
		exp1, exp2 : in std_logic_vector(3 downto 0);
		frac1, frac2 : in std_logic_vector(7 downto 0);
		sign_out : out std_logic;
		exp_out : out std_logic_vector(3 downto 0);
		frac_out : out std_logic_vector(7 downto 0)
	);
end fp_adder ;

architecture arch of fp_adder is
	-- suffix 	b, s, a, n for
	--			big, small, aligned, normalized
	signal signb, signs : std_logic;
	signal expb, exps, expn : unsigned(3 downto 0);
	signal fracb, fracs, fraca, fracn : unsigned(7 downto 0);
	signal fracaBeforRounding : unsigned(9 downto 0); -- 2 extra bits for gound and round bits
	signal sum_norm : unsigned(7 downto 0);
	signal exp_diff : unsigned(3 downto 0);
	signal sum : unsigned(8 downto 0); -- one extra for carry
	signal lead0: unsigned(2 downto 0);
	
	signal stickyBit : std_logic;
	-- OR i'th bit with it's previous bits
	signal fracsAccumOr : std_logic_vector(5 downto 0) := (others => '0');
begin
	-- 1st stage: sort to find the larger number 
	process (sign1, sign2, exp1, exp2, frac1, frac2)
	begin
		if (exp1 & frac1) > (exp2 & frac2) then 
			signb <= sign1;  
			signs <= sign2;  
			expb <= unsigned(exp1); 
			exps <= unsigned(exp2);
			fracb <= unsigned(frac1); 
			fracs <= unsigned(frac2); 
		else
			signb <= sign2;  
			signs <= sign1; 
			expb <= unsigned(exp2); 
			exps <= unsigned(exp1); 
			fracb <= unsigned(frac2); 
			fracs <= unsigned(frac1); 
		end if; 
	end process;  
	
	-- 2nd stage: align smaller numebr (Keep 2 extra bits for ground and round bits)
	exp_diff <= expb - exps;
	with exp_diff select
		fracaBeforRounding <=
							fracs 				& "00"	when "0000",
			"0" 		& 	fracs 				& '0' 	when "0001",
			"00" 		& 	fracs			 			when "0010",
			"000" 		& 	fracs(7 downto 1) 			when "0011",
			"0000" 		& 	fracs(7 downto 2) 			when "0100",
			"00000" 	& 	fracs(7 downto 3) 			when "0101",
			"000000" 	& 	fracs(7 downto 4) 			when "0110",
			"0000000" 	& 	fracs(7 downto 5) 			when "0111",
			"00000000" 	& 	fracs(7 downto 6) 			when "1000", 
			"0000000000"								when others; -- "1001" value not checked because if we know ground bit is 0, round bit does not matter
	
	-- Calculate sticky bits by ORing all bits that may affect it (fracs(5 downto 0))
	fracsAccumOr(0) <= fracs(0);
	fracsAccumOr_Gen :
	for i in 5 downto 1 generate
		fracsAccumOr(i) <= fracs(i) or fracsAccumOr(i-1);
	end generate;
	
	-- exp_diff = 2 means fracs(0) is on round bit and exp_diff = 9 means ground bit is 0 and sticky bit is not importnant
	stickyBit <= 	fracsAccumOr(to_integer(exp_diff-3)) when (exp_diff > 2) and (exp_diff < 9) else
					'0';
			
	process (stickyBit, fracaBeforRounding)
		constant zeroSLV2 : std_logic_vector(1 downto 0) := "00";
	begin
		-- Adding 1 to a shifted right number which were normalized, will not cause overflow
		-- If ground bit is 0, no need to sum (<0.5)
		if fracaBeforRounding(1) = '0' then
			fraca <= fracaBeforRounding(9 downto 2);
		else
			-- If g=1, rs=00 (=0.5)
			if std_logic(fracaBeforRounding(0)) & stickyBit = zeroSLV2 then
				fraca <= fracaBeforRounding(9 downto 2) + ("0000000"&fracaBeforRounding(2));
			-- If g=1, rs/=00 (>0.5)
			else
				fraca <= fracaBeforRounding(9 downto 2) + "00000001";
			end if;
		end if;
	end process;
				
	-- 3rd stage: add/subtract
	sum <= 	('0' & fracb) + ('0' & fraca) when signb = signs else
			('0' & fracb) - ('0' & fraca);
	
	-- 4th stage: normalize
	-- count leading 0s
	lead0 <= 	"000" when (sum(7) = '1') else
				"001" when (sum(6) = '1') else
				"010" when (sum(5) = '1') else
				"011" when (sum(4) = '1') else
				"100" when (sum(3) = '1') else
				"101" when (sum(2) = '1') else
				"110" when (sum(1) = '1') else
				"111";
				
	-- shift significand according to leading 0
	with lead0 select
		sum_norm <= 
			sum(7 downto 0) 				when "000", 
			sum(6 downto 0) & 	'0' 		when "001",  
			sum(5 downto 0) & 	"00" 		when "010",  
			sum(4 downto 0) & 	"000" 		when "011", 
			sum(3 downto 0) & 	"0000" 		when "100",  
			sum(2 downto 0) & 	"00000" 	when "101", 
			sum(1 downto 0) & 	"000000" 	when "111",  
			sum(0) & 			"0000000" 	when others;

	-- normalize with special conditions
	process (sum, sum_norm, expb, lead0) 
		variable expnTemp : unsigned(3 downto 0);
		variable fracnTemp : unsigned(8 downto 0);
		variable roundValue : std_logic_vector(0 downto 0);
	begin 
		if sum(8) = '1' then -- w/ carry out;
			-- If overflow occurred, we need to shift right the sum, so we have to round it
			-- sum(0) is the ground bit and the round and sticky bit are always 0 because we only shift 1 to right
			-- We only sum the result with 1 if ground and LSB are 1
			
			-- Shift right and round
			expnTemp := expb + 1; 
			roundValue(0) := sum(1) and sum(0);
			fracnTemp := sum(8 downto 1) + (unsigned("00000000"&roundValue));
			
			-- Check if overflow happened due to rounding
			if fracnTemp(8) = '1' then
				fracn <= fracnTemp(8 downto  1);
				expn <= expnTemp + 1;
			else
				fracn <= fracnTemp(7 downto  0);
				expn <= expnTemp;
			end if;
		elsif (lead0 > expb) then -- too small to normalize
			expn <= (others => '0'); -- set to 0
			fracn <= (others => '0');
		else
			expn <= expb - lead0;
			fracn <= sum_norm; 
		end if;
	end process;
	
	-- from output
	sign_out  <= signb;  
	exp_out <= std_logic_vector(expn); 
	frac_out <= std_logic_vector(fracn); 
end arch;
