----------------------------------------------------------------------------------
-- Company: Stony Brook University - ESE 345 Computer Architecture
-- Engineers: Kyle Han and Summer Wang
-- 
-- Create Date: 11/29/2023 08:24:40 PM
-- Design Name: 
-- Module Name: Instruction Buffer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
library std;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.all;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity instructionBuffer is 
	Port( 
	--Inputs
	clk : in std_logic;
	filename: in string;
	
	--Outputs
	instruction: out std_logic_vector(24 downto 0);
	pcOutput: out integer);
end instructionBuffer;


architecture Behavioral of instructionBuffer is
	signal PC: integer := 0;

	
	type instArray is array (0 to 63) of std_logic_vector(24 downto 0);
	signal instBuffer: instArray;
begin							 
	process(clk)
		file inputFile : text;
        variable lineContents : line;
		variable i: integer := 0;
		variable readFile: integer := 0;
		variable tempInst: std_logic_vector(24 downto 0);
	begin
		--On each rising edge
		if(rising_edge(clk)) then	
			--If the file hasn't been read into memory, read the file. Then, set readFile to 1 so that we won't enter.
			if(readFile = 0) then 
				file_open(inputFile, filename, READ_MODE);
				while not endfile(inputFile) loop
                    readline(inputFile, lineContents);        -- Reads text line in file, stores line into line_contents                  
					read(lineContents, tempInst);  -- Reads line_contents and stores it into a temporary variable
                    instBuffer(i) <= tempInst;     -- Takes the information from the temp variable and inserts it into the instBuffer(i), which is an entry in the 64 25-bit instruction set
					i := i + 1;
                end loop;
				file_close(inputFile);
				readFile := 1;
				PC <= 0;
			--If the program counter has not reached the end, increment.
			elsif(PC < 63) then
				PC <= PC + 1;
			else 
				PC <= PC;
			end if;
		end if;
	end process;
	-- At any time, the output should be whatever the instruction is
	instruction <= instBuffer(PC);
	pcOutput <= PC;

end Behavioral;