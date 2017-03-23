----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2017 12:40:24 PM
-- Design Name: 
-- Module Name: top_level - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_level is
port(
    iCLK            : in std_logic;
    --iPCsel           : in std_logic_vector(1 downto 0); -- testing
    iPCsel          : in std_logic;
    iEOC            : in std_logic;
    SW              : in std_logic;
    --idata_valid     : in std_logic; -- testing
    iReset          : in std_logic;     -- BTNC
    inData0          : in std_logic;    -- PIN D14 JB[1]
    inData1          : in std_logic;    -- PIN F16 JB[2]
    inData2          : in std_logic;    -- PIN G16 JB[3]
    inData3          : in std_logic;    -- PIN H14 JB[4]
    inData4          : in std_logic;    -- PIN E16 JB[5]
    inData5          : in std_logic;    -- PIN F13 JB[6]
    inData6          : in std_logic;    -- PIN G13 JB[7]
    inData7          : in std_logic;    -- PIN H16 JB[8]                      
    --iadc_dataReady  : in std_logic;     -- PIN E17 JA[6]
    inStartOutput   : in std_logic;
    oALE            : out std_logic;
    sysPWMout       : out std_logic_vector(0 downto 0);    -- PIN K1 JC[1]
    sysPWM_nout     : out std_logic_vector(0 downto 0);    -- PIN F6 JC[2]
    oadc_select     : out std_logic;    -- PIN F18 JA[1]
    oadc_clock      : out std_logic;    -- PIN D18 JA[2]
    oadc_loadAddressStart : out std_logic;    -- PIN E7 JA[3]
    oadc_outputEnable : out std_logic;    -- PIN G17 JA[4]
    odata_valid     : buffer std_logic;    -- PIN D17 JA[5]
    otx_ready       : out std_logic;    -- PIN J2 JC[3]
    outData         : out std_logic     -- data to PC -- PIN G6 JC[4]
    );
end top_level;

architecture Structural of top_level is

--component basic_uart is
--    port(
--        clk: in std_logic;                         -- clock
--        reset: in std_logic;                       -- reset
        
--        -- Client interface
--        rx_data: out std_logic_vector(7 downto 0); -- received byte
--        rx_enable: out std_logic;                  -- validates received byte (1 system clock spike)
--        tx_data: in std_logic_vector(7 downto 0);  -- byte to send
--        tx_enable: in std_logic;                   -- validates byte to send if tx_ready is '1'
--        tx_ready: out std_logic;                   -- if '1', we can send a new byte, otherwise we won't take it
        
--        -- Physical interface
--        rx: in std_logic;
--        tx: out std_logic
--        );
--end component;

 component uart is
     port (
         reset       :in  std_logic;
         txclk       :in  std_logic;
         ld_tx_data  :in  std_logic;
         tx_data     :in  std_logic_vector (7 downto 0);
         tx_enable   :in  std_logic;
         selCheck     :in std_logic_vector(1 downto 0);
         tx_out      :out std_logic;
         tx_empty    :out std_logic;
         rxclk       :in  std_logic;
         uld_rx_data :in  std_logic;
         rx_data     :out std_logic_vector (7 downto 0);
         rx_enable   :in  std_logic;
         rx_in       :in  std_logic;
         rx_empty    :out std_logic
     );
 end component;

--component ad_converter is
--	port (from_adc	: in std_logic_vector(7 downto 0);
--			adc_dataReady, slow_clk, reset, enable : in std_logic;
--			adc_select : out std_logic_vector(1 downto 0);
--			adc_output00FL, adc_output01FR, adc_output10BL, adc_output11BR
-- 			: out std_logic_vector(7 downto 0);
--			adc_clock, adc_loadAddressStart, adc_outputEnable, data_valid
--			: out std_logic);
--	end component;

