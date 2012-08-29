-------------------------------------------------------
--! @file pong.vhd
--! @brief Diese Datei beinhaltet die Hauptentity(Gegebenenfals noch eine Entity für die Pinzuweisung).
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
        --! Setzt das Spiel zurück
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
        --! Grün Werte an den DAC Wandler
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

for all: VIDEO_CONTROLLER use entity work.VIDEO_CONTROLLER(VIDEO_CONTROLLER_ARC);
for all: GAME_CONTROLLER use entity work.GAME_CONTROLLER(GAME_CONTROLLER_ARC);

signal V_ADR: bit_vector(11 downto 0);
signal H_ADR: bit_vector(11 downto 0);
signal V_ADR_STD: std_logic_vector(11 downto 0);
signal H_ADR_STD: std_logic_vector(11 downto 0);
signal PIXEL_CLK: bit;
signal PIXEL_CLK_STD: std_logic;
signal L_NOTR_PLAYER_1:  bit;
signal STEP_PLAYER_1:  bit;
signal L_NOTR_PLAYER_2:  bit;
signal STEP_PLAYER_2:  bit;
signal DATA:bit_vector(2 downto 0);

begin

VIDEO_CONTROLLER_INST : VIDEO_CONTROLLER       
  port map(CLK=>CLK,H_SYNC=>H_SYNC,V_SYNC=>V_SYNC,RED=>RED,GREEN=>GREEN,BLUE=>BLUE,VGA_CLOCK=>VGA_CLOCK,
           VGA_BLANK=>VGA_BLANK,VGA_SYNC=>VGA_SYNC,H_ADR=>H_ADR_STD,V_ADR=>V_ADR_STD,DIN=>DATA,ADR_CLK=>PIXEL_CLK_STD );
GAME_CONTROLLER_INST : GAME_CONTROLLER       
  port map(CLK=>CLK, UP_PLAYER_1=>L_NOTR_PLAYER_1,DOWN_PLAYER_1=>STEP_PLAYER_1,UP_PLAYER_2=>L_NOTR_PLAYER_2,
           DOWN_PLAYER_2=>STEP_PLAYER_2,RESET=>RESET,DOUT=>DATA,V_ADR=>V_ADR,H_ADR=>H_ADR,ADR_CLK=>PIXEL_CLK);

L_NOTR_PLAYER_1<=PADDLE_PLAYER1(0);
L_NOTR_PLAYER_2<=PADDLE_PLAYER2(0);
STEP_PLAYER_1<=PADDLE_PLAYER1(1);
STEP_PLAYER_2<=PADDLE_PLAYER2(1);

H_ADR<=to_bitvector(H_ADR_STD);
V_ADR<=to_bitvector(V_ADR_STD);
PIXEL_CLK<=to_bit(PIXEL_CLK_STD);

end architecture PONG_ARC;
