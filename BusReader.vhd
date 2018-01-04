library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BusReader is
	Port (
		busData        : in	std_logic_vector(31 downto 0);
		busAddress     : in	std_logic_vector(31 downto 0);
		busCtrl        : in	std_logic_vector(31 downto 0);
		
		sram				: in std_logic_vector(15 downto 0);
		
		nRst        : in	std_logic;
		Clk			: in	std_logic
	);	
end BusReader;

architecture Behavioral of BusReader is
		signal signal_busData        : std_logic_vector(31 downto 0);
		signal signal_busAddress     : std_logic_vector(31 downto 0);
		signal signal_busCtrl        : std_logic_vector(31 downto 0);
begin
process(nRst, Clk)
begin

if nRst = '0' then
	signal_busData 	<= x"00000000";
	signal_busAddress <= x"00000000";
	signal_busCtrl 	<= x"00000000";
elsif rising_edge(Clk) then
	signal_busData 	<= busData;
	signal_busAddress <= busAddress;
	signal_busCtrl 	<= busCtrl;
end if;
end process;


end Behavioral;
