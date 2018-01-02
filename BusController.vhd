library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BusController is
	generic (id : std_logic_vector(31 downto 0));
	Port (		
		busData		: inout std_logic_vector(31 downto 0);
		busAddr		: inout std_logic_vector(31 downto 0);
		busCtrl		: inout std_logic_vector(31 downto 0);


		busAck		: in std_logic_vector(31 downto 0);
		busReq		: out std_logic_vector(31 downto 0);
		busForward	: in std_logic_vector(31 downto 0);	


		nRst   					: in std_logic;
		Clk   					: in std_logic;	

		data        			: in	std_logic_vector(31 downto 0);
		address     			: in	std_logic_vector(31 downto 0);
		wren        			: in	std_logic;
		byteEna 	            : in std_logic_vector(3 downto 0);
		
		dataO	      			: out	std_logic_vector(31 downto 0);
		Stall						: out	std_logic
	);
end BusController;

architecture Behavioral of BusController is
	type state_type is (STATE_FORWARD, STATE_ACQUIRE, STATE_SEND, STATE_CLEAR);
	signal aktuellerZustand: state_type;
begin

process(nRst, Clk)
begin

if nRst = '0' then
	dataO 	  <= x"00000000";
	busData <= (others => 'Z');
	busAddr <= (others => 'Z');
	busCtrl <= (others => 'Z');
	aktuellerZustand <= STATE_FORWARD;
	Stall <= '0';
elsif rising_edge(Clk) then
	case aktuellerZustand is
		when STATE_FORWARD =>
			if (byteEna /= "0000") then
				Stall <= '1';
			
				if (busForward = x"FFFFFFFF") then				
					aktuellerZustand <= STATE_ACQUIRE;
				end if;
			else
				Stall <= '0';
			end if;
			dataO <= x"00000000";
			busData <= (others => 'Z');
			busAddr <= (others => 'Z');
			busCtrl <= (others => 'Z');
		when STATE_ACQUIRE =>			
			if (busAck = id) then				
				aktuellerZustand <= STATE_SEND;
				busData <= data;
				busAddr <= address;
				busCtrl <= x"000000" & "000" & byteEna & wren;
			else				
				busData <= (others => 'Z');
				busAddr <= (others => 'Z');
				busCtrl <= (others => 'Z');
			end if;
			Stall <= '1';
			dataO <= x"00000000";
		when STATE_SEND =>
			if (busCtrl = x"00000000") then
				aktuellerZustand <= STATE_CLEAR;
				dataO <= busData;
			else
				dataO <= x"00000000";
			end if;
			busData <= (others => 'Z');
			busAddr <= address;
			busCtrl <= (others => 'Z');
			Stall <= '0';
		when STATE_CLEAR =>
			aktuellerZustand <= STATE_FORWARD;		
			busData <= (others => 'Z');
			busAddr <= (others => 'Z');
			busCtrl <= (others => 'Z');
			Stall <= '0';
	end case;
end if;

end process;

process(busForward)
begin
	case aktuellerZustand is
		when STATE_FORWARD =>
			busReq  <= busForward;
		when STATE_ACQUIRE =>
			busReq	<= id;
		when STATE_SEND =>
			busReq  <= id;
		when STATE_CLEAR =>
			busReq  <= x"FFFFFFFF";
	end case;
end process;

end Behavioral;
