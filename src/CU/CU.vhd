library ieee;
use ieee.std_logic_1164.all;

entity CU is
generic(
  INST_WIDTH : integer := 32
);
port(
  clk       : in std_logic;
  inst      : in std_logic_vector(INST_WIDTH - 1 downto 0);
  mem_en    : out std_logic;
  alu_en    : out std_logic
);
end entity CU;

architecture rtl of CU is
  type cycle_stage_t is (fetch_instruction, decode_instruction);
  -- I-type instructions
  alias opcode : std_logic_vector(6 downto 0) is inst(6 downto 0);
  alias rd     : std_logic_vector(4 downto 0) is inst(11 downto 7);
  alias funct3 : std_logic_vector(2 downto 0) is inst(14 downto 12);
  alias rs1    : std_logic_vector(4 downto 0) is inst(19 downto 15);
  alias imm110 : std_logic_vector(11 downto 0) is inst(31 downto 20);

  signal cycle_stage : cycle_stage_t := fetch_instruction;
  signal curr_instr  : std_logic_vector()
begin

  process(inst, clk) 
  begin
    if rising_edge(clk) then
      case cycle_stage is
        when fetch_instruction =>
          mem_en <= '0'; --enable memory

      end case;
    end if;
  end process;

end architecture rtl;