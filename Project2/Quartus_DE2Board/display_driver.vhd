library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity display_driver is
port(   Input	: in std_logic_vector(15 downto 0);
        --clk  	: in std_logic;
		  HEX0	: out std_logic_vector(6 downto 0);
		  HEX1	: out std_logic_vector(6 downto 0);
		  HEX2	: out std_logic_vector(6 downto 0);
		  HEX3	: out std_logic_vector(6 downto 0);
		  HEX4	: out std_logic_vector(6 downto 0);
		  HEX5	: out std_logic_vector(6 downto 0);
		  HEX6	: out std_logic_vector(6 downto 0);
		  HEX7	: out std_logic_vector(6 downto 0)
);
end display_driver;  

architecture behavior of display_driver is

	signal H0   	: std_logic_vector(3 downto 0);
	signal H1		: std_logic_vector(3 downto 0);
	signal H2		: std_logic_vector(3 downto 0);
	signal H3		: std_logic_vector(3 downto 0);
	--signal Sel  		: std_logic_vector(1 downto 0);
	--signal clk_cnt	: integer range 0 to 9;
	--signal clk_en	: 	std_logic;

begin

	    H0   <= Input(3 downto 0);   
	    H1   <= Input(7 downto 4);   
	    H2   <= Input(11 downto 8);  
	    H3   <= Input(15 downto 12); 
		 HEX4 <= "1111111";
		 HEX5 <= "1111111";
		 HEX6 <= "1111111";
		 HEX7 <= "1111111";

--	begin
--	if rising_edge(clk) and clk_en='1' then
--	Sel <= Sel + 1;
--	end if;
--	end process;
--	
--	process(clk)
--	begin
--	if rising_edge(clk) then
--		if (clk_cnt = 9) then
--			clk_cnt <= 0;
--			clk_en <= '1';
--		else
--			clk_cnt <= clk_cnt + 1;
--			clk_en <= '0';
--		end if;
--	end if;
--	end process;
--	
--    process(Sel)
--    begin
--        case Sel is
--	    when "00" => H0 <= Input(3 downto 0);   
--	    when "01" => H1 <= Input(7 downto 4);   
--	    when "10" => H2 <= Input(11 downto 8);  
--	    when "11" => H3 <= Input(15 downto 12); 
--	    when others => H0 <= "1111"; H1 <= "1111"; H2 <= "1111"; H3 <= "1111";
--	end case;
--    end process;  
    
    process(H0) 
    begin
        case H0 is
        when "0000" => HEX0 <="1000000"; -- 0 shown on display
        when "0001" => HEX0 <="1111001"; -- 1 shown on display
        when "0010" => HEX0 <="0100100"; -- 2 shown on display
        when "0011" => HEX0 <="0110000"; -- 3 shown on display
        when "0100" => HEX0 <="0011001"; -- 4 shown on display
        when "0101" => HEX0 <="0010010"; -- 5 shown on display
        when "0110" => HEX0 <="0000010"; -- 6 shown on display
        when "0111" => HEX0 <="1111000"; -- 7 shown on display
        when "1000" => HEX0 <="0000000"; -- 8 shown on display
        when "1001" => HEX0 <="0010000"; -- 9 shown on display
        when "1010" => HEX0 <="0001000"; -- A shown on display
        when "1011" => HEX0 <="0000011"; -- b shown on display
        when "1100" => HEX0 <="1000110"; -- C shown on display
        when "1101" => HEX0 <="0100001"; -- d shown on display
        when "1110" => HEX0 <="0000110"; -- E shown on display
        when "1111" => HEX0 <="0001110"; -- F shown on display
        when others => HEX0 <="0001110"; -- F shown on display
    end case;
    end process;
	 
     process(H1) 
    begin
        case H1 is
        when "0000" => HEX1 <="1000000"; -- 0 shown on display
        when "0001" => HEX1 <="1111001"; -- 1 shown on display
        when "0010" => HEX1 <="0100100"; -- 2 shown on display
        when "0011" => HEX1 <="0110000"; -- 3 shown on display
        when "0100" => HEX1 <="0011001"; -- 4 shown on display
        when "0101" => HEX1 <="0010010"; -- 5 shown on display
        when "0110" => HEX1 <="0000010"; -- 6 shown on display
        when "0111" => HEX1 <="1111000"; -- 7 shown on display
        when "1000" => HEX1 <="0000000"; -- 8 shown on display
        when "1001" => HEX1 <="0010000"; -- 9 shown on display
        when "1010" => HEX1 <="0001000"; -- A shown on display
        when "1011" => HEX1 <="0000011"; -- b shown on display
        when "1100" => HEX1 <="1000110"; -- C shown on display
        when "1101" => HEX1 <="0100001"; -- d shown on display
        when "1110" => HEX1 <="0000110"; -- E shown on display
        when "1111" => HEX1 <="0001110"; -- F shown on display
        when others => HEX1 <="0001110"; -- F shown on display
    end case;
    end process;
	 
     process(H2) 
    begin
        case H2 is
        when "0000" => HEX2 <="1000000"; -- 0 shown on display
        when "0001" => HEX2 <="1111001"; -- 1 shown on display
        when "0010" => HEX2 <="0100100"; -- 2 shown on display
        when "0011" => HEX2 <="0110000"; -- 3 shown on display
        when "0100" => HEX2 <="0011001"; -- 4 shown on display
        when "0101" => HEX2 <="0010010"; -- 5 shown on display
        when "0110" => HEX2 <="0000010"; -- 6 shown on display
        when "0111" => HEX2 <="1111000"; -- 7 shown on display
        when "1000" => HEX2 <="0000000"; -- 8 shown on display
        when "1001" => HEX2 <="0010000"; -- 9 shown on display
        when "1010" => HEX2 <="0001000"; -- A shown on display
        when "1011" => HEX2 <="0000011"; -- b shown on display
        when "1100" => HEX2 <="1000110"; -- C shown on display
        when "1101" => HEX2 <="0100001"; -- d shown on display
        when "1110" => HEX2 <="0000110"; -- E shown on display
        when "1111" => HEX2 <="0001110"; -- F shown on display
        when others => HEX2 <="0001110"; -- F shown on display
    end case;
    end process;
	 
     process(H3) 
    begin
        case H3 is
        when "0000" => HEX3 <="1000000"; -- 0 shown on display
        when "0001" => HEX3 <="1111001"; -- 1 shown on display
        when "0010" => HEX3 <="0100100"; -- 2 shown on display
        when "0011" => HEX3 <="0110000"; -- 3 shown on display
        when "0100" => HEX3 <="0011001"; -- 4 shown on display
        when "0101" => HEX3 <="0010010"; -- 5 shown on display
        when "0110" => HEX3 <="0000010"; -- 6 shown on display
        when "0111" => HEX3 <="1111000"; -- 7 shown on display
        when "1000" => HEX3 <="0000000"; -- 8 shown on display
        when "1001" => HEX3 <="0010000"; -- 9 shown on display
        when "1010" => HEX3 <="0001000"; -- A shown on display
        when "1011" => HEX3 <="0000011"; -- b shown on display
        when "1100" => HEX3 <="1000110"; -- C shown on display
        when "1101" => HEX3 <="0100001"; -- d shown on display
        when "1110" => HEX3 <="0000110"; -- E shown on display
        when "1111" => HEX3 <="0001110"; -- F shown on display
        when others => HEX3 <="0001110"; -- F shown on display
    end case;
    end process;	 
    
end behavior;
