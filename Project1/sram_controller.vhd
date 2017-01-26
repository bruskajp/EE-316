library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sram_controller is
	port
	(
		r_w 				: in std_logic;
		clk 				: in std_logic;
		addr 				: in std_logic_vector (17 downto 0);
		r_w_en 				: in std_logic;
		data_in 			: in std_logic_vector (15 downto 0);
		data_out 			: out std_logic_vector (15 downto 0);
		r_w_status 			: out std_logic;

		sram_addr 			: out std_logic_vector (17 downto 0);
		sram_i_o  			: inout std_logic_vector (15 downto 0);
		sram_n_we 			: out std_logic;
		sram_n_oe 			: out std_logic;
		sram_n_ce 			: out std_logic;
		sram_n_ub 			: out std_logic;
		sram_n_lb 			: out std_logic
	);
end sram_controller;

architecture behavior of sram_controller is
	
	signal buf_data_in 	: std_logic_vector (15 downto 0);
	signal buf_r_w 		: std_logic := '0';
	signal buf_r_w_en 	: std_logic := '0'; 
	signal flag_r_w_en 	: std_logic := '0';
	
	type state_type is (s0, s1, s2);
	signal state : state_type := s0;

begin 
	
	sram_n_ce <= '0';
	sram_n_ub <= '0';
	sram_n_lb <= '0';

	process (clk)
	begin
		if rising_edge(clk) then
			if buf_r_w = '1' then
				sram_i_o <= buf_data_in;
			else
				sram_i_o <= "ZZZZZZZZZZZZZZZZ";
			end if;
		end if;
	end process;
	
	process (clk)
	begin
		if rising_edge(clk) then
			sram_addr <= addr;
			buf_data_in <= data_in;
			if (buf_r_w = '0') then
				data_out <= sram_i_o;
			end if;
		end if;
	end process;
	
	process (clk)
	begin
		if rising_edge(clk) then
			buf_r_w_en <= r_w_en;
			if buf_r_w_en = '0' and r_w_en = '1' then
				flag_r_w_en <= '1';
			else
				flag_r_w_en <= '0';
			end if;
		end if;
	end process;
	
	process (clk)
	begin
		if rising_edge(clk) then
			case state is
				when s0 =>
					r_w_status <= '0';
					buf_r_w <= r_w;
					sram_n_oe <= '1';
					sram_n_we <= '1';
					if flag_r_w_en = '1' then
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