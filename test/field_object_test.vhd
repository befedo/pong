library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity FIELD_OBJECT_TEST is
end entity FIELD_OBJECT_TEST;

architecture FIELD_OBJECT_ARC_TEST of FIELD_OBJECT_TEST is
signal DRAW:std_logic;
signal V_ADR: bit_vector(11 downto 0);
signal H_ADR: bit_vector(11 downto 0);

component FIELD_OBJECT  
    generic(
        --! Obere Spielfeld Grenze
        FIELD_TOP: integer range 0 to 1199:=10;
        --! Untere Spielfeld Grenze
        FIELD_BOTTOM: integer range 0 to 1199:=120;
        --! Linke Spielfeld Grenze
        FIELD_LEFT: integer range 0 to 1599:=65;
        --! Rechte Spielfeld Grenze
        FIELD_RIGHT:integer range 0 to 1599:=110;
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
end component FIELD_OBJECT;

for all: FIELD_OBJECT use entity work.FIELD_OBJECT(FIELD_OBJECT_ARC);

begin
FIELD_OBJECT_INST: FIELD_OBJECT 
    port map(DRAW,V_ADR,H_ADR);
    
    -- Hier startet der Test
    
    
TEST:process
begin
    assert false report "Test von FIELD_OBJECT startet." severity note;
    H_ADR<="000000000000";
    V_ADR<="000000000000";
    wait for 1 ns;
    assert DRAW='0' report "Test fehlgeschlagen:1." severity error;
    H_ADR<="000001000010";
    V_ADR<="000000001011";
    wait for 1 ns;
    assert DRAW='1' report "Test fehlgeschlagen:2." severity error;
    H_ADR<="000001010100";
    V_ADR<="000000001011";
    wait for 1 ns;
    assert DRAW='1' report "Test fehlgeschlagen:3." severity error;
    H_ADR<="000001101110";
    V_ADR<="000000001011";
    wait for 1 ns;
    assert DRAW='0' report "Test fehlgeschlagen:4." severity error;
    H_ADR<="000001100101";
    V_ADR<="000000011011";
    wait for 1 ns;
    assert DRAW='1' report "Test fehlgeschlagen:5." severity error;
    
    wait;
    
    
    
end process TEST;
    


end architecture FIELD_OBJECT_ARC_TEST;