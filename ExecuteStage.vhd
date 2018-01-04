library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ExecuteStage is
	Port (
		FunctI		: in std_logic_vector(2 downto 0);
		SrcData1I	: in std_logic_vector(31 downto 0);
		SrcData2I	: in std_logic_vector(31 downto 0);
		DestRegNoI	: in std_logic_vector(5 downto 0);
		DestWrEnI	: in std_logic;
		ImmI			: in std_logic_vector(31 downto 0);
		SelSrc2I		: in std_logic;
		AuxI			: in std_logic;
		PCNextI		: in std_logic_vector(31 downto 0);
		JumpI			: in std_logic;
		JumpRelI		: in std_logic;
		JumpTargetI	: in std_logic_vector(31 downto 0);
		MemAccessI	: in std_logic;
		MemWrEnI		: in std_logic;
		ClearI		: in std_logic;
		StallI		: in std_logic;
		nRst   		: in std_logic;
		Clk   		: in std_logic;

		
		
		SrcData2O	: out std_logic_vector(31 downto 0);
		ImmO			: out std_logic_vector(31 downto 0);
		SelSrc2O		: out std_logic;
		SrcData1O	: out std_logic_vector(31 downto 0);
		FunctO		: out std_logic_vector(2 downto 0);
		AuxO			: out std_logic;
		DestWrEnO	: out std_logic;
		DestRegNoO	: out std_logic_vector(5 downto 0);
		PCNextO		: out std_logic_vector(31 downto 0);
		JumpO			: out std_logic;
		JumpRelO		: out std_logic;
		JumpTargetO	: out std_logic_vector(31 downto 0);
		MemAccessO	: out std_logic;
		MemWrEnO		: out std_logic;
		ClearO		: out std_logic;
		StallO		: out std_logic
	);
end ExecuteStage;

architecture Behavioral of ExecuteStage is
begin

process(nRst, Clk, StallI)
begin

if nRst = '0' then
	FunctO       <= "000";
	SrcData1O    <= x"00000000";
	SrcData2O    <= x"00000000";
	ImmO         <= x"00000000";
	SelSrc2O     <= '0';
	AuxO         <= '0';
	DestWrEnO    <= '0';
	DestRegNoO   <= "000000";
	PCNextO      <= x"00000000";
	JumpO        <= '0';
	JumpRelO     <= '0';
	JumpTargetO  <= x"00000000";
	MemAccessO   <= '0';
	MemWrEnO     <= '0';
	ClearO       <= '0';
	StallO       <= '0';
elsif rising_edge(Clk) then
	if StallI = '0' then
		FunctO       <= FunctI;
		SrcData1O    <= SrcData1I;
		SrcData2O    <= SrcData2I;
		ImmO         <= ImmI;
		SelSrc2O     <= SelSrc2I;
		AuxO         <= AuxI;
		DestWrEnO    <= DestWrEnI;
		DestRegNoO   <= DestRegNoI;
		PCNextO      <= PCNextI;
		JumpO        <= JumpI;
		JumpRelO     <= JumpRelI;
		JumpTargetO  <= JumpTargetI;
		
		if (ClearI = '0') then
			MemAccessO   <= MemAccessI;
			MemWrEnO     <= MemWrEnI;
		else
			MemAccessO   <= '0';
			MemWrEnO     <= '0';	
		end if;
			
		ClearO       <= ClearI;
		StallO       <= StallI;
	end if;
end if;

end process;


end Behavioral;
