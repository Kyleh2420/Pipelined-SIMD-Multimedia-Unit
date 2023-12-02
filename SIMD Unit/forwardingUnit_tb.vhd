----------------------------------------------------------------------------------
-- Company: Stony Brook University - ESE 345 Computer Architecture
-- Engineers: Kyle Han and Summer Wang
-- 
-- Create Date: 12/2/2023 2:47:21 AM
-- Design Name: 
-- Module Name: forwardingUnit_TB - Behavioral
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

entity forwardingUnit_tb is
	
end forwardingUnit_tb;

architecture behavioral of forwardingUnit_tb is
	signal ex_wb_instruction: std_logic_vector(24 downto 0);
	signal ex_wb_rdData: std_logic_vector(127 downto 0);
	signal ex_wb_rdAddress: std_logic_vector(4 downto 0);
	
	signal if_ex_Instruction: std_logic_vector(24 downto 0);
	
	signal if_ex_rs3Address, if_ex_rs2Address, if_ex_rs1Address, if_ex_rdAddress: std_logic_vector(4 downto 0);
	signal if_ex_rs3Data, if_ex_rs2Data, if_ex_rs1Data: std_logic_vector(127 downto 0);

	signal fwdR3Data: std_logic_vector(127 downto 0);
	signal fwdR2Data: std_logic_vector(127 downto 0);
	signal fwdR1Data: std_logic_vector(127 downto 0);
begin
	UUT: entity fwdUnit
		port map(wbInstruction => ex_wb_instruction,
		exInstruction => if_ex_Instruction,
		
		r3DataIn => if_ex_rs3Data,
		r2DataIn => if_ex_rs2Data,
		r1DataIn => if_ex_rs1Data,
		
		wbData => ex_wb_rdData,
		
		exR3Address => if_ex_rs3Address,
		exR2Address => if_ex_rs2Address,
		exR1Address => if_ex_rs1Address,
		exRdAddress => if_ex_rdAddress,
		
		wbRdAddress => ex_wb_rdAddress,
		
		--Outputs from the mux
		r3DataOut => fwdR3Data,
		r2DataOut => fwdR2Data, 
		r1DataOut => fwdR1Data 
		);
		testing: process
		begin
			
			--1st instruction (in Wb unit) is nop
			--2nd instruction (in ex unit) is au
			ex_wb_instruction <= "1100000000000000000000000";
			if_ex_Instruction <= "1100000010000010000000010";
			
			if_ex_rs3Data <= X"10000000000000000000000000000000";
			if_ex_rs2Data <= X"F0000000000F404000000000123F4240";
			if_ex_rs1Data <= X"F0000000000F404000000000123F4240";
			wait for 10ns;
			

			std.env.finish;
		end process;
end behavioral;