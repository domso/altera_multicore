library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;


entity decode is
	Port (
		Insn			: in std_logic_vector(31 downto 0);
		Funct			: out std_logic_vector(2 downto 0);
		SrcRegNo1	: out std_logic_vector(4 downto 0);
		SrcRegNo2	: out std_logic_vector(4 downto 0);
		DestRegNo	: out std_logic_vector(4 downto 0);
		DestWrEn		: out std_logic;

		Imm			: out std_logic_vector(31 downto 0);
		SelSrc2		: out std_logic;
		Aux			: out std_logic;
		PCNextI		: in std_logic_vector(31 downto 0);
		PCNextO		: out std_logic_vector(31 downto 0);
		Jump			: out std_logic;
		JumpRel		: out std_logic;
		JumpTarget	: out std_logic_vector(31 downto 0);
		MemAccess	: out std_logic;
		MemWrEn		: out std_logic;
		Clear			: in std_logic;
		InterlockI	: in std_logic;
		InterlockO	: out std_logic;
		Stall			: in std_logic
	);
end decode;

architecture Behavioral of decode is

begin
process(Insn, PCNextI, Clear, InterlockI, Stall)
begin
	if (Clear = '1' or InterlockI = '1') then
		DestWrEn	 	 <= '0'; 
		Funct		 	 <= "000";
		SrcRegNo1 	 <= "00000";
		SrcRegNo2 	 <= "00000";
		DestRegNo 	 <= "00000";
		DestWrEn	 	 <= '0';
		SelSrc2	 	 <= '0';	
		Aux		 	 <= '0';
		Imm		 	 <= x"00000000";
		
		Jump		 	 <= '0';
		JumpRel	 	 <= '0';
		JumpTarget	 <= x"00000000";
		PCNextO		 <= PCNextI;	
			
		InterlockO	 <= '0';
		MemAccess	 <= '0';
		MemWrEn		 <= '0';
	else	
		case Insn(6 downto 0) is
		when opcode_OP => 
			Funct			 <= Insn(14 downto 12);
			SrcRegNo1 	 <= Insn(19 downto 15);
			SrcRegNo2 	 <= Insn(24 downto 20);
			DestRegNo 	 <= Insn(11 downto 7);
			DestWrEn	 	 <= '1';
			SelSrc2	 	 <= '1';
			
			Aux		 	 <= Insn(30);
			Imm		 	 <= x"00000000";
			
			Jump		 	 <= '0';
			JumpRel	 	 <= '0';
			JumpTarget	 <= x"00000000";
			PCNextO		 <= PCNextI;	
			
			InterlockO	 <= '0';
			MemAccess	 <= '0';
			MemWrEn		 <= '0';
		when opcode_OP_IMM => 
			Funct		 	 <= Insn(14 downto 12);
			SrcRegNo1 	 <= Insn(19 downto 15);
			SrcRegNo2 	 <= "00000";
			DestRegNo 	 <= Insn(11 downto 7);
			DestWrEn	 	 <= '1';
			SelSrc2	 	 <= '0';
			
			if (Insn(14 downto 12) = "101") then	
				Aux		 <= Insn(30);
			else
				Aux		 <= '0';
			end if;
			
			if (Insn(31 downto 31) = "0") then
				Imm		 <= x"00000000" or Insn(31 downto 20);
			else
				Imm		 <= x"FFFFF000" or Insn(31 downto 20);
			end if;
			
			Jump		 	 <= '0';
			JumpRel	 	 <= '0';
			JumpTarget	 <= x"00000000";
			PCNextO		 <= PCNextI;	
			
			InterlockO	 <= '0';
			MemAccess	 <= '0';
			MemWrEn		 <= '0';
		when opcode_LUI =>
			Funct		 	 <= "000";
			SrcRegNo1 	 <= "00000";
			SrcRegNo2 	 <= "00000";
			DestRegNo 	 <= Insn(11 downto 7);
			DestWrEn	 	 <= '1';
			SelSrc2	 	 <= '0';
			Aux		 	 <= '0';
			
			Imm		 	 <= Insn(31 downto 12) & x"000";
			
			Jump		 	 <= '0';
			JumpRel	 	 <= '0';
			JumpTarget	 <= x"00000000";
			PCNextO		 <= PCNextI;	
			
			InterlockO	 <= '0';
			MemAccess	 <= '0';
			MemWrEn		 <= '0';
		when opcode_JAL =>
			Funct		 	 <= "000";
			SrcRegNo1 	 <= "00000";
			SrcRegNo2 	 <= "00000";
			DestRegNo 	 <= Insn(11 downto 7);
			DestWrEn	 	 <= '1';
			SelSrc2	 	 <= '0';
			Aux		 	 <= '0';
			
			if (Insn(31 downto 31) = "0") then
				Imm		 <= x"00000000" or Insn(31 downto 20);
			else
				Imm		 <= x"FFFFF000" or Insn(31 downto 20);
			end if;
			
			Jump		 	 <= '1';
			JumpRel	 	 <= '0';
			JumpTarget	 <= std_logic_vector(signed(PCNextI) + to_signed(-4, 32) + signed(Insn(31) & Insn(19 downto 12) & Insn(20) & Insn(30 downto 21) &"0"));
			PCNextO 		 <= PCNextI;	
			
			InterlockO	 <= '0';
			MemAccess	 <= '0';
			MemWrEn		 <= '0';
			
		when opcode_JALR =>
			Funct		 	 <= "000";
			SrcRegNo1 	 <= Insn(19 downto 15);
			SrcRegNo2 	 <= "00000";
			DestRegNo 	 <= Insn(11 downto 7);
			DestWrEn	 	 <= '1';
			SelSrc2	 	 <= '0';	
			Aux		 	 <= '0';
			
			if (Insn(31 downto 31) = "0") then
				Imm		 <= x"00000000" or Insn(31 downto 20);
			else
				Imm		 <= x"FFFFF000" or Insn(31 downto 20);
			end if;

			Jump		 	 <= '1';
			JumpRel	 	 <= '1';
			JumpTarget	 <= std_logic_vector(signed(PCNextI) + to_signed(-4, 32) + signed(Insn(31) & Insn(19 downto 12) & Insn(20) & Insn(30 downto 21) &"0"));
			PCNextO		 <= PCNextI;	
			
			InterlockO	 <= '0';
			MemAccess	 <= '0';
			MemWrEn		 <= '0';
				
		when opcode_BRANCH =>
			Funct		 	 <= Insn(14 downto 12);
			SrcRegNo1 	 <= Insn(19 downto 15);
			SrcRegNo2 	 <= Insn(24 downto 20);
			
			DestRegNo 	 <= "00000";
			DestWrEn	 	 <= '0';
			SelSrc2	 	 <= '1';	
			Aux		 	 <= '0';
			Imm		 	 <= x"00000000";
			
			Jump		 	 <= '0';
			JumpRel	 	 <= '1';
			JumpTarget 	 <= std_logic_vector(signed(PCNextI) + to_signed(-4, 32) + signed(Insn(31) & Insn(7) & Insn(30 downto 25) & Insn(11 downto 8) &"0"));
			PCNextO 		 <= PCNextI;	
			
			InterlockO	 <= '0';
			MemAccess	 <= '0';
			MemWrEn		 <= '0';
				
		when opcode_AUIPC =>
			Funct		 	 <= "000";
			SrcRegNo1 	 <= "00000";
			SrcRegNo2 	 <= "00000";
			DestRegNo 	 <= Insn(11 downto 7);
			DestWrEn	 	 <= '1';
			SelSrc2	 	 <= '0';
			Aux		 	 <= '0';			
			Imm		 	 <= std_logic_vector(signed(PCNextI) + to_signed(-4, 32) + signed(Insn(31 downto 12) & x"000"));
			
			Jump		 	 <= '0';
			JumpRel	 	 <= '0';
			JumpTarget	 <= x"00000000"; 
			PCNextO 		 <= PCNextI;
			
			InterlockO	 <= '0';
			MemAccess	 <= '0';
			MemWrEn		 <= '0';
			
		when opcode_load =>
			Funct		 	 <= Insn(14 downto 12);
			SrcRegNo1 	 <= Insn(19 downto 15);
			SrcRegNo2 	 <= "00000";
			DestRegNo 	 <= Insn(11 downto 7);
			DestWrEn	 	 <= '1';
			SelSrc2	 	 <= '0';
			
			Aux			 <= '0';
			
			if (Insn(31 downto 31) = "0") then
				Imm		 <= x"00000000" or Insn(31 downto 20);
			else
				Imm		 <= x"FFFFF000" or Insn(31 downto 20);
			end if;
			
			Jump		 	 <= '0';
			JumpRel	 	 <= '0';
			JumpTarget	 <= x"00000000";
			PCNextO 		 <= PCNextI;		
			
			InterlockO	 <= '1';
			MemAccess	 <= '1';
			MemWrEn		 <= '0';
		when opcode_store =>
			Funct		 	 <= Insn(14 downto 12);
			SrcRegNo1 	 <= Insn(19 downto 15);
			SrcRegNo2 	 <= Insn(24 downto 20);
			DestRegNo 	 <= "00000";
			DestWrEn	 	 <= '0';
			SelSrc2	 	 <= '0';
			
			Aux			 <= '0';
			
			if (Insn(31 downto 31) = "0") then
				Imm		 <= x"00000" & Insn(31 downto 25) & Insn(11 downto 7);
			else
				Imm		 <= x"FFFFF" & Insn(31 downto 25) & Insn(11 downto 7);
			end if;
			
			Jump		 	 <= '0';
			JumpRel	 	 <= '0';
			JumpTarget	 <= x"00000000";
			PCNextO 		 <= PCNextI;		
			
			InterlockO	 <= '0';
			MemAccess	 <= '1';
			MemWrEn		 <= '1';
		when others =>
			DestWrEn	 	 <= '0'; 
			Funct		 	 <= "000";
			SrcRegNo1 	 <= "00000";
			SrcRegNo2 	 <= "00000";
			DestRegNo 	 <= "00000";
			DestWrEn	 	 <= '0';
			SelSrc2	 	 <= '0';	
			Aux		 	 <= '0';
			Imm		 	 <= x"00000000";
			
			Jump		 	 <= '0';
			JumpRel	 	 <= '0';
			JumpTarget	 <= x"00000000";
			PCNextO 		 <= PCNextI;	
			
			InterlockO	 <= '0';
			MemAccess	 <= '0';
			MemWrEn		 <= '0';
		end case;
	end if;
end process;

end Behavioral;
