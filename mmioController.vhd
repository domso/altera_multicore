library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mmioController is
	Port (
		data        : inout	std_logic_vector(31 downto 0);
		address     : inout	std_logic_vector(31 downto 0);
		ctrl	      : inout	std_logic_vector(31 downto 0);
		
		busAck      : in	std_logic_vector(31 downto 0);
		nRst        : in	std_logic;
		Clk			: in	std_logic;
		
		dataO	 		: out std_logic_vector(31 downto 0);
		wren			: out	std_logic
	);	
end mmioController;

architecture Behavioral of mmioController is

begin
process(nRst, Clk)
begin

if nRst = '0' then
	data	  <= (others => 'Z');
	address <= (others => 'Z');
	ctrl    <= (others => 'Z');
	wren    <= '0';
elsif rising_edge(Clk) then
	if busAck /= x"FFFFFFFF" and ctrl(31) = '0' and ctrl(0) = '1' and address(31 downto 30) = "11" then	
		ctrl	<= x"00000000";
		dataO	<= data;
		wren  <= '1';
	else
		ctrl <= (others => 'Z');
		wren <= '0';
	end if;				
			
	data	  <= (others => 'Z');
	address <= (others => 'Z');
end if;

end process;


end Behavioral;
