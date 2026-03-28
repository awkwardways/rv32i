library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
generic(
  PC_WIDTH : integer := 32
);
port(
  clk    : in std_logic;
  inc    : in std_logic;
  pc_out : out std_logic_vector(PC_WIDTH - 1 downto 0);
  incbo  : in std_logic;  --increase by offset
  offset : in std_logic_vector(PC_WIDTH - 1 downto 0);
  rst    : in std_logic
);
end entity PC;

architecture rtl of PC is
  signal count : unsigned(PC_WIDTH - 1 downto 0);
begin

  pc_out <= std_logic_vector(count);

  process(clk, inc, rst)
  begin
    if rising_edge(clk) and rst = '0' then
      if inc = '1' then
        count <= count + 1 when incbo = '0' else count + unsigned(offset);
      else
        count <= count;      
      end if;
    elsif rising_edge(clk) and rst = '1' then
      count <= (others => '0');
    end if;
  end process;

end architecture rtl;