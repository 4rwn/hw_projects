library ieee;
use ieee.std_logic_1164.all;

entity top is
    port (
        i_clk : in std_logic;
        i_rst_n : in std_logic;

        o_instr_rd_addr : out std_logic_vector(31 downto 0);
        i_instr_rd_data : in std_logic_vector(31 downto 0)
    );
end entity top;

architecture rtl of top is
    -- IF
    signal w_if_addr : std_logic_vector(31 downto 0);
    signal w_if_instr : std_logic_vector(31 downto 0);
    signal w_if_valid : std_logic;
begin
    -- IF
    instr_fetch : entity work.instruction_fetcher
        port map (
            i_clk => i_clk,
            i_rst_n => i_rst_n,

            i_stall => '0',
            i_jmp => '0',
            i_jmp_addr => (others => '0'),

            o_addr => w_if_addr,
            o_instr => w_if_instr,
            o_valid => w_if_valid,

            o_instr_rd_addr => o_instr_rd_addr,
            i_instr_rd_data => i_instr_rd_data
        );
end architecture rtl;