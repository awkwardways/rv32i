library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
  signal memory : memory_t := (others => (others => '0'));
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