library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity SCORE_OBJECT_TEST is
end entity SCORE_OBJECT_TEST;

architecture SCORE_OBJECT_ARC_TEST of SCORE_OBJECT_TEST is
signal CLK: bit;
signal RESET:  bit;
signal DRAW: std_logic;
signal V_ADR: bit_vector(11 downto 0);
signal H_ADR:  bit_vector(11 downto 0);
signal INCREASE: bit;
signal CURRENT_SCORE: integer range 0 to 5;

component SCORE_OBJECT  
  generic(
    --! Maximaler Punktestand
    MAX_POINT: integer range 0 to 14:=5;
    --! Anfangs X Position zum Zeichnen des Punktestandes
    START_X: integer range 0 to 1599:=10;
    --! Anfangs Y Position zum Zeichnen des Punktestandes
    START_Y: integer range 0 to 1199:=10;
    --! Breite eines Punktbalken
    BARE_WIDTH: natural:=10;
    --! Höhe eines Punktbalken
    BARE_HEIGHT: natural:=30;
    --! Abstand zwischen 2 Strichen
    DISTANCE: natural :=20
  );
  port(
    --! Takteingang
    CLK: in bit;
    --! Setzt den Punktestand zurück auf 0
    RESET: in bit;
    --! Erhöht mit den nächsten Takt den Punktestand
    INCREASE: in bit;
    --! Gibt den aktuellen Punktestand zurück
    CURRENT_SCORE: out integer range 0 to MAX_POINT;
    --! Ausgang ob die aktuelle Position(V_ADR und H_ADR) ein Bildpunkt enthält 
    DRAW: out std_logic;
    --! Vertikale Adresse 
    V_ADR: in bit_vector(11 downto 0);
    --! Horizontale Adresse
    H_ADR: in bit_vector(11 downto 0)
  );
end component SCORE_OBJECT;

for all: SCORE_OBJECT use entity work.SCORE_OBJECT(SCORE_OBJECT_ARC);

begin
SCORE_OBJECT_INST: SCORE_OBJECT 
    port map(CLK,RESET,INCREASE,CURRENT_SCORE,DRAW,V_ADR,H_ADR);
    
CLKGENERATOR: process
begin
    CLK<='1';
    wait for 0.1 ns;
    CLK<='0';
    wait for 0.1 ns;
end process CLKGENERATOR;
    
TEST: process
begin
    RESET<='1';
    wait for 1 ns;
    RESET<='0';
    wait for 10000 ns;
    INCREASE<='1';
    wait for 0.2 ns;
    INCREASE<='0';
    wait for 10000 ns;
    INCREASE<='1';
    wait for 0.2 ns;
    INCREASE<='0';
    wait for 10000 ns;
    INCREASE<='1';
    wait for 0.2 ns;
    INCREASE<='0';
    wait;
end process TEST;

ADR: process
begin
  H_ADR<=(others=>'0');
  V_ADR<=(others=>'0');
  wait for 1 ns;
  loop
  if(to_integer(unsigned(to_stdlogicvector(H_ADR))) = 100) then
    H_ADR<=(others=>'0');
    if(to_integer(unsigned(to_stdlogicvector(V_ADR))) = 50) then
      V_ADR<=(others=>'0');
    else
      V_ADR<=to_bitvector(to_stdlogicvector(V_ADR)+1);
    end if;
  else
    H_ADR<=to_bitvector(to_stdlogicvector(H_ADR)+1);
  end if;
  wait for 0.2 ns;
  end loop;
end process ADR;
    
    


end architecture SCORE_OBJECT_ARC_TEST;