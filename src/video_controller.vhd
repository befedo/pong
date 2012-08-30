 
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------
--! @file
--! @brief PONG Hauptentity 
-------------------------------------------------------

entity VIDEO_CONTROLLER is
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
        --! Aktuelle Horizontale Position der Ausgabe
        H_ADR: out std_logic_vector(11 downto 0);
        --! Aktuelle Vertikale Position der Ausgabe
        V_ADR: out std_logic_vector(11 downto 0);
        --! Farbvektor der an der aktuelle Position ausgegeben werden soll
        DIN: in bit_vector(2 downto 0);
        --! Taktfrequenz mit der sich H_ADR und V_ADR verändern
        ADR_CLK: out std_logic
    );
end entity VIDEO_CONTROLLER;


architecture VIDEO_CONTROLLER_ARC of VIDEO_CONTROLLER is
				
component VGA is   
          port( RED, GREEN, BLUE, CLOCK_50Mhz				: in bit;
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

--! Umwandlung des 1 Bit Farbwertes zur Ausgabe an den Analog Device D/A Wandler
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
