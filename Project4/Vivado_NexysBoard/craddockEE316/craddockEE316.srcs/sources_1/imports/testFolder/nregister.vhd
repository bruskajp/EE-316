-- file: nregister.vhd
-------------------------------------
-- n bit register for use in carry save counter
-- Shauna Rae
-- October 4, 1999

library ieee; 
use ieee.std_logic_1164.all; 


   --     component nregister is
	--	generic (data_width : positive := 16);
   ---             port(clock, reset : in std_logic; 
  --                   register_in: in std_logic_vector(data_width-1 downto 0);
  --                  register_out : out std_logic_vector(data_width-1 downto 0));
   --     end component nregister;



--define the entity of nregister
entity nregister is
	generic (data_width : positive := 16);
	port(clock, reset: in std_logic;
		register_in: in std_logic_vector(data_width-1 downto 0);
		register_out: out std_logic_vector(data_width-1 downto 0));
	end nregister;

architecture basic of nregister is

begin
	--define a process that is dependent on reset and a clock
	register_behaviour: process(clock, reset) is
	begin
		if reset = '0' then  -- on reset zero the output
			register_out <= (others => '0');
		--on rising edge of clock set output to input
		elsif rising_edge(clock) then 
			register_out <= register_in;

		end if;
	end process register_behaviour;

end basic;