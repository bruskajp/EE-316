library ieee;
use ieee.std_logic_1164.all;

entity sram_controller is
	port
	(
		r_w : in std_logic;
		clock : in std_logic;
		addr : in std_logic;
		data_in : in std_logic;
		data_out : out std_logic;
	);
end sram_controller;

architecture behavior of sram_controller is
	-- signal ... 

begin 

end behavior;

