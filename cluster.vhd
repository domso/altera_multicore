library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity cluster is
	Port (		
		nRst   					: in std_logic;
		Clk   					: in std_logic;
		
		busData		: inout std_logic_vector(31 downto 0);
		busAddr		: inout std_logic_vector(31 downto 0);
		busCtrl		: inout std_logic_vector(31 downto 0);
		
		busAck      : out std_logic_vector(31 downto 0)
	);
end cluster;

architecture Behavioral of cluster is
	type vector32 is array (natural range <>) of std_logic_vector(31 downto 0);
	signal signal_busAck : std_logic_vector(31 downto 0);

	
	constant num_core : integer := 1;	
	signal signal_busReq : vector32((num_core - 1) downto 0);	
	
	
component node	
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
end component;

begin

nodeCluster: for i in 0 to (num_core - 1) generate

firstNode: if i = 0 generate
n0: node 
	generic map(
		mhartid			=> std_logic_vector(to_unsigned(i, 32))
	)
	port map (
		nRst 		=> nRst,
		Clk		=> Clk,
		
		busData	=> busData,
		busAddr	=> busAddr,
		busCtrl	=> busCtrl,
		
		busAck	=> signal_busAck,
		busReq	=> signal_busAck,--signal_busReq(i),
		busForward => x"FFFFFFFF"
	);
end generate firstNode;

normalNode: if i > 0 and i < (num_core - 1) generate
n1: node 
	generic map(
		mhartid			=> std_logic_vector(to_unsigned(i, 32))
	)
	port map (
		nRst 		=> nRst,
		Clk		=> Clk,
		
		busData	=> busData,
		busAddr	=> busAddr,
		busCtrl	=> busCtrl,
		
		busAck	=> signal_busAck,
		busReq	=> signal_busReq(i),
		busForward => signal_busReq(i - 1)
	);
end generate normalNode;

lastNode: if i = (num_core - 1) and num_core > 1 generate
n2: node 
	generic map(
		mhartid			=> std_logic_vector(to_unsigned(i, 32))
	)
	port map (
		nRst 		=> nRst,
		Clk		=> Clk,
		
		busData	=> busData,
		busAddr	=> busAddr,
		busCtrl	=> busCtrl,
		
		busAck	=> signal_busAck,
		busReq	=> signal_busAck,
		busForward => signal_busReq(i - 1)
	);
end generate lastNode;
end generate nodeCluster;

process(Clk)
begin
if nRst = '0' then
	busAck 	<= x"FFFFFFFF";
elsif rising_edge(Clk) then
	busAck <= signal_busAck;
end if;
end process;

end Behavioral;

