library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity switch_controller is
	Port (			
		nRst : in  std_logic;
		Clk  : in  std_logic;
		V	  : in  std_logic_vector(17 downto 0);	
		
		sw : out std_logic_vector(31 downto 0)
	);	
end switch_controller;

architecture Behavioral of switch_controller is

begin
process(nRst, Clk)
begin

if (nRst = '0') then	
	sw <= (others => '0');
elsif (rising_edge(Clk)) then
	sw <= x"000" & "00" & V;
end if;

end process;

end Behavioral;
