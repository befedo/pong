
library ieee;
use ieee.std_logic_1164.all;

package CONV is
	function To_bit ( in_logic:std_logic ) return bit;
	function to_stdlogic(in_bit:bit) return std_logic;
end CONV;

package body CONV is
	
function To_bit ( in_logic:std_logic ) return bit is
	variable in_vector: std_logic_vector(0 downto 0);
	variable out_vector: bit_vector(0 downto 0);
begin
	in_vector(0):=in_logic;
	out_vector:=to_bitvector(in_vector);
	return out_vector(0);
end To_bit;


function to_stdlogic(in_bit:bit) return std_logic is
	variable out_vector: std_logic_vector(0 downto 0);
	variable in_vector: bit_vector(0 downto 0);
begin
	in_vector(0):=in_bit;
	out_vector:=to_stdlogicvector(in_vector);
	return out_vector(0);
end to_stdlogic;

end CONV;