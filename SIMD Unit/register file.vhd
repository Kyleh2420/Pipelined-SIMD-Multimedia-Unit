library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;


entity resgiter_file is
port(
	WR_en: in std_logic;	-- Write enable 
	R1_addr: in std_logic_vector(4 downto 0);  --	R1 Address input
	R2_addr: in std_logic_vector(4 downto 0);	 --	R2 Address input
	R3_addr: in std_logic_vector(4 downto 0);	 -- R3 Address input 
	Rd_addr: in std_logic_vector(4 downto 0);  -- Rd Address input
	Rd_data: in std_logic_vector(127 downto 0); -- Rd data in from Write Back
--	CLK: in std_logic; -- clock input for RAM
	R1_out: out std_logic_vector(127 downto 0); -- R2 register output
	R2_out: out std_logic_vector(127 downto 0); -- R2 register output
	R3_out: out std_logic_vector(127 downto 0); -- Data output of RAM
	-- below are all registers to write to file
	r0: out std_logic_vector(127 downto 0);
	r1: out std_logic_vector(127 downto 0);
	r2: out std_logic_vector(127 downto 0);
	r3: out std_logic_vector(127 downto 0);
	r4: out std_logic_vector(127 downto 0);
	r5: out std_logic_vector(127 downto 0);
	r6: out std_logic_vector(127 downto 0);
	r7: out std_logic_vector(127 downto 0);
	r8: out std_logic_vector(127 downto 0);
	r9: out std_logic_vector(127 downto 0);
	r10: out std_logic_vector(127 downto 0);
	r11: out std_logic_vector(127 downto 0);
	r12: out std_logic_vector(127 downto 0);
	r13: out std_logic_vector(127 downto 0);
	r14: out std_logic_vector(127 downto 0);
	r15: out std_logic_vector(127 downto 0);
	r16: out std_logic_vector(127 downto 0);
	r17: out std_logic_vector(127 downto 0);
	r18: out std_logic_vector(127 downto 0);
	r19: out std_logic_vector(127 downto 0);
	r20: out std_logic_vector(127 downto 0);
	r21: out std_logic_vector(127 downto 0);
	r22: out std_logic_vector(127 downto 0);
	r23: out std_logic_vector(127 downto 0);
	r24: out std_logic_vector(127 downto 0);
	r25: out std_logic_vector(127 downto 0);
	r26: out std_logic_vector(127 downto 0);
	r27: out std_logic_vector(127 downto 0);
	r28: out std_logic_vector(127 downto 0);
	r29: out std_logic_vector(127 downto 0);
	r30: out std_logic_vector(127 downto 0);
	r31: out std_logic_vector(127 downto 0)
	);
end resgiter_file;

architecture comb of resgiter_file is
-- define the new type for the 32*128 register file
type registers_array is array (31 downto 0) of std_logic_vector (127 downto 0);
-- initial values in the resgiter file
signal registers: registers_array :=(   		-- initializes every bit of each register to be 0
	others => (others => '0') );
   
begin
	process(all) 
   --  draft for instruction names: instructionBufferOut, id_if_instructionOut, if_ex_Instruction, ex_wb_instruction 
	begin
		if(WR_en='1') then -- when write enable = 1, 
			-- write back data into Rd in register file at the provided Rd address
			registers(to_integer(unsigned(Rd_addr))) <= Rd_Data;
			
			--for i in 0 to 31 loop
			--	ri <= registers(i);
			-- end loop;
			r0 <= registers(0);
			r1 <= registers(1);
			r2 <= registers(2);
			r3 <= registers(3);
			r4 <= registers(4);
			r5 <= registers(5);
			r6 <= registers(6);
			r7 <= registers(7);
			r8 <= registers(8);
			r9 <= registers(9);
			r10 <= registers(10);
			r11 <= registers(11);
			r12 <= registers(12);
			r13 <= registers(13);
			r14 <= registers(14);
			r15 <= registers(15);
			r16 <= registers(16);
			r17 <= registers(17);
			r18 <= registers(18);
			r19 <= registers(19);
			r20 <= registers(20);
			r21 <= registers(21);
			r22 <= registers(22);
			r23 <= registers(23);
			r24 <= registers(24);
			r25 <= registers(25);
			r26 <= registers(26);
			r27 <= registers(27);
			r28 <= registers(28);
			r29 <= registers(29);
			r30 <= registers(30);
			r31 <= registers(31);
			-- The index of the registers array needs to be integer so
			-- converts addr from std_logic_vector -> Unsigned -> Interger using numeric_std library
		end if;
		R1_out <= registers(to_integer(unsigned(R1_addr)));
		R2_out <= registers(to_integer(unsigned(R2_addr)));
		R3_out <= registers(to_integer(unsigned(R3_addr)));
		
	end process;
	 -- Data to be read out
end comb;