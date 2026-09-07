--  ❌  NE PAS MODIFIER CE FICHIER
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/16/2025 12:48:45 PM
-- Design Name: 
-- Module Name: rng - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rng is
    Port (
        clk   : in  std_logic;
        seed  : in  std_logic_vector(7 downto 0); --
        load  : in  std_logic;
        value : out std_logic_vector(15 downto 0)
    );
end rng;

architecture Behavioral of rng is

    -- Internal 16-bit LFSR register with default non-zero seed
    signal lfsr_reg : std_logic_vector(15 downto 0) := "1010101001010101";

begin

    value <= lfsr_reg;

    process(clk)
        variable fb : std_logic;
    begin
        if rising_edge(clk) then

            if load = '1' then
                -- Load user-provided 8-bit seed into upper and lower bytes
                -- Ensure LFSR is not all zeros (invalid state)
                if seed /= "00000000" then
                    lfsr_reg <= seed & (not seed);  -- spread 8-bit seed to 16 bits
                else
                    -- Default fallback if zero provided
                    lfsr_reg <= "1010101001010101";
                end if;

            else
                -- 16-bit LFSR feedback with maximal-length polynomial
                -- Taps: 16, 15, 13, 4 (polynomial x^16 + x^15 + x^13 + x^4 + 1)
                fb := lfsr_reg(15) xor lfsr_reg(14) xor lfsr_reg(12) xor lfsr_reg(3);

                -- Shift left and append feedback bit
                lfsr_reg <= lfsr_reg(14 downto 0) & fb;
            end if;

        end if;
    end process;

end Behavioral;

