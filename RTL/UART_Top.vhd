-------------------------------------------------------------------------------
--	FILE:			UART_Top.vhd
--
--	DESCRIPTION:	This design is used to implement a UART receiver and
--					transmitter working together.
--
-- 	ENGINEER:		Jordan Christman
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_Top is
generic(
	baud			: integer := 115200;
	clk_freq		: integer := 100000000);	-- 100 MHz
port(
	Rx_data_valid	: out std_logic;
	RxData			: out std_logic_vector(7 downto 0);
	Tx				: out std_logic;
	TxReady			: out std_logic;
	TxData 			: in std_logic_vector(7 downto 0);
	Rx				: in std_logic;
	start_Tx 		: in std_logic;
	reset 			: in std_logic;
	clk 			: in std_logic);
end;

architecture behavior of UART_Top is

-- Transmitter (Tx)
component tUART
generic (
	baud		: integer := 115200;
	clk_rate	: integer := 100000000);
port (
	data_out	: out std_logic;
	tx_ready	: out std_logic;
	start 		: in std_logic;
	data_in 	: in std_logic_vector(7 downto 0);
	reset 		: in std_logic;
	clk 		: in std_logic);
end component;

-- Receiver (Rx)
component rUART
generic (
	baud 		: integer := 115200;
	clk_rate	: integer := 100000000);
port (
	data_out 	: out std_logic_vector(7 downto 0);
	data_valid 	: out std_logic;
	data_in		: in std_logic;
	reset 		: in std_logic;
	clk 		: in std_logic);
end component;

begin
	-- Transmit UART
	transmitter: tUART
		generic map(baud, clk_freq)
		port map(Tx, TxReady, start_Tx, TxData, reset, clk);
	
	-- Receive UART
	receiver: rUART
		generic map(baud, clk_freq)
		port map(RxData, Rx_data_valid, Rx, reset, clk);
		
end behavior;