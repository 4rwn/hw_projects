library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_fetcher is
    port (
        i_clk : in std_logic;
        i_rst_n : in std_logic;

        i_stall : in std_logic;
        i_jmp : in std_logic;
        i_jmp_addr : in std_logic_vector(31 downto 0);

        o_addr : out std_logic_vector(31 downto 0);
        o_instr : out std_logic_vector(31 downto 0);
        o_valid : out std_logic;

        o_instr_rd_addr : out std_logic_vector(31 downto 0);
        i_instr_rd_data : in std_logic_vector(31 downto 0)
    );
end entity instruction_fetcher;

architecture rtl of instruction_fetcher is
    signal r_pc : unsigned(31 downto 0);
begin
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst_n then
                if i_jmp then
                    r_pc <= unsigned(i_jmp_addr);

                    o_valid <= '0';
                elsif not i_stall then
                    r_pc <= r_pc + 4;

                    o_addr <= std_logic_vector(r_pc);
                    o_valid <= '1';
                end if;
            else
                r_pc <= (others => '0');

                o_valid <= '1';
            end if;
        end if;
    end process;

    o_instr_rd_addr <= std_logic_vector(r_pc);
    o_instr <= i_instr_rd_data;
end architecture rtl;