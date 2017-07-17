----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/05/2017 01:36:15 PM
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_level is
    port( 
        clk_100mhz          : in STD_LOGIC;
        save_button_input   : in STD_LOGIC;
        ps2_clk             : in std_logic;
        ps2_data            : in std_logic;
        scl                 : inout std_logic;
        sda                 : inout std_logic;
        tx                  : inout std_logic;
        rx                  : inout std_logic;
        potX                : inout std_logic_vector(7 downto 0);
        potY                : inout std_logic_vector(7 downto 0);
        VGA_H_SYNC          : out std_logic;
        VGA_V_SYNC          : out std_logic;
        VGA_R               : out std_logic_vector(3 downto 0);
        VGA_G               : out std_logic_vector(3 downto 0);
        VGA_B               : out std_logic_vector(3 downto 0)
        --usb_bt_input        : in STD_LOGIC;
        --keyboard_input      : in STD_LOGIC_VECTOR(7 downto 0);
        --poten_x_pos_input   : in STD_LOGIC_VECTOR(7 downto 0);
        --poten_y_pos_input   : in STD_LOGIC_VECTOR(7 downto 0);
        --usb_bt_output       : out STD_LOGIC;
        --lcd_output          : out STD_LOGIC_VECTOR(7 downto 0); -- PUT BACK
        --vga_output          : out STD_LOGIC_VECTOR(11 downto 0);
        --tricolor_lcd_output : out STD_LOGIC_VECTOR(11 downto 0); -- PUT BACK
    );
end top_level;

