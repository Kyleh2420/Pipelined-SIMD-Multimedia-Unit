----------------------------------------------------------------------------------
-- Company: Stony Brook University - ESE 345 Computer Architecture
-- Engineers: Kyle Han and Summer Wang
-- 
-- Create Date: 11/30/2023 3:04:21 PM
-- Design Name: 
-- Module Name: multimediaUnit - Structural
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

entity multimediaUnit is
	port ( clk: in std_logic;  --External Clock signal
	filenameIn: in string;  -- The input file with machine code
	filenameOut: in string	   --The final output - the state of memory once the program have been run
	);
	
end multimediaUnit;

architecture structural of multimediaUnit is
	signal id_if_rs3, id_if_rs2, id_if_rs1, id_if_rd: std_logic_vector(4 downto 0);
	signal id_if_instruction, id_if_instructionOut: std_logic_vector(24 downto 0);
begin
	stage1: entity instructionBuffer port map(clk => clk, filename => filenameIn, instruction => id_if_instruction);
	id_if_register: entity if_idRegister port map(clk => clk, instruction => id_if_instruction,  --The inputs to the register
												instructionOut => id_if_instructionOut, rs3 => id_if_rs3, rs2 => id_if_rs2, rs1 => id_if_rs1, rd => id_if_rd);  --The outputs to the register
	
end structural;
