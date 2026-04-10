library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
generic(
  ADDR_WIDTH : integer := 12;
  DATA_WIDTH : integer := 32
);
port(
  clk         : in std_logic;
  reset       : in std_logic;
  data_in     : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  address_out : out std_logic_vector(ADDR_WIDTH - 1 downto 0); 
  wre         : out std_logic;
  begin_strb  : out std_logic;
  done_strb   : in std_logic;
  alu_op      : out std_logic_vector(2 downto 0);
  alu_mod     : out std_logic;
  alu_in      : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  rd_sel      : out std_logic_vector(4 downto 0);
  rs1_sel     : out std_logic_vector(4 downto 0);
  rs1_en      : out std_logic;
  rs2_sel     : out std_logic_vector(4 downto 0);
  rs2_en      : out std_logic;
  reg_wre     : out std_logic;
  mem_busy    : in std_logic;
  mem_mask    : out std_logic_vector(1 downto 0);
  immediate   : out std_logic_vector(31 downto 0);
  imm_sel     : out std_logic
);
end entity control_unit;

architecture rtl of control_unit is
  signal instruction : std_logic_vector(31 downto 0);
  type state_t is (get_next_instruction, store_instruction, decode_instruction, execute, get_load_data, store_load_data, store_data, wait_store_data);
  signal state : state_t := get_next_instruction;
  signal address : std_logic_vector(ADDR_WIDTH - 1 downto 0);
  signal data    : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal inc_pc  : std_logic;
  signal count   : std_logic_vector(ADDR_WIDTH - 1 downto 0); 

  alias opcode : std_logic_vector(6 downto 0) is instruction(6 downto 0);
  alias rd : std_logic_vector(4 downto 0) is instruction(11 downto 7);
  alias funct3 : std_logic_vector(2 downto 0) is instruction(14 downto 12);
  alias rs1 : std_logic_vector(4 downto 0) is instruction(19 downto 15);
  alias rs2 : std_logic_vector(4 downto 0) is instruction(24 downto 20);
  alias imm_110 : std_logic_vector(11 downto 0) is instruction(31 downto 20);
  constant OP_IMM : std_logic_vector(6 downto 0) := "0010011";
  constant OP     : std_logic_vector(6 downto 0) := "0110011";
  constant LOAD   : std_logic_vector(6 downto 0) := "0000011";
  constant STORE  : std_logic_vector(6 downto 0) := "0100011";

  component program_counter is
  port(
    reset, clk, inc : in std_logic;
    count           : out std_logic_vector(ADDR_WIDTH - 1 downto 0)
  );
  end component program_counter;

begin 

  PC: program_counter
  port map(
    reset => reset,
    clk => clk, 
    inc => inc_pc,  
    count => count
  );

  process(clk, reset)
  begin
    if rising_edge(clk) and reset = '0' then
      case state is
        when get_next_instruction => 
          mem_mask <= "00";
          imm_sel <= '0';
          rs1_en <= '0';
          rs2_en <= '0';
          reg_wre <= '0';
          address_out <= count;
          wre <= '0';
          begin_strb <= '1';
          inc_pc <= '1';
          state <= store_instruction;
        
        when store_instruction => 
          begin_strb <= '0';
          inc_pc <= '0';
          if done_strb = '1' then
            instruction <= data_in;
            state <= decode_instruction;
          end if;

        when decode_instruction => 
          case opcode is
            when OP_IMM => 
              alu_op <= funct3;
              rs1_sel <= rs1;
              rs1_en <= '1';
              rd_sel <= rd;
              imm_sel <= '1';
              if funct3 = "001" or funct3 = "101" then
                immediate(4 downto 0) <= imm_110(4 downto 0);
                immediate(31 downto 5) <= (others => '0');
                alu_mod <= imm_110(10);
              else
                immediate(11 downto 0) <= imm_110;
                immediate(31 downto 12) <= (others => imm_110(11));
              end if;
              state <= execute;
            
            when OP => 
              alu_op <= funct3;
              rs1_sel <= rs1;
              rs1_en <= '1';
              rs2_sel <= rs2;
              rs2_en <= '1';
              rd_sel <= rd;
              alu_mod <= imm_110(10);
              state <= execute;
            
            when LOAD => 
              alu_op <= "000";
              rs1_sel <= rs1;
              rs1_en <= '1';
              rd_sel <= rd;
              imm_sel <= '1';
              immediate(11 downto 0) <= imm_110;
              immediate(31 downto 12) <= (others => imm_110(11));
              mem_mask <= "10" when (funct3 = "000" or funct3 = "100") else "01" when (funct3 = "001" or funct3 = "101") else "00" when funct3 = "010";
              state <= get_load_data;

            when STORE => 
              alu_op <= "000";
              rs1_sel <= rs1;
              rs1_en <= '1';
              rs2_sel <= rs2;
              rs2_en <= '1';
              rd_sel <= rd;
              imm_sel <= '1';
              immediate(11 downto 0) <= instruction(31 downto 25) & instruction(11 downto 7);
              immediate(31 downto 12) <= (others => instruction(31));
              mem_mask <= "10" when (funct3 = "000" or funct3 = "100") else "01" when (funct3 = "001" or funct3 = "101") else "00" when funct3 = "010";
              state <= store_data;
              
            when others => state <= get_next_instruction;

          end case;
        
        when store_data => 
          address_out <= alu_in(ADDR_WIDTH - 1 downto 0);
          wre <= '1';
          begin_strb <= '1';
          state <= wait_store_data;

        when wait_store_data => 
          begin_strb <= '0';
          if done_strb = '1' then
            state <= get_next_instruction;
          end if;

        when get_load_data => 
          address_out <= alu_in(ADDR_WIDTH - 1 downto 0);
          wre <= '0';
          begin_strb <= '1';
          state <= store_load_data;

        when store_load_data => 
          begin_strb <= '0';
          if done_strb = '1' then
            case funct3 is
              when "000" => 
                immediate(7 downto 0) <= data_in(7 downto 0);
                immediate(31 downto 8) <= (others => alu_in(7));
              when "001" => 
                immediate(15 downto 0) <= data_in(15 downto 0);
                immediate(31 downto 16) <= (others => alu_in(15));
              when "010" => 
                immediate <= data_in;
              when others => immediate <= data_in;
            end case;
            rs1_sel <= (others => '0');
            rs1_en <= '1';
            alu_op <= "000";
            imm_sel <= '1';
            rd_sel <= rd;
            state <= execute;
          end if;

        when execute => 
          reg_wre <= '1';
          state <= get_next_instruction;

        when others => state <= get_next_instruction;
      end case;
    elsif rising_edge(clk) and reset = '1' then
      inc_pc     <= '0';
      wre        <= '0';
      begin_strb <= '0';
      alu_op     <= (others => '0');
      rd_sel     <= (others => '0');
      rs1_sel    <= (others => '0');
      rs1_en     <= '0';
      rs2_sel    <= (others => '0');
      rs2_en     <= '0';
      reg_wre    <= '0';
      immediate  <= (others => '0');
      state      <= get_next_instruction;
      imm_sel    <= '0';
      alu_mod    <= '0';
      mem_mask   <= (others => '0');
    end if;
  end process;

end architecture rtl;