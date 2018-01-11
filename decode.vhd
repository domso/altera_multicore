library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;


entity decode is
	Port (
		Insn		  : in std_logic_vector(31 downto 0);
		PCNextI	  : in std_logic_vector(31 downto 0);
		Clear		  : in std_logic;
		InterlockI : in std_logic;
		Stall		  : in std_logic;	
		
		Funct		  : out std_logic_vector(2 downto 0);
		SrcRegNo1  : out std_logic_vector(5 downto 0);
		SrcRegNo2  : out std_logic_vector(5 downto 0);
		DestRegNo  : out std_logic_vector(5 downto 0);
		DestWrEn	  : out std_logic;
		Imm		  : out std_logic_vector(31 downto 0);
		SelSrc2	  : out std_logic;
		Aux		  : out std_logic;
		PCNextO	  : out std_logic_vector(31 downto 0);
		Jump		  : out std_logic;
		JumpRel	  : out std_logic;
		JumpTarget : out std_logic_vector(31 downto 0);
		MemAccess  : out std_logic;
		MemWrEn	  : out std_logic;
		MemFunc	  : out std_logic_vector(3 downto 0);
		MemLink    : out std_logic;
		InterlockO : out std_logic
	);
end decode;

architecture Behavioral of decode is

begin
process(Insn, PCNextI, Clear, InterlockI, Stall)
begin
	if (Clear = '1' or InterlockI = '1') then
		DestWrEn	 	 <= '0'; 
		Funct		 	 <= "000";
		SrcRegNo1 	 <= "000000";
		SrcRegNo2 	 <= "000000";
		DestRegNo 	 <= "000000";
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
		MemFunc 		 <= "0000";
		MemLink		 <= '0';
	else	
		case Insn(6 downto 0) is
		when opcode_OP => 
			Funct			 <= Insn(14 downto 12);
			SrcRegNo1 	 <= "0" & Insn(19 downto 15);
			SrcRegNo2 	 <= "0" & Insn(24 downto 20);
			DestRegNo 	 <= "0" & Insn(11 downto 7);
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
			MemFunc 		 <= "0000";
			MemLink		 <= '0';
		when opcode_OP_IMM => 
			Funct		 	 <= Insn(14 downto 12);
			SrcRegNo1 	 <= "0" & Insn(19 downto 15);
			SrcRegNo2 	 <= "0" & "00000";
			DestRegNo 	 <= "0" & Insn(11 downto 7);
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
			MemFunc 		 <= "0000";
			MemLink		 <= '0';
		when opcode_LUI =>
			Funct		 	 <= "000";
			SrcRegNo1 	 <= "0" & "00000";
			SrcRegNo2 	 <= "0" & "00000";
			DestRegNo 	 <= "0" & Insn(11 downto 7);
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
			MemFunc 		 <= "0000";
			MemLink		 <= '0';
		when opcode_JAL =>
			Funct		 	 <= "000";
			SrcRegNo1 	 <= "0" & "00000";
			SrcRegNo2 	 <= "0" & "00000";
			DestRegNo 	 <= "0" & Insn(11 downto 7);
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
			MemFunc 		 <= "0000";
			MemLink		 <= '0';
		when opcode_JALR =>
			Funct		 	 <= "000";
			SrcRegNo1 	 <= "0" & Insn(19 downto 15);
			SrcRegNo2 	 <= "0" & "00000";
			DestRegNo 	 <= "0" & Insn(11 downto 7);
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
			MemFunc 		 <= "0000";		
			MemLink		 <= '0';
		when opcode_BRANCH =>
			Funct		 	 <= Insn(14 downto 12);
			SrcRegNo1 	 <= "0" & Insn(19 downto 15);
			SrcRegNo2 	 <= "0" & Insn(24 downto 20);
			
			DestRegNo 	 <= "0" & "00000";
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
			MemFunc 		 <= "0000";	
			MemLink		 <= '0';	
		when opcode_AUIPC =>
			Funct		 	 <= "000";
			SrcRegNo1 	 <= "0" & "00000";
			SrcRegNo2 	 <= "0" & "00000";
			DestRegNo 	 <= "0" & Insn(11 downto 7);
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
			MemFunc 		 <= "0000";
			MemLink		 <= '0';
		when opcode_load =>
			Funct		 	 <= Insn(14 downto 12);
			SrcRegNo1 	 <= "0" & Insn(19 downto 15);
			SrcRegNo2 	 <= "0" & "00000";
			DestRegNo 	 <= "0" & Insn(11 downto 7);
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
			MemFunc 		 <= "0000";
			MemLink		 <= '0';
		when opcode_store =>
			Funct		 	 <= Insn(14 downto 12);
			SrcRegNo1 	 <= "0" & Insn(19 downto 15);
			SrcRegNo2 	 <= "0" & Insn(24 downto 20);
			DestRegNo 	 <= "0" & "00000";
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
			MemFunc 		 <= "0000";
			MemLink		 <= '0';
		when opcode_ATOMIC =>
			Funct		 	 <= "010"; --only word!
			SrcRegNo1 	 <= "0" & Insn(19 downto 15);
			SrcRegNo2 	 <= "0" & Insn(24 downto 20);
			DestRegNo 	 <= "0" & Insn(11 downto 7);
			DestWrEn	 	 <= '1';
			SelSrc2	 	 <= '0';
			
			Aux			 <= '0';
			
			Imm		    <= x"00000000";
			
			Jump		 	 <= '0';
			JumpRel	 	 <= '0';
			JumpTarget	 <= x"00000000";
			PCNextO 		 <= PCNextI;		
			
			InterlockO	 <= '1';
			MemAccess	 <= '1';
			
			case Insn(31 downto 27) is
				when "00010"  => --LR
					MemFunc <= "0000";
					MemWrEn		 <= '0';
					MemLink		 <= '1';				
				when "00011"  => --SC
					MemFunc <= "0000";
					MemWrEn		 <= '1';	
					MemLink		 <= '1';		
				when "00001"  => --AMOSWAP
					MemFunc <= "0001";
					MemWrEn		 <= '0';
					MemLink		 <= '0';
				when "00000"  => --AMOADD
					MemFunc <= "0010";
					MemWrEn		 <= '0';
					MemLink		 <= '0';
				when "00100"  => --AMOXOR
					MemFunc <= "0011";
					MemWrEn		 <= '0';
					MemLink		 <= '0';
				when "01100"  => --AMOAND
					MemFunc <= "0100";
					MemWrEn		 <= '0';
					MemLink		 <= '0';
				when "01000"  => --AMOOR
					MemFunc <= "0101";
					MemWrEn		 <= '0';
					MemLink		 <= '0';
				when "10000"  => --AMOMIN
					MemFunc <= "0110";
					MemWrEn		 <= '0';
					MemLink		 <= '0';
				when "10100"  => --AMOMAX
					MemFunc <= "0111";
					MemWrEn		 <= '0';
					MemLink		 <= '0';
				when "11000"  => --AMOMINU
					MemFunc <= "1000";
					MemWrEn		 <= '0';
					MemLink		 <= '0';
				when "11100"  => --AMOMAXU
					MemFunc <= "1001";
					MemWrEn		 <= '0';
					MemLink		 <= '0';
				when others =>
					MemFunc <= "0000";
					MemWrEn		 <= '0';
					MemLink		 <= '0';
			end case;
		when opcode_SYSTEM => -- currently read only
			Funct		 	 <= "000";
			
			case Insn(31 downto 20) is
				when x"F10"  => --misa ISA and extensions supported.
					SrcRegNo1 <= "100000";
				when x"F11"  => --mvendorid Vendor ID.
					SrcRegNo1 <= "100001";
				when x"F12"  => --marchid Architecture ID.
					SrcRegNo1 <= "100010";
				when x"F13"  => --mimpid Implementation ID.
					SrcRegNo1 <= "100011";
				when x"F14"  => --mhartid Hardware thread ID.
					SrcRegNo1 <= "100100";
				when others =>
					SrcRegNo1 <= "000000";
			end case;
			
			--SrcRegNo1 	 <= "0" & Insn(19 downto 15);
			
			
			SrcRegNo2 	 <= "0" & "00000";
			DestRegNo 	 <= "0" & Insn(11 downto 7);
			DestWrEn	 	 <= '1';
			SelSrc2	 	 <= '1';
			
			Aux			 <= '0';			
			Imm			 <= x"00000000" or Insn(31 downto 20);
			
			Jump		 	 <= '0';
			JumpRel	 	 <= '0';
			JumpTarget	 <= x"00000000";
			PCNextO		 <= PCNextI;	
			
			InterlockO	 <= '0';
			MemAccess	 <= '0';
			MemWrEn		 <= '0';
			MemFunc 		 <= "0000";
			MemLink		 <= '0';
		when others =>
			DestWrEn	 	 <= '0'; 
			Funct		 	 <= "000";
			SrcRegNo1 	 <= "0" & "00000";
			SrcRegNo2 	 <= "0" & "00000";
			DestRegNo 	 <= "0" & "00000";
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
			MemFunc 		 <= "0000";
			MemLink		 <= '0';
		end case;
	end if;
end process;

end Behavioral;
