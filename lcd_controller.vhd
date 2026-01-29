-- LCD Controller

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


ENTITY lcd_controller IS	
	port(	rst			    : in 	std_logic;	
			clk			 	: in 	std_logic;							-- 1kHz clk (period of 1ms)
			lcd_enable 		: in	std_logic; 	                        -- Latches data into the controller
			lcd_bus 	    : in    std_logic_vector(9 downto 0);       -- [RS RW DB[7..0]]
			busy		    : out	std_logic := '1'; 				    -- Busy flag
			RW              : out 	std_logic; 				 			-- Read/write 
			RS              : out 	std_logic; 							-- Register select
			E               : out 	std_logic; 							-- Enabale data read/write
			lcd_data	    : out	std_logic_vector(7 downto 0);	    -- Data fed in to the display (DB[7..0])
			lcd_ON 	  	    : out   std_logic;							-- Turn on LCD display
			lcd_BLON	    : out   std_logic);							-- Turn on LCD backlight
end ENTITY;


ARCHITECTURE Behav of lcd_controller IS
	type t_state is (power_up, initialize, ready, send);
	signal curr_state	:	t_state;
	signal clk_count : integer range 0 to 30 := 0;
begin

	lcd_ON <= '1';		-- LCD power ON
	lcd_BLON <= '1';	-- LCD backlight ON
	
	process(clk)
	begin
	
		if rising_edge(clk) then
		
			if rst = '0' then			
				curr_state <= power_up;
				
			else
				case curr_state is
					
					-------------------------------------------------------------------------------------------------
					
					when power_up => 	
						busy <= '1';
						if (clk_count < 20) then        -- Wait 20 ms 
							clk_count <= clk_count + 1;
							curr_state <= power_up;
						else				            -- Power up complete
							clk_count <= 0;
							RS <= '0';
							RW <= '0';
							lcd_data <= "00111000";	    -- Function set_ 2-line mode
							curr_state <= initialize;
						end if;
					
					-------------------------------------------------------------------------------------------------
					
					when initialize => 	
						busy <= '1';
						clk_count <= clk_count + 1;
						if (clk_count < 2) then		  -- Wait 2ms 
							lcd_data <= "00111100";
							E <= '1';
							curr_state <= initialize;
						
						elsif (clk_count < 4) then	  -- Wait 2ms
							lcd_data <= "00000000";
							E <= '0';
							curr_state <= initialize;
							
						elsif (clk_count < 6) then	  -- Wait 2ms
							lcd_data <= "00001100";   -- Display on, cursor off, blink off
							E <= '1';
							curr_state <= initialize;
							
						elsif (clk_count < 8) then	  -- Wait 2ms
							lcd_data <= "00000000";
							E <= '0';
							curr_state <= initialize;
						
						elsif (clk_count < 10) then   -- Wait 2ms 
							lcd_data <= "00000001";	  -- Clear display
							E <= '1';
							curr_state <= initialize;
							
						elsif (clk_count < 14) then   -- Wait 4ms
							lcd_data <= "00000000";
							E <= '0';
							curr_state <= initialize;
							
						elsif (clk_count < 16) then   -- Wait 2ms, entry mode set
							lcd_data <= "00000110";	  -- Increment mode, no shift
							E <= '1';
							curr_state <= initialize;
							
						elsif (clk_count <= 18) then  -- Wait 2ms
							lcd_data <= "00000000";
							E <= '0';
							curr_state <= initialize;
						else
						-- Initialization complete
							clk_count <= 0;
							busy <= '0';
							curr_state <= ready;
						end if;
					
					
					-------------------------------------------------------------------------------------------------
					
					-- Wait for enable and latch in the instructions
					when ready	=>		
						if lcd_enable = '1' then
							busy <= '1';
							RS <= lcd_bus(9);
							RW <= lcd_bus(8);
							lcd_data <= lcd_bus(7 downto 0);
							clk_count <= 0;
							curr_state <= send;
						else
							busy <= '0';
							RS <= '0';
							RW <= '0';
							lcd_data <= (others => '0');
							clk_count <= 0;
							curr_state <= ready;
						end if;
						
					-------------------------------------------------------------------------------------------------
					
					-- Send instructions to LCD
					when send 	=> 	
						busy <= '1';
						if (clk_count < 8) then	       -- Staying in 'send'-state for 8ms
							busy <= '1';
							if (clk_count < 2) then    -- Negative enable (E='0')	
								E <= '0';
							elsif (clk_count < 4) then -- Positive enable (E='1') half cycle 
								E <= '1';
							elsif (clk_count < 6) then -- Negative enable 
								E <= '0';
							end if;
							clk_count <= clk_count + 1;
							curr_state <= send;
						else
							clk_count <= 0;
							curr_state <= ready;
						end if;
					-------------------------------------------------------------------------------------------------
					
				end case;
			end if;
		end if;
	end process;
end ARCHITECTURE;