library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity ALUTest is
	Port (
		B 				: in std_logic_vector(31 downto 0);
		A 				: in std_logic_vector(31 downto 0);
		Funct 		: in std_logic_vector(2 downto 0);
		Aux 			: in std_logic;
	
		DestWrEnI 	: in std_logic;
		DestRegNoI 	: in std_logic_vector(4 downto 0);
		
		
		PCNext 		: in std_logic_vector(31 downto 0);
		JumpI 		: in std_logic;
		JumpRel 		: in std_logic;
		JumpTargetI : in std_logic_vector(31 downto 0);
		MemAccessI 	: in std_logic;
		SrcData2 	: in std_logic_vector(31 downto 0);
		Clear 		: in std_logic;
		Stall 		: in std_logic;

		JumpTargetO : out std_logic_vector(31 downto 0);
		X 				: out std_logic_vector(31 downto 0);
		DestRegNoO 	: out std_logic_vector(4 downto 0);
		DestWrEnO 	: out std_logic;
		MemAccessO 	: out std_logic;
		MemWrData	: out std_logic_vector(31 downto 0);
		MemByteEna 	: out std_logic_vector(3 downto 0);
		JumpO 		: out std_logic
	);
end ALUTest;

architecture Behavioral of ALUTest is
begin
process(Funct, A, B, JumpI, Clear, SrcData2)
variable Result : std_logic_vector(31 downto 0) := x"00000000";
variable Cond   : boolean := true;
begin
	
	if (clear = '1') then	
		X 				<= x"00000000";			
		JumpTargetO <= x"00000000";
		JumpO 		<= '0';
		MemByteEna	<= "0000";
		MemWrData   <= x"00000000";
		Result		:= x"00000000";
		Cond			:= true;
	else
		if (JumpI = '0' and JumpRel = '1') then
			case Funct is
			  when funct_BEQ      =>	Cond := signed(A) = signed(B);
			  when funct_BNE      =>	Cond := signed(A) /= signed(B);
			  when funct_BLT      =>	Cond := signed(A) < signed(B);
			  when funct_BGE      =>	Cond := signed(A) >= signed(B);
			  when funct_BLTU     =>	Cond := unsigned(A) < unsigned(B);
			  when funct_BGEU     =>	Cond := unsigned(A) >= unsigned(B);
			  when others			 =>   Cond := false;
			end case;
			
			MemByteEna	 <= "0000";
			MemWrData 	 <= x"00000000";
			Result		 := x"00000000";	
		elsif (MemAccessI = '1') then
			Result := std_logic_vector(to_signed(to_integer(signed(A)) + to_integer(signed(B)), 32)); --funct_ADD
			case Funct(1 downto 0) is			
				when "00" => 
					MemByteEna  <= std_logic_vector(shift_left("0001", to_integer(unsigned(Result(1 downto 0)))));
					MemWrData 	<= SrcData2(7 downto 0) & SrcData2(7 downto 0) & SrcData2(7 downto 0) & SrcData2(7 downto 0);
				when "01" =>
					MemByteEna  <= std_logic_vector(shift_left("0011", to_integer(unsigned(Result(1 downto 0)))));
					MemWrData 	<= SrcData2(15 downto 0) & SrcData2(15 downto 0);
				when "10" =>	
					MemByteEna	<= "1111";		
					MemWrData 	<= SrcData2;
				when others =>
					MemByteEna  <= "0000";
					MemWrData	<= SrcData2;
			end case;			
			Cond			:= true;	
		else
			case Funct is
				when funct_ADD =>
					if (Aux = '0') then
						Result := std_logic_vector(to_signed(to_integer(signed(A)) + to_integer(signed(B)), 32)); --funct_ADD
					else
						Result := std_logic_vector(to_signed(to_integer(signed(A)) - to_integer(signed(B)), 32)); --funct_SUB
					end if;					
				when funct_SLL => Result := std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B(4 downto 0))))); --funct_SLL
				when funct_SLT => 																													--funct_SLT
					if (signed(A) < signed(B)) then 
						Result := x"00000001";
					else
						Result := x"00000000";
					end if; 																		
				when funct_SLTU =>                                                                                      --funct_SLTU
					if (unsigned(A) < unsigned(B)) then 
						Result := x"00000001";
					else
						Result := x"00000000";
					end if; 	 												
				when funct_XOR => Result := A xor B; 																								--funct_XOR
				when funct_SRL => 	
					if (Aux = '0') then	
						Result := std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B(4 downto 0))))); --funct_SRL
					else
						Result := std_logic_vector(shift_right(signed(A), to_integer(unsigned(B(4 downto 0))))); --funct_SRA
					end if;
				when funct_OR => Result := A or B; 																								--funct_OR
				when funct_AND => Result := A and B;																								--funct_AND

				when others => Result := x"00000000";
			end case;			
			
			MemByteEna	<= "0000";
			MemWrData <= SrcData2;
			Cond			:= true;
		end if;
		
		if (JumpI = '0') then		
			if (JumpRel = '1') then
				X 				<= x"00000000";			
				JumpTargetO <= JumpTargetI;
				if (Cond) then
					JumpO		<= '1';
				else
					JumpO		<= '0';
				end if;
			else
				X 				<= Result;
				JumpTargetO <= JumpTargetI;
				JumpO 		<= JumpI;
			end if;	
		else		
			if (JumpRel = '1') then
				X 				<= PCNext;			
				JumpTargetO <= Result;
				JumpO 		<= JumpI;
			else
				X 				<= PCNext;
				JumpTargetO <= JumpTargetI;
				JumpO 		<= JumpI;
			end if;	
		end if;
	end if;
end process;

process(MemAccessI, Clear)
begin
	if (Clear = '1') then
		MemAccessO <= '0';
	else
		MemAccessO <= MemAccessI;
	end if;
end process;

process(DestRegNoI, Clear)
begin
	if (Clear = '1') then
		DestRegNoO <= "00000";
	else
		DestRegNoO <= DestRegNoI;
	end if;
end process;

process(DestWrEnI, Clear)
begin
	if (Clear = '1') then
		DestWrEnO <= '0';
	else
		DestWrEnO <= DestWrEnI;
	end if;
end process;

end Behavioral;
