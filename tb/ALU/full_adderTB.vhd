library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish; 

entity fullAdderTB is 
end entity fullAdderTB;

architecture testbench of fullAdderTB is
  signal a      : std_logic;
  signal b      : std_logic;
  signal c_in   : std_logic;
  signal c_out  : std_logic;
  signal s      : std_logic;
  signal enable : std_logic;
begin

  UUT: entity work.full_adder(behavioural) 
      port map(
        a      => a,
        b      => b,
        c_in   => c_in,
        c_out  => c_out,
        s      => s,
        enable => enable
      );

  stimulus: process
    variable abc_in : std_logic_vector(2 downto 0) := "000";
  begin
    enable <= '1';
    for i in 0 to 2**abc_in'length - 1 loop
      abc_in := std_logic_vector(to_unsigned(i, abc_in'length));
      a <= abc_in(abc_in'left);
      b <= abc_in(1);
      c_in <= abc_in(abc_in'right);
      wait for 10 ns;
    end loop;
    report "DISABLED TEST: OK";
    enable <= '0';
    for i in 0 to 2**abc_in'length - 1 loop
      abc_in := std_logic_vector(to_unsigned(i, abc_in'length));
      a <= abc_in(abc_in'left);
      b <= abc_in(1);
      c_in <= abc_in(abc_in'right);
      wait for 10 ns;
    end loop;
    report "ENABLED TEST: OK";
    finish;
  end process stimulus;

  selfCheck: process 
    variable temp : integer := 0;
  begin
    wait on a, b, c_in;
    wait for 1 ns;
    if enable = '1' then
      assert s = '0'
        report "s is 1 even though unit is disabled" severity failure;
      assert c_out = '0'
        report "c_out is 1 even though unit is disabled" severity failure;
    else
      if a = '1' then
        temp := temp + 1;
      end if;
      if b = '1' then 
        temp := temp + 1;
      end if;
      if c_in = '1' then 
        temp := temp + 1;
      end if;
      if temp > 1 then
        assert c_out = '1'
          report "sum is greater than 1 but c_out is not 1"
          severity failure;
      else
        assert c_out = '0'
          report "sum is less than or equal to one, but c_out is not 0"
          severity failure;
      end if;
      temp := 0;
    end if;

  end process selfCheck;
end architecture testbench;