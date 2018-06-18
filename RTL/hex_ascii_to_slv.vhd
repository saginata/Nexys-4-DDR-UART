-------------------------------------------------------------------------------
--	FILE:			hex_ascii_to_slv.vhd
--
--	DESCRIPTION:	This design is used to convert hex ascii values to the
--					corresponding std_logic_vectors. This is effectively a 
--					LUT (Look Up Table).
--
-- 	ENGINEER:		Jordan Christman
-------------------------------------------------------------------------------
-- Libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entity
entity hex_ascii_to_slv is
port(
	slv_out			: out std_logic_vector(3 downto 0);	-- 7 Seg display number output
	ascii_in		: in std_logic_vector(7 downto 0));	-- ASCII data input
end;

-- Architecture
architecture behave of hex_ascii_to_slv is

begin

	out_proc: process(ascii_in)
	begin
		case ascii_in is
			when x"30" => slv_out <= "0000";	-- 0
			when x"31" => slv_out <= "0001";	-- 1
			when x"32" => slv_out <= "0010";	-- 2
			when x"33" => slv_out <= "0011";	-- 3
			when x"34" => slv_out <= "0100";	-- 4
			when x"35" => slv_out <= "0101";	-- 5
			when x"36" => slv_out <= "0110";	-- 6
			when x"37" => slv_out <= "0111";	-- 7
			when x"38" => slv_out <= "1000";	-- 8
			when x"39" => slv_out <= "1001"; 	-- 9
			when x"41" => slv_out <= "1010"; 	-- A
			when x"42" => slv_out <= "1011"; 	-- B
			when x"43" => slv_out <= "1100"; 	-- C
			when x"44" => slv_out <= "1101"; 	-- D
			when x"45" => slv_out <= "1110"; 	-- E
			when x"46" => slv_out <= "1111"; 	-- F
			when others => 						-- Simulation errors
				slv_out <= (others => 'X');
		end case;
	end process out_proc;

end behave;