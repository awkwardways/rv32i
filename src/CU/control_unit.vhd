library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
port(
  clk        : in std_logic;
  inc_pc     : out std_logic;
  instr_bus  : in std_logic_vector(31 downto 0);
  ram_oce    : out std_logic;
  ram_cen    : out std_logic;
  ram_wre    : out std_logic := '0';
  alu_en     : out std_logic := '0';
);
end entity control_unit;

architecture rtl of control_unit is
  signal instruction : std_logic_vector(31 downto 0);
  signal state : state_t := address_ram;

  type state_t is (address_ram, get_instruction, decode, increase_pc);
  alias opcode is std_logic_vector(6 downto 0) : instruction(6 downto 0);
  alias rd is std_logic_vector(4 downto 0) : instruction(11 downto 7);
  alias funct3 is std_logic_vector(2 downto 0) : instruction(14 downto 12);
  alias rs1 is std_logic_vector(4 downto 0) : instruction(19 downto 15);
  alias imm_110 is std_logic_vector(11 downto 0) : instruction(31 downto 20);
  constant OP_IMM : std_logic_vector(6 downto 0) := "0010011";

  
begin

  process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when address_ram => 
          inc_pc <= '0';
          ram_oce <= '0';
          ram_cen <= '0';
          state <= get_instruction;

        when get_instruction => 

          instruction <= instr_bus;
          state <= decode;
        
        when decode => 
          case opcode is
            when OP_IMM => 

          end case;
          state <= increase_pc;


        when increase_pc => 
          inc_pc <= '1';
          ram_oce <= '1';
          ram_cen <= '1';
          state <= address_ram;
      end case;
    end if;
  end process;

end architecture rtl;