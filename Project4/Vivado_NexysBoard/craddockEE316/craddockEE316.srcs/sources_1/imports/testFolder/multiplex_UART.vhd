-- file: multiplex.vhd
-------------------------------------
-- n bit multiplexer
-- Shauna Rae
-- October 18, 1999

library ieee; 
use ieee.std_logic_1164.all; 


--define the entity of multiplex
entity multiplex_UART is
	generic (data_width : positive := 8);
	port(select_line: in std_logic;
		in_a, in_b, in_c: in std_logic_vector(data_width-1 downto 0);
		output : out std_logic_vector(data_width-1 downto 0));
	end multiplex_UART;

architecture basic of multiplex_UART is
begin
	-- define a process which is dependent on select_line
	multiplex_behaviour: process --(select_line)
	begin
        if select_line = '0' then
            output <= in_a;
        elsif select_line = '1' then
            output <= in_b;
        
        end if;
	end process;

end basic;