component ADC_Controller is
     generic(samples : integer :=128);
   	 Port (     iclk : in STD_LOGIC;
		    reset : in STD_LOGIC;
	        EOC : in STD_LOGIC;
		    oStart : out STD_LOGIC;
		    ALE : out std_logic;
		    oOE : out std_logic;
			sel : buffer std_logic := '0';
		    oWriteReady : buffer std_logic;
		    oClk_en : out std_logic
           );
end component;

--component PWM_Controller is
--    port(
--        iadc_sel : in std_logic;
--        iSW      : in std_logic;
--        iData    : in std_logic_vector(7 downto 0);
--        --iData2  : in std_logic_vector(7 downto 0);
--        oData    : out std_logic_vector(7 downto 0)
--        );
--end component;
	
component RAM_Controller is
        generic( constant samples : integer := 128);
        Port ( clk11kHz : in STD_LOGIC;
               clk      : in std_logic;
               clk500kHz : in STD_LOGIC;
               idata_valid : in std_logic;
               sel : in STD_LOGIC_vector(1 downto 0);
               ointernalCount : out std_logic; 
               iadcsel : in std_logic;
               reset : in std_logic;
               ena1 : out std_logic;
               enb1 : out std_logic;
               ena2 : out std_logic;
               enb2 : out std_logic;
               wea : out std_logic_vector(0 downto 0);
               UARTen : out std_logic;
               ocount1 : out std_logic_vector(13 downto 0);
               ocount4 : out std_logic_vector(13 downto 0);
               ocount2 : out std_logic_vector(13 downto 0);
               ocount3 : out std_logic_vector(13 downto 0));
    end component;

    
component multiplex_UART is
        generic (data_width : positive := 8);
        port(select_line: in std_logic;
            in_a, in_b: in std_logic_vector(data_width-1 downto 0);
            --UARTen : out std_logic;
            output : out std_logic_vector(data_width-1 downto 0));
        end component;
        
component pwm IS
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
    END component; 

--component pwm_prog is
--generic(
--  N                     : integer := 8);      -- number of bit of PWM counter
--port (
--  i_clk                       : in  std_logic;
--  i_rstb                      : in  std_logic;
--  i_sync_reset                : in  std_logic;
--  i_pwm_module                : in  std_logic_vector(N-1 downto 0);  -- PWM Freq  = clock freq/ (i_pwm_module+1); max value = 2^N-1
--  i_pwm_width                 : in  std_logic_vector(N-1 downto 0);  -- PWM width = (others=>0)=> OFF; i_pwm_module => MAX ON 
--  o_pwm                       : out std_logic);
--end component;   
	
component clk1Mhz IS	
             PORT (
                  SIGNAL samplingFreq         : INOUT std_logic;
                  signal baudRate          : INOUT std_logic;
                  signal rx_clk             : inout std_logic;
                  signal tx_clk             : inout std_logic;      
                  SIGNAL iCLK         : IN std_logic);
    END component;
    
COMPONENT sig1dualRAM
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clkb : IN STD_LOGIC;
        enb : IN STD_LOGIC;
        addrb : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    END COMPONENT;
    
component btn_debounce_toggle is
    GENERIC (
        CONSTANT CNTR_MAX : std_logic_vector(15 downto 0) := X"FFFF");  
        Port ( BTN_I     : in  STD_LOGIC;
               CLK         : in  STD_LOGIC;
               BTN_O     : out  STD_LOGIC;
               TOGGLE_O : out  STD_LOGIC);
    end component;
    
--    component adc_parse is
--        Port ( iData : in STD_LOGIC_vector(7 downto 0);
--               oData1 : out STD_LOGIC_vector(7 downto 0);
--               oData2 : out STD_LOGIC_vector(7 downto 0);
--               iadc_sel : in STD_LOGIC);
--    end component;

