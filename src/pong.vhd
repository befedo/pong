-------------------------------------------------------
--! @file pong.vhd
--! @brief Diese Datei beinhaltet die Hauptentity(Gegebenenfals noch eine Entity fÃ¼r die Pinzuweisung).
--! @author Matthias Springsetin
--! @author Marc Ludwig
--! @date 27.08.12
-------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity PONG is
    port(
        --! Takteingang
        CLK: in bit;
        --! Setzt das Spiel zurÃ¼ck
        RESET: in bit;
        --! Eingang des Imkrementalgebers Spieler 1
        PADDLE_PLAYER1: in bit_vector(1 downto 0);
        --! Eingang des Imkrementalgebers Spieler 2
        PADDLE_PLAYER2: in bit_vector(1 downto 0);
        --! H-sync Ausgang des VGA Anschlusses
        H_SYNC: out std_logic;
        --! V-sync Ausgang des VGA Anschlusses
        V_SYNC: out std_logic;
        --! Rot Werte an den DAC Wandler
        RED: out std_logic_vector(9 downto 0);
        --! GrÃ¼n Werte an den DAC Wandler
        GREEN: out std_logic_vector(9 downto 0);
        --! Blau Werte an den DAC Wandler
        BLUE: out std_logic_vector(9 downto 0);
        --! Takt Ausgang zum DAC
        VGA_CLOCK: out std_logic;
        --! Blank Ausgang zum DAC
        VGA_BLANK: out std_logic;
        --! Sync Ausgang zum DAC
        VGA_SYNC: out std_logic
    );
end entity PONG;


architecture PONG_ARC of PONG is

component GAME_CONTROLLER     
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
end component GAME_CONTROLLER;

component VIDEO_CONTROLLER is
    port(
        --! Takteingang
        CLK : in bit;
        --! H-sync Ausgang des VGA Anschlusses
        H_SYNC,
        --! V-sync Ausgang des VGA Anschlusses
        V_SYNC: out std_logic;
        --! Rot Werte an den DAC Wandler
        RED,
        --! Grn Werte an den DAC Wandler
        GREEN,
        --! Blau Werte an den DAC Wandler
        BLUE: out std_logic_vector(9 downto 0);
        --! Takt Ausgang zum DAC
        VGA_CLOCK,
        --! Blank Ausgang zum DAC
        VGA_BLANK,
        --! Sync Ausgang zum DAC
        VGA_SYNC: out std_logic;
        H_ADR: out std_logic_vector(11 downto 0);
        V_ADR: out std_logic_vector(11 downto 0);
        DIN: in bit_vector(2 downto 0);
        ADR_CLK: out std_logic
    );
end component VIDEO_CONTROLLER;

component PADDLE is
	port(	--!	Takteingang
			CLK_50Mhz,
			--! Resetleitung
			RESET			:	in	bit;
			--!	Eingangsvektor
			DIN				:	in	bit_vector(1 downto 0);
			--! Richtungsvorgabe
			LEFTNOTRIGHT,
			--! Generierter Schritttakt
			STEP			:	out	std_logic
	);
end component PADDLE;

for all: VIDEO_CONTROLLER use entity work.VIDEO_CONTROLLER(VIDEO_CONTROLLER_ARC);
for all: GAME_CONTROLLER use entity work.GAME_CONTROLLER(GAME_CONTROLLER_ARC);
for all: PADDLE use entity work.PADDLE(VERHALTEN);

