library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SRAMControllerOnBus is
	Port (
		data        : inout	std_logic_vector(31 downto 0);
		address     : inout	std_logic_vector(31 downto 0);
		ctrl	      : inout	std_logic_vector(31 downto 0);
		
		busAck      : in	std_logic_vector(31 downto 0);
		nRst        : in	std_logic;
		Clk			: in	std_logic;
		ALUIn_1     : in  std_logic_vector(31 downto 0);
		ALUIn_2     : in  std_logic_vector(31 downto 0);
		
		SRAM_address			: out std_logic_vector(19 downto 0);
		SRAM_data				: inout std_logic_vector(15 downto 0);
		SRAM_Read_Enable_N 	: out std_logic;
		SRAM_Write_Enable_N 	: out std_logic;
		SRAM_Chip_Enable_N 	: out std_logic;
		SRAM_Low_Byte_N 		: out std_logic;
		SRAM_High_Byte_N		: out std_logic;
		
		ALUFunc              : out  std_logic_vector(3 downto 0);
		ALUOut_1             : out  std_logic_vector(31 downto 0);
		ALUOut_2             : out  std_logic_vector(31 downto 0)
	);	
end SRAMControllerOnBus;

architecture Behavioral of SRAMControllerOnBus is
type state_type is (waitMemInstr, readLowByte, readHighByte, writeHighByte);
signal aktuellerZustand: state_type;

signal SRAM_ALU_store				: std_logic_vector(31 downto 0);	

signal SRAM_data_store				: std_logic_vector(15 downto 0);
signal SRAM_address_store			: std_logic_vector(19 downto 0);
signal SRAM_ctrl_store	   		: std_logic_vector(31 downto 0);
signal SRAM_Write_Enable_N_store : std_logic;

begin
process(nRst, Clk)
	variable input_data_storage : std_logic_vector(31 downto 0);
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
	data				 			   <= (others => 'Z');
	address				 			<= (others => 'Z');
	
