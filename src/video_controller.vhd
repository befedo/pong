 
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------
--! @file
--! @brief PONG Hauptentity 
-------------------------------------------------------
entity VIDEO_CONTROLLER is
    port(
        --! Takteingang
        CLK: in bit;
        --! Setzt das Spiel zurück
        RESET: in bit;
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
end entity VIDEO_CONTROLLER;


architecture VIDEO_CONTROLLER_ARC of VIDEO_CONTROLLER is
signal H_ADR: bit_vector(9 downto 0);
signal V_ADR: bit_vector(8 downto 0);
signal DIN: bit_vector(2 downto 0);
signal DOUT: std_logic_vector(2 downto 0);
signal WE,EN: bit;

component VGA_RAM    
    generic(
        --! Horizontale groesse des Rams.
       H_WIDTH:natural:=10;
        --! Vertikale groesse des Rams.
       V_WIDTH:natural:=9;
        --! Breite eines Speicherbereichs.
       WORD_WIDTH:natural:=3
    );
    port(
        --! Adresseingang für die Horizontale.
        H_ADR: in bit_vector(H_WIDTH-1 downto 0);
        --! Adresseingang für die Vertikale.
        V_ADR: in bit_vector(V_WIDTH-1 downto 0);
        --! Eingangsleitung zum Parallelen schreiben.
        DIN: in bit_vector(WORD_WIDTH-1 downto 0);
        --! Alle Operationen werden mit denn Takt synchronisiert.
        CLK: in bit;
        --! Wenn das signal High ist wird das aktuelle Signal am DIN gespeichert. EN muss auch HIGH sein damit ein Effekt auftritt.
        WE: in bit;
        --! Wenn das signal High ist wird der Speicherbaustein aktiv.
        EN: in bit;
        --! Datenausgangsleitung zum Parallelen lesen.
        DOUT: out std_logic_vector(WORD_WIDTH-1 downto 0)
    );
end component VGA_RAM;


signal  SIG_RED, SIG_GREEN, SIG_BLUE                            : bit;
signal  SIG_RED_OUT, SIG_GREEN_OUT, SIG_BLUE_OUT, 
        SIG_H_SYNC_OUT, SIG_V_SYNC_OUT, 
        SIG_VIDEO_ON, SIG_PIXEL_CLOCK                           : std_logic;
signal  SIG_PIXEL_ROW, SIG_PIXEL_COLUMN                         : std_logic_vector(9 downto 0);

component VGA is   
          port( CLOCK_50Mhz, RED, GREEN, BLUE                   : in std_logic;
                RED_OUT, GREEN_OUT, BLUE_OUT, H_SYNC_OUT, 
                V_SYNC_OUT, VIDEO_ON, PIXEL_CLOCK               : out std_logic;
                PIXEL_ROW, PIXEL_COLUMN                         : out std_logic_vector(9 downto 0)
          ); 
end component VGA ; 

for all: VGA_RAM use entity work.VGA_RAM(VGA_RAM_ARC);
for all: VGA use entity work.VGA(ARCH);

begin


end architecture VIDEO_CONTROLLER_ARC;
