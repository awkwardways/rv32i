library ieee;
use ieee.std_logic_1164.all;

entity memory_unit is
generic(
  ADDR_WIDTH : integer := 32;
  DATA_WIDTH : integer := 32
);
port(
  address_in  : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  address_out : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
  din_in      : in std_logic_vector(DATA_WIDTH - 1 downto 0); 
  din_out     : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  dout_in     : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  dout_out    : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  mem_en      : out std_logic;
  wre_in      : in std_logic;
  wre_out     : out std_logic;
  clk         : in std_logic;
  begin_strb  : in std_logic;
  done_strb   : out std_logic;
  busy        : out std_logic
);
end entity memory_unit;

architecture rtl of memory_unit is
  type state_t is (idle, grab, acknowledge, undo);
  signal state : state_t := idle;
begin
  
  dout_out <= dout_in;

  process(clk, begin_strb, address_in, din_in)
  begin
    if rising_edge(clk) then
      case state is
        when idle => 
          if begin_strb = '1' then
            wre_out <= wre_in;
            address_out <= address_in;
            mem_en <= '1';
            busy <= '1';
            if wre_in = '1' then
              din_out <= din_in;
            end if;
            state <= grab;
          end if;

        when grab => 
          state <= acknowledge;

        when acknowledge =>
          if wre_in = '0' then
          end if; 
          done_strb <= '1';
          mem_en <= '0';
          state <= undo;
        
        when undo => 
          done_strb <= '0';
          busy <= '0';
          state <= idle;
      end case;
    end if;
  end process;

end architecture rtl;