library ieee;
use ieee.std_logic_1164.all;

entity full_adder is 
  port (
    a      : in std_logic;
    b      : in std_logic;
    c_in   : in std_logic;
    s      : out std_logic;
    c_out  : out std_logic;
    enable : in std_logic
  );
end entity full_adder;

architecture behavioural of full_adder is
begin

  s <= (a xor b) xor c_in when enable = '0' else '0';
  c_out <= (a and b) or (c_in and b) or (c_in and a) when enable = '0' else '0'; 

end architecture behavioural;