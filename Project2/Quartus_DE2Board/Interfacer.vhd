LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY Interfacer IS
  PORT(
  CLK		: in std_logic;
  data_in	: in std_logic_vector(15 downto 0) := x"0000";
  sda		: inout std_logic;
  scl		: inout std_logic);
END Interfacer;

architecture behavioural of Interfacer is
	component i2c_master is
	  PORT(
		clk       : IN     STD_LOGIC;                    --system clock
		reset_n   : IN     STD_LOGIC;                    --active low reset
		ena       : IN     STD_LOGIC;                    --latch in command
		addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
		rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
		data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
		busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
		data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
		ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
		sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
		scl       : INOUT  STD_LOGIC);                   --serial clock output of i2c bus
	end component;
	
	type state_type is (initial, wait_i2c, send_addr, send_data_1, send_data_2, send_data_3, send_data_4, stop);
	
	signal state		: state_type := initial;
	signal data_sec		: std_logic_vector(7 downto 0);
	signal address		: std_logic_vector(6 downto 0):= "1110001";
	signal read_write	: std_logic := '0';
	signal reset        : std_logic;
	signal enable		: std_logic;
	signal busy			: std_logic;
	signal error		: std_logic;
	signal busy_prev	: std_logic;
	signal data_prev	: std_logic_vector(15 downto 0);
	signal counter		: integer := 0;
	signal byteSel		: std_logic_vector(7 downto 0);
	signal transmitted	: boolean;
	
begin

I2CMaster : i2c_master
	port map(
		clk			=> CLK,
		reset_n     => reset,
		ena			=> enable,
		addr		=> address,
		rw			=> read_write,
		data_wr		=> data_sec,
		busy		=> busy,
		ack_error	=> error,
		sda			=> sda,
		scl			=> scl);
		
process(CLK, state, busy, error)
begin
if rising_edge(CLK) then
		data_prev <= data_in;
		case state is
			when initial =>
				reset <= '1';
				enable <= '1';
				
				if counter <= 12 then
					--enable <= '1';
					data_sec <= byteSel;	
					
					busy_prev <= busy;
					if  busy = '0' and busy_prev = '1' then 
						transmitted <= True;
					else
						transmitted <= false;
					end if;
					
					if transmitted then
						counter <= counter + 1;
						transmitted <= false;
					else
						counter <= counter;
					end if;
				elsif counter > 12 then
					enable <= '0';
					counter <= 0;
					state <= wait_i2c;
				end if;
			when wait_i2c => 
				if data_in /= data_prev then
					state <= send_addr;
					reset <= '0';
				else
					state <= wait_i2c;
				end if;
			when send_addr => 
				enable <= '1';				
				reset <= '1';				
				state <= send_data_1;
			when send_data_1 => 
				data_sec <= "0000" & data_in(15 downto 12);
				
				busy_prev <= busy;
				if  busy = '0' and busy_prev = '1' then 
					transmitted <= True;
				else
					transmitted <= false;
				end if;
				
				if transmitted then
					state <= send_data_2;
					transmitted <= false;
				else
					state <= send_data_1;
				end if;
			when send_data_2 => 
				data_sec <= "0000" & data_in(11 downto 8);
				
				busy_prev <= busy;
				if  busy = '0' and busy_prev = '1' then 
					transmitted <= True;
				else
					transmitted <= false;
				end if;
				
				if transmitted then
					state <= send_data_3;
					transmitted <= false;
				else
					state <= send_data_2;
				end if;
			when send_data_3 => 
				data_sec <= "0000" & data_in(7 downto 4);

				busy_prev <= busy;
				if  busy = '0' and busy_prev = '1' then  
					transmitted <= True;
				else
					transmitted <= false;
				end if;
				
				if transmitted then
					state <= send_data_4;
					transmitted <= false;
				else
					state <= send_data_3;
				end if;
			when send_data_4 => 
				data_sec <= "0000" & data_in(3 downto 0);
				
				busy_prev <= busy;
				if  busy = '0' and busy_prev = '1' then  
					transmitted <= True;
				else
					transmitted <= false;
				end if;
				
				if transmitted then
					state <= stop;
					transmitted <= false;
				else
					state <= send_data_4;
				end if;
			when stop => 
				enable <= '0';
				state <= wait_i2c;
			when others =>
				state <= wait_i2c;
		end case;
end if;
end process;

process(counter)
begin
case (counter) is
	when 0 => byteSel <= x"76"; -- board initialization sequence
	when 1 => byteSel <= x"76";
	when 2 => byteSel <= x"76";
	when 3 => byteSel <= x"7A";
	when 4 => byteSel <= x"FF";
	when 5 => byteSel <= x"77";
	when 6 => byteSel <= x"00";
	when 7 => byteSel <= x"79";
	when 8 => byteSel <= x"00";
	when 9 => byteSel <= x"00"; -- initial data
	when 10 => byteSel <= x"00";
	when 11 => byteSel <= x"00";
	when 12 => byteSel <= x"00";
	when others => byteSel <= x"00";
end case;
end process;
end behavioural;