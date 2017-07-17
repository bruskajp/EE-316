----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/05/2017 02:01:44 PM
-- Design Name: 
-- Module Name: game_logic - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity game_logic is
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
end game_logic;

architecture Behavioral of game_logic is
 
    -- Font ROM component
    component font_rom is
       port(
          clk   : in STD_LOGIC;
          addr  : in STD_LOGIC_VECTOR(10 downto 0);
          data  : out STD_LOGIC_VECTOR(7 downto 0)
       );
    end component;
 
    -- RAM clock divider component
    component clock_divider is
        generic(count_max : INTEGER := 8); -- FIX THIS?
        port( 
            clk         : in STD_LOGIC;
            reset       : in STD_LOGIC;
            clk_output  : out STD_LOGIC
        );
    end component;
 
    -- System properties
    signal pc_connected : STD_LOGIC := '0';
    signal screen_size  : STD_LOGIC := '0';
    signal reset        : STD_LOGIC := '0';
    signal pen_width    : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal ascii_char   : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    signal color        : STD_LOGIC_VECTOR(23 downto 0) := x"000000";

    --USB/bluetooth control send signals
    signal prev_screen_size         : STD_LOGIC := '0';
    signal prev_save                : STD_LOGIC := '0';
    signal prev_reset               : STD_LOGIC := '0';
    signal prev_pen_width           : STD_LOGIC_VECTOR(2 downto 0):= "000";
    signal prev_ascii_char          : STD_LOGIC_VECTOR(7 downto 0):= x"00";
    signal prev_x_pos, prev_y_pos   : STD_LOGIC_VECTOR(7 downto 0):= x"00";
    signal prev_color               : STD_LOGIC_VECTOR(23 downto 0):= x"000000";
    
    --USB/Bluetooth control receive signals
    signal prev_connections : STD_LOGIC_VECTOR(7 downto 0);

    -- Keyboard control signals
    signal num_values_input     : INTEGER   := 0;
    signal prev_pc_connected    : STD_LOGIC := '0';
    signal changing_item        : STD_LOGIC_VECTOR(2 downto 0) := "000"; -- [color, pen_width, screen_size]
    signal hex_input            : STD_LOGIC_VECTOR(3 downto 0)  := x"0";
    signal temp_hex_input       : STD_LOGIC_VECTOR(7 downto 0)  := x"00";
    signal input_values         : STD_LOGIC_VECTOR(23 downto 0) := x"000000";

    -- Font Rom signals
    signal font_rom_addr    : UNSIGNED(10 downto 0) := x"00" & "000";
    signal font_rom_data    : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    
    -- RAM clock divider signals
    signal ram_divider_counter  : INTEGER   := 0;
    signal ram_clk              : STD_LOGIC := '0';
    
    -- RAM Signals
    signal x_pos_int             : INTEGER := 0;
    signal y_pos_int             : INTEGER := 0;
    
    -- RAM fast update signals
    signal ram_update_count             : INTEGER := 0;
    signal ram_update_x_count           : INTEGER := 0;
    signal ram_update_y_count           : INTEGER := 0;
    signal ram_update                   : STD_LOGIC_VECTOR(2 downto 0) := "000"; -- [pos, sys_text, user_text]
    signal ram_update_slow              : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal ram_update_pos_slow          : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    signal ram_update_sys_text_slow     : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    signal ram_update_user_text_slow    : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    
    -- RAM slow control signals 
    signal x_addr_count, y_addr_count   : INTEGER := 0;

    -- RAM reset signals
    signal ram_reset        : STD_LOGIC := '0';
    signal ram_reset_slow   : STD_LOGIC := '0';
    signal ram_reset_count  : UNSIGNED(15 downto 0) := x"0000";
    signal prev_ram_resets  : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    
