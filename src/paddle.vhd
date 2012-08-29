library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------------------------------------
--! @file	paddle.vhd
--! @brief 	Entity, welche die Drehknöpfe in einen Richtungscodierten Impuls umwandelt,
--			welcher von Folgenden Schieberegistern verarbeitet wird.
------------------------------------------------------------------------------------------------------

entity PADDLE is
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
end entity PADDLE;


architecture VERHALTEN of PADDLE is

type 		ZUSTAENDE is (Z00, Z01, Z02, Z10, Z11, Z12, Z20, Z21, Z22, Z30, Z31, Z32);
attribute 	ENUM_ENCODING :	STRING;
attribute	ENUM_ENCODING of ZUSTAENDE: type is "0000 0001 0011 0010 0110 0111 0101 0100 1100 1101 1111 1110";
signal 		ZUSTAND, FOLGEZUSTAND : ZUSTAENDE;
signal		COUNTER : natural;

begin

ZUSTANDSSPEICHER:
process (CLK_50Mhz, RESET) is
begin
	if 		RESET = '1'							then 
			ZUSTAND <= Z00; 	
			COUNTER <= 0;
	elsif	CLK_50Mhz = '1'	and CLK_50Mhz'event	then
		if(COUNTER=4000) then
			ZUSTAND <= FOLGEZUSTAND;
			COUNTER <= 0;
		else
			COUNTER<=Counter+1;
		end if;
	end if;
end process ;

UEBERGANGSSCHALTNETZ: 
process (DIN, ZUSTAND) is
begin
----Defaultzuweisung----
	STEP <= '0';
	FOLGEZUSTAND <= Z00;
------------------------	
		case ZUSTAND is
			when Z00 =>		--------Zustandswechsel-----
							if 		DIN = "10" then	FOLGEZUSTAND <= Z01; 
							elsif 	DIN = "01" then	FOLGEZUSTAND <= Z32;	
							else	  		
								FOLGEZUSTAND<=Z00;		
							end if ;
									
			when Z01 =>				FOLGEZUSTAND <= Z10;	--------Zustandswechsel-----
									LEFTNOTRIGHT <= '0';	--------Ausgangsbelegung----
			when Z02 =>				FOLGEZUSTAND <= Z00;	--------Zustandswechsel-----
									LEFTNOTRIGHT <= '1';	--------Ausgangsbelegung----
			
			when Z10 =>		--------Zustandswechsel-----
							if 		DIN = "11" then	FOLGEZUSTAND <= Z11; 
							elsif 	DIN = "00" then FOLGEZUSTAND <= Z02;	
							else	  		
								FOLGEZUSTAND<=Z10;		
							end if ;
									STEP <= '1';			--------Ausgangsbelegung----
			when Z11 =>				FOLGEZUSTAND <= Z20;	--------Zustandswechsel-----
									LEFTNOTRIGHT <= '0';	--------Ausgangsbelegung----
			when Z12 =>				FOLGEZUSTAND <= Z10;	--------Zustandswechsel-----
									LEFTNOTRIGHT <= '1';	--------Ausgangsbelegung----
			
			when Z20 =>		--------Zustandswechsel-----
							if 		DIN = "01" then	FOLGEZUSTAND <= Z21; 
							elsif 	DIN = "10" then FOLGEZUSTAND <= Z12;	
							else	  	
								FOLGEZUSTAND<=Z20;		  				
							end if ;
			when Z21 =>				FOLGEZUSTAND <= Z30;	--------Zustandswechsel-----
									LEFTNOTRIGHT <= '0';	--------Ausgangsbelegung----
			when Z22 =>				FOLGEZUSTAND <= Z20;	--------Zustandswechsel-----
									LEFTNOTRIGHT <= '1';	--------Ausgangsbelegung----
			
			when Z30 =>		--------Zustandswechsel-----
							if 		DIN = "00" then	FOLGEZUSTAND <= Z31; 
							elsif 	DIN = "11" then FOLGEZUSTAND <= Z22;
							else		  	
								FOLGEZUSTAND<=Z30;			
							end if ;
									STEP <= '1';			--------Ausgangsbelegung----
			when Z31 =>				FOLGEZUSTAND <= Z00;	--------Zustandswechsel-----
									LEFTNOTRIGHT <= '0';	--------Ausgangsbelegung----
			when Z32 =>				FOLGEZUSTAND <= Z30;	--------Zustandswechsel-----
									LEFTNOTRIGHT <= '1';	--------Ausgangsbelegung----
		end case ; 
end process UEBERGANGSSCHALTNETZ;

  
end architecture VERHALTEN;
