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

--Overarching Clock Counter
	signal clockCount: integer := 0;

--Stage 1
	--(Instruction Buffer Output, ID/IF Register Output)
	signal id_if_rs3, id_if_rs2, id_if_rs1, id_if_rd: std_logic_vector(4 downto 0);
	signal instructionBufferOut, id_if_instructionOut: std_logic_vector(24 downto 0);
	signal PC: integer;
--Stage 2
	--Outputs of the Register File
	signal rfRs3Data, rfRs2Data, rfRs1Data: std_logic_vector(127 downto 0);
	type registers_array is array (31 downto 0) of std_logic_vector (127 downto 0);
	signal registers: registers_array :=(others => (others => '0')); 		-- initializes every bit of each register to be 0
	
	signal r0, r1, r2, r3, r4, r5, r6, r7, r8: std_logic_vector(127 downto 0);
	signal r9: std_logic_vector(127 downto 0);
	signal r10: std_logic_vector(127 downto 0);
	signal r11: std_logic_vector(127 downto 0);
	signal r12: std_logic_vector(127 downto 0);
	signal r13: std_logic_vector(127 downto 0);
	signal r14: std_logic_vector(127 downto 0);
	signal r15: std_logic_vector(127 downto 0);
	signal r16: std_logic_vector(127 downto 0);
	signal r17: std_logic_vector(127 downto 0);
	signal r18: std_logic_vector(127 downto 0);
	signal r19: std_logic_vector(127 downto 0);
	signal r20: std_logic_vector(127 downto 0);
	signal r21: std_logic_vector(127 downto 0);
	signal r22: std_logic_vector(127 downto 0);
	signal r23: std_logic_vector(127 downto 0);
	signal r24: std_logic_vector(127 downto 0);
	signal r25: std_logic_vector(127 downto 0);
	signal r26: std_logic_vector(127 downto 0);
	signal r27: std_logic_vector(127 downto 0);
	signal r28: std_logic_vector(127 downto 0);
	signal r29: std_logic_vector(127 downto 0);
	signal r30: std_logic_vector(127 downto 0);
	signal r31: std_logic_vector(127 downto 0);
	
	-- Output of IF/EX register
	signal if_ex_Instruction: std_logic_vector(24 downto 0);
	signal if_ex_rs3Address, if_ex_rs2Address, if_ex_rs1Address, if_ex_rdAddress: std_logic_vector(4 downto 0);
	signal if_ex_rs3Data, if_ex_rs2Data, if_ex_rs1Data: std_logic_vector(127 downto 0);
	
