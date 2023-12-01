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
-- Revision 0.02 - All components connected except forwarding unit
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

--Stage 1
	--(Instruction Buffer Output, ID/IF Register Output)
	signal id_if_rs3, id_if_rs2, id_if_rs1, id_if_rd: std_logic_vector(4 downto 0);
	signal instructionBufferOut, id_if_instructionOut: std_logic_vector(24 downto 0);
	
--Stage 2
	--Outputs of the Register File
	signal rfRs3Data, rfRs2Data, rfRs1Data: std_logic_vector(127 downto 0);
		
	-- Output of IF/EX register
	signal if_ex_Instruction: std_logic_vector(24 downto 0);
	signal if_ex_rs3Address, if_ex_rs2Address, if_ex_rs1Address, if_ex_rdAddress: std_logic_vector(4 downto 0);
	signal if_ex_rs3Data, if_ex_rs2Data, if_ex_rs1Data: std_logic_vector(127 downto 0);
	
--Stage 3
	signal aluRdData: std_logic_vector(127 downto 0);
	
--Stage 4
	--Output of the EX/WB Register
	signal ex_wb_instruction: std_logic_vector(24 downto 0);
	signal ex_wb_rdData: std_logic_vector(127 downto 0);
	signal ex_wb_rdAddress: std_logic_vector(4 downto 0);
	
	--Output of the Writeback Unit
	signal wbu_rdData: std_logic_vector(127 downto 0);
	signal wbu_rdAddress: std_logic_vector(4 downto 0);
	signal writeEn: std_logic;
begin
	stage1: entity instructionBuffer port map(clk => clk, filename => filenameIn, instruction => instructionBufferOut);
	id_if_register: entity if_idRegister port map(--The Inputs to the Register
												clk => clk, 
												instruction => instructionBufferOut,
												--The Outputs to the Register
												instructionOut => id_if_instructionOut, 
												rs3 => id_if_rs3, 
												rs2 => id_if_rs2, 
												rs1 => id_if_rs1, 
												rd => id_if_rd);

	register_file: entity resgiter_file port map(-- input
													WR_en => writeEn,
													R1_addr => id_if_rs1,
													R2_addr => id_if_rs2,
													R3_addr => id_if_rs3,
													Rd_addr => wbu_rdAddress, -- write back unit Rd
													Rd_data	=> wbu_rdData,
												--output
													R1_out => rfRs1Data,
													R2_out => rfRs2Data,
													R3_out => rfRs3Data);
													-- left is entity variable
													-- right is signal
												
	if_ex_register: entity if_exRegister port map(--The Inputs to the register
													clk => clk,
													instruction => id_if_instructionOut,
													
													r3DataIn => rfRs3Data,
													r2DataIn => rfRs2Data,
													r1DataIn => rfRs1Data,
													
													rs3AddressIn => id_if_rs3,
													rs2AddressIn => id_if_rs2,
													rs1AddressIn => id_if_rs1,
													rdAddressIn => id_if_rd,
													
													--The output of the register
													instructionOut => if_ex_Instruction,
													
													rs3AddressOut => if_ex_rs3Address,
													rs2AddressOut => if_ex_rs2Address,
													rs1AddressOut => if_ex_rs1Address,
													rdAddressOut => if_ex_rdAddress,
													
													r3DataOut => if_ex_rs3Data,
													r2DataOut => if_ex_rs2Data,
													r1DataOut => if_ex_rs1Data);
													
	ex_wb_register: entity ex_wbRegister port map( --The Inputs to the register
													clk => clk,
													instruction => if_ex_Instruction,
													rdDataIn => aluRdData,
													rdAddressIn => if_ex_rdAddress,
													
													--The outputs of the register
													instructionOut => ex_wb_instruction,
													rdDataOut => ex_wb_rdData,
													rdAddressOut => ex_wb_rdAddress); 
													
	writeBackUnit: entity writeBackUnit port map( --The Inputs to the WBU
													instruction => ex_wb_instruction,
													rdDataIn => ex_wb_rdData,
													rdAddressIn => ex_wb_rdAddress,
													
													--The Outputs of the WBU
													writeEn => writeEn,
													rdDataOut => wbu_rdData,
													rdAddressOut => wbu_rdAddress);
													

end structural;
