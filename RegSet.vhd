library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.constants.all;

entity RegSet is
	Port (
		RdRegNo1 				: in std_logic_vector(4 downto 0);
		RdRegNo2 				: in std_logic_vector(4 downto 0);
		WrRegNo  				: in std_logic_vector(4 downto 0);
		WrData   				: in std_logic_vector(31 downto 0);
		
		RdData1   				: out std_logic_vector(31 downto 0);
		RdData2   				: out std_logic_vector(31 downto 0);
		
		WrEn   					: in std_logic;
		nRst   					: in std_logic;
		Clk   					: in std_logic
	);
end RegSet;

architecture Behavioral of RegSet is
TYPE TRegisters IS array (0 to 31) of std_logic_vector(31 downto 0);
SIGNAL Registers : TRegisters;
begin
process(Clk, nRst, WrEn, WrData)
begin

if nRst = '0' then
	Registers(0) <= x"00000000";
	Registers(1) <= x"00000001";
	
	for i in 2 to 31
	loop
		Registers(i) <= x"00000000";
	end loop;
		
elsif rising_edge(Clk) then

	if WrEn = '1' and to_integer(unsigned(WrRegNo)) > 0 then
		Registers(to_integer(unsigned(WrRegNo))) <= WrData;
	end if;

end if;

end process;

process(RdRegNo1, RdRegNo2)
begin
	RdData1 <= Registers(to_integer(unsigned(RdRegNo1)));
	RdData2 <= Registers(to_integer(unsigned(RdRegNo2)));
end process;

end Behavioral;
