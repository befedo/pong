library IEEE;
use IEEE.std_logic_1164.all;


entity VGA_RAM_TEST is
end entity VGA_RAM_TEST;

architecture VGA_RAM_ARC_TEST of VGA_RAM_TEST is
signal H_ADR: bit_vector(9 downto 0);
signal V_ADR: bit_vector(8 downto 0);
signal DIN: bit_vector(2 downto 0);
signal DOUT: std_logic_vector(2 downto 0);
signal CLK,WE,EN: bit;

component VGA_RAM    
    generic(
        --! Horizontale groesse des Rams.
       H_WIDTH:natural:=10;
        --! Vertikale groesse des Rams.
       V_WIDTH:natural:=9;
        --! Breite eines Speicherbereichs.
       WORD_WIDTH:natural:=3
    );
    port(
        --! Adresseingang für die Horizontale.
        H_ADR: in bit_vector(H_WIDTH-1 downto 0);
        --! Adresseingang für die Vertikale.
        V_ADR: in bit_vector(V_WIDTH-1 downto 0);
        --! Eingangsleitung zum Parallelen schreiben.
        DIN: in bit_vector(WORD_WIDTH-1 downto 0);
        --! Alle Operationen werden mit denn Takt synchronisiert.
        CLK: in bit;
        --! Wenn das signal High ist wird das aktuelle Signal am DIN gespeichert. EN muss auch HIGH sein damit ein Effekt auftritt.
        WE: in bit;
        --! Wenn das signal High ist wird der Speicherbaustein aktiv.
        EN: in bit;
        --! Datenausgangsleitung zum Parallelen lesen.
        DOUT: out std_logic_vector(WORD_WIDTH-1 downto 0)
    );
end component VGA_RAM;

for all: VGA_RAM use entity work.VGA_RAM(VGA_RAM_ARC);

begin
VGA_RAM_INST: VGA_RAM 
    generic map(H_WIDTH=>10,V_WIDTH=>9,WORD_WIDTH=>3)
    port map(H_ADR,V_ADR,DIN,CLK,WE,EN,DOUT);
    
CLKGENERATOR: process
begin
    CLK<='1';
    wait for 0.1 ns;
    CLK<='0';
    wait for 0.1 ns;
end process CLKGENERATOR;
    
-- Hier startet der Test
TEST:process
begin
    EN<='1';
    assert false report "Test von VGA_RAM startet." severity note;
    --Schreiben Testen
    H_ADR<="0000000000";
    V_ADR<="000000000";
    DIN<="000";
    wait for 1 ns;
    WE<='1';
    wait for 10 ns;
    assert DOUT="000" report "WRITE Test fehlgeschlagen:1." severity error;
    WE<='0';
    wait for 10 ns;
    
    H_ADR<="0000000001";
    V_ADR<="000000000";
    DIN<="001";
    wait for 1 ns;
    WE<='1';
    wait for 10 ns;
    assert DOUT="001" report "WRITE Test fehlgeschlagen:2." severity error;
    WE<='0';
    wait for 10 ns;
    
    H_ADR<="0000000000";
    V_ADR<="000000001";
    DIN<="010";
    wait for 1 ns;
    WE<='1';
    wait for 10 ns;
    assert DOUT="010" report "WRITE Test fehlgeschlagen:3." severity error;
    WE<='0';
    wait for 10 ns;
        
    H_ADR<="0000000001";
    V_ADR<="000000001";
    DIN<="011";
    wait for 1 ns;
    WE<='1';
    wait for 10 ns;
    assert DOUT="011" report "WRITE Test fehlgeschlagen:4." severity error;
    WE<='0';
    wait for 10 ns;
        
    H_ADR<="0000000100";
    V_ADR<="000000001";
    DIN<="110";
    wait for 1 ns;
    WE<='1';
    wait for 10 ns;
    assert DOUT="110" report "WRITE Test fehlgeschlagen:5." severity error;
    WE<='0';
    wait for 10 ns;
    
    --Lesen Testen
    
    H_ADR<="0000000001";
    V_ADR<="000000000";
    DIN<="000";
    wait for 1 ns;
    wait for 10 ns;
    assert DOUT="001" report "READ Test fehlgeschlagen:1." severity error;
    wait for 10 ns;
    
    H_ADR<="0000000000";
    V_ADR<="000000000";
    DIN<="000";
    wait for 1 ns;
    wait for 10 ns;
    assert DOUT="000" report "READ Test fehlgeschlagen:2." severity error;
    wait for 10 ns;
    
    H_ADR<="0000000100";
    V_ADR<="000000001";
    DIN<="000";
    wait for 1 ns;
    wait for 10 ns;
    assert DOUT="110" report "READ Test fehlgeschlagen:3." severity error;
    wait for 10 ns;
    
    
    H_ADR<="0000000001";
    V_ADR<="000000001";
    DIN<="000";
    wait for 1 ns;
    wait for 10 ns;
    assert DOUT="011" report "READ Test fehlgeschlagen:4." severity error;
    wait for 10 ns;
    
    
    H_ADR<="0000000000";
    V_ADR<="000000001";
    DIN<="000";
    wait for 1 ns;
    wait for 10 ns;
    assert DOUT="010" report "READ Test fehlgeschlagen:5." severity error;
    wait for 10 ns;
    
    
    --ENABLE Testen
    EN<='0';
    
        H_ADR<="0000000001";
    V_ADR<="000000001";
    DIN<="000";
    wait for 1 ns;
    wait for 10 ns;
    assert DOUT="010" report "ENABLE Test fehlgeschlagen:1." severity error;
    wait for 10 ns;
    
    
    H_ADR<="0000000100";
    V_ADR<="000000001";
    DIN<="000";
    wait for 1 ns;
    wait for 10 ns;
    assert DOUT="010" report "ENABLE Test fehlgeschlagen:2." severity error;
    wait for 10 ns;
    
    H_ADR<="0000000001";
    V_ADR<="000000000";
    DIN<="001";
    wait for 1 ns;
    WE<='1';
    wait for 10 ns;
    assert DOUT="010" report "ENABLE Test fehlgeschlagen:3." severity error;
    WE<='0';
    wait for 10 ns;
    
    H_ADR<="0000000000";
    V_ADR<="000000001";
    DIN<="010";
    wait for 1 ns;
    WE<='1';
    wait for 10 ns;
    assert DOUT="010" report "ENABLE Test fehlgeschlagen:4." severity error;
    WE<='0';
    wait for 10 ns;
    
    
    wait;
    
    
    
end process TEST;


end architecture VGA_RAM_ARC_TEST;