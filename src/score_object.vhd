library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity SCORE_OBJECT is
  generic(
    MAX_POINT: integer range 0 to 14:=5;
    START_X: integer range 0 to 1599:=10;
    START_Y: integer range 0 to 1199:=10;
    BARE_WIDTH: natural:=10;
    BARE_HEIGTH: natural:=30;
    DISTANCE: natural :=20
  );
  port(
    CLK: in std_logic;
    RESET: in std_logic;
    INCREASE: in std_logic;
    CURRENT_SCORE: out integer range 0 to MAX_POINT;
    DRAW: out std_logic;
    V_ADR: in std_logic_vector(11 downto 0);
    H_ADR: in std_logic_vector(11 downto 0)
  );
end entity SCORE_OBJECT;

architecture SCORE_OBJECT_ARC of SCORE_OBJECT is
signal CURRENT_SCORE_SIG: integer range 0 to MAX_POINT;
begin

  SCORE:process(CLK, RESET)
  begin
    if(RESET='1') then
      CURRENT_SCORE_SIG<=0;
    elsif(CLK'event and CLK='1') then
      if(INCREASE='1') then
        if(not(CURRENT_SCORE_SIG=MAX_POINT)) then
          CURRENT_SCORE_SIG<=CURRENT_SCORE_SIG+1;
        end if;
      end if;
    end if;
  end process SCORE;
  
  CURRENT_SCORE<=CURRENT_SCORE_SIG;
  
  OUTPUT:process(V_ADR,H_ADR)
  begin
    DRAW<='0';
    BARE:for I in 0 to MAX_POINT-1 loop
      if(I<CURRENT_SCORE_SIG) then
        if(H_ADR>START_X+(DISTANCE+BARE_WIDTH)*I and H_ADR<START_X+BARE_WIDTH+(DISTANCE+BARE_WIDTH)*I and V_ADR>START_Y and V_ADR<START_Y+BARE_HEIGTH) then
          DRAW<='1';
        end if;
      end if;
    end loop;
  
  end process OUTPUT;

                
end architecture SCORE_OBJECT_ARC; 
 
