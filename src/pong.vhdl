library IEEE;
use IEEE.std_logic_1164.all;

-------------------------------------------------------
--! @file
--! @brief PONG Hauptentity 
-------------------------------------------------------
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
end entity;


architecture PONG_ARC of PONG is


begin


end architecture;
