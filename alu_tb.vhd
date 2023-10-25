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
    signal wordIn: STD_LOGIC_VECTOR (23 downto 0);
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
            -- wordIn can be something like 0 001 0000111100001111 0000
            -- This will load 0x0F0F into the first 16 bits of register rd
            wordIn <= "000100001111000011110000";
            
            wait for 15 ns;
            
            -- Testing the load immediate Function
            -- wordIn can be something like 0 010 1100111100101111 0000
            -- This will load 0xCF2F into the last 16 bits of register rd
            wordIn <= "001011001111001011110000"; 
			
			wait for 15 ns;			
            
                    
        end process;
end Behavioral;
