-------------------------------------------------------
--! @file paddle_object.vhd
--! @brief Diese Datei beinhaltet ein Spieler Paddle Object, zur Verwaltung der Position und Bewegung des Spieler "Schläger". 
--! @author Matthias Springsetin
--! @date 27.08.12
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity PADDLE_OBJECT is
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
        PADDLE_STEP_WIDTH: integer range 1 to 200:=10 
    );
    port(
        --! Takteingang
        CLK: in std_logic;
        --! Eingang für eine Aufwärtsbewegung
        UP: in std_logic;
        --! Eingang für eine Abwärtsbewegung
        DOWN: in std_logic;
        --! Setzt das Paddle mit einer '1' zurück zur Startposition
        RESET: in std_logic;
        --! Ausgang ob die aktuelle Position(V_ADR und H_ADR) ein Bildpunkt enthält 
        DRAW: out std_logic;
        --! Vertikale Adresse 
        V_ADR: in std_logic_vector(11 downto 0);
        --! Horizontale Adresse
        H_ADR: in std_logic_vector(11 downto 0);
        --! Aktuelle obere Position des Paddles
        PADDLE_TOP: out integer range 0 to 1199;
        --! Aktuelle untere Position des Paddles
        PADDLE_BOTTOM: out integer range 0 to 1199
    );
end entity PADDLE_OBJECT;

architecture PADDLE_OBJECT_ARC of PADDLE_OBJECT is
signal PADDLE_TOP_SIG: integer range 0 to 1199;
signal LOW_CLK: std_logic;

--PLEASE REMOVE ME
component FREQUENZTEILER is
    generic(	--! Parameter, durch welchen geteilt wird
        		CLKVALUE : positive := 100000
    );
	port(		--! Takteingang
				CLK,
				--! Reset Leitung 
				RESET    :   in std_logic;
				--! Taktausgang
				CLKOUT        :   out std_logic
	);
end component FREQUENZTEILER;


for all: FREQUENZTEILER use entity work.FREQUENZTEILER(VERHALTEN);

--PLEASE REMOVE ME NOT

begin
--PLEASE REMOVE ME

F_INST: FREQUENZTEILER
	port map(CLK=>CLK,RESET=>RESET, CLKOUT=>LOW_CLK);

--PLEASE REMOVE ME NOT


PLAYER_PADDLE:process(CLK,RESET)
  begin           
  if(RESET='1') then
    PADDLE_TOP_SIG<=PADDLE_TOP_START;
  elsif (LOW_CLK'event and LOW_CLK='1') then
    if(UP='1' and PADDLE_TOP_SIG>PADDLE_TOP_LIMIT) then
      PADDLE_TOP_SIG<=PADDLE_TOP_SIG-1;
    elsif(DOWN='1' and PADDLE_TOP_SIG+PADDLE_HEIGTH<PADDLE_BOTTOM_LIMIT) then
      PADDLE_TOP_SIG<=PADDLE_TOP_SIG+1;
    end if;
  end if;
  end process PLAYER_PADDLE;
               
AUSGABE:process(H_ADR,V_ADR)
     begin
        DRAW<='0';
        if(not(to_integer(unsigned(H_ADR))<PADDLE_POS_X or to_integer(unsigned(H_ADR))>(PADDLE_POS_X+PADDLE_WIDTH))) then
            if(not(to_integer(unsigned(V_ADR))<PADDLE_TOP_SIG or to_integer(unsigned(V_ADR))>(PADDLE_TOP_SIG+PADDLE_HEIGTH))) then
				DRAW<='1';
			end if;
		end if;
     end process;
               
PADDLE_TOP<=PADDLE_TOP_SIG;
PADDLE_BOTTOM<=PADDLE_TOP_SIG+PADDLE_HEIGTH;
                
end architecture PADDLE_OBJECT_ARC; 
