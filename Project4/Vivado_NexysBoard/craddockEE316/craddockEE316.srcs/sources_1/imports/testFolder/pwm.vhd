--------------------------------------------------------------------------------
--
--   FileName:         pwm.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 64-bit Version 12.1 Build 177 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 8/1/2013 Scott Larson
--     Initial Public Release
--   Version 2.0 1/9/2015 Scott Larson
--     Transistion between duty cycles always starts at center of pulse to avoid
--     anomalies in pulse shapes
--    
--------------------------------------------------------------------------------

-- PWM code taken from IEEE wiki - https://eewiki.net/pages/viewpage.action?pageId=20939345#PWMGenerator(VHDL)-CodeDownload

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY pwm IS
  GENERIC(
      sys_clk         : INTEGER := 100_000_000; --system clock frequency in Hz
      pwm_freq        : INTEGER := 500_000;    --PWM switching frequency in Hz
      bits_resolution : INTEGER := 64;          --bits of resolution setting the duty cycle
      phases          : INTEGER := 1);         --number of output pwms and phases
  PORT(
      clk       : IN  STD_LOGIC;                                    --system clock
      reset_n   : IN  STD_LOGIC;                                    --asynchronous reset
      ena       : IN  STD_LOGIC;                                    --latches in new duty cycle
      duty      : IN  STD_LOGIC_VECTOR(bits_resolution-1 DOWNTO 0); --duty cycle
      pwm_out   : OUT STD_LOGIC_VECTOR(phases-1 DOWNTO 0);          --pwm outputs
      pwm_n_out : OUT STD_LOGIC_VECTOR(phases-1 DOWNTO 0));         --pwm inverse outputs
END pwm;

ARCHITECTURE logic OF pwm IS
  CONSTANT  period     :  INTEGER := sys_clk/pwm_freq;                      --number of clocks in one pwm period
  TYPE counters IS ARRAY (0 TO phases-1) OF INTEGER RANGE 0 TO period - 1;  --data type for array of period counters
  SIGNAL  count        :  counters := (OTHERS => 0);                        --array of period counters
  SIGNAL   half_duty_new  :  INTEGER RANGE 0 TO period/2 := 0;              --number of clocks in 1/2 duty cycle
  TYPE half_duties IS ARRAY (0 TO phases-1) OF INTEGER RANGE 0 TO period/2; --data type for array of half duty values
  SIGNAL  half_duty    :  half_duties := (OTHERS => 0);                     --array of half duty values (for each phase)
BEGIN
  PROCESS(clk, reset_n)
  BEGIN
    IF(reset_n = '0') THEN                                                 --asynchronous reset
      count <= (OTHERS => 0);                                                --clear counter
      pwm_out <= (OTHERS => '0');                                            --clear pwm outputs
      pwm_n_out <= (OTHERS => '0');                                          --clear pwm inverse outputs
    ELSIF((clk'EVENT AND clk = '1')) THEN                                      --rising system clock edge
          IF(ena = '1') THEN                                                   --latch in new duty cycle
            half_duty_new <= conv_integer(duty)*period/(2**bits_resolution)/2;   --determine clocks in 1/2 duty cycle
          END IF;
          FOR i IN 0 to phases-1 LOOP                                            --create a counter for each phase
            IF(count(0) = period - 1 - i*period/phases) THEN                       --end of period reached
              count(i) <= 0;                                                         --reset counter
              half_duty(i) <= half_duty_new;                                         --set most recent duty cycle value
            ELSE                                                                   --end of period not reached
              count(i) <= count(i) + 1;                                              --increment counter
            END IF;
          END LOOP;
          FOR i IN 0 to phases-1 LOOP                                            --control outputs for each phase
            IF(count(i) = half_duty(i)) THEN                                       --phase's falling edge reached
              pwm_out(i) <= '0';                                                     --deassert the pwm output
              pwm_n_out(i) <= '1';                                                   --assert the pwm inverse output
            ELSIF(count(i) = period - half_duty(i)) THEN                           --phase's rising edge reached
              pwm_out(i) <= '1';                                                     --assert the pwm output
              pwm_n_out(i) <= '0';                                                   --deassert the pwm inverse output
            END IF;
          END LOOP;
    END IF;
  END PROCESS;
END logic;


--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--entity pwm_prog is
--generic(
--  N                     : integer := 8);      -- number of bit of PWM counter
--port (
--  i_clk                       : in  std_logic;
--  i_rstb                      : in  std_logic;
--  i_sync_reset                : in  std_logic;
--  i_pwm_module                : in  std_logic_vector(N-1 downto 0);  -- PWM Freq  = clock freq/ (i_pwm_module+1); max value = 2^N-1
--  i_pwm_width                 : in  std_logic_vector(N-1 downto 0);  -- PWM width = (others=>0)=> OFF; i_pwm_module => MAX ON 
--  o_pwm                       : out std_logic);
--end pwm_prog;
--architecture rtl of pwm_prog is
--signal r_max_count                           : unsigned(N-1 downto 0);
--signal r_pwm_counter                         : unsigned(N-1 downto 0);
--signal r_pwm_width                           : unsigned(N-1 downto 0);
--signal w_tc_pwm_counter                      : std_logic;
--begin
--w_tc_pwm_counter  <= '0' when(r_pwm_counter<r_max_count) else '1';  -- use to strobe new word
----------------------------------------------------------------------
--p_state_out : process(i_clk,i_rstb)
--begin
--  if(i_rstb='0') then
--    r_max_count     <= (others=>'0');
--    r_pwm_width     <= (others=>'0');
--    r_pwm_counter   <= (others=>'0');
--    o_pwm           <= '0';
--  elsif(rising_edge(i_clk)) then
--    r_max_count     <= unsigned(i_pwm_module);
--    if(i_sync_reset='1') then
--      r_pwm_width     <= unsigned(i_pwm_width);
--      r_pwm_counter   <= to_unsigned(0,N);
--      o_pwm           <= '0';
--    else
--      if(r_pwm_counter=0) and (r_pwm_width/=r_max_count) then
--        o_pwm           <= '0';
--      elsif(r_pwm_counter<=r_pwm_width) then
--        o_pwm           <= '1';
--      else
--        o_pwm           <= '0';
--      end if;
      
--      if(w_tc_pwm_counter='1') then
--        r_pwm_width      <= unsigned(i_pwm_width);
--      end if;
      
--      if(r_pwm_counter=r_max_count) then
--        r_pwm_counter   <= to_unsigned(0,N);
--      else
--        r_pwm_counter   <= r_pwm_counter + 1;
--      end if;
--    end if;
--  end if;
--end process p_state_out;
--end rtl;