signal rx_en:    std_logic:= '1';
signal tx_en:    std_logic:= '1';
signal txs:       std_logic;
signal rxs:       std_logic;
signal sreset_n:   std_logic;
signal Sreset:     std_logic;
--signal adc_1:     std_logic_vector(7 downto 0);
--signal adc_2:     std_logic_vector(7 downto 0);
--signal adc00:     std_logic_vector(7 downto 0);
--signal adc01:     std_logic_vector(7 downto 0);
--signal adc10:     std_logic_vector(7 downto 0);
--signal adc11:     std_logic_vector(7 downto 0);
signal rx_ld:        std_logic;
signal Sclk500kHZ: std_logic;
signal Sclk11kHz:  std_logic;
signal RAMout1:   std_logic_vector(7 downto 0);
signal RAMout2:   std_logic_vector(7 downto 0);
signal RAMout3:   std_logic_vector(7 downto 0);
signal UARTdata:  std_logic_vector(7 downto 0);
signal RAMUARTen:   std_logic;
--signal MUXUARTen:   std_logic;
signal RAMena1: std_logic;
signal RAMenb1: std_logic;
signal RAMena2: std_logic;
signal RAMenb2: std_logic;
signal RAMwea: std_logic_vector(0 downto 0);
signal RAMaddra1: std_logic_vector(13 downto 0);
signal RAMaddra2: std_logic_vector(13 downto 0);
signal RAMaddrb1: std_logic_vector(13 downto 0);
signal RAMaddrb2: std_logic_vector(13 downto 0);
signal inData   : std_logic_vector(7 downto 0);
signal PCsel    : std_logic_vector(1 downto 0);
signal rxSel    : std_logic_vector(7 downto 0);
signal stx_ready: std_logic:= '1';
signal adcsel   : std_logic;
signal adcsel_n : std_logic;
signal Spwm_out : std_logic;
signal Srx_clk  : std_logic;
signal Stx_clk : std_logic;
signal data_valid : std_logic;
signal RAM_count : std_logic;
signal PWMdata   : std_logic_vector(7 downto 0);
signal sig1 : std_logic_vector(7 downto 0);
signal sig2 : std_logic_vector(7 downto 0);
 

begin

--adc_1 <= adc00 or adc01;
--adc_2 <= adc10 or adc11;
RAMout3 <= RAMout1 or RAMout2;
sreset_n <= not iReset;
--inData <= inData0 & inData1 & inData2 & inData3 & inData4 & inData5 & inData6 & inData7;
inData <= inData7 & inData6 & inData5 & inData4 & inData3 & inData2 & inData1 & inData0;
PCsel <= rxSel(1 downto 0);
oadc_select <= adcsel;
adcsel_n <= not adcsel;
--sysPWM_nout <= not(Spwm_out);
--sysPWMout <= Spwm_out;
odata_valid <= data_valid;
rx_ld <= not(RAM_count) and rx_en; 

Inst_sys_clk: clk1Mhz
    port map(
        iCLK => iCLK,
        samplingFreq => Sclk500kHz,
        rx_clk  => Srx_clk,
        tx_clk => Stx_clk,
        baudRate  => Sclk11kHz
        );
        
Inst_ResetDeb: btn_debounce_toggle
            GENERIC map ( CNTR_MAX  =>  X"FFFF")  
                Port map ( BTN_I     => iReset,
                       CLK         => iCLK,
                       BTN_O     => Sreset,
                       TOGGLE_O => open
                       );
        
--Inst_ADC_Parse: adc_parse
--   Port map 
--        ( iData => inData,
--          oData1 => sig1,
--          oData2 => sig2,
--          iadc_sel => adcsel
--          );
          
--Inst_ADC: ad_converter
--    port map(
--        from_adc => inData,
--        adc_dataReady => iadc_dataReady,
--        slow_clk => Sclk500kHz,
--        reset => iReset,
--        enable => en,
--        adc_select => oadc_select,
--        adc_output00FL => adc00,
--        adc_output01FR => adc01,
--        adc_output10BL => adc10,
--        adc_output11BR => adc11,
--        adc_clock => oadc_clock,
--        adc_loadAddressStart => oadc_loadAddressStart,
--        adc_outputEnable => oadc_outputEnable,
--        data_valid => odata_valid
--        );

