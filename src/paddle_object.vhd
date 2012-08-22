library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity PADDLE_OBJECT is
    generic(
        PADDLE_TOP_LIMIT: integer range 0 to 1199:=199;
        PADDLE_BOTTOM_LIMIT: integer range 0 to 1199:=1100;
        PADDLE_TOP_START: integer range 0 to 1199:=500;
        PADDLE_BOTTOM_START:integer range 0 to 1199:=580;
        PADDLE_POS_X:integer range 0 to 1599:=90;
        PADDLE_WIDTH:integer range 0 to 1599:=10;
        PADDLE_STEP_WIDTH: integer range 1 to 200:=10 
    );
    port(
        --!
        CLK: in std_logic;
        UP: in std_logic;
        DOWN: in std_logic;
        RESET: in std_logic;
        DRAW: out std_logic;
        V_ADR: in std_logic_vector(11 downto 0);
        H_ADR: in std_logic_vector(11 downto 0);
        PADDLE_TOP: out integer range 0 to 1199;
        PADDLE_BOTTOM: out integer range 0 to 1199
    );
end entity PADDLE_OBJECT;

architecture PADDLE_OBJECT_ARC of PADDLE_OBJECT is
signal PADDLE_TOP_SIG: integer range 0 to 1199;
signal PADDLE_BOTTOM_SIG: integer range 0 to 1199;
begin
PLAYER_PADDLE:process(CLK,RESET)
  begin           
  if(RESET='1') then
    PADDLE_BOTTOM_SIG<=PADDLE_BOTTOM_START;
    PADDLE_TOP_SIG<=PADDLE_TOP_START;
  elsif (CLK'EVENT and CLK='1') then
    if(UP='1' and PADDLE_TOP_SIG<PADDLE_TOP_LIMIT) then
      PADDLE_TOP_SIG<=PADDLE_TOP_SIG+PADDLE_STEP_WIDTH;
      PADDLE_BOTTOM_SIG<=PADDLE_BOTTOM_SIG+PADDLE_STEP_WIDTH;
    elsif(DOWN='1' and PADDLE_BOTTOM_SIG>PADDLE_BOTTOM_LIMIT) then
      PADDLE_TOP_SIG<=PADDLE_TOP_SIG-PADDLE_STEP_WIDTH;
      PADDLE_BOTTOM_SIG<=PADDLE_BOTTOM_SIG-PADDLE_STEP_WIDTH;
    end if;
  end if;
  end process PLAYER_PADDLE;
               
AUSGABE:process(H_ADR,V_ADR)
     begin
        DRAW<='0';
        if(not(to_integer(unsigned(H_ADR))<PADDLE_POS_X or to_integer(unsigned(H_ADR))>(PADDLE_POS_X+PADDLE_WIDTH))) then
            if(not(to_integer(unsigned(V_ADR))<PADDLE_TOP_SIG or to_integer(unsigned(V_ADR))>PADDLE_BOTTOM_SIG)) then
				draw<='1';
			end if;
		end if;
     end process;
               
PADDLE_TOP<=PADDLE_TOP_SIG;
PADDLE_BOTTOM<=PADDLE_BOTTOM_SIG;
                
end architecture PADDLE_OBJECT_ARC; 
