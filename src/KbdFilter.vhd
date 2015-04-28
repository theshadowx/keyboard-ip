----------------------------------------------------------------------------------
-- Company: 
-- EngINeer: Ali Diouri
-- 
-- Create Date:    20:59:21 05/03/2012 
-- Design Name: 
-- Module Name:    KbdCore - Behavioral 
-- Project Name:   KbdFilter
-- Target Devices: 
-- Tool versions:  XilINx ISE 14.4
-- Description: 
--
-- DepENDencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 


----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;



ENTITY KbdFilter IS
    PORT ( 
                clk				:	IN		STD_LOGIC;
                rst 			:	IN		STD_LOGIC;
                kbdClk			:	IN		STD_LOGIC;
                kbdData			:	IN		STD_LOGIC;
                kbdClkF			:	OUT		STD_LOGIC;
                kbdDataF		:	OUT		STD_LOGIC
            );
END KbdFilter;



ARCHITECTURE Behavioral OF KbdFilter IS

CONSTANT FILTER_WIDTH : INTEGER := 4;

SIGNAL kbd_clkf_reg		:	std_logic_vector(FILTER_WIDTH-1 DOWNTO 0) := (OTHERS => '1');
SIGNAL kbd_Dataf_reg	:	std_logic_vector(FILTER_WIDTH-1 DOWNTO 0) := (OTHERS => '1');


BEGIN

		FilterKbdClk:PROCESS(clk,rst)
				BEGIN
					IF (rst = '1') THEN 
						kbd_clkf_reg <= (OTHERS => '1');
						kbdClkF	     <= '1';
					ELSIF (clk = '1' and clk'Event) THEN
						kbd_clkf_reg <=	kbdClk & kbd_clkf_reg(FILTER_WIDTH-1 DOWNTO 1);
						--clock
						IF (kbd_clkf_reg = X"F") THEN
							kbdClkF	<= '1';
						ELSIF (kbd_clkf_reg = X"0") THEN
							kbdClkF	<= '0';
						END IF;
					END IF;
				END PROCESS;

		FilterKbdData:PROCESS(clk,rst)
				BEGIN
					IF (rst = '1') THEN 
						kbd_dataf_reg <= (OTHERS => '1');
						kbdDataF	  <= '1';
					ELSIF (clk='1' and clk'Event) THEN
						kbd_dataf_reg <= kbdData & kbd_dataf_reg(FILTER_WIDTH-1 DOWNTO 1);
						--data
						IF (kbd_dataf_reg = X"F") THEN
							kbdDataF <= '1';
						ELSIF (kbd_dataf_reg = X"0") THEN
							kbdDataF <= '0';
						END IF;
					END IF;
				END PROCESS;

END Behavioral;

