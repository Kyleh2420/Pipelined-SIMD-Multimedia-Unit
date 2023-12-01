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
	signal clk: std_logic := '0';
	constant period : time := 1 us;
	
	constant in_str :string :="machineCode.txt";
    signal filenameIn: string(1 to in_str'length) := in_str;
	--signal filename: string(1 to 16) := "machineCode.txt"; --With this singular line of code, vivado didn't want to simulate. The constant above is a workaround
	
	constant out_str:string :="memory.txt";
    signal filenameOut: string(1 to out_str'length) := out_str;
	
begin
	UUT: entity multimediaUnit
		port map(
		--Inputs
		clk => clk,
		filenameIn => filenameIn,
		filenameOut => filenameOut);
		testing: process
		begin
			for i in 0 to 128 loop
				wait for period/2;
				clk <= not clk;
			end loop;
			std.env.finish;
		end process;
end behavioral;