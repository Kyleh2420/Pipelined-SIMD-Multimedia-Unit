----------------------------------------------------------------------------------
-- Company: Stony Brook University - ESE 345 Computer Architecture
-- Engineers: Kyle Han and Summer Wang
-- 
-- Create Date: 11/29/2023 9:57:21 PM
-- Design Name: 
-- Module Name: Multimedia Unit_TB - Behavioral
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
use std.env.finish;

entity multimediaUnit_tb is
	
end multimediaUnit_tb;

architecture behavioral of multimediaUnit_tb is
	signal clk: std_logic := '0';
	constant period : time := 10 us;
	
	constant in_str :string :="machineCode.txt";
    signal filenameIn: string(1 to in_str'length) := in_str;
	--signal filename: string(1 to 16) := "machineCode.txt"; --With this singular line of code, vivado didn't want to simulate. The constant above is a workaround
	
	constant out_str:string :="memory.txt";		--figure out how to ouput txt file
    signal filenameOut: string(1 to out_str'length) := out_str;
	--might not need this eof thing  -- update, just a signal to say finished writing to txt file
	signal eof: std_logic := '0';

--  type regArray is array (0 to 31) of std_logic_vector(127 downto 0);
--	signal registers: regArray;  
--	type STD_FILE is file of std_logic_vector(127 downto 0);	  -- define vector size
--	file fptrwr : STD_FILE;										  -- declare wr file pointer
	
begin
	UUT: entity multimediaUnit
		port map(
		--Inputs
		clk => clk,
		filenameIn => filenameIn,
		filenameOut => filenameOut);
		testing: process
			--declare variables used to write to results file
			file outputFile : text;

			variable fileStatWr : file_open_status;		-- if the variable = open_ok, everything fine. status_error -- file already open. name_error -- file can not be created. 
																-- mode_error -- cannnot be open in specified mode.
	        variable row : line;	-- a row
			variable i: integer := 0;		-- iterate from 0 - 31 for register printout
			variable fileRead: integer := 0;-- see if the file has been read? if writing to the results file many times, this won't be used
			--variable tempReg: std_logic_vector(127 downto 0); -- temp variable to store one register value
		
		begin
			for i in 0 to 133 loop			-- 67 cycles*2 -1 = 
				wait for period/2;
				clk <= not clk;
				-- probably need to insert code to write results file here.
				-- format:
				-- Cycle 1
				-- ID: instr
				-- RF: instr rs1_data rs2_data rs3_data rd rd_data 
				-- ALU: instr rd rd_data
				-- WB: instr rd rd_data
			end loop;
		-- simulation ends after 67 clocks!
		
			std.env.finish;
		end process;
end behavioral;