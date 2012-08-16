library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity PADDLE_OBJECT_TEST is
end entity PADDLE_OBJECT_TEST;

architecture PADDLE_OBJECT_ARC_TEST of PADDLE_OBJECT_TEST is
signal L_NOTR:  bit;
signal STEP:  bit;
signal CLK:  bit;
signal RESET:  bit;
signal DRAW:  std_logic;
signal V_ADR:  bit_vector(7 downto 0);
signal H_ADR:  bit_vector(7 downto 0);
signal PADDLE_TOP:  integer range 0 to 149;
signal PADDLE_BOTTOM:  integer range 0 to 149;

component PADDLE_OBJECT is
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
end component PADDLE_OBJECT;


for all: PADDLE_OBJECT use entity work.PADDLE_OBJECT(PADDLE_OBJECT_ARC);

begin
PADDLE_OBJECT_INST: PADDLE_OBJECT 
    port map(L_NOTR,STEP,CLK,RESET,DRAW,V_ADR,H_ADR,PADDLE_TOP,PADDLE_BOTTOM);
    
CLKGENERATOR: process
begin
    CLK<='1';
    wait for 0.1 ns;
    CLK<='0';
    wait for 0.1 ns;
end process CLKGENERATOR;

STEPGENERATOR: process
begin
    STEP<='1';
    wait for 50 ns;
    STEP<='0';
    wait for 50 ns;
end process STEPGENERATOR;

L_NOTRGENERATOR: process
begin
    L_NOTR<='1';
    wait for 1000 ns;
    L_NOTR<='0';
    wait for 1000 ns;
end process L_NOTRGENERATOR;
    
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
    
    


end architecture PADDLE_OBJECT_ARC_TEST;