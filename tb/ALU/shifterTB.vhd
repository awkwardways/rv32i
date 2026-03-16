library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity shifterTB is
end entity shifterTB;

architecture sim of shifterTB is
  constant DATA_WIDTH_TB : integer := 32;
  constant AMNT_WIDTH_TB : integer := 5;
  signal data_tb   : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal amnt_tb   : std_logic_vector(AMNT_WIDTH_TB - 1 downto 0);
  signal dir_tb    : std_logic;
  signal shft_tb   : std_logic;
  signal enable_tb : std_logic;
  signal rslt_tb   : std_logic_vector(DATA_WIDTH_TB - 1 downto 0); 
begin

  UUT: entity work.shifter(behavioural)
  generic map(
    DATA_WIDTH => DATA_WIDTH_TB,
    AMNT_WIDTH => AMNT_WIDTH_TB
  )
  port map(
    data   => data_tb,
    amnt   => amnt_tb,
    dir    => dir_tb,
    shft   => shft_tb,
    enable => enable_tb,
    rslt   => rslt_tb  
  );

  stimuli: process
  begin
    --Left shift test
    data_tb <= x"00000005";
    amnt_tb <= 5x"2";
    dir_tb <= '1';
    shft_tb <= '0';
    enable_tb <= '0';
    wait for 2 ns;
    assert rslt_tb = x"00000014" report "Left shift performed unsuccesfully" severity failure;
    data_tb <= x"ffffffff";
    amnt_tb <= 5x"1f";
    dir_tb <= '1';
    shft_tb <= '0';
    enable_tb <= '0';
    wait for 2 ns;
    assert rslt_tb = x"80000000" report "Left shift performed unsuccesfully" severity failure;

    --Left shift test
    data_tb <= x"00000005";
    amnt_tb <= 5x"2";
    dir_tb <= '0';
    shft_tb <= '0';
    enable_tb <= '0';
    wait for 2 ns;
    assert rslt_tb = x"00000001" report "Left shift performed unsuccesfully" severity failure;
    data_tb <= x"ffffffff";
    amnt_tb <= 5x"1f";
    dir_tb <= '0';
    shft_tb <= '0';
    enable_tb <= '0';
    wait for 2 ns;
    assert rslt_tb = x"00000001" report "Left shift performed unsuccesfully" severity failure;
    finish;
  end process;

end architecture sim;