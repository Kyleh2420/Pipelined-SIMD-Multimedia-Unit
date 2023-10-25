--Kyle Han
--ESE 382: Digital System Design using VHDL and PLDs 
--Lab 10: Direct Digital Synthesis System with Frequency Selection
--Task 3: Phase Accumulator TB


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity phaseAccumulatorTB is
    generic(
        a: positive := 14;
        m: positive := 7
    );
end phaseAccumulatorTB;

architecture behavioral of phaseAccumulatorTB is
    signal clkTB: std_logic := '0';
    signal resetBarTB: std_logic := '0';
    signal upTB: std_logic := '0';
    signal dTB: std_logic_vector(a-1 downto 0) := (others => '0');
    signal maxTB, minTB: std_logic := '0';
    signal qTB: std_logic_vector(m-1 downto 0);

    constant period: time := 10ns;

    begin
    uut: entity phase_accumulator port map(clk => clkTB, reset_bar => resetBarTB, up => upTB, d => dTB, max => maxTB, min => minTB, q => qTB);

    resetBarTB <= '0', '1' after 4*period, '0' after 2000 * period, '1' after 2004*period;
    upTB <= '1', '0' after 500*period, '1' after 1000*period;

    clock: process
    begin
        for i in 0 to 10000 loop
            wait for period;
            clkTB <= not clkTB;
        end loop;
        std.env.finish;
    end process;

    changeD: process
    variable i: std_logic_vector(a-1 downto 0) := (others => '0');
    begin
        for j in 0 to 2048 loop
            dTB <= i;
            wait for period * 4.3;
            if unsigned(i) > 10 then
                i := (others => '0');
            else
                i := std_logic_vector(unsigned(i) + '1');
			end if;
        end loop;
    end process;

end behavioral;