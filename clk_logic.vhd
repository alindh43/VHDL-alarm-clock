--Clk logic

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY clk_logic is
	PORT( clk       : in std_logic;    -- 50MHz clk
			mode      : in std_logic;    -- Button, when pressed ('0') the alarm can be set
			set       : in std_logic;    -- Button, when pressed ('0') the time or the alarm can be set (depending on if mode is '0' or '1')
			fast_mode : in std_logic;    -- Switch, when '1' fast mode is activated and setting the time or alarm goes significantly faster
			clk_time  : out std_logic;   -- Clk for counting the time
			clk_alarm : out std_logic;   -- Clk for counting the alarm
			clk_lcd   : out std_logic;   -- Clk for the lcd (1kHz)
			clk_buzz  : out std_logic ); -- Clk for sound generation (1kHz)
end ENTITY;

ARCHITECTURE Behav of clk_logic is		
	signal count_time_1s, count_time_set, count_alarm, count_lcd, count_buzz: integer range 0 to 50000001 := 0; -- Counters
	signal temp_clk_time, temp_clk_alarm, temp_clk_lcd, temp_clk_buzz : std_logic := '1';                       -- Keep track of clocks
begin


-----------------------------------------------------------------------------------------------------------------------------------------------		
		
	-- Logic for chosing which clk to run for the real-time clock. Either 1s clk, faster clk that sets the time, or an even faster clk that 
	-- sets the time when fast mode is active. The "counter limit"/"clk divider factor" for the TIME clk is basically arbitrary, but the 
	-- rest of the "set-clks" (even the ones for the alarm) are related in some way to this value.
	time_clock : process(clk, mode, set, fast_mode, count_time_1s, count_time_set, temp_clk_time)
	begin
	
		if rising_edge(clk) then
	
			-- Set time 
			if (set = '0') and (mode = '1') then
				count_time_1s <= 0;
				count_time_set <= count_time_set + 1;
				
				if (fast_mode = '1') then 
					-- Fast mode on, 60x faster than the regular TIME set clk
					if count_time_set >= (50000000/(60*10*60)) then  
						count_time_set <= 0;
						temp_clk_time <= not(temp_clk_time);
					end if;
					
				else 
				
					-- Regular TIME set clk
					if count_time_set >= (50000000/(60*10)) then -- Arbitrary value for counter limit
						count_time_set <= 0;
						temp_clk_time <= not(temp_clk_time);
					end if;
				end if;
					
			-- Real time clock (1s clk)
			else
				count_time_set <= 0;
				count_time_1s <= count_time_1s + 1;
				if count_time_1s >= (25000000) then  -- Dividing the 50MHz clk with 25e6 produces second increments close to "real seconds"
					count_time_1s <= 0;
					temp_clk_time <= not(temp_clk_time);
				end if;
				
			end if;
			
		end if;	
	end process;
	clk_time <= temp_clk_time;
	
-----------------------------------------------------------------------------------------------------------------------------------------------
	
	-- Clk for the alarm, if mode and set are not pressed in the clock is '0'
	alarm_clock : process(clk, set, mode, fast_mode, count_alarm, temp_clk_alarm)
	begin
	
		if rising_edge(clk) then
			if (set = '0') and (mode = '0') then
				count_alarm <= count_alarm + 1;
				if (fast_mode = '1') then
					
					-- Fast mode on, setting the alarm is 60x faster than the regular ALARM set clk 
					if count_alarm >= (50000000/(10*60)) then  
						count_alarm <= 0;
						temp_clk_alarm <= not(temp_clk_alarm);
					end if;
					
				else 
				
					-- Regular ALARM set clk (60x slower than regular TIME set clk since the TIME counts in seconds, but the ALARM counts in minutes)
					if count_alarm >= (50000000/10) then  
						count_alarm <= 0;
						temp_clk_alarm <= not(temp_clk_alarm);	
					end if;
					
				end if;
				
			else
				temp_clk_alarm <= '0';  -- If mode and set are not pressed, set alarm clk to '0'
			end if;
			
		end if;
	end process;
	clk_alarm <= temp_clk_alarm;

-----------------------------------------------------------------------------------------------------------------------------------------------
	
	-- LCD clock, 1kHz
	lcd_clock : process(clk)
	begin
		if rising_edge(clk) then 
			count_lcd <= count_lcd + 1;
			if (count_lcd = 50000) then           -- 50MHz/50000 = 1kHz  
				count_lcd <= 0;
				temp_clk_lcd <= not(temp_clk_lcd);
			end if;
		end if;
	end process;
	clk_lcd <= temp_clk_lcd;
	
-----------------------------------------------------------------------------------------------------------------------------------------------
	
	-- Buzzer clock, 1 kHz
	buzz_clock : process(clk)
	begin
		if rising_edge(clk) then 
			count_buzz <= count_buzz + 1;
			if (count_buzz = 50000) then    -- 1kHz clock that can be used for sound generation
				count_buzz <= 0;
				temp_clk_buzz <= not(temp_clk_buzz);
			end if;
		end if;
	end process;
	clk_buzz <= temp_clk_buzz;

-----------------------------------------------------------------------------------------------------------------------------------------------	
	
	
end ARCHITECTURE;