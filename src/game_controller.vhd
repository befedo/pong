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
        --! Eingang für eine Aufwärtsbewegung des ersten Spielers
        UP_PLAYER_1: in bit;
        --! Eingang für eine Abwärtsbewegung des ersten Spielers
        DOWN_PLAYER_1: in bit;
        --! Eingang für eine Aufwärtsbewegung des zweiten Spielers
        UP_PLAYER_2: in bit;
        --! Eingang für eine Abwärtsbewegung des zweiten Spielers
        DOWN_PLAYER_2: in bit;
        --! Setzt alle Positionen von Ball, Punkte-Stand und Paddles zurück
        RESET: in bit;
        --! Gibt den aktuellen Farbwert für die Horizontale und Vertikale Adresse zurück
        DOUT: out bit_vector(2 downto 0);
        --! Vertikale Adresse 
        V_ADR: in bit_vector(11 downto 0);
        --! Horizontale Adresse
        H_ADR: in bit_vector(11 downto 0);
        --! Takteingang für die Aktuallisierung des Farbausganges
        ADR_CLK: in bit
    );
end entity GAME_CONTROLLER;

architecture GAME_CONTROLLER_ARC of GAME_CONTROLLER is
signal PADDLE_1_STEP_IN: std_logic;
signal PADDLE_2_STEP_IN: std_logic;
signal DRAW_BALL:std_logic;
signal DRAW_PADDLE_1:std_logic;
signal DRAW_PADDLE_2:std_logic;
signal DRAW_FIELD:std_logic;
signal DRAW_SCORE_1:std_logic;
signal DRAW_SCORE_2:std_logic;
signal BALL_X_CURRENT:integer range 0 to 1599;
signal BALL_Y_CURRENT: integer range 0 to 1199;
signal PADDLE_TOP_PLAYER_1:integer range 0 to 1199;
signal PADDLE_BOTTOM_PLAYER_1:integer range 0 to 1199;
signal PADDLE_TOP_PLAYER_2:integer range 0 to 1199;
signal PADDLE_BOTTOM_PLAYER_2:integer range 0 to 1199;
signal INCREASE_PLAYER_1:bit;
signal INCREASE_PLAYER_2:bit;
signal SCORE_PLAYER_1:integer range 0 to 5;
signal SCORE_PLAYER_2:integer range 0 to 5;
signal BALL_RESET_1: bit;
signal BALL_RESET_2: bit;
signal RESET_SIG: bit;
signal PADDLE_1_UP: bit;
signal PADDLE_1_DOWN: bit;
signal PADDLE_1_UP_STD: std_logic;
signal PADDLE_1_DOWN_STD: std_logic;
signal PADDLE_2_UP: bit;
signal PADDLE_2_DOWN: bit;
signal PADDLE_2_UP_STD: std_logic;
signal PADDLE_2_DOWN_STD: std_logic;


type ZUSTAENDE is(z0,z1,z2,z3);
signal ZUSTAND,FOLGE_Z:ZUSTAENDE;

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
        BALL_Y_START_COUNT_MAX:natural :=1000000;
        BALL_Y_START_COUNT_MIN:natural :=50000;
        BALL_MIN_COUNT: natural := 50000;
        BALL_DIMENSION:natural:=50
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
        PADDLE_UP: in bit;
        PADDLE_DOWN: in bit
    );
end component BALL_OBJECT;

