----------------------------------------------------------------------------------
-- Company: Stony Brook University - ESE 345 Computer Architecture
-- Engineers: Kyle Han and Summer Wang
-- 
-- Create Date: 11/30/2023 9:57:21 PM
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

entity writeBackUnit_tb is
	
end writeBackUnit_tb;

architecture behavioral of writeBackUnit_tb is
	signal instruction: std_logic_vector(24 downto 0);
	
	signal rdData: std_logic_vector(127 downto 0);
	signal rdAddress: std_logic_vector(4 downto 0);
begin
	UUT: entity writeBackUnit
		port map(instruction => instruction,
		rdDataIn => rdData,
		rdAddressIn => rdAddress);
		testing: process
		begin
			
			--WriteEn should be 0
			instruction <= "1100000000000000000000000";
			rdAddress <= std_logic_vector(to_unsigned(31, 5));
			rdData <= (100 downto 80 => '1', others => '0');
			wait for 10ns;
			
			--WriteEn should be 1 for the rest of these
			instruction <= "1000000000000000000000000";
			rdAddress <= std_logic_vector(to_unsigned(5, 5));
			rdData <= (127 downto 80 => '1', others => '0');
			wait for 10ns;
			
			instruction <= "1100001100000000000000000";
			rdAddress <= std_logic_vector(to_unsigned(12, 5));
			rdData <= (60 downto 20 => '1', others => '0');
			wait for 10ns;
			
			--WriteEn should be 0
			instruction <= "1111110000000000000000000";
			rdAddress <= std_logic_vector(to_unsigned(31, 5));
			rdData <= (100 downto 80 => '1', others => '0');
			wait for 10ns;
			
			--WriteEn should be 1
			instruction <= "1111110001000000000000000";
			rdAddress <= std_logic_vector(to_unsigned(31, 5));
			rdData <= (100 downto 80 => '1', others => '0');
			wait for 10ns;
			std.env.finish;
		end process;
end behavioral;