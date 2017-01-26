library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity top_level is
	port(
		CLOCK_50 : in std_logic;
		KEY		: in std_logic_vector (3 downto 0);
		LEDG		: out std_logic_vector(7 downto 0) := X"00";
		
		SRAM_ADDR	: out std_logic_vector(17 downto 0);
		SRAM_DQ		: inout std_logic_vector(15 downto 0);
		SRAM_WE_N	: out std_logic;
		SRAM_OE_N	: out std_logic;
		SRAM_UB_N	: out std_logic;
		SRAM_LB_N	: out std_logic;
		SRAM_CE_N	: out std_logic;
		
		ROW_SEL	: in std_logic_vector(4 downto 0);
		COL_SEL	: out std_logic_vector(3 downto 0);
		
		LCD_DATA	: out std_logic_vector(7 downto 0);
		LCD_EN	: out std_logic;
		LCD_RS	: out std_logic;
		LCD_ON	: out std_logic;
		
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : out std_logic_vector(7 downto 0)
	);
end top_level;

architecture Behavioral of top_level is

	component system_controller is
		port (
			clk_50			: in std_logic;
			reset_key		: in std_logic;
			op_prog_mode	: out std_logic;
			
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
	end component;

begin

	LCD_ON	<= '1';
	HEX6		<= X"FF";
	HEX7		<= X"FF";

	Inst_system_controller: system_controller
	port map (
		clk_50			=> CLOCK_50,
		reset_key		=> KEY(0),
		op_prog_mode	=> LEDG(0),
		
		sram_addr	=> SRAM_ADDR,
		sram_dq		=> SRAM_DQ,
		sram_we_n	=> SRAM_WE_N,
		sram_oe_n	=> SRAM_OE_N,
		sram_ub_n	=> SRAM_UB_N,
		sram_lb_n	=> SRAM_LB_N,
		sram_ce_n	=> SRAM_CE_N,
		
		row_sel	=> ROW_SEL,
		col_sel	=> COL_SEL,
		
		lcd_data_out	=> LCD_DATA,
		lcd_enable_out	=> LCD_EN,
		lcd_select_out	=> LCD_RS,
		
		hex0	=> HEX0,
		hex1	=> HEX1,
		hex2	=> HEX2,
		hex3	=> HEX3,
		hex4	=> HEX4,
		hex5	=> HEX5
	);

end Behavioral;