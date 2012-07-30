library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity VGA_RAM is
    generic(
        --! Horizontale groesse des Rams.
       H_WIDTH:natural:=16;
        --! Vertikale groesse des Rams.
       V_WIDTH:natural:=16;
        --! Breite eines Speicherbereichs.
       WORD_WIDTH:natural:=3
    );
    port(
        --! Adresseingang für die Horizontale.
        H_ADDR: in bit_vector(H_WIDTH-1 downto 0);
        --! Adresseingang für die Vertikale.
        V_ADDR: in bit_vector(V_WIDTH-1 downto 0);
        --! Eingangsleitung zum Parallelen schreiben.
        DIN: in bit_vector(WORD_WIDTH-1 downto 0);
        --! Alle Operationen werden mit denn Takt synchronisiert.
        CLK: in bit;
        --! Wenn das signal High ist wird das aktuelle Signal am DIN gespeichert. EN muss auch HIGH sein damit ein Effekt auftritt.
        WE: in bit;
        --! Wenn das signal High ist wird der Speicherbaustein aktiv.
        EN: in bit;
        --! Datenausgangsleitung zum Parallelen lesen.
        DOUT: out std_logic_vector(WORD_WIDTH-1 downto 0)
    );
end entity VGA_RAM;

architecture VGA_RAM_ARC of VGA_RAM is
type MEM is array (0 to 2**H_WIDTH-1 , 0 to 2**V_WIDTH-1) of std_logic_vector(WORD_WIDTH-1 downto 0);
signal MEM_MAIN: MEM;
signal H_ADDR_INT : integer range 0 to 2**H_WIDTH-1;
signal V_ADDR_INT : integer range 0 to 2**V_WIDTH-1;
begin


    process(CLK)
    begin
        if(EN= '1' ) then
            if (CLK'Event and CLK = '1') then
                H_ADDR_INT<= to_integer(unsigned(to_stdlogicvector(H_ADDR)));
                V_ADDR_INT<= to_integer(unsigned(to_stdlogicvector(V_ADDR)));
                if(WE = '1' ) then
                    MEM_MAIN(H_ADDR_INT,V_ADDR_INT)<=to_stdlogicvector(DIN);
                end if;
            end if;
        end if;
    end process;
    
    DOUT<=MEM_MAIN(H_ADDR_INT,V_ADDR_INT);

end architecture VGA_RAM_ARC;