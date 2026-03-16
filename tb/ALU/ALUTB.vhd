library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity ALUTB is
end entity ALUTB;

architecture sim of ALUTB is 
  signal a_tb      : std_logic_vector(31 downto 0);
  signal b_tb      : std_logic_vector(31 downto 0);
  signal s_tb      : std_logic_vector(31 downto 0);
  signal c_in_tb   : std_logic;
  signal c_out_tb  : std_logic;
  signal op_sel_tb : std_logic_vector(9 downto 0);
  signal enable_tb : std_logic;

begin



  UUT: entity work.ALU(behavioural)
  port map(
    a_in => a_tb,
    b_in => b_tb, 
    c_in => c_in_tb,
    c_out => c_out_tb,
    s => s_tb,
    op_select => op_sel_tb,
    enable => enable_tb
  );

  stimuli: process
    variable a_state : unsigned(31 downto 0);
    variable b_state : unsigned(31 downto 0);
  begin

    op_sel_tb <= 10x"03";
    --Sum test
    enable_tb <= '0';
    a_state := x"7f034100";
    b_state := x"101148fb";
    a_tb <= std_logic_vector(a_state);
    b_tb <= std_logic_vector(b_state);
    c_in_tb <= '0';
    wait for 2 ns;
    assert s_tb = x"8f1489fb" report "ALU TEST: Adder is not summing correctly, 0x7f034100 + 0x101148fb does not yield expected 0x8f1489fb" severity failure;
    c_in_tb <= '1';
    wait for 2 ns;
    assert s_tb = x"8f1489fc" report "ALU TEST: Adder is not summing correctly, 0x7f034100 + 0x101148fb + Cin does not yield expected 0x8f1489fc" severity failure;

    --Sum with carry test
    a_state := x"f81400aa";
    b_state := x"21f5112b";
    a_tb <= std_logic_vector(a_state);
    b_tb <= std_logic_vector(b_state);
    c_in_tb <= '0';
    wait for 2 ns;
    assert s_tb = x"1a0911d5" and c_out_tb = '1' report "ALU TEST: Adder is not summing correctly, 0xf81400aa + 0x21f5112b does not yield expected output. c_out is " /* & std_logic'image(c_out_tb) & ". s is" & std_logic_vector(s_tb)'image */ severity failure;
    c_in_tb <= '1';
    wait for 2 ns;
    assert s_tb = x"1a0911d6" and c_out_tb = '1' report "ALU TEST: Adder is not summing correctly, 0xf81400aa + 0x21f5112b does not yield expected output. c_out is " /* & std_logic'image(c_out_tb) & ". s is" & std_logic_vector(s_tb)'image */ severity failure;
    report "ALU TEST: ADDER ENABLED Ok!";

    --Disabled test
    --enable_tb <= '1';
    --a_state := x"7f034100";
    --b_state := x"101148fb";
    --a_tb <= std_logic_vector(a_state);
    --b_tb <= std_logic_vector(b_state);
    --c_in_tb <= '0';
    --wait for 2 ns;
    --assert s_tb = 32x"Z" and c_out_tb = '0' report "ALU TEST: Adder is not getting disabled. Sum performed." severity failure;
    --c_in_tb <= '1';
    --wait for 2 ns;
    --assert s_tb = 32x"Z" and c_out_tb = '0' report "ALU TEST: Adder is not getting disabled when Cin is set. Sum performed." severity failure;

    --Sum with carry test
    --a_state := x"f81400aa";
    --b_state := x"21f5112b";
    --a_tb <= std_logic_vector(a_state);
    --b_tb <= std_logic_vector(b_state);
    --c_in_tb <= '0';
    --wait for 2 ns;
    --assert s_tb = 32x"Z" and c_out_tb = '0' report "ALU TEST: Adder is not getting disabled. Sum performed " /* & c_out'image & ". s is" & s'image */ severity failure;
    --c_in_tb <= '1';
    --wait for 2 ns;
    --assert s_tb = 32x"Z" and c_out_tb = '0' report "ALU TEST: Adder is not getting disabled. Sum performed " /* & c_out'image & ". s is" & s'image */ severity failure;
    --report "ALU TEST: ADDER DISABLED Ok!";
    
    --Signed operations test
    enable_tb <= '0';
    a_state := 32x"1";
    b_state := 32x"1";
    a_tb <= std_logic_vector(a_state);
    b_tb <= std_logic_vector(b_state);
    c_in_tb <= '0';
    op_sel_tb <= 10x"01";
    wait for 2 ns;
    assert s_tb = 32x"0" report "ALU TEST: Signed operation not being performed correctly" severity failure;
    a_state := 32x"1";
    b_state := 32x"1";
    a_tb <= std_logic_vector(a_state);
    b_tb <= std_logic_vector(b_state);
    c_in_tb <= '0';
    op_sel_tb <= 10x"00";
    wait for 2 ns;
    assert s_tb = x"fffffffe" report "ALU TEST: Signed operation not being performed correctly" severity failure;
    a_state := 32x"3";
    b_state := 32x"1";
    a_tb <= std_logic_vector(a_state);
    b_tb <= std_logic_vector(b_state);
    c_in_tb <= '0';
    op_sel_tb <= 10x"02";
    wait for 2 ns;
    assert s_tb = x"fffffffe" report "ALU TEST: Signed operation not being performed correctly" severity failure;
    report "ALU TEST: SIGNED OPERATIONS Ok!";

    -- Shift operations test
    a_state := x"00000005";
    b_state := 32x"2";
    a_tb <= std_logic_vector(a_state);
    b_tb <= std_logic_vector(b_state);
    op_sel_tb <= 10x"40";
    wait for 2 ns;
    assert s_tb = x"00000014" report "Left shift performed unsuccesfully" severity failure;
    a_state := x"ffffffff";
    b_state := 32x"1f";
    a_tb <= std_logic_vector(a_state);
    b_tb <= std_logic_vector(b_state);
    op_sel_tb <= 10x"40";
    wait for 2 ns;
    assert s_tb = x"80000000" report "Left shift performed unsuccesfully" severity failure;

    a_state := x"00000005";
    b_state := 32x"2";
    a_tb <= std_logic_vector(a_state);
    b_tb <= std_logic_vector(b_state);
    op_sel_tb <= 10x"44";
    wait for 2 ns;
    assert s_tb = x"00000001" report "Left shift performed unsuccesfully" severity failure;
    a_state := x"ffffffff";
    b_state := 32x"1f";
    a_tb <= std_logic_vector(a_state);
    b_tb <= std_logic_vector(b_state);
    op_sel_tb <= 10x"44";
    wait for 2 ns;
    assert s_tb = x"00000001" report "Left shift performed unsuccesfully" severity failure;
    finish;

  end process stimuli;

end architecture sim;