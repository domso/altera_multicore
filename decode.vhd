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

case Insn(6 downto 0) is

when opcode_OP => 
	Funct		 <= Insn(14 downto 12);
	SrcRegNo1 <= Insn(19 downto 15);
	SrcRegNo2 <= Insn(24 downto 20);
	DestRegNo <= Insn(11 downto 7);
	DestWrEn	 <= '1';
	SelSrc2	 <= '1';
	
	Aux		 <= Insn(30);
	
when opcode_OP_IMM => 
	Funct		 <= Insn(14 downto 12);
	SrcRegNo1 <= Insn(19 downto 15);
	DestRegNo <= Insn(11 downto 7);
	DestWrEn	 <= '1';
	SelSrc2	 <= '0';
	
	if (Insn(14 downto 12) = "101") then	
		Aux		 <= Insn(30);
	else
		Aux		 <= '0';
	end if;
	
	if (Insn(31 downto 31) = "0") then
		Imm		 <= x"00000000" or Insn(31 downto 20);
	else
		Imm		 <= x"FFFFFFFF" or Insn(31 downto 20);
	end if;
when others =>
	DestWrEn	 <= '0'; 
end case;




end process;

end Behavioral;