begin
    
    screen_size_output <= screen_size;
    pen_width_output <= pen_width;
    x_pos_output <= x_pos_input;
    y_pos_output <= y_pos_input;
    tricolor_led_output <= color(11 downto 0);
    color_output <= color;
    ram_we_output <= "1";
    --ram_we_output <= "0";
    reset_output <= reset;

    -- Previous signal generation process
    process(clk)
    begin
        prev_pc_connected <= pc_connected;
        prev_x_pos <= x_pos_input;
        prev_y_pos <= y_pos_input;
        prev_color <= color;
        prev_ascii_char <= ascii_char;
        prev_screen_size <= screen_size;
        prev_pen_width <= pen_width;
        prev_save <= save_button_input;
        prev_reset <= reset;
    end process;

    -- USB/Bluetooth control process
    process(clk, usb_bt_clk, prev_x_pos, prev_y_pos) -- FIX THIS (add update method)
    begin
        -- Sending Data
        if rising_edge(clk) then
            if reset /= prev_reset then
                usb_bt_output(15 downto 12) <= "1111";
                usb_bt_output(1) <= save_button_input;
                usb_bt_output(0) <= reset;
            elsif prev_x_pos /= x_pos_input then
                usb_bt_output(15 downto 14) <= "10";
                usb_bt_output(8) <= '0';
                usb_bt_output(7 downto 0) <= x_pos_input;
            elsif prev_y_pos /= y_pos_input then
                usb_bt_output(15 downto 14) <= "10";
                usb_bt_output(8) <= '1';
                usb_bt_output(7 downto 0) <= y_pos_input;
            elsif prev_color /= color then
                usb_bt_output(15 downto 12) <= "1100";
                usb_bt_output(11 downto 0) <= color(11 downto 0); -- change to 24 bit?
            elsif prev_screen_size /= screen_size or prev_pen_width /= pen_width then
                usb_bt_output(15 downto 12) <= "1110";
                usb_bt_output(3) <= screen_size;
                usb_bt_output(2 downto 0) <= pen_width;
            elsif prev_ascii_char /= ascii_char then
                usb_bt_output(15 downto 12) <= "1101";
                usb_bt_output(7 downto 0) <= ascii_char;
            elsif prev_save /= save_button_input then
                usb_bt_output(15 downto 12) <= "1111";
                usb_bt_output(1) <= save_button_input;
                usb_bt_output(0) <= reset;
            else
                usb_bt_output <= x"0000";
            end if;
        end if;
        
        -- Recieving Data
        if rising_edge(usb_bt_clk) then
            prev_connections <= prev_connections(6 downto 0) & usb_bt_input(0);
            if prev_connections = x"00" then
                pc_connected <= '0';
            else
                pc_connected <= '1';
            end if;
        end if;
    end process;
    
    -- Keyboard control process
    hex_input <= temp_hex_input(3 downto 0);
    process(clk)
    begin
        -- Keyboard control
        if rising_edge(clk) then
            if reset = '0' then
                if keyboard_input = x"77" and changing_item = "000" then -- input w and changing color 
                    ascii_char <= x"77";
                    changing_item <= "100";
                    num_values_input <= 1;
                elsif keyboard_input = x"63" and changing_item = "000" then -- input c and changing pen_width 
                    ascii_char <= x"63";
                    changing_item <= "010";
                    num_values_input <= 1;
                elsif keyboard_input = x"73" and changing_item = "000" then -- input s and changing screen_size 
                    ascii_char <= x"73";
                    changing_item <= "001";
                    num_values_input <= 1;
                elsif keyboard_input = x"72" and changing_item = "000" then -- input r
                    reset <= '1';
                    color <= x"FFFFFF";
                    pen_width <= "000";
                    screen_size <= '0';
                elsif keyboard_input = x"71" and changing_item /= "000" then -- input q and exit command
                    ascii_char <= x"71";
                    -- FIX THIS
                elsif keyboard_input = x"08" and num_values_input = 1 then -- input backspace
                    ascii_char <= x"08";
                    num_values_input <= 0;
                    changing_item <= "000";
                elsif changing_item /= "000" then
                    -- Ascii to hex converter
                    if (keyboard_input >= x"30" and keyboard_input <= x"39") then
                        temp_hex_input <= std_logic_vector(unsigned(keyboard_input) - x"30");
                    elsif (keyboard_input >= x"61" and keyboard_input <= x"66") then
                        temp_hex_input <= std_logic_vector(unsigned(keyboard_input) - x"57");
                    else
                        temp_hex_input <= x"FF";
                    end if;
                    
                    -- User keyboard input restrictions
                    if changing_item = "100" and hex_input <= x"F" then -- Limit color
                        input_values(((num_values_input * 4)-1) downto ((num_values_input-1) * 4)) <= hex_input;
                        num_values_input <= num_values_input + 1;
                    elsif changing_item = "010" and hex_input >= x"1" and hex_input <= x"7" then -- Limit pen_width
                        input_values(3 downto 0) <= hex_input;
                        num_values_input <= num_values_input + 1;
                    elsif changing_item = "001" and hex_input <= x"1" then -- Limit screen_size
                        input_values(3 downto 0) <= hex_input;
                        num_values_input <= num_values_input + 1;
                    end if;
                elsif keyboard_input = x"0A" then -- input enter
                    ascii_char <= x"0A";
                    if changing_item = "100" and num_values_input = 7 then -- new color
                        color <= input_values;
                        changing_item <= "000";
                    elsif changing_item = "010" and num_values_input = 1 then -- new pen_width
                        pen_width <= input_values(2 downto 0);
                        changing_item <= "000";
                    elsif changing_item = "001" and num_values_input = 1 then -- new screen_size
                        screen_size <= input_values(0);
                        changing_item <= "000";
                    end if;
                end if;
            end if;
            
            -- Reset handling
            if reset = '1' and prev_reset = '1' and ram_reset = '0' then
                reset <= '0';
                color <= x"000000";
            end if;
        end if;
    end process;
    
    -- Font ROM port map
    ram_font_rom : font_rom
       port map(
          clk   => clk,
          addr  => std_logic_vector(font_rom_addr),
          data  => font_rom_data
       );

    
    -- RAM clock divider port map
    ram_clock_divider : clock_divider
        generic map(count_max => 2) -- CHANGE VALUE
        port map( 
            clk         => clk,
            reset       => '0',
            clk_output  => ram_clk
        );
    
    x_pos_int <= to_integer(unsigned(x_pos_input));
    y_pos_int <= to_integer(unsigned(y_pos_input));
    
    -- RAM control process
    process(clk, ram_clk)
    begin
        -- When to update RAM
        --if rising_edge(clk) then
