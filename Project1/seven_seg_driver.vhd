-- Author: Zander Blasingame
-- Class: EE 316 Spring 2017
-- Description: Seven Segment Display driver

library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity seven_seg is
    port(
        data       	: in std_logic_vector(15 downto 0);
        address    	: in std_logic_vector(7 downto 0);
        hex0		: out std_logic_vector(7 downto 0);
        hex1		: out std_logic_vector(7 downto 0);
        hex2		: out std_logic_vector(7 downto 0);
        hex3		: out std_logic_vector(7 downto 0);
        hex4		: out std_logic_vector(7 downto 0);
        hex5		: out std_logic_vector(7 downto 0)
    );
end seven_seg;

architecture Behavioral of seven_seg is

-- Function to convert hex into seven seg
function hex_to_seven(hex_code : std_logic_vector(3 downto 0))
		return std_logic_vector is
	variable output : std_logic_vector(7 downto 0) := x"00";
begin
	-- Character Lookup table
	case hex_code is
        when x"0" => output := "00111111";
		when x"1" => output := "00000110";	
		when x"2" => output := "01011011";	
		when x"3" => output := "01001111";	
		when x"4" => output := "01100110";	
		when x"5" => output := "01101101";	
		when x"6" => output := "01111101";	
		when x"7" => output := "00000111";	
		when x"8" => output := "01111111";	
		when x"9" => output := "01100111";	
		when x"A" => output := "01110111";	
		when x"B" => output := "01111100";	
		when x"C" => output := "00111001";	
		when x"D" => output := "01011110";	
		when x"E" => output := "01111001";	
		when x"F" => output := "01110001";	
		when others => output := "00000000";
	end case;
	
	return not output;
end hex_to_seven;


begin

	hex5 <= hex_to_seven(address(7 downto 4));
	hex4 <= hex_to_seven(address(3 downto 0));
	hex3 <= hex_to_seven(data(15 downto 12));
	hex2 <= hex_to_seven(data(11 downto 8));
	hex1 <= hex_to_seven(data(7 downto 4));
	hex0 <= hex_to_seven(data(3 downto 0));

end Behavioral;