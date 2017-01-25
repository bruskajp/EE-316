----------------------------------------------------------------------------------
-- Institution: Clarkson Univeristy 
-- Engineers: Zander Blasingame and Brandon Norris
-- 
-- Create Date: 11/11/2016 21:06:23
-- Design Name: 
-- Module Name: lcd_driver - Behavioral
-- Project Name: 
-- Target Devices: Altera DE2
-- Tool Versions: 
-- Description: Created for the final of EE 365, repurposed for EE 316.
-- Display Model:
--
-- | Mode Op/Prog State Reset/Fwd/Bckwd |
-- | Enable/Disable addr data 			|
--
----------------------------------------------------------------------------------


library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity lcd_driver is
    Generic (
        -- Input clk frequency is given as 50MHz
        -- Internal clk frequency is 200Hz
        -- Number picked such that T = 5 ms
        constant cnt_max    : integer := 83333--333
    );
    Port (
        clk         		: in std_logic;
        reset       		: in std_logic;
        sys_fb       		: in std_logic;
        sys_en		 		: in std_logic;
		sys_prog			: in std_logic;
		address				: in std_logic;
        data		 		: in std_logic_vector(15 downto 0);
        data_out        	: out std_logic_vector(7 downto 0);
        enable_out      	: out std_logic;
        mode_select_out 	: out std_logic
	);
end lcd_driver;

architecture Behavioral of lcd_driver is

type word_mode is array (0 to 7) of std_logic_vector(7 downto 0);

-- Define signals here
signal lut_sel      		: integer range 0 to 47;
signal enable_sel   		: integer range 0 to 3;
signal clk_enable   		: std_logic := '1';
signal clk_cnt      		: integer range 0 to cnt_max;
signal sys_state_ascii 	    : word_mode;
signal sys_mode_ascii		: word_mode;
signal sys_en_ascii         : word_mode;

-- Function to convert hex into ascii
function hex_to_ascii(hex_code : std_logic_vector(3 downto 0))
		return std_logic_vector is
	variable output : std_logic_vector(7 downto 0) := x"30";
begin
	case hex_code is
		when x"0" => output := x"30";
		when x"1" => output := x"31";
		when x"2" => output := x"32";
		when x"3" => output := x"33";
		when x"4" => output := x"34";
		when x"5" => output := x"35";
		when x"6" => output := x"36";
		when x"7" => output := x"37";
		when x"8" => output := x"38";
		when x"9" => output := x"39";
		when x"A" => output := x"41";
		when x"B" => output := x"42";
		when x"C" => output := x"43";
		when x"D" => output := x"44";
		when x"E" => output := x"45";
		when x"F" => output := x"46";
		when others => output := x"30";
	end case;
	
	return output;
	
end hex_to_ascii;

