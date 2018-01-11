library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.constants.all;

entity RegSet is
	Port (
		WrEn   					: in std_logic;
		WrRegNo  				: in std_logic_vector(5 downto 0);
		WrData   				: in std_logic_vector(31 downto 0);
				
		RdRegNo1 				: in std_logic_vector(5 downto 0);
		RdRegNo2 				: in std_logic_vector(5 downto 0);
						
		nRst   					: in std_logic;
		Clk   					: in std_logic;
		mhartid   				: in std_logic_vector(31 downto 0);
		
		RdData1   				: out std_logic_vector(31 downto 0);
		RdData2   				: out std_logic_vector(31 downto 0)
	);
end RegSet;

architecture Behavioral of RegSet is
TYPE TRegisters IS array (0 to 63) of std_logic_vector(31 downto 0);
SIGNAL Registers    : TRegisters;
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
	
	--misa ISA and extensions supported.
		Registers(32) <= x"00000000";
	--mvendorid Vendor ID.
		Registers(33) <= x"00000000";
	--marchid Architecture ID.
		Registers(34) <= x"00000000";
	--mimpid Implementation ID.
		Registers(35) <= x"00000000";
	--mhartid Hardware thread ID.
		Registers(36) <= mhartid;
	
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
