library ieee;
use ieee.std_logic_1164.all;

entity ALU is 
  generic (
    A_WIDTH         : integer := 32;
    B_WIDTH         : integer := 32;
    S_WIDTH         : integer := 32;
    OP_SELECT_WIDTH : integer := 10
  );
  port (
    a_in      : in std_logic_vector(A_WIDTH - 1 downto 0);
    b_in      : in std_logic_vector(B_WIDTH - 1 downto 0);
    c_in      : in std_logic;
    c_out     : out std_logic;
    s         : out std_logic_vector(S_WIDTH - 1 downto 0);
    op_select : in std_logic_vector(OP_SELECT_WIDTH - 1 downto 0);
    enable    : in std_logic
  );
end entity ALU;

architecture behavioural of ALU is
  component full_adder is 
  port (
    a, b, c_in, enable : in std_logic;
    c_out, s           : out std_logic
  );
  end component full_adder;
  signal carry_vector : std_logic_vector(S_WIDTH downto 0) := (others => '0');
  signal a_buffer_out : std_logic_vector(A_WIDTH - 1 downto 0);
  signal b_buffer_out : std_logic_vector(B_WIDTH - 1 downto 0);
  signal enable_adder : std_Logic;
  signal shifter_dir  : std_logic;
  signal shifter_type : std_logic;
  signal shifter_en   : std_logic;

  constant SHIFTER_DATA_WIDTH : integer := 32;
  constant SHIFTER_AMNT_WIDTH : integer := 5;

  alias compl_a_buffer : std_logic is op_select(0);
  alias compl_b_buffer : std_logic is op_select(1);
  alias operation      : std_logic_vector(7 downto 0) is op_select(op_select'left downto 2);
begin

  enable_adder <= '0' when operation = x"00" and enable = '0' else '1';
  shifter_dir <= '1' when operation = x"10" or operation = x"20" else '0' when operation = x"11" or operation = x"21";
  shifter_type <= '1' when operation = x"10" or operation = x"11" else '0' when operation = x"20" or operation = x"21";
  shifter_en <=  '0' when (operation = x"10" or operation = x"11" or operation = x"20" or operation = x"21") else '1';

  a_buffer: entity work.twoscomp_buffer(behavioural)
  generic map(
    BUFFER_WIDTH => A_WIDTH
  )
  port map(
    a => a_in,
    b => a_buffer_out,
    complement => compl_a_buffer
  );

  b_buffer: entity work.twoscomp_buffer(behavioural)
  generic map(
    BUFFER_WIDTH => A_WIDTH
  )
  port map(
    a => b_in,
    b => b_buffer_out,
    complement => compl_b_buffer
  );

  carry_vector(0) <= c_in;
  c_out <= carry_vector(carry_vector'left);
  gen: for i in 0 to 31 generate
    w_adder : full_adder port map(
      a => a_buffer_out(i),
      b => b_buffer_out(i),
      s => s(i),
      c_in => carry_vector(i),
      c_out => carry_vector(i + 1),
      enable => enable_adder
    );
  end generate;

  shifter: entity work.shifter(behavioural)
  generic map(
    DATA_WIDTH => SHIFTER_DATA_WIDTH,
    AMNT_WIDTH => SHIFTER_AMNT_WIDTH
  )
  port map(
    data => a_in,
    amnt => b_in(SHIFTER_AMNT_WIDTH - 1 downto 0),
    dir  => shifter_dir,
    shft => shifter_type,
    enable => shifter_en,
    rslt => s
  );

end architecture behavioural;