library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity riscv_core_tb is
end entity riscv_core_tb;

architecture rtl of riscv_core_tb is
    constant CLOCK_PERIOD : time := 10 ns;
    constant RESET_PERIOD : time := 55 ns;

    signal clk : std_logic := '0';
    signal rst_n : std_logic := '0';

    signal r_instr_rd_addr : std_logic_vector(31 downto 0);
    signal r_instr_rd_data : std_logic_vector(31 downto 0);
begin
    p_clk_gen : process 
    begin
        wait for CLOCK_PERIOD/2;
        clk <= not clk;
    end process p_clk_gen;

    p_initial_reset : process 
    begin
        wait for RESET_PERIOD;
        rst_n <= '1';
        wait;
    end process p_initial_reset;

    instr_mem : entity work.memory
        generic map (
            ADDR_BITS => 10,
            INIT_FILE => "sim/tmp.hex"
        )
        port map (
            i_clk => clk,

            i_rd_addr => r_instr_rd_addr,
            o_rd_data => r_instr_rd_data,

            i_wr_en   => (others => '0'),
            i_wr_addr => (others => '0'),
            i_wr_data => (others => '0')
        );

    riscv_core : entity work.top
        port map (
            i_clk => clk,
            i_rst_n => rst_n,

            o_instr_rd_addr => r_instr_rd_addr,
            i_instr_rd_data => r_instr_rd_data
        );
end architecture rtl;