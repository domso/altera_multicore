library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;


entity node is
	generic (mhartid : std_logic_vector(31 downto 0));
	Port (		
		nRst   					: in std_logic;
		Clk   					: in std_logic;
		
		busData		: inout std_logic_vector(31 downto 0);
		busAddr		: inout std_logic_vector(31 downto 0);
		busCtrl		: inout std_logic_vector(31 downto 0);

		busAck		: in std_logic_vector(31 downto 0);
		busReq		: out std_logic_vector(31 downto 0);
		busForward	: in std_logic_vector(31 downto 0)

	);
end node;

architecture Behavioral of node is
		signal signal_address_a : std_logic_vector(9 downto 0);
		signal signal_address_b : std_logic_vector(9 downto 0);
		signal signal_q_a		  : std_logic_vector(31 downto 0);
		signal signal_q_b		  : std_logic_vector(31 downto 0);
		
		signal signal_stall    : std_logic;
		
		signal signal_data_out        : std_logic_vector(31 downto 0);
		
		signal signal_memFunc			 	 : std_logic_vector(3 downto 0);
		signal signal_data   		    : std_logic_vector(31 downto 0);
		signal signal_address         : std_logic_vector(31 downto 0);
		signal signal_wren			 	 : std_logic;
		signal signal_memLink			 	 : std_logic;
		signal signal_byteEna			 	 : std_logic_vector(3 downto 0);
		
		signal signal_stall_2core    : std_logic;
		
		signal signal_data_out_2core        : std_logic_vector(31 downto 0);
		
		signal signal_memFunc_2core			 	 : std_logic_vector(3 downto 0);
		signal signal_data_2core  		    : std_logic_vector(31 downto 0);
		signal signal_address_2core         : std_logic_vector(31 downto 0);
		signal signal_wren_2core			 	 : std_logic;
		signal signal_memLink_2core			 	 : std_logic;
		signal signal_memFence_2core			 	 : std_logic;
		signal signal_byteEna_2core			 	 : std_logic_vector(3 downto 0);
		
		

component InstructionMemory
	Port (
		address_a : in std_logic_vector(9 downto 0);
		address_b : in std_logic_vector(9 downto 0);
		clock		 : in std_logic;
		q_a		 : out std_logic_vector(31 downto 0);
		q_b		 : out std_logic_vector(31 downto 0)
	);
end component;

component core
	Port (
		instr_q_a : in std_logic_vector(31 downto 0);
		instr_q_b : in std_logic_vector(31 downto 0);
		data_out  : in std_logic_vector(31 downto 0);
		Clk	    : in std_logic;
		nRst	    : in std_logic;
		Stall	 	 : in std_logic;
		mhartid   : in std_logic_vector(31 downto 0);
		
		instr_address_a : out std_logic_vector(9 downto 0);
		instr_address_b : out std_logic_vector(9 downto 0);
		data   		    : out std_logic_vector(31 downto 0);
		address         : out std_logic_vector(31 downto 0);
		byteEna			 : out std_logic_vector(3 downto 0);
		wren			 	 : out std_logic;
		memLink       	 : out std_logic;
		memFence      	 : out std_logic;
		memFunc		 	 : out std_logic_vector(3 downto 0)
	);
end component;

component BusController
	generic (mhartid : std_logic_vector(31 downto 0));
	Port (		
		busData		: inout std_logic_vector(31 downto 0);
		busAddr		: inout std_logic_vector(31 downto 0);
		busCtrl		: inout std_logic_vector(31 downto 0);

		busAck		: in std_logic_vector(31 downto 0);
		busReq		: out std_logic_vector(31 downto 0);
		busForward	: in std_logic_vector(31 downto 0);	


		nRst   					: in std_logic;
		Clk   					: in std_logic;	

		Func     	         : in std_logic_vector(3 downto 0);	
		data        			: in	std_logic_vector(31 downto 0);
		address     			: in	std_logic_vector(31 downto 0);
		wren        			: in	std_logic;
		link        			: in	std_logic;
		byteEna 	            : in std_logic_vector(3 downto 0);
		

		
		dataO	      			: out	std_logic_vector(31 downto 0);
		Stall						: out	std_logic
	);
end component;

component write_buffer is
	Port (		
		nRst   					: in std_logic;
		Clk   					: in std_logic;	
		
		StallI					: in	std_logic;
		FenceI					: in	std_logic;
		
		FuncI     	         : in std_logic_vector(3 downto 0);	
		dataI        			: in std_logic_vector(31 downto 0);
		addressI     			: in std_logic_vector(31 downto 0);
		wrenI        			: in std_logic;
		linkI        			: in std_logic;
		byteEnaI 	         : in std_logic_vector(3 downto 0);
		resultDataI   			: in std_logic_vector(31 downto 0);
	
		StallO					: out	std_logic;
	
		FuncO     	         : out std_logic_vector(3 downto 0);	
		dataO        			: out std_logic_vector(31 downto 0);
		addressO     			: out std_logic_vector(31 downto 0);
		wrenO        			: out std_logic;
		linkO        			: out std_logic;
		byteEnaO 	         : out std_logic_vector(3 downto 0);
		resultDataO  			: out std_logic_vector(31 downto 0)
	);
end component;

begin

memInstance: InstructionMemory port map (
	address_a => signal_address_a,
	address_b => signal_address_b,
	clock     => Clk,
	q_a       => signal_q_a,
	q_b		 => signal_q_b
);

coreInstance: core port map (
	instr_q_a => signal_q_a,
	instr_q_b => signal_q_b,
	data_out  => signal_data_out_2core,
	Clk       => Clk,
	nRst	    => nRst,
	Stall	    => signal_stall_2core,
	mhartid   => mhartid,
	
	data	    => signal_data_2core,
	address	 => signal_address_2core,
	byteEna   => signal_byteEna_2core,
	wren		 => signal_wren_2core,
	memLink	 => signal_memLink_2core,
	memFence  => signal_memFence_2core,
	memFunc   => signal_memFunc_2core,
	instr_address_a => signal_address_a,
	instr_address_b => signal_address_b	
);

writeBufferInstance: write_buffer port map (
	nRst => nRst,
	Clk  => Clk,
	
	FenceI => signal_memFence_2core,
	FuncO => signal_memFunc,
	dataO => signal_data,
	addressO => signal_address,
	wrenO => signal_wren,
	linkO => signal_memLink,
	byteEnaO => signal_byteEna,
	
	resultDataI => signal_data_out,
	StallI => signal_stall,
	
	FuncI => signal_memFunc_2core,
	dataI => signal_data_2core,
	addressI => signal_address_2core,
	wrenI => signal_wren_2core,
	linkI => signal_memLink_2core,
	byteEnaI => signal_byteEna_2core,
	
	resultDataO => signal_data_out_2core,
	StallO => signal_stall_2core
);

busControllerInstance: BusController generic map (
	mhartid	=> mhartid
) port map (
	busData => busData,
	busAddr => busAddr,
	busCtrl => busCtrl,
	busAck  => busAck,
	busReq  => busReq,
	busForward => busForward,
	
	nRst => nRst,
	Clk  => Clk,
	
	Func => signal_memFunc,
	data => signal_data,
	address => signal_address,
	wren => signal_wren,
	link => signal_memLink,
	byteEna => signal_byteEna,
	
	dataO => signal_data_out,
	Stall => signal_stall
);


process(Clk)
begin
	
end process;

end Behavioral;
