-------------------------------------------------------------------------------
--	FILE:			UART_Controller_Top.vhd
--
--	DESCRIPTION:	This design is used to control a UART IP core. The UART 
--					controller interprets commands to light LED's or
--					the 7 segment display.
--
-- 	ENGINEER:		Jordan Christman
-------------------------------------------------------------------------------
-- Libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_Controller_Top is
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
end UART_Controller_Top;

architecture behavior of UART_Controller_Top is
-------------------------------------------------------------------------------
-- 								Constants
-------------------------------------------------------------------------------
constant maxcount				: integer := 200000;	-- 7 Seg display counter
constant max_instruction_count	: integer := 50;		-- Instruction Transmit Counter
constant max_error_count		: integer := 30;  		-- Error Message counter

-- UART Special Characters Carriage Return (CR) and Line Feed (LF)
constant CR		: std_logic_vector(7 downto 0) := x"0D";	
constant LF		: std_logic_vector(7 downto 0) := x"0A";
constant SPACE	: std_logic_vector(7 downto 0) := x"20";
-------------------------------------------------------------------------------
-- 								Signals
-------------------------------------------------------------------------------
-- State Machine Control Signals
signal invalid_command		: std_logic := '0';
signal invalid_args			: std_logic := '0';
signal command_received		: std_logic := '0';
signal args_received		: std_logic := '0';
signal command_complete		: std_logic := '0';
signal transmit_complete	: std_logic := '0';
signal start_controller		: std_logic := '0';

-- Command and Argument Storage Registers
signal command_reg		: std_logic_vector(31 downto 0) := x"30303030";
signal arg_reg			: std_logic_vector(31 downto 0) := x"30303030";

-- Start Controller Signals
signal start_lead			: std_logic := '0';
signal start_follow			: std_logic := '0';

signal read_rx_data			: std_logic := '0';
signal read_rx_lead			: std_logic := '0';
signal read_rx_follow		: std_logic := '0';

-- State Machine Signals
type state_type is(init_state, transmit_instructions_state, 
	transmit_error_msg_state, wait_for_cmd_state, wait_for_args_state, 
	execute_cmd_state);	
signal state, nxt_state		: state_type;

-- 7 Segment display control signals
signal Seg_0	: std_logic_vector(6 downto 0) := "1000000";
signal Seg_1	: std_logic_vector(6 downto 0) := "1000000";
signal Seg_2	: std_logic_vector(6 downto 0) := "1000000";
signal Seg_3	: std_logic_vector(6 downto 0) := "1000000";

-- a 27-bit counter is required to count to 100000000 (100 million/ 100 MHz)
-- we will be counting to 200,000 to achieve a 500Hz refresh rate 
signal counter	: unsigned(26 downto 0) := to_unsigned(0, 27);
signal toggle	: std_logic_vector(3 downto 0) := "0111";

-- 7 segment display signals
signal seg_0_ascii 	: std_logic_vector(7 downto 0) := x"30"; -- ASCII 0 value
signal seg_1_ascii 	: std_logic_vector(7 downto 0) := x"30";
signal seg_2_ascii 	: std_logic_vector(7 downto 0) := x"30";
signal seg_3_ascii 	: std_logic_vector(7 downto 0) := x"30";

-- LED Driver Signals
signal LED_0		: std_logic_vector(3 downto 0) := "0000";
signal LED_1		: std_logic_vector(3 downto 0) := "0000";
signal LED_2		: std_logic_vector(3 downto 0) := "0000";
signal LED_3		: std_logic_vector(3 downto 0) := "0000";
signal led_0_ascii	: std_logic_vector(7 downto 0) := x"30"; -- Initial value 0 in ASCII
signal led_1_ascii	: std_logic_vector(7 downto 0) := x"30";
signal led_2_ascii	: std_logic_vector(7 downto 0) := x"30";
signal led_3_ascii	: std_logic_vector(7 downto 0) := x"30";

-- Block RAM Signals
signal bram_data_reg		: std_logic_vector(7 downto 0);
signal bram_address_reg		: std_logic_vector(8 downto 0) := (others => '0');

