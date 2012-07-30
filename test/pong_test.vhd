library IEEE;
use IEEE.std_logic_1164.all;


entity PONG_TEST is
end entity PONG_TEST;

architecture PONG_ARC_TEST of PONG_TEST is
    signal CLK,RESET: bit;
    signal PADDLE_PLAYER1, PADDLE_PLAYER2: bit_vector(1 downto 0);
    signal H_SYNC, V_SYNC, VGA_BLANK, VGA_CLOCK, VGA_SYNC: std_logic;
    signal RED, GREEN, BLUE: std_logic_vector(9 downto 0);
component PONG
    port(
        CLK: in bit;
        RESET: in bit;
        PADDLE_PLAYER1: in bit_vector(1 downto 0);
        PADDLE_PLAYER2: in bit_vector(1 downto 0);
        H_SYNC: out std_logic;
        V_SYNC: out std_logic;
        RED: out std_logic_vector(9 downto 0);
        GREEN: out std_logic_vector(9 downto 0);
        BLUE: out std_logic_vector(9 downto 0);
        VGA_CLOCK: out std_logic;
        VGA_BLANK: out std_logic;
        VGA_SYNC: out std_logic
    );
end component PONG;

for all: PONG use entity work.PONG(PONG_ARC);

begin
PONG_INST: PONG 
    port map(CLK, RESET, PADDLE_PLAYER1, PADDLE_PLAYER2, H_SYNC, V_SYNC, 
             RED(9 downto 0),GREEN(9 downto 0),BLUE(9 downto 0), VGA_BLANK,
             VGA_CLOCK,VGA_SYNC);

end architecture PONG_ARC_TEST;