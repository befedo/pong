<<<<<<< HEAD
 
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------
--! @file
--! @brief PONG Hauptentity 
-------------------------------------------------------

entity VIDEO_CONTROLLER is
    port(
        --! Takteingang
        CLK: in std_logic;
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
end entity VIDEO_CONTROLLER;


architecture VIDEO_CONTROLLER_ARC of VIDEO_CONTROLLER is
				
component VGA is   
          port( RED, GREEN, BLUE, CLOCK_50Mhz				: in std_logic;
				RED_OUT, GREEN_OUT, BLUE_OUT, H_SYNC_OUT, 
                V_SYNC_OUT, VIDEO_ON, PIXEL_CLOCK			: out std_logic;
                PIXEL_ROW, PIXEL_COLUMN						: out std_logic_vector(11 downto 0)
          ); 
end component VGA ; 

for all: VGA use entity work.VGA(ARCH);

signal PIXEL_ROW:std_logic_vector(11 downto 0);
signal PIXEL_COLUMN:std_logic_vector(11 downto 0);
signal SIG_VGA_CLK: std_logic;
signal SIG_VIDEO_ON: std_logic;
signal SIG_GREEN: std_logic;
signal SIG_BLUE: std_logic;
signal SIG_RED: std_logic;


begin
-- Takt auf beide Komponente -> 50MHz
-- Temporre Signale da Quartus konvertierungen in der Port Map nicht zu lt

GEN_VGA : VGA		port map( CLOCK_50Mhz => CLK, RED => DIN(0), GREEN => DIN(1), BLUE => DIN(2),
	RED_OUT => SIG_RED, GREEN_OUT => SIG_GREEN, BLUE_OUT => SIG_BLUE, H_SYNC_OUT => H_SYNC,
	V_SYNC_OUT => V_SYNC, VIDEO_ON => SIG_VIDEO_ON, PIXEL_CLOCK => SIG_VGA_CLK, PIXEL_ROW=>PIXEL_ROW, PIXEL_COLUMN=>PIXEL_COLUMN);

process(SIG_VGA_CLK)
begin
	if(SIG_VGA_CLK'event and SIG_VGA_CLK='1') then
		if (SIG_RED='1') then
			RED<=(others=>'1');
		else
			RED<=(others=>'0');
		end if;

		if (SIG_GREEN='1') then
			GREEN<=(others=>'1');
		else
			GREEN<=(others=>'0');
		end if;

		if (SIG_BLUE='1') then
			BLUE<=(others=>'1');
		else
			BLUE<=(others=>'0');
		end if;
	end if;
end process;

VGA_BLANK<=SIG_VIDEO_ON;
VGA_CLOCK<=SIG_VGA_CLK;
VGA_SYNC<='1';
ADR_CLK<=SIG_VGA_CLK;
H_ADR<=PIXEL_COLUMN;
V_ADR<=PIXEL_ROW;



end architecture VIDEO_CONTROLLER_ARC;
=======
 
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------
--! @file
--! @brief PONG Hauptentity 
-------------------------------------------------------

entity VIDEO_CONTROLLER is
    port(
        --! Takteingang
        CLK,
        --! Setzt das Spiel zurck
        RESET : in bit;
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
        VGA_SYNC: out std_logic
    );
end entity VIDEO_CONTROLLER;


architecture VIDEO_CONTROLLER_ARC of VIDEO_CONTROLLER is

signal SIG_CLK, SIG_GND, SIG_VCC			: bit;
signal SIG_DATA, SIG_DIN					: bit_vector(2 downto 0);
signal SIG_TMP_DATA							: std_logic_vector(2 downto 0);
signal SIG_H_ADR, SIG_V_ADR					: bit_vector(9 downto 0);
signal SIG_TMP_H_ADR, SIG_TMP_V_ADR			: std_logic_vector(9 downto 0);
signal SIG_H_SYNC, SIG_V_SYNC, SIG_VGA_CLK	: std_logic;


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
        --! Adresseingang fr die Horizontale.
        H_ADR: in bit_vector(H_WIDTH-1 downto 0);
        --! Adresseingang fr die Vertikale.
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

				
component VGA is   
          port( RED, GREEN, BLUE, CLOCK_50Mhz				: in bit;
				RED_OUT, GREEN_OUT, BLUE_OUT, H_SYNC_OUT, 
                V_SYNC_OUT, VIDEO_ON, PIXEL_CLOCK			: out std_logic;
                PIXEL_ROW, PIXEL_COLUMN						: out std_logic_vector(9 downto 0)
          ); 
end component VGA ; 


for all: VGA_RAM use entity work.VGA_RAM(VGA_RAM_ARC);
for all: VGA use entity work.VGA(ARCH);


begin
-- Takt auf beide Komponente -> 50MHz
SIG_CLK <= CLK;
SIG_GND <= '0';
SIG_VCC <= '1';
SIG_DIN <= "000";
-- Temporre Signale da Quartus konvertierungen in der Port Map nicht zu lt
SIG_TMP_DATA <= to_stdlogicvector(SIG_DATA);
SIG_TMP_H_ADR <= to_stdlogicvector(SIG_H_ADR);
SIG_TMP_V_ADR <= to_stdlogicvector(SIG_V_ADR);

GEN_RAM : VGA_RAM 	port map( H_ADR => SIG_H_ADR, V_ADR => SIG_V_ADR(8 downto 0), DIN => SIG_DIN, CLK => SIG_CLK, WE => SIG_GND, EN => SIG_VCC, DOUT => SIG_TMP_DATA );
GEN_VGA : VGA		port map( CLOCK_50Mhz => SIG_CLK, RED => SIG_DATA(0), GREEN => SIG_DATA(1), BLUE => SIG_DATA(2), RED_OUT => OPEN, GREEN_OUT => OPEN, BLUE_OUT => OPEN, H_SYNC_OUT => SIG_H_SYNC, V_SYNC_OUT => SIG_V_SYNC, VIDEO_ON => OPEN, PIXEL_CLOCK => SIG_VGA_CLK, PIXEL_ROW => SIG_TMP_H_ADR, PIXEL_COLUMN => SIG_TMP_H_ADR );



end architecture VIDEO_CONTROLLER_ARC;
>>>>>>> quartus
