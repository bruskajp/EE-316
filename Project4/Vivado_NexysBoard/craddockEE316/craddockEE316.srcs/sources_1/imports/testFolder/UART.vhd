---- UART code taken from http://www.bealto.com/fpga-uart.html
--        -- Eric Bainville
--        -- Mar 2013

--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
--library work;
--use work.math_real.all;

--entity basic_uart is
--  generic (
--    DIVISOR: natural := 54  -- DIVISOR = 100,000,000 / (16 x BAUD_RATE)
--    -- 2400 -> 2604
--    -- 9600 -> 651
--    -- 115200 -> 54
--    -- 1562500 -> 4
--    -- 2083333 -> 3
--  );
--  port (
--    clk: in std_logic;                         -- clock
--    reset: in std_logic;                       -- reset
    
--    -- Client interface
--    rx_data: out std_logic_vector(7 downto 0); -- received byte
--    rx_enable: out std_logic;                  -- validates received byte (1 system clock spike)
--    tx_data: in std_logic_vector(7 downto 0);  -- byte to send
--    tx_enable: in std_logic;                   -- validates byte to send if tx_ready is '1'
--    tx_ready: out std_logic;                   -- if '1', we can send a new byte, otherwise we won't take it
    
--    -- Physical interface
--    rx: in std_logic;
--    tx: out std_logic
--  );
--end basic_uart;

--architecture Behavioral of basic_uart is
--  constant COUNTER_BITS : natural := integer(ceil(log(2,real(DIVISOR))));
--  type fsm_state_t is (idle, active); -- common to both RX and TX FSM
--  type rx_state_t is
--  record
--    fsm_state: fsm_state_t;                -- FSM state
--    counter: std_logic_vector(3 downto 0); -- tick count
--    bits: std_logic_vector(7 downto 0);    -- received bits
--    nbits: std_logic_vector(3 downto 0);   -- number of received bits (includes start bit)
--    enable: std_logic;                     -- signal we received a new byte
--  end record;
--  type tx_state_t is
--  record
--    fsm_state: fsm_state_t; -- FSM state
--    counter: std_logic_vector(3 downto 0); -- tick count
--    bits: std_logic_vector(8 downto 0); -- bits to emit, includes start bit
--    nbits: std_logic_vector(3 downto 0); -- number of bits left to send
--    ready: std_logic; -- signal we are accepting a new byte
--  end record;
  
--  signal rx_state,rx_state_next: rx_state_t;
--  signal tx_state,tx_state_next: tx_state_t;
--  signal sample: std_logic; -- 1 clk spike at 16x baud rate
--  signal sample_counter: std_logic_vector(COUNTER_BITS-1 downto 0); -- should fit values in 0..DIVISOR-1
  
--begin

--  -- sample signal at 16x baud rate, 1 CLK spikes
--  sample_process: process (clk,reset) is
--  begin
--    if reset = '1' then
--      sample_counter <= (others => '0');
--      sample <= '0';
--    elsif rising_edge(clk) then
--      if sample_counter = DIVISOR-1 then
--        sample <= '1';
--        sample_counter <= (others => '0');
--      else
--        sample <= '0';
--        sample_counter <= sample_counter + 1;
--      end if;
--    end if;
--  end process;

--  -- RX, TX state registers update at each CLK, and RESET
--  reg_process: process (clk,reset) is
--  begin
--    if reset = '1' then
--      rx_state.fsm_state <= idle;
--      rx_state.bits <= (others => '0');
--      rx_state.nbits <= (others => '0');
--      rx_state.enable <= '0';
--      tx_state.fsm_state <= idle;
--      tx_state.bits <= (others => '1');
--      tx_state.nbits <= (others => '0');
--      tx_state.ready <= '1';
--    elsif rising_edge(clk) then
--      rx_state <= rx_state_next;
--      tx_state <= tx_state_next;
--    end if;
--  end process;
  
--  -- RX FSM
--  rx_process: process (rx_state,sample,rx) is
--  begin
--    case rx_state.fsm_state is
    
--    when idle =>
--      rx_state_next.counter <= (others => '0');
--      rx_state_next.bits <= (others => '0');
--      rx_state_next.nbits <= (others => '0');
--      rx_state_next.enable <= '0';
--      if rx = '0' then
--        -- start a new byte
--        rx_state_next.fsm_state <= active;
--      else
--        -- keep idle
--        rx_state_next.fsm_state <= idle;
--      end if;
      
