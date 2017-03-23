----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2017 01:30:38 PM
-- Design Name: 
-- Module Name: adc_parse - Behavioral
-- Project Name: 
-- Target Devices: 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adc_parse is
    Port ( iData : in STD_LOGIC_vector(7 downto 0);
           oData1 : out STD_LOGIC_vector(7 downto 0);
           oData2 : out STD_LOGIC_vector(7 downto 0);
           iadc_sel : in STD_LOGIC);
end adc_parse;

architecture Behavioral of adc_parse is

begin
process(iadc_sel,iData)
begin
    if iadc_sel = '0' then
        oData1 <= iData;
    elsif iadc_sel = '1' then
        oData2 <= iData;
    end if;
end process;

end Behavioral;
