library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity vga_out is
  PORT ( iCLK           : in STD_LOGIC;
         px             : in STD_LOGIC_VECTOR(9 DOWNTO 0);
         py             : in STD_LOGIC_VECTOR(9 DOWNTO 0);
         potX           : in STD_LOGIC_VECTOR(7 DOWNTO 0);
         potY           : in STD_LOGIC_VECTOR(7 DOWNTO 0);
         color          : in STD_LOGIC_VECTOR(11 downto 0);
         red            : out STD_LOGIC_VECTOR(3 DOWNTO 0);
         green          : out STD_LOGIC_VECTOR(3 DOWNTO 0);
         blue           : out STD_LOGIC_VECTOR(3 DOWNTO 0);
         ram_addr_output : out STD_LOGIC_VECTOR(16 downto 0)
      );
end vga_out;

architecture Behavioral of vga_out is

signal px_int: INTEGER := 0;
signal py_int: INTEGER := 0;

begin

px_int <= to_integer(unsigned(px));
py_int <= to_integer(unsigned(py));

process(iCLK)
begin
if (rising_edge(iCLK)) then
    if ((py >= 107) and (py <= 363)) then
       if ((px >= 192) and (px <= 448)) then
            ram_addr_output <= std_logic_vector(to_unsigned( ((px_int-192) + ((py_int-107) * 256)) , 17)); -- FIX THIS
            red <= color(11 downto 8);
            green <= color(7 downto 4);
            blue <= color(3 downto 0);
--          if (((py - 107) = potY) and ((px - 192) = potX)) then
--             red <= "0000";
--             blue <= "0000";
--             green <= "0000";
--          else
--             red <= "1111";
--             blue <= "1111";
--             green <= "1111";
--          end if;
       else
          red <= "0000";
          blue <= "0000";
          green <= "0000";
       end if;
    elsif ((py >= 447) and (py <= 479)) then
       if ((px >= 128) and (px <= 512)) then
          ram_addr_output <= std_logic_vector(to_unsigned( (65536 + (px_int-128) + ((py_int-447) * 384)) , 17));
          red <= color(11 downto 8);
          green <= color(7 downto 4);
          blue <= color(3 downto 0);
--          red <= "0000";
--          blue <= "0000";
--          green <= "0000";
       else
          red <= "0000";
          blue <= "0000";
          green <= "0000";
       end if;
    end if;
end if;
end process;


end Behavioral;
