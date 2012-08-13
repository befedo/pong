library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

------------------------------------------------------------------------------------------------------
--! @file	vga.vhd
--! @brief 	Diese Entity erzeugt die Videosynchronisationssignale fr das Video->Monitor Interface,
-- 			sowie die RGB und Sync Signale und kann somit direkt an die VGA-Schnittstelle angeschlossen 
--			werden.
------------------------------------------------------------------------------------------------------

entity VGA is
	PORT(	--! Takteingang
			CLOCK_50Mhz,
			--! selektiert den roten Ausgang
			RED,
			--! selektiert den grnen Ausgang
			GREEN,
			--! selektiert den blauen Ausgang
			BLUE		: in	std_logic;
			--! Ausgang Rot
			RED_OUT,
			--! Ausgang Grn
			GREEN_OUT,
			--! Ausgang Blau
			BLUE_OUT,
			--! Ausgang H-Sync
			H_SYNC_OUT,
			--! Ausgang V-Sync
			V_SYNC_OUT,
			--! Ausgang Video aktiv
			VIDEO_ON,
			--! Pixeltakt
			PIXEL_CLOCK	: out	STD_LOGIC;
			--! Zeilenvektor
			PIXEL_ROW,
			--! Spaltenvektor
			PIXEL_COLUMN: out STD_LOGIC_VECTOR(9 downto 0));
end VGA;


architecture ARCH of VGA is
	signal HORIZ_SYNC, VERT_SYNC, PIXEL_CLOCK_INT : STD_LOGIC;
	signal VIDEO_ON_INT, VIDEO_ON_V, VIDEO_ON_H : STD_LOGIC;
	signal H_COUNT, V_COUNT :STD_LOGIC_VECTOR(9 downto 0);

-- Horizontale Timings  
	constant 	H_PIXELS_ACROSS		: Natural := 640;
	constant 	H_SYNC_LOW			: Natural := 664;
	constant 	H_SYNC_HIGH			: Natural := 760;
	constant 	H_END_COUNT			: Natural := 800;
-- Vertikale TImings
	constant 	V_PIXELS_DOWN		: Natural := 480;
	constant 	V_SYNC_LOW			: Natural := 491;
	constant 	V_SYNC_HIGH			: Natural := 493;
	constant 	V_END_COUNT			: Natural := 525;
	component 	VIDEO_PLL
		port(
				INCLK0				: in STD_LOGIC  := '0';
				C0					: out STD_LOGIC 
			);
	end component;

begin

-- PLL erzeugt die Pixeltaktfrequenz.
VIDEO_PLL_INST:
VIDEO_PLL port map 	(
					INCLK0	=> CLOCK_50Mhz,
					C0	 	=> PIXEL_CLOCK_INT
					);

--!	VIDEO_ON ist nur HIGH, wenn Bilddaten angezeigt werden, sondt LOW um leere Farbsignale whrend
--	des Rcklaufs zu vermeiden.
VIDEO_ON_INT <= VIDEO_ON_H and VIDEO_ON_V;
-- Ausgabe fr externe Logik
PIXEL_CLOCK <= PIXEL_CLOCK_INT;
VIDEO_ON <= VIDEO_ON_INT;

