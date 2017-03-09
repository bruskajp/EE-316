library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
    generic (constant divisor : integer := 83333); -- want the effective clock to be 600Hz, input clock is 50MHz, div by 83.3k
    Port ( iClk         : in  std_logic;
           iReset       : in  std_logic;		      -- KEY0
			  F_B				: in  std_logic;				-- KEY1
			  E_D				: in  std_logic;				-- KEY2	
   		  HEX0         : out std_logic_vector(6 downto 0);
			  HEX1         : out std_logic_vector(6 downto 0);
			  HEX2         : out std_logic_vector(6 downto 0);
			  HEX3         : out std_logic_vector(6 downto 0);
			  HEX4         : out std_logic_vector(6 downto 0);
			  HEX5         : out std_logic_vector(6 downto 0);
			  HEX6         : out std_logic_vector(6 downto 0);
			  HEX7         : out std_logic_vector(6 downto 0);
			  Tx				: out std_logic;
			  MOSI			: out std_logic;
			  CSN				: out std_logic;
			  SCK				: out std_logic;
			  scl				: inout std_logic;
			  sda				: inout std_logic;
			  clk_t			: inout std_logic := '0'	
			  );
end top_level;

architecture Structural of top_level is

---------------------------Components-----------------------

	component Reset_Delay is	
	PORT (
		SIGNAL iCLK 				: in std_logic;	
		SIGNAL oRESET 				: out std_logic
	);	
	end component;

	component clk_enabler is
	port (
			clock						: in  std_logic;
			clk_en					: out std_logic
		);
	end component;
	
	component btn_debounce_toggle is
   GENERIC (CONSTANT CNTR_MAX : std_logic_vector(15 downto 0) := X"FFFF");
	Port ( 
			  BTN_I 	 				: in   std_logic;
           CLK 		 			: in   std_logic;
           BTN_O 	 				: out  std_logic; 
			  TOGGLE_O 				: out  std_logic
			  );
	end component;

	component univ_bin_counter is
			generic (N: natural := 8);
			port (
				  clk						: in  std_logic;
				  syn_clr, en, up    : in  std_logic;
				  clk_en 				: in  std_logic := '1';
				  qo						: out std_logic_vector(N-1 downto 0)
			);
	end component;
	
	component Hex_ROM is
			port (
				  address				: in  std_logic_vector(7 downto 0);
				  clock					: in  std_logic;
				  q						: out std_logic_vector(15 downto 0)
				  );
   end component;
			
	component display_driver is
			port (
				  Input					: in  std_logic_vector(15 downto 0);
				  --clk						: in  std_logic;
				  HEX0					: out std_logic_vector(6 downto 0);
				  HEX1					: out std_logic_vector(6 downto 0);
				  HEX2					: out std_logic_vector(6 downto 0);
				  HEX3					: out std_logic_vector(6 downto 0);
				  HEX4					: out std_logic_vector(6 downto 0);
				  HEX5					: out std_logic_vector(6 downto 0);
				  HEX6					: out std_logic_vector(6 downto 0);
				  HEX7					: out std_logic_vector(6 downto 0)
			);
	end component;
	
	component TTL_Serial_Display is
			port (
				  Hex_IN 				: in  std_logic_vector (15 downto 0);
              iCLK         		: in  std_logic;
              Tx	       			: out std_logic);
	end component;
	
	component SPI_Display is
			port (
				  Hex_IN    			: in  std_logic_vector (15 downto 0);
				  iCLK      			: in  std_logic;
				  MOSI	   			: out std_logic;
				  CSN						: out std_logic;
				  SCK						: out std_logic
			);
	end component;
	
	component Interfacer is
	  PORT(
			CLK		: in std_logic;
			data_in	: in std_logic_vector(15 downto 0) := x"0000";
			sda		: inout std_logic;
			scl		: inout std_logic
			);
	end component;
			
-----------------------------Signals---------------------------------
	
	signal r_reg        				  : unsigned(3 downto 0);
	signal reset		  				  : std_logic;
	signal clk_en       				  : std_logic;
	signal clk_cnt      				  : integer range 0 to divisor:= 0;
	signal output       				  : integer range 0 to 15:= 0; 
   signal iReset_deb   				  : std_logic;	
	signal iCnt_en_deb, iF_B_deb    : std_logic;
	signal TOGGLE_up					  : std_logic;
	signal TOGGLE_en					  : std_logic; 
   signal reset_on					  : std_logic; 
	signal TOGGLE_Forward 			  : std_logic;
