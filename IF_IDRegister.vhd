----------------------------------------------------------------------------------
-- Company: Stony Brook University - ESE 345 Computer Architecture
-- Engineers: Kyle Han and Summer Wang
-- 
-- Create Date: 11/30/2023 2:33:21 PM
-- Design Name: 
-- Module Name: IF/ID Register - Behavioral
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

entity if_idRegister is
	Port( 
	--Inputs
	instruction: in std_logic_vector(24 downto 0);
	clk: in std_logic;
	
	--Outputs
	instructionOut: out std_logic_vector(24 downto 0);
	rs3: out std_logic_vector(4 downto 0);
	rs2: out std_logic_vector(4 downto 0);
	rs1: out std_logic_vector(4 downto 0);
	rd: out std_logic_vector(4 downto 0));
end if_idRegister;


architecture behavioral of if_idRegister is

begin
	process(clk)
	begin
		if(rising_edge(clk)) then 
			--On a rising clock edge, we want to see the asynchronous data sent out. So whatever is in instruction is split
			instructionOut <= instruction;
			rs3 <= instruction(19 downto 15);
			rs2 <= instruction(14 downto 10);
			rs1 <= instruction(9 downto 5);
			rd <= instruction(4 downto 0);
		end if;
	end process;
	
end behavioral;
