----------------------------------------------------------------------------------
-- Company: Stony Brook University - ESE 345 Computer Architecture
-- Engineers: Kyle Han and Summer Wang
-- 
-- Create Date: 11/30/2023 2:33:21 PM
-- Design Name: 
-- Module Name: EX/WB Register - Behavioral
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

entity ex_wbRegister is
	Port( 
	--Inputs
	clk: in std_logic;
	
	instruction: in std_logic_vector(24 downto 0);
	
	rdDataIn: in std_logic_vector(127 downto 0);
	
	rdAddressIn: in std_logic_vector(4 downto 0);
	
	
	--Outputs
	instructionOut: out std_logic_vector(24 downto 0);
	
	rdDataOut: out std_logic_vector(127 downto 0);
	
	rdAddressOut: out std_logic_vector(4 downto 0)
	);
end ex_wbRegister;


architecture behavioral of ex_wbRegister is

begin
	process(clk)
	begin
		if(rising_edge(clk)) then 
			--On a rising clock edge, we want to see the asynchronous data sent out. So whatever is in instruction is split
			instructionOut <= instruction;

			rdAddressOut <= rdAddressIn;
			
			rdDataOut <= rdDataIn;
		end if;
	end process;
	
end behavioral;
