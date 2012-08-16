library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity PADDLE_OBJECT is
    generic(
        PADDLE_TOP_SIG_LIMIT: integer range 0 to 149:=30;
        PADDLE_BOTTOM_SIG_LIMIT: integer range 0 to 149:=120;
        PADDLE_TOP_SIG_START: integer range 0 to 149:=65;
        PADDLE_BOTTOM_SIG_START:integer range 0 to 149:=85;
        PADDLE_POS_X:integer range 0 to 199:=20;
        PADDLE_WIDTH:integer range 0 to 199:=5
    );
    port(
        --!
        L_NOTR: in bit;
        STEP: in bit;
        CLK: in bit;
        RESET: in bit;
        DRAW: out std_logic;
        V_ADR: in bit_vector(7 downto 0);
        H_ADR: in bit_vector(7 downto 0);
        PADDLE_TOP: out integer range 0 to 149;
        PADDLE_BOTTOM: out integer range 0 to 149
    );
end entity PADDLE_OBJECT;

architecture PADDLE_OBJECT_ARC of PADDLE_OBJECT is
signal PADDLE_TOP_SIG: integer range 0 to 149;
signal PADDLE_BOTTOM_SIG: integer range 0 to 149;
begin
PLAYER_PADDLE1:process(STEP,RESET)
  begin
  if(RESET='1') then
    PADDLE_BOTTOM_SIG<=PADDLE_BOTTOM_SIG_START;
    PADDLE_TOP_SIG<=PADDLE_TOP_SIG_START;
  elsif (STEP'EVENT and STEP='1') then
  --PADDLE_BOTTOM_SIG<=60;
    if(L_NOTR='1' and PADDLE_BOTTOM_SIG<PADDLE_BOTTOM_SIG_LIMIT) then
      PADDLE_TOP_SIG<=PADDLE_TOP_SIG+1;
      PADDLE_BOTTOM_SIG<=PADDLE_BOTTOM_SIG+1;
    elsif(L_NOTR='0' and PADDLE_TOP_SIG>PADDLE_TOP_SIG_LIMIT) then
      PADDLE_TOP_SIG<=PADDLE_TOP_SIG-1;
      PADDLE_BOTTOM_SIG<=PADDLE_BOTTOM_SIG-1;
    end if;
  end if;
  end process PLAYER_PADDLE1;
               
MAIN:process(CLK)
  begin
  if(CLK'EVENT and CLK='1') then
    DRAW<='0';
    if(not(to_integer(unsigned(to_stdlogicvector(H_ADR)))<PADDLE_POS_X or to_integer(unsigned(to_stdlogicvector(H_ADR)))>(PADDLE_POS_X+PADDLE_WIDTH))) then
      if(not(to_integer(unsigned(to_stdlogicvector(V_ADR)))<PADDLE_TOP_SIG or to_integer(unsigned(to_stdlogicvector(V_ADR)))>PADDLE_BOTTOM_SIG)) then
        draw<='1';
      end if;
    end if;
  end if;
  end process MAIN;
     
PADDLE_TOP<=PADDLE_TOP_SIG;
PADDLE_BOTTOM<=PADDLE_BOTTOM_SIG;

               
     
                
end architecture PADDLE_OBJECT_ARC; 
