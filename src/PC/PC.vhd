library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
port(
  reset : in std_logic;
  count : out std_logic_vector(11 downto 0);
  clk   : in std_logic;
  inc   : in std_logic
);
end entity program_counter;

architecture rtl of program_counter is
  signal count_reg : unsigned(11 downto 0) := (others => '0'); 
begin

  count <= std_logic_vector(count_reg);

  process(clk, reset)
  begin
    if rising_edge(clk) and reset = '0' then
      count_reg <= count_reg + 1 when inc = '1' else count_reg;
    elsif rising_edge(clk) and reset = '1' then
      count_reg <= (others => '0');
    end if;
  end process;

end architecture rtl;