----------------------------------------------------------------------------------
-- Company: Stony Brook University - ESE 345 Computer Architecture
-- Engineers: Kyle Han and Summer Wang
-- 
-- Create Date: 10/17/2023 06:40:40 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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

--    There are 8 different 16 bit sections of the register Rd. 
--     +127-----112|111----96|95----80|79-----64|63-----48|47-----32|31-----16|15------0+
--     |      7         6        5         4         3          2          1        0   |
--     +--------------------------------------------------------------------------------+


--    There are 4 different 32 bit sections of the register Rd. 
--     +127--------96|95---------64|63---------32|31---------0+
--     |       3            2             1            0      |
--     +------------------------------------------------------+

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    generic(n: integer := 16;
            registerLength: integer := 128);
    Port ( wordIn : in STD_LOGIC_VECTOR (24 downto 0);
           rs3 : in STD_LOGIC_VECTOR (127 downto 0);
           rs2 : in STD_LOGIC_VECTOR (127 downto 0);
           rs1 : in STD_LOGIC_VECTOR (127 downto 0);
           rd : out STD_LOGIC_VECTOR (127 downto 0));
end ALU;


architecture Behavioral of ALU is


----------------------------Saturation Check Sub---------------------------------------
-- Saturation will check if the amount has overflowed. 
-- neg - neg can't overflow
-- pos - pos can't overflow
-- neg - pos may underflow
-- pos - neg may overflow 
-- To check if overflow: if the MSB of the result register (msbRd) is different than the MSB in the register msb2, it has over/underflowed
-- that is to say (3 bit) 011 - 100 = 101. 0 is in rs2, 1 is the msb of the rd. this has underflowed
-- (3 bit) 100 - 001 = (1)011. 1 of rd2

--Return 1 if over/underflow
--Return 0 if all good
	
--if (msb2, msbRd) = 10, underflow
--if (msb2, msbRd) = 01, overflow
	function saturationCheckSub(msb1: std_logic_vector(0 downto 0); msb2: std_logic_vector(0 downto 0); msbRd: std_logic_vector(0 downto 0)) return integer is
    	variable result : integer;
		begin
	    -- Check if msb1 is equal to msb2. If so, then exit with 0: function won't check.
	    if (msb1 = msb2) then
	        result := 0;
	    else
	        --Otherwise, check if the signs of msb2 and msbRd match
			--If they match, then there is no error. 
			--If they don't match, over/underflow
			if (msb2 = msbRd) then
				result := 0;	
			else
				result := 1;
			end if;
	    end if;
	    
	    return result;
	end function saturationCheckSub;
-------------------------------------------------------------------------------------

----------------------------Saturation Check Add---------------------------------------
-- Saturation will check if the amount has overflowed. 
-- neg + neg May overflow
-- pos + pos May overflow
-- neg + pos can't underflow
-- pos + neg can't overflow 
-- To check if overflow: if the MSB of the result register (msbRd) is different than the MSB in the register msb2, it has over/underflowed
-- that is to say (3 bit) 011 - 100 = 101. 0 is in rs2, 1 is the msb of the rd. this has underflowed
-- (3 bit) 100 - 001 = (1)011. 1 of rd2

--Return 1 if over/underflow
--Return 0 if all good
	
--if (msb2, msbRd) = 10, underflow
--if (msb2, msbRd) = 01, overflow
	function saturationCheckAdd(msb1: std_logic_vector(0 downto 0); msb2: std_logic_vector(0 downto 0); msbRd: std_logic_vector(0 downto 0)) return integer is
    	variable result : integer;
		begin
	    -- Check if msb1 is not equal to msb2. If so, then exit with 0: function won't check.
		--It was impossible to over/underflow
	    if (msb1 /= msb2) then
	        result := 0;
	    else
	        --Otherwise, check if the signs of msb2 and msbRd match
			--If they match, then there is no error. 
			--If they don't match, over/underflow
			if (msb2 = msbRd) then
				result := 0;	
			else
				result := 1;
			end if;
	    end if;
	    
	    return result;
	end function saturationCheckAdd;
-------------------------------------------------------------------------------------

