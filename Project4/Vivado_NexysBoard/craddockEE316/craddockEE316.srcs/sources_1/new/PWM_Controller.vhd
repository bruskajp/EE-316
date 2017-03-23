----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2017 12:12:06 PM
-- Design Name: 
-- Module Name: PWM_Controller - Behavioral
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

entity PWM_Controller is
    port(
        iadc_sel : in std_logic;
        iSW      : in std_logic;
        iData    : in std_logic_vector(7 downto 0);
        --iData2   : in std_logic_vector(7 downto 0);
        oData    : out std_logic_vector(7 downto 0)
        );
end PWM_Controller;

architecture Behavioral of PWM_Controller is


begin

process(iadc_sel,iSW)
begin
    if iadc_sel = '0' and iSW = '0' then
        oData <= iData;
    elsif iadc_sel = '1' and iSW = '1' then
        oData <= iData;
    else
        oData <= "00000000";
    end if;
end process;

end Behavioral;
