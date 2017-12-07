library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SRAMController is
	Port (
		data        : in	std_logic_vector(31 downto 0);
		wren        : in	std_logic;
		address     : in	std_logic_vector(9 downto 0);
		byteena		: in	std_logic_vector(3 downto 0);
		data_out		: out	std_logic_vector(31 downto 0);
		wren_out		: out	std_logic;
		address_out : out	std_logic_vector(9 downto 0);
		byteena_out : out	std_logic_vector(3 downto 0);
		Stall			: out	std_logic;
		
		nRst        : in	std_logic;
		Clk			: in	std_logic
	);	
end SRAMController;

architecture Behavioral of SRAMController is
type state_type is (waitMemInstr, readLowByte, readHighByte, writeHighByte);
signal aktuellerZustand: state_type;

signal store_data_out	 : std_logic_vector(31 downto 0);
signal store_wren_out	 : std_logic;
signal store_address_out : std_logic_vector(9 downto 0);
signal store_byteena_out : std_logic_vector(3 downto 0);

signal asd	 : std_logic;


begin
process(nRst, Clk, wren, byteena)
begin

if nRst = '0' then
	data_out				<= x"00000000";
	wren_out				<= '0';
	address_out 		<= "0000000000";
	byteena_out 		<= x"0";
	Stall					<= '0';
	aktuellerZustand	<= waitMemInstr;
	
	asd	<= '0';
elsif rising_edge(Clk) then
	case aktuellerZustand is	
		when waitMemInstr =>
			store_data_out				<= data;
			store_wren_out				<= wren;
			store_address_out			<= address;
			store_byteena_out 		<= byteena;
		
			data_out		<= x"00000000";
			wren_out		<= '0';
			address_out <= "0000000000";
			byteena_out <= x"0";
			
			if wren	= '1' then
				Stall			<= '1';
				aktuellerZustand <= writeHighByte;
			elsif byteena /= "0000" then
				Stall			<= '1';
				aktuellerZustand <= readLowByte;
			else
				Stall			<= '0';
			end if;			
		when readLowByte 	=>
			Stall					<= '1';
			aktuellerZustand  <= readHighByte;
		when readHighByte =>
			data_out				<= store_data_out;
			wren_out				<= store_wren_out;
			address_out			<= store_address_out;
			byteena_out 		<= store_byteena_out;
			
			Stall					<= '1';
			aktuellerZustand  <= waitMemInstr;
		when writeHighByte =>
			data_out				<= store_data_out;
			wren_out				<= store_wren_out;
			address_out			<= store_address_out;
			byteena_out 		<= store_byteena_out;
			
			Stall					<= '0';
			aktuellerZustand  <= waitMemInstr;	
	end case;
	
	
end if;

end process;


end Behavioral;
