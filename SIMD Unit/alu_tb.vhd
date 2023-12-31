----------------------------------------------------------------------------------
-- Company: Stony Brook University - ESE 345 Computer Architecture
-- Engineers: Kyle Han and Summer Wang
-- 
-- Create Date: 10/24/2023 11:34:21 PM
-- Design Name: 
-- Module Name: ALU_TB - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
use work.all; 
use std.env.finish;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU_TB is
    generic(n: integer := 16;
            registerLength: integer := 128);
end ALU_TB;

architecture Behavioral of ALU_TB is
    -- Control Signals - Necessary for process to show us the output on the graph
    signal clk: std_logic := '0';
    -- Stimulus signals - signals mapped to the input and inout ports of tested entity
    signal wordIn: STD_LOGIC_VECTOR (24 downto 0);
    signal rs3: std_logic_vector(registerLength-1 downto 0);
    signal rs2: std_logic_vector(registerLength-1 downto 0);
    signal rs1: std_logic_vector(registerLength-1 downto 0);
    -- Observed signals - signals mapped to the output ports of tested entity
    signal rd: STD_LOGIC_VECTOR (127 downto 0);
begin
    UUT: entity ALU
        generic map (n => n,
                    registerLength => registerLength
        )
                    
        port map(wordIn => wordIn,
                rs3 => rs3,
                rs2 => rs2,
                rs1 => rs1,
                rd => rd);
        
        testing: process
        begin		   
			
			--Testing for R4 Instruction: intMulAddLo
			-- wordIn is 1 0 000 00000 00000 00000 00000
			
			--0th
			--Set the 0th set of 32 bits of rs1 to 3  
			--Set the 0th set of 32 bits of rs2 to 5 
			--Set the 0th set of 32 bits of rs3 to 5
			--That is: (5*5) + 3 = 28, which is 0x0_001C
			
			--1st
			--Testing the overflow portion
			--Set the 1st set of 32 bits of rs1 to 0x7FFF_FFFC, the hightest 32 bit number - 3
			--Set the 1st set of 16 bits of rs2 to 0x7FFF, the highest 16 bit 
			--Set the 1st set of 16 bits of rs3 to 0x0002, 2
			--That is: (32,767*2) = 65,534 + 4,294,967,296 = 4,295,032,830, which overflowed
			--Therefore, saturation should set it at 0x7FFF_FFFF
			
			--2nd
			--Testing the normal operation
			--Set the 1st set of 32 bits of rs1 to 0x1000_0000, the lowest 32 bit number
			--Set the 1st set of 16 bits of rs2 to 0x0000, 0 
			--Set the 1st set of 16 bits of rs3 to 0x0000, 0
			--That is: (0*0) = 0 - 4,294,967,296 = -4,294,967,296, or 0x1000_0000
			
			--3rd
			--Testing the underflow operation
			--Set the 1st set of 32 bits of rs1 to 0x8000_0000, the lowest 32 bit number
			--Set the 1st set of 16 bits of rs2 to 0x8000, The lowest 16 bit number 
			--Set the 1st set of 16 bits of rs3 to 0x7FFF, The Highest 16 bit number
			--That is: (32,767*-32,768) = -1,073,709,056 - 2147483647 = Saturate to 8000_0000

			wordIn <= "1000000000000000000000000";
			rs1 <= X"80000000100000007FFFFFFC00000003";
			rs2 <= X"000080000000000000007FFF00000005";
			rs3 <= X"00007FFF000000000000000200000005"; 
			
			wait for 10 ns;
			
			--Testing for R4 Instruction: intMulAddHi
			-- wordIn is 1 0 001 00000 00000 00000 00000
			
			--0th
			--Set the 0th set of 32 bits of rs1 to 3  
			--Set the 0th set of 32 bits of rs2 to 5 
			--Set the 0th set of 32 bits of rs3 to 5
			--That is: (5*5) + 3 = 28, which is 0x0_001C
			
			--1st
			--Testing the overflow portion
			--Set the 1st set of 32 bits of rs1 to 0x7FFF_FFFC, the hightest 32 bit number - 3
			--Set the 1st set of 16 bits of rs2 to 0x7FFF, the highest 16 bit 
			--Set the 1st set of 16 bits of rs3 to 0x0002, 2
			--That is: (32,767*2) = 65,534 + 4,294,967,296 = 4,295,032,830, which overflowed
			--Therefore, saturation should set it at 0x7FFF_FFFF
			
			--2nd
			--Testing the normal operation
			--Set the 1st set of 32 bits of rs1 to 0x1000_0000, the lowest 32 bit number
			--Set the 1st set of 16 bits of rs2 to 0x0000, 0 
			--Set the 1st set of 16 bits of rs3 to 0x0000, 0
			--That is: (0*0) = 0 - 4,294,967,296 = -4,294,967,296, or 0x1000_0000
			
			--3rd
			--Testing the underflow operation
			--Set the 1st set of 32 bits of rs1 to 0x8000_0000, the lowest 32 bit number
			--Set the 1st set of 16 bits of rs2 to 0x8000, The lowest 16 bit number 
			--Set the 1st set of 16 bits of rs3 to 0x7FFF, The Highest 16 bit number
			--That is: (32,767*-32,768) = -1,073,709,056 - 2147483647 = Saturate to 8000_0000

			wordIn <= "1000100000000000000000000";
			rs1 <= X"80000000100000007FFFFFFC00000003";
			rs2 <= X"80000000000000007FFF000000050000";
			rs3 <= X"7FFF0000000000000002000000050000"; 
			
			wait for 10 ns;
			
			--Testing for R4 Instruction: intMulSubLo
			-- wordIn is 1 0 010 00000 00000 00000 00000
			
			--0th
			--Set the 0th set of 32 bits of rs1 to 3  
			--Set the 0th set of 32 bits of rs2 to 5 
			--Set the 0th set of 32 bits of rs3 to 5
			--That is: (5*5) - 3 = 22, which is 0b1_0110
			
			--1st
			--Testing the Underflow portion
			--Set the 1st set of 32 bits of rs1 to 0x7FFF_FFFF, the highest 32 bit number
			--Set the 1st set of 16 bits of rs2 to 0x0001, 1 
			--Set the 1st set of 16 bits of rs3 to 0x8000, The lowest 16 bit number
			--That is: (-32,768*1) = -32768 - 2,147,483,647 = -2,147,516,415, which underflowed
			--Therefore, saturation should set it at 0x8000_0000
			
			--2nd
			--Testing the Overflow operation
			--Set the 1st set of 32 bits of rs1 to 0x8000_0000, the lowest 32 bit number
			--Set the 1st set of 16 bits of rs2 to 0x7FFF, the highest 16 bit 
			--Set the 1st set of 16 bits of rs3 to 0x7FFF, the highest 16 bit
			--That is: (32,767*32,767) = 1,073,676,289 - -2,147,483,648 = 3,221,159,937, which overflowed
			--Therefore, saturation should set it at 0x7FFF_FFFF
			
			--3rd
			--Testing the Overflow operation
			--Testing the Overflow operation
			--Set the 1st set of 32 bits of rs1 to 0x8000_0000, the lowest 32 bit number
			--Set the 1st set of 16 bits of rs2 to 0x7FFF, the highest 16 bit 
			--Set the 1st set of 16 bits of rs3 to 0x7FFF, the highest 16 bit
			--That is: (32,767*32,767) = 1,073,676,289 - -2,147,483,648 = 3,221,159,937, which overflowed
			--Therefore, saturation should set it at 0x7FFF_FFFF
			wordIn <= "1001000000000000000000000";
			rs1 <= X"80000000800000007FFFFFFF00000003";
			rs2 <= X"00007FFF00007FFF0000000100000005";
			rs3 <= X"00007FFF00007FFF0000800000000005"; 
			
			wait for 10 ns;
			
			--Testing for R4 Instruction: intMulSubHi
			-- wordIn is 1 0 011 00000 00000 00000 00000
			
			--0th
			--Set the 0th set of 32 bits of rs1 to 3  
			--Set the 0th set of 32 bits of rs2 to 5 
			--Set the 0th set of 32 bits of rs3 to 5
			--That is: (5*5) - 3 = 22, which is 0x0000_0016
			
			--1st
			--Testing the Underflow portion
			--Set the 1st set of 32 bits of rs1 to 0x7FFF_FFFF, the highest 32 bit number
			--Set the 1st set of 16 bits of rs2 to 0x0001, 1 
			--Set the 1st set of 16 bits of rs3 to 0x8000, The lowest 16 bit number
			--That is: (-32,768*1) = -32768 - 2,147,483,647 = -2,147,516,415, which underflowed
			--Therefore, saturation should set it at 0x8000_0000
			
			--2nd
			--Testing the Overflow operation
			--Set the 1st set of 32 bits of rs1 to 0x8000_0000, the lowest 32 bit number
			--Set the 1st set of 16 bits of rs2 to 0x7FFF, the highest 16 bit 
			--Set the 1st set of 16 bits of rs3 to 0x7FFF, the highest 16 bit
			--That is: (32,767*32,767) = 1,073,676,289 - -2,147,483,648 = 3,221,159,937, which overflowed
			--Therefore, saturation should set it at 0x7FFF_FFFF
			
			--3rd
			--Testing the Overflow operation
			--Testing the Overflow operation
			--Set the 1st set of 32 bits of rs1 to 0x8000_0000, the lowest 32 bit number
			--Set the 1st set of 16 bits of rs2 to 0x7FFF, the highest 16 bit 
			--Set the 1st set of 16 bits of rs3 to 0x7FFF, the highest 16 bit
			--That is: (32,767*32,767) = 1,073,676,289 - -2,147,483,648 = 3,221,159,937, which overflowed
			--Therefore, saturation should set it at 0x7FFF_FFFF
			wordIn <= "1001100000000000000000000";
			rs1 <= X"80000000800000007FFFFFFF00000003";
			rs2 <= X"7FFF00007FFF00000001000000050000";
			rs3 <= X"7FFF00007FFF00008000000000050000"; 
			
			wait for 10 ns;
			
			--Testing for R4 Instruction: longMulAddLo
			-- wordIn is 1 0 100 00000 00000 00000 00000
			
			--0th
			--Overflow Operation
			--Set the 0th set of 64 bits of rs1 to 0x7FFF_FFFF_FFFF_FFFF, the highest 64 bit number 
			--Set the 0th set of 32 bits of rs2 to 0x7FFF_FFFF 
			--Set the 0th set of 32 bits of rs3 to 0x7FFF_FFFF
			--This should cap out at 0x7FFF_FFFF_FFFF_FFFF
			
			--1st
			--Testing the Underflow portion
			--Set the 1st set of 32 bits of rs1 to 0x8000_0000_0000_0000, the lowest 64 bit number
			--Set the 1st set of 16 bits of rs2 to 0x8000_0000, The lowest 32 bit number
			--Set the 1st set of 16 bits of rs3 to 0x7FFF_FFFF, The highest 32 bit number
			--This should saturate at 0x8000_0000_0000_0000
			wordIn <= "1010000000000000000000000";
			rs1 <= X"80000000000000007FFFFFFFFFFFFFFF";
			rs2 <= X"0000000080000000000000007FFFFFFF";
			rs3 <= X"000000007FFFFFFF000000007FFFFFFF"; 
			
			wait for 10 ns;
			
			--Testing for R4 Instruction: longMulAddLo
			-- wordIn is 1 0 100 00000 00000 00000 00000
			
			--0th
			--Normal Operation
			--Set the 1st set of 64 bits of rs1 to 0x0000_0000_000F_4240, the lowest 64 bit number
			--Set the 1st set of 32 bits of rs2 to 0x7FFF_FFFF, The highest 32 bit number
			--Set the 1st set of 32 bits of rs3 to 0x7FFF_FFFF, The highest 32 bit number
			--That is: (2147483647 * 2147483647) + 1000000 = 4,611,686,014,133,420,609
			--Expect: 3FFFFFFF000F4241
			
			--1st
			--Normal Operation
			--Set the 1st set of 64 bits of rs1 to 0x0000_0000_000F_4240, the lowest 64 bit number
			--Set the 1st set of 32 bits of rs2 to 0x7FFF_FFFF, The highest 32 bit number
			--Set the 1st set of 32 bits of rs3 to 0x7FFF_FFFF, The highest 32 bit number
			--That is: (2147483647 * 2147483647) + 1000000 = 4,611,686,014,133,420,609
			--Expect: 3FFFFFFF000F4241
			wordIn <= "1010000000000000000000000";
			rs1 <= X"00000000000F424000000000000F4240";
			rs2 <= X"000000007FFFFFFF000000007FFFFFFF";
			rs3 <= X"000000007FFFFFFF000000007FFFFFFF"; 
			
			wait for 10 ns;
			
			--Testing for R4 Instruction: longMulAddHi
			-- wordIn is 1 0 101 00000 00000 00000 00000
			
			--0th
			--Normal Operation
			--Set the 1st set of 64 bits of rs1 to 0x0000_0000_000F_4240, the lowest 64 bit number
			--Set the 1st set of 32 bits of rs2 to 0x7FFF_FFFF, The highest 32 bit number
			--Set the 1st set of 32 bits of rs3 to 0x7FFF_FFFF, The highest 32 bit number
			--That is: (2147483647 * 2147483647) + 1000000 = 4,611,686,014,133,420,609
			--Expect: 3FFFFFFF000F4241
			
			--1st
			--Normal Operation
			--Set the 1st set of 64 bits of rs1 to 0x0000_0000_000F_4240, the lowest 64 bit number
			--Set the 1st set of 32 bits of rs2 to 0x7FFF_FFFF, The highest 32 bit number
			--Set the 1st set of 32 bits of rs3 to 0x7FFF_FFFF, The highest 32 bit number
			--That is: (2147483647 * 2147483647) + 1000000 = 4,611,686,014,133,420,609
			--Expect: 3FFFFFFF000F4241
			wordIn <= "1010100000000000000000000";
			rs1 <= X"00000000000F424000000000000F4240";
			rs2 <= X"7FFFFFFF000000007FFFFFFF00000000";
			rs3 <= X"7FFFFFFF000000007FFFFFFF00000000"; 
			
			wait for 10 ns;
			
			--Testing for R4 Instruction: longMulAddHi
			-- wordIn is 1 0 101 00000 00000 00000 00000
			
			--0th
			--Overflow Operation
			--Set the 0th set of 64 bits of rs1 to 0x7FFF_FFFF_FFFF_FFFF, the highest 64 bit number 
			--Set the 0th set of 32 bits of rs2 to 0x7FFF_FFFF 
			--Set the 0th set of 32 bits of rs3 to 0x7FFF_FFFF
			--This should cap out at 0x7FFF_FFFF_FFFF_FFFF
			
			--1st
			--Testing the Underflow portion
			--Set the 1st set of 32 bits of rs1 to 0x8000_0000_0000_0000, the lowest 64 bit number
			--Set the 1st set of 16 bits of rs2 to 0x8000_0000, The lowest 32 bit number
			--Set the 1st set of 16 bits of rs3 to 0x7FFF_FFFF, The highest 32 bit number
			--This should saturate at 0x8000_0000_0000_0000
			wordIn <= "1010100000000000000000000";
			rs1 <= X"80000000000000007FFFFFFFFFFFFFFF";
			rs2 <= X"80000000000000007FFFFFFF00000000";
			rs3 <= X"7FFFFFFF000000007FFFFFFF00000000"; 
			
			wait for 10 ns;
			
			--Testing for R4 Instruction: longMulSubLo
			-- wordIn is 1 0 110 00000 00000 00000 00000
			
			--0th
			--Normal Operation
			--Set the 0th set of 64 bits of rs1 to 0x7FFF_FFFF_FFFF_FFFF, the highest 64 bit number 
			--Set the 0th set of 32 bits of rs2 to 0x7FFF_FFFF 
			--Set the 0th set of 32 bits of rs3 to 0x7FFF_FFFF
			--This should result in 0x4000 0000 8000 0000
			
			--1st
			--Testing the Normal operation
			--Set the 1st set of 32 bits of rs1 to 0x8000_0000_0000_0000, the lowest 64 bit number
			--Set the 1st set of 16 bits of rs2 to 0x8000_0000, The lowest 32 bit number
			--Set the 1st set of 16 bits of rs3 to 0x7FFF_FFFF, The highest 32 bit number
			--This should result in to 0xBFFF FFFF 0000 0002
			wordIn <= "1011000000000000000000000";
			rs1 <= X"80000000000000007FFFFFFFFFFFFFFF";
			rs2 <= X"0000000080000000000000007FFFFFFF";
			rs3 <= X"000000007FFFFFFF000000007FFFFFFF"; 
			
			wait for 10 ns;
			
			--Testing for R4 Instruction: longMulSubLo
			-- wordIn is 1 0 110 00000 00000 00000 00000
			
			--0th
			--Overflow Operation
			--Set the 0th set of 64 bits of rs1 to 0x8000_0000_0000_0000, the lowest 64 bit number 
			--Set the 0th set of 32 bits of rs2 to 0x7FFF_FFFF 
			--Set the 0th set of 32 bits of rs3 to 0x7FFF_FFFF
			--This should result in 0x7FFF_FFFF_FFFF_FFFF
			
			--1st
			--Testing the Underflow Operation
			--Set the 1st set of 32 bits of rs1 to 0x7FFF_FFFF_FFFF_FFFF, the highest 64 bit number
			--Set the 1st set of 16 bits of rs2 to 0x8000_0000, The lowest 32 bit number
			--Set the 1st set of 16 bits of rs3 to 0x7FFF_FFFF, The highest 32 bit number
			--This should saturate to 0x8000 0000 0000 0000
			wordIn <= "1011000000000000000000000";
			rs1 <= X"7FFFFFFFFFFFFFFF8000000000000000";
			rs2 <= X"0000000080000000000000007FFFFFFF";
			rs3 <= X"000000007FFFFFFF000000007FFFFFFF"; 
			
			wait for 10 ns;
			
			--Testing for R4 Instruction: longMulSubHi
			-- wordIn is 1 0 111 00000 00000 00000 00000
			
			--0th
			--Normal Operation
			--Set the 1st set of 64 bits of rs1 to 0x0000_0000_000F_4240, the lowest 64 bit number
			--Set the 1st set of 32 bits of rs2 to 0x7FFF_FFFF, The highest 32 bit number
			--Set the 1st set of 32 bits of rs3 to 0x7FFF_FFFF, The highest 32 bit number
			--That is: (2147483647 * 2147483647) - 1000000 = 4,611,686,014,133,420,609
			--Expect: 3FFFFFFF000F4241
			
			--1st
			--Normal Operation
			--Set the 1st set of 64 bits of rs1 to 0x0000_0000_000F_4240, the lowest 64 bit number
			--Set the 1st set of 32 bits of rs2 to 0x7FFF_FFFF, The highest 32 bit number
			--Set the 1st set of 32 bits of rs3 to 0x7FFF_FFFF, The highest 32 bit number
			--That is: (2147483647 * 2147483647) - 1000000 = 4,611,686,014,133,420,609
			--Expect: 3FFFFFFF000F4241
			wordIn <= "1011100000000000000000000";
			rs1 <= X"00000000000F424000000000000F4240";
			rs2 <= X"7FFFFFFF000000007FFFFFFF00000000";
			rs3 <= X"7FFFFFFF000000007FFFFFFF00000000"; 
			
			wait for 10 ns;
			
			--Testing for R4 Instruction: longMulSubHi
			-- wordIn is 1 0 111 00000 00000 00000 00000
			
			--0th
			--Overflow Operation
			--Set the 0th set of 64 bits of rs1 to 0x8000_0000_0000_0000, the lowest 64 bit number 
			--Set the 0th set of 32 bits of rs2 to 0x7FFF_FFFF 
			--Set the 0th set of 32 bits of rs3 to 0x7FFF_FFFF
			--This should result in 0x7FFF_FFFF_FFFF_FFFF
			
			--1st
			--Testing the Underflow Operation
			--Set the 1st set of 32 bits of rs1 to 0x7FFF_FFFF_FFFF_FFFF, the highest 64 bit number
			--Set the 1st set of 16 bits of rs2 to 0x8000_0000, The lowest 32 bit number
			--Set the 1st set of 16 bits of rs3 to 0x7FFF_FFFF, The highest 32 bit number
			--This should saturate to 0x8000 0000 0000 0000
			wordIn <= "1011100000000000000000000";
			rs1 <= X"7FFFFFFFFFFFFFFF8000000000000000";
			rs2 <= X"80000000000000007FFFFFFF00000000";
			rs3 <= X"7FFFFFFF000000007FFFFFFF00000000"; 
		
			wait for 10 ns;	  
			
			--DONE! Testing for 0000 NOP			   
			-- wordIn is 1 1 0000 0000 00000 00000 00000
			--No matter what the register values are, we should output 0s
			--This will be taken care of by the register file, not the ALU.
			wordIn <= "1100000000000000000000000";
			wait for 10 ns;
			
			--DONE! Testing for 0001 SHRHI			   
			-- wordIn is 1 1 0000 0001 00001 00000 00000
			--Shift right by 1
			wordIn <= "1100000001000010000000000";
			rs1 <= X"12340000234500000000000023451234";
			wait for 10 ns;
			
			--DONE! Testing for 0001 SHRHI
			-- wordIn is 1 1 0000 0001 00100 00000 00000
			--Shift right by 4
			wordIn <= "1100000001001000000000000";
			rs1 <= X"12340000234500002350009023451234";
			wait for 10 ns;
			
			--DONE! test again rotate right 8 digits
			-- wordIn is 1 1 0000 0001 01000 00000 00000
			-- Shift right by 8
			-- Expected rd = "FFFF0000 11A28000 00000000 0FFFFFFF"
			wordIn <= "1100000001010000000000000";
			rs1 <= X"FFFE000023450000000000001FFFFFFF";
			wait for 10 ns;
			
			--DONE Testing for 0010 AU - add word unsigned
			-- wordIn is 1 1 0000 0010 00000 00000 00000
			-- Expect rd = "CA864202 00000000 7FFFFFFF 001B4240"
			wordIn <= "1100000010000000000000000";		 --regular case, do not overflow
			rs1 <= X"654321010000000000000000000F4240";
			rs2 <= X"65432101000000007FFFFFFF000C0000";
			wait for 10 ns;

			
			--DONE Testing for 0011 CNT1H - count 1s in halfword
			-- wordIn is 1 1 0000 0011 00000 00000 00000
			-- Expect rd = "0004 0000 0004 0002 0000 0000 0004 0003"	 "4 0 4 2 0 0 4 3"
			wordIn <= "1100000011000000000000000";
			rs1 <= X"F0000000000F404000000000000F4240";	 --
			rs2 <= X"F0000000000000000000000000000000";	 --r2 not used but put in a 1 to see if that messes up with output
			wait for 10 ns;
			
			--DONE Testing for 0100 AHS - add halfword saturated saturated
			-- wordIn is 1 1 0000 0100 00000 00000 00000
			--0th
			--Normal Operation
			--Set zeroth set of rs2 to 0x1AB5, which is 6,837
			--Set zeroth set of rs1 to 0x9263, which is 37475
			--Answer should be placed in zeroth 16 bits of rd
			--Answer is 44,312, answer is 0xAD18
			
			--1st
			--Underflow Operation
			--Set last set of rs2 to 0x8000, which is most negative number
			--Set last set of rs1 to 0x8000, which is most negative number
			--Answer should underflow - 16 bits can't get more negative than 8000
			--Answer should 0x8000
			
			--2nd
			--Overflow Condition
			--Set 2nd set of rs2 to 0x7FFF, which is most postive number
			--Set 2nd set of rs1 to 0x0005, which is 5
			--Answer should be placed in last 16 bits of rd
			--Answer should overflow - you can't get anymore positive
			--Saturation will kick in, answer is 0x7FFF
			
			--3rd
			--Normal Operation
			--Set 3rd set of rs2 to 0x0005, which is dec 5
			--Set 3rd set of rs1 to 0x0007, which is dec 7
			--Answer should be placed in last 16 bits of rd
			--Answer is 12, which is 000C  
			
			--Repeat for index 4 to 7
			wordIn <= "1100000100000000000000000";						 
			rs1 <= X"00070005800092630007000580009263";
			rs2 <= X"00057FFF80001AB500057FFF80001AB5";
			wait for 10 ns;
			
			
			--Testing for 0101 bitwiseOR
			--Set the first 32 bits of rs1 to 1, then others to 0  
			--Set the last 32 bits of rs2 to 1, then others to 0 
			-- wordIn is 1 1 0000 0101 00000 00000 00000
			wordIn <= "1100000101000000000000000";
			rs1 <= (100 downto 80 => '1', others => '0');
			rs2 <= (90 downto 50 => '1', others => '0');  
			
			
			wait for 10 ns;
			
			--DONE Testing for 0110 BCW - broadcast word
			-- wordIn is 1 1 0000 0110 00000 00000 00000
			-- Expect rd = "123F 4240 123F 4240 123F 4240 123F 4240"		
			wordIn <= "1100000110000000000000000";
			rs1 <= X"F0000000000F404000000000123F4240";	-- only the LSB 8 hex # matter
			rs2 <= X"10000000000000000000000000000000";
			wait for 10 ns;
			
			--DONE Testing for 0111 MAXWS - max signed word
			-- wordIn is 1 1 0000 0111 00000 00000 00000
			-- Expect rd = "123F 4240 000F 4040 123F 4240 123F 4240"		
			wordIn <= "1100000111000000000000000";
			rs1 <= X"F000000F000F40400000000000020000";
			rs2 <= X"123F424000000000123F4240123F4240";
			wait for 10 ns;	
				
			--DONE Testing for 1000 MINWS - min signed word
			-- wordIn is 1 1 0000 1000 00000 00000 00000
			-- Expect rd = "F000 0000 F000 0000 F000 0000 F000 0000"					
			wordIn <= "1100001000000000000000000";
			rs1 <= X"F000000000000000F0000000F0000000";
			rs2 <= X"10000000F00000001000000000000000";
			wait for 10 ns;	
		
			--DONE Testing for 1001 MLHU - multiply low unsigned
			-- wordIn is 1 1 0000 1001 00000 00000 00000
			
			--0th
			--3*3 = 9
			
			--1st
			--104 * 2 = 208 [Hex]
			--260 * 2 = 520 [Dec]
			
			--2nd
			--4040 * FFFF =	1043F3BBFC0	     [Hex]
			--16448 * 65535 = 1,077,919,680  [Dec]
			
			--3rd
			--FFFF * 0001 = FFFF [Hex]
			--65535 * 1 = 65535  [Dec]
			wordIn <= "1100001001000000000000000";
			rs1 <= X"FF00FFFF000F40400000010400000003";
			rs2 <= X"110000010000FFFF0000000200000003";
			wait for 10 ns;	
			wordIn <= "1000001001000000000000000";
			wait for 10ns;
			
			--Testing for 1010 MLHSS - multiply by sign saturated
			-- wordIn is 1 1 0000 1010 00000 00000 00000   1850000
			-- when a 16-bit field of rs2 = 0, rd outputs 0 for that field.
			-- Expected Rd = "8000 0000 0000 0000 0000 0000 0000 0000"
			
			--0th
			-- 3*-1 = -3
			-- 3*8000 = FFFD	[hex]
			
			--1st
			-- -3 * -1 = 3
			-- FFFD * 8000 = 3 [Hex]
			
			--2nd
			--saturate
			-- 8000 * 8000 =	7FFF [Hex]
			-- -32768 * -1 = 32767  [Dec]
			
			--3rd
			--7FFF * 0001 = 7FFF [Hex]
			-- 32767 * 1 = 32767  [Dec]
			
			--4th
			-- C56A * 0001 = C56A [Hex]
			-- -14998 * 1 = -14998  [Dec]
			
			--5th
			-- 5136 * 5691 = 5136 [Hex]
			-- 5430 * 1 = 5430  [Dec]
			
			--6th
			-- C56A * 8000 = 3A96 [Hex]
			-- -14998 * -1 = 14998  [Dec]
			
			--7th
			--FFFF * 0001 = FFFF[Hex]
			-- -1 * 1 = -1  [Dec]
			wordIn <= "1100001010000000000000000";
			rs1 <= X"FFFFC56A5136C56A7FFF8000FFFD0003";	 --	
			rs2 <= X"00018000569100010001800080008000";
			wait for 10 ns;
			
			--Testing for ROTW
			--Set the first 32 bits of rs1 to 1, then others to 0  
			--Set the last 32 bits of rs2 to 1, then others to 0 
			-- wordIn is 1 1 0000 1101 00000 00000 00000
			--RS2 is hexadecimal "00000001 | 00000002 | 00000003 | 00000004"
			wordIn <= "1100001101000000000000000";
			rs1 <= X"0123456789ABCDEF0123456789ABCDEF";
			rs2 <= X"0000000400000003000000040000001F";
			
			wait for 10 ns;
			
			
            -- Testing the load immediate Function
            -- wordIn can be something like 0 001 0000 1111 0000 1111 00000
            -- This will load 0x0F0F into the second 16 bits of register rd
            wordIn <= "0001000011110000111100000";
            
            wait for 10 ns;
            
            -- Testing the load immediate Function
            -- wordIn can be something like 0 010 1100111100101111 00000
            -- This will load 0xCF2F into the third 16 bits of register rd
            wordIn <= "0010110011110010111100000"; 
			
			wait for 10 ns;		
			
			-- Testing the load immediate Function
            -- wordIn can be something like 0 000 1100000000100011 00000
            -- This will load 0xC023 into the last 16 bits of register rd
            wordIn <= "0000010000000010001100000"; 
			
			wait for 10 ns;		
			
			--Testing for bitwiseOR
			--Set the first 32 bits of rs1 to 1, then others to 0  
			--Set the last 32 bits of rs2 to 1, then others to 0 
			-- wordIn is 1 1 0000 0101 00000 00000 00000
			wordIn <= "1100000101000000000000000";
			rs1 <= (127 downto 95 => '1', others => '0');
			rs2 <= (31 downto 0 => '1', others => '0');  
			
			
			wait for 10 ns;	
			
			--Testing for bitwiseAND
			--Set the first 32 bits of rs1 to 1, then others to 0  
			--Set the last 32 bits of rs2 to 1, then others to 0 
			-- wordIn is 1 1 0000 1011 00000 00000 00000
			wordIn <= "1100001011000000000000000";
			rs1 <= (127 downto 95 => '1', others => '0');
			rs2 <= (100 downto 80 => '1', others => '0');
			
			wait for 10 ns;
			
			--Testing for INVB
			--Set the rs1 to all F
			-- wordIn is 1 1 0000 1100 00000 00000 00000
			wordIn <= "1100001100000000000000000";
			rs1 <= (127 downto 0 => '1', others => '0');
			
			wait for 10 ns;	
			
			--Testing for INVB
			--Set the rs1 to all 0
			-- wordIn is 1 1 0000 1100 00000 00000 00000
			wordIn <= "1100001100000000000000000";
			rs1 <= (others => '0');
			
			wait for 10 ns;
			
			--Testing for SFWU
			-- wordIn is 1 1 0000 1110 00000 00000 00000
				
			--0th
			--Set 0th set of rs1 to 0x0100_0000, which is dec 16,777,216
			--Set 0th set of rs2 to 0x1000_0000, which is dec 268,435,456
			--Answer should be placed in last 32 bits of rd
			--Answer is 0x0F00_0000, or 251,658,240
			
			--1st
			--Testing edge case for SFWU
			--Set last set of rs2 to 0x0000_0005, which is dec 5
			--Set last set of rs1 to 0x0000_0007, which is dec 7
			--Answer should be placed in last 32 bits of rd
			--Answer is negative when done in decimal.
			--Answer is should underflow to FFFF_FFFE
			
			--3rd
			--Set last set of rs2 to 0xFFFF_FFFF, which is dec 4,294,967,295
			--Set last set of rs1 to 0x0000_1CF3, which is dec 7,411
			--Answer is negative when done in decimal.
			--Answer is should underflow to FFFF_E30C
			
			--4th
			--Testing edge case for SFWU
			--Set last set of rs2 to 0x1000_0000, which is dec 16,777,216
			--Set last set of rs1 to 0x0100_0000, which is dec 268,435,456
			--Answer should be placed in last 32 bits of rd.
			--Answer is 0x0F00_0000, or 251,658,240
			
			wordIn <= "1100001110000000000000000";
			rs1 <= X"00000000000000000000000700000002";
			rs2 <= X"00000000000000000000000500000005";  
			
			wait for 10 ns;
			
			
			--Testing for SFHS
			-- wordIn is 1 1 0000 1111 00000 00000 00000
			
			--0th
			--Underflow Condition
			--Set zeroth set of rs2 to 0x8000, which is most negative number
			--Set zeroth set of rs1 to 0x0001, which is 1
			--Answer should be placed in zeroth 16 bits of rd
			--Answer should underflow - you can't get any more negative
			--Saturation will kick in, answer is 0x8000
			
			--1st
			--Regular Operation
			--Set last set of rs2 to 0x8000, which is most negative number
			--Set last set of rs1 to 0x8000, which is most negative number
			--Answer should be placed in 1st 16 bits of rd
			--Answer should 0x0000
			
			--2nd
			--Overflow Condition
			--Set 2nd set of rs2 to 0x7FFF, which is most postive number
			--Set 2nd set of rs1 to 0x8000, which is most negative number
			--Answer should be placed in last 16 bits of rd
			--Answer should overflow - you can't get anymore positive
			--Saturation will kick in, answer is 0x7FFF
			
			--3rd
			--Normal Operation
			--Set 3rd set of rs2 to 0x0005, which is dec 5
			--Set 3rd set of rs1 to 0x0007, which is dec 7
			--Answer should be placed in last 16 bits of rd
			--Answer is -2, which is FFFE
			
			wordIn <= "1100001111000000000000000";
			rs1 <= X"00078000800000010007800080000001";
			rs2 <= X"00057FFF8000800000057FFF80008000"; 
			
			wait for 10 ns;
			
			finish;
        end process;
end Behavioral;