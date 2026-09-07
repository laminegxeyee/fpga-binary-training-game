library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM_CORE is
    Port (
        clk        : in  STD_LOGIC;
        rst_n      : in  STD_LOGIC;
        DISP0      : out STD_LOGIC_VECTOR(4 downto 0);
        DISP1      : out STD_LOGIC_VECTOR(4 downto 0);
        DISP2      : out STD_LOGIC_VECTOR(4 downto 0);
        DISP3      : out STD_LOGIC_VECTOR(4 downto 0);
        DISP4      : out STD_LOGIC_VECTOR(4 downto 0);
        DISP5      : out STD_LOGIC_VECTOR(4 downto 0);
        DISP6      : out STD_LOGIC_VECTOR(4 downto 0);
        DISP7      : out STD_LOGIC_VECTOR(4 downto 0);
        L          : in  STD_LOGIC;
        R          : in  STD_LOGIC;
        C          : in  STD_LOGIC;
        sw         : in  STD_LOGIC_VECTOR(9 downto 0);
        rand_value : in  STD_LOGIC_VECTOR(15 downto 0);
        LD         : out STD_LOGIC_VECTOR(15 downto 0)

    );
end FSM_CORE;

architecture Behavioral of FSM_CORE is

    type state_type is (
        S_INIT, S_MODE, S_NEW, S_PLAY,
        S_SUCCESS, S_FAIL, S_GAME_OVER, S_SHOW_SCORE
    );

    signal cur_state, next_state : state_type;

    signal mode       : STD_LOGIC := '0';
    signal tries      : INTEGER range 0 to 3 := 3;
    signal score      : UNSIGNED(6 downto 0) := (others => '0');
    signal target_num : UNSIGNED(9 downto 0) := (others => '0');
    signal sw_val     : UNSIGNED(9 downto 0);
    signal is_correct : STD_LOGIC;
    signal unite, dizaine, centaine, milieme : UNSIGNED(3 downto 0); 
    signal s_unite, s_dizaine     : UNSIGNED(3 downto 0); 
    constant zero : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    constant un : STD_LOGIC_VECTOR(4 downto 0) := "00001";
    constant deux : STD_LOGIC_VECTOR(4 downto 0) := "00010";
    constant trois : STD_LOGIC_VECTOR(4 downto 0) := "00011";
    constant quatre : STD_LOGIC_VECTOR(4 downto 0) := "00100";
    constant cinq : STD_LOGIC_VECTOR(4 downto 0) := "00101";
    constant six : STD_LOGIC_VECTOR(4 downto 0) := "00110";
    constant sept : STD_LOGIC_VECTOR(4 downto 0) := "00111";
    constant huit : STD_LOGIC_VECTOR(4 downto 0) := "01000";
    constant neuf : STD_LOGIC_VECTOR(4 downto 0) := "01001";
    constant CODE_E : STD_LOGIC_VECTOR(4 downto 0) := "01110";
    constant CODE_r : STD_LOGIC_VECTOR(4 downto 0) := "10000";
    constant CODE_c : STD_LOGIC_VECTOR(4 downto 0) := "10010";
    constant CODE_L : STD_LOGIC_VECTOR(4 downto 0) := "10011";
    constant CODE_v : STD_LOGIC_VECTOR(4 downto 0) := "10100";
    constant CODE_d : STD_LOGIC_VECTOR(4 downto 0) := "01101";
    constant rien : STD_LOGIC_VECTOR(4 downto 0) := "11111";

    function digit_to_code(d : UNSIGNED(3 downto 0)) return STD_LOGIC_VECTOR is
    begin
        case d is
            when "0000" => return zero;
            when "0001" => return un;
            when "0010" => return deux;
            when "0011" => return trois;
            when "0100" => return quatre;
            when "0101" => return cinq;
            when "0110" => return six;
            when "0111" => return sept;
            when "1000" => return huit;
            when "1001" => return neuf;
            when others => return rien;
        end case;
    end function;

