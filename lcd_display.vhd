LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.NUMERIC_STD.ALL;
--USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;
-- SW8 (GLOBAL RESET) resets LCD
ENTITY LCD_Display IS
		
		PORT(reset, clock			: IN	STD_LOGIC;
			sensor1, sensor2			: IN std_logic;
			sensor3, sensor4, sensor5	: IN std_logic;
			switch1, switch2, switch3	: OUT std_logic;
			track1, track2, track3, track4		: OUT std_logic;
			dirA, dirB 					: OUT std_logic_vector(1 DOWNTO 0));
			LCD_RS, LCD_E				: OUT	STD_LOGIC;
			LCD_RW						: OUT   STD_LOGIC;
			DATA_BUS					: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0));
		
END LCD_Display;

ARCHITECTURE a OF LCD_Display IS

TYPE character_string IS ARRAY ( 0 TO 31 ) OF STD_LOGIC_VECTOR( 7 DOWNTO 0 );
TYPE STATE_TYPE IS (HOLD, FUNC_SET, DISPLAY_ON, MODE_SET, Print_String,
LINE2, RETURN_HOME, DROP_LCD_E, RESET1, RESET2, 
RESET3, DISPLAY_OFF, DISPLAY_CLEAR);

-- LCD Display Signals
SIGNAL state, next_command: STATE_TYPE;
SIGNAL LCD_display_string	: character_string;
-- Enter new ASCII hex data above for LCD Display
SIGNAL DATA_BUS_VALUE, Next_Char: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL CLK_COUNT_400HZ: STD_LOGIC_VECTOR(19 DOWNTO 0);
SIGNAL CHAR_COUNT: STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL CLK_400HZ,LCD_RW_INT : STD_LOGIC;
SIGNAL Line1_chars, Line2_chars: STD_LOGIC_VECTOR(127 DOWNTO 0);


-- LCD Display Code for Train Status
LCD_display_string <= (
-- ASCII hex values for LCD Display
-- Enter Live Hex Data Values from hardware here
-- LCD DISPLAYS THE FOLLOWING:
-------------------------
--| sXXXXXtXXXXswXXX   |
--| Train  daXX dbXX   |
-------------------------
-- Line 1
X"73",X"0" & "000" & Sensor5,X"0" & "000" & Sensor4,
X"0" & "000" & Sensor3,X"0" & "000" & Sensor2,X"0" & "000" & Sensor1,
X"74",X"0" & "000" & Track4,X"0" & "000" & Track3,
X"0" & "000" & Track2,X"0" & "000" & Track1,
X"73",X"77",X"0" & "000" & Switch3,X"0" & "000" & Switch2,X"0" & "000" & Switch1,

-- Line 2
X"54",X"72",X"61",X"69",X"6E",X"20",
X"20",X"64",X"61",X"0" & "000" & DIRA(1),X"0" & "000" & DIRA(0),
X"20",X"64",X"62",X"0" & "000" & DIRB(1),X"0" & "000" & DIRB(0));

-- BIDIRECTIONAL TRI STATE LCD DATA BUS
	DATA_BUS <= DATA_BUS_VALUE WHEN LCD_RW_INT = '0' ELSE "ZZZZZZZZ";
-- get next character in display string
	Next_Char <= LCD_display_string(CONV_INTEGER(CHAR_COUNT));
	LCD_RW <= LCD_RW_INT;
LCD_CLOCK: PROCESS
	BEGIN
	 WAIT UNTIL CLOCK'EVENT AND CLOCK = '1';
		IF RESET = '1' THEN
		 CLK_COUNT_400HZ <= X"00000";
		 CLK_400HZ <= '0';
		ELSE
				IF CLK_COUNT_400HZ < X"0EA60" THEN 
				 CLK_COUNT_400HZ <= CLK_COUNT_400HZ + 1;
				ELSE
		    	 CLK_COUNT_400HZ <= X"00000";
				 CLK_400HZ <= NOT CLK_400HZ;
				END IF;
		END IF;
	END PROCESS LCD_CLOCK;
	LCD_ON <= '1';
