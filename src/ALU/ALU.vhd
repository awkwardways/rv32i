library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is 
  generic (
    A_WIDTH         : integer := 32;
    B_WIDTH         : integer := 32;
    C_WIDTH         : integer := 32
  );
  port (
    a      : in std_logic_vector(A_WIDTH - 1 downto 0);
    b      : in std_logic_vector(B_WIDTH - 1 downto 0);
    c      : out std_logic_vector(C_WIDTH - 1 downto 0);
    op_select : in std_logic_vector(2 downto 0);
    modifier  : in std_logic
  );
end entity ALU;

architecture rtl of ALU is
begin

  process(op_select, a, b)
  begin
    case op_select is 
      when "000" => 
        c <= std_logic_vector(unsigned(a) + unsigned(b)) when modifier = '0' else std_logic_vector(unsigned(a) - unsigned(b));

      when "001" => 
        c <= std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(b(4 downto 0)))));

      when "010" => 
        c <= 32x"1" when signed(a) < signed(b) else 32x"0";

      when "011" => 
        c <= 32x"1" when unsigned(a) < unsigned(b) else 32x"0";
      
      when "100" => 
        c <= a xor b;

      when "101" => 
        c <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(b(4 downto 0))))) when modifier = '0' else std_logic_vector(shift_right(signed(a), to_integer(unsigned(b(4 downto 0)))));

      when "110" => 
        c <= a or b;

      when "111" => 
        c <= a and b;

      when others => c <= (others => '0');
    end case;
  end process;

end architecture rtl;