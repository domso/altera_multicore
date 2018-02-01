library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity write_buffer is
	Port (		
		nRst   		: in std_logic;
		Clk   		: in std_logic;			
		StallI		: in	std_logic;
		FenceI		: in	std_logic;		
		FuncI     	: in std_logic_vector(3 downto 0);	
		dataI       : in std_logic_vector(31 downto 0);
		addressI    : in std_logic_vector(31 downto 0);
		wrenI       : in std_logic;
		linkI       : in std_logic;
		byteEnaI 	: in std_logic_vector(3 downto 0);
		resultDataI : in std_logic_vector(31 downto 0);
	
		StallO		: out	std_logic;	
		FuncO     	: out std_logic_vector(3 downto 0);	
		dataO       : out std_logic_vector(31 downto 0);
		addressO    : out std_logic_vector(31 downto 0);
		wrenO       : out std_logic;
		linkO       : out std_logic;
		byteEnaO 	: out std_logic_vector(3 downto 0);
		resultDataO : out std_logic_vector(31 downto 0)
	);
end write_buffer;

architecture Behavioral of write_buffer is
	type state_in_type is (STATE_IN_READY, STATE_IN_FULL, STATE_IN_FLUSH, STATE_IN_WAIT);
	signal inputState: state_in_type;
	
	type state_out_type is (STATE_OUT_READY, STATE_OUT_WRITE_WAIT, STATE_OUT_WRITE_CLOSE, STATE_OUT_READ_WAIT, STATE_OUT_READ_CLOSE);
	signal outputState : state_out_type;
	
	type vector74 is array (natural range <>) of std_logic_vector(73 downto 0);
	
	constant num_slots : integer := 4;	
	
	signal store_read_Func    : std_logic_vector(3 downto 0);	
	signal store_read_data    : std_logic_vector(31 downto 0);
	signal store_read_address : std_logic_vector(31 downto 0);
	signal store_read_wren    : std_logic;
	signal store_read_link    : std_logic;
	signal store_read_byteEna : std_logic_vector(3 downto 0);		
	signal store_result       : std_logic_vector(31 downto 0);
begin

process(nRst, Clk)
	variable found_byte_ena : std_logic_vector(3 downto 0) := "0000";
	variable found_data     : std_logic_vector(31 downto 0) := x"00000000";
	variable slots          : vector74((num_slots - 1) downto 0);	
	variable current_slot   : integer := 0;
	
	variable read_Func    : std_logic_vector(3 downto 0);	
	variable read_data  	 : std_logic_vector(31 downto 0);
	variable read_address : std_logic_vector(31 downto 0);
	variable read_wren    : std_logic;
	variable read_link    : std_logic;
	variable read_byteEna : std_logic_vector(3 downto 0);
begin

if (nRst = '0') then
	for i in 0 to num_slots - 1
	loop
		slots(i) := (others => '0');
	end loop;
	
	current_slot := 0;
	inputState  <= STATE_IN_READY;
	outputState <= STATE_OUT_READY;
	
	StallO   <= '0';
	FuncO    <= (others => '0');
	dataO    <= (others => '0');
	addressO <= (others => '0');
	wrenO    <= '0';
	linkO    <= '0';
	byteEnaO <= (others => '0');
	
	resultDataO <= (others => '0');
	
	read_Func    := (others => '0');
	read_data    := (others => '0');
	read_address := (others => '0');
	read_wren    := '0';
	read_link    := '0';
	read_byteEna := (others => '0');	
	
	store_read_Func    <= (others => '0');
	store_read_data    <= (others => '0');
	store_read_address <= (others => '0');
	store_read_wren    <= '0';
	store_read_link    <= '0';
	store_read_byteEna <= (others => '0');
	
	store_result <= (others => '0');
