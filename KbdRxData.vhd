----------------------------------------------------------------------------------
-- Company: 
-- EngINeer: Ali Diouri
-- 
-- Create Date:    20:59:21 05/03/2012 
-- Design Name: 
-- Module Name:    KbdCore - Behavioral 
-- Project Name:   KbdRxData
-- Target Devices: 
-- TOol versions:  XilINx ISE 14.4
-- Description: 
--
-- DepENDencies: 
--
-- RevISion: 
-- RevISion 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;


entity KbdRxData IS
Port ( 
                clk         : IN  STD_LOGIC;
                rst         : IN  STD_LOGIC;
                kbd_Data    : IN  STD_LOGIC;
                kbd_clk     : IN  STD_LOGIC;
                Rx_en       : IN  STD_LOGIC;
                dataValid   : OUT STD_LOGIC;
                busy        : OUT STD_LOGIC;
                Data        : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
         );
END KbdRxData;

ARCHITECTURE Behavioral OF KbdRxData IS

SIGNAL tmpData11            : std_logic_vecTOr(0 TO 10);
SIGNAL count                : std_logic_vecTOr(3 DOWNTO 0);
SIGNAL dataSTOred           : std_logic;
SIGNAL startGet             : std_logic;


BEGIN

PROCESS (clk,rst)
BEGIN
    IF (rst ='1') THEN
        dataSTOred <= '0';
        startGet   <= '0';
        count      <= (OTHERS=>'0');
        tmpData11  <= (OTHERS=>'0');
    ELSIF (clk='1' and clk'Event) THEN
        IF (Rx_en = '1') THEN
            IF (startGet = '0') THEN
                IF (kbd_data = '0') THEN
                    startGet <= '1';
                ELSE 
                    startGet <= '0';
                END IF;
            ELSIF(kbd_clk = '0') THEN
                IF (dataSTOred = '0') THEN
                    count      <= count + conv_std_logic_vecTOr(1,count'LENGTH);
                    tmpData11  <= kbd_Data & tmpData11(0 TO 9);
                    dataSTOred <= '1';
                END IF;
            ELSIF(kbd_clk = '1') THEN
                dataSTOred <= '0';
                IF(count = conv_std_logic_vecTOr(11,count'LENGTH)) THEN
                    startGet <= '0';
                    count    <= (OTHERS=>'0');
                END IF;
            END IF;
        ELSE
        END IF;
    END IF;
END PROCESS;


PROCESS(rst, clk)
BEGIN
    IF(rst = '1') THEN
        busy      <= '0';
        dataValid <= '0';
        Data      <= (OTHERS=>'0');
    ELSIF (clk = '1' and clk'Event) THEN
        busy      <= startGet;
        Data      <= (OTHERS=>'0');
        dataValid <= '0';
        IF (count = conv_std_logic_vecTOr(11,count'LENGTH)) and (kbd_clk = '1') THEN
            data <= tmpData11(2 TO 9);
            dataValid <= '1';
        END IF;
    END IF;
END PROCESS;



END Behavioral;