--PADDLE Komponente
component PADDLE_OBJECT is
    generic(
        PADDLE_TOP_LIMIT: integer range 0 to 1199:=199;
        PADDLE_BOTTOM_LIMIT: integer range 0 to 1199:=1100;
        PADDLE_TOP_START: integer range 0 to 1199:=600;
        PADDLE_POS_X:integer range 0 to 1599:=90;
        PADDLE_HEIGTH: integer range 0 to 1199:=100;
        PADDLE_WIDTH:integer range 0 to 1599:=10;
        PADDLE_STEP_WIDTH: integer range 1 to 200:=10 
    );
    port(
        --! Takteingang
        CLK: in bit;
        --! Eingang für eine Aufwärtsbewegung
        UP: in bit;
        --! Eingang für eine Abwärtsbewegung
        DOWN: in bit;
        --! Setzt das Paddle mit einer '1' zurück zur Startposition
        RESET: in bit;
        --! Ausgang ob die aktuelle Position(V_ADR und H_ADR) ein Bildpunkt enthält 
        DRAW: out std_logic;
        --! Vertikale Adresse 
        V_ADR: in bit_vector(11 downto 0);
        --! Horizontale Adresse
        H_ADR: in bit_vector(11 downto 0);
        --! Aktuelle obere Position des Paddles
        PADDLE_TOP: out integer range 0 to 1199;
        --! Aktuelle untere Position des Paddles
        PADDLE_BOTTOM: out integer range 0 to 1199;
        
        UP_SIG: out std_logic;
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
        --! Ausgang ob die aktuelle Position(V_ADR und H_ADR) ein Bildpunkt enthält 
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

for all: BALL_OBJECT use entity work.BALL_OBJECT(BALL_OBJECT_ARC);
for all: PADDLE_OBJECT use entity work.PADDLE_OBJECT(PADDLE_OBJECT_ARC);
for all: FIELD_OBJECT use entity work.FIELD_OBJECT(FIELD_OBJECT_ARC);
for all: SCORE_OBJECT use entity work.SCORE_OBJECT(SCORE_OBJECT_ARC);

begin

BALL_OBJECT_INST: BALL_OBJECT 
  port map(CLK,RESET=>BALL_RESET_1,RESET_2=>BALL_RESET_2,DRAW=>DRAW_BALL,V_ADR=>V_ADR,H_ADR=>H_ADR,X_CURRENT=>BALL_X_CURRENT,
    Y_CURRENT=>BALL_Y_CURRENT,PADDLE_1_UP=>PADDLE_1_UP,PADDLE_1_DOWN=>PADDLE_1_DOWN,PADDLE_2_UP=>PADDLE_2_UP,PADDLE_2_DOWN=>PADDLE_2_DOWN);
    
PADDLE_OBJECT_INST_1: PADDLE_OBJECT 
  port map(CLK=>CLK,UP=>UP_PLAYER_1,DOWN=>DOWN_PLAYER_1,RESET=>RESET_SIG,DRAW=>DRAW_PADDLE_1,V_ADR=>V_ADR,
    H_ADR=>H_ADR,PADDLE_TOP=>PADDLE_TOP_PLAYER_1,PADDLE_BOTTOM=>PADDLE_BOTTOM_PLAYER_1,UP_SIG=>PADDLE_1_UP_STD,
    DOWN_SIG=>PADDLE_1_DOWN_STD);
    
PADDLE_OBJECT_INST_2: PADDLE_OBJECT 
  generic map(PADDLE_POS_X=>1500)
  port map(CLK=>CLK,UP=>UP_PLAYER_2,DOWN=>DOWN_PLAYER_2,RESET=>RESET_SIG,DRAW=>DRAW_PADDLE_2,V_ADR=>V_ADR,
    H_ADR=>H_ADR,PADDLE_TOP=>PADDLE_TOP_PLAYER_2,PADDLE_BOTTOM=>PADDLE_BOTTOM_PLAYER_2,UP_SIG=>PADDLE_2_UP_STD,
    DOWN_SIG=>PADDLE_2_DOWN_STD);
        
FIELD_OBJECT_INST:FIELD_OBJECT
  port map(DRAW=>DRAW_FIELD,H_ADR=>H_ADR,V_ADR=>V_ADR);
  
SCORE_OBJECT_INST_1: SCORE_OBJECT
  port map(CLK=>CLK, RESET=>RESET_SIG,INCREASE=>INCREASE_PLAYER_1,CURRENT_SCORE=>SCORE_PLAYER_1,DRAW=>DRAW_SCORE_1,V_ADR=>V_ADR,H_ADR=>H_ADR);
 
SCORE_OBJECT_INST_2: SCORE_OBJECT
  generic map(START_X=>800)
  port map(CLK=>CLK, RESET=>RESET_SIG,INCREASE=>INCREASE_PLAYER_2,CURRENT_SCORE=>SCORE_PLAYER_2,DRAW=>DRAW_SCORE_2,V_ADR=>V_ADR,H_ADR=>H_ADR);

  
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
   
MAIN:process(CLK,RESET)
  begin
  if(RESET='1') then
	ZUSTAND<=z0;
  elsif(CLK'event and CLK='1') then
    ZUSTAND<=FOLGE_Z;
  end if;
  end process MAIN;
   
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
      --Spiel läuft
      when z1=>
        if(BALL_X_CURRENT=100 and (BALL_Y_CURRENT<PADDLE_TOP_PLAYER_1 or BALL_Y_CURRENT>PADDLE_BOTTOM_PLAYER_1)) then 
          FOLGE_Z<=z3;
        elsif(BALL_X_CURRENT=1500 and (BALL_Y_CURRENT<PADDLE_TOP_PLAYER_2 or BALL_Y_CURRENT>PADDLE_BOTTOM_PLAYER_2)) then
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
