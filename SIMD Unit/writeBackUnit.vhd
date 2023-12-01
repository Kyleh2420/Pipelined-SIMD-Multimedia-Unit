----------------------------------------------------------------------------------
-- Company: Stony Brook University - ESE 345 Computer Architecture
-- Engineers: Kyle Han and Summer Wang
-- 
-- Create Date: 11/30/2023 2:33:21 PM
-- Design Name: 
-- Module Name: Write Back Unit - Behavioral
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

entity writeBackUnit is
	Port(
	--Inputs
	instruction: in std_logic_vector(24 downto 0);
	rdDataIn: in std_logic_vector(127 downto 0);
	rdAddressIn: in std_logic_vector(4 downto 0);
	
	--Outputs
	writeEn: out std_logic;
	rdDataOut: out std_logic_vector(127 downto 0);
	rdAddressOut: out std_logic_vector(4 downto 0)
	);
end writeBackUnit;



architecture behavioral of writeBackUnit is

begin
	rdDataOut <= rdDataIn;
	rdAddressOut <= rdAddressIn;
	
	writeEn <= '0' when (instruction(24 downto 23) = "11" and instruction(18 downto 15) = "0000") else '1';
end behavioral;