--Inst_PWM_Controller: PWM_Controller
--    port map(
--        iadc_sel => adcsel,
--        iSW         => SW,
--        iData       => inData,
--        --iData2      => sig2,
--        oData       => pwmData
--        );

Inst_ADC: ADC_Controller
    generic map(samples => 128)
    port map(
        iclk => iCLK,
        reset => Sreset,
        EOC => iEOC,
        oStart => oadc_loadAddressStart,
        ALE => oALE,
        oOE => oadc_outputEnable,
        sel => adcsel,
        oWriteReady => data_valid,
        oClk_en => oadc_clock
        );
        
        
Inst_RAM_Controller: RAM_Controller
    generic map(samples => 128)
    port map(
        clk => iCLK,
        clk11kHz => Sclk11kHz,
        idata_valid => data_valid,
        clk500kHz => Sclk500kHz,
        iadcsel => adcsel,
        reset => Sreset,
        sel => PCsel,
        ointernalCount => RAM_count,
        ena1 => RAMena1,
        enb1 => RAMenb1,
        ena2 => RAMena2,
        enb2 => RAMenb2,
        wea => RAMwea,
        UARTen => RAMUARTen,
        ocount1 => RAMaddra1,
        ocount4 => RAMaddra2,
        ocount2 => RAMaddrb1,
        ocount3 => RAMaddrb2
        );
        
Inst_RAM1: sig1dualRAM
    port map(
        clka => iCLK,
        ena => adcsel_n,
        wea => RAMwea,
        addra => RAMaddra1,
        dina => inData,
        clkb => iCLK,
        enb => RAMenb1,
        addrb => RAMaddrb1,
        doutb => RAMout1
        );        
                 
Inst_RAM2: sig1dualRAM
        port map(
            clka => iCLK,
            ena => adcsel,
            wea => RAMwea,
            addra => RAMaddra2,
            dina => inData,
            clkb => iCLK,
            enb => RAMenb2,
            addrb => RAMaddrb2,
            doutb => RAMout2
            );
        
Inst_Mux: multiplex_UART  
        generic map (data_width => 8)
        port map(
        -- inputs
        select_line => RAMenb2,
        --UARTen => MUXUARTen,
        in_a => RAMout1,
        in_b => RAMout2,
        -- outputs
        output => UARTdata
        );        
        
Inst_PWM: pwm
    generic map(
        sys_clk => 100_000_000,
        pwm_freq => 500_000,
        bits_resolution => 8,
        phases => 1)
    port map(
        clk => iCLK,
        reset_n => sreset_n,
        ena => rx_en,
        duty => inData,
        pwm_out => sysPWMout,
        pwm_n_out => sysPWM_nout
        );

--Inst_PWM: pwm_prog
--    generic map( N => 8)
--    port map(
--        i_clk => iCLK,
--        i_rstb => Sreset,
--        i_sync_reset => Sreset,
--        i_pwm_module => "01000000",
--        i_pwm_width => UARTdata,
--        o_pwm => Spwm_out
--        );
                

--Inst_UART: basic_uart
--    port map(
--      clk => iCLK,
--      reset => iReset,
--      rx_data   => rxSel,
--      tx_data   => RAMout3,
--      rx_enable => rx_en,
--      tx_enable => tx_en,
--      rx        => iPCsel,
--      tx        => outData,
--      tx_ready  => otx_ready
--      );  

Inst_UART: uart
    port map(
        reset => Sreset,
        txclk => Stx_clk,
        ld_tx_data => RAM_count,
        tx_data => UARTdata,
        selCheck => PCsel,
        tx_enable => tx_en,
        tx_out => outData,
        tx_empty => open,
        rxclk => Srx_clk,
        uld_rx_data => rx_ld,
        rx_data => rxSel,
        rx_enable => rx_en,
        rx_in => iPCsel,
        rx_empty => open
        );




















    

end Structural;
