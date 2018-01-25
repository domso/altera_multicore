library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mmioController is
	Port (
		busData        : inout	std_logic_vector(31 downto 0);
		busAddress     : inout	std_logic_vector(31 downto 0);
		busCtrl	      : inout	std_logic_vector(31 downto 0);
		
		dataI	 		: in std_logic_vector(31 downto 0);
		busAck      : in	std_logic_vector(31 downto 0);
		nRst        : in	std_logic;
		Clk			: in	std_logic;
		
		dataO	 		: out std_logic_vector(31 downto 0);
		set			: out	std_logic_vector(3 downto 0)
	);	
end mmioController;

architecture Behavioral of mmioController is

begin
process(nRst, Clk)
begin

if nRst = '0' then
	busData	  <= (others => 'Z');
	busAddress <= (others => 'Z');
	busCtrl    <= (others => 'Z');
	set        <= (others => '0');
	dataO      <= (others => '0');
elsif rising_edge(Clk) then
	if busAck /= x"FFFFFFFF" and busCtrl(31) = '0' and busCtrl /= x"00000000" and busAddress(31 downto 30) = "11" then	
		busCtrl	<= x"00000000";		
		
		if  (busCtrl(0) = '0') then
			case busAddress(7 downto 0) is
				when x"00" =>
					set  <= "0000";
					busData <= dataI;
				when others   =>
					set  <= "0000";
					busData <= (others => 'Z');
			end case;
			
			dataO <= (others => '0');
		else
			case busAddress(7 downto 0) is
				when x"10" =>
					set     <= "0001";
				when x"20" =>
					set     <= "0010";
				when x"30" =>
					set     <= "0100";
				when x"40" =>
					set     <= "1000";
				when others   => 
					set     <= "0000";
			end case;
			
			busData <= (others => 'Z');
			dataO   <= busData;
		end if;	
	else
		busCtrl <= (others => 'Z');
		busData <= (others => 'Z');
		dataO <= (others => '0');
		set  <= "0000";
	end if;						
	
	busAddress <= (others => 'Z');
end if;

end process;


end Behavioral;