elsif rising_edge(Clk) then
	case inputState is
		when STATE_IN_READY =>
			if (wrenI = '1' and addressI(31 downto 30) /= "00") then									-- write
				slots(current_slot) := byteEnaI & linkI & wrenI & addressI & dataI & FuncI;				
				current_slot := current_slot + 1;
				
				if (current_slot = num_slots and FenceI = '0') then
					inputState <= STATE_IN_FULL;
					StallO <= '1';
				elsif (FenceI = '1') then
					inputState <= STATE_IN_FLUSH;
					StallO <= '1';			

					store_read_Func    <= (others => '0');
					store_read_data    <= (others => '0');
					store_read_address <= (others => '0');
					store_read_wren    <= '0';
					store_read_link    <= '0';
					store_read_byteEna <= (others => '0');					
				else
					StallO <= '0';
					resultDataO <= store_result;
				end if;	
			elsif (wrenI = '0' and byteEnaI /= "0000" and addressI(31 downto 30) /= "00") then                                          -- read(-modify-write)
				found_byte_ena  := "0000";
				found_data := x"00000000";
				
				for i in 0 to num_slots - 1 loop
					exit when i = current_slot;
					if (slots(i)(67 downto 38) = addressI(31 downto 2)) then
						found_byte_ena := found_byte_ena or slots(i)(73 downto 70);
						
						case slots(i)(73 downto 70) is
							when "0001" => found_data := found_data(31 downto 8)  & slots(i)(11 downto 4);
							when "0010" => found_data := found_data(31 downto 16) & slots(i)(19 downto 12) & found_data(7 downto 0);
							when "0100" => found_data := found_data(31 downto 24) & slots(i)(27 downto 20) & found_data(15 downto 0);
							when "1000" => found_data := slots(i)(35 downto 28) & found_data(23 downto 0);
							when "0011" => found_data := found_data(31 downto 16) & slots(i)(19 downto 4);
							when "1100" => found_data := slots(i)(35 downto 20) & found_data(15 downto 0);
							when "1111" => found_data := slots(i)(35 downto 4); 
							when others =>
						end case;						
					end if;
				end loop;
							
				if (found_byte_ena = "0000" and FenceI = '0') then							                   -- no colliding write in buffer
					StallO <= '1';
					inputState <= STATE_IN_WAIT;
					
					read_Func    := FuncI;
					read_data    := dataI;
					read_address := addressI;
					read_wren    := wrenI;
					read_link    := linkI;
					read_byteEna := byteEnaI;
				elsif ((found_byte_ena and byteEnaI) = byteEnaI and FuncI = "0000" and FenceI = '0') then   -- collision, but enough data in buffer
					StallO <= '0';
					resultDataO <= found_data;
				else																	                   -- collision, and not enough data in buffer
					StallO <= '1';
					inputState <= STATE_IN_FLUSH;
														
					store_read_Func    <= FuncI;
					store_read_data    <= dataI;
					store_read_address <= addressI;
					store_read_wren    <= wrenI;
					store_read_link    <= linkI;
					store_read_byteEna <= byteEnaI;
				end if;	
			else
				if (FenceI = '1') then
					StallO <= '1';
					inputState <= STATE_IN_FLUSH;
					store_read_Func    <= (others => '0');
					store_read_data    <= (others => '0');
					store_read_address <= (others => '0');
					store_read_wren    <= '0';
					store_read_link    <= '0';
					store_read_byteEna <= (others => '0');	
				else
					resultDataO <= store_result;
					StallO <= '0';
				end if;
			end if;
		when STATE_IN_FULL =>	
			if (current_slot = num_slots) then
				StallO <= '1';
			else
				resultDataO <= store_result;
				StallO <= '0';
				inputState <= STATE_IN_READY;
			end if;
		when STATE_IN_FLUSH =>			
			if (current_slot = 0 and read_byteEna = "0000") then
			
				if (store_read_byteEna = "0000") then			
					inputState <= STATE_IN_READY;
					resultDataO <= store_result;
					StallO <= '0';					
				else
					read_Func    := store_read_Func;  
					read_data    := store_read_data;
					read_address := store_read_address;
					read_wren    := store_read_wren; 
					read_link    := store_read_link;
					read_byteEna := store_read_byteEna;					
				
					inputState <= STATE_IN_WAIT;
					StallO <= '1';
				end if;
			else
				StallO <= '1';
			end if;
		when STATE_IN_WAIT =>
			if (read_byteEna = "0000") then
				inputState <= STATE_IN_READY;
				resultDataO <= store_result;
				StallO <= '0';
			else
				StallO <= '1';
			end if;
	end case;	
	
	
	case outputState is
		when STATE_OUT_READY =>		
			if (read_byteEna = "0000") then		
				FuncO    <= slots(0)(3 downto 0);
				dataO    <= slots(0)(35 downto 4);
				addressO <= slots(0)(67 downto 36);
				wrenO    <= slots(0)(68);
				linkO    <= slots(0)(69);
				byteEnaO <= slots(0)(73 downto 70);

				if (StallI = '0' and slots(0)(73 downto 70) /= "0000") then
					outputState <= STATE_OUT_WRITE_WAIT;
				end if;
			else
				FuncO    <= read_Func;
				dataO    <= read_data;
				addressO <= read_address;
				wrenO    <= read_wren;
				linkO    <= read_link;
				byteEnaO <= read_byteEna;

				if (StallI = '0') then
					outputState <= STATE_OUT_READ_WAIT;
				end if;
			end if;
		when STATE_OUT_WRITE_WAIT =>
			FuncO    <= slots(0)(3 downto 0);
			dataO    <= slots(0)(35 downto 4);
			addressO <= slots(0)(67 downto 36);
			wrenO    <= slots(0)(68);
			linkO    <= slots(0)(69);
			byteEnaO <= slots(0)(73 downto 70);
			
			if (StallI = '1') then
				outputState <= STATE_OUT_WRITE_CLOSE;
			end if;
		when STATE_OUT_WRITE_CLOSE =>
			FuncO    <= (others => '0');
			dataO    <= (others => '0');
			addressO <= (others => '0');
			wrenO    <= '0';
			linkO    <= '0';
			byteEnaO <= (others => '0');
			
			if (StallI = '0') then
				outputState <= STATE_OUT_READY;
				store_result <= resultDataI;
				
				if (current_slot /= 0) then
					for i in 0 to num_slots - 2
					loop
						slots(i) := slots(i + 1);
					end loop;
					slots(num_slots - 1) := (others => '0');
					current_slot := current_slot - 1;				
				end if;	
			end if;	
		when STATE_OUT_READ_WAIT =>
			FuncO    <= read_Func;
			dataO    <= read_data;
			addressO <= read_address;
			wrenO    <= read_wren;
			linkO    <= read_link;
			byteEnaO <= read_byteEna;

			if (StallI = '1') then
				outputState <= STATE_OUT_READ_CLOSE;
			end if;
		when STATE_OUT_READ_CLOSE =>
			FuncO    <= (others => '0');
			dataO    <= (others => '0');
			addressO <= (others => '0');
			wrenO    <= '0';
			linkO    <= '0';
			byteEnaO <= (others => '0');
			
			if (StallI = '0') then
				outputState <= STATE_OUT_READY;
				store_result <= resultDataI;
			
				read_Func    := (others => '0');
				read_data    := (others => '0');
				read_address := (others => '0');
				read_wren    := '0';
				read_link    := '0';
				read_byteEna := (others => '0');	
			end if;
	end case;
	
end if;

end process;

end Behavioral;
