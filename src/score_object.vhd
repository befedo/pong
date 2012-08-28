-------------------------------------------------------
--! @file score_object.vhd
--! @brief Diese Datei beinhaltet das Score Object, dieses dient zum zeichnen und verwalten des Punktestandes.
--! @author Matthias Springsetin
--! @date 27.08.12
-------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity SCORE_OBJECT is
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
    CLK: in std_logic;
    --! Setzt den Punktestand zurück auf 0
    RESET: in std_logic;
    --! Erhöht mit den nächsten Takt den Punktestand
    INCREASE: in std_logic;
    --! Gibt den aktuellen Punktestand zurück
    CURRENT_SCORE: out integer range 0 to MAX_POINT;
    --! Ausgang ob die aktuelle Position(V_ADR und H_ADR) ein Bildpunkt enthält 
    DRAW: out std_logic;
    --! Vertikale Adresse 
    V_ADR: in std_logic_vector(11 downto 0);
    --! Horizontale Adresse
    H_ADR: in std_logic_vector(11 downto 0);
  );
end entity SCORE_OBJECT;

architecture SCORE_OBJECT_ARC of SCORE_OBJECT is
  --! Interner Punktestand
  signal CURRENT_SCORE_SIG: integer range 0 to MAX_POINT;
begin

  --! Prozess für die Verwaltung des Punktestandes
  SCORE:process(CLK, RESET)
  begin
    if(RESET='1') then
      CURRENT_SCORE_SIG<=0;
    elsif(CLK'event and CLK='1') then
      if(INCREASE='1') then
        if(not(CURRENT_SCORE_SIG=MAX_POINT)) then
          CURRENT_SCORE_SIG<=CURRENT_SCORE_SIG+1;
        end if;
      end if;
    end if;
  end process SCORE;
  
  CURRENT_SCORE<=CURRENT_SCORE_SIG;
  
  --! Ausgabe des Punktestandes
  OUTPUT:process(V_ADR,H_ADR)
  begin
    DRAW<='0';
    BARE:for I in 0 to MAX_POINT-1 loop
      if(I<CURRENT_SCORE_SIG) then
        if(H_ADR>START_X+(DISTANCE+BARE_WIDTH)*I and H_ADR<START_X+BARE_WIDTH+(DISTANCE+BARE_WIDTH)*I and V_ADR>START_Y and V_ADR<START_Y+BARE_HEIGHT) then
          DRAW<='1';
        end if;
      end if;
    end loop;
  
  end process OUTPUT;

                
end architecture SCORE_OBJECT_ARC; 
 
