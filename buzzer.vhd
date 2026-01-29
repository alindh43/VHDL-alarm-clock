-- Buzzer

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY buzzer is
	PORT( clk    : in std_logic;                      -- 50MHz
			clk_1kHz : in std_logic;                  -- 1kHz
			rst    : in std_logic;
			set    : in std_logic;
			a_off  : in std_logic;                    -- Button, when pressed ('0') the alarm is turned off 
			min    : in std_logic_vector(7 downto 0); -- Time minutes (bcd)
			hour   : in std_logic_vector(7 downto 0); -- Time hours (bcd)
			a_min  : in std_logic_vector(7 downto 0); -- Alarm minutes (bcd)
			a_hour : in std_logic_vector(7 downto 0); -- Alarm hours (bcd)
			buzz   : out std_logic );                 -- Buzzer, 1kHz signal when the alarm = time, otherwise '0'
end ENTITY;


ARCHITECTURE Behav of buzzer is 

	type t_state is (idle, buzzing);                  -- Defining the states
	signal curr_state: t_state;
	signal prev_min, prev_hour : std_logic_vector(7 downto 0) := "00000000"; -- Keeping track of values


begin

	process (clk, rst, set, a_off, min, hour, a_min, a_hour, prev_min, prev_hour) is 
	begin
		
		-- Single process state machine 
		if rst = '0' then
			curr_state <= idle;       -- When rst is pressed, go to idle state 
			
		elsif rising_edge(clk) then
		
			case curr_state is
			
				-----------------------------------------------------------------------------------------------------------------------------------
				
				when idle =>
					if (min = "00000000") and (hour = "00000000") then              -- Don't want the buzzer to activate when starting the digital alarm clock
						curr_state <= idle;
					elsif (min = prev_min) and (hour = prev_hour) then              -- No buzzing if a_off has been pushed and alarm=time is still true
						curr_state <= idle;
					elsif (set = '1') and (min = a_min) and (hour = a_hour) then    -- When the time matches the alarm and 'set' is not pressed down
						curr_state <= buzzing;                                      -- Go to buzzing state
					else
						curr_state <= idle;
					end if;
					
				-----------------------------------------------------------------------------------------------------------------------------------		
					
				when buzzing => 
					if a_off = '0' then        -- If button 'a_off' is pressed, turn off the alarm
						curr_state <= idle;    -- Go to idle state
					else
						prev_min <= min;       -- Storing the value of min and hour before a_off is pushed
						prev_hour <= hour;
						curr_state <= buzzing; -- Keep on buzzing
					end if;
				
				-----------------------------------------------------------------------------------------------------------------------------------
					
			end case;
			
		end if;
		
	end process;
	
	-- Output 1kHz or '0' to buzz
	buzz <= '0'      when curr_state = idle else
			  clk_1kHz when curr_state = buzzing else
			  '0';

end ARCHITECTURE;