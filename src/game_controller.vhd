-------------------------------------------------------
--! @file game_controller.vhd
--! @brief Diese Datei beinhaltet den Game Controller, seine Aufgabe bestreht darin das Spielfeld aufzubauen und die Eingaben des Spielers zu verarbeiten.
--! @author Matthias Springsetin
--! @date 27.08.12
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity GAME_CONTROLLER is
    port(
        --! Takteingang
        CLK: in bit;
        --! Eingang für das Paddle des 1. Spielers
        STEP_PLAYER1: in bit;
        --! Richtungsbit des Paddles
		LNOTR_PLAYER1: in bit;
        --! Eingang für das Paddle des 2. Spielers
        STEP_PLAYER2: in bit;
        --! Richtungsbit des Paddles
		LNOTR_PLAYER2: in bit;        
        --! Setzt alle Positionen von Ball, Punkte-Stand und Paddles zurÃ¼ck
        RESET: in bit;
        --! Gibt den aktuellen Farbwert fÃ¼r die Horizontale und Vertikale Adresse zurÃ¼ck
        DOUT: out bit_vector(2 downto 0);
        --! Vertikale Adresse 
        V_ADR: in bit_vector(11 downto 0);
        --! Horizontale Adresse
        H_ADR: in bit_vector(11 downto 0);
        --! Takteingang fÃ¼r die Aktuallisierung des Farbausganges
        ADR_CLK: in bit
    );
end entity GAME_CONTROLLER;

architecture GAME_CONTROLLER_ARC of GAME_CONTROLLER is
--! Signal ob an der aktuellen Position sich der Ball befindet
signal DRAW_BALL:std_logic;
--! Signal ob an der aktuellen Position sich das erste Spieler Paddle befindet
signal DRAW_PADDLE_1:std_logic;
--! Signal ob an der aktuellen Position sich das erste Spieler Paddle befindet
signal DRAW_PADDLE_2:std_logic;
--! Signal ob an der aktuellen Position sich das Spielfeld befindet
signal DRAW_FIELD:std_logic;
--! Signal ob an der aktuellen Position sich die Punktzahlangabe des ersten Spielers befindet
signal DRAW_SCORE_1:std_logic;
--! Signal ob an der aktuellen Position sich die Punktzahlangabe des zweiten Spielers befindet
signal DRAW_SCORE_2:std_logic;
--! Signal für die aktuelle X Position des Balles
signal BALL_X_CURRENT:integer range 0 to 1599;
--! Signal für die aktuelle Y Position des Balles
signal BALL_Y_CURRENT: integer range 0 to 1199;
--! Obere Position des ersten Spieler Paddles
signal PADDLE_TOP_PLAYER_1:integer range 0 to 1199;
--! Untere Position des ersten Spieler Paddles
signal PADDLE_BOTTOM_PLAYER_1:integer range 0 to 1199;
--! Obere Position des zweiten Spieler Paddles
signal PADDLE_TOP_PLAYER_2:integer range 0 to 1199;
--! Untere Position des zweiten Spieler Paddles
signal PADDLE_BOTTOM_PLAYER_2:integer range 0 to 1199;
--! Signal für die Erhöhung des Punktestandes des ersten Spielers
signal INCREASE_PLAYER_1:bit;
--! Signal für die Erhöhung des Punktestandes des zweiten Spielers
signal INCREASE_PLAYER_2:bit;
--! Aktueller Punktestand des 1 Spielers
signal SCORE_PLAYER_1:integer range 0 to 5;
--! Aktueller Punktestand des 2 Spielers
signal SCORE_PLAYER_2:integer range 0 to 5;
--! Setzt den Ball auf die erste Position zurück
signal BALL_RESET_1: bit;
--! Setzt den Ball auf die zweite Position zurück
signal BALL_RESET_2: bit;
--! Setzt alle Objekt auf denn Ausgangzustand zurück
signal RESET_SIG: bit;
--! Umgewandeltes Paddle_1_Up_Std signal
signal PADDLE_1_UP: bit;
--! Umgewandeltes Paddle_1_Down_Std signal
signal PADDLE_1_DOWN: bit;
--! Ist '1' wenn die letzte Bewegung des Paddles nach oben ging(erster Spieler)
signal PADDLE_1_UP_STD: std_logic;
--! Ist '1' wenn die letzte Bewegung des Paddles nach unten ging(erster Spieler)
signal PADDLE_1_DOWN_STD: std_logic;
--! Umgewandeltes Paddle_2_Up_Std signal
signal PADDLE_2_UP: bit;
--! Umgewandeltes Paddle_2_Down_Std signal
signal PADDLE_2_DOWN: bit;
--! Ist '1' wenn die letzte Bewegung des Paddles nach oben ging(zweiter Spieler)
signal PADDLE_2_UP_STD: std_logic;
--! Ist '1' wenn die letzte Bewegung des Paddles nach unten ging(zweiter Spieler)
signal PADDLE_2_DOWN_STD: std_logic;

