library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity BALL_OBJECT_TEST is
end entity BALL_OBJECT_TEST;

architecture BALL_OBJECT_ARC_TEST of BALL_OBJECT_TEST is
signal CLK: bit;
signal RESET:  bit;
signal DRAW: std_logic;
signal V_ADR: bit_vector(7 downto 0);
signal H_ADR:  bit_vector(7 downto 0);
signal X_CURRENT: integer range 0 to 199;
signal Y_CURRENT: integer range 0 to 149;

component BALL_OBJECT  
    generic(
        BALL_TOP_LIMIT: integer range 0 to 149:=10;
        BALL_BOTTOM_LIMIT: integer range 0 to 149:=20;
        BALL_LEFT_LIMIT: integer range 0 to 199:=10;
        BALL_RIGHT_LIMIT:integer range 0 to 199:=20;
        BALL_X_START: integer range 0 to 199:=11;
        BALL_Y_START:integer range 0 to 149:=11;
        BALL_X_START_COUNT: natural:=10000;
        BALL_Y_START_COUNT:natural :=50000
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
end component BALL_OBJECT;

for all: BALL_OBJECT use entity work.BALL_OBJECT(BALL_OBJECT_ARC);

begin
BALL_OBJECT_INST: BALL_OBJECT 
    port map(CLK,RESET,DRAW,V_ADR,H_ADR,X_CURRENT,Y_CURRENT);
    
CLKGENERATOR: process
begin
    CLK<='1';
    wait for 0.1 ns;
    CLK<='0';
    wait for 0.1 ns;
end process CLKGENERATOR;
    
TEST: process
begin
    RESET<='1';
    wait for 1 ns;
    RESET<='0';
    wait;
end process TEST;

ADR: process
begin
  H_ADR<=(others=>'0');
  V_ADR<=(others=>'0');
  wait for 1 ns;
  loop
  if(conv_integer(to_stdlogicvector(H_ADR)) = 199) then
    H_ADR<=(others=>'0');
    if(conv_integer(to_stdlogicvector(V_ADR)) = 149) then
      V_ADR<=(others=>'0');
    else
      V_ADR<=to_bitvector(to_stdlogicvector(V_ADR)+1);
    end if;
  else
    H_ADR<=to_bitvector(to_stdlogicvector(H_ADR)+1);
  end if;
  wait for 0.2 ns;
  end loop;
end process ADR;
    
    


end architecture BALL_OBJECT_ARC_TEST;