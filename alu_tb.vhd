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
            -- Testing the load immediate Function
            -- wordIn can be something like 0 001 0000 1111 0000 1111 00000
            -- This will load 0x0F0F into the second 16 bits of register rd
            wordIn <= "0001000011110000111100000";
            
            wait for 15 ns;
            
            -- Testing the load immediate Function
            -- wordIn can be something like 0 010 1100111100101111 00000
            -- This will load 0xCF2F into the third 16 bits of register rd
            wordIn <= "0010110011110010111100000"; 
			
			wait for 15 ns;		
			
			-- Testing the load immediate Function
            -- wordIn can be something like 0 010 1100000000100011 00000
            -- This will load 0xC023 into the last 16 bits of register rd
            wordIn <= "0010110000000010001100000"; 
			
			wait for 15 ns;		
			
			--Testing for bitwiseOR
			--Set the first 32 bits of rs1 to 1, then others to 0  
			--Set the last 32 bits of rs2 to 1, then others to 0 
			-- wordIn is 1 1 0000 0101 00000 00000 00000
			wordIn <= "1100000101000000000000000";
			rs1 <= (127 downto 95 => '1', others => '0');
			rs2 <= (31 downto 0 => '1', others => '0');  
			
			
			wait for 15 ns;	
			
			--Testing for bitwiseAND
			--Set the first 32 bits of rs1 to 1, then others to 0  
			--Set the last 32 bits of rs2 to 1, then others to 0 
			-- wordIn is 1 1 0000 1011 00000 00000 00000
			wordIn <= "1100001011000000000000000";
			rs1 <= (127 downto 95 => '1', others => '0');
			rs2 <= (100 downto 80 => '1', others => '0');
			
			wait for 15 ns;
                    
        end process;
end Behavioral;
