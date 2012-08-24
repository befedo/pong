library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity SCORE_OBJECT_TEST is
end entity SCORE_OBJECT_TEST;

architecture SCORE_OBJECT_ARC_TEST of SCORE_OBJECT_TEST is
signal CLK: std_logic;
signal RESET:  std_logic;
signal DRAW: std_logic;
signal V_ADR: std_logic_vector(11 downto 0);
signal H_ADR:  std_logic_vector(11 downto 0);
signal INCREASE: std_logic;
signal CURRENT_SCORE: integer range 0 to 5;

component SCORE_OBJECT  
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
end component SCORE_OBJECT;

for all: SCORE_OBJECT use entity work.SCORE_OBJECT(SCORE_OBJECT_ARC);

begin
SCORE_OBJECT_INST: SCORE_OBJECT 
    port map(CLK,RESET,INCREASE,CURRENT_SCORE,DRAW,V_ADR,H_ADR);
    
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
    wait for 10000 ns;
    INCREASE<='1';
    wait for 0.2 ns;
    INCREASE<='0';
    wait for 10000 ns;
    INCREASE<='1';
    wait for 0.2 ns;
    INCREASE<='0';
    wait for 10000 ns;
    INCREASE<='1';
    wait for 0.2 ns;
    INCREASE<='0';
    wait;
end process TEST;

ADR: process
begin
  H_ADR<=(others=>'0');
  V_ADR<=(others=>'0');
  wait for 1 ns;
  loop
  if(conv_integer(H_ADR) = 100) then
    H_ADR<=(others=>'0');
    if(conv_integer(V_ADR) = 50) then
      V_ADR<=(others=>'0');
    else
      V_ADR<=V_ADR+1;
    end if;
  else
    H_ADR<=H_ADR+1;
  end if;
  wait for 0.2 ns;
  end loop;
end process ADR;
    
    


end architecture SCORE_OBJECT_ARC_TEST;