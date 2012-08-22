library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity GAME_CONTROLLER is
    port(
        --! 
        CLK: in std_logic;
        UP_PLAYER_1: in std_logic;
        DOWN_PLAYER_1: in std_logic;
        UP_PLAYER_2: in std_logic;
        DOWN_PLAYER_2: in std_logic;
        RESET: in std_logic;
        DOUT: out std_logic_vector(2 downto 0);
        V_ADR: in std_logic_vector(11 downto 0);
        H_ADR: in std_logic_vector(11 downto 0);
        ADR_CLK: in std_logic
    );
end entity GAME_CONTROLLER;

architecture GAME_CONTROLLER_ARC of GAME_CONTROLLER is
signal PADDLE_1_STEP_IN: std_logic;
signal PADDLE_2_STEP_IN: std_logic;
signal DRAW_BALL:std_logic;
signal DRAW_PADDLE_1:std_logic;
signal DRAW_PADDLE_2:std_logic;
signal DRAW_FIELD:std_logic;
signal BALL_X_CURRENT:integer range 0 to 1599;
signal BALL_Y_CURRENT: integer range 0 to 1199;
signal PADDLE_TOP_PLAYER_1:integer range 0 to 1199;
signal PADDLE_BOTTOM_PLAYER_1:integer range 0 to 1199;
signal PADDLE_TOP_PLAYER_2:integer range 0 to 1199;
signal PADDLE_BOTTOM_PLAYER_2:integer range 0 to 1199;

type ZUSTAENDE is(z0,z1,z2,z3);
signal ZUSTAND,FOLGE_Z:ZUSTAENDE;

--BALL Komponente
component BALL_OBJECT  
    generic(
        BALL_TOP_LIMIT: integer range 0 to 1199:=199;
        BALL_BOTTOM_LIMIT: integer range 0 to 1199:=1100;
        BALL_LEFT_LIMIT: integer range 0 to 1599:=100;
        BALL_RIGHT_LIMIT:integer range 0 to 1599:=1500;
        BALL_X_START: integer range 0 to 1599:=700;
        BALL_Y_START:integer range 0 to 1199:=500;
        BALL_X_START_COUNT: natural:=100000;
        BALL_Y_START_COUNT:natural :=100000;
        BALL_DIMENSION:natural:=50
    );
    port(
        --!
        CLK: in std_logic;
        RESET: in std_logic;
        DRAW: out std_logic;
        V_ADR: in std_logic_vector(11 downto 0);
        H_ADR: in std_logic_vector(11 downto 0);
        X_CURRENT:out integer range 0 to 1599;
        Y_CURRENT:out integer range 0 to 1199
    );
end component BALL_OBJECT;

--PADDLE Komponente
component PADDLE_OBJECT is
    generic(
        PADDLE_TOP_LIMIT: integer range 0 to 1199:=199;
        PADDLE_BOTTOM_LIMIT: integer range 0 to 1199:=1100;
        PADDLE_TOP_START: integer range 0 to 1199:=500;
        PADDLE_BOTTOM_START:integer range 0 to 1199:=580;
        PADDLE_POS_X:integer range 0 to 1599:=90;
        PADDLE_WIDTH:integer range 0 to 1599:=10;
        PADDLE_STEP_WIDTH: integer range 1 to 200:=10 
    );
    port(
        --!
        CLK: in std_logic;
        UP: in std_logic;
        DOWN: in std_logic;
        RESET: in std_logic;
        DRAW: out std_logic;
        V_ADR: in std_logic_vector(11 downto 0);
        H_ADR: in std_logic_vector(11 downto 0);
        PADDLE_TOP: out integer range 0 to 1199;
        PADDLE_BOTTOM: out integer range 0 to 1199
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
        --!
        DRAW: out std_logic;
        V_ADR: in std_logic_vector(11 downto 0);
        H_ADR: in std_logic_vector(11 downto 0)
    );
end component FIELD_OBJECT;


for all: BALL_OBJECT use entity work.BALL_OBJECT(BALL_OBJECT_ARC);
for all: PADDLE_OBJECT use entity work.PADDLE_OBJECT(PADDLE_OBJECT_ARC);
for all: FIELD_OBJECT use entity work.FIELD_OBJECT(FIELD_OBJECT_ARC);

begin

BALL_OBJECT_INST: BALL_OBJECT 
    port map(CLK,RESET,DRAW=>DRAW_BALL,V_ADR=>V_ADR,H_ADR=>H_ADR);
    
PADDLE_OBJECT_INST_1: PADDLE_OBJECT 
    port map(CLK=>CLK,UP=>UP_PLAYER_1,DOWN=>DOWN_PLAYER_1,RESET=>RESET,DRAW=>DRAW_PADDLE_1,V_ADR=>V_ADR,
			 H_ADR=>H_ADR,PADDLE_TOP=>PADDLE_TOP_PLAYER_1,PADDLE_BOTTOM=>PADDLE_BOTTOM_PLAYER_1);
    
PADDLE_OBJECT_INST_2: PADDLE_OBJECT 
	generic map(PADDLE_POS_X=>1500)
    port map(CLK=>CLK,UP=>UP_PLAYER_2,DOWN=>DOWN_PLAYER_2,RESET=>RESET,DRAW=>DRAW_PADDLE_2,V_ADR=>V_ADR,
			 H_ADR=>H_ADR,PADDLE_TOP=>PADDLE_TOP_PLAYER_2,PADDLE_BOTTOM=>PADDLE_BOTTOM_PLAYER_2);
        
FIELD_OBJECT_INST:FIELD_OBJECT
	port map(DRAW=>DRAW_FIELD,H_ADR=>H_ADR,V_ADR=>V_ADR);
	
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
    else
	  DOUT<="000";
    end if;
  end if;
  end process AUSGABE;
        
GAME_AUTOMATE:process(ZUSTAND)
  begin
    FOLGE_Z<=z1;
    case ZUSTAND is
      when z0=>
        FOLGE_Z<=z1;
      when z1=>
      when z2=>
      when z3=>
    end case;
  end process GAME_AUTOMATE;
                
end architecture GAME_CONTROLLER_ARC; 