--Stage 3
	signal fwdR3Data: std_logic_vector(127 downto 0);
	signal fwdR2Data: std_logic_vector(127 downto 0);
	signal fwdR1Data: std_logic_vector(127 downto 0);
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
	stage1: entity instructionBuffer port map(clk => clk, filename => filenameIn, instruction => instructionBufferOut, pcOutput => PC);
		
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
	
													
	fwdMux: entity fwdUnit port map(
		--Inputs to the Mux
		wbInstruction => ex_wb_instruction,
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
		
		
	alu: entity ALU port map(
							--Inputs to the ALU 
							wordIn => if_ex_Instruction,
							rs3 => fwdR3Data,
							rs2 => fwdR2Data,
							rs1 => fwdR1Data,
							rd => aluRdData);			
													
													
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
-- BELOW isn't allowed 
-- figure out how to output 1 result text file
--		if(fileRead = 0) then
--			file_open(fileStatWr, outputFile, filenameOut, WRITE_MODE);		 -- acc open the file
--			for i in 0 to 31 loop
				--readline(outputFile, row);
--				write(row, registers(i), right, 128);
--			end loop;
--			eof <= '1';		-- indicate eof
--			file_close(outputFile);	-- close outputFile "memory.txt"
		-- elsif(PC < 67) then    -- have some sort of mechanism to keep the file printout until the end of 
--		end if;
		
--		if(rising_edge(clk)) then
--			write(row, registers(i), right, 15);
--		end if;
		
		
	result_write : process (clk)
    file result_file: text;
    variable row : line;
    variable open_status : file_open_status;
    begin		
		if (rising_edge(clk)) then
			clockCount <= clockCount + 1;
				
	        file_open(open_status, result_file, filenameOut, APPEND_MODE);		-- open output file in append mode
	        if (open_status = open_ok)  then
				report "printing to file";
				write(row, "{{Cycle " & integer'image(clockCount) & "}}");
				writeline(result_file, row);
				--PC <= PC + 1;  -- PC might become funny because this is incrementing
				
				-- Printing IF Stage
				write(row, "[IF Stage]");
				writeline(result_file, row);
	            write(row, "Opcode: " & to_string(if_ex_Instruction) & string'(""));
				writeline(result_file, row);
				write(row, string'(""));
				writeline(result_file, row);
				
				-- Printing ID Stage
				write(row, "[Instruction Decode Stage RF]");
				writeline(result_file, row);
				if (id_if_instructionOut(24 downto 15) /= "11XXXX0000") then
					if (id_if_instructionOut(24 downto 23) = "10" or id_if_instructionOut(24 downto 23) = "11") then  --R3 and R4 instr
						write(row, "Register " & integer'image(to_integer(unsigned(id_if_rs1))) & ": " & integer'image(to_integer(unsigned(rfRs1Data))));	 --r1 addr id_if_rs2 + r1 value	--rs2_ID    1 a_val_ID 2b, 3c
						writeline(result_file, row); 
						write(row, "Register " & integer'image(to_integer(unsigned(id_if_rs2))) & ": " & integer'image(to_integer(unsigned(rfRs2Data))));
						writeline(result_file, row);
					end if;
					if (id_if_instructionOut(24 downto 23) = "10") then -- R4 Instruction 
						write(row, "Register " & integer'image(to_integer(unsigned(id_if_rs3))) & ": " & integer'image(to_integer(unsigned(rfRs3Data))));
						writeline(result_file, row);
					end if;
					write(row, "Rd " & integer'image(to_integer(unsigned(id_if_instructionOut(4 downto 0)))));
					write(row, string'(""));
					writeline(result_file, row);
				end if;
	            
				-- Printing EX Stage
				write(row, "[ALU]");
				writeline(result_file, row);
				if (if_ex_Instruction(24 downto 15) /= "11XXXX0000") then
					if (if_ex_Instruction(24) = '1') then
						write(row, "Register " & integer'image(to_integer(unsigned(if_ex_rs1Address))) & ": " & integer'image(to_integer(unsigned(if_ex_rs1Data))));
						writeline(result_file, row); 
						write(row, "Register " & integer'image(to_integer(unsigned(if_ex_rs2Address))) & ": " & integer'image(to_integer(unsigned(if_ex_rs2Data))));
						writeline(result_file, row);
					end if;
					if (if_ex_Instruction(24 downto 23) = "10") then -- R4 Instruction 
						write(row, "Register " & integer'image(to_integer(unsigned(if_ex_rs3Address))) & ": " & integer'image(to_integer(unsigned(if_ex_rs3Data))));
						writeline(result_file, row);
					end if;
					write(row, "Destination Register " & integer'image(to_integer(unsigned(if_ex_Instruction(4 downto 0)))) & ": " & integer'image(to_integer(unsigned(aluRdData))));
					write(row, string'(""));
					writeline(result_file, row);
				end if;
				
				-- Printing WB Stage
				write(row, "[WB]");
				writeline(result_file, row);
				if (ex_wb_instruction(24 downto 15) /= "11XXXX0000") then
					-- Write signals based on what is being forwarded, or whether there's a writeback
					--if (ex_wb_instruction(24) = '1') then
					--	write(row, "Register " & integer'image(to_integer(unsigned(rs1_EX))) & ": " & integer'image(to_integer(unsigned(a_val_EX))));
					--	writeline(result_file, row); 
					--	write(row, "Register " & integer'image(to_integer(unsigned(rs2_EX))) & ": " & integer'image(to_integer(unsigned(b_val_EX))));
					--	writeline(result_file, row);
					--end if;
					--if (ex_wb_instruction(24 downto 23) = "10") then -- R4 Instruction 
					--	write(row, "Register " & integer'image(to_integer(unsigned(rs3_EX))) & ": " & integer'image(to_integer(unsigned(c_val_EX))));
					--	writeline(result_file, row);
					--end if;
					write(row, "Rd " & integer'image(to_integer(unsigned(ex_wb_instruction(4 downto 0)))) & ": " & integer'image(to_integer(unsigned(ex_wb_rdData))));
					write(row, string'(""));
					writeline(result_file, row);
				end if;
				
				write(row, string'(""));
				writeline(result_file, row);
				write(row, string'(""));
				writeline(result_file, row);
				
	            file_close(result_file); 
	        else
	            report "File could not be opened" severity error;
	        end if; 
		end if;
    end process result_write;
end structural;
