library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity FIELD_OBJECT is
    generic(
        FIELD_TOP: integer range 0 to 1199:=10;
        FIELD_BOTTOM: integer range 0 to 1199:=120;
        FIELD_LEFT: integer range 0 to 1599:=65;
        FIELD_RIGHT:integer range 0 to 1599:=85;
        FIELD_MITTEL:integer range 0 to 1599:=100;
        FIELD_WIDTH:natural:=3
    );
    port(
        --!
        DRAW: out std_logic;
        V_ADR: in std_logic_vector(11 downto 0);
        H_ADR: in std_logic_vector(11 downto 0)
    );
end entity FIELD_OBJECT;

architecture FIELD_OBJECT_ARC of FIELD_OBJECT is
begin
	MAIN:process(V_ADR,H_ADR)
	variable H_ADR_SIG: integer:=to_integer(unsigned(H_ADR));
	variable V_ADR_SIG: integer:=to_integer(unsigned(V_ADR));
	begin
		draw<='0';
		if(V_ADR_SIG>FIELD_TOP and V_ADR_SIG<FIELD_BOTTOM and H_ADR_SIG>FIELD_LEFT and H_ADR_SIG<FIELD_RIGHT) then
			draw<='1';
			if(H_ADR_SIG>FIELD_MITTEL and H_ADR_SIG<FIELD_MITTEL+FIELD_WIDTH ) then
				
			elsif(V_ADR_SIG>FIELD_TOP+FIELD_WIDTH and V_ADR_SIG<FIELD_BOTTOM-FIELD_WIDTH and H_ADR_SIG>FIELD_LEFT+FIELD_WIDTH and H_ADR_SIG<FIELD_RIGHT-FIELD_WIDTH) then
				draw<='0';
			end if;
		end if;
	end process MAIN;
end architecture FIELD_OBJECT_ARC; 