--            ram_update_pos_slow <= ram_update_pos_slow(6 downto 0) & ram_update_slow(2);
--            ram_update_pos_slow <= ram_update_pos_slow(6 downto 0) & ram_update_slow(2);
--            ram_update_pos_slow <= ram_update_pos_slow(6 downto 0) & ram_update_slow(2);
        
            if (x_pos_input /= prev_x_pos or y_pos_input /= prev_y_pos) then
                ram_update(2) <= '1'; -- pos
            elsif (color /= prev_color or pen_width /= prev_pen_width 
                  or pc_connected /= prev_pc_connected) then
                ram_update(1) <= '1'; -- sys_text
            elsif (ascii_char /= prev_ascii_char) then
                ram_update(0) <= '1'; -- user_text
            end if;
            
--            if ram_update_pos_slow = x"00" then
--                ram_update(2) <= '0';
--            end if;
            
--            if ram_update_sys_text_slow = x"00" then
--                ram_update(1) <= '0';
--            end if;
                        
--            if ram_update_user_text_slow = x"00" then
--                ram_update(0) <= '0';
--            end if;
            
            if reset = '1' and ram_reset = '0' then
                ram_reset <= '1';
                prev_ram_resets <= prev_ram_resets(6 downto 0) & ram_reset;
            end if;
            
            if ram_reset_slow = '0' and prev_ram_resets = x"FF" then
                ram_reset <= '0';
            end if;           
        --end if;
        
        -- Draw to RAM
        --if rising_edge(ram_clk) then
        if rising_edge(clk) then
            --if ram_reset = '0' then
                if ram_update(2) = '1' then -- pos
                --if(true) then
                    --ram_we_output <= "1";
                    ram_val_output <= color(23 downto 20) & color(15 downto 12) & color(7 downto 4);
                    --ram_update_slow(2) <= '1';
                    --ram_update(2) <= '0';
--                    if (y_addr_count < unsigned(pen_width)) and
--                       ((y_pos_int + y_addr_count) < 256) and
--                       ((y_pos_int + y_addr_count) >= 0) then
--                        if (x_addr_count < unsigned(pen_width)) and 
--                           ((x_pos_int + x_addr_count) < 256) and 
--                           ((x_pos_int + x_addr_count) >= 0) then
                            ram_addr_output <= std_logic_vector(to_unsigned( ((x_pos_int+x_addr_count) + ((y_pos_int+y_addr_count) * 256)) , 17));
