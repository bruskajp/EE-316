----------------------------------------------------------------------------------
-- Company: 
-- Engineer: John Dobson
-- 
-- Create Date: 10/08/2013 08:05:27 PM
-- Design Name: 
-- Module Name: Nexys3_Display - Behavioral
-- Project Name: 
-- Target Devices: Nexys3 Spartan-6, Alterra DE0-Nano
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Nexys4_Display is
    Port ( 
           Hex_IN : in STD_LOGIC_VECTOR (15 downto 0);
           iCLK         : in STD_LOGIC;
           An_OUT       : out STD_LOGIC_VECTOR (7 downto 0);
           SevSeg_OUT   : out STD_LOGIC_VECTOR (7 downto 0));
end Nexys4_Display;

architecture Behavioral of Nexys4_Display is

signal DIV : unsigned(15 DOWNTO 0) :=X"0000";

--Signals for StateMachine:
type stateType is (A, B, C, D);
Signal Q	: std_logic_vector(3 downto 0);
Signal Y	: std_logic_vector(1 downto 0);
signal CS, NS : stateType;

--Signals for Splitter:
signal X : std_logic_vector (3 downto 0);
signal clk_en: std_logic;
signal An_OFF : std_logic_vector(3 downto 0);



BEGIN
StateMachine:
--code pulled from Ring_Counter.vhd
process(iCLK)
begin	
	if rising_edge(iCLK) then
		if DIV >= X"31" then
				DIV <= X"0000";
				clk_en <= '1';
		else
			DIV <= DIV +1;
			clk_en <= '0';
		end if;
	end if;
end process;



Process(iCLK, clk_en)
Begin
	if rising_edge(iCLK) and clk_en = '1' then
	 CS <= NS;
	end if;
end process;

process (CS)
begin
Y <= "00"; 
	case CS is
		when A => 
			Y <= "00";
			Q <= "1110";
			NS <= B;
	
		when B => 
			Y <= "01";
			Q <= "1101";			
			NS <= C;
			
		when C => 
			Y <= "10";
			Q <= "1011";			
			NS <= D;
			
		when D => 
			Y <= "11";
			Q <= "0111";			
			NS <= A;

	end case;
end process;
	An_OFF <= "1111";
	An_OUT <= An_OFF & Q;	

HexSplitter:
Process(Hex_IN, Y)
begin
    case Y is
    
        when "00" =>
            X <= Hex_IN(3 downto 0);
            
        when "01" =>
            X <= Hex_IN(7 downto 4);
            
        when "10" =>
            X <= Hex_IN(11 downto 8);
            
        when "11" =>
            X <= Hex_IN(15 downto 12);
            
         when others => X <= "1111";
            
    end case;
end process;  
    
HexToSevenSeg:
Process(X)
begin
    case X is
    
        when "0000" => SevSeg_OUT <= "11000000";  -- 0
        when "0001" => SevSeg_OUT <= "11111001";  -- 1
        when "0010" => SevSeg_OUT <= "10100100";  -- 2
        when "0011" => SevSeg_OUT <= "10110000";  -- 3
        when "0100" => SevSeg_OUT <= "10011001";  -- 4
        when "0101" => SevSeg_OUT <= "10010010";  -- 5
        when "0110" => SevSeg_OUT <= "10000010";  -- 6
        when "0111" => SevSeg_OUT <= "11111000";  -- 7
        when "1000" => SevSeg_OUT <= "10000000";  -- 8
        when "1001" => SevSeg_OUT <= "10011000";  -- 9
        when "1010" => SevSeg_OUT <= "10001000";  -- A
        when "1011" => SevSeg_OUT <= "10000011";  -- b
        when "1100" => SevSeg_OUT <= "11000110";  -- C
        when "1101" => SevSeg_OUT <= "10100001";  -- d
        when "1110" => SevSeg_OUT <= "10000110";  -- E
        when "1111" => SevSeg_OUT <= "10001110";  -- F
        when others => SevSeg_OUT <= "11111111"; 
            
    end case;
end process;


end Behavioral;
