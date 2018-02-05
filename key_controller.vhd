library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity key_controller is
	Port (	
		set  : in  std_logic;		
		nRst : in  std_logic;
		Clk  : in  std_logic;
		V	  : in  std_logic_vector(3 downto 0);	
		
		keys : out std_logic_vector(31 downto 0)
	);	
end key_controller;

architecture Behavioral of key_controller is
begin
process(nRst, Clk)
variable pressedState : std_logic_vector(3 downto 0);
variable eventState : std_logic_vector(3 downto 0);
begin

if (nRst = '0') then	
	pressedState := (others => '0');
	eventState := (others => '0');
	--keys    <= (others => '0');
elsif (rising_edge(Clk)) then	
	pressedState := pressedState or V;
	
	for i in 0 to 3 loop
		if (pressedState(i) = '1' and V(i) = '0') then
			eventState(i) := '1';
			pressedState(i) := '0';
		end if;
	end loop;

	if (set = '1') then
		keys <= x"000000" & eventState & V;
		eventState := "0000";
	end if;
end if;

end process;

end Behavioral;