architecture Behavioral of top_level is

    -- RAM component
    component blk_mem_gen_0
        port(
            clka    : in STD_LOGIC;
            wea     : in STD_LOGIC_VECTOR(0 downto 0);
            addra   : in STD_LOGIC_VECTOR(16 downto 0);
            dina    : in STD_LOGIC_VECTOR(11 downto 0);
            clkb    : in STD_LOGIC;
            addrb   : in STD_LOGIC_VECTOR(16 downto 0);
            doutb   : out STD_LOGIC_VECTOR(11 downto 0)
        );
    end component;    
    
    -- Game logic component
    component game_logic is
        port( 
            clk                     : in STD_LOGIC;
            usb_bt_clk              : in STD_LOGIC;
            save_button_input       : in STD_LOGIC;   
            keyboard_input          : in STD_LOGIC_VECTOR(7 downto 0);
            x_pos_input             : in STD_LOGIC_VECTOR(7 downto 0);
            y_pos_input             : in STD_LOGIC_VECTOR(7 downto 0);
            usb_bt_input            : in STD_LOGIC_VECTOR(7 downto 0);
            reset_output            : out STD_LOGIC;
            screen_size_output      : out STD_LOGIC;
            pen_width_output        : out STD_LOGIC_VECTOR(2 downto 0);
            x_pos_output            : out STD_LOGIC_VECTOR(7 downto 0);
            y_pos_output            : out STD_LOGIC_VECTOR(7 downto 0);
            tricolor_led_output     : out STD_LOGIC_VECTOR(11 downto 0);
            usb_bt_output           : out STD_LOGIC_VECTOR(15 downto 0);
            color_output            : out STD_LOGIC_VECTOR(23 downto 0);
            ram_we_output           : out STD_LOGIC_VECTOR(0 downto 0);
            ram_val_output          : out STD_LOGIC_VECTOR(11 downto 0);
            ram_addr_output         : out STD_LOGIC_VECTOR(16 downto 0)
        );
    end component;
    
    -- USB/Bluetooth clock divider component
    component clock_divider is
        generic(count_max : INTEGER := 2); -- CHANGE VALUE
        port( 
            clk         : in STD_LOGIC;
            reset       : in STD_LOGIC;
            clk_output  : out STD_LOGIC
        );
    end component;
    
    component sys_clk IS	
             GENERIC (
                  CONSTANT REF_CLK : integer := 100000000;  --  100.0 MHz   
                  CONSTANT OUT_CLK : integer := 25000000); 
             PORT (
                  SIGNAL oCLK         : INOUT std_logic;      
                  SIGNAL iCLK         : IN std_logic;          
                  SIGNAL iRST     : IN std_logic);
    END component;
    
    component vga_sync IS
       GENERIC (
     
          H_SYNC_TOTAL  : INTEGER := 800;
          H_PIXELS      : INTEGER := 640;
          H_SYNC_START  : INTEGER := 659;
          H_SYNC_WIDTH  : INTEGER := 96;
          V_SYNC_TOTAL  : INTEGER := 525;
          V_PIXELS      : INTEGER := 480;
          V_SYNC_START  : INTEGER := 493;
          V_SYNC_WIDTH  : INTEGER := 2;
          H_START       : INTEGER := 699
    );
       PORT (
          iCLK          : IN STD_LOGIC;
          iRST_N        : IN STD_LOGIC;
          iRed          : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
          iGreen        : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
          iBlue         : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
          px            : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
          py            : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
          VGA_R         : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
          VGA_G         : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
          VGA_B         : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
          VGA_H_SYNC    : OUT STD_LOGIC;
          VGA_V_SYNC    : OUT STD_LOGIC
          --VGA_BLANK     : OUT STD_LOGIC
       );
    END component;
    
    component vga_out is
      PORT ( iCLK          : in STD_LOGIC;
             px            : in STD_LOGIC_VECTOR(9 DOWNTO 0);
             py            : in STD_LOGIC_VECTOR(9 DOWNTO 0);
             potX          : in STD_LOGIC_VECTOR(7 DOWNTO 0);
             potY          : in STD_LOGIC_VECTOR(7 DOWNTO 0);
             color         : in STD_LOGIC_VECTOR(11 downto 0);
             red          : out STD_LOGIC_VECTOR(3 DOWNTO 0);
             green        : out STD_LOGIC_VECTOR(3 DOWNTO 0);
             blue         : out STD_LOGIC_VECTOR(3 DOWNTO 0);
             ram_addr_output : out STD_LOGIC_VECTOR(16 downto 0)
          );
    end component;
    
    component i2c_user_logic is
      Port ( 
            clk        : in std_logic;
            busy       : in std_logic;
            data_rd    : in std_logic_vector(7 downto 0);
            ienable     : in std_logic;
            i2c_ena     : out std_logic;
            i2c_addr    : out std_logic_vector(6 downto 0);
            i2c_rw      : out std_logic;
            reset_n     : out std_logic;
            i2c_data_wr : out std_logic_vector(7 downto 0);
            valid       : out std_logic;
            data16bit   : out std_logic_vector(15 downto 0)
       );
    end component;
    
    component i2c_master IS
      GENERIC(
        input_clk : INTEGER := 100_000_000; --input clock speed from user logic in Hz
        bus_clk   : INTEGER := 9600);   --speed the i2c bus (scl) will run at in Hz
      PORT(
        clk       : IN     STD_LOGIC;                    --system clock
        reset_n   : IN     STD_LOGIC;                    --active low reset
        ena       : IN     STD_LOGIC;                    --latch in command
        addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
        rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
        data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
        busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
        data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
        ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
        sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
        scl       : INOUT  STD_LOGIC);                   --serial clock output of i2c bus
    end component;
    
    component ps2_keyboard_to_ascii IS
      GENERIC(
          clk_freq                  : INTEGER := 100_000_000; --system clock frequency in Hz
          ps2_debounce_counter_size : INTEGER := 9);         --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
      PORT(
          clk        : IN  STD_LOGIC;                     --system clock input
          ps2_clk    : IN  STD_LOGIC;                     --clock signal from PS2 keyboard
          ps2_data   : IN  STD_LOGIC;                     --data signal from PS2 keyboard
          ascii_new  : OUT STD_LOGIC;                     --output flag indicating new ASCII value
          ascii_code : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)); --ASCII value
    END component;
    
    component uart is
        port (
            reset       :in  std_logic;
            txclk       :in  std_logic;
            ld_tx_data  :in  std_logic;
            tx_data     :in  std_logic_vector (7 downto 0);
            tx_enable   :in  std_logic;
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
        
    -- RAM signals
    signal ram_addrb    : STD_LOGIC_VECTOR(16 downto 0);
    signal ram_doutb     : STD_LOGIC_VECTOR(11 downto 0);

    -- Game logic signals
    signal gl_reset                     : STD_LOGIC;
    signal gl_screen_size               : STD_LOGIC;
    signal gl_pen_width                 : STD_LOGIC_VECTOR(2 downto 0);
    signal gl_x_pos, gl_y_pos           : STD_LOGIC_VECTOR(7 downto 0);
    signal gl_tricolor_led              : STD_LOGIC_VECTOR(11 downto 0);
    signal gl_usb_bt                    : STD_LOGIC_VECTOR(15 downto 0);
    signal gl_color                     : STD_LOGIC_VECTOR(23 downto 0);
    signal gl_ram_we                    : STD_LOGIC_VECTOR(0 downto 0);
    signal gl_ram_val                   : STD_LOGIC_VECTOR(11 downto 0);
    signal gl_ram_addr                  : STD_LOGIC_VECTOR(16 downto 0);
    
    -- Potentionmeter interface signals
    signal poten_x_pos : STD_LOGIC_VECTOR(7 downto 0);
    signal poten_y_pos : STD_LOGIC_VECTOR(7 downto 0);
    
    -- USB/Bluetooth signals
    signal usb_bt_input_vector  : STD_LOGIC_VECTOR(7 downto 0);
    signal usb_bt_output_vector : STD_LOGIC_VECTOR(7 downto 0);
    
    -- USB/Bluetooth clock divider signals
    signal usb_bt_clk : STD_LOGIC;
    
    -- Ryan's shit
    signal reset_n : std_logic;
    signal px : std_logic_vector(9 downto 0);
    signal py : std_logic_vector(9 downto 0);
    signal red  : std_logic_vector(3 downto 0);
    signal green  : std_logic_vector(3 downto 0);
    signal blue  : std_logic_vector(3 downto 0);
    signal i2cClk : std_logic;
    signal i2c_ena : std_logic;
    signal i2c_addr : std_logic_vector(6 downto 0);
    signal i2c_rw : std_logic;
    signal i2c_reset : std_logic;
    signal i2c_data_wr : std_logic_vector(7 downto 0);
    signal vgaClk : std_logic;
    signal busy : std_logic;
    signal ack_error : std_logic;
    signal ascii_code : std_logic_vector(6 downto 0);
    signal full_ascii_code : std_logic_vector(7 downto 0);
    signal ascii_new  : std_logic;
    signal valid : std_logic;
    signal data_rd : std_logic_vector(7 downto 0);
    signal data16bit : std_logic_vector(15 downto 0);
    signal uartClk : std_logic;
    signal uartClkEna: std_logic;
    signal rx_data : std_logic_vector(7 downto 0);

begin

    -- RAM port map
    ram : blk_mem_gen_0
        port map (
            clka    => clk_100mhz,
            wea     => gl_ram_we,
            addra   => gl_ram_addr,
            dina    => gl_ram_val,
            clkb    => clk_100mhz,
            addrb   => ram_addrb,
            doutb   => ram_doutb
        );

    full_ascii_code <= "0" & ascii_code;
    -- Game logic port map
    gl : game_logic
        port map( 
            clk                     => clk_100mhz,
            usb_bt_clk              => usb_bt_clk,
            save_button_input       => save_button_input,
            keyboard_input          => full_ascii_code,
            x_pos_input             => potX,
            y_pos_input             => potY,
            usb_bt_input            => usb_bt_input_vector,
            reset_output            => gl_reset,
            screen_size_output      => gl_screen_size,
            pen_width_output        => gl_pen_width,
            x_pos_output            => gl_x_pos,
            y_pos_output            => gl_y_pos,
            color_output            => gl_color,
            tricolor_led_output     => gl_tricolor_led,
            usb_bt_output           => gl_usb_bt,
            ram_we_output           => gl_ram_we,
            ram_val_output          => gl_ram_val,
            ram_addr_output         => gl_ram_addr 
        );
        
    -- USB/Bluetooth clock divider port map
    usb_bt_clock_divider : clock_divider
        generic map(count_max => 2) -- CHANGE VALUE
        port map( 
            clk         => clk_100mhz,
            reset       => '0',
            clk_output  => usb_bt_clk
        );
        
        
    -- Ryan's mess 
    reset_n <= not gl_reset;   
        
    process(clk_100mhz)
    begin
        if(rising_edge(clk_100mhz)) then
           if(valid = '1') then
              if(data16bit(12) = '0') then
                 potX <= data16bit(11 downto 4);
              elsif(data16bit(12) = '1') then
                 potY <= data16bit(11 downto 4);
              end if;
           end if;
         end if;
    end process;
    
    Inst_sys_clk : sys_clk
        GENERIC map (
            REF_CLK => 100000000,  --  100.0 MHz   
            OUT_CLK => 25000000)
        PORT map (
            oCLK     => vgaClk,  
            iCLK     => clk_100mhz, 
            iRST     => gl_reset
        );
              
        Inst_i2c_clk : sys_clk
        GENERIC map (
            REF_CLK  => 100000000,  --  100.0 MHz   
            OUT_CLK  => 1000000)
        PORT map (
            oCLK     => i2cClk,  
            iCLK     => clk_100mhz, 
            iRST     => gl_reset
            );                 
    
        Inst_uart_clk : sys_clk
        GENERIC map (
                      REF_CLK  => 100000000,  --  100.0 MHz   
                      OUT_CLK  => 115200)
           PORT map (
                      oCLK     => uartClk,  
                      iCLK     => clk_100mhz, 
                      iRST     => gl_reset
                      );    
                      
         Inst_uartEna_clk : sys_clk
         GENERIC map (
                       REF_CLK  => 100000000,  --  100.0 MHz   
                       OUT_CLK  => 11520)
         PORT map (
                       oCLK     => uartClkEna,  
                       iCLK     => clk_100mhz, 
                       iRST     => gl_reset
                      );                      
                      
        Inst_vga_sync : vga_sync
        GENERIC map (
                      H_SYNC_TOTAL  => 800,
                      H_PIXELS      => 640,
                      H_SYNC_START  => 659,
                      H_SYNC_WIDTH  => 96,
                      V_SYNC_TOTAL  => 525,
                      V_PIXELS      => 480,
                      V_SYNC_START  => 493,
                      V_SYNC_WIDTH  => 2,
                      H_START       => 699)
        PORT map (
                      iCLK          => vgaClk,
                      iRST_N        => reset_n,
                      iRed          => red,
                      iGreen        => green,
                      iBlue         => blue,
                      px            => px,
                      py            => py,
                      VGA_R         => VGA_R,
                      VGA_G         => VGA_G,
                      VGA_B         => VGA_B,
                      VGA_H_SYNC    => VGA_H_SYNC,
                      VGA_V_SYNC    => VGA_V_SYNC
                      --VGA_BLANK     => 
                      );
                      
         Inst_vga_out : vga_out
         PORT map( 
                      iCLK          => clk_100mhz,
                      px            => px,
                      py            => py,
                      potX          => potX,
                      potY          => potY,
                      color         => ram_doutb,
                      red           => red,
                      green         => green,
                      blue          => blue,
                      ram_addr_output => ram_addrb
                            );
                            
         Inst_i2c_user_logic : i2c_user_logic
         Port map( 
                      clk           => clk_100mhz,
                      busy          => busy,
                      ienable       => '1',
                      data_rd       => data_rd,
                      i2c_ena       => i2c_ena,
                      i2c_addr      => i2c_addr,
                      i2c_rw        => i2c_rw,
                      reset_n       => i2c_reset,
                      i2c_data_wr   => i2c_data_wr,
                      valid         => valid,
                      data16bit     => data16bit
                               );
                               
        Inst_i2c_master : i2c_master
        GENERIC map(
                      input_clk => 100_000_000, --input clock speed from user logic in Hz
                      bus_clk   => 9600)   --speed the i2c bus (scl) will run at in Hz
        PORT map(
                      clk       => clk_100mhz,                    --system clock
                      reset_n   => i2c_reset,                    --active low reset
                      ena       => i2c_ena,                    --latch in command
                      addr      => i2c_addr,                    --address of target slave
                      rw        => i2c_rw,                    --'0' is write, '1' is read
                      data_wr   => i2c_data_wr,                    --data to write to slave
                      busy      => busy,                    --indicates transaction in progress
                      data_rd   => data_rd,                    --data read from slave
                      ack_error => ack_error,                    --flag if improper acknowledge from slave
                      sda       => sda,                    --serial data output of i2c bus
                      scl       => scl                   --serial clock output of i2c bus
                      );
                      
         Inst_ps2_keyboard_to_ascii : ps2_keyboard_to_ascii
         GENERIC map(
                      clk_freq                  =>   100_000_000, --system clock frequency in Hz
                      ps2_debounce_counter_size =>   9)         --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
         PORT map(
                      clk        => clk_100mhz,                     --system clock input
                      ps2_clk    => ps2_clk,                     --clock signal from PS2 keyboard
                      ps2_data   => ps2_data,                     --data signal from PS2 keyboard
                      ascii_new  => ascii_new,                     --output flag indicating new ASCII value
                      ascii_code => ascii_code); --ASCII value
                      
    Inst_uart : uart
    port map(
        reset       => gl_reset,
        txclk       => uartClk,
        ld_tx_data  => uartClkEna,
        tx_data     => gl_usb_bt(7 downto 0),  -- FIX THIS (its actually 2 sets of commands)
        tx_enable   => '1',
        tx_out      => tx,  --o
        tx_empty    => open,  --o
        rxclk       => uartClk,
        uld_rx_data => uartClkEna,
        rx_data     => usb_bt_input_vector,  --o (7 downto 0)
        rx_enable   => '1',
        rx_in       => rx,
        rx_empty    => open  --o
    );

end Behavioral;
