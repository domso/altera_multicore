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
	type state_type is (STATE_READY, STATE_FORWARD, STATE_ACQUIRE, STATE_SEND, STATE_CLEAR);
	signal aktuellerZustand: state_type;
	
	signal store_data        			: std_logic_vector(31 downto 0);
	signal store_address     			: std_logic_vector(31 downto 0);
	signal store_wren        			: std_logic;
	signal store_byteEna 	         : std_logic_vector(3 downto 0);
	
begin

process(nRst, Clk)
begin

if nRst = '0' then
	dataO 	  <= x"00000000";
	busData <= (others => 'Z');
	busAddr <= (others => 'Z');
	busCtrl <= (others => 'Z');
	aktuellerZustand <= STATE_READY;
	Stall <= '0';
elsif rising_edge(Clk) then
	case aktuellerZustand is
		when STATE_READY =>
			if (byteEna /= "0000") then
				Stall <= '1';
				
				store_data 	  <= data;
				store_address <= address;
				store_wren    <= wren;
				store_byteEna <= byteEna;
				
				if (busForward = x"FFFFFFFF") then				
					aktuellerZustand <= STATE_ACQUIRE;
				else
					aktuellerZustand <= STATE_FORWARD;
				end if;
			else
				Stall <= '0';
			end if;
			
			dataO <= x"00000001";
			busData <= (others => 'Z');
			busAddr <= (others => 'Z');
			busCtrl <= (others => 'Z');
		when STATE_FORWARD =>			
			if (busForward = x"FFFFFFFF") then				
				aktuellerZustand <= STATE_ACQUIRE;
			end if;
			
			Stall <= '1';
			dataO <= x"00000001";
			busData <= (others => 'Z');
			busAddr <= (others => 'Z');
			busCtrl <= (others => 'Z');
		when STATE_ACQUIRE =>			
			if (busAck = id) then				
				aktuellerZustand <= STATE_SEND;
				if store_wren = '1' then
					busData <= store_data;
				else
					busData <= (others => 'Z');
				end if;
				busAddr <= store_address;
				busCtrl <= x"000000" & "000" & store_byteEna & store_wren;
			else				
				busData <= (others => 'Z');
				busAddr <= (others => 'Z');
				busCtrl <= (others => 'Z');
			end if;
			Stall <= '1';
			dataO <= x"00000002";
		when STATE_SEND =>
			if (busCtrl = x"00000000") then
				aktuellerZustand <= STATE_READY;
				dataO <= busData;				
				Stall <= '0';
			else
				dataO <= x"00000003";
				Stall <= '1';
			end if;
			busData <= (others => 'Z');
			busAddr <= store_address;
			busCtrl <= (others => 'Z');
		when STATE_CLEAR =>
			aktuellerZustand <= STATE_READY;	
			dataO <= x"00000004";	
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
		when STATE_READY =>
			busReq  <= busForward;
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
