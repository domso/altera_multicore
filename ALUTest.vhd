library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity ALUTest is
	Port (
		A 				: in std_logic_vector(31 downto 0);
		B 				: in std_logic_vector(31 downto 0);
		Funct 		: in std_logic_vector(2 downto 0);
		Aux 			: in std_logic;
		PCNext 		: in std_logic_vector(31 downto 0);
		JumpI 		: in std_logic_vector(0 downto 0);
		JumpRel 		: in std_logic_vector(0 downto 0);
		JumpTargetI : in std_logic_vector(31 downto 0);
		MemAccessI 	: in std_logic_vector(0 downto 0);
		SrcData2 	: in std_logic_vector(31 downto 0);
		DestRegNoI 	: in std_logic_vector(4 downto 0);
		DestWrEnI 	: in std_logic_vector(0 downto 0);
		Clear 		: in std_logic_vector(0 downto 0);
		Stall 		: in std_logic_vector(0 downto 0);

		X 				: out std_logic_vector(31 downto 0);
		JumpO 		: out std_logic_vector(0 downto 0);
		JumpTargetO : out std_logic_vector(31 downto 0);
		DestRegNoO 	: out std_logic_vector(4 downto 0);
		DestWrEnO 	: out std_logic_vector(0 downto 0);
		MemAccessO 	: out std_logic_vector(0 downto 0);
		MemWrData	: out std_logic_vector(31 downto 0);
		MemByteEna 	: out std_logic_vector(3 downto 0)
	);
end ALUTest;

architecture Behavioral of ALUTest is
begin

process(Funct, A, B)
begin

case Funct is
	when "000" =>
		if (Aux = '0') then
			X <= std_logic_vector(to_signed(to_integer(signed(A)) + to_integer(signed(B)), 32)); --funct_ADD
		else
			X <= std_logic_vector(to_signed(to_integer(signed(A)) - to_integer(signed(B)), 32)); --funct_SUB
		end if;	
	
	when "001" => X <= std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B(4 downto 0))))); --funct_SLL
	when "010" => 																													--funct_SLT
		if (signed(A) < signed(B)) then 
			X <= x"00000001";
		else
			X <= x"00000000";
		end if; 																		
	when "011" =>                                                                                      --funct_SLTU
		if (unsigned(A) < unsigned(B)) then 
			X <= x"00000001";
		else
			X <= x"00000000";
		end if; 	 												
	when "100" => X <= A xor B; 																								--funct_XOR
	when "101" => 	
		if (Aux = '0') then	
			X <= std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B(4 downto 0))))); --funct_SRL
		else
			X <= std_logic_vector(shift_right(signed(A), to_integer(unsigned(B(4 downto 0))))); --funct_SRA
		end if;
	when "110" => X <= A or B; 																								--funct_OR
	when "111" => X <= A and B;																								--funct_AND

	when others => X <= x"00000000";

end case;

end process;


process(DestRegNoI)
begin

DestRegNoO <= DestRegNoI;

end process;

process(DestWrEnI)
begin

DestWrEnO <= DestWrEnI;

end process;



end Behavioral;