---000-Signed Integer Multiply-Add Low with Saturation used in R4 instruction Type---
--The only real time you have to worry about saturation is after the addition/subtraction

	procedure intMulAddLo(signal r1, r2, r3: in std_logic_vector(registerLength-1 downto 0);
	signal rd: out std_logic_vector(registerLength-1 downto 0)) is
		variable wordIndex: integer;
		variable halfWord: integer := 16;
		variable wordLength: integer := 32;
		variable MSB, LSB: integer;
		variable var3: signed (halfWord-1 downto 0);
		variable var2: signed (halfWord-1 downto 0);
		variable resultMul: signed (wordLength-1 downto 0);
		variable resultAdd: signed (wordLength-1 downto 0);
		begin
			
			--0th Bit
			wordIndex := 0;
			LSB := registerLength * wordIndex / 4;
			MSB := (registerLength * wordIndex / 4) + halfWord - 1;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul + signed(r1 (MSB + halfWord downto LSB));
			
			--Then, we check for saturation
			if (saturationCheckAdd( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then
				--There are two ways to do this. Ultimately, the goal is to replace with 01111111... or 100000... First is to realize that the check of (msb2, msbRd), if different, gives you the
				--exact order that the over/underflow should be. Can either do directly, or with a reference.
				--if (msb2, msbRd) = 10, underflow rd <= 100000...
				--if (msb2, msbRd) = 01, overflow  rd <= 011111...
				
					
				--if (resultMul(wordLength -1) = '0' and resultAdd(wordLength -1) = '1') then
				--	rd( 62 downto 32) <= (others => '1');
				--	rd( 63) <= '0';
				--else
				--	rd( 62 downto 32) <= (others => '0');
				--	rd( 63) <= '1';
				--end if;
				
				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd(LSB + wordLength-1 downto LSB) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( LSB + wordLength-1 downto LSB ) <= std_logic_vector(resultAdd);
			end if;
			
			
			--1st Bit
			wordIndex := 1;
			LSB := registerLength * wordIndex / 4;
			MSB := (registerLength * wordIndex / 4) + halfWord - 1;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul + signed(r1 (MSB + halfWord downto LSB));
			
			--Then, we check for saturation
			if (saturationCheckAdd( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd(LSB + wordLength-1 downto LSB) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( LSB + wordLength-1 downto LSB ) <= std_logic_vector(resultAdd);
			end if;
			
			--2nd Bit
			wordIndex := 2;
			LSB := registerLength * wordIndex / 4;
			MSB := (registerLength * wordIndex / 4) + halfWord - 1;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul + signed(r1 (MSB + halfWord downto LSB));
			
			
			--Then, we check for saturation
			if (saturationCheckAdd( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd(LSB + wordLength-1 downto LSB) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( LSB + wordLength-1 downto LSB ) <= std_logic_vector(resultAdd);
			end if;
			
			--3rd Bit
			wordIndex := 3;
			LSB := registerLength * wordIndex / 4;
			MSB := (registerLength * wordIndex / 4) + halfWord - 1;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul + signed(r1 (MSB + halfWord downto LSB));
			
			--Then, we check for saturation
			if (saturationCheckAdd( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd(LSB + wordLength-1 downto LSB) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( LSB + wordLength-1 downto LSB ) <= std_logic_vector(resultAdd);
			end if;
			
			
			
			
			
	end intMulAddLo;
-------------------------------------------------------------------------------------

---001-Signed Integer Multiply-Add High with Saturation used in R4 instruction Type---
--The only real time you have to worry about saturation is after the addition/subtraction

	procedure intMulAddHi(signal r1, r2, r3: in std_logic_vector(registerLength-1 downto 0);
	signal rd: out std_logic_vector(registerLength-1 downto 0)) is
		variable wordIndex: integer;
		variable halfWord: integer := 16;
		variable wordLength: integer := 32;
		variable MSB, LSB: integer;
		variable var3: signed (halfWord-1 downto 0);
		variable var2: signed (halfWord-1 downto 0);
		variable resultMul: signed (wordLength-1 downto 0);
		variable resultAdd: signed (wordLength-1 downto 0);
		begin
			
			--0th Bit
			wordIndex := 0;
			LSB := (registerLength * wordIndex / 4)+16;
			MSB := ((registerLength * wordIndex / 4) + halfWord - 1)+16;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul + signed(r1 (MSB downto LSB - halfWord));
			--resultAdd := resultMul;
			--Then, we check for saturation
			if (saturationCheckAdd( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then
				--There are two ways to do this. Ultimately, the goal is to replace with 01111111... or 100000... First is to realize that the check of (msb2, msbRd), if different, gives you the
				--exact order that the over/underflow should be. Can either do directly, or with a reference.
				--if (msb2, msbRd) = 10, underflow rd <= 100000...
				--if (msb2, msbRd) = 01, overflow  rd <= 011111...
				
					
				--if (resultMul(wordLength -1) = '0' and resultAdd(wordLength -1) = '1') then
				--	rd( 62 downto 32) <= (others => '1');
				--	rd( 63) <= '0';
				--else
				--	rd( 62 downto 32) <= (others => '0');
				--	rd( 63) <= '1';
				--end if;
				
				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd(MSB downto LSB - halfWord) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( MSB downto MSB - wordLength+1) <= std_logic_vector(resultAdd);
			end if;
			
			
			--1st Bit
			wordIndex := 1;
			LSB := (registerLength * wordIndex / 4)+16;
			MSB := ((registerLength * wordIndex / 4) + halfWord - 1)+16;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul + signed(r1 (MSB downto LSB - halfWord));
			
			--Then, we check for saturation
			if (saturationCheckAdd( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd( MSB downto LSB - halfWord) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( MSB downto MSB - wordLength+1) <= std_logic_vector(resultAdd);
			end if;
			
			--2nd Bit
			wordIndex := 2;
			LSB := (registerLength * wordIndex / 4)+16;
			MSB := ((registerLength * wordIndex / 4) + halfWord - 1)+16;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul + signed(r1 (MSB downto LSB - halfWord));
			
			
			--Then, we check for saturation
			if (saturationCheckAdd( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd( MSB downto LSB - halfWord) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( MSB downto MSB - wordLength+1) <= std_logic_vector(resultAdd);
			end if;
			
			--3rd Bit
			wordIndex := 3;
			LSB := (registerLength * wordIndex / 4)+16;
			MSB := ((registerLength * wordIndex / 4) + halfWord - 1)+16;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul + signed(r1 (MSB downto LSB - halfWord));
			
			--Then, we check for saturation
			if (saturationCheckAdd( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd(MSB downto LSB - halfWord) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( MSB downto MSB - wordLength+1) <= std_logic_vector(resultAdd);
			end if;
			
			
			
			
			
	end intMulAddHi;
-------------------------------------------------------------------------------------


---010-Signed Integer Multiply-Sub Low with Saturation used in R4 instruction Type---
--The only real time you have to worry about saturation is after the addition/subtraction

	procedure intMulSubLo(signal r1, r2, r3: in std_logic_vector(registerLength-1 downto 0);
	signal rd: out std_logic_vector(registerLength-1 downto 0)) is
		variable wordIndex: integer;
		variable halfWord: integer := 16;
		variable wordLength: integer := 32;
		variable MSB, LSB: integer;
		variable var3: signed (halfWord-1 downto 0);
		variable var2: signed (halfWord-1 downto 0);
		variable resultMul: signed (wordLength-1 downto 0);
		variable resultAdd: signed (wordLength-1 downto 0);
		begin
			
			--0th Bit
			wordIndex := 0;
			LSB := registerLength * wordIndex / 4;
			MSB := (registerLength * wordIndex / 4) + halfWord - 1;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul - signed(r1 (MSB + halfWord downto LSB));
			
			--Then, we check for saturation
			if (saturationCheckSub( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then
				--There are two ways to do this. Ultimately, the goal is to replace with 01111111... or 100000... First is to realize that the check of (msb2, msbRd), if different, gives you the
				--exact order that the over/underflow should be. Can either do directly, or with a reference.
				--if (msb2, msbRd) = 10, underflow rd <= 100000...
				--if (msb2, msbRd) = 01, overflow  rd <= 011111...
				
					
				--if (resultMul(wordLength -1) = '0' and resultAdd(wordLength -1) = '1') then
				--	rd( 62 downto 32) <= (others => '1');
				--	rd( 63) <= '0';
				--else
				--	rd( 62 downto 32) <= (others => '0');
				--	rd( 63) <= '1';
				--end if;
				
				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd(LSB + wordLength-1 downto LSB) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( LSB + wordLength-1 downto LSB ) <= std_logic_vector(resultAdd);
			end if;
			
			
			--1st Bit
			wordIndex := 1;
			LSB := registerLength * wordIndex / 4;
			MSB := (registerLength * wordIndex / 4) + halfWord - 1;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul - signed(r1 (MSB + halfWord downto LSB));
			
			
			--Then, we check for saturation
			if (saturationCheckSub( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd(LSB + wordLength-1 downto LSB) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( LSB + wordLength-1 downto LSB ) <= std_logic_vector(resultAdd);
			end if;
			
			--2nd Bit
			wordIndex := 2;
			LSB := registerLength * wordIndex / 4;
			MSB := (registerLength * wordIndex / 4) + halfWord - 1;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul - signed(r1 (MSB + halfWord downto LSB));
			--resultAdd := signed(r1 (MSB + halfWord downto LSB));
			--resultAdd := resultMul;
			
			--Then, we check for saturation
			if (saturationCheckSub( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd(LSB + wordLength-1 downto LSB) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( LSB + wordLength-1 downto LSB ) <= std_logic_vector(resultAdd);
			end if;
			
			--3rd Bit
			wordIndex := 3;
			LSB := registerLength * wordIndex / 4;
			MSB := (registerLength * wordIndex / 4) + halfWord - 1;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul - signed(r1 (MSB + halfWord downto LSB));
			
			--Then, we check for saturation
			if (saturationCheckSub( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd(LSB + wordLength-1 downto LSB) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( LSB + wordLength-1 downto LSB ) <= std_logic_vector(resultAdd);
			end if;
			
			
			
			
			
	end intMulSubLo;
-------------------------------------------------------------------------------------
---011-Signed Integer Multiply-Sub High with Saturation used in R4 instruction Type---
--The only real time you have to worry about saturation is after the addition/subtraction

	procedure intMulSubHi(signal r1, r2, r3: in std_logic_vector(registerLength-1 downto 0);
	signal rd: out std_logic_vector(registerLength-1 downto 0)) is
		variable wordIndex: integer;
		variable halfWord: integer := 16;
		variable wordLength: integer := 32;
		variable MSB, LSB: integer;
		variable var3: signed (halfWord-1 downto 0);
		variable var2: signed (halfWord-1 downto 0);
		variable resultMul: signed (wordLength-1 downto 0);
		variable resultAdd: signed (wordLength-1 downto 0);
		begin
			
			--0th Bit
			wordIndex := 0;
			LSB := (registerLength * wordIndex / 4)+16;
			MSB := ((registerLength * wordIndex / 4) + halfWord - 1)+16;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul - signed(r1 (MSB downto LSB - halfWord));
			--resultAdd := resultMul;
			--Then, we check for saturation
			if (saturationCheckSub( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then
				--There are two ways to do this. Ultimately, the goal is to replace with 01111111... or 100000... First is to realize that the check of (msb2, msbRd), if different, gives you the
				--exact order that the over/underflow should be. Can either do directly, or with a reference.
				--if (msb2, msbRd) = 10, underflow rd <= 100000...
				--if (msb2, msbRd) = 01, overflow  rd <= 011111...
				
					
				--if (resultMul(wordLength -1) = '0' and resultAdd(wordLength -1) = '1') then
				--	rd( 62 downto 32) <= (others => '1');
				--	rd( 63) <= '0';
				--else
				--	rd( 62 downto 32) <= (others => '0');
				--	rd( 63) <= '1';
				--end if;
				
				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd(MSB downto LSB - halfWord) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( MSB downto MSB - wordLength+1) <= std_logic_vector(resultAdd);
			end if;
			
			
			--1st Bit
			wordIndex := 1;
			LSB := (registerLength * wordIndex / 4)+16;
			MSB := ((registerLength * wordIndex / 4) + halfWord - 1)+16;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul - signed(r1 (MSB downto LSB - halfWord));
			
			--Then, we check for saturation
			if (saturationCheckSub( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd( MSB downto LSB - halfWord) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( MSB downto MSB - wordLength+1) <= std_logic_vector(resultAdd);
			end if;
			
			--2nd Bit
			wordIndex := 2;
			LSB := (registerLength * wordIndex / 4)+16;
			MSB := ((registerLength * wordIndex / 4) + halfWord - 1)+16;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul - signed(r1 (MSB downto LSB - halfWord));
			
			
			--Then, we check for saturation
			if (saturationCheckSub( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd( MSB downto LSB - halfWord) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( MSB downto MSB - wordLength+1) <= std_logic_vector(resultAdd);
			end if;
			
			--3rd Bit
			wordIndex := 3;
			LSB := (registerLength * wordIndex / 4)+16;
			MSB := ((registerLength * wordIndex / 4) + halfWord - 1)+16;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul - signed(r1 (MSB downto LSB - halfWord));
			
			--Then, we check for saturation
			if (saturationCheckSub( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd(MSB downto LSB - halfWord) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( MSB downto MSB - wordLength+1) <= std_logic_vector(resultAdd);
			end if;
			
			
			
			
			
	end intMulSubHi;
-------------------------------------------------------------------------------------
---100-Signed Long Multiply-Add Low with Saturation used in R4 instruction Type---
--The only real time you have to worry about saturation is after the addition/subtraction

	procedure longMulAddLo(signal r1, r2, r3: in std_logic_vector(registerLength-1 downto 0);
	signal rd: out std_logic_vector(registerLength-1 downto 0)) is
		variable wordIndex: integer;
		variable halfWord: integer := 32;
		variable wordLength: integer := 64;
		variable MSB, LSB: integer;
		variable var3: signed (halfWord-1 downto 0);
		variable var2: signed (halfWord-1 downto 0);
		variable resultMul: signed (wordLength-1 downto 0);
		variable resultAdd: signed (wordLength-1 downto 0);
		begin
			
			--0th Bit
			wordIndex := 0;
			LSB := registerLength * wordIndex / 2;
			MSB := (registerLength * wordIndex / 2) + halfWord - 1;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul + signed(r1 (MSB downto LSB));
			
			--Then, we check for saturation
			if (saturationCheckAdd( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then
				--There are two ways to do this. Ultimately, the goal is to replace with 01111111... or 100000... First is to realize that the check of (msb2, msbRd), if different, gives you the
				--exact order that the over/underflow should be. Can either do directly, or with a reference.
				--if (msb2, msbRd) = 10, underflow rd <= 100000...
				--if (msb2, msbRd) = 01, overflow  rd <= 011111...
				
					
				--if (resultMul(wordLength -1) = '0' and resultAdd(wordLength -1) = '1') then
				--	rd( 62 downto 32) <= (others => '1');
				--	rd( 63) <= '0';
				--else
				--	rd( 62 downto 32) <= (others => '0');
				--	rd( 63) <= '1';
				--end if;
				
				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd(LSB + wordLength-1 downto LSB) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( LSB + wordLength-1 downto LSB ) <= std_logic_vector(resultAdd);
			end if;
			
			
			--1st Bit
			wordIndex := 1;
			LSB := registerLength * wordIndex / 2;
			MSB := (registerLength * wordIndex / 2) + halfWord - 1;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul + signed(r1 (MSB downto LSB));
			--resultAdd := resultMul;
			
			--Then, we check for saturation
			if (saturationCheckAdd( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd(LSB + wordLength-1 downto LSB) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( LSB + wordLength-1 downto LSB ) <= std_logic_vector(resultAdd);
			end if;
	
			
	end longMulAddLo;
-------------------------------------------------------------------------------------

---101-Signed Long Multiply-Add High with Saturation used in R4 instruction Type---
--The only real time you have to worry about saturation is after the addition/subtraction

	procedure longMulAddHi(signal r1, r2, r3: in std_logic_vector(registerLength-1 downto 0);
	signal rd: out std_logic_vector(registerLength-1 downto 0)) is
		variable wordIndex: integer;
		variable halfWord: integer := 32;
		variable wordLength: integer := 64;
		variable MSB, LSB: integer;
		variable var3: signed (halfWord-1 downto 0);
		variable var2: signed (halfWord-1 downto 0);
		variable resultMul: signed (wordLength-1 downto 0);
		variable resultAdd: signed (wordLength-1 downto 0);
		begin
			
			--0th Bit
			wordIndex := 0;
			LSB := registerLength * wordIndex / 2;
			MSB := (registerLength * wordIndex / 2) + halfWord - 1;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul + signed(r1 (MSB + halfWord downto LSB));
			
			--Then, we check for saturation
			if (saturationCheckAdd( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then
				--There are two ways to do this. Ultimately, the goal is to replace with 01111111... or 100000... First is to realize that the check of (msb2, msbRd), if different, gives you the
				--exact order that the over/underflow should be. Can either do directly, or with a reference.
				--if (msb2, msbRd) = 10, underflow rd <= 100000...
				--if (msb2, msbRd) = 01, overflow  rd <= 011111...
				
					
				--if (resultMul(wordLength -1) = '0' and resultAdd(wordLength -1) = '1') then
				--	rd( 62 downto 32) <= (others => '1');
				--	rd( 63) <= '0';
				--else
				--	rd( 62 downto 32) <= (others => '0');
				--	rd( 63) <= '1';
				--end if;
				
				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd(MSB downto LSB - halfWord) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( MSB downto LSB - halfWord ) <= std_logic_vector(resultAdd);
			end if;
			
			
			--1st Bit
			wordIndex := 1;
			LSB := registerLength * wordIndex / 2;
			MSB := (registerLength * wordIndex / 2) + halfWord - 1;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul + signed(r1 (MSB + halfWord downto LSB));
			--resultAdd := resultMul;
			
			--Then, we check for saturation
			if (saturationCheckAdd( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd(MSB downto LSB - halfWord) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( MSB downto LSB - halfWord ) <= std_logic_vector(resultAdd);
			end if;
	
			
	end longMulAddHi;
------------------------------------------------------------------------------------


---110-Signed Long Multiply-Sub Low with Saturation used in R4 instruction Type---
--The only real time you have to worry about saturation is after the addition/subtraction

	procedure longMulSubLo(signal r1, r2, r3: in std_logic_vector(registerLength-1 downto 0);
	signal rd: out std_logic_vector(registerLength-1 downto 0)) is
		variable wordIndex: integer;
		variable halfWord: integer := 32;
		variable wordLength: integer := 64;
		variable MSB, LSB: integer;
		variable var3: signed (halfWord-1 downto 0);
		variable var2: signed (halfWord-1 downto 0);
		variable resultMul: signed (wordLength-1 downto 0);
		variable resultAdd: signed (wordLength-1 downto 0);
		begin
			
			--0th Bit
			wordIndex := 0;
			LSB := registerLength * wordIndex / 2;
			MSB := (registerLength * wordIndex / 2) + halfWord - 1;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul - signed(r1 (MSB + halfWord downto LSB));
			
			--Then, we check for saturation
			if (saturationCheckSub( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then
				--There are two ways to do this. Ultimately, the goal is to replace with 01111111... or 100000... First is to realize that the check of (msb2, msbRd), if different, gives you the
				--exact order that the over/underflow should be. Can either do directly, or with a reference.
				--if (msb2, msbRd) = 10, underflow rd <= 100000...
				--if (msb2, msbRd) = 01, overflow  rd <= 011111...
				
					
				--if (resultMul(wordLength -1) = '0' and resultAdd(wordLength -1) = '1') then
				--	rd( 62 downto 32) <= (others => '1');
				--	rd( 63) <= '0';
				--else
				--	rd( 62 downto 32) <= (others => '0');
				--	rd( 63) <= '1';
				--end if;
				
				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd(LSB + wordLength-1 downto LSB) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( LSB + wordLength-1 downto LSB ) <= std_logic_vector(resultAdd);
			end if;
			
			
			--1st Bit
			wordIndex := 1;
			LSB := registerLength * wordIndex / 2;
			MSB := (registerLength * wordIndex / 2) + halfWord - 1;
			
			var3 := signed( r3( MSB downto LSB ) );
			var2 := signed( r2( MSB downto LSB ) );
			resultMul := var3 * var2;
			
			resultAdd := resultMul - signed(r1 (MSB + halfWord downto LSB));
			--resultAdd := resultMul;
			
			--Then, we check for saturation
			if (saturationCheckSub( std_logic_vector(r1(((wordIndex+1) * wordLength)-1 downto ((wordIndex+1) * wordLength)-1)), std_logic_vector(resultMul(wordLength-1 downto wordLength-1)), std_logic_vector(resultAdd(wordLength-1 downto wordLength-1)) ) = 1) then				
				--Replace the rd with the first bit from resultMul, then the rest from the MSB of resultAdd
				resultAdd(wordLength-1 downto 0) := (others => resultAdd(wordLength-1));
				rd(LSB + wordLength-1 downto LSB) <= std_logic_vector(resultMul(wordLength-1 downto wordLength-1)) & std_logic_vector(resultAdd(wordLength - 2 downto 0));
			else
				rd( LSB + wordLength-1 downto LSB ) <= std_logic_vector(resultAdd);
			end if;
	
			
	end longMulSubLo;
-------------------------------------------------------------------------------------


---0101-Procedure to compute the bitwiseOR used in R3 instruction type---------------

    procedure bitwiseOR(signal r1, r2: in std_logic_vector(registerLength-1 downto 0);
                        signal rd: out std_logic_vector(registerLength-1 downto 0)) is
    begin
        rd <= r1 or r2;
              
    end bitwiseOR;
 ------------------------------------------------------------------------------------
 
 ---1011-Procedure to compute the bitwiseAND used in R3 instruction type-------------

    procedure bitwiseAND(signal r1, r2: in std_logic_vector(registerLength-1 downto 0);
                        signal rd: out std_logic_vector(registerLength-1 downto 0)) is
    begin
        rd <= r1 and r2;
              
    end bitwiseAND;
 -----------------------------------------------------------------------------------
 
  ---1100-Procedure to compute INVB used in R3 instruction type-------------

    procedure INVB(signal r1, r2: in std_logic_vector(registerLength-1 downto 0);
                        signal rd: out std_logic_vector(registerLength-1 downto 0)) is
    begin
        rd <= not r1;
              
    end INVB;
 -----------------------------------------------------------------------------------

 ---1101-Procedure to compute the ROTW used in R3 instruction type------------------
    procedure ROTW(signal rs1, rs2: in std_logic_vector(registerLength-1 downto 0);
                        signal rd: out std_logic_vector(registerLength-1 downto 0)) is
        variable temp: std_logic_vector(registerLength-1 downto 0);
		variable offset: integer;	
		variable wordIndex: integer;
		variable leftBit: integer;
    begin
        --ROTW: rotate bits in word : the contents of each 32-bit field in register rs1 
             --are rotated to the right according to the value of the 5 least significant bits 
             --of the corresponding 32-bit field in register rs2. The results are placed in register rd. 
             --Bits rotated out of the right end of each word are rotated in on the left end of the same 32-bit word field. 
             --(Comments: 4 separate 32-bit word values in each 128-bit register)
             
             --------Procedure to compute the ROTW used in R3 instruction type------
             -- In my understanding, a word is 32 bits. Therefore, 
             -- 31 ... 16 ... 0 rotated right 15 times is now 15 ... 31 ... 16
             --
            -- The following indicates the bit to be moved to the 0th index
            --      to_integer(unsigned(rs2(4 downto 0)))-1
 		
			-- I want to use a generate statement for this. What I'm doing doesn't work.
				
            -- Zeroth word 
			--Corresponding 5 bits is: 5-0
			wordIndex := 0;
			leftBit := to_integer(unsigned(rs2( (wordIndex * registerLength / 4) + 4 downto (wordIndex * registerLength / 4))));
            leftBit := leftBit-1;
			offset := (wordIndex * registerLength / 4);
			
			temp(leftBit downto 0) := rs1(32*wordIndex+leftBit downto 32*wordIndex);
            rd(32-leftBit-2+offset downto offset) <= rs1(32*(wordIndex+1)-1 downto leftBit+1+32*wordIndex);
            rd(32*(wordIndex+1)-1 downto 32*(wordIndex+1)-1-leftBit) <= temp(leftBit downto 0);  
			
			
			-- First word 
			--Corresponding 5 bits is: 5-0
			wordIndex := 1;
			leftBit := to_integer(unsigned(rs2( (wordIndex * registerLength / 4) + 4 downto (wordIndex * registerLength / 4))));
            leftBit := leftBit-1;
			offset := (wordIndex * registerLength / 4);
			
			temp(leftBit downto 0) := rs1(32*wordIndex+leftBit downto 32*wordIndex);
            rd(32-leftBit-2+offset downto offset) <= rs1(32*(wordIndex+1)-1 downto leftBit+1+32*wordIndex);
            rd(32*(wordIndex+1)-1 downto 32*(wordIndex+1)-1-leftBit) <= temp(leftBit downto 0);
			
			-- Second word 
			--Corresponding 5 bits is: 5-0
			wordIndex := 2;
			leftBit := to_integer(unsigned(rs2( (wordIndex * registerLength / 4) + 4 downto (wordIndex * registerLength / 4))));
            leftBit := leftBit-1;
			offset := (wordIndex * registerLength / 4);
			
			temp(leftBit downto 0) := rs1(32*wordIndex+leftBit downto 32*wordIndex);
            rd(32-leftBit-2+offset downto offset) <= rs1(32*(wordIndex+1)-1 downto leftBit+1+32*wordIndex);
            rd(32*(wordIndex+1)-1 downto 32*(wordIndex+1)-1-leftBit) <= temp(leftBit downto 0);
			
			-- Third word 
			--Corresponding 5 bits is: 5-0
			wordIndex := 3;
			leftBit := to_integer(unsigned(rs2( (wordIndex * registerLength / 4) + 4 downto (wordIndex * registerLength / 4))));
            leftBit := leftBit-1;
			offset := (wordIndex * registerLength / 4);
			
			temp(leftBit downto 0) := rs1(32*wordIndex+leftBit downto 32*wordIndex);
            rd(32-leftBit-2+offset downto offset) <= rs1(32*(wordIndex+1)-1 downto leftBit+1+32*wordIndex);
            rd(32*(wordIndex+1)-1 downto 32*(wordIndex+1)-1-leftBit) <= temp(leftBit downto 0);
              
    end ROTW;
 ----------------------------------------------------------------------------
---1110-Procedure to subtract word from unsigned used in R3 instruction type-------------

	procedure SFWU(signal r1, r2: in std_logic_vector(registerLength-1 downto 0);
					signal rd: out std_logic_vector(registerLength-1 downto 0)) is
		variable wordIndex: integer;
		variable int1: unsigned((registerLength / 4) - 1 downto 0);
		variable int2: unsigned((registerLength / 4) - 1 downto 0);
		variable maxBit: integer;
		variable minBit: integer;
    begin
        wordIndex := 0;	
		maxBit := ( (wordIndex+1) * registerLength / 4) - 1;
		minBit := ( (wordIndex) * registerLength / 4);
		
		int1 := unsigned(r1(maxBit downto minBit));
		int2 :=	unsigned(r2(maxBit downto minBit));
		
		--This is what I thought of at first
		--rd(maxBit downto minBit) <=  std_logic_vector(int2 - int1);
		--Turns out VHDL does the subtraction as a twos compliment, but interpets the result as unsigned
		--So 5-7 = 14 (0101 - 0111 = 1110), which makes sense as twos compliment in binary
		--However, I don't believe that's what the essence of this instruction is. Therefore, I am
		--programing this to simply find the difference between the two values.
		
		if (int1 < int2) then
			rd(maxBit downto minBit) <=  std_logic_vector(int2 - int1);
		elsif (int1 > int2) then
			rd(maxBit downto minBit) <=  std_logic_vector(int1 - int2);
		else
			rd(maxBit downto minBit) <= (others => '0');
		end if;
    end SFWU;
-----------------------------------------------------------------------------------


-----------------------------------------------------------------------------------
---1111-Procedure to Subtract from halfword saturated used in R3 instruction type-------------

	procedure SFHS(signal r1, r2: in std_logic_vector(registerLength-1 downto 0);
					signal rd: out std_logic_vector(registerLength-1 downto 0)) is
		variable wordIndex: integer;
		variable halfWordCt: integer := 8;
		variable registerLength: integer := 128;
		variable wordLength: integer := registerLength / halfWordCt;
		variable result: signed(wordLength-1 downto 0);
		variable val2: signed(wordLength-1 downto 0);
		variable val1: signed(wordLength-1 downto 0);
		variable LSB: integer;
		variable MSB: integer;
	begin
		--if (saturationCheckSub("1", "0", "1") = 1) then
		--	  rd <= (others => '1');
		--else
		--	rd <= (others => '0');	
		--end if;
		
		
		-- A generate statement would be better here. However, generate statements dont work inside a procedure.
		-- If this was in its own entity, it would work just fine.
		
		--For the 0th index
		wordIndex := 0;
 		LSB := registerLength * wordIndex / halfWordCt;
		MSB := LSB + wordLength - 1;
		
		val2 := signed ( r2( MSB downto LSB));
		val1 := signed ( r1( MSB downto LSB));
		result( wordLength-1 downto 0) := val2 - val1;
		
		if (saturationCheckSub( std_logic_vector(val1(wordLength-1 downto wordLength-1)), std_logic_vector(val2(wordLength-1 downto wordLength-1)), std_logic_vector(result(wordLength-1 downto wordLength-1)) ) = 1) then
			result(wordLength-1 downto 0) := (others => result(wordLength-1));
			rd(MSB downto LSB) <= val2(wordLength-1) & std_logic_vector(result(wordLength - 2 downto 0));
		else
			rd( MSB downto LSB ) <= std_logic_vector(result);
		end if;
		
		
		--For the 1st index
		wordIndex := 1;
 		LSB := registerLength * wordIndex / halfWordCt;
		MSB := LSB + wordLength - 1;
		
		val2 := signed ( r2( MSB downto LSB));
		val1 := signed ( r1( MSB downto LSB));
		result( wordLength-1 downto 0) := val2 - val1;
		
		if (saturationCheckSub( std_logic_vector(val1(wordLength-1 downto wordLength-1)), std_logic_vector(val2(wordLength-1 downto wordLength-1)), std_logic_vector(result(wordLength-1 downto wordLength-1)) ) = 1) then
			result(wordLength-1 downto 0) := (others => result(wordLength-1));
			rd(MSB downto LSB) <= val2(wordLength-1) & std_logic_vector(result(wordLength - 2 downto 0));
		else
			rd( MSB downto LSB ) <= std_logic_vector(result);
		end if;
		
		--For the 2nd index
		wordIndex := 2;
 		LSB := registerLength * wordIndex / halfWordCt;
		MSB := LSB + wordLength - 1;
		
		val2 := signed ( r2( MSB downto LSB));
		val1 := signed ( r1( MSB downto LSB));
		result( wordLength-1 downto 0) := val2 - val1;
		
		if (saturationCheckSub( std_logic_vector(val1(wordLength-1 downto wordLength-1)), std_logic_vector(val2(wordLength-1 downto wordLength-1)), std_logic_vector(result(wordLength-1 downto wordLength-1)) ) = 1) then
			result(wordLength-1 downto 0) := (others => result(wordLength-1));
			rd(MSB downto LSB) <= val2(wordLength-1) & std_logic_vector(result(wordLength - 2 downto 0));
		else
			rd( MSB downto LSB ) <= std_logic_vector(result);
		end if;
		
		--For the 3rd index
		wordIndex := 3;
 		LSB := registerLength * wordIndex / halfWordCt;
		MSB := LSB + wordLength - 1;
		
		val2 := signed ( r2( MSB downto LSB));
		val1 := signed ( r1( MSB downto LSB));
		result( wordLength-1 downto 0) := val2 - val1;
		
		if (saturationCheckSub( std_logic_vector(val1(wordLength-1 downto wordLength-1)), std_logic_vector(val2(wordLength-1 downto wordLength-1)), std_logic_vector(result(wordLength-1 downto wordLength-1)) ) = 1) then
			result(wordLength-1 downto 0) := (others => result(wordLength-1));
			rd(MSB downto LSB) <= val2(wordLength-1) & std_logic_vector(result(wordLength - 2 downto 0));
		else
			rd( MSB downto LSB ) <= std_logic_vector(result);
		end if;
		
		--For the 4th index
		wordIndex := 4;
 		LSB := registerLength * wordIndex / halfWordCt;
		MSB := LSB + wordLength - 1;
		
		val2 := signed ( r2( MSB downto LSB));
		val1 := signed ( r1( MSB downto LSB));
		result( wordLength-1 downto 0) := val2 - val1;
		
		if (saturationCheckSub( std_logic_vector(val1(wordLength-1 downto wordLength-1)), std_logic_vector(val2(wordLength-1 downto wordLength-1)), std_logic_vector(result(wordLength-1 downto wordLength-1)) ) = 1) then
			result(wordLength-1 downto 0) := (others => result(wordLength-1));
			rd(MSB downto LSB) <= val2(wordLength-1) & std_logic_vector(result(wordLength - 2 downto 0));
		else
			rd( MSB downto LSB ) <= std_logic_vector(result);
		end if;
		
		--For the 5th index
		wordIndex := 5;
 		LSB := registerLength * wordIndex / halfWordCt;
		MSB := LSB + wordLength - 1;
		
		val2 := signed ( r2( MSB downto LSB));
		val1 := signed ( r1( MSB downto LSB));
		result( wordLength-1 downto 0) := val2 - val1;
		
		if (saturationCheckSub( std_logic_vector(val1(wordLength-1 downto wordLength-1)), std_logic_vector(val2(wordLength-1 downto wordLength-1)), std_logic_vector(result(wordLength-1 downto wordLength-1)) ) = 1) then
			result(wordLength-1 downto 0) := (others => result(wordLength-1));
			rd(MSB downto LSB) <= val2(wordLength-1) & std_logic_vector(result(wordLength - 2 downto 0));
		else
			rd( MSB downto LSB ) <= std_logic_vector(result);
		end if;
		
		--For the 6th index
		wordIndex := 6;
 		LSB := registerLength * wordIndex / halfWordCt;
		MSB := LSB + wordLength - 1;
		
		val2 := signed ( r2( MSB downto LSB));
		val1 := signed ( r1( MSB downto LSB));
		result( wordLength-1 downto 0) := val2 - val1;
		
		if (saturationCheckSub( std_logic_vector(val1(wordLength-1 downto wordLength-1)), std_logic_vector(val2(wordLength-1 downto wordLength-1)), std_logic_vector(result(wordLength-1 downto wordLength-1)) ) = 1) then
			result(wordLength-1 downto 0) := (others => result(wordLength-1));
			rd(MSB downto LSB) <= val2(wordLength-1) & std_logic_vector(result(wordLength - 2 downto 0));
		else
			rd( MSB downto LSB ) <= std_logic_vector(result);
		end if;
		
		--For the 7th index
		wordIndex := 7;
 		LSB := registerLength * wordIndex / halfWordCt;
		MSB := LSB + wordLength - 1;
		
		val2 := signed ( r2( MSB downto LSB));
		val1 := signed ( r1( MSB downto LSB));
		result( wordLength-1 downto 0) := val2 - val1;
		
		if (saturationCheckSub( std_logic_vector(val1(wordLength-1 downto wordLength-1)), std_logic_vector(val2(wordLength-1 downto wordLength-1)), std_logic_vector(result(wordLength-1 downto wordLength-1)) ) = 1) then
			result(wordLength-1 downto 0) := (others => result(wordLength-1));
			rd(MSB downto LSB) <= val2(wordLength-1) & std_logic_vector(result(wordLength - 2 downto 0));
		else
			rd( MSB downto LSB ) <= std_logic_vector(result);
		end if;
		

    end SFHS;
-----------------------------------------------------------------------------------


 
 
 
--Enumerate the various options available
--NUL is our effective NULL, since that is a reserved keyword. In our case, NUL means that option is not selected
type OPCODE is (NOP, SHRHI, AU, CNT1H, AHS, ORopcode, BCW, MAXWS, MINWS, MLHU, MLHSS, ANDopcode, INVB, ROTW, SFWU, SFHS, NUL);

type r4Format is(intMulAddLo, intMulAddHi, intMulSubLo, intMulSubHi, longMulAddLo, longMulAddHi, longMulSubLo, longMulSubHi, NUL);

      signal selectOpcode : OPCODE;
      signal r4: r4Format;
	  
	  
	  
	  
    
      
      
begin
	
    ALUProcess: process (all)
    	   -- For Load Immediate
    variable loadIndex: integer;
   
    --A variable temp that can be used for any part of the ALU. Assume this will be overwritten for every new process
    variable temp: std_logic_vector(127 downto 0);
    variable intTemp: integer;
    
    begin
		
		
    if (wordIn(24) = '0') then
        --If wordIn[24] == 0, then we load Immediate
        
        --Load a 16-bit Immediate value from the [20:5] instruction field into the 16-bit field specified by the Load Index field [23:21] of the 128-bit register rd. 
        --Other fields of register rd are not changed. Note that a LI instruction first reads register rd and then (after inserting an immediate value into one of its fields) 
        --writes it back to register rd, i.e., register rd is both a source and destination register of the LI instruction!
        
    
        --Breakdown the wordIn(23:21) into its integer counterpart
        loadIndex := to_integer(unsigned(wordIn(23 downto 21)));
        
        --Store the immediate value
        temp(15 downto 0) := wordIn(20 downto 5);
        
        --Write it to the paticular register index required
        rd((loadIndex+1)*16-1 downto (loadIndex*16)) <= temp(15 downto 0);
  
    
    elsif (wordIn(23) = '0') then
    --Otherwise, we're at 10: Instruction is R4 type
        case wordIn(22 downto 20) is
            when "000" => intMulAddLo(rs1, rs2, rs3, rd);
            when "001" => intMulAddHi(rs1, rs2, rs3, rd);
            when "010" => intMulSubLo(rs1, rs2, rs3, rd);
            when "011" => intMulSubHi(rs1, rs2, rs3, rd);
            when "100" => longMulAddLo(rs1, rs2, rs3, rd);
            when "101" => longMulAddHi(rs1, rs2, rs3, rd);
            when "110" => longMulSubLo(rs1, rs2, rs3, rd);
            when "111" => r4 <= longMulSubHi;
            when others => r4 <= NUL;
        end case;
      
    else 
    --Otherwise, we're at 11: Instruction is R3 type
    
        --Figure out what opcode the R3 instruction type is telling us to do.
        case wordIn(18 downto 15) is
            when "0000" => selectOpcode <= NOP;
            when "0001" => selectOpcode <= SHRHI;
            when "0010" => selectOpcode <= AU;
            when "0011" => selectOpcode <= CNT1H;
            when "0100" => selectOpcode <= AHS;
            when "0101" => bitwiseOR(rs1, rs2, rd);
            when "0110" => selectOpcode <= BCW;
            when "0111" => selectOpcode <= MAXWS;
            when "1000" => selectOpcode <= MINWS;
            when "1001" => selectOpcode <= MLHU;
            when "1010" => selectOpcode <= MLHSS;
            when "1011" => bitwiseAND(rs1, rs2, rd);
            when "1100" => INVB(rs1, rs2, rd);
            when "1101" => ROTW(rs1, rs2, rd);
            when "1110" => SFWU(rs1, rs2, rd);
            when "1111" => SFHS(rs1, rs2, rd);
            when others => selectOpcode <= NUL;
        end case;
        
        
    
    end if;
    
    end process;

end Behavioral;
