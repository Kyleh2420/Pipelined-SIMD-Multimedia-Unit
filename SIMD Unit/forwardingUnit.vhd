----------------------------------------------------------------------------------
-- Company: Stony Brook University - ESE 345 Computer Architecture
-- Engineers: Kyle Han and Summer Wang
-- 
-- Create Date: 11/30/2023 11:24:21 PM
-- Design Name: 
-- Module Name: Forwarding Unit - Behavioral
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

entity fwdUnit is
	Port(
	--Inputs
	--The instruction currently being executed
	exInstruction: in std_logic_vector(24 downto 0);
	--The instruction in the instruction Fetch stage
	ifInstruction: in std_logic_vector(24 downto 0);
	
	r3DataIn: in std_logic_vector(127 downto 0);
	r2DataIn: in std_logic_vector(127 downto 0);
	r1DataIn: in std_logic_vector(127 downto 0);
	
	--Data from the output of the ALU
	exData: in std_logic_vector(127 downto 0);
	
	--Addresses of R3-R1 of the instruction fetch stage
	ifR3Address: in std_logic_vector(4 downto 0);
	ifR2Address: in std_logic_vector(4 downto 0);
	ifR1Address: in std_logic_vector(4 downto 0);
	ifRdAddress: in std_logic_vector(4 downto 0);
	
	--Address of Rd of the execute stage
	exRdAddress: in std_logic_vector(4 downto 0);
	
	
	--Outputs
	r3DataOut: out std_logic_vector(127 downto 0);
	r2DataOut: out std_logic_vector(127 downto 0);
	r1DataOut: out std_logic_vector(127 downto 0);
	
	);
end fwdUnit;

architecture behavioral of fwdUnit is
begin 
	forward: process(exInstruction)
	begin
		--By default, route the data right through.
		r3DataOut <= r3DataIn;
		r2DataOut <= r2DataIn;
		r1DataOut <= r1DataIn;
		
		--If the execute instruction is a nop, just forward the data through
		--There is no exRd, so there's nothing to check.
		if (exInstruction(24 downto 15) = "11----0000") then
			--Do nothing, just let the data forward through
			
		--If the instruction fetch opcode is a load imm, we'll compare exRd to garbage addresses.
		--No data gets forwarded
		elsif (ifInstruction(24) = '0') then
		--However, if execute instruction is load imm, and so is the next one with the same rd, we have a hazard.
			if (ifRdAddress = exRdAddress) then
				rs1 <= exData;	
			end if;
		else 
			--Handling any instruction into r3/r4
			--If execute rd = if rs1, data hazard
			if (exRdAddress = ifR1Address) then
				r1DataOut <= exData;	
			end if;
			
			--If execute rd = if rs2, data hazard
			if (exRdAddress = ifR2Address) then
				r2DataOut <= exData;	
			end if;
			
			--If execute rd = if rs3, data hazard
			if (exRdAddress = ifR3Address) then
				r3DataOut <= exData;	
			end if;
			
		end if;		
	end process;

end behavioral;