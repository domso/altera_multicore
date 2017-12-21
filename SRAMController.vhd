library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SRAMController is
	Port (
		data        : in	std_logic_vector(31 downto 0);
		wren        : in	std_logic;
		address     : in	std_logic_vector(19 downto 0);
		byteena		: in	std_logic_vector(3 downto 0);
		
		data_out		: out	std_logic_vector(31 downto 0);
		
		
		
		SRAM_address			: out std_logic_vector(19 downto 0);
		SRAM_data				: inout std_logic_vector(15 downto 0);
		SRAM_Read_Enable_N 	: out std_logic;
		SRAM_Write_Enable_N 	: out std_logic;
		SRAM_Chip_Enable_N 	: out std_logic;
		SRAM_Low_Byte_N 		: out std_logic;
		SRAM_High_Byte_N		: out std_logic;
	
		Stall			: out	std_logic;
		
		nRst        : in	std_logic;
		Clk			: in	std_logic
	);	
end SRAMController;

architecture Behavioral of SRAMController is
type state_type is (waitMemInstr, readLowByte, readHighByte, writeHighByte);
signal aktuellerZustand: state_type;
	
signal SRAM_data_store				: std_logic_vector(15 downto 0);
signal SRAM_address_store			: std_logic_vector(19 downto 0);
signal SRAM_Write_Enable_N_store : std_logic;

begin
process(nRst, Clk, wren, byteena)
begin

if nRst = '0' then
	SRAM_Chip_Enable_N			<= '0';
	SRAM_Low_Byte_N				<= '0';
	SRAM_High_Byte_N				<= '0';	
	SRAM_Read_Enable_N			<= '1';
	SRAM_Write_Enable_N  		<= '1';
	SRAM_Write_Enable_N_store	<= '1';	
	SRAM_address					<= x"00000";
	SRAM_address_store   		<= x"00000";	
	SRAM_data						<= (others => 'Z');	
	data_out				 			<= x"00000000";
	
	Stall								<= '0';
elsif rising_edge(Clk) then
	SRAM_Chip_Enable_N	<= '0';
	
	case aktuellerZustand is	
		when waitMemInstr =>			
			if wren	= '1' and address(19) = '1' then
				Stall <= '1';
				
				case byteena is
					when "0001" =>
						SRAM_data					 <= "ZZZZZZZZ" & data(7 downto 0);
						SRAM_data_store			 <= (others => 'Z');
						SRAM_Low_Byte_N			 <= '0';
						SRAM_High_Byte_N			 <= '1';						
						SRAM_Write_Enable_N 		 <= '0';	
						SRAM_Write_Enable_N_store<= '1';
					when "0010" =>
						SRAM_data				    <= data(15 downto 8) & "ZZZZZZZZ";	
						SRAM_data_store			 <= (others => 'Z');
						SRAM_Low_Byte_N			 <= '1';
						SRAM_High_Byte_N			 <= '0';						
						SRAM_Write_Enable_N  	 <= '0';	
						SRAM_Write_Enable_N_store<= '1';
					when "0100" =>
						SRAM_data					 <= (others => 'Z');
						SRAM_data_store			 <= "ZZZZZZZZ"& data(23 downto 16);
						SRAM_Low_Byte_N			 <= '0';
						SRAM_High_Byte_N		 	 <= '1';					
						SRAM_Write_Enable_N  	 <= '1';	
						SRAM_Write_Enable_N_store<= '0';
					when "1000" =>
						SRAM_data					 <= (others => 'Z');		
						SRAM_data_store			 <= data(31 downto 24) & "ZZZZZZZZ";
						SRAM_Low_Byte_N			 <= '1';
						SRAM_High_Byte_N			 <= '0';					
						SRAM_Write_Enable_N  	 <= '1';	
						SRAM_Write_Enable_N_store<= '0';
					when "0011" =>
						SRAM_data					 <= data(15 downto 0);
						SRAM_data_store			 <= (others => 'Z');		
						SRAM_Low_Byte_N			 <= '0';
						SRAM_High_Byte_N			 <= '0';					
						SRAM_Write_Enable_N  	 <= '0';	
						SRAM_Write_Enable_N_store<= '1';
					when "1100" =>
						SRAM_data					 <= (others => 'Z');	
						SRAM_data_store			 <= data(31 downto 16);
						SRAM_Low_Byte_N			 <= '0';
						SRAM_High_Byte_N			 <= '0';					
						SRAM_Write_Enable_N  	 <= '1';	
						SRAM_Write_Enable_N_store<= '0';
					when "1111" =>
						SRAM_data					 <= data(15 downto 0);
						SRAM_data_store			 <= data(31 downto 16);
						SRAM_Low_Byte_N			 <= '0';
						SRAM_High_Byte_N			 <= '0';					
						SRAM_Write_Enable_N  	 <= '0';	
						SRAM_Write_Enable_N_store<= '0';
					when others =>
						SRAM_data					 <= (others => 'Z');	
						SRAM_data_store			 <= (others => 'Z');	
						SRAM_Low_Byte_N			 <= '0';
						SRAM_High_Byte_N			 <= '0';					
						SRAM_Write_Enable_N  	 <= '1';	
						SRAM_Write_Enable_N_store<= '1';
				end case;				
				
				SRAM_Read_Enable_N	<= 'X';	
				aktuellerZustand 		<= writeHighByte;
			elsif byteena /= "0000" and address(19) = '1' then
				Stall						<= '1';
				SRAM_data				<= (others => 'Z');
				SRAM_Read_Enable_N	<= '0';
				SRAM_Write_Enable_N  <= '1';		
				aktuellerZustand 		<= readLowByte;
				SRAM_Low_Byte_N		<= '0';
				SRAM_High_Byte_N		<= '0';
			else
				Stall						<= '0';
				SRAM_data				<= (others => 'Z');
				SRAM_Read_Enable_N	<= '1';
				SRAM_Write_Enable_N  <= '1';	
				SRAM_Low_Byte_N		<= '0';
				SRAM_High_Byte_N		<= '0';
			end if;				
			
			SRAM_address				<= address(18 downto 0) & "0";
			SRAM_address_store		<= std_logic_vector(to_unsigned(to_integer(unsigned(address(18 downto 0) & "0")) + 1, 20));		
			data_out				 		<= x"00000000";
		when readLowByte 	=>
			Stall							<= '1';
			SRAM_Read_Enable_N		<= '0';
			SRAM_Write_Enable_N 		<= '1';		
			SRAM_address				<= SRAM_address_store;
			aktuellerZustand  		<= readHighByte;
			SRAM_data_store			<= SRAM_data;
			data_out				 		<= x"00000000";
		when readHighByte =>			
			Stall							<= '0';
			SRAM_Read_Enable_N		<= '1';
			SRAM_Write_Enable_N  	<= '1';	
			SRAM_address				<= SRAM_address_store;
			aktuellerZustand  		<= waitMemInstr;
			data_out				 		<= SRAM_data & SRAM_data_store;
			SRAM_data					<= (others => 'Z');
		when writeHighByte =>
			Stall							<= '0';
			SRAM_data					<= SRAM_data_store;
			SRAM_Read_Enable_N		<= 'X';
			SRAM_Write_Enable_N 	 	<= SRAM_Write_Enable_N_store;
			SRAM_address				<= SRAM_address_store;
			aktuellerZustand 			<= waitMemInstr;	
			data_out				 		<= x"00000000";
	end case;
end if;

end process;


end Behavioral;
