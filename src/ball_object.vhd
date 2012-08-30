-------------------------------------------------------
--! @file ball_object.vhd
--! @brief Diese Datei enthält ein Ball Object, dies wird genutzt zur Berechnung der Position und der Bewegung des Balles.
--! @author Matthias Springsetin
--! @date 27.08.12
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity BALL_OBJECT is
    generic(
        --! Obere Begrenzung des Balles
        BALL_TOP_LIMIT: integer range 0 to 1199:=10;
        --! Untere Begrenzung des Balles
        BALL_BOTTOM_LIMIT: integer range 0 to 1199:=20;
        --! Linke Begrenzung des Balles
        BALL_LEFT_LIMIT: integer range 0 to 1599:=10;
        --! Rechte Begrenzung des Balles
        BALL_RIGHT_LIMIT:integer range 0 to 1599:=20;
        --! X Koordinate des Balles bei RESET
        BALL_X_START: integer range 0 to 1599:=11;
        --! Y Koordinate des Balles bei RESET
        BALL_Y_START:integer range 0 to 1199:=11;
        --! X Koordinate des Balles bei RESET_2
        BALL_X_START_2: integer range 0 to 1599:=11;
        --! Y Koordinate des Balles bei RESET_2
        BALL_Y_START_2:integer range 0 to 1199:=11;
        --! Takteiler für eine Bewegung in X Richtung
        BALL_X_START_COUNT: natural:=1000;
        --! Takteiler für eine Bewegung in Y Richtung
        BALL_Y_START_COUNT:natural :=5000;
        --! Wert um den der Startwert reduziert wird wenn es zu einer Richtungsumkehr kommt
        BALL_SPEED_UP:natural := 150;
        --! Beschleunigung des Balles in Y Richtung 
        BALL_SPEED_UP_Y:natural := 150;
        --! Maximaler Zählerstand bis die Bewegung umgekehrt wird
        BALL_Y_START_COUNT_MAX:natural :=40000;
        --! Minimaler Zählerstand für die Maximal Geschwindigkeit in Y Richtung
        BALL_Y_START_COUNT_MIN:natural :=50000;
        --! Minimaler Start-Zählwert
        BALL_MIN_COUNT: natural := 50000;
        --! Ausdehnung des Balles
        BALL_DIMENSION:natural:=6
    );
    port(
        --! Takteingang für die Bewegung des Balles
        CLK: in bit;
        --! Setzt den Ball auf die erste Start Position zurück 
        RESET: in bit;
        --! Setzt den Ball auf die zweite Start Position zurück 
        RESET_2: in bit;
        --! Ausgang ob die aktuelle Position(V_ADR und H_ADR) ein Bildpunkt enthält 
        DRAW: out std_logic;
        --! Vertikale Adresse 
        V_ADR: in bit_vector(11 downto 0);
        --! Horizontale Adresse
        H_ADR: in bit_vector(11 downto 0);
        --! Aktuelle X Position der Ball-Mitte
        X_CURRENT:out integer range 0 to 1599;
        --! Aktuelle Y Position der Ball-Mitte
        Y_CURRENT:out integer range 0 to 1199;
        --! Eingang für die Bewegungsrichtung des linken Paddles(hoch)
        PADDLE_1_UP: in bit;
        --! Eingang für die Bewegungsrichtung des linken Paddles(runter)
        PADDLE_1_DOWN: in bit;
        --! Eingang für die Bewegungsrichtung des rechten Paddles(hoch)
        PADDLE_2_UP: in bit;
        --! Eingang für die Bewegungsrichtung des linken Paddles(runter)
        PADDLE_2_DOWN: in bit
    );
end entity BALL_OBJECT;

architecture BALL_OBJECT_ARC of BALL_OBJECT is
--! Aktuelle Bewegungsrichtung in X Richtung
signal OFFSET_X: integer range -1 to 1;
--! Aktuelle Bewegungsrichtung in Y Richtung
signal OFFSET_Y: integer range -1 to 1;
--! Aktueller Zählerstand bis zur nächsten Bewegung auf der X Achse
signal COUNT_X: natural;
--! Aktueller Zählerstand bis zur nächsten Bewegung auf der Y Achse
signal COUNT_Y: natural;
--! Aktuelle Position des Balles in X Richtung
signal BALL_X: integer range 0 to 1599;
--! Aktuelle Position des Balles in Y Richtung
signal BALL_Y: integer range 0 to 1199;
--! Startwert des nächsten Zähldurchgang für die Bewegung in Y Richtung
signal COUNTER_START_Y: natural;
--! Startwert des nächsten Zähldurchgang für die Bewegung in X Richtung
signal COUNTER_START_X: natural;
begin

