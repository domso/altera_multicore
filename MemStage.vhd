library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MemStage is
	Port (
		FunctI			: in std_logic_vector(2 downto 0);
		DestDataI		: in std_logic_vector(31 downto 0);
		DestRegNoI		: in std_logic_vector(5 downto 0);
		DestWrEnI		: in std_logic;
		MemAccessI		: in std_logic;
		
		DestWrEnO		: out std_logic;
		DestRegNoO		: out std_logic_vector(5 downto 0);
		DestDataO		: out std_logic_vector(31 downto 0);
		MemAccessO		: out std_logic;
		FunctO			: out std_logic_vector(2 downto 0);
				
				
		StallI			: in std_logic;
		nRst   			: in std_logic;
		Clk   			: in std_logic
	);
end MemStage;

architecture Behavioral of MemStage is
begin

process(nRst, Clk, StallI)
begin

if nRst = '0' then
	DestWrEnO		<= '0';
	DestRegNoO		<= "000000";
	DestDataO		<= x"00000000";
	MemAccessO		<= '0';
	FunctO			<= "000";
elsif rising_edge(Clk) then
	if StallI = '0' then
		DestWrEnO		<= DestWrEnI;
		DestRegNoO		<= DestRegNoI;
		DestDataO		<= DestDataI;
		MemAccessO		<= MemAccessI;
		FunctO			<= FunctI;
	end if;
end if;

end process;


end Behavioral;