LCD_DISPLAY:	PROCESS (CLK_400HZ, reset)
	BEGIN
		IF reset = '1' THEN
			state <= RESET1;
			DATA_BUS_VALUE <= X"38";
			next_command <= RESET2;
			LCD_E <= '1';
			LCD_RS <= '0';
			LCD_RW_INT <= '1';

		ELSIF CLK_400HZ'EVENT AND CLK_400HZ = '1' THEN
-- State Machine to send commands and data to LCD DISPLAY			
			CASE state IS
-- Set Function to 8-bit transfer and 2 line display with 5x8 Font size
-- see Hitachi HD44780 family data sheet for LCD command and timing details
				WHEN RESET1 =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"38";
						state <= DROP_LCD_E;
						next_command <= RESET2;
						CHAR_COUNT <= "00000";
				WHEN RESET2 =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"38";
						state <= DROP_LCD_E;
						next_command <= RESET3;
				WHEN RESET3 =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"38";
						state <= DROP_LCD_E;
						next_command <= FUNC_SET;
-- EXTRA STATES ABOVE ARE NEEDED FOR RELIABLE PUSHBUTTON RESET OF LCD
				WHEN FUNC_SET =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"38";
						state <= DROP_LCD_E;
						next_command <= DISPLAY_OFF;
-- Turn off Display and Turn off cursor
				WHEN DISPLAY_OFF =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"08";
						state <= DROP_LCD_E;
						next_command <= DISPLAY_CLEAR;
-- Clear Display and Turn off cursor
				WHEN DISPLAY_CLEAR =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"01";
						state <= DROP_LCD_E;
						next_command <= DISPLAY_ON;
-- Turn on Display and Turn off cursor
				WHEN DISPLAY_ON =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"0C";
						state <= DROP_LCD_E;
						next_command <= MODE_SET;
-- Set write mode to auto increment address and move cursor to the right
				WHEN MODE_SET =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"06";
						state <= DROP_LCD_E;
						next_command <= Print_String;
-- Write ASCII hex character in first LCD character location
				WHEN Print_String =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW_INT <= '0';
-- ASCII character to output
						IF Next_Char(7 DOWNTO  4) /= X"0" THEN
						DATA_BUS_VALUE <= Next_Char;
						ELSE
-- Convert 4-bit value to an ASCII hex digit
							IF Next_Char(3 DOWNTO 0) >9 THEN
-- ASCII A...F
							 DATA_BUS_VALUE <= X"4" & (Next_Char(3 DOWNTO 0)-9);
							ELSE
-- ASCII 0...9
							 DATA_BUS_VALUE <= X"3" & Next_Char(3 DOWNTO 0);
							END IF;
						END IF;
						state <= DROP_LCD_E;
-- Loop to send out 32 characters to LCD Display  (16 by 2 lines)
						IF (CHAR_COUNT < 31) AND (Next_Char /= X"FE") THEN 
						 CHAR_COUNT <= CHAR_COUNT +1;
						ELSE 
						 CHAR_COUNT <= "00000"; 
						END IF;
-- Jump to second line?
						IF CHAR_COUNT = 15 THEN next_command <= line2;
-- Return to first line?
						ELSIF (CHAR_COUNT = 31) OR (Next_Char = X"FE") THEN 
						 next_command <= return_home; 
						ELSE next_command <= Print_String; END IF;
-- Set write address to line 2 character 1
				WHEN LINE2 =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"C0";
						state <= DROP_LCD_E;
						next_command <= Print_String;
-- Return write address to first character postion on line 1
				WHEN RETURN_HOME =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"80";
						state <= DROP_LCD_E;
						next_command <= Print_String;
-- The next three states occur at the end of each command or data transfer to the LCD
-- Drop LCD E line - falling edge loads inst/data to LCD controller
				WHEN DROP_LCD_E =>
						LCD_E <= '0';
						state <= HOLD;
-- Hold LCD inst/data valid after falling edge of E line				
				WHEN HOLD =>
						state <= next_command;
			END CASE;
		END IF;
	END PROCESS LCD_DISPLAY;
END a;