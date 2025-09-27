library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity memory is
    generic (
        ADDR_BITS : integer := 10;
        INIT_FILE : string := ""
    );
    port (
        i_clk : in std_logic;

        i_rd_addr : in std_logic_vector(31 downto 0);
        o_rd_data : out std_logic_vector(31 downto 0);

        i_wr_en : in std_logic_vector(1 downto 0);
        i_wr_addr : in std_logic_vector(31 downto 0);
        i_wr_data : in std_logic_vector(31 downto 0)
    );
end entity memory;

architecture rtl of memory is
    type mem_t is array (0 to 2**ADDR_BITS - 1) of std_logic_vector(7 downto 0);

    constant SIZE : integer := 2**ADDR_BITS;

    signal r_mem : mem_t;
begin
    p_rd_wr : process(i_clk)
        variable init_done : boolean := false;
        file f : text;
        variable l : line;
        variable v : std_logic_vector(7 downto 0);
        variable i : integer := 0;

        variable w_rd_addr, w_wr_addr : integer range 0 to SIZE - 1;
        variable w_rd_data0, w_rd_data1, w_rd_data2, w_rd_data3 : std_logic_vector(7 downto 0);
    begin
        -- Initialization from file
        if not init_done then
            init_done := true;
            if INIT_FILE /= "" then
                file_open(f, INIT_FILE, read_mode);
                while not endfile(f) and i < SIZE loop
                    readline(f, l);
                    hread(l, v);
                    r_mem(i) <= v;
                    i := i + 1;
                end loop;
            end if;
        end if;

        if rising_edge(i_clk) then
            w_rd_addr := to_integer(unsigned(i_rd_addr(ADDR_BITS-1 downto 0)));
            w_wr_addr := to_integer(unsigned(i_wr_addr(ADDR_BITS-1 downto 0)));

            -- Reads
            w_rd_data0 := r_mem(w_rd_addr);
            if w_rd_addr+1 < SIZE then w_rd_data1 := r_mem(w_rd_addr+1); else w_rd_data1 := (others => '0'); end if;
            if w_rd_addr+2 < SIZE then w_rd_data2 := r_mem(w_rd_addr+2); else w_rd_data2 := (others => '0'); end if;
            if w_rd_addr+3 < SIZE then w_rd_data3 := r_mem(w_rd_addr+3); else w_rd_data3 := (others => '0'); end if;

            o_rd_data <= w_rd_data3 & w_rd_data2 & w_rd_data1 & w_rd_data0;

            -- Writes
            if i_wr_en = "01" then
                r_mem(w_wr_addr) <= i_wr_data(7 downto 0);
            elsif i_wr_en = "10" then
                r_mem(w_wr_addr) <= i_wr_data(7 downto 0);
                if w_wr_addr+1 < SIZE then r_mem(w_wr_addr + 1) <= i_wr_data(15 downto 8); end if;
            elsif i_wr_en = "11" then
                r_mem(w_wr_addr) <= i_wr_data(7 downto 0);
                if w_wr_addr+1 < SIZE then r_mem(w_wr_addr + 1) <= i_wr_data(15 downto 8); end if;
                if w_wr_addr+2 < SIZE then r_mem(w_wr_addr + 2) <= i_wr_data(23 downto 16); end if;
                if w_wr_addr+3 < SIZE then r_mem(w_wr_addr + 3) <= i_wr_data(31 downto 24); end if;
            end if;
        end if;
    end process p_rd_wr;
end architecture rtl;