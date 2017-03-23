-- file: en_register.vhd
-------------------------------------
-- n bit register with enable
-- Shauna Rae
-- October 18, 1999

library ieee; 
use ieee.std_logic_1164.all; 

--create a package so that the register can be used again and the width
--can be set
package en_register_pkg is
-- set a constant so that it is easy to change the width of the nregister

--creat the enabled register component
        component en_register is
				generic (data_width : positive := 20);
                port(clock, reset, enable_in : in std_logic; 
					enable_out: out std_logic;
                  	register_in: in std_logic_vector(data_width-1 downto 0);
                  	register_out : out std_logic_vector(data_width-1 downto 0));
        end component en_register;

        component multiplex is
				generic (data_width : positive := 16);
                port(select_line : in std_logic; 
                     in_a, in_b: in std_logic_vector(data_width-1 downto 0);
                     output : out std_logic_vector(data_width-1 downto 0));
        end component multiplex;

        component nregister is
				generic (data_width : positive := 16);
                port(clock, reset : in std_logic; 
                     register_in: in std_logic_vector(data_width-1 downto 0);
                     register_out : out std_logic_vector(data_width-1 downto 0));
        end component nregister;

end en_register_pkg;

library ieee; 
use ieee.std_logic_1164.all; 
library work;
use work.en_register_pkg.all;

--define the entity of the enabled register
entity en_register is
	generic (data_width : positive := 8);
	port(clock, reset, enable_in: in std_logic;
		enable_out: out std_logic;
		register_in: in std_logic_vector(data_width-1 downto 0);
		register_out : out std_logic_vector(data_width-1 downto 0));
	end en_register;

-- use structural VHDL to define the enabled register
-- use the packages of the multiplexer and the n-bit register 

architecture mixed of en_register is
-- assign internal signals 
	signal loop_back, throughput: std_logic_vector(data_width-1 downto 0);

begin

	-- latch the enable signal so that it can propagate
	register_behaviour: process(clock) is
	begin
		if reset = '0' then  -- on reset zero the output
			enable_out <= '0';
		--on rising edge of clock set output to input
		elsif rising_edge(clock) then 
			enable_out <= enable_in;
		end if;
	end process register_behaviour;

-- map the multiplexer inside the enabled register
selection : multiplex  
		generic map (data_width => data_width)
		port map(
		-- inputs
		select_line => enable_in,
		in_a => loop_back,
		in_b => register_in,
		-- outputs
		output => throughput);
		
-- map the register inside the enabled register
register1 : nregister 
		generic map (data_width => data_width)
		port map(
		-- inputs
		clock => clock,
		reset => reset,
		register_in => throughput,
		-- outputs
		register_out => loop_back);

-- assign the values of the output of the register
-- to the output of the enabled register
register_out <= loop_back;

end mixed;	

