library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SevenSeg is
	Port (
	
		set  : in  std_logic;
		V	  : in  std_logic_vector(31 downto 0);		
		nRst : in  std_logic;
		Clk  : in  std_logic;
		
		Hex0 : out std_logic_vector(6 downto 0);
		Hex1 : out std_logic_vector(6 downto 0);
		Hex2 : out std_logic_vector(6 downto 0);
		Hex3 : out std_logic_vector(6 downto 0)
	);	
end SevenSeg;

architecture Behavioral of SevenSeg is
signal state : std_logic_vector(31 downto 0);

begin
process(nRst, Clk)
begin

if (nRst = '0') then
	state <= x"00000000";
	Hex0  <= "0000000";
	Hex1  <= "0000000";
	Hex2  <= "0000000";
	Hex3  <= "0000000";
elsif (rising_edge(Clk)) then
	if (set = '1') then	
		state <= V;
	end if;
	
	Hex0 <= state(6 downto 0);
	Hex1 <= state(14 downto 8);
	Hex2 <= state(22 downto 16);
	Hex3 <= state(30 downto 24);
end if;
end process;

end Behavioral;
