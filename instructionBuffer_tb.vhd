----------------------------------------------------------------------------------
-- Company: Stony Brook University - ESE 345 Computer Architecture
-- Engineers: Kyle Han and Summer Wang
-- 
-- Create Date: 11/29/2023 9:57:21 PM
-- Design Name: 
-- Module Name: insructionBuffer_TB - Behavioral
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

entity instructionBuffer_tb is
	
end instructionBuffer_tb;

architecture behavioral of instructionBuffer_tb is
	signal clk: std_logic := '0';
	
	constant BL_STR :string :="machineCode.txt";
    signal filename: string(1 to BL_STR'length) := BL_STR ;
	--signal filename: string(1 to 16) := "machineCode.txt"; --With this singular line of code, vivado didn't want to simulate. The constant above is a workaround
	signal instruction: std_logic_vector(24 downto 0);
	
	constant period : time := 1 us;
begin
	UUT: entity instructionBuffer
		port map(clk => clk,
		filename => filename,
		instruction => instruction);
		testing: process
		begin
			for i in 0 to 128 loop
				wait for period/2;
				clk <= not clk;
			end loop;
			std.env.finish;
		end process;
end behavioral;