begin
    -- Clock enabler
    process(clk)
    begin
        if rising_edge(clk) then
            if clk_cnt = cnt_max then
                clk_cnt <= 0;
                clk_enable <= '1';
            else
                clk_cnt <= clk_cnt + 1;
                clk_enable <= '0';
            end if;
        end if;    
    end process;
    
    -- enable_out selection clock
    process(clk)
    begin
		if rising_edge(clk) and clk_enable = '1' then
            if enable_sel = 3 then
                enable_sel <= 1;
            else
                enable_sel <= enable_sel + 1;
            end if;
        end if;
    end process;
    
    -- data_out selection clock
    process(clk)
    begin
		if rising_edge(clk) and clk_enable = '1' and enable_sel = 3 then
            if lut_sel = 47 then
                lut_sel <= 10;
            else
                lut_sel <= lut_sel + 1;
            end if;
        end if;
    end process;
	
	-- Mux for mode
	process(sys_prog)
	begin
		if sys_prog = '0' then
			sys_mode_ascii <= (x"4F", x"70", x"65", x"72", x"61", x"74", x"65", x"20"); -- Operate
		else
			sys_mode_ascii <= (x"50", x"72", x"6F", x"67", x"72", x"61", x"6D", x"20"); -- Program
		end if;
	end process;
	 
	-- Mux for state
	process(reset, sys_fb)
	begin
	if reset = '1' then
		sys_state_ascii <= (x"52", x"65", x"73", x"65", x"74", x"20", x"20", x"20"); -- Reset
	else
		if sys_fb = '1' then
			sys_state_ascii <= (x"46", x"6F", x"72", x"77", x"61", x"72", x"64", x"20"); -- Forward
		else
			sys_state_ascii <= (x"42", x"61", x"63", x"6B", x"77", x"61", x"72", x"64"); -- Backward
		end if;
	end if;
	end process;
     
    -- Mux for sys enable ascii
    process(sys_en)
    begin
        if sys_en = '1' then
            sys_en_ascii <= (x"45", x"6E", x"61", x"62", x"6C", x"65", x"20", x"20"); -- Enable
        else
            sys_en_ascii <= (x"44", x"69", x"73", x"61", x"62", x"6C", x"65", x"20"); -- Disable
        end if;
    end process;
    
    -- LUT for enable_out default 0
    with enable_sel select enable_out <=
        '1' when 0,
        '0' when 1,
        '1' when 2,
        '0' when 3,
        '0' when others;
        
    -- LUT for data_out and mode_select_out default is #ff and 0 respectively
    process(lut_sel)
    begin
        case lut_sel is
            -- Initialize
            when 0 => data_out <= x"38"; mode_select_out <= '0';
            when 1 => data_out <= x"38"; mode_select_out <= '0';  
            when 2 => data_out <= x"38"; mode_select_out <= '0';  
            when 3 => data_out <= x"38"; mode_select_out <= '0';  
            when 4 => data_out <= x"38"; mode_select_out <= '0';  
            when 5 => data_out <= x"38"; mode_select_out <= '0';  
            when 6 => data_out <= x"01"; mode_select_out <= '0';  
            when 7 => data_out <= x"0c"; mode_select_out <= '0';  
            when 8 => data_out <= x"06"; mode_select_out <= '0';  
            when 9 => data_out <= x"80"; mode_select_out <= '0';
            -- Op/Prog			
			when 10 => data_out <= sys_mode_ascii(0); mode_select_out <= '1';
            when 11 => data_out <= sys_mode_ascii(1); mode_select_out <= '1';
            when 12 => data_out <= sys_mode_ascii(2); mode_select_out <= '1';
            when 13 => data_out <= sys_mode_ascii(3); mode_select_out <= '1';
            when 14 => data_out <= sys_mode_ascii(4); mode_select_out <= '1';
            when 15 => data_out <= sys_mode_ascii(5); mode_select_out <= '1';
            when 16 => data_out <= sys_mode_ascii(6); mode_select_out <= '1';
            when 18 => data_out <= sys_mode_ascii(7); mode_select_out <= '1';
            -- Space
            when 19 => data_out <= x"FE"; mode_select_out <= '1';  
            -- System State
            when 20 => data_out <= sys_state_ascii(0); mode_select_out <= '1';
            when 21 => data_out <= sys_state_ascii(1); mode_select_out <= '1';
            when 22 => data_out <= sys_state_ascii(2); mode_select_out <= '1';
            when 23 => data_out <= sys_state_ascii(3); mode_select_out <= '1';
            when 24 => data_out <= sys_state_ascii(4); mode_select_out <= '1';
            when 25 => data_out <= sys_state_ascii(5); mode_select_out <= '1';
            when 26 => data_out <= sys_state_ascii(6); mode_select_out <= '1';
            when 27 => data_out <= sys_state_ascii(7); mode_select_out <= '1';
            -- Newline
            when 28 => data_out <= x"C0"; mode_select_out <= '0'; 
            -- Enable / Disable
            when 29 => data_out <= sys_en_ascii(0); mode_select_out <= '1';
            when 30 => data_out <= sys_en_ascii(1); mode_select_out <= '1';
            when 31 => data_out <= sys_en_ascii(2); mode_select_out <= '1';
            when 32 => data_out <= sys_en_ascii(3); mode_select_out <= '1';
            when 33 => data_out <= sys_en_ascii(4); mode_select_out <= '1';
            when 34 => data_out <= sys_en_ascii(5); mode_select_out <= '1';
            when 35 => data_out <= sys_en_ascii(6); mode_select_out <= '1';
            when 36 => data_out <= sys_en_ascii(7); mode_select_out <= '1';
            -- Space
            when 37 => data_out <= x"FE"; mode_select_out <= '1';
			-- Address ex. x00
			when 38 => data_out <= x"78"; mode_select_out <= '1';
			when 39 => data_out <= hex_to_ascii(address(7 downto 4)); mode_select_out <= '1';
			when 40 => data_out <= hex_to_ascii(address(3 downto 0)); mode_select_out <= '1';
            -- Space
			when 41 => data_out <= x"FE"; mode_select_out <= '1';
			-- Data ex. xA0A0
			when 42 => data_out <= x"78"; mode_select_out <= '1';
            when 43 => data_out <= hex_to_ascii(data(15 downto 12)); mode_select_out <= '1';
            when 44 => data_out <= hex_to_ascii(data(11 downto 8)); mode_select_out <= '1';
            when 45 => data_out <= hex_to_ascii(data(7 downto 4)); mode_select_out <= '1';
            when 46 => data_out <= hex_to_ascii(data(3 downto 0)); mode_select_out <= '1';
			-- Jump to first line after 'System'
			when 47 => data_out <= x"87"; mode_select_out <= '0';
            -- Catch errors
            when others => data_out <= x"FF"; mode_select_out <= '1';
        end case;
    end process;
    
end Behavioral;