library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;


entity Fetch is
	Port (
		JumpTarget	: in std_logic_vector(31 downto 0);
		InterlockI	: in std_logic;
		Stall			: in std_logic;
		
		PCNext		: out std_logic_vector(31 downto 0);
		ImemAddr		: out std_logic_vector(9 downto 0);
		PCOld			: in std_logic_vector(31 downto 0);
		Jump			: in std_logic
	);
end Fetch;

architecture Behavioral of Fetch is

begin
process(PCOld, Jump, JumpTarget, InterlockI, Stall)
begin

if (Jump = '1') then
	PCNext 	<= JumpTarget;	
	ImemAddr <= JumpTarget(11 downto 2);
else
	PCNext 	<= std_logic_vector(to_signed(to_integer(signed(PCOld)) + 4, 32));
	ImemAddr <= std_logic_vector(to_signed(to_integer(signed(PCOld)) + 4, 32))(11 downto 2);
end if;

end process;

end Behavioral;
