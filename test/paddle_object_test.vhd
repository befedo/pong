library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity PADDLE_OBJECT_TEST is
end entity PADDLE_OBJECT_TEST;

architecture PADDLE_OBJECT_ARC_TEST of PADDLE_OBJECT_TEST is
signal L_NOTR:  bit;
signal STEP:  bit;
signal CLK:  bit;
signal RESET:  bit;
signal DRAW:  std_logic;
signal V_ADR:  bit_vector(11 downto 0);
signal H_ADR:  bit_vector(11 downto 0);
signal PADDLE_TOP:  integer range 0 to 1199;
signal PADDLE_BOTTOM:  integer range 0 to 1199;
signal UP_SIG: std_logic;
signal DOWN_SIG: std_logic;

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
        --! Höhe des Paddles, in Pixel
        PADDLE_HEIGTH: integer range 0 to 1199:=100;
        --! Breite des Paddles, in Pixel
        PADDLE_WIDTH:integer range 0 to 1599:=10;
        --! Pixel Schrittweite bei einen Bewegung 
        PADDLE_STEP_WIDTH: integer range 1 to 200:=10;
        --! Verzögerung bei der erkennung der letzten Bewegungsrichtung
        MOVE_REACTION: positive:=1000
    );
    port(
        --! Takteingang
        CLK: in bit;        
        L_NOTR: in bit;
        STEP: in bit;
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


for all: PADDLE_OBJECT use entity work.PADDLE_OBJECT(PADDLE_OBJECT_ARC);

begin
PADDLE_OBJECT_INST: PADDLE_OBJECT 
    port map(CLK,L_NOTR,STEP,RESET,DRAW,V_ADR,H_ADR,PADDLE_TOP,PADDLE_BOTTOM,UP_SIG,DOWN_SIG);
    
CLKGENERATOR: process
begin
    CLK<='1';
    wait for 0.1 ns;
    CLK<='0';
    wait for 0.1 ns;
end process CLKGENERATOR;

STEPGENERATOR: process
begin
    STEP<='1';
    wait for 50 ns;
    STEP<='0';
    wait for 50 ns;
end process STEPGENERATOR;

L_NOTRGENERATOR: process
begin
    L_NOTR<='1';
    wait for 1000 ns;
    L_NOTR<='0';
    wait for 1000 ns;
end process L_NOTRGENERATOR;
    
TEST: process
begin
    RESET<='1';
    wait for 1 ns;
    RESET<='0';
    wait;
end process TEST;

ADR: process
begin
  H_ADR<=(others=>'0');
  V_ADR<=(others=>'0');
  wait for 1 ns;
  loop
  if(conv_integer(to_stdlogicvector(H_ADR)) = 199) then
    H_ADR<=(others=>'0');
    if(conv_integer(to_stdlogicvector(V_ADR)) = 149) then
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
    
    


end architecture PADDLE_OBJECT_ARC_TEST;