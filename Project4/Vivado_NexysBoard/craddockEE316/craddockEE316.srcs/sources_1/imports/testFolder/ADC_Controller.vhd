library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;  
use IEEE.std_logic_arith.all;        

entity ADC_Controller is
     generic(samples : integer := 128);
   	 Port (     iclk : in STD_LOGIC;
		    reset : in STD_LOGIC;
	            EOC : in STD_LOGIC;--i
		    oStart : out STD_LOGIC;--o
		    ALE : out std_logic;--o
		    oOE : buffer std_logic;--o
			sel : buffer std_logic;--o
		    oWriteReady : out std_logic;--o
		    oClk_en : out std_logic--o
           );
end entity ADC_Controller;

Architecture Behavioral of ADC_Controller is

signal clk_en : std_logic;
signal clk_cnt : integer := 0;
signal state : integer:=0;
signal Write_sig : STD_LOGIC := '0';
signal sadc_dataSelect : std_logic := '0';
signal dataCount : integer:= 0;

begin

oClk_en <= clk_en;
oWriteReady <= Write_sig;

process(oOE)
begin
    if(rising_edge(oOE)) then
        dataCount <= dataCount + 1;
        if dataCount = samples  then
            sadc_dataSelect <= not(sadc_dataSelect);
            sel <= sadc_dataSelect;
            dataCount <= 0;
        end if;
    end if;
end process;

clock_enabler: process(iclk)
begin
    if (rising_edge(iclk))  then
        if (clk_cnt = 49) then 
            clk_cnt <= 0; 
            clk_en <= not(clk_en);
        else
            clk_cnt   <= clk_cnt + 1;
            --clk_en <= '0';
        end if;
    end if;
end process;

Convert: process (iClk, EOC, reset)
begin
 if reset = '1' then
 			oOE <= '0';
			ALE <= '0';
			oStart <= '0';
			state <= 0;
			Write_sig <= '0';
 elsif rising_edge (iClk) and clk_en = '1' then
	case state is
		when 0 =>
			oOE <= '0';
			ALE <= '0';
			oStart <= '0';
			state <= 1;
			Write_sig <= '0';
		when 1 => 
			ALE <= '1';
			oStart<='0';
			state <= 2;
		when 2 => 
			ALE <= '1';
			oStart <= '1';
			state <= 3;
		when 3 => 
			ALE <= '0';
			oStart <= '1';
			state <= 4;
		when 4 => 
			ALE <= '0';
			oStart <= '0';
			state <= 5;
		when 5 =>
			if (EOC = '1') then
				state<=6;
			else 
				state <= 5;
			end if;
        	when 6 =>
			oOE <= '1';
			state <= 7;
		when 7 =>
			Write_sig <= '1';
			state <= 0;
		when others =>
		  state <= 0;
	end case;
end if;
end process;

end Behavioral;
