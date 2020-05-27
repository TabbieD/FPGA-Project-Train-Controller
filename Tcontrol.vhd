library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Tcontrol is
	port
	(
		-- Input ports
		reset, clock, sensor1, sensor2,
		sensor3, sensor4	: in  std_logic;
		
		-- Output ports
		entry_A, entry_B, switch3	: out std_logic;
		dirA, dirB			: out std_logic_vector(1 downto 0)
		--sensor_1, sensor_2, sensor_3,
		--sensor_4			: out std_logic
	);
end Tcontrol;

-- Library Clause(s) (optional)
-- Use Clause(s) (optional)

architecture behaviour of Tcontrol is

	type state_type is (ABout, Ain, Bin, Astop, Bstop);
	signal state	: state_type;
	signal sensor12, sensor13, sensor24 : std_logic_vector(1 downto 0);
	

begin
	
	
	process(reset, clock) is 
	begin 
		if(reset = '1') then
			state <= ABout; 
		elsif(rising_edge(clock)) then
			-- Synchronous Sequential Statement(s)
			case state is
				when ABout=>
					case sensor12 is
						when "00" => state <= ABout;
						when "01" => state <= Bin;
						when "10" => state <= Ain;
						when "11" => state <= Ain;
						when others => state <= ABout;
					end case;
				
				when Ain =>
					case sensor24 is
						when "00" => state <= Ain;
						when "01" => state <= ABout;
						when "10" => state <= Bstop;
						when "11" => state <= ABout;
						when others => state <= ABout;
					end case;
					
				when Bin =>
					case sensor13 is
						when "00" => state <= Bin;
						when "01" => state <= ABout;
						when "10" => state <= Astop;
						when "11" => state <= ABout;
						when others => state <= ABout;
					end case;
					
				when Astop =>
					if sensor3 = '1' then
						state <= Ain;
					else
						state <= Astop;
					end if;
					
				when Bstop =>
					if sensor4 = '1' then
						state <= Bin;
					else
						state <= Bstop;
					end if;
			end case;			
		end if;
	end process; 
	
	sensor12 <= sensor1 & sensor2;
	sensor13 <= sensor1 & sensor3;
	sensor24 <= sensor2 & sensor4;
	
	--sensor_1 <= sensor1;
	--sensor_2 <= sensor2;
	--sensor_3 <= sensor3;
	--sensor_4 <= sensor4;
	
	switch3	<= '0';
	
	with state select
		entry_A <=  '0' when ABout,
					'1' when Ain,
					'0' when Bin,
					'0' when Astop,
					'1' when Bstop;
					
	with state select
		entry_B <=  '0' when ABout,
					'0' when Ain,
					'1' when Bin,
					'1' when Astop,
					'0' when Bstop;
					
	WITH state SELECT
		DirA <= "01"  WHEN ABout,
				"01"  WHEN Ain,
				"01"  WHEN Bin,
				"00" WHEN Astop,
				"01" WHEN Bstop;
				
	WITH state SELECT
		DirB <=     "01"  WHEN ABout,
					"01"  WHEN Ain,
					"01"  WHEN Bin,
					"01" WHEN Astop,
					"00" WHEN Bstop;

	
end behaviour;
