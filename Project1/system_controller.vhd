library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity system_controller is
	port
	(
		clk : in std_logic;
		reset_key : in std_logic;
		keypress : in std_logic_vector (7 downto 0); -- check size
		data_out : out std_logic;
		op_prog_mode: out std_logic;
	);
end system_controller;

architecture behavior of system_controller is
	
	signal buf_f_b : std_logic;

	signal buf_resey_key : std_logic;
	signal flag_reset : std_logic;
	signal buf_keypress : std_logic_vector (15 downto 0); -- check size
	signal flag_keypress : std_logic_vector (15 downto 0); -- check size

	type state_type is (init, op_mode, prog_mode);
	signal state : state_type := init;

begin 
	
	process (clk)
	begin
		if rising_edge(clk) then	
			buf_reset_key <= reset_key;
			if buf_reset_key = '0' and reset_key = '1' then
				flag_reset <= '1';
			else
				flag_reset <= '0';
			end if;

			buf_keypress <= keypress;
			if buf_keypress = "0xFF" and keypress /= "0xFF" then
				flag_keypress <= keypress;
			else
				flag_keypress <= "0xFF";
			end if;
		end if;
	end process;
	
	process (clk)
	begin
		if rising_edge(clk) then
			case state is
				when init =>
					if counter_out = "0xFF" then
						state <= op_mode;
						buf_f_b <= '0';
						buf_clk_en <= '0';
						buf_addr_data <= '0';
					else
						buf_f_b <= '0';
						buf_clk_en <= '1';
						sram_r_w <= '1';
						sram_r_w_en <= '1';
						sram_addr <= counter_out;
						rom_addr <= counter_out;
						rom_in <= counter_out;
						sram_data_in <= rom_out;
					end if;
					counter_reset <= '0';
				when op_mode =>
					op_prog_mode <= '0';
					if flag_keypress = "0xF0" then -- L : check this
						buf_f_b <= buf_f_b xor '1';
					elsif flag_keypress = "0xF1" then -- H : check this
						buf_clk_en <= buf_clk_en xor '1';
					elsif flag_keypress = "0xF2" then -- Shift : check this
						state <= prog_mode;
					elsif flag_reset = '1' then
						state <= init;
						counter_reset <= '1';
					end if;
					sram_r_w <= '0';
					sram_r_w_en <= '1';
					sram_addr <= counter_out;
					data_out <= sram_data_out;
					counter_reset <= '0';
				when prog_mode =>
					op_prog_mode <= '1';
					if flag_keypress = "0xF0" and sram_r_w_stat = '0' then -- L : check this
						sram_r_w_en <= '1';
					elsif flag_keypress = "0xF1" then -- H : check this
						buf_addr_data <= buf_addr_data xor '1';
					elsif flag_keypress = "0xF2" then -- Shift : check this
						state <= op_mode;
						counter_reset <= '1';
					elsif flag_reset = '1' then
						state <= init;
						counter_reset <= '1';
					end if;
					buf_clk_en <= '0';
					sram_r_w <= '1';
					sram_addr <= keypad_addr;
					sram_data_in <= keypad_data_in;
			end case;
		end if;
	end process;

	-- add component for Controlling Output. 
	-- in: buf_addr_data
	-- out:  

	-- add component for Counter. 
	-- in: counter_reset, buf_f_b, buf_clk_en, clk
	-- out: counter_out
	
	-- add component for ROM. 
	-- in: rom_addr
	-- out: rom_out

	-- add component for SRAM Controller. 
	-- in: sram_data_in, sram_addr, sram_r_w, sram_r_w_en
	-- out: sram_r_w_stat, sram_data_out

end behavior;
