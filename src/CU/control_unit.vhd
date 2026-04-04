library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
port(
  clk        : in std_logic;
  reset      : in std_logic;
  inc_pc     : out std_logic;
  instr_bus  : in std_logic_vector(31 downto 0);
  wre        : out std_logic;
  begin_strb : out std_logic;
  done_strb  : in std_logic;
  alu_op     : out std_logic_vector(2 downto 0);
  rd_sel     : out std_logic_vector(4 downto 0);
  rs1_sel    : out std_logic_vector(4 downto 0);
  rs1_en     : out std_logic;
  rs2_sel    : out std_logic_vector(4 downto 0);
  rs2_en     : out std_logic;
  reg_wre    : out std_logic;
  mem_busy   : in std_logic;
  immediate  : out std_logic_vector(31 downto 0)
);
end entity control_unit;

architecture rtl of control_unit is
  signal instruction : std_logic_vector(31 downto 0);
  type state_t is (address_ram, get_instruction, decode, execute, increase_pc);
  signal state : state_t := address_ram;

  alias opcode : std_logic_vector(6 downto 0) is instruction(6 downto 0);
  alias rd : std_logic_vector(4 downto 0) is instruction(11 downto 7);
  alias funct3 : std_logic_vector(2 downto 0) is instruction(14 downto 12);
  alias rs1 : std_logic_vector(4 downto 0) is instruction(19 downto 15);
  alias imm_110 : std_logic_vector(11 downto 0) is instruction(31 downto 20);
  constant OP_IMM : std_logic_vector(6 downto 0) := "0010011";

begin

  process(clk)
  begin
    if rising_edge(clk) and reset = '0' then
      case state is
        when address_ram => 
          if mem_busy = '0' then
            begin_strb <= '1';
            wre <= '0';
            state <= get_instruction;
          end if;
        
        when get_instruction => 
          begin_strb <= '0';
          if done_strb = '1' then
            instruction <= instr_bus;
            state <= decode;
          end if;

        when decode => 
          case opcode is
            when "0010011" => 
              alu_op <= funct3;
              rs1_sel <= rs1;
              rs1_en <= '1';
              rd_sel <= rd;
              immediate(11 downto 0) <= imm_110;
              immediate(31 downto 12) <= (others => imm_110(11));
            when others => state <= increase_pc;
          end case;
          state <= increase_pc;
          
        when execute => 
          inc_pc <= '1';
          reg_wre <= '1';

        when increase_pc => 
          reg_wre <= '0';
          inc_pc <= '0';
          rs1_en <= '0';
          rs2_en <= '0';
          state <= address_ram;
    
      end case;
    elsif rising_edge(clk) and reset = '1' then
      inc_pc     <= '0';
      wre        <= '0';
      begin_strb <= '0';
      alu_op     <= (others => '0');
      rd_sel     <= (others => '0');
      rs1_sel    <= (others => '0');
      rs1_en     <= '0';
      rs2_sel    <= (others => '0');
      rs2_en     <= '0';
      reg_wre    <= '0';
      immediate  <= (others => '0');
      state      <= address_ram;
    end if;
  end process;

end architecture rtl;