-------------------------------------------------------------------------------
--	FILE:			UART_Wrapper_Top
--
--	DESCRIPTION:	Top Level, connects the UART to the controller
--
-- 	ENGINEER:		Leszek Nowak
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_Wrapper_Top is
generic(
	baud			: integer := 115200;
	clk_freq		: integer := 100000000);	-- 100 MHz
port(	
	Tx				: out std_logic;
	Rx				: in std_logic;
	reset 			: in std_logic;
	clk 			: in std_logic;
	btnC			: in std_logic;	
	-- 7 Segment Display Output
    seg             : out std_logic_vector(6 downto 0);    
    -- 7 Segment Display Decimal Point
    dp              : out std_logic;
    -- Selects Digit    
    an              : out std_logic_vector(3 downto 0);
    -- LED's
    led             : out std_logic_vector(15 downto 0));
end UART_Wrapper_Top;

architecture behavior of UART_Wrapper_Top is

signal rx_data_valid		: std_logic := '0';
signal rx_data              : std_logic_vector(7 downto 0);
signal tx_data              : std_logic_vector(7 downto 0);
signal start_tx_data		: std_logic := '0';
signal tx_ready     		: std_logic := '0';
signal bram_data            : std_logic_vector(7 downto 0) := x"55";
signal bram_address         : std_logic_vector(8 downto 0) := (others => '0');

-- Transmitter (Tx)
component UART_Controller_Top
port(
    seg             : out std_logic_vector(6 downto 0);    
    -- 7 Segment Display Decimal Point
    dp              : out std_logic;
    -- Selects Digit    
    an              : out std_logic_vector(3 downto 0);
    -- LED's
    led             : out std_logic_vector(15 downto 0);
	-- Data to Tx
	data_to_tx		: out std_logic_vector(7 downto 0);
	-- Start Transmitting Data
	start_tx_data	: out std_logic;
	
	-- BRAM Address & Data
	bram_address	: out std_logic_vector(8 downto 0);
	bram_data		: in std_logic_vector(7 downto 0);
	
	-- UART Controller
	tx_ready		: in std_logic;
	btnC			: in std_logic;
	rx_input_data	: in std_logic_vector(7 downto 0);
	rx_data_rdy		: in std_logic;
	reset			: in std_logic;
	clk				: in std_logic);
end component;

-- Receiver (Rx)
component UART_Top
generic (
	baud			: integer := 115200;
    clk_freq        : integer := 100000000);    -- 100 MHz
port(
    Rx_data_valid    : out std_logic;
    RxData           : out std_logic_vector(7 downto 0);
    Tx               : out std_logic;
    TxReady          : out std_logic;
    TxData           : in std_logic_vector(7 downto 0);
    Rx               : in std_logic;
    start_Tx         : in std_logic;
    reset            : in std_logic;
    clk              : in std_logic);
end component;

begin

	
	-- Controller
	myUART: UART_Top		
	   generic map(baud, clk_freq)
	   port map(rx_data_valid,rx_data,Tx,tx_ready,tx_data,Rx,start_tx_data,reset,clk);
		
	-- Uart
	myController: UART_Controller_Top
		
		port map(
            data_to_tx => tx_data,
            start_tx_data => start_tx_data,
            tx_ready => tx_ready,
            btnC => btnC,
            rx_input_data => rx_data,
            rx_data_rdy => rx_data_valid,
            reset => reset,
            clk => clk,
            
            bram_address => bram_address,
            bram_data => bram_data,
            
            seg => seg,
            led => led,
            an => an,
            dp => dp
		);
		

		
end behavior;