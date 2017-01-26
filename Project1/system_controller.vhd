library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity system_controller is
	port
	(
		clk_50			: in std_logic;
		reset_key		: in std_logic;
		op_prog_mode	: out std_logic;
		--data_out			: out std_logic_vector (15 downto 0);
		
		sram_addr	: out std_logic_vector (17 downto 0);
		sram_dq		: inout std_logic_vector (15 downto 0);
		sram_we_n	: out std_logic;
		sram_oe_n	: out std_logic;
		sram_ub_n	: out std_logic;
		sram_lb_n	: out std_logic;
		sram_ce_n	: out std_logic;
		
		row_sel	: in std_logic_vector (4 downto 0);
		col_sel	: out std_logic_vector(3 downto 0);
		
		lcd_data_out 			: out std_logic_vector(7 downto 0);
		lcd_enable_out      	: out std_logic;
		lcd_select_out			: out std_logic;
		
		hex0, hex1, hex2, hex3, hex4, hex5 : out std_logic_vector (7 downto 0)
	);
end system_controller;

architecture behavior of system_controller is
	
	signal clk_cnt      	: integer range 0 to 500000;
	signal clk_slow		: std_logic := '0';
	
	signal keypress		: std_logic_vector (7 downto 0); 
	signal keypad_addr	: std_logic_vector (7 downto 0);
	signal keypad_data	: std_logic_vector (15 downto 0);

	
	signal buf_f_b 		: std_logic;
	signal buf_reset_key : std_logic;
	signal flag_reset 	: std_logic;
	signal buf_keypress 	: std_logic_vector (7 downto 0); 
	signal flag_keypress : std_logic_vector (7 downto 0); 

	signal deb_reset_key			: std_logic;
	signal buf_deb_reset_key	: std_logic;
	signal deb_keypress			:std_logic_vector (7 downto 0);
	signal buf_deb_keypress 	: std_logic_vector (7 downto 0); 
	
	type state_type is (init, op_mode, prog_mode);
	signal state : state_type := init;
	
	signal buf_addr_data 	: std_logic;
	signal buf_clk_en 		: std_logic := '0';
	signal counter_reset 	: std_logic;
	signal counter_out 		: std_logic_vector (7 downto 0);
	signal counter2_out 		: std_logic_vector (7 downto 0);
	signal rom_addr 			: std_logic_vector (7 downto 0);
	signal rom_out 			: std_logic_vector (15 downto 0);
	signal buf_op_prog_mode : std_logic;
	
	signal sram_cntlr_data_in 	: std_logic_vector (15 downto 0);
	signal sram_cntlr_addr 		: std_logic_vector (17 downto 0);
	signal sram_cntlr_r_w 		: std_logic;
	signal sram_cntlr_r_w_en 	: std_logic := '0';
	signal sram_cntlr_r_w_stat : std_logic;
	signal sram_cntlr_data_out : std_logic_vector (15 downto 0);
	
	signal key_out			: std_logic_vector(7 downto 0);
	signal keypress_out	: std_logic; -- unneeded

	component input_handler is
		generic (
			COUNT_MAX : integer := 500000
		);
		port (
			row_sel			: in std_logic_vector(4 downto 0);
			clk				: in std_logic;
			reset				: in std_logic;
			key_out			: out std_logic_vector(7 downto 0);
			col_sel			: out std_logic_vector(3 downto 0);
			keypress_out	: out std_logic
		);
	end component;
	
	component counter is 
		generic (
			constant cnt_max : integer := 50000000 -- fix this value 
		);
		port (
			iClk         : in std_logic;
			iReset       : in std_logic;
			is_forward	 : in std_logic;
			is_enabled   : in std_logic;
			output_data	 : out std_logic_vector(7 downto 0)		
		);
	end component;
	
	component rom is
		port (
			address	: in std_logic_vector (7 DOWNTO 0);
			clock		: in std_logic;
			q			: out std_logic_vector (15 DOWNTO 0)
		);
	end component;
	
	component sram_controller is
		port (
			r_w 					: in std_logic;
			clk 					: in std_logic;
			addr 					: in std_logic_vector (17 downto 0);
			r_w_en 				: in std_logic;
			data_in 				: in std_logic_vector (15 downto 0);
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
	end component;
	
	component display_driver is
	port (
		keycode				: in std_logic_vector(7 downto 0);
		sram_address		: in std_logic_vector(7 downto 0);
		sram_data			: in std_logic_vector(15 downto 0);
		write_address		: in std_logic;
		is_programming		: in std_logic;
		clk					: in std_logic;
		address				: out std_logic_vector(7 downto 0);
		data					: out std_logic_vector(15 downto 0)
	);
	end component;
	
	component seven_seg_driver is
		port(
			data     : in std_logic_vector(15 downto 0);
			address  : in std_logic_vector(7 downto 0);
			hex0		: out std_logic_vector(7 downto 0);
			hex1		: out std_logic_vector(7 downto 0);
			hex2		: out std_logic_vector(7 downto 0);
			hex3		: out std_logic_vector(7 downto 0);
			hex4		: out std_logic_vector(7 downto 0);
			hex5		: out std_logic_vector(7 downto 0)
		);
	end component;
	
	component lcd_driver is
		generic ( 
			constant cnt_max    : integer := 83333--333
		);
		port (
			clk         		: in std_logic;
			reset       		: in std_logic;
			sys_fb       		: in std_logic;
			sys_en		 		: in std_logic;
			sys_prog				: in std_logic;
			is_addr				: in std_logic;
			address				: in std_logic_vector(7 downto 0);
			data		 			: in std_logic_vector(15 downto 0);
			data_out        	: out std_logic_vector(7 downto 0);
			enable_out      	: out std_logic;
			mode_select_out 	: out std_logic
		);
	end component;
	
begin 
	
	Inst_input_handler: input_handler
	generic map (COUNT_MAX => 500000) 
	port map (
		row_sel			=> row_sel,
		clk				=> clk_50,
		reset				=> flag_reset,
		key_out			=> keypress,
		col_sel			=> col_sel,
		keypress_out	=> keypress_out
	);

	
	Inst_counter: counter
	generic map (cnt_max => 50000000)
	port map (
		iClk			=> clk_50,
		iReset 		=> counter_reset,
		is_forward	=> not buf_f_b,
		is_enabled	=> buf_clk_en,
		output_data => counter_out
	);
	
	Inst_counter2: counter
	generic map (cnt_max => 5000)
	port map (
		iClk			=> clk_50,
		iReset 		=> counter_reset,
		is_forward	=> not buf_f_b,
		is_enabled	=> buf_clk_en,
		output_data => counter2_out
	);
	
	Inst_rom: rom
	port map (
		address	=> rom_addr,
		clock		=> clk_50,
		q			=> rom_out
	);
	
	Inst_sram_controller: sram_controller
	port map (
		r_w			=> sram_cntlr_r_w,
		clk			=> clk_50,
		addr			=> sram_cntlr_addr,
		r_w_en		=> sram_cntlr_r_w_en,
		data_in		=> sram_cntlr_data_in,
		data_out		=> sram_cntlr_data_out,
		r_w_status	=> sram_cntlr_r_w_stat,
		
		sram_addr	=> sram_addr,
		sram_i_o		=> sram_dq,	
		sram_n_we	=> sram_we_n,
		sram_n_oe	=> sram_oe_n,
		sram_n_ce	=> sram_ce_n,
		sram_n_ub	=> sram_ub_n,
		sram_n_lb	=> sram_lb_n
	);
	
	Inst_display_driver: display_driver
	port map (
		keycode			=> flag_keypress,
		sram_address	=> sram_cntlr_addr(7 downto 0),
		sram_data		=> sram_cntlr_data_out,
		write_address	=> buf_addr_data,
		is_programming	=> buf_op_prog_mode,
		clk				=> clk_50,
		address			=> keypad_addr,
		data				=> keypad_data
	);
	
	Inst_seven_seg_driver: seven_seg_driver
	port map(
		data		=> keypad_data,
		address	=> keypad_addr, 
		hex0		=> hex0,
		hex1		=> hex1,
		hex2		=> hex2,
		hex3		=> hex3,
		hex4		=> hex4,
		hex5		=> hex5
	);
	
	Inst_lcd_driver: lcd_driver
	generic map ( cnt_max => 83333)
	port map(
		clk         		=> clk_50,
		reset       		=> not reset_key,
		sys_fb       		=> not buf_f_b,
		sys_en		 		=> buf_clk_en,
		sys_prog				=> buf_op_prog_mode,
		is_addr				=> buf_addr_data,
		address				=> keypad_addr,
		data		 			=> keypad_data,
		data_out        	=> lcd_data_out,
		enable_out      	=> lcd_enable_out,
		mode_select_out	=> lcd_select_out
	);
	
	process(clk_50)
	begin
		if rising_edge(clk_50) then
			if clk_cnt = 100000 then
				clk_cnt <= 0;
				buf_keypress <= keypress;
				if buf_keypress = X"FF" and keypress /= X"FF" then
					deb_keypress <= keypress;
				else
					deb_keypress <= X"FF";
				end if;
			else
				clk_cnt <= clk_cnt + 1;
			end if;
		end if;    
	end process;
	
	process (clk_50)
	begin
		if rising_edge(clk_50) then
			buf_deb_keypress <= deb_keypress;
			if buf_deb_keypress = X"FF" and deb_keypress /= X"FF" then
				flag_keypress <= deb_keypress;
			else
				flag_keypress <= X"FF";
			end if;
		end if;
	end process;
	
	process (clk_50)
	begin
		if rising_edge(clk_50) then
			case state is
				when init =>
					counter_reset <= '0';
					if counter2_out = X"FF" then
						state <= op_mode;
						buf_f_b <= '0';
						buf_clk_en <= '0';
						buf_addr_data <= '0';
						counter_reset <= '1';
					else
						buf_f_b <= '0';
						buf_clk_en <= not buf_clk_en;
						sram_cntlr_r_w <= '1';
						sram_cntlr_r_w_en <= not sram_cntlr_r_w_en;
						sram_cntlr_addr <= "0000000000" & counter2_out;
						rom_addr <= counter2_out;
						sram_cntlr_data_in <= rom_out;
					end if;
				when op_mode =>
					op_prog_mode <= '0';
					buf_op_prog_mode <= '0';
					if flag_keypress = X"F2" then -- L 
						buf_f_b <= not buf_f_b;
					elsif flag_keypress = X"F1" then -- H 
						buf_clk_en <= not buf_clk_en;
					elsif flag_keypress = X"F0" then -- Shift
						state <= prog_mode;
						sram_cntlr_r_w_en <= '0';
					elsif reset_key = '0' then
						state <= init;
						counter_reset <= '1';
					else 
					end if;
					sram_cntlr_r_w <= '0';
					sram_cntlr_r_w_en <= not sram_cntlr_r_w_en;
					sram_cntlr_addr <= "0000000000" & counter_out;
					rom_addr <= counter_out; -- DEBUGGING CODE
					--data_out <= sram_cntlr_data_out;
					counter_reset <= '0';
				when prog_mode =>
					op_prog_mode <= '1';
					buf_op_prog_mode <= '1';
					if flag_keypress = X"F2" and sram_cntlr_r_w_stat = '0' then -- L
						sram_cntlr_r_w_en <= '1';
					elsif flag_keypress = X"F1" then -- H 
						buf_addr_data <= not buf_addr_data;
					elsif flag_keypress = X"F0" then -- Shift 
						state <= op_mode;
						counter_reset <= '1';
					elsif reset_key = '0' then
						state <= init;
						counter_reset <= '1';
					else 
						sram_cntlr_r_w_en <= '0';
					end if;  
					buf_clk_en <= '0';
					sram_cntlr_r_w <= '1';
					sram_cntlr_addr <= "0000000000" & keypad_addr;
					sram_cntlr_data_in <= keypad_data;
			end case;
		end if;
	end process;
	
end behavior;