--                        else
--                            x_addr_count <= 0;
--                        end if;
--                        y_addr_count <= y_addr_count + 1;
--                    else
--                        y_addr_count <= 0;
--                    end if;

                    --elsif prev_x_pos /= x_pos_input and prev_y_pos /= y_pos_input then --Not needed?
                        --ram_update(1) <= '0';
                        --ram_we_output <= "0"; --Not needed?
                        --ram_update(2) <= '0'; --Not needed?
--                elsif ram_update(2 downto 1) = "01" then -- sys_text
--                    ram_update_slow(2 downto 1) <= "01";
--                    if ram_update_count < 3 then 
--                        if ram_update_y_count < 16 then
--                            if ram_update_x_count < 8 then
--                                if ram_update_count = 1 then -- Update color
--                                    ram_addr_output <= std_logic_vector(to_unsigned(65618 + ram_update_x_count 
--                                                                        + (ram_update_y_count * 384), 17));
--                                    ram_val_output <= color(11 downto 0);
--                                elsif ram_update_count = 2 then -- Update pen_width
--                                    ram_addr_output <= std_logic_vector(to_unsigned(65768 + ram_update_x_count 
--                                                                        + (ram_update_y_count * 384), 17));
--                                    font_rom_addr <= "000" & (x"30" + unsigned("0000" & pen_width)); -- FIX THIS (concurency)
--                                    if font_rom_data(ram_update_x_count) = '1' then
--                                        ram_val_output <= x"000";
--                                    else 
--                                        ram_val_output <= x"FFF";
--                                    end if;
--                                else -- Update pc_connnection
--                                    ram_addr_output <= std_logic_vector(to_unsigned(65888 + ram_update_x_count 
--                                                                        + (ram_update_count * 10)
--                                                                        + (ram_update_y_count * 384), 17));
--                                    font_rom_addr <= "00" & (x"30" + "0000000" & pc_connected); -- FIX THIS (concurency)
--                                    if font_rom_data(ram_update_x_count) = '1' then
--                                        ram_val_output <= x"000";
--                                    else 
--                                        ram_val_output <= x"FFF";
--                                    end if;
--                                end if;
--                                ram_update_x_count <= ram_update_x_count + 1;
--                            else
--                                ram_update_x_count <= 0;
--                            end if;
--                            ram_update_y_count <= ram_update_x_count + 1;
--                        else
--                            ram_update_y_count <= 0;
--                        end if;
--                        ram_update_count <= ram_update_count + 1;
--                    else
--                        ram_update_slow(1) <= '0';
--                        ram_update_count <= 0;
--                    end if;
--                elsif ram_update = "001" then -- user_text
--                    ram_update_slow <= "001";
--                    if ram_update_count < 8 then
--                        if ram_update_y_count < 16 then
--                            if ram_update_x_count < 8 then
--                                ram_addr_output <= std_logic_vector(to_unsigned(66102 +  ram_update_x_count 
--                                                                    + (ram_update_y_count * 384), 17));
--                                font_rom_addr <= unsigned("000" & ascii_char); -- FIX THIS (concurency)
--                                if font_rom_data(ram_update_x_count) = '1' then
--                                    ram_val_output <= x"000";
--                                else 
--                                    ram_val_output <= x"FFF";
--                                end if;
--                                ram_update_x_count <= ram_update_x_count + 1;
--                            else
--                                ram_update_x_count <= 0;
--                            end if;
--                            ram_update_y_count <= ram_update_x_count + 1;
--                        else
--                            ram_update_y_count <= 0;
--                        end if;
--                        ram_update_count <= ram_update_count + 1;
--                    else
--                        ram_update_slow(0) <= '0';
--                        ram_update_count <= 0;
--                    end if;
--                else
--                    ram_update_slow <= "000";
                --end if;
----            else -- ram_reset = 1
----                -- Drawing Screen (sys_text and user_text update automatically)
----                if ram_reset_count < 65536 then
----                    ram_reset_slow <= '1';  
----                    ram_reset_count <= ram_reset_count + 1;
----                    ram_addr_output <= "0" & std_logic_vector(ram_reset_count);
----                else
----                    ram_reset_slow <= '0';
----                    ram_reset_count <= x"0000"; 
----                end if;
            end if;
        end if;
    end process;

end Behavioral;
