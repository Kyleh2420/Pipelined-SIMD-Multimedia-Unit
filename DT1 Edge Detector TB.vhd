--Kyle Han
--ESE 382: Lab 10
--Lab 10: Direct Digital Synthesis System with Frequency Selection
--DT1: Edge Detector Testbench
--Non self checking testbench 

library ieee;
use ieee.std_logic_1164.all;
use work.all;

entity edgeDetectTB is
end edgeDetectTB;

architecture testbench of edgeDetectTB is
    signal resetBarTB, sigEdgeTB: std_logic;
    signal clkTB: std_logic := '0';
	signal posTB: std_logic := '0';
	signal sigTB: std_logic := '0';
    constant period : time := 10ns;
begin
    uut: entity edge_det port map (rst_bar => resetBarTB, clk => clkTB, sig => sigTB, pos => posTB, sig_edge => sigEdgeTB);
    resetBarTB <= '0', '1' after 4 * period;


    clock: process
    begin
        for i in 0 to 2048 loop
            wait for period;
            clkTB <= not clkTB;
        end loop;
        std.env.finish;
    end process;
	
	sigIn: process
	begin
		for i in 0 to 2048 loop
			wait for period * 5.3;
			sigTB <= not sigTB;
		end loop;
	end process; 
	
	posIn: process
	begin
		for i in 0 to 2048 loop	
			wait for period;
			if (i = 1019) then 
				posTB <= not posTB;
			end if;
		end loop;
	end process;
	
end testbench;
