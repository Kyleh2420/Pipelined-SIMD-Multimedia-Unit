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
	--The instruction currently being written back
	wbInstruction: in std_logic_vector(24 downto 0);
	--The instruction in the execution stage
	exInstruction: in std_logic_vector(24 downto 0);
	
	r3DataIn: in std_logic_vector(127 downto 0);
	r2DataIn: in std_logic_vector(127 downto 0);
	r1DataIn: in std_logic_vector(127 downto 0);
	
	--Data from the output of the wb register file
	wbData: in std_logic_vector(127 downto 0);
	
	--Addresses of R3-R1 of the execute stage
	exR3Address: in std_logic_vector(4 downto 0);
	exR2Address: in std_logic_vector(4 downto 0);
	exR1Address: in std_logic_vector(4 downto 0);
	exRdAddress: in std_logic_vector(4 downto 0);
	
	--Address of Rd of the execute stage
	wbRdAddress: in std_logic_vector(4 downto 0);
	
	
	--Outputs
	r3DataOut: out std_logic_vector(127 downto 0);
	r2DataOut: out std_logic_vector(127 downto 0);
	r1DataOut: out std_logic_vector(127 downto 0)
	);
end fwdUnit;

architecture behavioral of fwdUnit is
begin
	--For some reason, sensitivity list doesn't work with all
	--Originally, I used wbInstruction and exInstruction as a part of the sensitivity list.
	--Howev
	forward: process(r3DataIn, r2DataIn, r1DataIn, wbData, exR3Address, exR2Address, exR1Address, exRdAddress, wbRdAddress)
	begin
		--By default, route the data right through.
		r3DataOut <= r3DataIn;
		r2DataOut <= r2DataIn;
		r1DataOut <= r1DataIn;
		
		--If the execute instruction is a nop, just forward the data through
		--There is no wbRd, so there's nothing to check.
		if (wbInstruction(24 downto 23) = "11" and wbInstruction(18 downto 15) = "0000") then
			--Do nothing, just let the data forward through
			
		--If the ex opcode is a load imm, we'll compare wbRd to garbage addresses.
		--No data gets forwarded
		elsif (exInstruction(24) = '0') then
		--However, if wb instruction is load imm, and ex is also li with same rd, we have a hazard.
			if (exRdAddress = wbRdAddress) then
				r1DataOut <= wbData;	
			end if;
		else 
			--Handling any instruction into r3/r4
			--If wb rd = ex rs1, data hazard
			if (wbRdAddress = exR1Address) then
				r1DataOut <= wbData;
			end if;
			
			--If wb rd = ex rs2, data hazard
			if (wbRdAddress = exR2Address) then
				r2DataOut <= wbData;
			end if;
			
			--If wb rd = ex rs3, data hazard
			if (wbRdAddress = exR3Address) then
				r3DataOut <= wbData;
			end if;
			
		end if;		
	end process;

end behavioral;