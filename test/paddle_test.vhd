library IEEE;
use IEEE.STD_LOGIC_1164.all;

------------------------------------------------------------------------------------------------------
--! @file	paddle_test.vhd
--! @brief 	Testbench zur Paddle Entity, welche die Drehknöpfe in einen Richtungscodierten Impuls umwandelt.
------------------------------------------------------------------------------------------------------

entity PADDLE_TEST is end entity PADDLE_TEST;

architecture TESTBENCH of PADDLE_TEST is 
----------------------------------------
--			Signaldefinitionen
----------------------------------------
			--!	Takteingang
signal		GEN_CLK_50Mhz		:	bit;
			--! Resetleitung
signal		GEN_RESET			:	bit;
			--!	Eingangsvektor
signal		GEN_DIN				:	bit_vector(1 downto 0);
			--! Richtungsvorgabe
signal		GEN_LEFTNOTRIGHT	:	std_logic;
			--! Generierter Schritttakt
signal		GEN_STEP			:	std_logic;
----------------------------------------
--			Komponentendeklaration
----------------------------------------
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
end component PADDLE ; 

for all: PADDLE use entity work.PADDLE(VERHALTEN);

begin
----------------------------------------
--			Erzeugt den Systemtakt
----------------------------------------
SYSTEMTAKT : process is
begin
	GEN_CLK_50Mhz <= '0';
	wait for 20 ns;  
	GEN_CLK_50Mhz <= '1';
	wait for 20 ns;	
end process SYSTEMTAKT;
----------------------------------------
--			Reset Zmstand testen
----------------------------------------
RESETSTATE : process is
begin
	GEN_RESET <= '1';
	wait for 60 ns;
	GEN_RESET <= '0';
	wait;	
end process RESETSTATE;
----------------------------------------
--		Erzeugung der DIN Signale
--		füt Vor- und Rücklauf
----------------------------------------
ENCODE : process is
begin
	GEN_DIN(0) <= '0', '1' after 10 ms, '0' after 20 ms, '1' after 30 ms, '0' after 40 ms, '1' after 50 ms, '0' after 60 ms, '1' after 75 ms, '0' after 85 ms, '1' after 95 ms, '0' after 105 ms, '1' after 115 ms, '0' after 125 ms;
	GEN_DIN(1) <= '0', '1' after 15 ms, '0' after 25 ms, '1' after 35 ms, '0' after 45 ms, '1' after 55 ms, '0' after 65 ms, '1' after 70 ms, '0' after 80 ms, '1' after 90 ms, '0' after 100 ms, '1' after 110 ms, '0' after 120 ms;
	wait;
end process ENCODE;

DUT: PADDLE port map(GEN_CLK_50Mhz, GEN_RESET, GEN_DIN, GEN_LEFTNOTRIGHT, GEN_STEP);

end architecture TESTBENCH;




