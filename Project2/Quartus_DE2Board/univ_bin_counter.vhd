library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity univ_bin_counter is
   generic(N: natural := 8;
				count_max : INTEGER := 8);
   port(
        clk						   : in std_logic;
        syn_clr, en, up       : in std_logic;
		  clk_en 					: in std_logic := '1';
        qo							: out std_logic_vector(N-1 downto 0)
   );
end univ_bin_counter;

architecture arch of univ_bin_counter is

	signal count 					: integer := 0;
   --signal r_reg				   : unsigned(N-1 downto 0);
   --signal r_next					: unsigned(N-1 downto 0);
	
begin

   -- register--
--   process(clk, syn_clr)
--   begin
--      if (syn_clr='1') then
--         r_reg <= (others=>'0');
--      elsif rising_edge(clk) and clk_en = '1' then
--         r_reg <= r_next;
--      end if;
--   end process;
	
	process(clk, en, syn_clr, up, count)
	begin
		if rising_edge(clk) then
			if syn_clr = '1' then 
				count <= 0;
			elsif up = '1' and en = '1' then 
				count <= count + 1;
			elsif up = '0' and en = '1' then
				count <= count - 1;
			end if;
			
			if up = '1' and count = count_max then
				count <= 0;
			elsif up = '0' and count = 0 then 
				count <= count_max;
			end if;
		end if;	
	end process;
	
   -- next-state logic--
--	r_next <= (others=>'0') when syn_clr='1' else
--				 "00000000"        when r_reg = "00001000" and en='1' and up='1' else
--				 "00001000"        when r_reg = "00000000" and en='1' and up='0' else
--				 r_reg + 1     when en ='1' and up='1' else
--				 r_reg - 1     when en ='1' and up='0' else
--				 r_reg;
	-- output logic--
	process(count)
	begin
		case (count) is
			when 0 => qo <= X"07";
			when 1 => qo <= X"0F";
			when 2 => qo <= X"17";
			when 3 => qo <= X"1F";
			when 4 => qo <= X"27";
			when 5 => qo <= X"2F";
			when 6 => qo <= X"37";
			when 7 => qo <= X"3F";
			when 8 => qo <= X"47";
			when others => qo <= X"3F";
		end case;
	end process;
		
end arch;
