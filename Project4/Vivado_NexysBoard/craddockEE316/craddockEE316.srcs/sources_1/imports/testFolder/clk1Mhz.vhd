LIBRARY ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY clk1Mhz IS	
		 PORT (
			  SIGNAL samplingFreq 		: INOUT std_logic:= '1';
			  signal baudRate          : INOUT std_logic:= '1';
			  signal rx_clk            : inout std_logic:= '1';
			  signal tx_clk            : inout std_logic:= '1';	  
			  SIGNAL iCLK 		: IN std_logic);
END clk1Mhz;



ARCHITECTURE Arch OF clk1Mhz IS

    SIGNAL DIV 	: std_logic_vector (25 DOWNTO 0):="00"&X"000000";
    SIGNAL DIV2 	: std_logic_vector (25 DOWNTO 0):="00"&X"000000";
    SIGNAL DIV3 	: std_logic_vector (25 DOWNTO 0):="00"&X"000000";
    SIGNAL DIV4 	: std_logic_vector (25 DOWNTO 0):="00"&X"000000";
BEGIN

 PROCESS(iCLK) -- 11.52 kHz clock
 BEGIN

	IF rising_edge(iCLK) THEN 
		IF DIV >= 4341 THEN
			 DIV  <= "00"&X"000000"; 	
			 baudRate <= NOT baudRate; 	
		ELSE
			 DIV  <= DIV + '1'; 
		END IF;
	END IF;
 END PROCESS;

 PROCESS(iCLK) -- 1 MHz clock
 BEGIN

	IF rising_edge(iCLK) THEN 
		IF DIV2 >= 49 THEN 
			 DIV2  <= "00"&X"000000"; 	
			 samplingFreq <= NOT samplingFreq; 	
		ELSE
			 DIV2  <= DIV2 + '1'; 
		END IF;
	END IF;
 END PROCESS;
 
  PROCESS(iCLK) -- 1 MHz clock
 BEGIN

    IF rising_edge(iCLK) THEN       -- 11.52kHz*16 
        IF DIV3 >= 272 THEN 
             DIV3  <= "00"&X"000000";     
             rx_clk <= NOT rx_clk;     
        ELSE
             DIV3  <= DIV3 + '1'; 
        END IF;
    END IF;
 END PROCESS;

process(iCLK)
begin
IF rising_edge(iCLK) THEN       -- 115.20k*10 
        IF DIV4 >= 435 THEN 
             DIV4  <= "00"&X"000000";     
             tx_clk <= NOT tx_clk;     
        ELSE
             DIV4  <= DIV4 + '1'; 
        END IF;
    END IF;
 END PROCESS;
END Arch;