--! Aktuelle Vertikale Adresse(Umgewandelt)
signal V_ADR: bit_vector(11 downto 0);
--! Aktuelle Horizontale Adresse(Umgewandelt)
signal H_ADR: bit_vector(11 downto 0);
--! Aktuelle Vertikale Adresse
signal V_ADR_STD: std_logic_vector(11 downto 0);
--! Aktuelle Horizontale Adresse
signal H_ADR_STD: std_logic_vector(11 downto 0);
--! Taktfrequenz mit der sich H_ADR und V_ADR verändern(Umgewandelt)
signal PIXEL_CLK: bit;
--! Taktfrequenz mit der sich H_ADR und V_ADR verändern
signal PIXEL_CLK_STD: std_logic;
--! Signal für die Unterscheidung ob sich das Paddle, des 1 Spielers, nach oben oder nach unten bewegen soll
signal L_NOTR_PLAYER_1:  std_logic;
--! Mit jeder Flanke von Step wird eine Bewegung nach unten oder nach oben vollzogen(erster Spieler)
signal STEP_PLAYER_1:  std_logic;
--! Signal für die Unterscheidung ob sich das Paddle, des 2 Spielers, nach oben oder nach unten bewegen soll
signal L_NOTR_PLAYER_2:  std_logic;
--! Mit jeder Flanke von Step wird eine Bewegung nach unten oder nach oben vollzogen(zweiter Spieler)
signal STEP_PLAYER_2:  std_logic;
--! Signal für die Unterscheidung ob sich das Paddle, des 1 Spielers, nach oben oder nach unten bewegen soll(Umgewandelt)
signal L_NOTR_PLAYER_1_BIT:  bit;
--! Mit jeder Flanke von Step wird eine Bewegung nach unten oder nach oben vollzogen(erster Spieler)(Umgewandelt)
signal STEP_PLAYER_1_BIT:  bit;
--! Signal für die Unterscheidung ob sich das Paddle, des 2 Spielers, nach oben oder nach unten bewegen soll(Umgewandelt)
signal L_NOTR_PLAYER_2_BIT:  bit;
--! Mit jeder Flanke von Step wird eine Bewegung nach unten oder nach oben vollzogen(zweiter Spieler)(Umgewandelt)
signal STEP_PLAYER_2_BIT:  bit;
--! Farben Vektor
signal DATA:bit_vector(2 downto 0);

begin

VIDEO_CONTROLLER_INST : VIDEO_CONTROLLER       
  port map(CLK=>CLK,H_SYNC=>H_SYNC,V_SYNC=>V_SYNC,RED=>RED,GREEN=>GREEN,BLUE=>BLUE,VGA_CLOCK=>VGA_CLOCK,
           VGA_BLANK=>VGA_BLANK,VGA_SYNC=>VGA_SYNC,H_ADR=>H_ADR_STD,V_ADR=>V_ADR_STD,DIN=>DATA,ADR_CLK=>PIXEL_CLK_STD );
GAME_CONTROLLER_INST : GAME_CONTROLLER       
  port map(CLK=>CLK,STEP_PLAYER1 => STEP_PLAYER_1_BIT, LNOTR_PLAYER1 => L_NOTR_PLAYER_1_BIT, STEP_PLAYER2 => STEP_PLAYER_2_BIT,LNOTR_PLAYER2 => L_NOTR_PLAYER_2_BIT, RESET=>RESET,DOUT=>DATA,V_ADR=>V_ADR,H_ADR=>H_ADR,ADR_CLK=>PIXEL_CLK);
           
PADDLE_INT1: PADDLE
  port map(CLK_50Mhz => CLK, RESET => RESET, DIN => PADDLE_PLAYER1, LEFTNOTRIGHT => L_NOTR_PLAYER_1, STEP => STEP_PLAYER_1);
  
PADDLE_INT2: PADDLE
  port map(CLK_50Mhz => CLK, RESET => RESET, DIN => PADDLE_PLAYER2, LEFTNOTRIGHT => L_NOTR_PLAYER_2, STEP => STEP_PLAYER_2);  


L_NOTR_PLAYER_1_BIT<=to_bit(L_NOTR_PLAYER_1);
L_NOTR_PLAYER_2_BIT<=to_bit(L_NOTR_PLAYER_2);
STEP_PLAYER_1_BIT<=to_bit(STEP_PLAYER_1);
STEP_PLAYER_2_BIT<=to_bit(STEP_PLAYER_2);
H_ADR<=to_bitvector(H_ADR_STD);
V_ADR<=to_bitvector(V_ADR_STD);
PIXEL_CLK<=to_bit(PIXEL_CLK_STD);

end architecture PONG_ARC;
