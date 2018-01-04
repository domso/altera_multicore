library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SRAMControllerOnBus is
	Port (
		data        : inout	std_logic_vector(31 downto 0);
		address     : inout	std_logic_vector(31 downto 0);
		ctrl	    : inout	std_logic_vector(31 downto 0);
		
		SRAM_address			: out std_logic_vector(19 downto 0);
		SRAM_data				: inout std_logic_vector(15 downto 0);
		SRAM_Read_Enable_N 	: out std_logic;
		SRAM_Write_Enable_N 	: out std_logic;
		SRAM_Chip_Enable_N 	: out std_logic;
		SRAM_Low_Byte_N 		: out std_logic;
		SRAM_High_Byte_N		: out std_logic;
	
		
		nRst        : in	std_logic;
		Clk			: in	std_logic
	);	
end SRAMControllerOnBus;

architecture Behavioral of SRAMControllerOnBus is
type state_type is (waitMemInstr, readLowByte, readHighByte, writeHighByte);
signal aktuellerZustand: state_type;
	
signal SRAM_data_store				: std_logic_vector(15 downto 0);
signal SRAM_address_store			: std_logic_vector(19 downto 0);
signal SRAM_Write_Enable_N_store : std_logic;

begin
process(nRst, Clk)
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
	data				 			<= (others => 'Z');
	address				 			<= (others => 'Z');
	
elsif rising_edge(Clk) then
	SRAM_Chip_Enable_N	<= '0';
	address				 			<= (others => 'Z');
	
	case aktuellerZustand is	
		when waitMemInstr =>			
			if ctrl /= x"00000000" and address(31) = '1' then				
				case ctrl(4 downto 1) is
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
			elsif ctrl(4 downto 1) /= "0000" and address(19) = '1' then
				SRAM_data				<= (others => 'Z');
				SRAM_Read_Enable_N	<= '0';
				SRAM_Write_Enable_N  <= '1';		
				aktuellerZustand 		<= readLowByte;
				SRAM_Low_Byte_N		<= '0';
				SRAM_High_Byte_N		<= '0';
			else
				SRAM_data				<= (others => 'Z');
				SRAM_Read_Enable_N	<= '1';
				SRAM_Write_Enable_N  <= '1';	
				SRAM_Low_Byte_N		<= '0';
				SRAM_High_Byte_N		<= '0';
			end if;				
			
			SRAM_address				<= address(19 downto 1) & "0";
			SRAM_address_store		<= std_logic_vector(to_unsigned(to_integer(unsigned(address(18 downto 0) & "0")) + 1, 20));		
			data				 			<= (others => 'Z');
			ctrl				 			<= (others => 'Z');
		when readLowByte 	=>
			SRAM_Read_Enable_N		<= '0';
			SRAM_Write_Enable_N 		<= '1';		
			SRAM_address				<= SRAM_address_store;
			aktuellerZustand  		<= readHighByte;
			SRAM_data_store			<= SRAM_data;
			data				 			<= (others => 'Z');
			ctrl				 			<= (others => 'Z');
		when readHighByte =>			
			SRAM_Read_Enable_N		<= '1';
			SRAM_Write_Enable_N  	<= '1';	
			SRAM_address				<= SRAM_address_store;
			aktuellerZustand  		<= waitMemInstr;
			ctrl							<= x"00000000";
			data 					 		<= SRAM_data & SRAM_data_store;
			SRAM_data					<= (others => 'Z');
		when writeHighByte =>
			SRAM_data					<= SRAM_data_store;
			SRAM_Read_Enable_N		<= 'X';
			SRAM_Write_Enable_N 	 	<= SRAM_Write_Enable_N_store;
			SRAM_address				<= SRAM_address_store;
			aktuellerZustand 			<= waitMemInstr;	
			ctrl							<= x"00000000";
			data				 			<= (others => 'Z');
	end case;
end if;

end process;


end Behavioral;
