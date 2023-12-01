----------------------------------------------------------------------------------
-- Company: Stony Brook University - ESE 345 Computer Architecture
-- Engineers: Kyle Han and Summer Wang
-- 
-- Create Date: 11/30/2023 2:33:21 PM
-- Design Name: 
-- Module Name: IF/EX Register - Behavioral
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

entity if_exRegister is
	Port( 
	--Inputs
	clk: in std_logic;
	
	instruction: in std_logic_vector(24 downto 0);
	
	r3DataIn: in std_logic_vector(127 downto 0);
	r2DataIn: in std_logic_vector(127 downto 0);
	r1DataIn: in std_logic_vector(127 downto 0);
	
	rs3AddressIn: in std_logic_vector(4 downto 0);
	rs2AddressIn: in std_logic_vector(4 downto 0);
	rs1AddressIn: in std_logic_vector(4 downto 0);
	rdAddressIn: in std_logic_vector(4 downto 0);
	
	
	--Outputs
	instructionOut: out std_logic_vector(24 downto 0);
	
	rs3AddressOut: out std_logic_vector(4 downto 0);
	rs2AddressOut: out std_logic_vector(4 downto 0);
	rs1AddressOut: out std_logic_vector(4 downto 0);
	rdAddressOut: out std_logic_vector(4 downto 0);
	
	r3DataOut: out std_logic_vector(127 downto 0);
	r2DataOut: out std_logic_vector(127 downto 0);
	r1DataOut: out std_logic_vector(127 downto 0)
	
	);
end if_exRegister;


architecture behavioral of if_exRegister is

begin
	process(clk)
	begin
		if(rising_edge(clk)) then 
			--On a rising clock edge, we want to see the asynchronous data sent out. So whatever is in instruction is split
			instructionOut <= instruction;
			
			rs3AddressOut <= rs3AddressIn;
			rs2AddressOut <= rs2AddressIn;
			rs1AddressOut <= rs1AddressIn;
			rdAddressOut <= rdAddressIn;
			
			r3DataOut <= r3DataIn;
			r2DataOut <= r2DataIn;
			r1DataOut <= r1DataIn;
		end if;
	end process;
	
end behavioral;
