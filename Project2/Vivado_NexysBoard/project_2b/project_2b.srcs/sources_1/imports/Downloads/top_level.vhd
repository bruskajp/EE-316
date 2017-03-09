library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity top_level is
		port (
		iReset					: in std_logic; 
		iClk					: in std_logic; 
		iCnt_en 				: in std_logic;	
		iF_B                    : in std_logic;
		An_OUT                  : out std_logic_vector(7 downto 0);
		SevSeg_OUT              : out std_logic_vector(7 downto 0);
		Tx                      : out std_logic;
		SCK                     : out std_logic;
		CSN                     : out std_logic;
		MOSI                    : out std_logic;
		SDA                     : inout std_logic;
		SCL                     : inout std_logic;
		high                    : out std_logic 
		);
end top_level;

architecture Structural of top_level is

	component clk_enabler is
            GENERIC (
            CONSTANT cnt_max : integer     := 99999999);       	
            port(	
            clock						   : in std_logic;	 
            reset                          : in std_logic;
            clk_en					       : out std_logic
            );
	end component;
	
	component sys_clk is	
		 GENERIC (
			  CONSTANT REF_CLK : integer := 50000000;  --  50.0 MHz   
			  CONSTANT OUT_CLK : integer := 10000000); --  10.0 MHz 
		 PORT (
			  SIGNAL oCLK 		: INOUT std_logic;	  
			  SIGNAL iCLK 		: IN std_logic;		  
			  SIGNAL iRST_N 	: IN std_logic);	
	end component;	

	component Reset_Delay IS	
		 PORT (
			  SIGNAL iCLK 		: IN std_logic;	
			  SIGNAL oRESET 	: OUT std_logic
				);	
	end component;	
	  
    component univ_bin_counter is
       generic(N: integer := 4);
       port(
          clk, reset                : in std_logic;
          syn_clr, en, up           : in std_logic;
          load                      : in std_logic;
          clk_en                    : in std_logic;
          d                         : in std_logic_vector(N-1 downto 0);
          max                       : in unsigned(N-1 downto 0);
          min                       : in unsigned(N-1 downto 0);
          q                         : out std_logic_vector(N-1 downto 0)
       );
    end component;
    
    component btn_debounce_toggle is
    GENERIC (
    CONSTANT CNTR_MAX   : std_logic_vector(15 downto 0));                   --:=X"FFFF"
        Port ( BTN_I 	: in  STD_LOGIC;
               CLK 		: in  STD_LOGIC;
               BTN_O 	: out  STD_LOGIC;
               TOGGLE_O : out  STD_LOGIC);
    end component;
    
    component Nexys4_Display is
    Port ( HEX_IN       : in STD_LOGIC_VECTOR (15 downto 0);
           iCLK         : in STD_LOGIC;
           An_OUT       : out STD_LOGIC_VECTOR (7 downto 0);
           SevSeg_OUT   : out STD_LOGIC_VECTOR (7 downto 0));
    end component;    
    
    component TTL_Serial_Display is
        --generic (
            --constant TTL_Driver: unsigned:= X"291E");
            port(
               Hex_IN           : in STD_LOGIC_VECTOR (15 downto 0);
               iCLK             : in STD_LOGIC;
               Tx               : out STD_LOGIC);
    end component;
    
    component SPI_Display is
        Port ( 
               Hex_IN           : in STD_LOGIC_VECTOR (15 downto 0);
               iCLK             : in STD_LOGIC;
               MOSI             : out STD_LOGIC;
               CSN              : out STD_LOGIC;
               SCK             : out STD_LOGIC);
    end component;
	
	COMPONENT blk_mem_LUT
      PORT (
        clka : IN STD_LOGIC;
        ena  : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
      );
    END COMPONENT;
    
    COMPONENT interfacer
      PORT (
        CLK		   : in std_logic;
        data_in    : in std_logic_vector(15 downto 0) := x"0000";
        sda        : inout std_logic;
        scl        : inout std_logic
	  );
    END COMPONENT;
    
	signal clk					                    : std_logic;
	signal clk_enable              					: std_logic;
	signal reset, DelayReset	                    : std_logic;
    signal DelayReset_n                             : std_logic;
    signal iReset_deb                       	    : std_logic;
    signal iCnt_en_toggle, iF_B_toggle              : std_logic;
         
    signal oCOUNT                   : std_logic_vector(3 downto 0);
	signal hex						: std_logic_vector(15 downto 0);
     
                
