-- Alarm counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY counter_alarm is
	PORT( rst      	: in std_logic;   
			clk      	: in std_logic;                        -- Either regular ALARM set clk or fast mode ALARM set clk
			a_out_min    : out std_logic_vector(5 downto 0);   -- Alarm-time clock minutes in binary
			a_out_hour   : out std_logic_vector(5 downto 0) ); -- Alarm-time clock hours in binary
end ENTITY;


ARCHITECTURE Behav of counter_alarm is

	signal min, hour : std_logic_vector(5 downto 0);           -- Binary minute and hour

begin
												 								 											 
	-- Alarm clock increment
	P_time_clock : process(clk, rst, min, hour)
	begin
		
		if rst = '0' then 
			min <= "000000";
			hour <= "000000";
	
		elsif rising_edge(clk) then
			
			if min = "111011" then      -- 59
				min <= ("000000");
				
				if hour = "010111" then -- 23
					hour <= ("000000");
				else
					hour <= hour + 1;   -- Increment hour
				end if;
				
			else
				min <= min + 1;         -- Increment minute
			end if;
			
		end if;				
		
		
	end process;
	
	a_out_min  <= min;
	a_out_hour <= hour;

end ARCHITECTURE;