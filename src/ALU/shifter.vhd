library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter is
  generic(
    DATA_WIDTH : integer := 32;
    AMNT_WIDTH : integer := 5
  );
  port(
    data   : in std_logic_vector(DATA_WIDTH - 1 downto 0);
    amnt   : in std_logic_vector(AMNT_WIDTH - 1 downto 0);
    dir    : in std_logic;  -- '1' for left '0' for right
    shft   : in std_logic;  -- '1' for logical shift, '0' for arithmetic shift
    enable : in std_logic;
    rslt   : out std_logic_vector(DATA_WIDTH - 1 downto 0)
  );
end entity shifter;

architecture behavioural of shifter is
begin

  process(data, amnt, shft, enable, dir) is
  begin
    if enable = '0' then
      if dir = '0' then
        rslt(to_integer(rslt'left - unsigned(amnt)) downto 0) <= data(data'left downto to_integer(unsigned(amnt)));
        rslt(rslt'left downto to_integer(rslt'length - unsigned(amnt))) <= (others => '0');
      else 
        rslt(rslt'left downto to_integer(unsigned(amnt))) <= data(to_integer(data'left - unsigned(amnt)) downto 0);
        rslt(to_integer(unsigned(amnt) - 1) downto 0) <= (others => '0');
      end if;
    else
      rslt <= (others => 'Z');
    end if;
  end process;

end architecture behavioural;