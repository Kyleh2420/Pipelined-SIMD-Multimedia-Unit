LIBRARY ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.ALL;
use work.all;
use std.env.finish;

-- VHDL testbench for register file
ENTITY tb_Reg_File IS
END tb_Reg_File;
 
ARCHITECTURE Behavioral OF tb_Reg_File IS 
 
    -- Component Declaration for register file in VHDL
 
    COMPONENT resgiter_file
    PORT(
        WR_en: in std_logic;	-- Write enable 
		R1_addr: in std_logic_vector(4 downto 0);  --	R1 Address input
		R2_addr: in std_logic_vector(4 downto 0);	 --	R2 Address input
		R3_addr: in std_logic_vector(4 downto 0);	 -- R3 Address input 
		Rd_addr: in std_logic_vector(4 downto 0);  -- Rd Address input
		Rd_data: in std_logic_vector(127 downto 0); -- Rd data in from Write Back
	--	CLK: in std_logic; -- clock input for RAM
		R1_out: out std_logic_vector(127 downto 0); -- R2 register output
		R2_out: out std_logic_vector(127 downto 0); -- R2 register output
		R3_out: out std_logic_vector(127 downto 0) -- Data output of RAM
        );
    END COMPONENT;
    

    --Inputs
	signal WR_en: std_logic := '0';	-- Write enable 
	signal R1_addr: std_logic_vector(4 downto 0) := (others => '0');  --	R1 Address input
	signal R2_addr: std_logic_vector(4 downto 0);	 --	R2 Address input
	signal R3_addr: std_logic_vector(4 downto 0);	 -- R3 Address input 
	signal Rd_addr: std_logic_vector(4 downto 0);  -- Rd Address input
	signal Rd_data: std_logic_vector(127 downto 0); -- Rd data in from Write Back

	--Outputs
	signal R1_out: std_logic_vector(127 downto 0);
	signal R2_out: std_logic_vector(127 downto 0);
 	signal R3_out: std_logic_vector(127 downto 0);

begin
    -- Instantiate the single-port RAM in VHDL
	uut: entity resgiter_file 
		port map(
          WR_en => WR_en,
          R1_addr => R1_addr,
          R2_addr => R2_addr,
		  R3_addr => R3_addr,
          Rd_addr => Rd_addr,
		  Rd_data => Rd_data,
		  R1_out => R1_out,
		  R2_out => R2_out,
		  R3_out => R3_out
        );
		
		test: process
		begin
			WR_en <= '1';
			R1_addr <= "00001";
			R2_addr <= "00010";
			R3_addr <= "00011";
			Rd_addr <= "00001";  -- supposed to write back to $r1
			Rd_data <= (others => '1');
--Rd_data <= (7 => '1', 5 downto 1 => '1', 6 => B_BIT, others => '0');
			wait for 20 ns;
			
			WR_en <= '1';
			R1_addr <= "00001";
			R2_addr <= "00010";
			R3_addr <= "00011";
			Rd_addr <= "00010";  -- supposed to write back to $r2
			Rd_data <= (7 => '1', 4 downto 0 => '1', others => '0');
			wait for 20 ns;
			
			-- when WR_en is 0, verify that nothing gets written in
			WR_en <= '0';
			R1_addr <= "00001";
			R2_addr <= "00000";
			R3_addr <= "00011";
			Rd_addr <= "00000";  -- supposed to write back to $r3
			Rd_data <= (7 => '1', 4 downto 0 => '1', others => '0');
			wait for 20 ns;
			
			WR_en <= '1';
			R1_addr <= "00001";
			R2_addr <= "00010";
			R3_addr <= "00011";
			Rd_addr <= "00100";  -- supposed to write back to $r4
			Rd_data <= (7 => '1', 4 downto 0 => '1', others => '0');
			wait for 20 ns;
			
			WR_en <= '1';
			R1_addr <= "00100";	 -- $r4
			R2_addr <= "00010";	 -- $r2
			R3_addr <= "00011";	 -- $r3
			Rd_addr <= "00100";  -- supposed to write back to $r4
			Rd_data <= (6 => '1', 3 downto 0 => '1', others => '0');
			wait for 20 ns;
			
			WR_en <= '1';
			R1_addr <= "00001";
			R2_addr <= "00010";
			R3_addr <= "00011";
			Rd_addr <= "00101";  -- supposed to write back to $r5
			Rd_data <= (7 => '1', 4 downto 0 => '1', others => '0');
			wait for 20 ns;
			
			WR_en <= '1';
			R1_addr <= "00001";
			R2_addr <= "00010";
			R3_addr <= "00011";
			Rd_addr <= "00110";  -- supposed to write back to $r6
			Rd_data <= (8 => '1', 4 downto 0 => '1', others => '0');
			wait for 20 ns;
			
			WR_en <= '1';
			R1_addr <= "00100";
			R2_addr <= "00110";	 -- supposed to spit out what's written in
			R3_addr <= "00101";
			Rd_addr <= "00110";  -- supposed to write back to $r6
			Rd_data <= (7 => '1', 4 downto 0 => '1', others => '0');
			wait for 20 ns;
			
			WR_en <= '1';
			R1_addr <= "00100";
			R2_addr <= "00110";	 -- supposed to spit out what's written in
			R3_addr <= "10101";
			Rd_addr <= "10101";  -- supposed to write back to $r6
			Rd_data <= (100 => '1', 4 downto 0 => '1', others => '0');
			wait for 20 ns;
			
		finish;
		end process;
end Behavioral;