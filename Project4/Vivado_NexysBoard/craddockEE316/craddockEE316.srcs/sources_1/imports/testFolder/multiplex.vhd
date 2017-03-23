-- file: multiplex.vhd
-------------------------------------
-- n bit multiplexer
-- Shauna Rae
-- October 18, 1999

library ieee; 
use ieee.std_logic_1164.all; 


--define the entity of multiplex
entity multiplex is
	generic (data_width : positive := 16);
	port(select_line: in std_logic;
		in_a, in_b: in std_logic_vector(data_width-1 downto 0);
		output : out std_logic_vector(data_width-1 downto 0));
	end multiplex;

architecture basic of multiplex is
begin
	-- define a process which is dependent on select_line
	multiplex_behaviour: process --(select_line)
	begin
		if select_line = '0' then  -- select line zero select in_a
			output <= in_a;
		-- select line one select in_a as output
		else
			output <= in_b;
		end if;
	end process;

end basic;