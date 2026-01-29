-- Time counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY counter_time is
	PORT( rst      	: in std_logic;   
			clk      	: in std_logic;                       -- Either 1s clk, faster regular TIME set clk or fast mode TIME set clk
			out_sec    : out std_logic_vector(5 downto 0);    -- Real-time clock seconds in binary
			out_min    : out std_logic_vector(5 downto 0);    -- Real-time clock minutes in binary
			out_hour   : out std_logic_vector(5 downto 0) );  -- Real-time clock hours in binary
end ENTITY;



ARCHITECTURE Behav of counter_time is

	signal sec, min, hour : std_logic_vector(5 downto 0);   -- Binary second, minute and hour

begin
												 								 											 
	-- Time clock increment 
	P_time_clock : process(clk, rst, sec, min, hour)
	begin
		
		if rst = '0' then 
			sec <= "000000";
			min <= "000000";
			hour <= "000000";
	
		elsif rising_edge(clk) then
		
			if sec = "111011" then          -- 59
				sec <= ("000000");
				
            if min = "111011" then          -- 59
					min <= ("000000");
               
					if hour = "010111" then -- 23
						hour <= ("000000");
					else
						hour <= hour + 1;
               end if;
					
				else
					min <= min + 1;
            end if;
				
			else	
				sec <= sec + 1;
         end if;
			
		end if;				
		
		
	end process;
	
	out_sec    <= sec;
	out_min    <= min;
	out_hour   <= hour;
	
end ARCHITECTURE;	