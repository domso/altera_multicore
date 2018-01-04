library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BusSync is
	Port (
		busData        : in	std_logic_vector(31 downto 0);
		busAddress     : in	std_logic_vector(31 downto 0);
		busCtrl        : in	std_logic_vector(31 downto 0);

		SRAM        : in	std_logic_vector(15 downto 0);
	
		busDataO        : out	std_logic_vector(31 downto 0);
		busAddressO     : out	std_logic_vector(31 downto 0);
		busCtrlO        : out	std_logic_vector(31 downto 0);
		
		SRAMO        : out	std_logic_vector(15 downto 0);
		
		nRst        : in	std_logic;
		Clk			: in	std_logic
	);	
end BusSync;

architecture Behavioral of BusSync is
begin
process(nRst, Clk)
begin

if nRst = '0' then
	busDataO 	<= x"00000000";
	busAddressO <= x"00000000";
	busCtrlO 	<= x"00000000";
	SRAMO			<= x"0000";
elsif rising_edge(Clk) then
	busDataO 	<= busData;
	busAddressO <= busAddress;
	busCtrlO 	<= busCtrl;
	SRAMO			<= SRAM;
end if;
end process;


end Behavioral;