begin
    sw_val     <= unsigned(sw);
    is_correct <= '1' when sw_val = target_num else '0';
    
    conv_target : process(target_num)
        variable n   : integer;
        variable unitei : integer;
        variable dizainei : integer;
        variable centainei : integer;
        variable miliemei : integer;
    begin
        n   := to_integer(target_num);
        if n < 0 then
            n := 0;
        elsif n > 1023 then
            n := 1023;
        end if;

        miliemei := n / 1000;
        n   := n mod 1000;
        centainei := n / 100;
        n   := n mod 100;
        dizainei := n / 10;
        unitei := n mod 10;

        unite <= to_unsigned(unitei, 4);
        dizaine <= to_unsigned(dizainei, 4);
        centaine <= to_unsigned(centainei, 4);
        milieme <= to_unsigned(miliemei, 4);
    end process conv_target;


    conv_score : process(score)
        variable n   : integer;
        variable unitei : integer;
        variable dizainei : integer;
    begin
        n := to_integer(score);
        if n < 0 then
            n := 0;
        elsif n > 99 then
            n := 99;
        end if;

        dizainei := n / 10;
        unitei := n mod 10;

        s_dizaine <= to_unsigned(dizainei, 4);
        s_unite <= to_unsigned(unitei, 4);
    end process conv_score;


    state_reg : process(clk, rst_n)
    begin
        if rst_n = '0' then
            cur_state  <= S_INIT;
            mode       <= '0';
            tries      <= 3;
            score      <= (others => '0');
            target_num <= (others => '0');
        elsif rising_edge(clk) then
            cur_state <= next_state;

            case cur_state is
                when S_INIT =>
                    tries <= 3;
                    score <= (others => '0');

                when S_MODE =>
                    if L = '1' then
                        mode <= '0';
                    elsif R = '1' then
                        mode <= '1';
                    end if;

                when S_NEW =>
                    if mode = '0' then

                        target_num <= (others => '0');
                        target_num(3 downto 0) <= to_unsigned(
                            to_integer(unsigned(rand_value(3 downto 0))) mod 10, 4
                        );
                    else
                        target_num <= unsigned(rand_value(9 downto 0));
                    end if;

                when others =>
                    null;
            end case;

            if (cur_state = S_PLAY) and (next_state = S_SUCCESS) then
                score <= score + 1;
            end if;

            if (cur_state = S_PLAY) and (next_state = S_FAIL) then
                if tries > 0 then
                    tries <= tries - 1;
                end if;
            end if;

            if (cur_state = S_SHOW_SCORE) and (next_state = S_MODE) then
                tries <= 3;
                score <= (others => '0');
            end if;
        end if;
    end process state_reg;


    next_state_logic : process(cur_state, C, is_correct, tries)
    begin
        next_state <= cur_state;

        case cur_state is
            when S_INIT =>
                next_state <= S_MODE;

            when S_MODE =>
                if C = '1' then
                    next_state <= S_NEW;
                end if;

            when S_NEW =>
                next_state <= S_PLAY;

            when S_PLAY =>
                if C = '1' then
                    if is_correct = '1' then
                        next_state <= S_SUCCESS;
                    else
                        next_state <= S_FAIL;
                    end if;
                end if;

            when S_SUCCESS =>
                if C = '1' then
                    next_state <= S_NEW;
                end if;

            when S_FAIL =>
                if C = '1' then
                    if tries = 0 then
                        next_state <= S_GAME_OVER;
                    else
                        next_state <= S_NEW;
                    end if;
                end if;

            when S_GAME_OVER =>
                if C = '1' then
                    next_state <= S_SHOW_SCORE;
                end if;

            when S_SHOW_SCORE =>
                if C = '1' then
                    next_state <= S_MODE;
                end if;

            when others =>
                next_state <= S_INIT;
        end case;
    end process next_state_logic;

output_logic : process(cur_state, mode, tries, sw_val,
                       unite, dizaine, centaine, milieme, s_unite, s_dizaine, target_num)
    variable ld_tmp : STD_LOGIC_VECTOR(15 downto 0);
    variable i      : integer;
begin

    ld_tmp := (others => '1');
    DISP4 <= rien;
    DISP5 <= rien;
    DISP6 <= rien;
    DISP7 <= rien;


    case cur_state is

        when S_INIT =>
            DISP0 <= rien;
            DISP1 <= rien;
            DISP2 <= rien;
            DISP3 <= rien;

        when S_MODE =>
            DISP3 <= CODE_L;
            DISP2 <= CODE_v;
            DISP1 <= CODE_L;
            if mode = '0' then
                DISP0 <= zero;
            else
                DISP0 <= huit;
            end if;

        when S_NEW =>
            DISP0 <= rien;
            DISP1 <= rien;
            DISP2 <= rien;
            DISP3 <= rien;

        when S_PLAY =>
              for i in 13 to 15 loop
                 ld_tmp(i) := '0';
              end loop;
            if tries >= 1 then
                ld_tmp(15) := '1';
            end if;
            if tries >= 2 then
                ld_tmp(14) := '1';
            end if;
            if tries = 3 then
                ld_tmp(13) := '1';
            end if;
            
            if mode = '0' then       
              DISP0 <= digit_to_code(unite);
              DISP1 <= rien;
              DISP2 <= rien;
              DISP3 <= rien;
            else
                DISP0 <= digit_to_code(unite);
                DISP1 <= digit_to_code(dizaine);
                DISP2 <= digit_to_code(centaine);
                DISP3 <= digit_to_code(milieme);
            end if;


            for i in 0 to 9 loop
                if sw_val(i) = '1' then
                    ld_tmp(i) := '1'; 
                else
                    ld_tmp(i) := '0';
                end if;    
            end loop;
            
            for i in 10 to 12 loop
                 ld_tmp(i) := '0';
            end loop;
     

        when S_SUCCESS =>
            DISP3 <= six;
            DISP2 <= zero;
            DISP1 <= zero;
            DISP0 <= CODE_d;
            ld_tmp := (others => '0');

        when S_FAIL =>
            DISP3 <= CODE_E;
            DISP2 <= CODE_r;
            DISP1 <= CODE_r;
            DISP0 <= CODE_r;

            if mode = '0' then
                for i in 0 to 15 loop
                    ld_tmp(i) := '0';
                end loop;
            else

                for i in 0 to 9 loop
                    if sw_val(i) = target_num(i) then
                        ld_tmp(i) := '0';  
                    else
                        ld_tmp(i) := '1';  
                    end if;
                end loop;
                
            end if;

        when S_GAME_OVER =>
            DISP3 <= zero;
            DISP2 <= CODE_V;
            DISP1 <= CODE_E;
            DISP0 <= CODE_R;
            ld_tmp := (others => '1');

        when S_SHOW_SCORE =>
            DISP3 <= cinq;
            DISP2 <= CODE_C;
            DISP1 <= digit_to_code(s_dizaine);
            DISP0 <= digit_to_code(s_unite);
            ld_tmp := (others => '1');

        when others =>
            DISP0 <= rien;
            DISP1 <= rien;
            DISP2 <= rien;
            DISP3 <= rien;
    end case;

    LD <= ld_tmp;
end process output_logic;
end Behavioral;
