library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity GAME_CONTROLLER is
    port(
        --!
        L_NOTR_PLAYER_1: in bit;
        STEP_PLAYER_1: in bit;
        L_NOTR_PLAYER_2: in bit;
        STEP_PLAYER_2: in bit;
        CLK: in bit;
        RESET: in bit;
        DOUT: out std_logic_vector(2 downto 0);
        V_ADR: out std_logic_vector(7 downto 0);
        H_ADR: out std_logic_vector(7 downto 0);
        PICTURE_COMPLETE: out std_logic
    );
end entity GAME_CONTROLLER;

architecture GAME_CONTROLLER_ARC of GAME_CONTROLLER is
signal VCOUNTER:integer range 0 to 199;
signal HCOUNTER:integer range 0 to 149;
signal VCOUNTER_BIT:bit_vector(7 downto 0);
signal HCOUNTER_BIT:bit_vector(7 downto 0);
signal PADDLE_1_STEP_IN: bit;
signal PADDLE_2_STEP_IN: bit;
signal DRAW_BALL:std_logic;
signal DRAW_PADDLE_1:std_logic;
signal DRAW_PADDLE_2:std_logic;
signal BALL_X_CURRENT:integer range 0 to 199;
signal BALL_Y_CURRENT: integer range 0 to 149;
type ZUSTAENDE is(z0,z1,z2,z3);
signal ZUSTAND,FOLGE_Z:ZUSTAENDE;

--BALL Komponente
component BALL_OBJECT  
    generic(
        BALL_TOP_LIMIT: integer range 0 to 149:=10;
        BALL_BOTTOM_LIMIT: integer range 0 to 149:=20;
        BALL_LEFT_LIMIT: integer range 0 to 199:=10;
        BALL_RIGHT_LIMIT:integer range 0 to 199:=20;
        BALL_X_START: integer range 0 to 199:=11;
        BALL_Y_START:integer range 0 to 149:=11;
        BALL_X_START_COUNT: natural:=10000;
        BALL_Y_START_COUNT:natural :=50000
    );
    port(
        --!
        CLK: in bit;
        RESET: in bit;
        DRAW: out std_logic;
        V_ADR: in bit_vector(7 downto 0);
        H_ADR: in bit_vector(7 downto 0);
        X_CURRENT:out integer range 0 to 199;
        Y_CURRENT:out integer range 0 to 149
    );
end component BALL_OBJECT;

--PADDLE Komponente
component PADDLE_OBJECT is
    generic(
        PADDLE_TOP_SIG_LIMIT: integer range 0 to 149:=10;
        PADDLE_BOTTOM_SIG_LIMIT: integer range 0 to 149:=120;
        PADDLE_TOP_SIG_START: integer range 0 to 149:=65;
        PADDLE_BOTTOM_SIG_START:integer range 0 to 149:=85;
        PADDLE_POS_X:integer range 0 to 199:=20;
        PADDLE_WIDTH:integer range 0 to 199:=5
    );
    port(
        --!
        L_NOTR: in bit;
        STEP: in bit;
        CLK: in bit;
        RESET: in bit;
        DRAW: out std_logic;
        V_ADR: in bit_vector(7 downto 0);
        H_ADR: in bit_vector(7 downto 0);
        PADDLE_TOP: out integer range 0 to 149;
        PADDLE_BOTTOM: out integer range 0 to 149
    );
end component PADDLE_OBJECT;

for all: BALL_OBJECT use entity work.BALL_OBJECT(BALL_OBJECT_ARC);
for all: PADDLE_OBJECT use entity work.PADDLE_OBJECT(PADDLE_OBJECT_ARC);

begin


BALL_OBJECT_INST: BALL_OBJECT 
    port map(CLK,RESET,DRAW=>DRAW_BALL,V_ADR=>VCOUNTER_BIT,H_ADR=>HCOUNTER_BIT,X_CURRENT=>BALL_X_CURRENT,Y_CURRENT=>BALL_Y_CURRENT);
    

PADDLE_OBJECT_INST_1: PADDLE_OBJECT 
    port map(L_NOTR=>L_NOTR_PLAYER_1,STEP=>PADDLE_1_STEP_IN,CLK,RESET,DRAW=>DRAW_PADDLE_1,V_ADR=>VCOUNTER_BIT,H_ADR=>HCOUNTER_BIT,PADDLE_TOP,PADDLE_BOTTOM);
    
    
PADDLE_OBJECT_INST_2: PADDLE_OBJECT 
    port map(L_NOTR=>L_NOTR_PLAYER_2,STEP=>PADDLE_2_STEP_IN,CLK,RESET,DRAW=>DRAW_PADDLE_2,V_ADR=>VCOUNTER_BIT,H_ADR=>HCOUNTER_BIT,PADDLE_TOP,PADDLE_BOTTOM);
    
COUNT_GENERATOR:process(CLK,RESET)
  begin
                
  if(RESET='1') then
    VCOUNTER<=0;
    HCOUNTER<=0;
    ZUSTAND<=z0;
  elsif(CLK'EVENT and CLK='1') then
    --Zustand uebernehmen
    ZUSTAND<=FOLGE_Z;
    --Counter
    if(VCOUNTER<199) then
      VCOUNTER<=VCOUNTER+1;
    else 
      VCOUNTER<=0;
      if(HCOUNTER<149) then
        HCOUNTER<=HCOUNTER+1;
      else 
        HCOUNTER<=0;
      end if;
    end if;
  end if;
  end process COUNT_GENERATOR;
                
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
