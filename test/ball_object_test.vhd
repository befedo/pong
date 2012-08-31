library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity BALL_OBJECT_TEST is
end entity BALL_OBJECT_TEST;

architecture BALL_OBJECT_ARC_TEST of BALL_OBJECT_TEST is
signal CLK: bit;
signal RESET:  bit;
signal RESET_2: bit;
signal DRAW: std_logic;
signal V_ADR: bit_vector(11 downto 0);
signal H_ADR:  bit_vector(11 downto 0);
signal X_CURRENT: integer range 0 to 199;
signal Y_CURRENT: integer range 0 to 149;
signal PADDLE_1_UP: bit;
signal PADDLE_1_DOWN: bit;
signal PADDLE_2_UP: bit;
signal PADDLE_2_DOWN: bit;

component BALL_OBJECT  
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
end component BALL_OBJECT;

for all: BALL_OBJECT use entity work.BALL_OBJECT(BALL_OBJECT_ARC);

begin
BALL_OBJECT_INST: BALL_OBJECT 
    port map(CLK,RESET,RESET_2,DRAW,V_ADR,H_ADR,X_CURRENT,Y_CURRENT,PADDLE_1_UP,PADDLE_1_DOWN,PADDLE_2_UP,PADDLE_2_DOWN);
    
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
    
    


end architecture BALL_OBJECT_ARC_TEST;