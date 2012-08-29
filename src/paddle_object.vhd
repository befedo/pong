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
        PADDLE_STEP_WIDTH: integer range 1 to 200:=10;
        MOVE_REACTION: positive:=100
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
end entity PADDLE_OBJECT;

architecture PADDLE_OBJECT_ARC of PADDLE_OBJECT is
signal PADDLE_TOP_SIG: integer range 0 to 1199;
signal PADDLE_TOP_SIG_LAST: integer range 0 to 1199;
signal COUNT: natural;

begin

PLAYER_PADDLE:process(STEP,RESET)
  begin           
  if(RESET='1') then
    PADDLE_TOP_SIG<=PADDLE_TOP_START;
  elsif (STEP'EVENT and STEP='1') then
    if(L_NOTR='1' and PADDLE_TOP_SIG>PADDLE_TOP_LIMIT) then
      PADDLE_TOP_SIG<=PADDLE_TOP_SIG-PADDLE_STEP_WIDTH;
    elsif(L_NOTR='0' and PADDLE_TOP_SIG+PADDLE_HEIGTH<PADDLE_BOTTOM_LIMIT) then
      PADDLE_TOP_SIG<=PADDLE_TOP_SIG+PADDLE_STEP_WIDTH;
    end if;
  end if;
  end process PLAYER_PADDLE;
               
AUSGABE:process(H_ADR,V_ADR)
     begin
        DRAW<='0';
        if(not(to_integer(unsigned(to_stdlogicvector(H_ADR)))<PADDLE_POS_X or to_integer(unsigned(to_stdlogicvector(H_ADR)))>(PADDLE_POS_X+PADDLE_WIDTH))) then
            if(not(to_integer(unsigned(to_stdlogicvector(V_ADR)))<PADDLE_TOP_SIG or to_integer(unsigned(to_stdlogicvector(V_ADR)))>(PADDLE_TOP_SIG+PADDLE_HEIGTH))) then
				DRAW<='1';
			end if;
		end if;
     end process;
               
PADDLE_TOP<=PADDLE_TOP_SIG;
PADDLE_BOTTOM<=PADDLE_TOP_SIG+PADDLE_HEIGTH;

MOVEMENT:process(CLK)
	begin
		if(CLK'event and CLK='1') then
			if(PADDLE_TOP_SIG=PADDLE_TOP_SIG_LAST) then
				COUNT<=COUNT+1;
				if(COUNT>MOVE_REACTION) then
					UP_SIG<='0';
					DOWN_SIG<='0';
					COUNT<=0;
				end if;
			else
				COUNT<=0;
				if(PADDLE_TOP_SIG<PADDLE_TOP_SIG_LAST) then
					UP_SIG<='1';
				else 
					DOWN_SIG<='1';
				end if;
			end if;
		end if;
	end process;
                
end architecture PADDLE_OBJECT_ARC; 