--! Prozess für die Initalisierung des Balles und für die Bewegung des Balles
MAIN:process(CLK,RESET,RESET_2)
  begin
  if(RESET='1') then
    COUNTER_START_X<=BALL_X_START_COUNT;
    COUNTER_START_Y<=BALL_Y_START_COUNT;
    COUNT_X<=BALL_X_START_COUNT;
    COUNT_Y<=BALL_Y_START_COUNT;
    OFFSET_X<=1;
    OFFSET_Y<=1;
    BALL_X<=BALL_X_START;
    BALL_Y<=BALL_Y_START;
  elsif(RESET_2='1') then
    COUNTER_START_X<=BALL_X_START_COUNT;
    COUNTER_START_Y<=BALL_Y_START_COUNT;
    COUNT_X<=BALL_X_START_COUNT;
    COUNT_Y<=BALL_Y_START_COUNT;
    OFFSET_X<=-1;
    OFFSET_Y<=-1;
    BALL_X<=BALL_X_START_2;
    BALL_Y<=BALL_Y_START_2;
  elsif(CLK'EVENT and CLK='1') then
    --Ball bewegen
    if(COUNT_X=0) then
      COUNT_X<=COUNTER_START_X;
      if(BALL_X<=BALL_LEFT_LIMIT) then
        BALL_X<=BALL_X+1;
        OFFSET_X<=-OFFSET_X;
        if(COUNTER_START_X>BALL_MIN_COUNT) then
            COUNTER_START_X<=COUNTER_START_X-BALL_SPEED_UP;
        end if;
        --PADDLE BEWEGUNG(BALL RUNTER)
        if(PADDLE_1_UP='1' and OFFSET_Y=-1) then
            COUNTER_START_Y<=COUNTER_START_Y+BALL_SPEED_UP_Y;
            if(COUNTER_START_Y>BALL_Y_START_COUNT_MAX) then
                OFFSET_Y<=-OFFSET_Y;
            end if;
        end if;
        if(PADDLE_1_DOWN='1' and OFFSET_Y=-1) then
            if(COUNTER_START_Y>BALL_Y_START_COUNT_MIN) then
                COUNTER_START_Y<=COUNTER_START_Y-BALL_SPEED_UP_Y;
            end if;
        end if;
        --PADDLE BEWEGUNG(BALL HOCH)
        if(PADDLE_1_UP='1' and OFFSET_Y=1) then
            if(COUNTER_START_Y>BALL_Y_START_COUNT_MIN) then
                COUNTER_START_Y<=COUNTER_START_Y-BALL_SPEED_UP_Y;
            end if;
        end if;
        if(PADDLE_1_DOWN='1' and OFFSET_Y=1) then
            COUNTER_START_Y<=COUNTER_START_Y+BALL_SPEED_UP_Y;
            if(COUNTER_START_Y>BALL_Y_START_COUNT_MAX) then
                OFFSET_Y<=-OFFSET_Y;
            end if;
        end if;
        --
      elsif(BALL_X>=BALL_RIGHT_LIMIT) then
        BALL_X<=BALL_X-1;
        OFFSET_X<=-OFFSET_X;
        if(COUNTER_START_X>BALL_MIN_COUNT) then
            COUNTER_START_X<=COUNTER_START_X-BALL_SPEED_UP;
        end if;
        --PADDLE BEWEGUNG(BALL RUNTER)
        if(PADDLE_2_UP='1' and OFFSET_Y=-1) then
            COUNTER_START_Y<=COUNTER_START_Y+BALL_SPEED_UP_Y;
            if(COUNTER_START_Y>BALL_Y_START_COUNT_MAX) then
                OFFSET_Y<=-OFFSET_Y;
            end if;
        end if;
        if(PADDLE_2_DOWN='1' and OFFSET_Y=-1) then
            if(COUNTER_START_Y>BALL_Y_START_COUNT_MIN) then
                COUNTER_START_Y<=COUNTER_START_Y-BALL_SPEED_UP_Y;
            end if;
        end if;
        --PADDLE BEWEGUNG(BALL HOCH)
        if(PADDLE_2_UP='1' and OFFSET_Y=1) then
            if(COUNTER_START_Y>BALL_Y_START_COUNT_MIN) then
                COUNTER_START_Y<=COUNTER_START_Y-BALL_SPEED_UP_Y;
            end if;
        end if;
        if(PADDLE_2_DOWN='1' and OFFSET_Y=1) then
            COUNTER_START_Y<=COUNTER_START_Y+BALL_SPEED_UP_Y;
            if(COUNTER_START_Y>BALL_Y_START_COUNT_MAX) then
                OFFSET_Y<=-OFFSET_Y;
            end if;
        end if;
        --
      else
        BALL_X<=BALL_X+OFFSET_X;
      end if;
    else
      COUNT_X<=COUNT_X-1;
    end if;
    if(COUNT_Y=0) then
      COUNT_Y<=COUNTER_START_Y;
      if(BALL_Y<=BALL_TOP_LIMIT) then
        BALL_Y<=BALL_Y+1;
        OFFSET_Y<=-OFFSET_Y;
      elsif(BALL_Y>=BALL_BOTTOM_LIMIT) then
        BALL_Y<=BALL_Y-1;
        OFFSET_Y<=-OFFSET_Y;
      else
        BALL_Y<=BALL_Y+OFFSET_Y;
      end if;
    else
      COUNT_Y<=COUNT_Y-1;
    end if;
  end if;
  end process MAIN;
  
  X_CURRENT<=BALL_X;
  Y_CURRENT<=BALL_Y;

--! Gibt den Ball als Runden Objekt aus
AUSGABE:process(H_ADR,V_ADR)
  variable DIFF_BALL_X: integer;
  variable DIFF_BALL_Y: integer;
  begin
  DIFF_BALL_X:=(BALL_X-to_integer(unsigned(to_stdlogicvector(H_ADR))))*(BALL_X-to_integer(unsigned(to_stdlogicvector(H_ADR))));
  DIFF_BALL_Y:=(BALL_Y-to_integer(unsigned(to_stdlogicvector(V_ADR))))*(BALL_Y-to_integer(unsigned(to_stdlogicvector(V_ADR))));
    if((DIFF_BALL_X+DIFF_BALL_Y)<BALL_DIMENSION) then
      DRAW<='1';
    else
      DRAW<='0';
    end if;
  end process AUSGABE;
     
                
end architecture BALL_OBJECT_ARC; 
