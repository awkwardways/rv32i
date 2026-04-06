library ieee;
use ieee.std_logic_1164.all;

entity cpu_tb is
end entity cpu_tb;

architecture sim of cpu_tb is
  constant DATA_WIDTH_TB : integer                       := 32;
  constant ADDR_WIDTH_TB : integer                       := 12;
  constant CLK_FREQ      : integer                       := 20e6;
  constant CLK_PERIOD    : time                          := 1000 ms / CLK_FREQ;
  constant ADDI          : std_logic_vector(31 downto 0) := "10101000110100001000000010010011";
  constant SLTI          : std_logic_vector(31 downto 0) := "10101000111000001010000100010011";
  constant SLTIU         : std_logic_vector(31 downto 0) := "11111111111100001011000100010011";
  constant XORI          : std_logic_vector(31 downto 0) := "01010111001000001100000010010011";
  constant ORI           : std_logic_vector(31 downto 0) := "10101000110100000110000110010011";
  constant ANDI          : std_logic_vector(31 downto 0) := "10101000110100000111000010010011";
  constant SLLI          : std_logic_vector(31 downto 0) := "00000000111100010001100010010011";
  constant SRLI          : std_logic_vector(31 downto 0) := "00000000111110001101001000010011";
  constant SRAI          : std_logic_vector(31 downto 0) := "01000001111100011101001010010011";

  signal clk_tb          : std_logic := '0';
  signal reset_tb        : std_logic; 
  signal address_bus_tb  : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0);     
  signal data_out_tb     : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal data_in_tb      : std_logic_vector(DATA_WIDTH_TB - 1 downto 0); 
  signal mem_en_tb       : std_logic;
  signal wre_out_tb      : std_logic;
begin

  clk_tb <= not clk_tb after CLK_PERIOD / 2;

  UUT: entity work.cpu(rtl)
  generic map(
    DATA_WIDTH => DATA_WIDTH_TB,
    ADDR_WIDTH => ADDR_WIDTH_TB 
  )
  port map(
    clk => clk_tb, 
    reset => reset_tb,
    address_bus => address_bus_tb,
    data_out => data_out_tb,
    data_in => data_in_tb,
    mem_en => mem_en_tb,
    wre_out => wre_out_tb
  );
  
  stimuli: process
  begin
    reset_tb <= '1';
    wait until rising_edge(clk_tb);
    reset_tb <= '0';
    data_in_tb <= ADDI;
    wait for 8 * CLK_PERIOD;
    data_in_tb <= SLTI;
    wait for 8 * CLK_PERIOD;
    data_in_tb <= SLTIU;
    wait for 8 * CLK_PERIOD;
    data_in_tb <= XORI;
    wait for 8 * CLK_PERIOD;
    data_in_tb <= ORI;
    wait for 8 * CLK_PERIOD;
    data_in_tb <= ANDI;
    wait for 8 * CLK_PERIOD;
    data_in_tb <= SLLI;
    wait for 8 * CLK_PERIOD;
    data_in_tb <= SRLI;
    wait for 8 * CLK_PERIOD;
    data_in_tb <= SRAI;
    wait;
  end process stimuli;

end architecture;