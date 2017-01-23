-- Author: Zander Blasingame
-- Class: EE 316 Spring 2017

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity input_handler is
	generic (
		DIVIDER : integer := 100
	);
	port (
		row_sel			: in std_logic_vector(4 downto 0);
		clk				: in std_logic;
		reset			: in std_logic;
		key_out			: out std_logic_vector(7 downto 0);
		col_sel			: out std_logic_vector(3 downto 0);
		keypress_out	: out std_logic
	);
end input_handler;

architecture input_handler of input_handler is

	signal counter					: integer range 0 to DIVIDER - 1 := 0;
	signal clk_en					: std_logic := '0';
	signal keypress					: std_logic := '0';
	signal buf_col_sel				: std_logic_vector(3 downto 0);
	signal rev_row_sel				: std_logic_vector(4 downto 0);
	signal rev_col_sel				: std_logic_vector(3 downto 0);
	
	signal internal_state_sel		: integer range 0 to 3 := 0;
	signal key_address				: std_logic_vector(8 downto 0);
	
begin
	-- Clock Enabler 
	process(clk)
	begin
		if reset = '1' then
			counter <= 0;
		elsif rising_edge(clk) then
			if counter < DIVIDER then
				counter <= counter + 1;
			else
				counter <= 0;
				clk_en <= not clk_en;	
			end if;
		end if;
	end process;

	-- col_sel selection clock
	process(clk)
	begin
		if reset = '1' then
			internal_state_sel <= 0;
		elsif rising_edge(clk) and keypress = '0' then
			if internal_state_sel < 4 then
				internal_state_sel <= internal_state_sel + 1;
			else
				internal_state_sel <= 0;
			end if;
		end if;
	end process;

	-- Keypress
	process(row_sel)
	begin
		if reset = '1' then
			keypress <= '0';
		else
			keypress <= not(row_sel(4) and row_sel(3) and row_sel(2)
							and row_sel(1) and row_sel(0));
		end if;
		
		keypress_out <= keypress;
	end process;

	-- Mux for col_sel
	process(internal_state_sel)
	begin
		case internal_state_sel is
			when 0 => buf_col_sel <= "0111";
			when 1 => buf_col_sel <= "1011";
			when 2 => buf_col_sel <= "1101";
			when 3 => buf_col_sel <= "1110";
			when others => buf_col_sel <= "1111";
		end case;
		col_sel <= buf_col_sel;
	end process;

	-- LUT selection
	process(row_sel, buf_col_sel)
	begin
		key_address <= buf_col_sel & row_sel;
		case key_address is
			when "111011110" => key_out <= x"0A";	
			when "110111110" => key_out <= x"0B";	
			when "101111110" => key_out <= x"0C";
			when "011111110" => key_out <= x"0D";	
			when "111011101" => key_out <= x"01";	
			when "110111101" => key_out <= x"02";	
			when "101111101" => key_out <= x"03";	
			when "011111101" => key_out <= x"0E";	
			when "111011011" => key_out <= x"04";	
			when "110111011" => key_out <= x"05";	
			when "101111011" => key_out <= x"06";	
			when "011111011" => key_out <= x"0F";	
			when "111010111" => key_out <= x"07";	
			when "110110111" => key_out <= x"08";	
			when "101110111" => key_out <= x"09";	
			when "011110111" => key_out <= x"F0"; -- Shift
			when "110101111" => key_out <= x"00";	
			when "101101111" => key_out <= x"F1"; -- H
			when "011101111" => key_out <= x"F2"; -- L
			when others => key_out <= x"FF";
		end case;
	end process;

end input_handler;