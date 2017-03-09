LIBRARY ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY sys_clk IS	
		 GENERIC (
			  CONSTANT REF_CLK : integer := 50000000;  --  50.0 MHz   
			  CONSTANT OUT_CLK : integer := 10000000); --  10.0 MHz 
		 PORT (
			  SIGNAL oCLK 		: INOUT std_logic;	  
			  SIGNAL iCLK 		: IN std_logic;		  
			  SIGNAL iRST_N 	: IN std_logic);
END sys_clk;



ARCHITECTURE Arch OF sys_clk IS

    SIGNAL DIV 	: std_logic_vector (25 DOWNTO 0):="00"&X"000000";
BEGIN


 PROCESS(iCLK, iRST_N)
 BEGIN

	IF (iRST_N='0') THEN 
		DIV <= "00"&X"000000"; 
		oCLK <= '0'; 
	ELSIF rising_edge(iCLK) THEN 
		IF DIV >= REF_CLK/OUT_CLK/2 - 1 THEN
			 DIV  <= "00"&X"000000"; 	
			 oCLK <= NOT oCLK; 	
		ELSE
			 DIV  <= DIV + '1'; 
		END IF;
	END IF;
 END PROCESS;

END Arch;

