library ieee;
use ieee.std_logic_1164.all;

entity control_unit_tb is
end entity control_unit_tb;

architecture sim of control_unit_tb is 
  constant ADDR_WIDTH_TB : integer := 12;
  constant DATA_WIDTH_TB : integer := 32;
  constant CLK_FREQ      : integer := 20e6;
  constant CLK_PERIOD    : time    := 1000 ms / CLK_FREQ;
  constant A_WIDTH_TB    : integer := 32;
  constant B_WIDTH_TB    : integer := 32;
  constant C_WIDTH_TB    : integer := 32;
  constant REG_WIDTH_TB  : integer := 32;

  signal clk_tb         : std_logic := '0';
  signal inc_pc_tb      : std_logic;
  signal instr_bus_tb   : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal begin_strb_tb  : std_logic;
  signal done_strb_tb   : std_logic;
  signal alu_op_tb      : std_logic_vector(2 downto 0);
  signal alu_mod_tb     : std_logic;
  signal rd_sel_tb      : std_logic_vector(4 downto 0);
  signal rd_tb          : std_logic_vector(REG_WIDTH_TB - 1 downto 0);
  signal rs1_sel_tb     : std_logic_vector(4 downto 0);
  signal rs1_tb         : std_logic_vector(REG_WIDTH_TB - 1 downto 0);
  signal rs1_en_tb      : std_logic;
  signal rs2_sel_tb     : std_logic_vector(4 downto 0);
  signal rs2_tb         : std_logic_vector(REG_WIDTH_TB - 1 downto 0);
  signal rs2_en_tb      : std_logic;
  signal count_tb       : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0);
  signal address_out_tb : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0);
  signal din_in_tb      : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal din_out_tb     : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal dout_in_tb     : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal mem_en_tb      : std_logic;
  signal wre_in_tb      : std_logic;
  signal wre_out_tb     : std_logic;
  signal busy_tb        : std_logic;
  signal reset_tb       : std_logic;
  signal reg_wre_tb     : std_logic;
  signal immediate_tb   : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal imm_sel_tb     : std_logic;
  signal mux_out_tb     : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);

begin

  clk_tb <= not clk_tb after CLK_PERIOD / 2;

  UUT: entity work.control_unit(rtl)
  port map(
    clk => clk_tb, 
    reset => reset_tb,
    inc_pc => inc_pc_tb, 
    instr_bus => instr_bus_tb, 
    wre => wre_in_tb,
    begin_strb => begin_strb_tb, 
    done_strb => done_strb_tb, 
    alu_op => alu_op_tb, 
    alu_mod => alu_mod_tb,
    rd_sel => rd_sel_tb, 
    rs1_sel => rs1_sel_tb, 
    rs1_en  => rs1_en_tb,
    rs2_sel => rs2_sel_tb, 
    rs2_en => rs2_en_tb,
    reg_wre => reg_wre_tb,
    mem_busy => busy_tb,
    immediate => immediate_tb,
    imm_sel => imm_sel_tb
  );

  PC: entity work.program_counter(rtl)
  port map(
    reset => '0',
    count => count_tb,
    clk => clk_tb,
    inc => inc_pc_tb
  );

  MU: entity work.memory_unit(rtl)
  generic map(
    ADDR_WIDTH => ADDR_WIDTH_TB,
    DATA_WIDTH => DATA_WIDTH_TB
  )
  port map(
    address_in  => count_tb,
    address_out => address_out_tb, 
    din_in      => din_in_tb,
    din_out     => din_out_tb,
    dout_in     => dout_in_tb,
    dout_out    => instr_bus_tb,
    mem_en      => mem_en_tb,
    wre_in      => wre_in_tb,
    wre_out     => wre_out_tb,
    clk         => clk_tb,
    reset       => reset_tb,
    begin_strb  => begin_strb_tb,
    done_strb   => done_strb_tb,
    busy        => busy_tb
  );

  RAM: entity work.ram(rtl)
  generic map(
    ADDR_WIDTH => ADDR_WIDTH_TB,
    DATA_WIDTH => DATA_WIDTH_TB
  )
  port map(
    address => address_out_tb,
    din => din_out_tb,
    dout => dout_in_tb,
    en => mem_en_tb,
    wre => wre_out_tb,
    clk => clk_tb
  );

  REGISTERS: entity work.registers_unit(rtl)
  generic map(
    REG_WIDTH => REG_WIDTH_TB
  )
  port map(
    clk => clk_tb,
    reset => reset_tb,
    rs1_en => rs1_en_tb,
    rs2_en => rs2_en_tb,
    rs1_sel => rs1_sel_tb,
    rs2_sel => rs2_sel_tb,
    rd_sel => rd_sel_tb,
    rs1 => rs1_tb,
    rs2 => rs2_tb,
    rd => rd_tb,
    wre => reg_wre_tb 
  );

  MUX: entity work.mux(rtl)
  generic map(
    DATA_WIDTH => DATA_WIDTH_TB
  )
  port map(
    imm => immediate_tb,
    reg => rs2_tb,
    sel => imm_sel_tb,
    outp => mux_out_tb
  );

  ALU: entity work.alu(rtl)
  generic map(
    A_WIDTH => A_WIDTH_TB,
    B_WIDTH => B_WIDTH_TB,
    C_WIDTH => C_WIDTH_TB
  )
  port map(
    a => rs1_tb,
    b => mux_out_tb,
    c => rd_tb,
    op_select => alu_op_tb,
    modifier => alu_mod_tb
  );

  stimuli: process
  begin
    reset_tb <= '1';
    wait until rising_edge(clk_tb);
    reset_tb <= '0';
    wait;
  end process;

end architecture sim;