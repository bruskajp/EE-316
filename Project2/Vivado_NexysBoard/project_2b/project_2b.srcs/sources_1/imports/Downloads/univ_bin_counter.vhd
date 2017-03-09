-- Source: http://academic.csuohio.edu/chu_p/rtl/fpga_vhdl.html
-- Listing 4.10
-- modified: added port "clk_en", Sept 5, 2013

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity univ_bin_counter is
   generic(N: integer := 8);
   port(
      clk, reset				: in std_logic;
      syn_clr, load, en, up     : in std_logic;
	  clk_en 					: in std_logic ;
      d							: in std_logic_vector(N-1 downto 0);
      max                       : in unsigned(N-1 downto 0);
      min                       : in unsigned(N-1 downto 0);
      q							: out std_logic_vector(N-1 downto 0)
       );
end univ_bin_counter;

architecture arch of univ_bin_counter is
   signal r_reg				: unsigned(N-1 downto 0) := min;
   signal r_next			: unsigned(N-1 downto 0);
  
   signal max_tick          : std_logic;
   signal min_tick          : std_logic;
   
begin
   -- register
   process(clk,reset,clk_en,syn_clr,min,r_next)
   begin
      if (reset='1' or syn_clr = '1') then
         r_reg <= min;         
      elsif rising_edge(clk) and clk_en = '1' then
         r_reg <= r_next;
      end if;
   end process;
 
 process (en,up,r_reg,min,max)
 begin  
    if (en = '1') then
        if (up = '1') then
            if (r_reg = max) then
                r_next <= min;
            elsif (r_reg /= max) then
                r_next <= r_reg +1;
            end if;
        elsif (up = '0') then
            if (r_reg = min) then
                r_next <= max;
            elsif (r_reg /= min) then
                r_next <= r_reg -1;
            end if;
        end if;
    elsif (en = '0') then
        r_next <= r_reg;
    end if;
end process;
   
   q <= std_logic_vector(r_reg);
    
end arch;

