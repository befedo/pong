library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

------------------------------------------------------------------------------------------------------
--! @file	frequenzteiler.vhd
--! @brief 	Diese Entity erzeugt ein Signak, welches aus dem geteilten Takt abgeleitet wird und durch
--			einen GENERIC Parameter bestimmt werden kann.
------------------------------------------------------------------------------------------------------

entity FREQUENZTEILER is
    generic(	--! Parameter, durch welchen geteilt wird
        		CLKVALUE : positive := 1024
    );
	port(		--! Takteingang
				CLK,
				--! Reset Leitung 
				RESET    :   in bit;
				--! Taktausgang
				CLKOUT        :   out std_logic
	);
end FREQUENZTEILER;

architecture VERHALTEN of FREQUENZTEILER is

begin
--! Zähler Prozess zum generiren 
COUNT:process(CLK, RESET)
variable VALUE    :   integer range 0 to CLKVALUE-1;
    begin
        if RESET = '1' then
            VALUE := 0;
            CLKOUT <= '0';
        elsif (CLK = '1' and CLK'event) then
            if VALUE < CLKVALUE-1 then
                VALUE := VALUE+1;
            else
                VALUE := 0;
            end if;
            
            if VALUE = 0 then 
                CLKOUT <= '1';    
            end if;
            
            if VALUE = CLKVALUE/2 then
                CLKOUT <= '0';
            end if;         
        end if;                
    end process COUNT;
end VERHALTEN;