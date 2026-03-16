library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity twoscomp_bufferTB is
end entity twoscomp_bufferTB;

architecture sim of twoscomp_bufferTB is
  constant BUFFER_WIDTH_TB : integer := 32;
  signal a_tb : std_logic_vector(BUFFER_WIDTH_TB - 1 downto 0);
  signal b_tb : std_logic_vector(BUFFER_WIDTH_TB - 1 downto 0);
  signal complement_tb : std_logic;
begin

  UUT: entity work.twoscomp_buffer(behavioural)
  generic map(
    BUFFER_WIDTH => BUFFER_WIDTH_TB
  )
  port map(
    a => a_tb,
    b => b_tb,
    complement => complement_tb
  );

  stimuli: process
  begin
    a_tb <= 32x"6";
    complement_tb <= '0';
    wait for 10 ns;
    assert b_tb = std_logic_vector(not unsigned(a_tb) + 1) report "Twos complement not performed correctly on non overflowing integer" severity failure;
    complement_tb <= '1';
    wait for 10 ns;
    assert b_tb = a_tb report "Buffer not letting signal through" severity failure;
    a_tb <= x"fffffffe";
    complement_tb <= '0';
    wait for 10 ns;
    assert b_tb = std_logic_vector(not unsigned(a_tb) + 1) report "Twos complement not performed correctly on overflowing integer" severity failure;
    complement_tb <= '1';
    wait for 10 ns;
    assert b_tb = a_tb report "Buffer not letting signal through" severity failure;
    report "2'S COMPLEMENT BUFFER: Ok!";
    finish;
  end process stimuli;

end architecture sim;