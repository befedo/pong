library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

------------------------------------------------------------------------------------------------------
--! @file	frequenzteiler.vhd
--! @brief 	Testbench zur Frequenzteiler Entity.
------------------------------------------------------------------------------------------------------

entity FREQUENZTEILER_TB is end FREQUENZTEILER_TB;

architecture TESTBENCH of FREQUENZTEILER_TB is
constant BITS : natural :=  100;

signal CLK, RESET : bit;
signal CLKOUT : bit;

component FREQUENZTEILER is
    generic(
        CLKVALUE      : natural := 1024
    );
    port(
        CLK, RESET    :   in bit;
        CLKOUT        :   inout bit
    );
end component FREQUENZTEILER;

begin

RST:process is
begin
    RESET <= '1';
    wait for 40 ns;
    RESET <= '0';
    wait;
end process;


TIMING:process is
begin
    CLK <= '0';
    wait for 20 ns;
    CLK <= '1';
    wait for 20 ns;
end process TIMING;

MAPPED: FREQUENZTEILER
    generic map (CLKVALUE => BITS)
    port map (CLK, RESET, CLKOUT);

end TESTBENCH;

