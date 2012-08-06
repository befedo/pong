library IEEE;
use  IEEE.STD_LOGIC_1164.all;
--use  IEEE.STD_LOGIC_ARITH.all;
--use  IEEE.STD_LOGIC_UNSIGNED.all;

------------------------------------------------------------------------------------------------------
--! @file	paddle.vhd
--! @brief 	Entity, welche die Drehknöpfe in einen Richtungscodierten Impuls umwandelt,
--			welcher von Folgenden Schieberegistern verarbeitet wird.
------------------------------------------------------------------------------------------------------
entity PADDLE is
	generic (
			TAKTTEILER		:	natural	:=	1024;
	) ;  
	
	port(	--!	Takteingang
			CLK_50Mhz		:	in	bit;
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
--TODO: Zustandsautomat beenden
attribute	ENUM_ENCODING of ZUSTAENDE: type is "0000 0001 0010 0011";
signal 		ZUSTAND, FOLGEZUSTAND : ZUSTAENDE;

begin
  
end architecture VERHALTEN;
