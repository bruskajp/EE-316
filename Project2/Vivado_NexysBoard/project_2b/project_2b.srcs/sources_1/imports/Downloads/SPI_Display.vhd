library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI_Display is
    Port ( 
           Hex_IN 		: in STD_LOGIC_VECTOR (15 downto 0);
           iCLK         : in STD_LOGIC;
           MOSI	       	: out STD_LOGIC;
		   CSN			: out STD_LOGIC;
		   SCK			: out STD_LOGIC);
end SPI_Display;

architecture Behavioral of SPI_Display is

signal DIV : unsigned(15 DOWNTO 0) :=X"0000"; 

--Signals for StateMachine:
type stateType is range 0 to 18;
Signal Sel		: integer range 0 to 11;
Signal Q		: std_logic;
signal CS	    : stateType;
signal X1,X2,X3,X4	: std_logic_vector (3 downto 0);
signal extend		: std_logic_vector (3 downto 0);
signal clk_en		: std_logic;
signal HEX2_Data1	: std_logic_vector (7 downto 0);
signal HEX2_Data2	: std_logic_vector (7 downto 0);
signal HEX2_Data3	: std_logic_vector (7 downto 0);
signal HEX2_Data4	: std_logic_vector (7 downto 0);
signal LUT_Data		: std_logic_vector (7 downto 0);
signal sCSN			: std_logic := '1';
signal sSCK		    : std_logic := '0';

BEGIN

LUTConversion:
Process(Hex_IN)
begin
        X1 <= Hex_IN(15 downto 12);
        X2 <= Hex_IN(11 downto 8);           
        X3 <= Hex_IN(7 downto 4);
        X4 <= Hex_IN(3 downto 0);	
		extend <= "0000"; 
end process; 

Process(X1, X2, X3, X4)
begin          
        HEX2_Data1 <= extend & X1;    
		HEX2_Data2 <= extend & X2; 
		HEX2_Data3 <= extend & X3; 
		HEX2_Data4 <= extend & X4; 
end process;  

LUTMux:
process (Sel)
begin
	if (Sel = 0) then
		LUT_Data <= X"76";
	elsif (Sel = 1) then
		LUT_Data <= X"76";
	elsif (Sel = 2) then
		LUT_Data <= X"76";
	elsif (Sel = 3) then
        LUT_Data <= X"76";		
	elsif (Sel = 4) then
		LUT_Data <= X"79";
	elsif (Sel = 5) then
		LUT_Data <= X"00";
	elsif (Sel = 6) then
	    LUT_Data <= X"7A"; 
	elsif (Sel = 7) then
	    LUT_Data <= X"FF";    
	elsif (Sel = 8) then
		LUT_Data <= HEX2_Data1;		
	elsif (Sel = 9) then
		LUT_Data <= HEX2_Data2;	
	elsif (Sel = 10) then
		LUT_Data <= HEX2_Data3;	
	elsif (Sel = 11) then
		LUT_Data <= HEX2_Data4;	
	end if;
end process;

StateMachine:
--code pulled from Ring_Counter.vhd
process(iCLK)
begin	
	if rising_edge(iCLK) then
	   if DIV >= X"0018" then    
			DIV <= X"0000";
			clk_en <= '1';
		else
			DIV <= DIV +1;
			clk_en <= '0';
		end if;
	end if;
end process;

process (CS, iCLK, clk_en)
begin
    if rising_edge(iCLK) and clk_en = '1' then
	case CS is
		when 0 => 
			CS <= 1;
			sSCK <= '0';
			sCSN <= '0';
			Q <= LUT_Data(7);
			
		when 1 => 
			CS <= 2;
			sSCK <= '1';
	        Q <= LUT_Data(7);
	        
		when 2 => 
			Q <= LUT_Data(6);			
			CS <= 3;
			sSCK <= '0';
			
		when 3 => 
			Q <= LUT_Data(6);			
			CS <= 4;
			sSCK <= '1';
			
		when 4 => 
			Q <= LUT_Data(5);			
			CS <= 5;
			sSCK <= '0';

		when 5 => 
			Q <= LUT_Data(5);			
			CS <= 6;
			sSCK <= '1';

		when 6 => 
			Q <= LUT_Data(4);			
			CS <= 7;
			sSCK <= '0';

		when 7 => 
			Q <= LUT_Data(4);			
			CS <= 8;
			sSCK <= '1';

		when 8 => 
			Q <= LUT_Data(3);			
			CS <= 9;
			sSCK <= '0';

		when 9 => 
			Q <= LUT_Data(3);			
			CS <= 10;
			sSCK <= '1';
			
		when 10 => 
			Q <= LUT_Data(2);			
			CS <= 11;
			sSCK <= '0';

		when 11 => 
			Q <= LUT_Data(2);			
			CS <= 12;
			sSCK <= '1';
			
		when 12 => 
			Q <= LUT_Data(1);			
			CS <= 13;
			sSCK <= '0';
			
		when 13 => 
			Q <= LUT_Data(1);			
			CS <= 14;
			sSCK <= '1';
			
		when 14 => 
			Q <= LUT_Data(0);			
			CS <= 15;
			sSCK <= '0';
			
		when 15 => 
			Q <= LUT_Data(0);			
			CS <= 16;
			sSCK <= '1';
			
		when 16 =>
			Q <= '0';
			CS <= 17;
			sSCK <= '0';
			
		when 17 =>
			Q <= '0';
			CS <= 18;
			sSCK <= '0';
			sCSN <= '1';
			if (Sel < 11) then
                Sel <= Sel+1;
            else
                Sel <= 8;
            end if;    

		when 18 =>
			Q <= '0';
            CS <= 1;
            sSCK <= '0';
            sCSN <= '0';	

	end case;
	end if;
end process;
MOSI <= Q;
CSN <= sCSN;
SCK <= sSCK;

end Behavioral;
