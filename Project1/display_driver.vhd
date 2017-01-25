-- Author: Zander Blasingame
-- Class: EE 316 Spring 2017

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity display_driver is
	port (
		keycode				: in std_logic_vector(3 downto 0);
		flag_keypress		: in std_logic;
		sram_address		: in std_logic_vector(7 downto 0);
		sram_data			: in std_logic_vector(15 downto 0);
		write_address		: in std_logic;
		is_programming		: in std_logic;
		address				: out std_logic_vector(7 downto 0);
		data				: out std_logic_vector(15 downto 0)
	);
end display_driver;

architecture behavior of display_driver is
	
	-- Internal Register Signals
	signal data_register		: std_logic_vector(15 downto 0) := x"0000";
	signal address_register		: std_logic_vector(7 downto 0) := x"0000";
	
begin
	-- Demux for piping input into correct register
	process(write_address, keycode, flag_keypress)
	begin
		if write_address = '1' and flag_keypress = '1' then
			address_register(3 downto 0) <= keycode;
			address_register(7 downto 4) <= address_register(3 downto 0);
		elsif flag_keypress = '1' then
			data_register(3 downto 0) <= keycode;
			data_register(7 downto 4) <= data_register(3 downto 0);
			data_register(11 downto 8) <= data_register(7 downto 4);
			data_register(15 downto 12) <= data_register(11 downto 8);
		end if;
	end process;
	
	-- Mux for piping selecting data output stream
	process(is_programming, address_register, data_register)
	begin
		if is_programming = '1' then
			address <= address_register;
			data <= data_register;
		else
			address <= sram_address;
			data <= sram_data;
		end if;
	end process;
end behavior;