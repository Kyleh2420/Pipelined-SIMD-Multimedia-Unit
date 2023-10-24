--Kyle Han
--ESE 382: Digital System Design using VHDL and PLDs 
--Lab 10: Direct Digital Synthesis System with Frequency Selection
--Task 4: Phase Accumulator FSM Testbench

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity phaseAccTB is
end phaseAccTB;

architecture testbench of phaseAccTB is
    signal clkTB: std_logic := '0'; --Sys Clock
    signal reset_barTB: std_logic:= '0'; --Asynch Reset
    signal maxTB: std_logic := '0'; --max Count
    signal minTB: std_logic := '0'; --min Count
    signal upTB: std_logic; --Count Direction
    signal posTB: std_logic; --

    constant period: time := 10ns;
begin
    uut: entity phase_accumulator_fsm port map(clk => clkTB, reset_bar => reset_barTB, max => maxTB, min => minTB, up => upTB, pos => posTB);
    reset_barTB <= '0', '1' after 4*period;
    maxTB <= '0', '1' after 100* period, '0' after 110* period, '1' after 400*period, '0' after 410*period;
    minTB <= '0', '1' after 200* period, '0' after 210*period, '1' after 500* period, '0' after 510*period;

    clk: process
    begin
        for i in 0 to 2048 loop
            wait for period;
            clkTB <= not clkTB;
        end loop;
        std.env.finish; 
	end process;
end testbench;

