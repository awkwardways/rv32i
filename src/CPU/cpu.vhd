library ieee;
use ieee.std_logic_1164.all;

entity cpu is 
generic(
  DATA_WIDTH : integer := 32;
  ADDR_WIDTH : integer := 12
);
port(
  clk         : in std_logic;
  reset       : in std_logic;
  address_bus : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
  data_out    : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  data_in     : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  mem_en      : out std_logic;
  wre_out     : out std_logic
);
end entity cpu;

architecture rtl of cpu is
  constant A_WIDTH    : integer := 32;
  constant B_WIDTH    : integer := 32;
  constant C_WIDTH    : integer := 32;

  signal inc_pc     : std_logic;
  signal instr_bus  : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal wre_in     : std_logic;
  signal begin_strb : std_logic; 
  signal done_strb  : std_logic;
  signal alu_op     : std_logic_vector(2 downto 0);
  signal alu_mod    : std_logic;
  signal rd         : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal rd_sel     : std_logic_vector(4 downto 0);
  signal rs1        : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal rs1_sel    : std_logic_vector(4 downto 0);
  signal rs1_en     : std_Logic;
  signal rs2        : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal rs2_sel    : std_logic_vector(4 downto 0);
  signal rs2_en     : std_logic;
  signal reg_wre    : std_logic;
  signal busy       : std_logic;
  signal immediate  : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal imm_sel    : std_logic;
  signal count      : std_logic_vector(ADDR_WIDTH - 1 downto 0);
  signal din_in     : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal mux_out    : std_logic_vector(DATA_WIDTH - 1 downto 0);
begin

  CU: entity work.control_unit(rtl)
  port map(
    clk => clk, 
    reset => reset,
    inc_pc => inc_pc, 
    instr_bus => instr_bus, 
    wre => wre_in,
    begin_strb => begin_strb, 
    done_strb => done_strb, 
    alu_op => alu_op, 
    alu_mod => alu_mod,
    rd_sel => rd_sel, 
    rs1_sel => rs1_sel, 
    rs1_en  => rs1_en,
    rs2_sel => rs2_sel, 
    rs2_en => rs2_en,
    reg_wre => reg_wre,
    mem_busy => busy,
    immediate => immediate,
    imm_sel => imm_sel
  );

  MU: entity work.memory_unit(rtl)
  generic map(
    ADDR_WIDTH => ADDR_WIDTH,
    DATA_WIDTH => DATA_WIDTH
  )
  port map(
    address_in  => count,
    address_out => address_bus, 
    din_in      => din_in,
    din_out     => data_out,
    dout_in     => data_in,
    dout_out    => instr_bus,
    mem_en      => mem_en,
    wre_in      => wre_in,
    wre_out     => wre_out,
    clk         => clk,
    reset       => reset,
    begin_strb  => begin_strb,
    done_strb   => done_strb,
    busy        => busy
  );

  REGISTERS: entity work.registers_unit(rtl)
  generic map(
    REG_WIDTH => DATA_WIDTH
  )
  port map(
    clk => clk,
    reset => reset,
    rs1_en => rs1_en,
    rs2_en => rs2_en,
    rs1_sel => rs1_sel,
    rs2_sel => rs2_sel,
    rd_sel => rd_sel,
    rs1 => rs1,
    rs2 => rs2,
    rd => rd,
    wre => reg_wre 
  );

  PC: entity work.program_counter(rtl)
  port map(
    reset => reset,
    count => count,
    clk => clk,
    inc => inc_pc
  );

  ALU: entity work.alu(rtl)
  generic map(
    A_WIDTH => A_WIDTH,
    B_WIDTH => B_WIDTH,
    C_WIDTH => C_WIDTH
  )
  port map(
    a => rs1,
    b => mux_out,
    c => rd,
    op_select => alu_op,
    modifier => alu_mod
  );

  MUX: entity work.mux(rtl)
  generic map(
    DATA_WIDTH => DATA_WIDTH
  )
  port map(
    imm => immediate,
    reg => rs2,
    sel => imm_sel,
    outp => mux_out
  );

end architecture rtl;