-- Transmit Instruction Signals
signal instruction_count	: integer range 0 to 255 := 0; -- We need 101 so 256 to be safe
signal error_count			: integer range 0 to 127 := 0; -- We need 64 so 127 to be safe
signal clock_count			: integer range 0 to 7 := 0; -- We need 2 so 7 to be safe

-- Receive Instruction Signal
signal two_clock_count		: integer range 0 to 7 := 0;	

-- Start Transmitter register
signal start_tx_data_reg    : std_logic := '0';
signal first_address        : std_logic := '1';     -- Indicates when first address goes through (we wait 3 clock cycles)

-- Wait for 2 clock cycles to have passed
signal two_clocks_passed    	: std_logic := '0';     -- Indicate two clock cycles have passed
signal enable_clock_count   	: std_logic := '0';     -- Enable's the clock count process
signal address_incremented  	: std_logic := '0';     -- Has the address been incremented
signal two_clock_cycles			: std_logic := '1';		-- Rx two clock cycles
signal enable_two_clock_cycles	: std_logic := '1';



-------------------------------------------------------------------------------
-- 						Component Instantiations
-------------------------------------------------------------------------------
-- decimal_ascii_to_7seg
component decimal_ascii_to_7seg
port(
	seg_out			: out std_logic_vector(6 downto 0);	-- 7 Seg display number output
    ascii_in        : in std_logic_vector(7 downto 0);    -- ASCII data input
    clk             : in std_logic);
end component;

-- hex_ascii_to_slv
component hex_ascii_to_slv
port(
	slv_out			: out std_logic_vector(3 downto 0);	-- 7 Seg display number output
    ascii_in        : in std_logic_vector(7 downto 0));    -- ASCII data input
end component;




