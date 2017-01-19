library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sram_controller is
	port
	(
		r_w 				: in std_logic;
		clk 				: in std_logic;
		addr 				: in std_logic_vector (19 downto 0);
		r_w_en 			: in std_logic;
		data_in 		: in std_logic_vector (15 downto 0);
		data_out 		: out std_logic_vector (15 downto 0);
		r_w_status 	: out std_logic;

		sram_addr 	: out std_logic_vector (19 downto 0);
		sram_i_o  	: inout std_logic_vector (15 downto 0);
		sram_n_we 	: out std_logic;
		sram_n_oe 	: out std_logic;
		sram_n_ce 	: out std_logic;
		sram_n_ub 	: out std_logic;
		sram_n_lb 	: out std_logic;
	);
end sram_controller;

architecture behavior of sram_controller is
	
	signal buf_data_in : std_logic_vector (15 downto 0);
	signal buf_r_w : std_logic;
	signal buf_n_r_w : std_logic;

	
	type state_type is (s0, s1, s2);
	signal en_state : state_type;
	signal r_w_state : state_type;

begin 
	
	sram_ce <= '0';
	sram_ub <= '0';
	sram_lb <= '0';
	
	tristate: for i in 0 to 15 generate
	begin
		sram_i_o(i) <= buf_data_in(i) when buf_r_w = '1' else 'Z';
	end generate tristate;

	process (clk) is
		if rising_edge(clk) then
			sram_addr <= addr;
			buf_data_in <= data_in;
			if (r_w_buf = '0') then
				data_out <= sram_i_o;
			end if;
		end if;
	end process;
	
	process (clk) is
		if rising_edge(clk) then
			case r_w_state is
				when s0 =>
					r_w_status <= '0';
					buf_r_w <= r_w;
					sram_n_oe <= '1';
					sram_n_we <= '1';
					if rising_edge(r_w_en) then
					-- if (r_w_en = '1') then
						state <= s1;
					else
						state <= s0;
					end if;
				when s1 =>
					r_w_status <= '1';
					if (buf_r_w = '0') then
						sram_n_oe <= '0';
					else
						sram_n_we <= '0';
					end if;
					state <= s2; 
				when s2 =>
					r_w_status <= '1';
					if (buf_r_w = '0') then
						sram_n_oe <= '0';
					else
						sram_n_we <= '0';
					end if;
					state <= s0;
			end case;
		end if;
	end process;

end behavior;

