-------------------------------------------------------
--! @file field_object.vhd
--! @brief Diese Datei beinhaltet ein Field Object, dieses dient zum Zeichnen der Spielfeld-Grenzen.
--! @author Matthias Springsetin
--! @date 27.08.12
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity FIELD_OBJECT is
    generic(
        --! Obere Spielfeld Grenze
        FIELD_TOP: integer range 0 to 1199:=10;
        --! Untere Spielfeld Grenze
        FIELD_BOTTOM: integer range 0 to 1199:=120;
        --! Linke Spielfeld Grenze
        FIELD_LEFT: integer range 0 to 1599:=65;
        --! Rechte Spielfeld Grenze
        FIELD_RIGHT:integer range 0 to 1599:=85;
        --! Mittellinie des Spielfeldes
        FIELD_MITTEL:integer range 0 to 1599:=100;
        --! Breite der Spielfeld Linien
        FIELD_WIDTH:natural:=3
    );
    port(
        --! Ausgang ob die aktuelle Position(V_ADR und H_ADR) ein Bildpunkt enthält 
        DRAW: out std_logic;
        --! Vertikale Adresse 
        V_ADR: in bit_vector(11 downto 0);
        --! Horizontale Adresse
        H_ADR: in bit_vector(11 downto 0)
    );
end entity FIELD_OBJECT;

architecture FIELD_OBJECT_ARC of FIELD_OBJECT is
begin
    --! Ausgabe des Spielfeldes
	AUSGABE:process(V_ADR,H_ADR)
	variable H_ADR_SIG: integer;
	variable V_ADR_SIG: integer;
	begin
	V_ADR_SIG:=to_integer(unsigned(to_stdlogicvector(V_ADR)));
	H_ADR_SIG:=to_integer(unsigned(to_stdlogicvector(H_ADR)));
		draw<='0';
		if(V_ADR_SIG>FIELD_TOP and V_ADR_SIG<FIELD_BOTTOM and H_ADR_SIG>FIELD_LEFT and H_ADR_SIG<FIELD_RIGHT) then
			draw<='1';
			if(H_ADR_SIG>FIELD_MITTEL and H_ADR_SIG<FIELD_MITTEL+FIELD_WIDTH ) then
				
			elsif(V_ADR_SIG>FIELD_TOP+FIELD_WIDTH and V_ADR_SIG<FIELD_BOTTOM-FIELD_WIDTH and H_ADR_SIG>FIELD_LEFT+FIELD_WIDTH and H_ADR_SIG<FIELD_RIGHT-FIELD_WIDTH) then
				draw<='0';
			end if;
		end if;
	end process AUSGABE;
end architecture FIELD_OBJECT_ARC; 