process
begin
	wait until(PIXEL_CLOCK_INT'EVENT) and (PIXEL_CLOCK_INT='1');

--	Generieren der horizontalen und vertikalen Timings H_count zhlt: 
--	(Pixel + zustzliche Zeit fr Sync-Signale)
-- 
--  HORIZ_SYNC  ------------------------------------__________--------
--  H_count     0                 #pixels            sync low      end
--
	if (H_COUNT = H_END_COUNT) then
   		H_COUNT <= "0000000000";
	else
   		H_COUNT <= H_COUNT + 1;
	end if;

--Generiere Horizontal Sync mittels H_count.
	if (H_COUNT <= H_SYNC_HIGH) and (H_COUNT >= H_SYNC_LOW) then
 	  	HORIZ_SYNC <= '0';
	else
 	  	HORIZ_SYNC <= '1';
	end if;
--!	V_COUNT zhlt reihen, abwrts:
--	(#Zeilen  + extra Zeit fr V sync Signal)
--  
--  VERT_SYNC      -----------------------------------------------_______------------
--  V_count         0                        last pixel row      V sync low       end
--
	if (V_COUNT >= V_END_COUNT) and (H_COUNT >= H_SYNC_LOW) then
   		V_COUNT <= "0000000000";
	elsif (H_COUNT = H_SYNC_LOW) then
   		V_COUNT <= V_COUNT + 1;
	end if;

--Generiere Horizontal Sync mittels V_count.
	if (V_COUNT <= V_SYNC_HIGH) and (V_COUNT >= V_SYNC_LOW) then
   		VERT_SYNC <= '0';
	else
  		vert_sync <= '1';
	end if;

-- Generieren des VIDEO_ON Signals, whrend Inhalt angezeigt wird.
--! VIDEO_ON = 1 Pixel werden angezeigt
--! VIDEO_ON = 0 Rcklauf - jetzt knnen Pixelwerte geupdatet werden
	if (H_COUNT < H_PIXELS_ACROSS) then
   		VIDEO_ON_H <= '1';
   		PIXEL_COLUMN <= H_COUNT;
	else
	   	VIDEO_ON_H <= '0';
	end if;

	if (V_COUNT <= V_PIXELS_DOWN) then
   		VIDEO_ON_V <= '1';
   		PIXEL_ROW <= V_COUNT;
	else
   		VIDEO_ON_V <= '0';
	end if;

-- Alle Signale ber D-Flip Flop's zur verfgung stellen, um ein verschwommenes Bild zu vermeiden.
		H_SYNC_OUT <= HORIZ_SYNC;
		V_SYNC_OUT <= VERT_SYNC;
-- RGB Signale beim Rcklauf deaktivieren.
		RED_OUT <= RED and VIDEO_ON_INT;
		GREEN_OUT <= GREEN and VIDEO_ON_INT;
		BLUE_OUT <= BLUE and VIDEO_ON_INT;

end process;
end ARCH;
-- -----------------------------------------------------------------
--     Gemeinsame Video-Modi - Pixeltakt und Sync-Zhlerwerte     --
-- -----------------------------------------------------------------
--
--  Modus		Refresh   H-Sync	  Pixel clock  Interlaced?  VESA?
--  ----------------------------------------------------------------
--  640x480     60Hz      31.5khz     25.175Mhz       No         No
--  640x480     63Hz      32.8khz     28.322Mhz       No         No
--  640x480     70Hz      36.5khz     31.5Mhz         No         No
--  640x480     72Hz      37.9khz     31.5Mhz         No        Yes
--  800x600     56Hz      35.1khz     36.0Mhz         No        Yes
--  800x600     56Hz      35.4khz     36.0Mhz         No         No
--  800x600     60Hz      37.9khz     40.0Mhz         No        Yes
--  800x600     60Hz      37.9khz     40.0Mhz         No         No
--  800x600     72Hz      48.0khz     50.0Mhz         No        Yes
--  1024x768    60Hz      48.4khz     65.0Mhz         No        Yes
--  1024x768    60Hz      48.4khz     62.0Mhz         No         No
--  1024x768    70Hz      56.5khz     75.0Mhz         No        Yes
--  1024x768    70Hz      56.25khz    72.0Mhz         No         No
--  1024x768    76Hz      62.5khz     85.0Mhz         No         No
--  1280x1024   59Hz      63.6khz    110.0Mhz         No         No
--  1280x1024   61Hz      64.24khz   110.0Mhz         No         No
--  1280x1024   74Hz      78.85khz   135.0Mhz         No         No
--  ----------------------------------------------------------------
--
-- Kleine Anpassungen der Sync Signale knnen dazu dienen, das Bild
-- links/rechts (H) oder hoch/runter (V) zu bewegen.
--
--
--
-- 	----------------------------------------------------------------
--!	Auszug aus Hamblen, Rapid Prototyping of Digital Systems.
-- 	----------------------------------------------------------------
--
--
-- 640x480@60Hz Non-Interlaced mode
-- Horizontal Sync = 31.5kHz
-- Timing: H=(0.95us, 3.81us, 1.59us), V=(0.35ms, 0.064ms, 1.02ms)
--
--	          clock     horizontal timing         vertical timing      flags
--             Mhz    pix.col low  high end    pix.rows low  high end
--640x480    25.175     640  664   760  800        480  491   493  525
--                              <->                        <->    
--  sync pulses: Horiz----------___------   Vert-----------___-------
--
-- Alternate 640x480@60Hz Non-Interlaced mode
-- Horizontal Sync = 31.5kHz
-- Timing: H=(1.27us, 3.81us, 1.27us) V=(0.32ms, 0.06ms, 1.05ms)
--
-- name        clock   horizontal timing     vertical timing      flags
--640x480      25.175  640  672  768  800    480  490  492  525
--
--
-- 640x480@63Hz Non-Interlaced mode (non-standard)
-- Horizontal Sync = 32.8kHz
-- Timing: H=(1.41us, 1.41us, 5.08us) V=(0.24ms, 0.092ms, 0.92ms)
--
-- name        clock   horizontal timing     vertical timing      flags
--640x480      28.322  640  680  720  864    480  488  491  521
--
--
-- 640x480@70Hz Non-Interlaced mode (non-standard)
-- Horizontal Sync = 36.5kHz
-- Timing: H=(1.27us, 1.27us, 4.57us) V=(0.22ms, 0.082ms, 0.82ms)
--
-- name        clock   horizontal timing     vertical timing      flags
--640x480      31.5    640  680  720  864    480  488  491  521
--
--
-- VESA 640x480@72Hz Non-Interlaced mode
-- Horizontal Sync = 37.9kHz
-- Timing: H=(0.76us, 1.27us, 4.06us) V=(0.24ms, 0.079ms, 0.74ms)
--
-- name        clock   horizontal timing     vertical timing      flags
--640x480      31.5    640  664  704  832    480  489  492  520
--
--
-- VESA 800x600@56Hz Non-Interlaced mode
-- Horizontal Sync = 35.1kHz
-- Timing: H=(0.67us, 2.00us, 3.56us) V=(0.03ms, 0.063ms, 0.70ms)
--
-- name        clock   horizontal timing     vertical timing      flags
--800x600      36      800  824  896 1024    600  601  603  625
--
--
-- Alternate 800x600@56Hz Non-Interlaced mode
-- Horizontal Sync = 35.4kHz
-- Timing: H=(0.89us, 4.00us, 1.11us) V=(0.11ms, 0.057ms, 0.79ms)
--
-- name        clock   horizontal timing     vertical timing      flags
--800x600      36      800  832  976 1016    600  604  606  634
--
--
-- VESA 800x600@60Hz Non-Interlaced mode
-- Horizontal Sync = 37.9kHz
-- Timing: H=(1.00us, 3.20us, 2.20us) V=(0.03ms, 0.106ms, 0.61ms)
--
-- name        clock   horizontal timing     vertical timing      flags
--800x600      40      800  840  968 1056    600  601  605  628 +hsync +vsync
--
--
-- Alternate 800x600@60Hz Non-Interlaced mode
-- Horizontal Sync = 37.9kHz
-- Timing: H=(1.20us, 3.80us, 1.40us) V=(0.13ms, 0.053ms, 0.69ms)
--
-- name        clock   horizontal timing     vertical timing      flags
--800x600      40      800 848 1000 1056     600  605  607  633
--
--
-- VESA 800x600@72Hz Non-Interlaced mode
-- Horizontal Sync = 48kHz
-- Timing: H=(1.12us, 2.40us, 1.28us) V=(0.77ms, 0.13ms, 0.48ms)
--
-- name        clock   horizontal timing     vertical timing      flags
--800x600      50      800  856  976 1040    600  637  643  666  +hsync +vsync
--
--
-- VESA 1024x768@60Hz Non-Interlaced mode
-- Horizontal Sync = 48.4kHz
-- Timing: H=(0.12us, 2.22us, 2.58us) V=(0.06ms, 0.12ms, 0.60ms)
--
-- name        clock   horizontal timing     vertical timing      flags
--1024x768     65     1024 1032 1176 1344    768  771  777  806 -hsync -vsync
--
--
-- 1024x768@60Hz Non-Interlaced mode (non-standard dot-clock)
-- Horizontal Sync = 48.4kHz
-- Timing: H=(0.65us, 2.84us, 0.65us) V=(0.12ms, 0.041ms, 0.66ms)
--
-- name        clock   horizontal timing     vertical timing      flags
--1024x768     62     1024 1064 1240 1280   768  774  776  808
--
--
-- VESA 1024x768@70Hz Non-Interlaced mode
-- Horizontal Sync=56.5kHz
-- Timing: H=(0.32us, 1.81us, 1.92us) V=(0.05ms, 0.14ms, 0.51ms)
--
-- name        clock   horizontal timing     vertical timing      flags
--1024x768     75     1024 1048 1184 1328    768  771  777  806 -hsync -vsync
--
--
-- 1024x768@70Hz Non-Interlaced mode (non-standard dot-clock)
-- Horizontal Sync=56.25kHz
-- Timing: H=(0.44us, 1.89us, 1.22us) V=(0.036ms, 0.11ms, 0.53ms)
--
-- name        clock   horizontal timing     vertical timing      flags
--1024x768     72     1024 1056 1192 1280    768  770  776  806   -hsync -vsync
--
--
-- 1024x768@76Hz Non-Interlaced mode
-- Horizontal Sync=62.5kHz
-- Timing: H=(0.09us, 1.41us, 2.45us) V=(0.09ms, 0.048ms, 0.62ms)
--
-- name        clock   horizontal timing     vertical timing      flags
--1024x768     85     1024 1032 1152 1360    768  784  787  823
--
--
-- 1280x1024@59Hz Non-Interlaced mode (non-standard)
-- Horizontal Sync=63.6kHz
-- Timing: H=(0.36us, 1.45us, 2.25us) V=(0.08ms, 0.11ms, 0.65ms)
--
-- name        clock   horizontal timing     vertical timing      flags
--1280x1024   110     1280 1320 1480 1728   1024 1029 1036 1077
--
--
-- 1280x1024@61Hz, Non-Interlaced mode
-- Horizontal Sync=64.25kHz
-- Timing: H=(0.44us, 1.67us, 1.82us) V=(0.02ms, 0.05ms, 0.41ms)
--
-- name        clock   horizontal timing     vertical timing      flags
--1280x1024   110     1280 1328 1512 1712   1024 1025 1028 1054
--
--
-- 1280x1024@74Hz, Non-Interlaced mode
-- Horizontal Sync=78.85kHz
-- Timing: H=(0.24us, 1.07us, 1.90us) V=(0.04ms, 0.04ms, 0.43ms)
--
-- name        clock   horizontal timing     vertical timing      flags
--1280x1024   135     1280 1312 1456 1712   1024 1027 1030 1064
--
--	VGA female connector: 15 pin small "D" connector
--                   _________________________
--                   \   5   4   3   2   1   /
--                    \   10  X   8   7   6 /
--                     \ 15  14  13 12  11 /
--                      \_________________/
--   Signal Name    Pin Number   Notes
--   -----------------------------------------------------------------------
--   RED video          1        Analog signal, around 0.7 volt, peak-to-peak  75 ohm 
--   GREEN video        2        Analog signal, sround 0.7 volt, peak-to-peak  75 ohm 
--   BLUE video         3        Analog signal, around 0.7 volt, peak-to-peak  75 ohm
--   Monitor ID #2      4        
--   Digital Ground     5        Ground for the video system.
--   RED ground         6  \     The RGB color video signals each have a separate
--   GREEN ground       7  |     ground connection.  
--   BLUE ground        8  /      
--   KEY                9        (X = Not present)
--   SYNC ground       10        TTL return for the SYNC lines.
--   Monitor ID #0     11        
--   Monitor ID #1     12        
--   Horizontal Sync   13        Digital levels (0 to 5 volts, TTL output)
--   Vertical Sync     14        Digital levels (0 to 5 volts, TTL output)
--   Not Connected     15        (Not used)
--