---------------------------------------------------------------------
	signal iROM							  : std_logic_vector(7 downto 0);
	signal oROM							  : std_logic_vector(15 downto 0);
---------------------------------------------------------------------

	constant cnt_max2					  : integer :=19999999;
	signal   clk_cnt2					  : integer range 0 to cnt_max2;
	signal   clk_en2					  : std_logic;
	
-----------------------------Buttons---------------------------------

	signal   clk_counter					  : integer range 0 to 3999999;
		
	signal   clk_counter2					  : integer range 0 to 3999999;

begin

--	process(iClk)
--	begin
--	if rising_edge(iClk) then
--		if (clk_cnt2 = cnt_max2) then
--			 clk_cnt2 <= 0;
--			 clk_en2 <= '1';
--		else
--			clk_cnt2 <= clk_cnt2 + 1;
--			clk_en2 <= '0';
--		end if;
--	end if;
--	end process;

	process(iClk)
	begin
		if rising_edge(iClk) then
			if (clk_counter = 50) then
				clk_t <= not clk_t;
				clk_counter <= 0;
			else
				clk_counter <= clk_counter + 1;
			end if;
		end if;
	end process;
	
	process(iClk)
	begin
		if rising_edge(iClk) then
			if (clk_t = '0') then
				clk_counter2 <= clk_counter2 +1;
			end if;
		end if;
	end process;

	Inst_clk_Reset_Delay: Reset_Delay	
		   port map(
			iCLK 	    => iClk,	
			oRESET    => reset
			);
			
	Inst_clk_enabler: clk_enabler
			port map(
			clock		 => iClk,
			clk_en	 => clk_en
			);

   Inst_iReset_debounce: btn_debounce_toggle
			generic map(CNTR_MAX => X"FFFF")     -- For simulation: use CNTR_MAX => X"0009", else use X"FFFF""     
			port map(
			BTN_I       => iReset,
			CLK         => iClk,
			BTN_O       => iReset_deb,
			TOGGLE_O    => open 						 -- Toggle output is not used in this design
			);                	
	
	Inst_iCnt_en_debounce: btn_debounce_toggle
			generic map(CNTR_MAX => X"FFFF") 	-- For simulation: use CNTR_MAX => X"0009", else use X"FFFF"
			port map(
			BTN_I		=> E_D,
			CLK	   => iClk,
			BTN_O		=> open,
			TOGGLE_O	=> TOGGLE_en
			);    		

	Inst_iF_B_debounce: btn_debounce_toggle
			generic map(CNTR_MAX => X"FFFF") 	-- For simulation: use CNTR_MAX => X"0009", else use X"FFFF"" 	
			port map(
			BTN_I		=> F_B,
			CLK	   => iClk,
			BTN_O		=> open,
			TOGGLE_O	=> TOGGLE_up
			);
			
-------------------------Component Definitions-----------------------	
		
	Inst_univ_bin_counter:	univ_bin_counter
			generic map(N => 8)
			port map(
			clk 	 	=> clk_en,
			qo  	 	=> iROM,
			en 	 	=> TOGGLE_en,
			up		 	=> TOGGLE_up,
			syn_clr	=> iReset_deb
			);
			
	Inst_Hex_ROM:	Hex_ROM
			port map(
			clock 	=> iClk,
			address  => iROM,
			q 			=> oROM
			);
			
	Inst_display_driver: display_driver
			port map(
		   Input	=> oROM,
         --clk  	=> clk_en,
		   HEX0	=> HEX0,
		   HEX1	=> HEX1,
		   HEX2	=> HEX2,
		   HEX3	=> HEX3,
		   HEX4	=> HEX4,
		   HEX5	=> HEX5,
		   HEX6	=> HEX6,
		   HEX7	=> HEX7
			);
	
	Inst_TTL_Serial_Display: TTL_Serial_Display
			port map(
			Hex_IN 	=> oROM,
			iClk	 	=> clk_en,
			Tx			=> Tx
			);
	
	Inst_SPI_Display: SPI_Display
			port map(
			Hex_IN	=> oROM,
			iClk		=> clk_en,
			MOSI		=> MOSI,
			CSN		=> CSN,
			SCK		=> SCK
			);
	
	Inst_Interfacer: Interfacer
			port map(
			CLK		=> iClk,
			data_in	=> oROM,
			sda		=> sda,
			scl		=> scl
			);

end Structural;
