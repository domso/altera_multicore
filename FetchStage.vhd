library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;


entity FetchStage is
	Port (
		PCI			: in std_logic_vector(31 downto 0);
		PCO			: out std_logic_vector(31 downto 0);	
		
		nRst   		: in std_logic;
		Clk   		: in std_logic
	);
end FetchStage;

architecture Behavioral of FetchStage is

begin
process(Clk, nRst)
begin

if nRst = '0' then
	PCO	<= x"FFFFFFFC";		
elsif rising_edge(Clk) then
	PCO	<= PCI;
end if;


end process;

end Behavioral;
