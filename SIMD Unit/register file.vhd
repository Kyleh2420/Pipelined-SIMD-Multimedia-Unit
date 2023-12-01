library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;


entity resgiter_file is
port(
	WR_en: in std_logic;	-- Write enable 
	R1_addr: in std_logic_vector(4 downto 0);  --	R1 Address input
	R2_addr: in std_logic_vector(4 downto 0);	 --	R2 Address input
	R3_addr: in std_logic_vector(4 downto 0);	 -- R3 Address input 
	Rd_addr: in std_logic_vector(4 downto 0);  -- Rd Address input
	Rd_data: in std_logic_vector(127 downto 0); -- Rd data in from Write Back
--	CLK: in std_logic; -- clock input for RAM
	R1_out: out std_logic_vector(127 downto 0); -- R2 register output
	R2_out: out std_logic_vector(127 downto 0); -- R2 register output
	R3_out: out std_logic_vector(127 downto 0) -- Data output of RAM
);
end resgiter_file;

architecture comb of resgiter_file is
-- define the new type for the 32*128 register file
type registers_array is array (31 downto 0) of std_logic_vector (127 downto 0);
-- initial values in the resgiter file
signal registers: registers_array :=(   		-- initializes every bit of each register to be 0
	others => (others => '0') );
   
begin
	process(all) 

	begin
		if(WR_en='1') then -- when write enable = 1, 
			-- write back data into Rd in register file at the provided Rd address
			registers(to_integer(unsigned(Rd_addr))) <= Rd_Data;
			-- The index of the registers array needs to be integer so
			-- converts RAM_ADDR from std_logic_vector -> Unsigned -> Interger using numeric_std library
		end if;
		R1_out <= registers(to_integer(unsigned(R1_addr)));
		R2_out <= registers(to_integer(unsigned(R2_addr)));
		R3_out <= registers(to_integer(unsigned(R3_addr)));
		
	end process;
	 -- Data to be read out
end comb;