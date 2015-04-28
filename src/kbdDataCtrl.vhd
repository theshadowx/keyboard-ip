----------------------------------------------------------------------------------
-- Company: 
-- EngINeer: Ali Diouri
-- 
-- Create Date:    20:59:21 05/03/2012 
-- Design Name: 
-- Module Name:    KbdCore - Behavioral 
-- Project Name:   KbdDataCtrl
-- Target Devices: 
-- Tool versions:  XilINx ISE 14.4
-- Tool versions: 
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



ENTITY KbdDataCtrl IS
PORT ( 
    clk             : IN    STD_LOGIC;
    rst             : IN    STD_LOGIC;
    busyRx          : IN    STD_LOGIC;
    busyTx          : IN    STD_LOGIC;
    validDataKb     : IN    STD_LOGIC;
    dataINIBuff     : IN    STD_LOGIC;
    DataFromKb      : IN    STD_LOGIC_VECTOR (7 DOWNTO 0);
    DataFromIBuff   : IN    STD_LOGIC_VECTOR (7 DOWNTO 0);
    Tx_en           : OUT   STD_LOGIC;
    Rx_en           : OUT   STD_LOGIC;
    rd_en           : OUT   STD_LOGIC;
    wr_en           : OUT   STD_LOGIC;
    DataTokb        : OUT   STD_LOGIC_VECTOR (7 DOWNTO 0);
    DataToOBuff     : OUT   STD_LOGIC_VECTOR (7 DOWNTO 0)
);
END KbdDataCtrl;

ARCHITECTURE Behavioral OF KbdDataCtrl IS

SIGNAL ValidDataINIbuff : std_logic;
SIGNAL GetDataIBuff     : std_logic;
SIGNAL StartTransmit    : std_logic;

BEGIN

PROCESS(Rst,Clk)
BEGIN
    IF(rst = '1') THEN
        rd_en            <= '0';
        wr_en            <= '0';
        Tx_en            <= '0';
        Rx_en            <= '0';
        ValidDataINIbuff <= '0';
        startTransmit    <= '0';
        GetDataIBuff     <= '0';
        DataToOBuff      <= (OTHERS => '0');
        DataTokb         <= (OTHERS => '0');
    ELSIF(clk = '1') and (clk'event) THEN
        IF(busyRx = '0') and ( busyTx = '0') THEN
            IF (startTransmit = '1') THEN
                Tx_en            <= '1';
                Rx_en            <= '0';
                rd_en            <= '0';
                wr_en            <= '0';
                ValidDataINIbuff <= '0';
                GetDataIBuff     <= '0';
                startTransmit    <= '0';
            ELSIF (GetDataIBuff = '1') THEN
                dataToKb         <= dataFromIBuff;
                Tx_en            <= '0';
                Rx_en            <= '0';
                rd_en            <= '0';
                wr_en            <= '0';
                ValidDataINIbuff <= '0';
                GetDataIBuff     <= '0';
                startTransmit    <= '1';
            ELSIF (ValidDataINIbuff = '1') THEN
                Tx_en            <= '0';
                Rx_en            <= '0';
                rd_en            <= '0';
                wr_en            <= '0';
                ValidDataINIbuff <= '0';
                GetDataIBuff     <= '1';
                startTransmit    <= '0';
            ELSIF(dataINIbuff = '0') THEN
                rd_en            <= '1';
                wr_en            <= '0';
                Tx_en            <= '0';
                Rx_en            <= '0';
                ValidDataINIbuff <= '1';
                GetDataIBuff     <= '0';
                startTransmit    <= '0';
            ELSE
                rd_en            <= '0';
                wr_en            <= '0';
                Tx_en            <= '0';
                Rx_en            <= '1';
                startTransmit    <= '0';
                GetDataIBuff     <= '0';
                ValidDataINIbuff <= '0';
            END IF;
        ELSIF(busyTx = '1') THEN
            wr_en            <= '0';
            rd_en            <= '0';
            ValidDataINIbuff <= '0';
            startTransmit    <= '0';
            Tx_en            <= '0';
            Rx_en            <= '0';
        ELSIF(busyRx = '1') THEN
            Tx_en <= '0';
            Rx_en <= '1';
            rd_en <= '0';
            wr_en <= '0';
            IF (validDataKb = '1') THEN
                dataToOBuff <= dataFromKb;
                wr_en       <= '1';
            END IF;
        END IF;
    END IF;
END PROCESS;


END Behavioral;
