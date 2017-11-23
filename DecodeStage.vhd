library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DecodeStage is
	Port (
		PCNextI    				: in std_logic_vector(31 downto 0);
		InsnI    				: in std_logic_vector(31 downto 0);
		
		ClearI					: in std_logic;
		InterlockI				: in std_logic;
		StallI					: in std_logic;
		
		
		InsnO    				: out std_logic_vector(31 downto 0);
		PCNextO    				: out std_logic_vector(31 downto 0);
		
		ClearO					: out std_logic;
		InterlockO				: out std_logic;
		StallO					: out std_logic;
		
		nRst   					: in std_logic;
		Clk   					: in std_logic
	);
end DecodeStage;

architecture Behavioral of DecodeStage is
begin

process(nRst, Clk)
begin

if nRst = '0' then
	InsnO 	  <= x"00000000";
	PCNextO    <= x"00000000";
	ClearO     <= '0';
	InterlockO <= '0';
	StallO     <= '0';	
elsif rising_edge(Clk) then
	InsnO 	  <= InsnI;
	PCNextO    <= PCNextI;
	ClearO     <= ClearI;
	InterlockO <= InterlockI;
	StallO     <= StallI;
end if;

end process;


end Behavioral;
