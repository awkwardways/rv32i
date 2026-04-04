library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;


entity ram is
generic(
  ADDR_WIDTH : integer := 12;
  DATA_WIDTH : integer := 32
);
port(
  address : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  din     : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  dout    : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  en      : in std_logic;
  wre     : in std_logic;
  clk     : in std_logic
);
end entity ram;

architecture rtl of ram is
  type memory_t is array (0 to 4095) of std_logic_vector(31 downto 0);

  impure function init_mem return memory_t is
    file init_file : text open read_mode is "C:/Users/Franco/Documents/Codigo/VHDL/rv32i/src/memory/ram_init.hex";
    variable buf : line;
    variable ram_content : memory_t;
    variable i : integer := 0;
  begin
    while not endfile(init_file) loop
      readline(init_file, buf);
      hread(buf, ram_content(i));
      i := i + 1;
    end loop;
    ram_content(i to 4095) := ((others => x"00000013"));
    return ram_content;
  end function;

  signal memory : memory_t := init_mem;
begin

  process(clk, wre, en, address, din)
  begin
    if rising_edge(clk) and en = '1' then
      if wre = '0' then
        dout <= memory(to_integer(unsigned(address)));
      else
        memory(to_integer(unsigned(address))) <= din;
        dout <= (others => 'Z');
      end if;
    elsif rising_edge(clk) and en = '0' then
      dout <= (others => 'Z');
    end if;
  end process;

end architecture rtl;