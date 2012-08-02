library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-------------------------------------------------------
--! @file
--! @brief 
-------------------------------------------------------
entity MUX is
    generic(
        --!Gibt die Breite der Signale an
        WIDTH:natural:=16
    );
    port(
        --!Eingangsignal auswahl. Wenn SL 1 ist wird das zweite Signal auf denn Ausgang geschalten
        SL: in bit;
        --!Eingangsignal 1
        IN_SIGNAL_1: in bit_vector(WIDTH-1 downto 0);
        --!Eingangsignal 2
        IN_SIGNAL_2: in bit_vector(WIDTH-1 downto 0);
        --!Ausgangssignal
        OUT_SIGNAL: out std_logic_vector(WIDTH-1 downto 0)
    );
end entity MUX;


architecture MUX_ARC of MUX is
begin
    with SL select
        OUT_SIGNAL <= to_stdlogicvector(IN_SIGNAL_1) when '0',
                      to_stdlogicvector(IN_SIGNAL_2) when '1';


end architecture MUX_ARC;
