----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2017 06:15:00 PM
-- Design Name: 
-- Module Name: RAM_Controller - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RAM_Controller is
    generic( constant samples : integer := 128);
    Port ( clk11kHz : in STD_LOGIC;
           clk      : in std_logic;
           clk500kHz : in STD_LOGIC;
           idata_valid : in std_logic;
           sel : in STD_LOGIC_vector(1 downto 0);
           reset : in std_logic;
           iadcsel : in std_logic;
           ointernalCount : out std_logic;
           ena1 : out std_logic;
           enb1 : out std_logic;
           ena2 : out std_logic;
           enb2 : out std_logic;
           wea : out std_logic_vector(0 downto 0);
           UARTen : out std_logic;
           ocount1 : out std_logic_vector(13 downto 0);
           ocount2 : out std_logic_vector(13 downto 0);
           ocount4 : out std_logic_vector(13 downto 0);
           ocount3 : out std_logic_vector(13 downto 0));
end RAM_Controller;

architecture Behavioral of RAM_Controller is

signal count1 : integer:= -1;
signal count2 : integer:= -1;
signal count3 : integer:= -1;
signal count4 : integer:= -1;
signal count2flag : std_logic;
signal count3flag : std_logic;
signal doneFlag : std_logic:= '0';
signal doneCount : integer :=0;
signal internalCount : std_logic:= '0';
signal Ssel         : std_logic_vector(1 downto 0) := "00";
signal selRes       : std_logic_vector(1 downto 0) := "00";
--signal sel : std_logic_vector(1 downto 0):= "11";
signal clk_cnt : integer;
signal clk_en   : std_logic:= '0';

begin

--Ssel <= sel;
ointernalCount <= internalCount;

process(clk500kHz)
begin
    if rising_edge(clk500kHz) then
        if clk_cnt >= 2 then
            clk_en <= not(clk_en);
        else
            clk_cnt <= clk_cnt + 1;
        end if;
    end if;
end process;
            
    

process(iadcsel, reset,clk)--idata_valid, iadcsel, reset)
begin
if rising_edge(clk) then
    wea <= "1";
    if reset = '1' then
        count1 <= -1;
    elsif reset = '0' then
        if iadcsel = '0' then
            if count1 < samples then
                count1 <= count1 + 1;
                --ena1 <= '1';
            elsif count1 >= samples - 1 AND ((count2 = samples -1 and sel = "01") or (count2 = samples - 1 and count3 = samples - 1 and internalCount = '0' and doneFlag = '1' and sel = "11")) then
                count1 <= -1;
                --ena1 <= '0';
            end if;
        end if;
    end if;
end if;
end process;

process(iadcsel)
begin
    if iadcsel = '0' then
        ena1 <= '1';
        ena2 <= '0';
    elsif iadcsel = '1' then
        ena1 <= '0';
        ena2 <= '1';
    end if;
end process;
    
process(iadcsel, reset,clk)--idata_valid, iadcsel, reset)
begin
if rising_edge(clk) then
    wea <= "1";
    if reset = '1' then
        count4 <= -1;
    elsif reset = '0' then
        if iadcsel = '1' then
            if count4 < samples then
                count4 <= count4 + 1;
                --ena1 <= '1';
            elsif count4 >= samples - 1 AND ((count3 = samples -1 and sel = "01") or (count2 = samples - 1 and count3 = samples - 1 and internalCount = '0' and doneFlag = '1' and sel = "11")) then
                count4 <= -1;
                --ena1 <= '0';
            end if;
        end if;
    end if;
end if;
end process;   

--            if count1 < samples and iadcsel = '0' and idata_valid = '1' and Ssel = "00" then
--                count1 <= count1 + 1;
--                ena1 <= '1';
--                ena2 <= '0';
--            elsif count1 >= samples-1 AND ((count2 = samples - 1 and sel = "01") or (count2 = samples -1 and count3 = samples -1 and internalCount = '1' and doneFlag = '1' and sel = "11")) then
--                count1 <= -1; 
--            end if;
--            if count4 < samples and iadcsel = '1' and idata_valid = '1' and Ssel = "00" then
--                count4 <= count4 + 1;
--                ena1 <= '0';
--                ena2 <= '1';
--            elsif count4 >= samples-1 AND ((count3 = samples - 1 and sel = "10") or (count2 = samples -1 and count3 = samples -1 and internalCount = '1' and doneFlag = '1' and sel = "11")) then
--                count4 <= -1;
--            end if;
    --end if;
--    if rising_edge(clk500kHz) and iadcsel = '1' then
--            if count4 < samples then
--                count4 <= count1 + 1;
--            elsif count4 >= samples-1 AND (internalCount = '0' and doneFlag = '0') then --((count2 = samples-1 and sel = "01") or (count3 = samples-1 and sel = "10") or (count2 = samples - 1 and count3 = samples - 1 and sel = "11") or sel = "00") then
--                count4 <= 0;
--            end if;
--        end if;
--end process;

process(clk11kHz,sel)
begin
    if rising_edge(clk11kHz) then
        if reset = '1' then
            count2 <= -1;
            count3 <= -1;
            enb1 <= '0';
            enb2 <= '0';
            --selRes <= "00";
        elsif sel = "00" then--selRes = "00" then
        
        elsif sel = "01" then
            --selRes <= "01";
            if count2 = samples - 1 then
                count2 <= -1;
                internalCount <= '0';
                UARTen <= '0';
                enb1 <= '0';
                --doneFlag <= '1';
            else
                count2 <= count2 + 1;
                UARTen <= '1';
                enb1 <= '1';
                internalCount <= '1';
            end if;
        elsif sel = "10" then
            --selRes <= "01";
            if count3 = samples - 1 then
                count3 <= -1;
                internalCount <= '0';
                UARTen <= '0';
                enb2 <= '0';
            else
                count3 <= count3 + 1;
                internalCount <= '1';
                UARTen <= '1';
                enb2 <= '1';
            end if;
        elsif sel = "11" then
            --selRes <= "01";
            UARTen <= '1';
            if count2 = samples - 1 then
                if count3 = samples - 1 then
                    enb1 <= '0';
                    enb2 <= '0';
                    doneFlag <= '1';
                    internalCount <= '0';
                    --UARTen <= '0';
                else
                    enb1 <= '0';
                    enb2 <= '1';
                    count3 <= count3 + 1;
                    --UARTen <= '1';
                    internalCount <= '1';
                end if;
            else
                enb1 <= '1';
                enb2 <= '0';
                count2 <= count2 + 1;
                --UARTen <= '1';
                internalCount <= '1';
            end if;
            
            if doneFlag = '1' then
                enb1 <= '0';
                enb2 <= '0';
                doneCount <= doneCount + 1;
                internalCount <= '0';
                if doneCount = samples then
                    count2 <= -1;
                    count3 <= -1;
                    doneFlag <= '0';
                    doneCount <= 0;
                end if;
            end if;            
        end if;
    end if;
end process;


ocount1 <= std_logic_vector(to_signed(count1, ocount1'length));
ocount2 <= std_logic_vector(to_signed(count2, ocount2'length));
ocount3 <= std_logic_vector(to_signed(count3, ocount3'length));
ocount4 <= std_logic_vector(to_signed(count4, ocount4'length));

end Behavioral;