-------------------------------------------------------------------------------
-- 						UART Controller Architecture
-------------------------------------------------------------------------------
begin



	-- Set the LED register to the LED outputs
	led <= LED_3 & LED_2 & LED_1 & LED_0;
	
	-- LED display Drivers
	led0 : hex_ascii_to_slv
		port map(LED_0, led_0_ascii);
		
	led1 : hex_ascii_to_slv
		port map(LED_1, led_1_ascii);
		
	led2 : hex_ascii_to_slv
		port map(LED_2, led_2_ascii);
		
	led3 : hex_ascii_to_slv
		port map(LED_3, led_3_ascii);	
	
	-- 7 Segment display drivers
	seg0 : decimal_ascii_to_7seg
		port map(Seg_0, seg_0_ascii, clk);
		
	seg1 : decimal_ascii_to_7seg
		port map(Seg_1, seg_1_ascii, clk);
		
	seg2 : decimal_ascii_to_7seg
		port map(Seg_2, seg_2_ascii, clk);

	seg3 : decimal_ascii_to_7seg
		port map(Seg_3, seg_3_ascii, clk);
		
	-- Anode segment drivers
	an <= toggle;
	
	-- Set decimal place to off
	dp <= '1';
	
	-- Set the start Tx signal
	start_tx_data <= start_tx_data_reg;
	
	-- Counter to create 60Hz and shift toggle bits
	counter_proc: process(clk)
	begin
		if(rising_edge(clk)) then
			if(reset = '0' or counter = maxcount) then
				counter <= (others => '0');
				toggle(0) <= toggle(3);
				toggle(1) <= toggle(0);
				toggle(2) <= toggle(1);
				toggle(3) <= toggle(2);
			else
				counter <= counter + 1;
			end if;
		end if;
	end process counter_proc;	
	
	-- Toggle the seven segment displays
	toggle_proc: process(toggle)
	begin
		if(toggle(0) = '0') then
			seg <= Seg_0;
		elsif(toggle(1) = '0') then
			seg <= Seg_1;
		elsif(toggle(2) = '0') then
			seg <= Seg_2;
		else
			seg <= Seg_3;
		end if;
	end process toggle_proc;
	
	---------------------------------------------------------------------------
    -- Clock counting process
    ---------------------------------------------------------------------------
    two_clocks_passed_proc: process(clk)
    begin
        if(rising_edge(clk)) then
            if(enable_clock_count = '1') then
                if(clock_count = 2) then
                    two_clocks_passed <= '1';
                    clock_count <= 0;
                else
                    clock_count <= clock_count + 1;
                    two_clocks_passed <= '0';
                end if;
                
            else
                two_clocks_passed <= '0';
            end if;
        end if;
    end process two_clocks_passed_proc;
	
	---------------------------------------------------------------------------
	-- Tx Process
	---------------------------------------------------------------------------
	-- BRAM DATA
	bram_data_reg <= bram_data;
	data_to_tx <= bram_data_reg;
	
	-- BRAM ADDRESSING
	bram_address_reg <= std_logic_vector(to_unsigned(instruction_count + error_count, bram_address_reg'length));
	bram_address <= bram_address_reg;
	
	tx_proc: process(clk)
	begin
		if(rising_edge(clk)) then
		
		    if(state = wait_for_cmd_state) then
		      transmit_complete <= '0';
		      --first_address <= 0;
		    end if;
		
			if(state = transmit_instructions_state) then
				if(tx_ready = '1') then
					if(instruction_count < max_instruction_count and first_address = '0') then
					   if(address_incremented = '1') then
					       if(two_clocks_passed = '1') then
					           enable_clock_count <= '0'; -- stop clock counting
					           start_tx_data_reg <= '1';   -- Start the Tx data transfer
					           address_incremented <= '0'; -- clear address increment
					       else
					           enable_clock_count <= '1'; -- start clock counting
					       end if;
					   else
					      instruction_count <= instruction_count + 1;	-- increment address counter
					      address_incremented <= '1';  -- indicate address has been incremented
					   end if; 						 
					else
					   start_tx_data_reg <= '1';   -- Start the UART data transmission
					   first_address <= '0';  -- Indicate we've passed the first address
					end if;	
				else
					start_tx_data_reg <= '0';
				end if;
				
				if(instruction_count = max_instruction_count) then
				    transmit_complete <= '1';   -- Indicate the transfer is complete
				end if;	
			end if;
			
			if(state = transmit_error_msg_state) then
				if(tx_ready = '1') then
					if(error_count < max_error_count) then
						if(address_incremented = '1') then
							if(two_clocks_passed = '1') then
								enable_clock_count <= '0';	-- stop clock counter
								start_tx_data_reg <= '1';	-- start TX data transfer
								address_incremented <= '0'; -- clear address incremented
							else
								enable_clock_count <= '1';	-- start clock counter
							end if;
						else
							error_count <= error_count + 1; -- Increment Error Counter
							address_incremented <= '1';  -- indicate address has been incremented
						end if;	
					end if;
				else
					start_tx_data_reg <= '0';
				end if;
				
				if(error_count = max_error_count) then
				    transmit_complete <= '1';
				end if;
				
			else
				error_count <= 0; -- Reset Error Count
			end if;
			
		end if;
	end process tx_proc;
	
	---------------------------------------------------------------------------
	-- Rx Process
	---------------------------------------------------------------------------
	rx_proc: process(clk)
	begin
		if(rising_edge(clk)) then
			if(state = wait_for_cmd_state) then
				if(read_rx_data = '1') then
					-- Once a " " is received send signal
					if(rx_input_data = SPACE) then
						command_received <= '1';
					else
						-- Store Message onto command register 
						command_reg(7 downto 0) <= rx_input_data;
						
						-- Shift results onto command register
						command_reg(15 downto 8) <= command_reg(7 downto 0);
						command_reg(23 downto 16) <= command_reg(15 downto 8);
						command_reg(31 downto 24) <= command_reg(23 downto 16);
					end if;
					
				end if;
			end if;
			
			if(state = wait_for_args_state) then
				if(read_rx_data = '1') then
					-- Once a CR or LF is received send signal
					if(rx_input_data = CR or rx_input_data = LF) then
						-- Send signal to execute the command
						args_received <= '1';
					else
						-- Store Arguments onto Argument register
						arg_reg(7 downto 0) <= rx_input_data;
						
						-- Shift results onto argument register
						arg_reg(15 downto 8) <= arg_reg(7 downto 0);
						arg_reg(23 downto 16) <= arg_reg(15 downto 8);
						arg_reg(31 downto 24) <= arg_reg(23 downto 16);
					end if;	
				end if;
				
				command_received <= '0';	-- clear command signal
				
			else
				args_received <= '0';	-- Clear args_received signal
			end if;
			
			if(command_complete = '1') then
				command_reg <= x"30303030"; -- what is all zero's in ASCII (hex) ???
				arg_reg <= x"30303030";
			end if;
		end if;
	end process rx_proc;
	
	---------------------------------------------------------------------------
	-- Execute Command Process
	---------------------------------------------------------------------------
	execute_cmd_proc: process(clk, command_reg)
	begin
		if(rising_edge(clk)) then
			if(state = execute_cmd_state) then
			
				case command_reg is
					when x"306c6564" =>
						-- Set LED Outputs (led)
						-- Set LED outputs here!
						led_0_ascii <= arg_reg(7 downto 0);
						led_1_ascii <= arg_reg(15 downto 8);
						led_2_ascii <= arg_reg(23 downto 16);
						led_3_ascii <= arg_reg(31 downto 24);
						
					when x"37736567" =>
						seg_0_ascii <= arg_reg(7 downto 0);
                        seg_1_ascii <= arg_reg(15 downto 8);
                        seg_2_ascii <= arg_reg(23 downto 16);
                        seg_3_ascii <= arg_reg(31 downto 24);
						
					when others =>
						-- Go to transmit_error_msg_state
						invalid_command <= '1';
				end case;
				
				command_complete <= '1';
	
	        else
	           command_complete <= '0';
               invalid_command <= '0';
               
			end if;		
		end if;
	end process execute_cmd_proc;
	
	---------------------------------------------------------------------------
	-- Start Transmitting Signal Process
	---------------------------------------------------------------------------
	start_controller <= start_lead and (not start_follow);	-- Start Tx instructions
	read_rx_data <= read_rx_lead and (not read_rx_follow);	-- Read input Rx data
	start_controller_proc: process (clk)
	begin
		if(rising_edge(clk)) then
			if(reset = '0') then
				start_lead <= '0';
				start_follow <= '0';
				read_rx_lead <= '0';
				read_rx_follow <= '0';
			else
				start_lead <= btnC;
				start_follow <= start_lead;
				read_rx_lead <= rx_data_rdy;
				read_rx_follow <= read_rx_lead;
			end if;
		end if;
	end process start_controller_proc;
	
	---------------------------------------------------------------------------
	-- State Machine Processes
	---------------------------------------------------------------------------
	state_proc : process(clk)
	begin
		if(rising_edge(clk)) then
			if(reset = '0') then
				state <= init_state;
			else
				state <= nxt_state;
			end if;
		end if;
	end process state_proc;

	---------------------------------------------------------------------------
	-- Next State Process
	---------------------------------------------------------------------------
	nxt_state_proc : process(state, start_controller, transmit_complete, command_received, 
	                         invalid_command, args_received, invalid_args, command_complete)
	begin
		nxt_state <= state;
		
		-- Fill out and complete the state machine using the state machine diagram!
		case state is
			when init_state => 
			     if(start_controller = '1') then			     
                    nxt_state <= transmit_instructions_state;
                 else
                    nxt_state <= init_state;
                 end if;
                 
			when transmit_instructions_state =>
			     if(transmit_complete = '1') then
			        nxt_state <= wait_for_cmd_state;
                 else
                    nxt_state <= transmit_instructions_state;
                 end if;

			when wait_for_cmd_state =>
                if(command_received = '1') then
                   nxt_state <= wait_for_args_state;
                else
                   nxt_state <= wait_for_cmd_state;
                end if;

			when wait_for_args_state =>
                if(args_received = '1') then
                   nxt_state <= execute_cmd_state;
                else
                   nxt_state <= wait_for_args_state;
                end if;

			when execute_cmd_state =>
			    if(command_complete = '1') then
                   nxt_state <= wait_for_cmd_state;
                elsif (invalid_args = '1') then
                   nxt_state <= transmit_error_msg_state;
                else
                   nxt_state <= execute_cmd_state;
                end if;

			when transmit_error_msg_state =>
                if(transmit_complete = '1') then
                    nxt_state <= wait_for_cmd_state;
                else
                    nxt_state <= transmit_error_msg_state;
                end if;

			when others =>
				nxt_state <= init_state;
		end case;
	end process nxt_state_proc;	
	
end behavior;