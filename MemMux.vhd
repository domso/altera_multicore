library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.constants.all;

entity MemMux is
	Port (
		RomDataIn 	: in std_logic_vector(31 downto 0);
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
	case FunctI	is
		when "000"  => 		
			if (MemoryDataIn(7 + (to_integer(unsigned(ALUDataIn(1 downto 0))) * 8) downto 7 + (to_integer(unsigned(ALUDataIn(1 downto 0))) * 8)) = "1") then					
				WrData <= x"FFFFFF" & MemoryDataIn(7 + (to_integer(unsigned(ALUDataIn(1 downto 0))) * 8) downto (to_integer(unsigned(ALUDataIn(1 downto 0))) * 8));
			else
				WrData <= x"000000" & MemoryDataIn(7 + (to_integer(unsigned(ALUDataIn(1 downto 0))) * 8) downto (to_integer(unsigned(ALUDataIn(1 downto 0))) * 8));		
			end if;	
		when "001"  => 
			if (MemoryDataIn(15 + (to_integer(unsigned(ALUDataIn(1 downto 0))) * 8) downto (15 + to_integer(unsigned(ALUDataIn(1 downto 0))) * 8)) = "1") then
				WrData <= x"FFFF" & MemoryDataIn(15 + (to_integer(unsigned(ALUDataIn(1 downto 0))) * 8) downto (to_integer(unsigned(ALUDataIn(1 downto 0))) * 8));
			else
				WrData <= x"0000" & MemoryDataIn(15 + (to_integer(unsigned(ALUDataIn(1 downto 0))) * 8) downto (to_integer(unsigned(ALUDataIn(1 downto 0))) * 8));
			end if;	
		when "010"  => WrData <= MemoryDataIn;
		when "100"  => WrData <= x"000000" & MemoryDataIn(7 + (to_integer(unsigned(ALUDataIn(1 downto 0))) * 8) downto (to_integer(unsigned(ALUDataIn(1 downto 0))) * 8));		
		when "101"  => WrData <= x"0000" & MemoryDataIn(15 + (to_integer(unsigned(ALUDataIn(1 downto 0))) * 8) downto (to_integer(unsigned(ALUDataIn(1 downto 0))) * 8));
		when others => WrData <= MemoryDataIn;	
	end case;	
else
	WrData <= ALUDataIn;
end if;

end process;

end Behavioral;