--    when active =>
--      rx_state_next <= rx_state;
--      if sample = '1' then
--        if rx_state.counter = 8 then
--          -- sample next RX bit (at the middle of the counter cycle)
--          if rx_state.nbits = 9 then
--            rx_state_next.fsm_state <= idle; -- back to idle state to wait for next start bit
--            rx_state_next.enable <= rx; -- OK if stop bit is '1'
--          else
--            rx_state_next.bits <= rx & rx_state.bits(7 downto 1);
--            rx_state_next.nbits <= rx_state.nbits + 1;
--          end if;
--        end if;
--        rx_state_next.counter <= rx_state.counter + 1;
--      end if;
      
--    end case;
--  end process;
  
--  -- RX output
--  rx_output: process (rx_state) is
--  begin
--    rx_enable <= rx_state.enable;
--    rx_data <= rx_state.bits;
--  end process;
  
--  -- TX FSM
--  tx_process: process (tx_state,sample,tx_enable,tx_data) is
--  begin
--    case tx_state.fsm_state is
    
--    when idle =>
--      if tx_enable = '1' then
--        -- start a new bit
--        tx_state_next.bits <= tx_data & '0';  -- data & start
--        tx_state_next.nbits <= "0000" + 10; -- send 10 bits (includes '1' stop bit)
--        tx_state_next.counter <= (others => '0');
--        tx_state_next.fsm_state <= active;
--        tx_state_next.ready <= '0';
--      else
--        -- keep idle
--        tx_state_next.bits <= (others => '1');
--        tx_state_next.nbits <= (others => '0');
--        tx_state_next.counter <= (others => '0');
--        tx_state_next.fsm_state <= idle;
--        tx_state_next.ready <= '1';
--      end if;
      
--    when active =>
--      tx_state_next <= tx_state;
--      if sample = '1' then
--        if tx_state.counter = 15 then
--          -- send next bit
--          if tx_state.nbits = 0 then
--            -- turn idle
--            tx_state_next.bits <= (others => '1');
--            tx_state_next.nbits <= (others => '0');
--            tx_state_next.counter <= (others => '0');
--            tx_state_next.fsm_state <= idle;
--            tx_state_next.ready <= '1';
--          else
--            tx_state_next.bits <= '1' & tx_state.bits(8 downto 1);
--            tx_state_next.nbits <= tx_state.nbits - 1;
--          end if;
--        end if;
--        tx_state_next.counter <= tx_state.counter + 1;
--      end if;
      
--    end case;
--  end process;

--  -- TX output
--  tx_output: process (tx_state) is
--  begin
--    tx_ready <= tx_state.ready;
--    tx <= tx_state.bits(0);
--  end process;

