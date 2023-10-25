--Kyle Han
--ESE 382: Digital System Design using VHDL and PLDs 
--Lab 10: Direct Digital Synthesis System with Frequency Selection
--Task 2: Frequency Register Testbench


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;


entity frequency_regTB is
	generic (a: positive := 14);
end frequency_regTB;

architecture testbench of frequency_regTB is
    signal loadTB: std_logic := '0';
    signal clkTB: std_logic := '0';
    signal reset_barTB: std_logic := '0';
    signal dTB: std_logic_vector(a-1 downto 0) := (others => '0');
    signal qTB: std_logic_vector(a-1 downto 0);

    constant period : time := 10ns;
    begin
    uut: entity frequency_reg port map(load => loadTB, clk => clkTB, reset_bar => reset_barTB, d => dTB, q => qTB);
    reset_BarTB <= '0', '1' after 4* period, '0' after 1000 * period, '1' after 1004 * period;

    clock: process
    begin
        for i in 0 to 4096 loop
            wait for period;
            clkTB <= not clkTB;
        end loop;
        std.env.finish;
    end process;

    dValue: process
    begin
        dTB <= (others => '0');
        for i in 0 to 4096 loop
            dTB <= std_logic_vector(unsigned(dTB) + 1);
			wait for period*1.1;
        end loop;
    end process;
	
	loadValue: process
	begin
		for i in 0 to 1024 loop
			loadTB <= not loadTB;
			wait for period * 21.3;
		end loop;
	end process;


end testbench;