library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity memALU is
	Port (
		Funct 		: in std_logic_vector(3 downto 0);
		A 				: in std_logic_vector(31 downto 0);
		B 				: in std_logic_vector(31 downto 0);
		X_1			: out std_logic_vector(31 downto 0);
		X_2			: out std_logic_vector(31 downto 0)
	);
end memALU;

architecture Behavioral of memALU is
begin
process(Funct, A, B)
begin
	case Funct is
		when "0000" =>
			X_1 <= x"00000000";
			X_2 <= x"00000000";
		when "0001" => --AMOSWAP.W
			X_1 <= A;
			X_2 <= B;
		when "0010" => --AMOADD.W
			X_1 <= std_logic_vector(to_signed(to_integer(signed(A)) + to_integer(signed(B)), 32));
			X_2 <= x"00000000";
		when "0011" => --AMOXOR.W
			X_1 <= A xor B;
			X_2 <= x"00000000";
		when "0100" => --AMOAND.W
			X_1 <= A and B;
			X_2 <= x"00000000";
		when "0101" => --AMOOR.W
			X_1 <= A or B;
			X_2 <= x"00000000";
		when "0110" => --AMOMIN.W
			if (signed(A) < signed(B)) then
				X_1 <= A;
			else
				X_1 <= B;
			end if;
			X_2 <= x"00000000";
		when "0111" => --AMOMAX.W
			if (signed(A) > signed(B)) then
				X_1 <= A;
			else
				X_1 <= B;
			end if;
			X_2 <= x"00000000";
		when "1000" => --AMOMINU.W
			if (unsigned(A) < unsigned(B)) then
				X_1 <= A;
			else
				X_1 <= B;
			end if;
			X_2 <= x"00000000";
		when "1001" => --AMOMAXU.W
			if (unsigned(A) > unsigned(B)) then
				X_1 <= A;
			else
				X_1 <= B;
			end if;
			X_2 <= x"00000000";
		when "1010" =>
			X_1 <= x"00000000";
			X_2 <= x"00000000";
		when "1011" =>
			X_1 <= x"00000000";
			X_2 <= x"00000000";
		when "1100" =>
			X_1 <= x"00000000";
			X_2 <= x"00000000";
		when "1101" =>
			X_1 <= x"00000000";
			X_2 <= x"00000000";
		when "1110" =>
			X_1 <= x"00000000";
			X_2 <= x"00000000";
		when "1111" =>
			X_1 <= x"00000000";
			X_2 <= x"00000000";
		when others =>
			X_1 <= x"00000000";
			X_2 <= x"00000000";
	end case;
end process;

end Behavioral;
