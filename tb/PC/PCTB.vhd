library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PCTB is 
end entity PCTB;

architecture sim of PCTB is
  constant PC_WIDTH_TB : integer := 32;
  constant CLK_FREQ    : integer := 20e6;
  constant CLK_PERIOD  : time    := 1000 ms / CLK_FREQ;

  signal clk_tb    : std_logic := '0';
  signal inc_tb    : std_logic;
  signal pc_out_tb : std_logic_vector(PC_WIDTH_TB - 1 downto 0);
  signal incbo_tb  : std_logic;
  signal offset_tb : std_logic_vector(PC_WIDTH_TB - 1 downto 0);
  signal rst_tb    : std_logic;
begin

  UUT: entity work.PC(rtl)
  generic map(
    PC_WIDTH => PC_WIDTH_TB
  )
  port map(
    clk => clk_tb,
    inc => inc_tb,
    pc_out => pc_out_tb,
    incbo => incbo_tb,
    offset => offset_tb,
    rst => rst_tb
  );

  clk_tb <= not clk_tb after CLK_PERIOD;

  stimuli: process
  begin
    rst_tb <= '1';
    wait on clk_tb;
    wait for 10 ns;
    assert pc_out_tb = 32x"0" report "Not reseting correctly" severity failure;
    rst_tb <= '0';
    inc_tb <= '1';
    incbo_tb <= '0';
    offset_tb <= (others => '0');
    wait on clk_tb;
    wait on clk_tb;
    wait for 10 ns;
    assert pc_out_tb = 32x"1" report "Not incrementing correctly" severity failure;
    incbo_tb <= '1';
    offset_tb <= 32x"fffffffe";
    wait on clk_tb;
    wait on clk_tb;
    wait for 10 ns;
    assert pc_out_tb = 32x"ffffffff" report "Offset increment not functioning correctly" severity failure;
    incbo_tb <= '0';
    wait on clk_tb;
    wait on clk_tb;
    wait for 10 ns;
    assert pc_out_tb = 32x"0" report "Offset increment not overflowing correctly" severity failure;
    wait; 
  end process stimuli;

end architecture sim;