--! Zustände die der Gameautomat einnehmen kann
type ZUSTAENDE is(z0,z1,z2,z3);
--! Aktueller Zustand des Spielautomat
signal ZUSTAND:ZUSTAENDE;
--! Nächster Zustand des Spielautomat
signal FOLGE_Z:ZUSTAENDE;

--BALL Komponente
component BALL_OBJECT  
    generic(
        BALL_TOP_LIMIT: integer range 0 to 1199:=199;
        BALL_BOTTOM_LIMIT: integer range 0 to 1199:=1100;
        BALL_LEFT_LIMIT: integer range 0 to 1599:=100;
        BALL_RIGHT_LIMIT:integer range 0 to 1599:=1500;
        BALL_X_START: integer range 0 to 1599:=110;
        BALL_Y_START:integer range 0 to 1199:=650;
        BALL_X_START_2: integer range 0 to 1599:=1490;
        BALL_Y_START_2:integer range 0 to 1199:=650;
        BALL_X_START_COUNT: natural:=200000;
        BALL_Y_START_COUNT:natural :=200000;
        BALL_SPEED_UP:natural := 10000;
        BALL_SPEED_UP_Y:natural := 50000;
        BALL_Y_START_COUNT_MAX:natural :=400000;
        BALL_Y_START_COUNT_MIN:natural :=50000;
        BALL_MIN_COUNT: natural := 40000;
        BALL_DIMENSION:natural:=50
    );
    port(
        --! Takteingang fÃ¼r die Bewegung des Balles
        CLK: in bit;
        --! Setzt den Ball auf die erste Start Position zurÃ¼ck 
        RESET: in bit;
        --! Setzt den Ball auf die zweite Start Position zurÃ¼ck 
        RESET_2: in bit;
        --! Ausgang ob die aktuelle Position(V_ADR und H_ADR) ein Bildpunkt enthÃ¤lt 
        DRAW: out std_logic;
        --! Vertikale Adresse 
        V_ADR: in bit_vector(11 downto 0);
        --! Horizontale Adresse
        H_ADR: in bit_vector(11 downto 0);
        --! Aktuelle X Position der Ball-Mitte
        X_CURRENT:out integer range 0 to 1599;
        --! Aktuelle Y Position der Ball-Mitte
        Y_CURRENT:out integer range 0 to 1199;
        PADDLE_1_UP: in bit;
        PADDLE_1_DOWN: in bit;
        PADDLE_2_UP: in bit;
        PADDLE_2_DOWN: in bit
    );
end component BALL_OBJECT;

--PADDLE Komponente
component PADDLE_OBJECT is
    generic(
        --! Oberes Limit des Spieler Paddles
        PADDLE_TOP_LIMIT: integer range 0 to 1199:=199;
        --! Untere Limit des Spieler Paddles
        PADDLE_BOTTOM_LIMIT: integer range 0 to 1199:=1100;
        --! Obere Position des Paddles bei einen Reset
        PADDLE_TOP_START: integer range 0 to 1199:=500;
        --! Vertikale Position des Paddles
        PADDLE_POS_X:integer range 0 to 1599:=90;
        --! HÃ¶he des Paddles, in Pixel
        PADDLE_HEIGTH: integer range 0 to 1199:=100;
        --! Breite des Paddles, in Pixel
        PADDLE_WIDTH:integer range 0 to 1599:=10;
        --! Pixel Schrittweite bei einen Bewegung 
        PADDLE_STEP_WIDTH: integer range 1 to 200:=10;
        --! VerzÃ¶gerung bei der erkennung der letzten Bewegungsrichtung
        MOVE_REACTION: positive:=1000000
    );
    port(
        --! Takteingang
        CLK: in bit;    
        --! L_NOTR gibt die Drehrichtung des Drehgebers an.
        L_NOTR: in bit;
        --! Mit jeder Flanke von Step wird eine Bewegung nach unten oder nach oben vollzogen
        STEP: in bit;
        --! Setzt das Paddle mit einer '1' zurÃ¼ck zur Startposition
        RESET: in bit;
        --! Ausgang ob die aktuelle Position(V_ADR und H_ADR) ein Bildpunkt enthÃ¤lt 
        DRAW: out std_logic;
        --! Vertikale Adresse 
        V_ADR: in bit_vector(11 downto 0);
        --! Horizontale Adresse
        H_ADR: in bit_vector(11 downto 0);
        --! Aktuelle obere Position des Paddles
        PADDLE_TOP: out integer range 0 to 1199;
        --! Aktuelle untere Position des Paddles
        PADDLE_BOTTOM: out integer range 0 to 1199;
        --! Die Letzte Bewegung des Paddles ging nach oben
        UP_SIG: out std_logic;
        --! Die Letzte Bewegung des Paddles ging nach unten
        DOWN_SIG: out std_logic
    );
