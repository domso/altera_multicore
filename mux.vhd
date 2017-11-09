library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.constants.all;

entity mux is
	Port (
		src1 				: in std_logic_vector(31 downto 0);
		src2 				: in std_logic_vector(31 downto 0);
		set 				: in std_logic;
		output 			: out std_logic_vector(31 downto 0)
	);
end mux;

architecture Behavioral of mux is
begin
process(src1, src2, set)
begin

if (set = '1') then
	output <= src1;
else
	output <= src2;
end if;

end process;

end Behavioral;
