library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity BALL_OBJECT is
    generic(
        BALL_TOP_LIMIT: integer range 0 to 149:=0;
        BALL_BOTTOM_LIMIT: integer range 0 to 149:=149;
        BALL_LEFT_LIMIT: integer range 0 to 199:=0;
        BALL_RIGHT_LIMIT:integer range 0 to 199:=199;
        BALL_X_START: integer range 0 to 199:=0;
        BALL_Y_START:integer range 0 to 149:=0;
        BALL_X_START_COUNT: natural:=0;
        BALL_Y_START_COUNT:natural :=0
    );
    port(
        --!
        CLK: in bit;
        RESET: in bit;
        DRAW: out std_logic;
        V_ADR: in bit_vector(7 downto 0);
        H_ADR: in bit_vector(7 downto 0);
        X_CURRENT:out integer range 0 to 199;
        Y_CURRENT:out integer range 0 to 149
    );
end entity BALL_OBJECT;

architecture BALL_OBJECT_ARC of BALL_OBJECT is
signal OFFSET_X: integer range -1 to 1;
signal OFFSET_Y: integer range -1 to 1;
signal COUNT_X: integer;
signal COUNT_Y: integer;
signal BALL_X: integer range 0 to 199;
signal BALL_Y: integer range 0 to 149;
begin

MAIN:process(clk,reset)
  begin
  if(reset='1') then
    COUNT_X<=BALL_X_START_COUNT;
    COUNT_Y<=BALL_Y_START_COUNT;
    OFFSET_X<=1;
    OFFSET_Y<=1;
    BALL_X<=BALL_X_START;
    BALL_Y<=BALL_Y_START;
  elsif(CLK'EVENT and CLK='1') then
    --Ball bewegen
    if(COUNT_X=0) then
      COUNT_X<=BALL_X_START_COUNT;
      if(BALL_X<=BALL_LEFT_LIMIT) then
        BALL_X<=BALL_X+1;
        OFFSET_X<=-OFFSET_X;
      elsif(BALL_X>=BALL_RIGHT_LIMIT) then
        BALL_X<=BALL_X-1;
        OFFSET_X<=-OFFSET_X;
      else
        BALL_X<=BALL_X+OFFSET_X;
      end if;
    else
      COUNT_X<=COUNT_X-1;
    end if;
    if(COUNT_Y=0) then
      COUNT_Y<=BALL_Y_START_COUNT;
      if(BALL_Y<=BALL_TOP_LIMIT) then
        BALL_Y<=BALL_Y+1;
        OFFSET_Y<=-OFFSET_Y;
      elsif(BALL_Y>=BALL_BOTTOM_LIMIT) then
        BALL_Y<=BALL_Y-1;
        OFFSET_Y<=-OFFSET_Y;
      else
        BALL_Y<=BALL_Y+OFFSET_Y;
      end if;
    else
      COUNT_Y<=COUNT_Y-1;
    end if;
  end if;
  end process MAIN;
  
  X_CURRENT<=BALL_X;
  Y_CURRENT<=BALL_Y;
  
  AUSGABE:process(H_ADR,V_ADR)
  begin
    if(to_integer(unsigned(to_stdlogicvector(H_ADR)))=BALL_X and to_integer(unsigned(to_stdlogicvector(V_ADR)))=BALL_Y) then
      DRAW<='1';
    else
      DRAW<='0';
    end if;
  end process AUSGABE;
     
                
end architecture BALL_OBJECT_ARC; 
