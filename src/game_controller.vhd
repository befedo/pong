library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity GAME_CONTROLLER is
    generic(
        PADDLE_TOP_LIMIT: integer range 0 to 199:=120;
        PADDLE_BOTTOM_LIMIT: integer range 0 to 199:=50
    );
    port(
        --!
        L_NOTR_PLAYER_1: in bit;
        STEP_PLAYER_1: in bit;
        L_NOTR_PLAYER_2: in bit;
        STEP_PLAYER_2: in bit;
        CLK: in bit;
        RESET: in bit;
        DOUT: out std_logic_vector(2 downto 0);
        V_ADR: out std_logic_vector(7 downto 0);
        H_ADR: out std_logic_vector(7 downto 0);
        PICTURE_COMPLETE: out std_logic
    );
end entity GAME_CONTROLLER;

architecture GAME_CONTROLLER_ARC of GAME_CONTROLLER is
signal PLAYER_PADDLE1_TOP: integer range 0 to 149;
signal PLAYER_PADDLE1_BOTTOM: integer range 0 to 149;
signal PLAYER_PADDLE2_TOP: integer range 0 to 149;
signal PLAYER_PADDLE2_BOTTOM: integer range 0 to 149;
signal BALL_X: integer range 0 to 199;
signal BALL_Y: integer range 0 to 149;
signal BALL_X_SPEED: integer range -128 to 127;
signal BALL_Y_SPEED: integer range -128 to 127;
signal VCOUNTER:integer range 0 to 199;
signal HCOUNTER:integer range 0 to 149;
type ZUSTAENDE is(z0,z1,z2,z3,z4);
signal ZUSTAND,FOLGE_Z:ZUSTAENDE;
begin
COUNT_GENERATOR:process(CLK,RESET)
                begin
                
                if(RESET='1') then
                    VCOUNTER<=0;
                    HCOUNTER<=0;
                    ZUSTAND<=z0;
                elsif(CLK'EVENT and CLK='1') then
                --Zustand uebernehmen
                ZUSTAND<=FOLGE_Z;
                --Counter
                    if(VCOUNTER<199) then
                        VCOUNTER<=VCOUNTER+1;
                    else 
                        VCOUNTER<=0;
                        if(HCOUNTER<149) then
                            HCOUNTER<=HCOUNTER+1;
                        else 
                            HCOUNTER<=0;
                        end if;
                    end if;
                end if;
                end process COUNT_GENERATOR;
                
PLAYER_PADDLE1:process(STEP_PLAYER_1)
               begin
               if (STEP_PLAYER_1'EVENT and STEP_PLAYER_1='1') then
                    if(L_NOTR_PLAYER_1='1' and PLAYER_PADDLE1_TOP<PADDLE_TOP_LIMIT) then
                        PLAYER_PADDLE1_TOP<=PLAYER_PADDLE1_TOP+1;
                        PLAYER_PADDLE1_BOTTOM<=PLAYER_PADDLE1_BOTTOM+1;
                    elsif(L_NOTR_PLAYER_1='0' and PLAYER_PADDLE1_BOTTOM>PADDLE_BOTTOM_LIMIT) then
                        PLAYER_PADDLE1_TOP<=PLAYER_PADDLE1_TOP-1;
                        PLAYER_PADDLE1_BOTTOM<=PLAYER_PADDLE1_BOTTOM-1;
                    end if;
               end if;
               end process PLAYER_PADDLE1;
               
PLAYER_PADDLE2:process(STEP_PLAYER_2)
               begin
               if (STEP_PLAYER_2'EVENT and STEP_PLAYER_2='1') then
                    if(L_NOTR_PLAYER_2='1' and PLAYER_PADDLE2_TOP<PADDLE_TOP_LIMIT) then
                        PLAYER_PADDLE2_TOP<=PLAYER_PADDLE2_TOP+1;
                        PLAYER_PADDLE2_BOTTOM<=PLAYER_PADDLE2_BOTTOM+1;
                    elsif(L_NOTR_PLAYER_2='0' and PLAYER_PADDLE2_BOTTOM>PADDLE_BOTTOM_LIMIT) then
                        PLAYER_PADDLE2_TOP<=PLAYER_PADDLE2_TOP-1;
                        PLAYER_PADDLE2_BOTTOM<=PLAYER_PADDLE2_BOTTOM-1;
                    end if;
               end if;
               end process PLAYER_PADDLE2;
               
GAME_AUTOMATE:process(ZUSTAND)
              begin
              FOLGE_Z<=z1;
                case ZUSTAND is
                        when z0=>               FOLGE_Z<=z1;
                                                PLAYER_PADDLE1_TOP<=50;
                                                PLAYER_PADDLE1_BOTTOM<=10;
                                                PLAYER_PADDLE2_TOP<=50;
                                                PLAYER_PADDLE2_BOTTOM<=10;
                                                BALL
                        when z1=>
                        when z2=>
                        when z3=>
                end case;
              end process GAME_AUTOMATE;
                
end architecture GAME_CONTROLLER_ARC; 
