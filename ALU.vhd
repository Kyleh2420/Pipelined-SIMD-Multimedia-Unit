----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/17/2023 06:40:40 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity instructionSetR3 is
    generic(n: integer := 16);
    Port ( wordIn : in STD_LOGIC_VECTOR (23 downto 0);
           rs2 : in STD_LOGIC_VECTOR (127 downto 0);
           rd : out STD_LOGIC_VECTOR (127 downto 0);
           rs1 : in STD_LOGIC_VECTOR (127 downto 0));
end instructionSetR3;


architecture Behavioral of instructionSetR3 is

--------Procedure to compute the bitwiseOR used in R3 instruction type------

    procedure bitwiseOR(signal r1, r2: in std_logic_vector(n-1 downto 0);
                        signal rd: out std_logic_vector(n-1 downto 0)) is
    begin
        rd <= r1 or r2;
              
    end bitwiseOR;
 ----------------------------------------------------------------------------
 
 --------Procedure to compute the bitwiseAND used in R3 instruction type------

    procedure bitwiseAND(signal r1, r2: in std_logic_vector(n-1 downto 0);
                        signal rd: out std_logic_vector(n-1 downto 0)) is
    begin
        rd <= r1 and r2;
              
    end bitwiseAND;
 ----------------------------------------------------------------------------


--Enumerate the various options available
--NUL is our effective NULL, since that is a reserved keyword. In our case, NUL means that option is not selected
type OPCODE is (NOP, SHRHI, AU, CNT1H, AHS, ORopcode, BCW, MAXWS, MINWS, MLHU, MLHSS, ANDopcode, INVB, ROTW, SFWU, SFHS, NUL);

type r4Format is(intMulAddLo, intMulAddHi, intMulSubLo, intMulSubHi, longMulAddLo, longMulAddHi, longMulSubLo, longMulSubHi, NUL);

      signal selectOpcode : OPCODE;
      signal r4: r4Format;
      
    
      
      
begin
    ALU: process (all)
    
    -- For Load Immediate
    variable loadIndex: integer;
    variable immValue: std_logic_vector(15 downto 0);
    
    begin
    if (wordIn(24) = '0') then
    --If wordIn[24] == 0, then we load Immediate
    
    --Load a 16-bit Immediate value from the [20:5] instruction field into the 16-bit field specified by the Load Index field [23:21] of the 128-bit register rd. 
    --Other fields of register rd are not changed. Note that a LI instruction first reads register rd and then (after inserting an immediate value into one of its fields) 
    --writes it back to register rd, i.e., register rd is both a source and destination register of the LI instruction!
    
    
--    There are 8 different 16 bit sections of the register Rd. 
--     +127--112|111----96|95----80|79-----64|63-----48|47-----32|31-----1|15-----8|7------0+
--     |    8        7         6        5         4        3         2         1        0   |
--     +------------------------------------------------------------------------------------+

    --Breakdown the wordIn(23:21) into its integer counterpart
    loadIndex := to_integer(unsigned(wordIn(23 downto 21)));
    
    --Store the immediate value
    immValue := wordIn(20 downto 5);
    
    --Write it to the paticular register index required
    rd(loadIndex*16-1 downto (loadIndex-1)*16) <= immValue;
  
    
    elsif (wordIn(23) = '0') then
    --Otherwise, we're at 10: Instruction is R4 type
        case wordIn(22 downto 20) is
            when "000" => r4 <= intMulAddLo;
            when "001" => r4 <= intMulAddHi;
            when "010" => r4 <= intMulSubLo;
            when "011" => r4 <= intMulSubHi;
            when "100" => r4 <= longMulAddLo;
            when "101" => r4 <= longMulAddHi;
            when "110" => r4 <= longMulSubLo;
            when "111" => r4 <= longMulSubHi;
            when others => r4 <= NUL;
        end case;
      
    else 
    --Otherwise, we're at 11: Instruction is R3 type
    
        --Figure out what opcode the R3 instruction type is telling us to do.
        case wordIn(18 downto 15) is
            when "0000" => selectOpcode <= NOP;
            when "0001" => selectOpcode <= SHRHI;
            when "0010" => selectOpcode <= AU;
            when "0011" => selectOpcode <= CNT1H;
            when "0100" => selectOpcode <= AHS;
            when "0101" => bitwiseOR(rs1, rs2, rd);
            when "0110" => selectOpcode <= BCW;
            when "0111" => selectOpcode <= MAXWS;
            when "1000" => selectOpcode <= MINWS;
            when "1001" => selectOpcode <= MLHU;
            when "1010" => selectOpcode <= MLHSS;
            when "1011" => bitwiseAND(rs1, rs2, rd);
            when "1100" => selectOpcode <= INVB;
            when "1101" => selectOpcode <= ROTW;
            when "1110" => selectOpcode <= SFWU;
            when "1111" => selectOpcode <= SFHS;
            when others => selectOpcode <= NUL;
        end case;
        
        
    
    end if;
    
    end process;

end Behavioral;
