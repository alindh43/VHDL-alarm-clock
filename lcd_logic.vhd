-- LCD Logic

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY lcd_logic is	
	port(	clk			: in	std_logic;						    -- 1kHz clock (the lcd will run on this clk)
			rst			: in 	std_logic;	
			lcd_busy		: in	std_logic;					    -- Busy flag
			sec         : in  std_logic_vector(7 downto 0); 
			min			: in std_logic_vector(7 downto 0);
			hour 			: in std_logic_vector(7 downto 0);
			a_min       : in std_logic_vector(7 downto 0);
			a_hour      : in std_logic_vector(7 downto 0);
			rst_lcd		: out std_logic;                            -- Passing the reset to the controller (same as rst)
			clk_lcd		: out	std_logic;                          -- Passing the clock to the controller (same as clk)
			lcd_enable 	: inout std_logic;                          -- Receiving lcd_enable from lcd controller
			lcd_bus 		: out   std_logic_vector(9 DOWNTO 0));  -- Controll signal (RS and RW) and data DB: [RS RW DB[7..0]]
end ENTITY;


ARCHITECTURE arch of lcd_logic is
	signal anode : integer range 0 to 30 := 0;                      -- Number of "actions" to write 
begin
	
	process(clk)
		constant nr_init  : std_logic_vector(3 downto 0) := "0011"; -- Every number has the same first four bits (nr_init)
	begin
	
		if rising_edge(clk) then
		
			if (lcd_busy = '0' AND lcd_enable = '0') then  
				lcd_enable <= '1';
				if anode < 30 then
					anode <= anode + 1;	
				else 
					anode <= 0;
				end if;
				
				case anode is
					
					-- Writing "TIME:  h1h0:m1m0:s1s0"
					when 1 => lcd_bus <= "1001010100";            			 -- T
					when 2 => lcd_bus <= "1001001001";            			 -- I
					when 3 => lcd_bus <= "1001001101";            			 -- M
					when 4 => lcd_bus <= "1001000101";            			 -- E
					when 5 => lcd_bus <= "10" & nr_init & "1010"; 			 -- :
					when 6 => lcd_bus <= "1000100000";            			 -- *Space*
					when 7 => lcd_bus <= "1000100000";            			 -- *Space*
					when 8 => lcd_bus <=  "10" & nr_init & hour(7 downto 4); -- h1
					when 9 => lcd_bus <=  "10" & nr_init & hour(3 downto 0); -- h0
					when 10 => lcd_bus <= "10" & nr_init & "1010";           -- :
					when 11 => lcd_bus <= "10" & nr_init & min(7 downto 4);  -- m1
					when 12 => lcd_bus <= "10" & nr_init & min(3 downto 0);  -- m0
					when 13 => lcd_bus <= "10" & nr_init & "1010";           -- :
					when 14 => lcd_bus <= "10" & nr_init & sec(7 downto 4);  -- s1
					when 15 => lcd_bus <= "10" & nr_init & sec(3 downto 0);  -- s0
					
					-- Switch rows
					when 16 => lcd_bus <= "0011000000";
					
					-- Writing "ALARM: h1h0:m1m0" (but with the alarm times instead (i.e a_hour and a_min)
					when 17 => lcd_bus <= "1001000001"; 					    -- A
					when 18 => lcd_bus <= "1001001100"; 						-- L
					when 19 => lcd_bus <= "1001000001"; 						-- A
					when 20 => lcd_bus <= "1001010010"; 						-- R
					when 21 => lcd_bus <= "1001001101"; 						-- M
					when 22 => lcd_bus <= "1000111010"; 						-- :
					when 23 => lcd_bus <= "1000100000"; 						-- *Space*
					when 24 => lcd_bus <= "10" & nr_init & a_hour(7 downto 4);  -- h1
					when 25 => lcd_bus <= "10" & nr_init & a_hour(3 downto 0);  -- h0
					when 26 => lcd_bus <= "10" & nr_init & "1010";              -- :
					when 27 => lcd_bus <= "10" & nr_init & a_min(7 downto 4);   -- m1
					when 28 => lcd_bus <= "10" & nr_init & a_min(3 downto 0);   -- m0				
					
					
					-- Return back to first row and first letter
					when 29 => lcd_bus <= "0000000010";
					
					
					-- Turn off the display
					when others => lcd_enable <= '0';
					
				END CASE;
				
			else
				lcd_enable <= '0';
			end if;
			
		end if;	
		
	end process;

	
	rst_lcd <= rst;
	clk_lcd <= clk;

end ARCHITECTURE;