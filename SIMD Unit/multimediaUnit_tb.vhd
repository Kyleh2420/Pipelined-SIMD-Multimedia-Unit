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
--  signals for instruction buffer
	signal clk: std_logic := '0';
	constant period : time := 10 us;
	signal clkcount: integer := -1;

--  filenames
	constant inputFile :string :="machineCode.txt";
    constant BL_STR: string :="";
    constant outputFile: string := "memory.txt";
	
--	constant out_str:string :="memory.txt";
--    signal filenameOut: string(1 to out_str'length) := out_str;
--	--might not need this eof thing  -- update, just a signal to say finished writing to txt file
--	signal eof: std_logic := '0';
--	
--	constant result_register: string := "result_register.txt";		   -- made a new file, store final reg file state, to compare to expected results
--	signal fileReg: string(1 to result_register'length) := result_register;
	
	signal instr, opcode, func, field: std_logic_vector(24 downto 0);
	signal rs1_data, rs2_data, rs3_data, 
    mux_data1, mux_data2, mux_data3, mux_data,
    alu_in1, alu_in2, alu_in3, alu_out,
    wb_data: std_logic_vector(127 downto 0);
    signal WE:  std_logic;
    signal rd: std_logic_vector(4 downto 0);
	signal r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28, r29, r30, r31: std_logic_vector(127 downto 0);
	
	
	type filltype is (NOFILL, ZEROFILL);
    function to_dstring (
        value:      in integer;
        field:      in width := 0;
        just:       in side := RIGHT;
        fill:       in filltype := NOFILL
    ) return string is
        variable retstr: string (1 to field);
    begin
        if field = 0 then
            return integer'image(value);
        elsif field < integer'image(value)'length then 
            retstr := (others => '#');
        elsif fill = NOFILL  or just = LEFT then
            retstr := justify (integer'image(value), just, field);
        else  -- fill = ZEROFILL and just = RIGHT, field >= image length
            retstr  := justify (integer'image(abs value), just, field);
            for i in retstr'range loop
                if retstr(i) = ' ' then
                    retstr(i) := '0';
                end if;
            end loop;
            if value < 0 then
                retstr(1) := '-';
            end if;
        end if;
        return retstr;
    end function to_dstring;

-- tb signals on the right
-- component signal on the left
begin
	UUT: entity multimediaUnit
		port map (clk => clk, filenameIn => inputFile, filenameOut => outputFile,
	       instr => instr, opcode => opcode, func => func, field => field,	     --instructions for each stage
	       rs1_data => rs1_data, rs2_data => rs2_data, rs3_data => rs3_data,	 --stage 1
	       mux_data1 => mux_data1, mux_data2 => mux_data2, mux_data3 => mux_data3, --stage 2
	       alu_in1 => alu_in1, alu_in2 => alu_in2, alu_in3 => alu_in3, alu_out => alu_out,				 --stage 3
	       wb_data => wb_data,
	       WE => WE, rd => rd,
		   r0 => r0, r1 => r1, r2 => r2, r3 => r3, r4 => r4, r5 => r5, r6 => r6, r7 => r7, r8 => r8, r9 => r9,
		   r10 => r10, r11 => r11, r12 => r12, r13 => r13, r14 => r14, r15 => r15, r16 => r16, r17 => r17, r18 => r18, r19 => r19,
		   r20 => r20, r21 => r21, r22 => r22, r23 => r23, r24 => r24, r25 => r25, r26 => r26, r27 => r27, r28 => r28, r29 => r29,	 
		   r30 => r30, r31 => r31);
		   
		testing: process
			--declare variables used to write to results file
			file outputFile : text;
			variable fileStatWr : file_open_status;		-- if the variable = open_ok, everything fine. status_error -- file already open. name_error -- file can not be created. 
														-- mode_error -- cannnot be open in specified mode.
	        variable row : line;	-- a row
			variable i: integer := 0;		-- iterate from 0 - 31 for register printout
			variable fileRead: integer := 0;-- see if the file has been read? if writing to the results file many times, this won't be used
			--variable tempReg: std_logic_vector(127 downto 0); -- temp variable to store one register value
---- original loop		
--		begin
--			for i in 0 to 135 loop			-- 67 cycles*2 -1 = 
--				wait for period/2;
--				clk <= not clk;

--			end loop;
--		-- simulation ends after 67 clocks!
--		-- write the end results file here
--		-- file_open(open_status, outputFile, filenameOut, )

--  from J
	begin	 
		for i in 0 to 69 * 2 loop
			clk <= not clk;
			if(i mod 2 = 0) then
			     clkcount <= clkcount + 1;
			end if;
			report "INSTRUCTION " & (to_string(clkcount)) severity note; 
			-- NOTE: to_string FUNCTION REQUIRES VHDL-2008. GO TO DESIGN TAB >> SETTINGS >> COMPILATION >> VHDL >> CHANGE STANDARD VERSION TO VHDL-2008
			wait for period/2;
		end loop;
		std.env.finish;
	end process; 
--	
	resultheader: process
	   file result_file: text;
	   variable line_contents: line;
	   variable open_status: file_open_status;
	   
	begin
	   file_open(open_status, result_file, outputfile, WRITE_MODE);
	   if open_status = open_ok then
	       write(line_contents, string'("                                                                                       **********************************"));
	       writeline(result_file, line_contents);
	       write(line_contents, string'("                                                                                       *                                *"));
	       writeline(result_file, line_contents);
	       write(line_contents, string'("                                                                                       *           RESULT FILE          *"));
	       writeline(result_file, line_contents);
	       write(line_contents, string'("                                                                                       *                                *"));
	       writeline(result_file, line_contents);
	       write(line_contents, string'("                                                                                       **********************************"));
	       writeline(result_file, line_contents);
	       write(line_contents, string'(""));
	       writeline(result_file, line_contents);
	       write(line_contents, string'(""));
	       writeline(result_file, line_contents);
	   end if;
	   file_close(result_file);
	   wait;    
	end process;
	
	resultfile: process(clk)
	   file result_file: text;
	   variable line_contents: line;
	   variable open_status: file_open_status;
	   variable r1, r2, r3, ro, i: integer;
	begin
	   r1 := to_integer(unsigned(opcode(9 downto 5)));
	   r2 := to_integer(unsigned(opcode(14 downto 10)));
	   r3 := to_integer(unsigned(opcode(19 downto 15)));
	   ro := to_integer(unsigned(rd));

	   if rising_edge(clk) then
		   if (clkcount < 68) then
		       file_open(open_status, result_file, outputfile, APPEND_MODE);
		       if(open_status = open_ok) then
		           write(line_contents, string'("====================="));
		           writeline(result_file, line_contents);
		           write(line_contents, string'("      Cycle " & integer'image(clkcount)));
		           writeline(result_file, line_contents);
		           write(line_contents, string'("====================="));
		           writeline(result_file, line_contents);
		           write(line_contents, string'(""));
		           writeline(result_file, line_contents);
		           write(line_contents, string'("||             STAGE 1 - FETCH            ||             STAGE 2 - DECODE            ||                               STAGE 3 - EXECUTE                              ||           STAGE 4 - WRITEBACK           ||"));
		           writeline(result_file, line_contents);
		           write(line_contents, string'("||========================================||=========================================||==============================================================================||=========================================||"));
		           writeline(result_file, line_contents);
		           write(line_contents, string'("|| instruction: " & to_hstring(instr) & "                   || opcode: " & to_hstring(opcode) & "                         || function: " & to_hstring(func) & "                                                            || field: " & to_hstring(field) & "                          ||"));
		           writeline(result_file, line_contents);																																																			    
		           write(line_contents, string'("||                                        || R[" & to_dstring(r1, 2, RIGHT, ZEROFILL) & "]: " & to_hstring(rs1_data) & " || M1: " & to_hstring(mux_data1) & " || A1: " & to_hstring(alu_in1) & " || WE: " & to_string(WE) & "                                   ||"));
		           writeline(result_file, line_contents);
		           write(line_contents, string'("||                                        || R[" & to_dstring(r2, 2, RIGHT, ZEROFILL) & "]: " & to_hstring(rs2_data) & " || M2: " & to_hstring(mux_data2) & " || A2: " & to_hstring(alu_in2) & " || RD: " & to_dstring(ro, 2, RIGHT, ZEROFILL) & "                                  ||"));
		           writeline(result_file, line_contents);
		           write(line_contents, string'("||                                        || R[" & to_dstring(r3, 2, RIGHT, ZEROFILL) & "]: " & to_hstring(rs3_data) & " || M3: " & to_hstring(mux_data3) & " || A3: " & to_hstring(alu_in3) & " || R[" & to_dstring(ro, 2, RIGHT, ZEROFILL) & "]: " & to_hstring(wb_data) & " ||"));
		           writeline(result_file, line_contents);
		           write(line_contents, string'("||                                        ||                                         || FD: " & to_hstring(wb_data) & " || AO: " & to_hstring(alu_out) & " ||                                         ||"));
		           writeline(result_file, line_contents);
		           write(line_contents, string'("||========================================||=========================================||==============================================================================||=========================================||"));
		           writeline(result_file, line_contents);
		           write(line_contents, string'("     R[RS] = RS DATA     M = MUX INPUT DATA     FD = FORWARD DATA      A = ALU INPUT DATA     AO = ALU OUTPUT     WE = WRITE ENABLE     RD = WRITE DESTINATION     R[RD] = WRITE DATA"));
		           writeline(result_file, line_contents);
		           write(line_contents, string'(""));
		           writeline(result_file, line_contents);
		           write(line_contents, string'(""));
		           writeline(result_file, line_contents);
		           write(line_contents, string'(""));
		           writeline(result_file, line_contents);
		       else
		           report "File could not be opened" severity error;
		       end if;
			   file_close(result_file);
			end if;
	   end if;
	end process;
	
	process(clkcount) 
	 file result_file: text;
	   variable line_contents: line;
	   variable open_status: file_open_status;
	   variable i: integer;
	begin
		if (clkcount = 68) then
			file_open(open_status, result_file, outputfile, APPEND_MODE);
		   	if(open_status = open_ok) then
					   i := 0;
				   write(line_contents, string'("R"&integer'image(i) & "  " & to_hstring(r0) ));
				   writeline(result_file, line_contents);
				   i := i + 1;

				   write(line_contents, string'("R"&integer'image(i) & "  " & to_hstring(r1) ));
				   writeline(result_file, line_contents);  i := i + 1;					   
				   write(line_contents, string'("R"&integer'image(i) & "  " & to_hstring(r2) ));
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & "  " & to_hstring(r3) ));
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & "  " & to_hstring(r4) ) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & "  " & to_hstring(r5) ) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & "  " & to_hstring(r6) ) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & "  " & to_hstring(r7) ) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & "  " & to_hstring(r8) ) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & "  " & to_hstring(r9) ) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r10) ) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r11) ) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r12)) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r13)) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r14)) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r15)) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r16)) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r17)) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r18)) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r19)) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r20)) );
				   writeline(result_file, line_contents);  i := i + 1;
				   
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r21)) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r22)) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r23)) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r24)) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r25)) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r26)) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r27)) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r28)) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r29)) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r30) ) );
				   writeline(result_file, line_contents);  i := i + 1;
				   write(line_contents, string'("R"&integer'image(i) & " " & to_hstring(r31) ) );
				   writeline(result_file, line_contents);  i := i + 1;
		   else
			   report "File could not be opened" severity error;
		   end if;
		   file_close(result_file);
	   end if;
	end process;   
end behavioral;