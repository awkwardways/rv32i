library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity twoscomp_buffer is
  generic (
    BUFFER_WIDTH : integer := 32
  );
  port(
    a          : in std_logic_vector(BUFFER_WIDTH - 1 downto 0);
    b          : out std_logic_vector(BUFFER_WIDTH - 1 downto 0);
    complement : in std_logic
  );
end entity twoscomp_buffer;

architecture behavioural of twoscomp_buffer is
begin

  b <= std_logic_vector(not unsigned(a) + 1) when complement = '0' else a;

end architecture;