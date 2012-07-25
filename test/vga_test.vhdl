library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

------------------------------------------------------------------------------------------------------
--! @file	vga_test.vhd
--! @brief 	Diese Entity repräsentiert die Testbench für das Video->Monitor Interface,
-- 			sowie die RGB und Sync Signale.
------------------------------------------------------------------------------------------------------
entity VGA_TEST is end entity VGA_TEST;


architecture ARCH of entity is 

signal	CLK, SIG_RED, SIG_GREEN, SIG_BLUE			:		bit;
signal	SIG_RED_OUT, SIG_GREEN_OUT, SIG_BLUE_OUT, 
		SIG_H_SYNC_OUT, SIG_V_SYNC_OUT, 
		SIG_VIDEO_ON, SIG_PIXEL_CLOCK				: 		std_logic;
signal	SIG_PIXEL_ROW, SIG_PIXEL_COLUMN				: 		std_logic_vector(9 downto 0));

component VGA is   
	  port(	CLOCK_50Mhz, RED, GREEN, BLUE			: 	in	std_logic;
			RED_OUT, GREEN_OUT, BLUE_OUT, H_SYNC_OUT, 
			V_SYNC_OUT, VIDEO_ON, PIXEL_CLOCK		: 	out	std_logic;
			PIXEL_ROW, PIXEL_COLUMN					: 	out std_logic_vector(9 downto 0)
	  ); 
end component VGA ; 

for all: VGA use entity work.VGA(ARCH); 

	begin
	GENERATE_CLK:
	process
	begin
	    CLK <= '0';
	    wait for 10 ns;
	    CLK <= '1';
	    wait for 10 ns;                
	end process;
 

end architecture ARCH;
