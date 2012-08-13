library IEEE;
use IEEE.STD_LOGIC_1164.all;

------------------------------------------------------------------------------------------------------
--! @file	video_controller_test.vhd
--! @brief 	Testbench zur Hauptentity
------------------------------------------------------------------------------------------------------

entity VIDEO_CONTROLLER_TEST is end entity VIDEO_CONTROLLER_TEST;

architecture TESTBENCH of VIDEO_CONTROLLER_TEST is 
----------------------------------------
--			Signaldefinitionen
----------------------------------------
		-- Systemtakt
signal	SIG_CLK		:	bit;
signal	SIG_RESET	:	bit;

component VIDEO_CONTROLLER is   
    port(
        CLK, RESET										: in 	bit;
        H_SYNC, V_SYNC, VGA_CLOCK, VGA_BLANK, VGA_SYNC	: out 	std_logic;
        RED, GREEN, BLUE								: out 	std_logic_vector(9 downto 0)
    );	   
end component VIDEO_CONTROLLER ; 

for all: VIDEO_CONTROLLER use entity work.VIDEO_CONTROLLER(VIDEO_CONTROLLER_ARC);

begin
----------------------------------------
--			Erzeugt den Systemtakt
----------------------------------------
SYSTEMTAKT : process is
begin
	SIG_CLK <= '0';
	wait for 20 ns;  
	SIG_CLK <= '1';
	wait for 20 ns;	
end process SYSTEMTAKT;
----------------------------------------
--			Reset Zustand testen
----------------------------------------
RESETSTATE : process (SIG_RESET) is
begin
	SIG_RESET <= '1';
	wait for 60 ns;
	SIG_RESET <= '0';
	wait;	
end process RESETSTATE;

DUT : VIDEO_CONTROLLER port map( CLK => SIG_CLK, RESET => SIG_RESET, H_SYNC => OPEN, V_SYNC => OPEN, VGA_CLOCK => OPEN, VGA_BLANK => OPEN, VGA_SYNC => OPEN, RED => OPEN, GREEN => OPEN, BLUE => OPEN );
  
end architecture TESTBENCH;

