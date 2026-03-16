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
  signal a_comp       : std_logic;
  signal b_buffer_out : std_logic_vector(B_WIDTH - 1 downto 0);
  signal b_comp       : std_logic;
begin

  a_comp <= op_select(0) and op_select(1);
  b_comp <= op_select(2) and op_select(3); 

  a_buffer: entity work.twoscomp_buffer(behavioural)
  generic map(
    BUFFER_WIDTH => A_WIDTH
  )
  port map(
    a => a_in,
    b => a_buffer_out,
    complement => a_comp
  );

  b_buffer: entity work.twoscomp_buffer(behavioural)
  generic map(
    BUFFER_WIDTH => A_WIDTH
  )
  port map(
    a => b_in,
    b => b_buffer_out,
    complement => b_comp
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
      enable => enable
    );
  end generate;

end architecture behavioural;