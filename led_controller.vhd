library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_controller is
	generic (size : integer := 31);
	Port (	
		V	  : in  std_logic_vector(31 downto 0);	
		set  : in  std_logic;	
		nRst : in  std_logic;
		Clk  : in  std_logic;
		
		led : out std_logic_vector(size downto 0)
	);	
end led_controller;

architecture Behavioral of led_controller is
signal store_led : std_logic_vector(size downto 0);

begin
process(nRst, Clk)
begin

if (nRst = '0') then
	store_led <= (others => '0');	
	led <= (others => '0');
elsif (rising_edge(Clk)) then
	if (set = '1') then	
		store_led <= V(size downto 0);
	end if;
	
	led <= store_led;
end if;
end process;

end Behavioral;
