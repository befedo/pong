library IEEE;
use IEEE.std_logic_1164.all;


entity MUX_TEST is
end entity MUX_TEST;

architecture MUX_ARC_TEST of MUX_TEST is
signal SL: bit;
signal IN_SIGNAL_1: bit_vector(7 downto 0);
signal IN_SIGNAL_2: bit_vector(7 downto 0);
signal OUT_SIGNAL: std_logic_vector(7 downto 0);

component MUX    
    generic(
        --!Gibt die Breite der Signale an
        WIDTH:natural:=16
    );
    port(
        --!Eingangsignal auswahl. Wenn SL 1 ist wird das zweite Signal auf denn Ausgang geschalten
        SL: in bit;
        --!Eingangsignal 1
        IN_SIGNAL_1: in bit_vector(WIDTH-1 downto 0);
        --!Eingangsignal 2
        IN_SIGNAL_2: in bit_vector(WIDTH-1 downto 0);
        --!Ausgangssignal
        OUT_SIGNAL: out std_logic_vector(WIDTH-1 downto 0)
    );
end component MUX;

for all: MUX use entity work.MUX(MUX_ARC);

begin
MUX_INST: MUX 
    generic map(WIDTH=>8)
    port map(SL,IN_SIGNAL_1,IN_SIGNAL_2,OUT_SIGNAL);
    
    
-- Hier startet der Test
TEST:process
begin
    assert false report "Test von MUX startet." severity note;
    IN_SIGNAL_1<="01011010";
    IN_SIGNAL_2<="10101010";
    SL<='1';
    wait for 10 ns;
    assert OUT_SIGNAL="10101010" report "MUX Test fehlgeschlagen:1." severity error;
    SL<='0';
    wait for 10 ns;
    assert OUT_SIGNAL="01011010" report "MUX Test fehlgeschlagen:2." severity error;
    IN_SIGNAL_1<="01111010";
    wait for 10 ns;
    assert OUT_SIGNAL="01111010" report "MUX Test fehlgeschlagen:3." severity error;
    wait;
    
    
    
end process TEST;


end architecture MUX_ARC_TEST;