begin
    
    high <= '1';
    
	DelayReset <= reset;
	DelayReset_n  <= not DelayReset;
	
	Inst_iCnt_en_debounce: btn_debounce_toggle
			generic map(CNTR_MAX => X"0009") 	-- For simulation: use CNTR_MAX => X"0009", else use X"FFFF"
			port map(
			BTN_I		=> iCnt_en,
			CLK	        => iCLK,
			BTN_O		=> open,
			TOGGLE_O	=> iCnt_en_toggle);    			
	
	Inst_iReset_debounce: btn_debounce_toggle
            generic map(CNTR_MAX => X"0009")     -- For simulation: use CNTR_MAX => X"0009", else use X"FFFF"
            port map(
            BTN_I        => iReset,
            CLK          => iCLK,
            BTN_O        => iReset_deb,
            TOGGLE_O     => open);                         
                    
	Inst_iF_B_debounce: btn_debounce_toggle
			generic map(CNTR_MAX => X"0009") 	-- For simulation: use CNTR_MAX => X"0009", else use X"FFFF"" 	
			port map(
			BTN_I		=> iF_B,
			CLK	        => iCLK,
			BTN_O		=> open,
			TOGGLE_O	=> iF_B_toggle);    			
			
	
	Inst_clk_Reset_Delay: Reset_Delay	
		    port map(
			iCLK 	    => iCLK,	
			oRESET      => reset
			);			
			
    Inst_clk_enabler: clk_enabler
            generic map(
            cnt_max     => 9999999 )  --***           -- For simulation: use cnt_max     => 99 else use 9999999 (for 1 Hz counters)                                                
            port map( 
            clock       => clk,                 -- output from sys_clk   -- 10 MHz clock 
            reset       => iReset_deb,
            clk_en      => clk_enable              -- enable every 10,000th sys_clk edge
            );	
            
    Inst_Univ_Counter: univ_bin_counter
            generic map(N => 4)
            port map(
            clk             => clk,
            reset           => iReset_deb,
            syn_clr         => DelayReset,
            en              => iCnt_en_toggle,
            up              => iF_B_toggle,
            load            => '0',                    
            clk_en          => clk_enable,                   
            d               => (others => '0'),                   
            max             => "1000",
            min             => "0000",
            q               => oCOUNT   
            );
			
	Inst_sys_clk: sys_clk 
		  generic map (
		  REF_CLK   => 100000000, --  100.0 MHz   
		  OUT_CLK   =>  10000000) --   10.0 MHz 
		  port map (
		  oCLK 		=> clk,	  
		  iCLK 		=> iCLK,		  
		  iRST_N 	=> DelayReset_n
		  );
		  
    Inst_Hex_Counter: Nexys4_Display
        port map (
        HEX_IN      => hex,
        iCLK        => clk,
        An_OUT      => An_OUT,
        SevSeg_OUT  => SevSeg_OUT
        );	
               
    Inst_TTL_Display: TTL_Serial_Display 
    --generic map(
    --TTL_Driver => X"291E")
       Port map( 
              Hex_IN     => hex,
              iCLK       => iClk,
              Tx         => Tx);
              
    Inst_SPI_Display: SPI_Display 
      Port map( 
             Hex_IN  => hex,
             iCLK    => clk,
             MOSI    => MOSI,
             CSN     => CSN,
             SCK     => SCK);  
		
	your_instance_name : blk_mem_LUT
          PORT MAP (
            clka => iCLK,
            ena  => '1',
            addra => oCOUNT,
            douta => hex
          );
    Inst_Interfacer : interfacer
          PORT MAP (
            CLK        => iCLK,
            data_in    => hex,
            sda        => SDA,
            scl        => SCL
          );

end Structural;

