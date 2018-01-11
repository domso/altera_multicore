library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BusController is
	generic (mhartid : std_logic_vector(31 downto 0));
	Port (		
		busData		: inout std_logic_vector(31 downto 0);
		busAddr		: inout std_logic_vector(31 downto 0);
		busCtrl		: inout std_logic_vector(31 downto 0);


		busAck		: in std_logic_vector(31 downto 0);
		busReq		: out std_logic_vector(31 downto 0);
		busForward	: in std_logic_vector(31 downto 0);	
		


		nRst   					: in std_logic;
		Clk   					: in std_logic;	

		Func     	         : in std_logic_vector(3 downto 0);	
		data        			: in	std_logic_vector(31 downto 0);
		address     			: in	std_logic_vector(31 downto 0);
		wren        			: in	std_logic;
		link        			: in	std_logic;
		byteEna 	            : in std_logic_vector(3 downto 0);
		
		dataO	      			: out	std_logic_vector(31 downto 0);
		Stall						: out	std_logic
	);
end BusController;

architecture Behavioral of BusController is
	type state_type is (STATE_READY, STATE_FORWARD, STATE_ACQUIRE, STATE_SEND);
	signal aktuellerZustand: state_type;
	
	signal store_data        			: std_logic_vector(31 downto 0);
	signal store_address     			: std_logic_vector(31 downto 0);
	signal store_link_address 			: std_logic_vector(31 downto 0);
	signal store_wren        			: std_logic;
	signal store_link        			: std_logic;
	signal store_byteEna 	         : std_logic_vector(3 downto 0);
	signal store_func 	            : std_logic_vector(3 downto 0);
	
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
			if (byteEna /= "0000" and address(31 downto 30) /= "00") then
				Stall <= '1';
				
				store_data 	  <= data;
				store_address <= address;
				store_wren    <= wren;
				store_link	  <= link;
				store_byteEna <= byteEna;
				store_func	  <= Func;
								
				if (busForward = x"FFFFFFFF") then				
					aktuellerZustand <= STATE_ACQUIRE;
				else
					aktuellerZustand <= STATE_FORWARD;
				end if;
			else
				Stall <= '0';
			end if;
			
			if (busAddr = store_link_address and busCtrl(31) = '0' and busCtrl(0) = '1') then
				store_link_address <= x"00000000";
			end if;
			
			dataO <= x"00000001";
			busData <= (others => 'Z');
			busAddr <= (others => 'Z');
			busCtrl <= (others => 'Z');
		when STATE_FORWARD =>			
			if (busForward = x"FFFFFFFF") then				
				aktuellerZustand <= STATE_ACQUIRE;
			end if;
			
			if (busAddr = store_link_address and busCtrl(31) = '0' and busCtrl(0) = '1') then
				store_link_address <= x"00000000";
			end if;
			
			Stall <= '1';
			dataO <= x"00000001";
			busData <= (others => 'Z');
			busAddr <= (others => 'Z');
			busCtrl <= (others => 'Z');
		when STATE_ACQUIRE =>	
			if (store_link = '1' and store_wren = '1' and store_link_address /= store_address) then
				aktuellerZustand <= STATE_READY;
				dataO <= x"00000001";				
				Stall <= '0';
				
				if (busAck = mhartid) then				
					busCtrl <= x"00000000";
				else
					busCtrl <= (others => 'Z');
				end if;
				
				busData <= (others => 'Z');
				busAddr <= (others => 'Z');
			else
				if (busAck = mhartid) then				
					aktuellerZustand <= STATE_SEND;
					if store_wren = '1' or store_func /= "0000" then
						busData <= store_data;
					else
						busData <= (others => 'Z');
					end if;
					busAddr <= store_address;
					busCtrl <= x"00000" & "000" & store_func & store_byteEna & store_wren;
				else	
					if (busAddr = store_link_address and busCtrl(31) = '0' and busCtrl(0) = '1') then
						store_link_address <= x"00000000";
					end if;
					
					busData <= (others => 'Z');
					busAddr <= (others => 'Z');
					busCtrl <= (others => 'Z');
				end if;
				
				Stall <= '1';
				dataO <= x"00000002";
			end if;
		when STATE_SEND =>
			if (busCtrl = x"00000000") then
				aktuellerZustand <= STATE_READY;
					
				Stall <= '0';
				
				if (store_link = '1' and store_wren = '1') then
					dataO <= x"00000000";
				else
					dataO <= busData;			
				end if;
				
				if (store_link = '1' and store_wren = '0') then
					store_link_address <= store_address;
				else						
					store_link_address <= x"00000000";				
				end if;
			else
				dataO <= x"00000003";
				Stall <= '1';
			end if;
			
			busData <= (others => 'Z');
			busAddr <= store_address;
			busCtrl <= (others => 'Z');
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
			busReq	<= mhartid;
		when STATE_SEND =>
			busReq  <= mhartid;
	end case;
end process;

end Behavioral;