--end Behavioral;
library ieee;
     use ieee.std_logic_1164.all;
     use ieee.std_logic_unsigned.all;
 
 entity uart is
     port (
         reset       :in  std_logic;
         txclk       :in  std_logic;
         ld_tx_data  :in  std_logic;
         tx_data     :in  std_logic_vector (7 downto 0);
         tx_enable   :in  std_logic;
         selCheck    :in std_logic_vector(1 downto 0);
         tx_out      :out std_logic;
         tx_empty    :out std_logic;
         rxclk       :in  std_logic;
         uld_rx_data :in  std_logic;
         rx_data     :out std_logic_vector (7 downto 0);
         rx_enable   :in  std_logic;
         rx_in       :in  std_logic;
         rx_empty    :out std_logic
     );
 end entity;
 architecture rtl of uart is
    -- Internal Variables
     signal tx_reg         :std_logic_vector (7 downto 0);
     signal tx_over_run    :std_logic;
     signal tx_cnt         :std_logic_vector (3 downto 0);
     signal rx_reg         :std_logic_vector (7 downto 0);
     signal rx_sample_cnt  :std_logic_vector (3 downto 0);
     signal rx_cnt         :std_logic_vector (3 downto 0);
     signal rx_frame_err   :std_logic;
     signal rx_over_run    :std_logic;
     signal rx_d1          :std_logic;
     signal rx_d2          :std_logic;
     signal rx_busy        :std_logic;
     signal rx_is_empty    :std_logic;
     signal tx_is_empty    :std_logic;
 begin
    -- UART RX Logic
     process (rxclk, reset,selCheck) begin
         if (reset = '1') then
             rx_reg        <= (others=>'0');
             rx_data       <= (others=>'0');
             rx_sample_cnt <= (others=>'0');
             rx_cnt        <= (others=>'0');
             rx_frame_err  <= '0';
             rx_over_run   <= '0';
             rx_is_empty   <= '1';
             rx_d1         <= '1';
             rx_d2         <= '1';
             rx_busy       <= '0';
         elsif (rising_edge(rxclk)) then
            -- Synchronize the asynch signal
             rx_d1 <= rx_in;
             rx_d2 <= rx_d1;
            -- Uload the rx data
             if (uld_rx_data = '1') then
                 rx_data  <= rx_reg;
                 rx_is_empty <= '1';
             end if;
             if uld_rx_data = '1' and selCheck /= "00" and rx_is_empty = '1' then
                 rx_data <= "00000000";
             end if;
            -- Receive data only when rx is enabled
             if (rx_enable = '1') then
                -- Check if just received start of frame
                 if (rx_busy = '0' and rx_d2 = '0') then
                     rx_busy       <= '1';
                     rx_sample_cnt <= X"1";
                     rx_cnt        <= X"0";
                 end if;
                -- Start of frame detected, Proceed with rest of data
                 if (rx_busy = '1') then
                     rx_sample_cnt <= rx_sample_cnt + 1;
                    -- Logic to sample at middle of data
                     if (rx_sample_cnt = 7) then
                         if ((rx_d2 = '1') and (rx_cnt = 0)) then
                             rx_busy <= '0';
                         else
                             rx_cnt <= rx_cnt + 1;
                            -- Start storing the rx data
                             if (rx_cnt > 0 and rx_cnt < 9) then
                                 rx_reg(conv_integer(rx_cnt) - 1) <= rx_d2;
                             end if;
                             if (rx_cnt = 9) then
                                 rx_busy <= '0';
                                -- Check if End of frame received correctly
                                 if (rx_d2 = '0') then
                                     rx_frame_err <= '1';
                                 else
                                     rx_is_empty  <= '0';
                                     rx_frame_err <= '0';
                                    -- Check if last rx data was not unloaded,
                                     if (rx_is_empty = '1') then
                                         rx_over_run  <= '0';
                                     else
                                         rx_over_run  <= '1';
                                     end if;
                                 end if;
                             end if;
                         end if;
                     end if;
                 end if;
             end if;
             if (rx_enable = '0') then
                 rx_busy <= '0';
             end if;
         end if;
     end process;
     rx_empty <= rx_is_empty;
     
    -- UART TX Logic
     process (txclk, reset) begin
         if (reset = '1') then
             tx_reg        <= (others=>'0');
             tx_is_empty   <= '1';
             tx_over_run   <= '0';
             tx_out        <= '0';
             tx_cnt        <= (others=>'0');
         elsif (rising_edge(txclk)) then
 
             if (ld_tx_data = '1') then
                 if (tx_is_empty = '0') then
                     tx_over_run <= '0';
                 else
                     tx_reg   <= tx_data;
                     tx_is_empty <= '0';
                 end if;
             end if;
             if (tx_enable = '1' and tx_is_empty = '0') then
                 tx_cnt <= tx_cnt + 1;
                 if (tx_cnt = 0) then
                     tx_out <= '0';
                 end if;
                 if (tx_cnt > 0 and tx_cnt < 9) then
                     tx_out <= tx_reg(conv_integer(tx_cnt) -1);
                 end if;
                 if (tx_cnt = 9) then
                     tx_out <= '1';
                     tx_cnt <= X"0";
                     tx_is_empty <= '1';
                 end if;
             end if;
             if (tx_enable = '0') then
                 tx_cnt <= X"0";
             end if;
         end if;
     end process;
     
--     process(uld_rx_data)
--     begin
--        if uld_rx_data = '1' and selCheck /= "00" and rx_is_empty = '1' then
--            rx_data <= "00000000";
--        end if;
--    end process;
--     tx_empty <= tx_is_empty;
 
 end architecture;