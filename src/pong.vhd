library ieee;
use ieee.std_logic_1164.all;
-------------------------------------------------------
--! @file
--! @brief PONG Hauptentity 
-------------------------------------------------------
entity PONG is
    port(
        --! Takteingang
        CLK: in std_logic;
        --! Setzt das Spiel zurück
        RESET: in std_logic;
        --! Eingang des Imkrementalgebers Spieler 1
        PADDLE_PLAYER1: in std_logic_vector(1 downto 0);
        --! Eingang des Imkrementalgebers Spieler 2
        PADDLE_PLAYER2: in std_logic_vector(1 downto 0);
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
        --! 
        CLK,
		  ADR_CLK,
        UP_PLAYER_1,
        DOWN_PLAYER_1,
        UP_PLAYER_2,
        DOWN_PLAYER_2,
        RESET: in std_logic;
        DOUT: out std_logic_vector(2 downto 0);
        V_ADR: in std_logic_vector(11 downto 0);
        H_ADR: in std_logic_vector(11 downto 0)
    );
end component GAME_CONTROLLER;

component VIDEO_CONTROLLER is
    port(
        --! Takteingang
        CLK : in std_logic;
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
		  DIN: in std_logic_vector(2 downto 0);
		  ADR_CLK: out std_logic
    );
end component VIDEO_CONTROLLER;


for all: VIDEO_CONTROLLER use entity work.VIDEO_CONTROLLER(VIDEO_CONTROLLER_ARC);
for all: GAME_CONTROLLER use entity work.GAME_CONTROLLER(GAME_CONTROLLER_ARC);

signal V_ADR: std_logic_vector(11 downto 0);
signal H_ADR: std_logic_vector(11 downto 0);
signal PIXEL_CLK: std_logic;
signal L_NOTR_PLAYER_1:  std_logic;
signal STEP_PLAYER_1:  std_logic;
signal L_NOTR_PLAYER_2:  std_logic;
signal STEP_PLAYER_2:  std_logic;
signal DATA:std_logic_vector(2 downto 0);

begin

VIDEO_CONTROLLER_INST : VIDEO_CONTROLLER       
  port map(CLK=>CLK,H_SYNC=>H_SYNC,V_SYNC=>V_SYNC,RED=>RED,GREEN=>GREEN,BLUE=>BLUE,VGA_CLOCK=>VGA_CLOCK,
           VGA_BLANK=>VGA_BLANK,VGA_SYNC=>VGA_SYNC,H_ADR=>H_ADR,V_ADR=>V_ADR,DIN=>DATA,ADR_CLK=>PIXEL_CLK );
GAME_CONTROLLER_INST : GAME_CONTROLLER       
  port map(CLK=>CLK, UP_PLAYER_1=>L_NOTR_PLAYER_1,DOWN_PLAYER_1=>STEP_PLAYER_1,UP_PLAYER_2=>L_NOTR_PLAYER_2,
           DOWN_PLAYER_2=>STEP_PLAYER_2,RESET=>RESET,DOUT=>DATA,V_ADR=>V_ADR,H_ADR=>H_ADR,ADR_CLK=>PIXEL_CLK);

L_NOTR_PLAYER_1<=PADDLE_PLAYER1(0);
L_NOTR_PLAYER_2<=PADDLE_PLAYER2(0);
STEP_PLAYER_1<=PADDLE_PLAYER1(1);
STEP_PLAYER_2<=PADDLE_PLAYER2(1);

end architecture PONG_ARC;
