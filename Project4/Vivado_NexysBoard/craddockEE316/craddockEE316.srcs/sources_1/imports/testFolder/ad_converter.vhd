-- file: ad_converter.vhd
-------------------------------------
-- control module for the analog to digital converter
-- Shauna Rae
-- October 29, 1999

library ieee; 
use ieee.std_logic_1164.all; 

package ad_converter_pkg is
	component ad_converter
		port (from_adc : in std_logic_vector(7 downto 0);
				adc_dataReady, slow_clk, reset, enable : in std_logic;
				adc_select : out std_logic_vector(1 downto 0);
				adc_output00FL, adc_output01FR, adc_output10BL, 
				adc_output11BR : out std_logic_vector(7 downto 0);
				adc_clock, adc_loadAddressStart, adc_outputEnable, 
				data_valid: out std_logic);
		end component;
end ad_converter_pkg;

library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all; 
library work;
use work.ad_converter_pkg.all;
use work.en_register_pkg.all;

entity ad_converter is
	port (from_adc	: in std_logic_vector(7 downto 0);
			adc_dataReady, slow_clk, reset, enable : in std_logic;
			adc_select : out std_logic_vector(1 downto 0);
			adc_output00FL, adc_output01FR, adc_output10BL, adc_output11BR
 			: out std_logic_vector(7 downto 0);
			adc_clock, adc_loadAddressStart, adc_outputEnable, data_valid
			: out std_logic);
	end ad_converter;

architecture mixed of ad_converter is
signal selection: std_logic_vector(1 downto 0);
signal count: std_logic_vector(2 downto 0);
signal outputEnable, flag_start, flag_wait, loadAddressStart,
		enable00FL, enable01FR, enable10BL, enable11BR, 
		data_valid00FL, data_valid01FR, data_valid10BL, data_valid11BR
		: std_logic;
signal dataReady_curr : std_logic;
signal dataReady_meta : std_logic;
signal dataReady_last : std_logic;

begin
	adc_clock <= slow_clk;
	adc_loadAddressStart <= loadAddressStart;
	adc_select <= selection;
	adc_outputEnable <= outputEnable;
	
	process(adc_dataReady, slow_clk)
	begin
	   if rising_edge(slow_clk) then
	       dataReady_meta <= adc_dataReady;
	       dataReady_curr <= dataReady_meta;
	   end if;
	end process;
	
	dataReady_last <= dataReady_curr when rising_edge(slow_clk);
	
	test :process(slow_clk, reset)
	begin	

		-- reset state
		if reset = '0' then
			selection <= "00";
			flag_start <= '0';
			loadAddressStart <= '0';
			data_valid <= '0';

		-- on rising edge of slow_clk
		elsif slow_clk'event and slow_clk = '1' then

			-- data_valid should go high when data from
			-- all registers is valid, once all four
			data_valid <= data_valid11BR;

			-- alternate between starting conversion
			-- and reading output from ADC
			if flag_start = '0' and enable = '1' then

				-- load address and start conversion
				-- requires a pulse
				if loadAddressStart = '0' then
					outputEnable <= '0';
					loadAddressStart <= '1';
				elsif loadAddressStart = '1' then
					loadAddressStart <= '0';
					flag_start <= '1';
				end if;

			-- now read output
			elsif flag_start = '1' then

				-- check if conversion complete
				-- for even addresses flag_wait should
				-- be one for odd 0
				if flag_wait = '1' and (selection = "00" or 
					selection = "10") then

					-- change address
					if selection = "00" then
						selection <= "01";
					elsif selection = "10" then
						selection <= "11";
					end if;			

					-- set outputEnable high
					outputEnable <= '1';
					-- clear flag to begin next conversion
					flag_start <= '0';

				-- case for odd addresses
				elsif flag_wait = '0' and (selection = "01" or
					selection = "11") then
					if selection = "11" then
						selection <= "00";
					elsif selection = "01" then
						selection <= "10";
					end if;
					outputEnable <= '1';
					flag_start <= '0';
				end if;
			end if;			
		end if;
	end process;
		
	-- This process is used to check that the a conversion
	-- is complete on the ADC.  This is indicated by a
	-- rising edge of the adc_dataReady line.
	check_dataReady : process(adc_dataReady)
	begin
		if (dataReady_curr XOR dataReady_last) = '1' then
			if flag_wait = '0' then
				flag_wait <= '1';
			elsif	flag_wait = '1' then
				flag_wait <= '0';
			end if;
		end if;

	end process check_dataReady; 
		
	-- store data in appropriate registers by enabling
	with selection select
		enable00FL <= outputEnable when "01",
		'0' when others;
	with selection select
		enable01FR <= outputEnable when "10",
		'0' when others;
	with selection select
		enable10BL <= outputEnable when "11",
		'0' when others;
	with selection select
		enable11BR <= outputEnable when "00",
		'0' when others;

	-- assign the outputs of the converter to an enabled register
	inregister00FL : en_register
		generic map ( data_width => 8)
		port map(
		-- inputs
		clock => slow_clk,
		reset => reset,
		enable_in => enable00FL,	
		register_in => from_adc,
		-- outputs
		register_out => adc_output00FL,
		enable_out => data_valid00FL);

	inregister01FR : en_register
		generic map ( data_width => 8)
		port map(
		-- inputs
		clock => slow_clk,
		reset => reset,
		enable_in => enable01FR,	
		register_in => from_adc,
		-- outputs
		register_out => adc_output01FR,
		enable_out => data_valid01FR);

	inregister10BL : en_register
		generic map ( data_width => 8)
		port map(
		-- inputs
		clock => slow_clk,
		reset => reset,
		enable_in => enable10BL,	
		register_in => from_adc,
		-- outputs
		register_out => adc_output10BL,
		enable_out => data_valid10BL);

	inregister11BR : en_register
		generic map ( data_width => 8)
		port map(
		-- inputs
		clock => slow_clk,
		reset => reset,
		enable_in => enable11BR,	
		register_in => from_adc,
		-- outputs
		register_out => adc_output11BR,
		enable_out => data_valid11BR);

end mixed;