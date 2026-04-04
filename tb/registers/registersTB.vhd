library ieee;
use ieee.std_logic_1164.all;

entity registerstb is 
end entity registerstb;

architecture sim of registerstb is 
  constant CLK_FREQ   : integer := 20e6;
  constant CLK_PERIOD : time    := 1000 ms / CLK_FREQ;
  constant REG_WIDTH_TB  : integer := 32;

  signal clk_tb : std_logic := '0';
  signal rs1_en_tb : std_logic;
  signal rs2_en_tb : std_logic;
  signal rs1_sel_tb : std_logic_vector(4 downto 0);
  signal rs2_sel_tb : std_logic_vector(4 downto 0);
  signal rd_sel_tb : std_logic_vector(4 downto 0);
  signal rs1_tb : std_logic_vector(REG_WIDTH_TB - 1 downto 0);
  signal rs2_tb : std_logic_vector(REG_WIDTH_TB - 1 downto 0);
  signal rd_tb : std_logic_vector(REG_WIDTH_TB - 1 downto 0);
  signal wre_tb : std_logic;
begin

  clk_tb <= not clk_tb after CLK_PERIOD / 2;

  UUT: entity work.registers_unit(rtl)
  generic map(
    REG_WIDTH => REG_WIDTH_TB
  )
  port map(
    clk => clk_tb,
    rs1_en => rs1_en_tb,
    rs2_en => rs2_en_tb,
    rs1_sel => rs1_sel_tb,
    rs2_sel => rs2_sel_tb,
    rd_sel => rd_sel_tb,
    rs1 => rs1_tb,
    rs2 => rs2_tb,
    rd => rd_tb,
    wre => wre_tb
  );

  stimuli: process
  begin
    rs1_en_tb <= '1';
    rs2_en_tb <= '1';
    rs1_sel_tb <= "00001";
    rs2_sel_tb <= "00000";
    rd_sel_tb  <= "00001";
    wre_tb <= '0';
    wait until rising_edge(clk_tb);
    rd_tb <= x"fafa0303";
    wre_tb <= '1';
    wait until rising_edge(clk_tb);
    wre_tb <= '0';
    wait until rising_edge(clk_tb);
    rd_tb <= x"ffffffff";
    rd_sel_tb <= "00000";
    wre_tb <= '1';
    wait until rising_edge(clk_tb);
    wre_tb <= '0';
    wait;
  end process stimuli;

end architecture sim;