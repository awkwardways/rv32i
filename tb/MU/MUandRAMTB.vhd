library ieee;
use ieee.std_logic_1164.all;

entity muandramtb is
end entity muandramtb;

architecture sim of muandramtb is
  constant ADDR_WIDTH_TB : integer := 12;
  constant DATA_WIDTH_TB : integer := 32;
  constant CLK_FREQ      : integer := 20e6;
  constant CLK_PERIOD    : time    := 1000 ms / CLK_FREQ;

  --MU signals
  signal address_in_tb  : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0);
  signal address_out_tb : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0);
  signal din_in_tb      : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal din_out_tb     : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal dout_in_tb     : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal dout_out_tb    : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal mem_en_tb      : std_logic;
  signal wre_in_tb      : std_logic;
  signal wre_out_tb     : std_logic;
  signal clk_tb         : std_logic := '0';
  signal begin_strb_tb  : std_logic;
  signal done_strb_tb   : std_logic;
  signal busy_tb        : std_logic;
begin

  clk_tb <= not clk_tb after CLK_PERIOD / 2;

  MU: entity work.memory_unit(rtl)
  generic map(
    ADDR_WIDTH => ADDR_WIDTH_TB,
    DATA_WIDTH => DATA_WIDTH_TB
  )
  port map(
    address_in  => address_in_tb,
    address_out => address_out_tb, 
    din_in      => din_in_tb,
    din_out     => din_out_tb,
    dout_in     => dout_in_tb,
    dout_out    => dout_out_tb,
    mem_en      => mem_en_tb,
    wre_in      => wre_in_tb,
    wre_out     => wre_out_tb,
    clk         => clk_tb,
    begin_strb  => begin_strb_tb,
    done_strb   => done_strb_tb,
    busy        => busy_tb
  );

  UUT: entity work.ram(rtl)
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

  stimuli: process
  begin
    address_in_tb <= 12x"100";
    din_in_tb     <= x"0000fafa";
    wre_in_tb     <= '1';
    begin_strb_tb <= '1';
    wait on clk_tb;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    begin_strb_tb <= '0';
    wait for CLK_PERIOD;
    wre_in_tb <= '0';
    begin_strb_tb <= '1';
    wait for CLK_PERIOD;
    begin_strb_tb <= '0';
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    assert dout_out_tb = x"0000fafa" report "Write unsuccessful" severity failure;
    wait;
  end process stimuli;

end architecture sim;