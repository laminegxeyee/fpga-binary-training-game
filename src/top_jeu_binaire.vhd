library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_jeu_binaire is
    Port (
        CLK       : in  STD_LOGIC;
        BTNU      : in  STD_LOGIC;
        BTNL      : in  STD_LOGIC;
        BTNR      : in  STD_LOGIC;
        BTNC      : in  STD_LOGIC;
        SW        : in  STD_LOGIC_VECTOR(15 downto 0);
        LD        : out STD_LOGIC_VECTOR(15 downto 0);
        SEVEN_SEG : out STD_LOGIC_VECTOR(7 downto 0);
        AN        : out STD_LOGIC_VECTOR(7 downto 0)
    );
end top_jeu_binaire;

architecture Behavioral of top_jeu_binaire is

    component debounce is
        generic(
            counter_size  :  integer := 19
        );
        port(
            clk    : in  STD_LOGIC;
            button : in  STD_LOGIC;
            result : out STD_LOGIC
        );
    end component;

    component pulse_gen is
        Port (
            clk       : in  STD_LOGIC;
            rst_n     : in  STD_LOGIC;
            btn_in    : in  STD_LOGIC;
            pulse_out : out STD_LOGIC
        );
    end component;
    
    component rng is
        Port (
            clk   : in  std_logic;
            seed  : in  std_logic_vector(7 downto 0);
            load  : in  std_logic;
            value : out std_logic_vector(15 downto 0)
        );
    end component;

    component gestAffichage is
        Port (
            CLK      : in  STD_LOGIC;
            DISP0    : in std_logic_vector(4 downto 0);
            DISP1    : in std_logic_vector(4 downto 0);
            DISP2    : in std_logic_vector(4 downto 0);
            DISP3    : in std_logic_vector(4 downto 0);
            DISP4    : in std_logic_vector(4 downto 0);
            DISP5    : in std_logic_vector(4 downto 0);
            DISP6    : in std_logic_vector(4 downto 0);
            DISP7    : in std_logic_vector(4 downto 0);
            SEVEN_SEG : out STD_LOGIC_VECTOR (7 downto 0);
            AN        : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    component FSM_CORE is
        Port (
            clk        : in  STD_LOGIC;
            rst_n      : in  STD_LOGIC;

            L          : in  STD_LOGIC;
            R          : in  STD_LOGIC;
            C          : in  STD_LOGIC;

            sw         : in  STD_LOGIC_VECTOR(9 downto 0);
            rand_value : in  STD_LOGIC_VECTOR(15 downto 0);

            LD         : out STD_LOGIC_VECTOR(15 downto 0);

            DISP0      : out STD_LOGIC_VECTOR(4 downto 0);
            DISP1      : out STD_LOGIC_VECTOR(4 downto 0);
            DISP2      : out STD_LOGIC_VECTOR(4 downto 0);
            DISP3      : out STD_LOGIC_VECTOR(4 downto 0);
            DISP4      : out STD_LOGIC_VECTOR(4 downto 0);
            DISP5      : out STD_LOGIC_VECTOR(4 downto 0);
            DISP6      : out STD_LOGIC_VECTOR(4 downto 0);
            DISP7      : out STD_LOGIC_VECTOR(4 downto 0)
        );
    end component;

    signal rst_n    : STD_LOGIC;

    signal L_db, R_db, C_db : STD_LOGIC;
    signal L_p, R_p, C_p    : STD_LOGIC;

    signal rand_val : STD_LOGIC_VECTOR(15 downto 0);

    signal d0, d1, d2, d3, d4, d5, d6, d7 : STD_LOGIC_VECTOR(4 downto 0);

    signal seed_cnt : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

begin 

    process(CLK)
    begin
        if rising_edge(CLK) then
            seed_cnt <= std_logic_vector(unsigned(seed_cnt) + 1);
        end if;
    end process;

    rst_n <= not BTNU;

    deb_L : debounce
        port map(
            clk    => CLK,
            button => BTNL,
            result => L_db
        );

    deb_R : debounce
        port map(
            clk    => CLK,
            button => BTNR,
            result => R_db
        );

    deb_C : debounce
        port map(
            clk    => CLK,
            button => BTNC,
            result => C_db
        );

    pg_L : pulse_gen
        port map(
            clk       => CLK,
            rst_n     => rst_n,
            btn_in    => L_db,
            pulse_out => L_p
        );

    pg_R : pulse_gen
        port map(
            clk       => CLK,
            rst_n     => rst_n,
            btn_in   => R_db,
            pulse_out => R_p
        );

    pg_C : pulse_gen
        port map(
            clk       => CLK,
            rst_n     => rst_n,
            btn_in    => C_db,
            pulse_out => C_p
        );

    u_rng : rng
        port map(
            clk   => CLK,
            seed  => seed_cnt,
            load  => BTNU,
            value => rand_val
        );
    
    u_core : FSM_CORE
        port map(
            clk        => CLK,
            rst_n      => rst_n,

            L          => L_p,
            R          => R_p,
            C          => C_p,

            sw         => SW(9 downto 0),
            rand_value => rand_val,

            LD         => LD,

            DISP0      => d0,
            DISP1      => d1,
            DISP2      => d2,
            DISP3      => d3,
            DISP4      => d4,
            DISP5      => d5,
            DISP6      => d6,
            DISP7      => d7
        );

    u_aff : gestAffichage
        port map(
            CLK       => CLK,
            DISP0     => d0,
            DISP1     => d1,
            DISP2     => d2,
            DISP3     => d3,
            DISP4     => d4,
            DISP5     => d5,
            DISP6     => d6,
            DISP7     => d7,
            SEVEN_SEG => SEVEN_SEG,
            AN        => AN
        );

end Behavioral;
