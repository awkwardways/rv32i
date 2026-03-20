library ieee;
use ieee.std_logic_1164.all;

entity CU is
generic(
  INST_WIDTH : integer := 32
);
port(
  clk    : in std_logic;
  inst   : in std_logic_vector(INST_WIDTH - 1 downto 0);
  alu_en : out std_logic;
);
end entity CU;

architecture rtl of CU is
  -- I-type instructions
  alias opcode : std_logic_vector(6 downto 0) is inst(6 downto 0);
  alias rd     : std_logic_vector(4 downto 0) is inst(11 downto 7);
  alias funct3 : std_logic_vector(2 downto 0) is inst(14 downto 12);
  alias rs1    : std_logic_vector(4 downto 0) is inst(19 downto 15);
  alias imm110 : std_logic_vector(11 downto 0) is inst(31 downto 20);
begin

  process(inst, clk) 
  begin
    case inst is
      when "0010011" => 
        alu_en => '1';
    end case;
  end process;

end architecture rtl;