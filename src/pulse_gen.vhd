library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pulse_gen is
    Port (
        clk       : in  STD_LOGIC;
        rst_n     : in  STD_LOGIC;     
        btn_in    : in  STD_LOGIC;    
        pulse_out : out STD_LOGIC      
    );
end pulse_gen;

architecture Behavioral of pulse_gen is

    signal btn_sync_0, btn_sync_1 : STD_LOGIC;


    type state_type is (IDLE, PULSE, WAIT_RELEASE);
    signal current_state, next_state : state_type;

begin

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            btn_sync_0 <= '0';
            btn_sync_1 <= '0';
        elsif rising_edge(clk) then
            btn_sync_0 <= btn_in;
            btn_sync_1 <= btn_sync_0;
        end if;
    end process;

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;


    process(current_state, btn_sync_1)
    begin
        case current_state is

            when IDLE =>
                if btn_sync_1 = '1' then
                    next_state <= PULSE;        
                else
                    next_state <= IDLE;
                end if;

            when PULSE =>

                if btn_sync_1 = '1' then
                    next_state <= WAIT_RELEASE;
                else
                    next_state <= IDLE;
                end if;

            when WAIT_RELEASE =>
                if btn_sync_1 = '0' then
                    next_state <= IDLE;          
                else
                    next_state <= WAIT_RELEASE;
                end if;

            when others =>
                next_state <= IDLE;
        end case;
    end process;


    process(current_state)
    begin
        case current_state is
            when PULSE =>
                pulse_out <= '1';    
            when others =>
                pulse_out <= '0';
        end case;
    end process;

end Behavioral;
