-- UART_Terminal test bench
-- test_UART.vhd

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

use std.textio.all ;
use ieee.std_logic_textio.all ;
--use work.sim_mem_init.all;

entity test_UART is
end;

architecture test of test_UART is
 
component UART_Wrapper_Top
port (
	Tx		: out std_logic;
    Rx      : in std_logic;
    an 		: out STD_LOGIC_VECTOR ( 3 downto 0 );
    btnC 	: in STD_LOGIC;
    clk 	: in STD_LOGIC;
    dp 		: out STD_LOGIC;
    led 	: out STD_LOGIC_VECTOR ( 15 downto 0 );
    seg 	: out STD_LOGIC_VECTOR ( 6 downto 0 );
    reset 	: in STD_LOGIC);
end component;



-- Simulation signals
signal Rx_sim 	: std_logic := '1';
signal Tx_sim 	: std_logic := '1';
signal an 		: STD_LOGIC_VECTOR ( 3 downto 0 );
signal btnC 	: STD_LOGIC := '0';
signal clk 		: STD_LOGIC := '0';
signal dp 		: STD_LOGIC;
signal led 		: STD_LOGIC_VECTOR ( 15 downto 0 );
signal seg 		: STD_LOGIC_VECTOR ( 6 downto 0 );
signal sw0 		: STD_LOGIC := '0';


begin
	-- UART_Terminal_HDL_Wrapper 
	dev_to_test:  UART_Wrapper_Top  
		port map(
		    Rx => Rx_sim,
		    Tx => Tx_sim,
            an => an,	 
            btnC => btnC,
            clk => clk,
            dp => dp,     
            led => led,     
            seg => seg,     
            reset => sw0  	
		);
	
	-- Generating a system clock
	clk_proc : process
		begin
		wait for 5 ns;
		clk <= not clk;
	end process clk_proc;
	
	stimulus : process
		begin
		
		-- Pull reset line high
		wait for 30 ns;
		sw0 <= '1';
		
		-- Simulate the start button being pressed & released
		wait for 1ms;
		btnC <= '1';
		wait for 100 ns;
		btnC <= '0';
		
		-- Wait for transmission to complete
		wait for 10ms;
		
		-- Simulate "l"
		Rx_sim <= '0';
		wait for 26.04 us;
		Rx_sim <= '1';
		wait for 17.36 us;
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 17.36 us;
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		
		-- Simulate "e"
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		Rx_sim <= '0';
		wait for 17.36 us;
		Rx_sim <= '1';
		wait for 17.36 us;
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		
		-- Simulate "d"
		Rx_sim <= '0';
		wait for 26.04 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		Rx_sim <= '0';
		wait for 17.36 us;
		Rx_sim <= '1';
		wait for 17.36 us;
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		
		-- Simulate " "
		Rx_sim <= '0';
		wait for 52.08 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		Rx_sim <= '0';
		wait for 17.36 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		
		-- Simulate "F"
		Rx_sim <= '0';
		wait for 17.36 us;
		Rx_sim <= '1';
		wait for 17.36 us;
		Rx_sim <= '0';
		wait for 26.04 us;
		Rx_sim <= '1';
		wait for 8.86 us;
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		
		-- Simulate "0"
		Rx_sim <= '0';
		wait for 43.4 us;
		Rx_sim <= '1';
		wait for 17.36 us;
		Rx_sim <= '0';
		wait for 17.36 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		
		-- Simulate "0"
		Rx_sim <= '0';
		wait for 43.4 us;
		Rx_sim <= '1';
		wait for 17.36 us;
		Rx_sim <= '0';
		wait for 17.36 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		
		-- Simulate "F"
		Rx_sim <= '0';
		wait for 17.36 us;
		Rx_sim <= '1';
		wait for 17.36 us;
		Rx_sim <= '0';
		wait for 26.04 us;
		Rx_sim <= '1';
		wait for 8.86 us;
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		
		-- Simulate "CR"
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 17.36 us;
		Rx_sim <= '0';
		wait for 34.72 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		
		-----------------------------------------------------------------------
		
		-- Simulate "7"
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 26.04 us;
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 17.36 us;
		Rx_sim <= '0';
		wait for 17.36 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		
		-- Simulate "s"
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 17.36 us;
		Rx_sim <= '0';
		wait for 17.36 us;
		Rx_sim <= '1';
		wait for 26.04 us;
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		
		-- Simulate "e"
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		Rx_sim <= '0';
		wait for 17.36 us;
		Rx_sim <= '1';
		wait for 17.36 us;
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		
		-- Simulate "g"
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 26.04 us;
		Rx_sim <= '0';
		wait for 17.36 us;
		Rx_sim <= '1';
		wait for 17.36 us;
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		
		-- Simulate " "
		Rx_sim <= '0';
		wait for 52.08 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		Rx_sim <= '0';
		wait for 17.36 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		
		-- Simulate "1"
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		Rx_sim <= '0';
		wait for  26.04us;
		Rx_sim <= '1';
        wait for  17.36 us;
		Rx_sim <= '0';
		wait for  17.36 us;
        Rx_sim <= '1';
		wait for 8.68 us;
		
		-- Simulate "2"
		Rx_sim <= '0';
		wait for 17.36 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		Rx_sim <= '0';
		wait for 17.36 us;
		Rx_sim <= '1';
		wait for 17.36 us;
		Rx_sim <= '0';
		wait for 17.36 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		
		-- Simulate "0"
		Rx_sim <= '0';
		wait for 43.4 us;
		Rx_sim <= '1';
		wait for 17.36 us;
		Rx_sim <= '0';
		wait for 17.36 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		
		-- Simulate "7"
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 26.04 us;
		Rx_sim <= '0';
		wait for 8.68 us;
		Rx_sim <= '1';
		wait for 17.36 us;
		Rx_sim <= '0';
		wait for 17.36 us;
		Rx_sim <= '1';
		wait for 8.68 us;
		
		-- Simulate "CR"
        Rx_sim <= '0';
        wait for 8.68 us;
        Rx_sim <= '1';
        wait for 8.68 us;
        Rx_sim <= '0';
        wait for 8.68 us;
        Rx_sim <= '1';
        wait for 17.36 us;
        Rx_sim <= '0';
        wait for 34.72 us;
        Rx_sim <= '1';
        wait for 8.68 us;
        
        wait for 5ms;
		
		-- Report that UART Terminal has completed
		report "UART Terminal Test Completed";
	end process stimulus;
end test;