elsif rising_edge(Clk) then
	SRAM_Chip_Enable_N	<= '0';
	
	case aktuellerZustand is	
		when waitMemInstr =>		
			if busAck /= x"FFFFFFFF" and ctrl(31) = '0' and ctrl(0) = '1' and address(31) = '1' then		
				if (ctrl(8 downto 5) = "0000") then
					input_data_storage := data;
				else
					input_data_storage := ALUIn_1;
				end if;
	
				case ctrl(4 downto 1) is
					when "0001" =>
						SRAM_data					 <= "ZZZZZZZZ" & input_data_storage(7 downto 0);
						SRAM_data_store			 <= (others => 'Z');
						SRAM_Low_Byte_N			 <= '0';
						SRAM_High_Byte_N			 <= '1';						
						SRAM_Write_Enable_N 		 <= '0';	
						SRAM_Write_Enable_N_store<= '1';
					when "0010" =>
						SRAM_data				    <= input_data_storage(15 downto 8) & "ZZZZZZZZ";	
						SRAM_data_store			 <= (others => 'Z');
						SRAM_Low_Byte_N			 <= '1';
						SRAM_High_Byte_N			 <= '0';						
						SRAM_Write_Enable_N  	 <= '0';	
						SRAM_Write_Enable_N_store<= '1';
					when "0100" =>
						SRAM_data					 <= (others => 'Z');
						SRAM_data_store			 <= "ZZZZZZZZ"& input_data_storage(23 downto 16);
						SRAM_Low_Byte_N			 <= '0';
						SRAM_High_Byte_N		 	 <= '1';					
						SRAM_Write_Enable_N  	 <= '1';	
						SRAM_Write_Enable_N_store<= '0';
					when "1000" =>
						SRAM_data					 <= (others => 'Z');	
						SRAM_data_store			 <= input_data_storage(31 downto 24) & "ZZZZZZZZ";
						SRAM_Low_Byte_N			 <= '1';
						SRAM_High_Byte_N			 <= '0';					
						SRAM_Write_Enable_N  	 <= '1';	
						SRAM_Write_Enable_N_store<= '0';
					when "0011" =>
						SRAM_data					 <= input_data_storage(15 downto 0);
						SRAM_data_store			 <= (others => 'Z');		
						SRAM_Low_Byte_N			 <= '0';
						SRAM_High_Byte_N			 <= '0';					
						SRAM_Write_Enable_N  	 <= '0';	
						SRAM_Write_Enable_N_store<= '1';
					when "1100" =>
						SRAM_data					 <= (others => 'Z');	
						SRAM_data_store			 <= input_data_storage(31 downto 16);
						SRAM_Low_Byte_N			 <= '0';
						SRAM_High_Byte_N			 <= '0';					
						SRAM_Write_Enable_N  	 <= '1';	
						SRAM_Write_Enable_N_store<= '0';
					when "1111" =>
						SRAM_data					 <= input_data_storage(15 downto 0);
						SRAM_data_store			 <= input_data_storage(31 downto 16);
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
				
				if (ctrl(8 downto 5) = "0001") then
					SRAM_ALU_store       <= ALUIn_2;
				else
					SRAM_ALU_store       <= ALUIn_1;
				end if;
				
				SRAM_Read_Enable_N	<= 'X';	
				aktuellerZustand 		<= writeHighByte;
				ctrl				 		<= x"FFFFFFFF";
			elsif busAck /= x"FFFFFFFF" and ctrl(0) = '0' and ctrl /= x"00000000" and address(31) = '1' then
				SRAM_data				<= (others => 'Z');
				SRAM_Read_Enable_N	<= '0';
				SRAM_Write_Enable_N  <= '1';		
				aktuellerZustand 		<= readLowByte;
				SRAM_Low_Byte_N		<= '0';
				SRAM_High_Byte_N		<= '0';
			   ctrl				 		<= x"FFFFFFFF";
				
				if (ctrl(8 downto 5) /= "0000") then
					SRAM_ALU_store <= data;
				end if;				
			else
				SRAM_data				<= (others => 'Z');
				SRAM_Read_Enable_N	<= '1';
				SRAM_Write_Enable_N  <= '1';	
				SRAM_Low_Byte_N		<= '0';
				SRAM_High_Byte_N		<= '0';
				ctrl				 		<= (others => 'Z');
			end if;				
			
			SRAM_address				<= address(20 downto 2) & "0";
			SRAM_address_store		<= std_logic_vector(to_unsigned(to_integer(unsigned(address(20 downto 2) & "0")) + 1, 20));		
			SRAM_ctrl_store     		<= ctrl;
			data				 			<= (others => 'Z');
			address				 		<= (others => 'Z');
		when readLowByte 	=>
			SRAM_Read_Enable_N		<= '0';
			SRAM_Write_Enable_N 		<= '1';		
			SRAM_address				<= SRAM_address_store;
			aktuellerZustand  		<= readHighByte;
			SRAM_data_store			<= SRAM_data;
			data				 			<= (others => 'Z');
			ctrl				 			<= x"FFFFFFFF";
			address				 		<= (others => 'Z');
			--maybe?
			SRAM_data					<= (others => 'Z');
		when readHighByte =>			
			SRAM_Read_Enable_N		<= '1';
			SRAM_Write_Enable_N  	<= '1';	
			SRAM_address				<= SRAM_address_store;			
			aktuellerZustand  		<= waitMemInstr;	
			
			if (SRAM_ctrl_store(8 downto 5) = "0000") then								
				ctrl <= x"00000000";
				data <= SRAM_data & SRAM_data_store;
			else
				ctrl     <= SRAM_ctrl_store(31 downto 1) & "1";
				data     <= (others => 'Z');
				ALUOut_1 <= SRAM_ALU_store;
				ALUOut_2 <= SRAM_data & SRAM_data_store;
				ALUFunc  <= SRAM_ctrl_store(8 downto 5);
			end if;
			
			SRAM_data					<= (others => 'Z');
			address				 		<= (others => 'Z');
		when writeHighByte =>
			SRAM_data					<= SRAM_data_store;
			SRAM_Read_Enable_N		<= 'X';
			SRAM_Write_Enable_N 	 	<= SRAM_Write_Enable_N_store;
			SRAM_address				<= SRAM_address_store;
			aktuellerZustand 			<= waitMemInstr;	
			ctrl							<= x"00000000";			
			address				 		<= (others => 'Z');

			if (SRAM_ctrl_store(8 downto 5) = "0000") then	
				data				 			<= (others => 'Z');
			else
				data				 			<= SRAM_ALU_store;
			end if;			
	end case;
end if;

end process;


end Behavioral;
