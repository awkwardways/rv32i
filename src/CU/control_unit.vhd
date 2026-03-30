library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
port(
  clk        : in std_logic;
  inc_pc     : out std_logic;
  instr_bus  : in std_logic_vector(31 downto 0);
  ram_oce    : out std_logic;
  ram_cen    : out std_logic;
  ram_wre    : out std_logic := '0'
);
end entity control_unit;

architecture rtl of control_unit is
  type state_t is (address_ram, get_instruction, decode, increase_pc);
  signal state : state_t := address_ram;
  signal instruction : std_logic_vector(31 downto 0);
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