end component PADDLE_OBJECT;

--FIELD Komponente
component FIELD_OBJECT is
    generic(
        FIELD_TOP: integer range 0 to 1199:=189;
        FIELD_BOTTOM: integer range 0 to 1199:=1110;
        FIELD_LEFT: integer range 0 to 1599:=80;
        FIELD_RIGHT:integer range 0 to 1599:=1520;
        FIELD_MITTEL:integer range 0 to 1599:=800;
        FIELD_WIDTH:natural:=3
    );
    port(
        --! Ausgang ob die aktuelle Position(V_ADR und H_ADR) ein Bildpunkt enthÃ¤lt 
        DRAW: out std_logic;
        --! Vertikale Adresse 
        V_ADR: in bit_vector(11 downto 0);
        --! Horizontale Adresse
        H_ADR: in bit_vector(11 downto 0)
    );
end component FIELD_OBJECT;

--SCORE Komponente
component SCORE_OBJECT is
  generic(
    MAX_POINT: integer range 0 to 14:=5;
    START_X: integer range 0 to 1599:=80;
    START_Y: integer range 0 to 1199:=20;
    BARE_WIDTH: natural:=15;
    BARE_HEIGHT: natural:=60;
    DISTANCE: natural :=20
  );
  port(
    --! Takteingang
    CLK: in bit;
    --! Setzt den Punktestand zurÃ¼ck auf 0
    RESET: in bit;
    --! ErhÃ¶ht mit den nÃ¤chsten Takt den Punktestand
    INCREASE: in bit;
    --! Gibt den aktuellen Punktestand zurÃ¼ck
    CURRENT_SCORE: out integer range 0 to MAX_POINT;
    --! Ausgang ob die aktuelle Position(V_ADR und H_ADR) ein Bildpunkt enthÃ¤lt 
    DRAW: out std_logic;
    --! Vertikale Adresse 
    V_ADR: in bit_vector(11 downto 0);
    --! Horizontale Adresse
    H_ADR: in bit_vector(11 downto 0)
  );
end component SCORE_OBJECT;

for all: BALL_OBJECT use entity work.BALL_OBJECT(BALL_OBJECT_ARC);
for all: PADDLE_OBJECT use entity work.PADDLE_OBJECT(PADDLE_OBJECT_ARC);
for all: FIELD_OBJECT use entity work.FIELD_OBJECT(FIELD_OBJECT_ARC);
for all: SCORE_OBJECT use entity work.SCORE_OBJECT(SCORE_OBJECT_ARC);

begin

BALL_OBJECT_INST: BALL_OBJECT 
  port map(CLK,RESET=>BALL_RESET_1,RESET_2=>BALL_RESET_2,DRAW=>DRAW_BALL,V_ADR=>V_ADR,H_ADR=>H_ADR,X_CURRENT=>BALL_X_CURRENT,
    Y_CURRENT=>BALL_Y_CURRENT,PADDLE_1_UP=>PADDLE_1_UP,PADDLE_1_DOWN=>PADDLE_1_DOWN,PADDLE_2_UP=>PADDLE_2_UP,PADDLE_2_DOWN=>PADDLE_2_DOWN);
    
PADDLE_OBJECT_INST_1: PADDLE_OBJECT 
  port map(CLK=>CLK,L_NOTR=>LNOTR_PLAYER1, STEP=>STEP_PLAYER1,RESET=>RESET_SIG,DRAW=>DRAW_PADDLE_1,V_ADR=>V_ADR,
    H_ADR=>H_ADR,PADDLE_TOP=>PADDLE_TOP_PLAYER_1,PADDLE_BOTTOM=>PADDLE_BOTTOM_PLAYER_1,UP_SIG=>PADDLE_1_UP_STD,
    DOWN_SIG=>PADDLE_1_DOWN_STD);
    
