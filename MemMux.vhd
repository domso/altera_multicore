library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.constants.all;

entity MemMux is
	Port (
		ALUDataIn 		: in std_logic_vector(31 downto 0);
		Set 				: in std_logic;
		FunctI			: in std_logic_vector(2 downto 0);
		MemoryDataIn 	: in std_logic_vector(31 downto 0);
		WrData 			: out std_logic_vector(31 downto 0)
	);
end MemMux;

architecture Behavioral of MemMux is
begin
process(MemoryDataIn, ALUDataIn, Set)
begin

if (set = '1') then
	WrData <= MemoryDataIn;
else
	WrData <= ALUDataIn;
end if;

end process;

end Behavioral;