PADDLE_OBJECT_INST_2: PADDLE_OBJECT 
  generic map(PADDLE_POS_X=>1500)
  port map(CLK=>CLK,L_NOTR=>LNOTR_PLAYER2,STEP=>STEP_PLAYER2,RESET=>RESET_SIG,DRAW=>DRAW_PADDLE_2,V_ADR=>V_ADR,
    H_ADR=>H_ADR,PADDLE_TOP=>PADDLE_TOP_PLAYER_2,PADDLE_BOTTOM=>PADDLE_BOTTOM_PLAYER_2,UP_SIG=>PADDLE_2_UP_STD,
    DOWN_SIG=>PADDLE_2_DOWN_STD);
        
FIELD_OBJECT_INST:FIELD_OBJECT
  port map(DRAW=>DRAW_FIELD,H_ADR=>H_ADR,V_ADR=>V_ADR);
  
SCORE_OBJECT_INST_1: SCORE_OBJECT
  port map(CLK=>CLK, RESET=>RESET_SIG,INCREASE=>INCREASE_PLAYER_1,CURRENT_SCORE=>SCORE_PLAYER_1,DRAW=>DRAW_SCORE_1,V_ADR=>V_ADR,H_ADR=>H_ADR);
 
SCORE_OBJECT_INST_2: SCORE_OBJECT
  generic map(START_X=>800)
  port map(CLK=>CLK, RESET=>RESET_SIG,INCREASE=>INCREASE_PLAYER_2,CURRENT_SCORE=>SCORE_PLAYER_2,DRAW=>DRAW_SCORE_2,V_ADR=>V_ADR,H_ADR=>H_ADR);

--! Farbzuweisung der einzelnen Objekte
AUSGABE:process(ADR_CLK)
  begin
  if(ADR_CLK'event and ADR_CLK='1') then
    if(DRAW_BALL='1') then
      DOUT<="001";
	elsif(DRAW_PADDLE_1='1') then
      DOUT<="010";
    elsif(DRAW_PADDLE_2='1') then
      DOUT<="100";
    elsif(DRAW_FIELD='1') then
      DOUT<="111";
    elsif(DRAW_SCORE_1='1') then
      DOUT<="010";
    elsif(DRAW_SCORE_2='1') then
      DOUT<="100";
    else
	  DOUT<="000";
    end if;
  end if;
  end process AUSGABE;
   
--! Hauptprozess für den Automaten
MAIN:process(CLK,RESET)
  begin
  if(RESET='1') then
	ZUSTAND<=z0;
  elsif(CLK'event and CLK='1') then
    ZUSTAND<=FOLGE_Z;
  end if;
  end process MAIN;

--! Übergangsautomat von einen Spielzustand zum nächsten
GAME_AUTOMATE:process(ZUSTAND,BALL_X_CURRENT)
  begin
    FOLGE_Z<=z0;
    RESET_SIG<='0';
    BALL_RESET_1<='0';
    BALL_RESET_2<='0';
    INCREASE_PLAYER_1<='0';
    INCREASE_PLAYER_2<='0';
    case ZUSTAND is
      --Zustand nach den START
      when z0=>
        FOLGE_Z<=z1;
        RESET_SIG<='1';
        BALL_RESET_1<='1';
      --Spiel lÃ¤uft
      when z1=>
        if(BALL_X_CURRENT=100 and (BALL_Y_CURRENT<PADDLE_TOP_PLAYER_1-15 or BALL_Y_CURRENT>PADDLE_BOTTOM_PLAYER_1+15)) then 
          FOLGE_Z<=z3;
        elsif(BALL_X_CURRENT=1500 and (BALL_Y_CURRENT<PADDLE_TOP_PLAYER_2-15 or BALL_Y_CURRENT>PADDLE_BOTTOM_PLAYER_2+15)) then
          FOLGE_Z<=z2;
        else
          FOLGE_Z<=z1;
        end if;

      --Spieler 1 Punktet
      when z2=>
        if(SCORE_PLAYER_1=5) then
          FOLGE_Z<=z0;
        else
          BALL_RESET_2<='1';
          INCREASE_PLAYER_1<='1';
          FOLGE_Z<=z1;
        end if;
      --Spieler 2 Punktet
      when z3=>
        if(SCORE_PLAYER_2=5) then
          FOLGE_Z<=z0;
        else
          BALL_RESET_1<='1';
          INCREASE_PLAYER_2<='1';
          FOLGE_Z<=z1;
        end if;
    end case;
  end process GAME_AUTOMATE;
  
   
PADDLE_1_UP<=to_bit(PADDLE_1_UP_STD);
PADDLE_1_DOWN<=to_bit(PADDLE_1_DOWN_STD);
PADDLE_2_UP<=to_bit(PADDLE_2_UP_STD);
PADDLE_2_DOWN<=to_bit(PADDLE_2_DOWN_STD);
                
end architecture GAME_CONTROLLER_ARC; 
