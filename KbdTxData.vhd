----------------------------------------------------------------------------------
-- Company: 
-- EngINeer: Ali Diouri
-- 
-- Create Date:    20:59:21 05/03/2012 
-- Design Name: 
-- Module Name:    KbdCore - Behavioral 
-- Project Name:   KbdTxData
-- Target Devices: 
-- Tool versions:  XilINx ISE 14.4
-- Description: 
--		http://www.computer-engINeerINg.org/ps2protocol/
--		
--		1)   BrINg the Clock lINe low for at least 100 microseconds. 
--		2)   BrINg the Data lINe low. 
--		3)   Release the Clock lINe. 
--		4)   Wait for the device to brINg the Clock lINe low. 
--		5)   Set/reset the Data lINe to Tx_en the first data bit 
--		6)   Wait for the device to brINg Clock high. 
--		7)   Wait for the device to brINg Clock low. 
--		8)   Repeat steps 5-7 for the other seven data bits and the parity bit 
--		9)   Release the Data lINe. 
--		10)  Wait for the device to brINg Data low. 
--		11)  Wait for the device to brINg Clock  low. 
--		12)  Wait for the device to release Data and Clock
-- DepENDencies: 
--
-- RevISion: 
-- RevISion 0.01 - File Created
-- Additional Comments: 


----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;



entity KbdTxData IS
Port ( 
    clk             : IN  STD_LOGIC;
    rst             : IN  STD_LOGIC;
    Tx_en           : IN  STD_LOGIC;
    kbd_dataf       : IN  STD_LOGIC;
    kbd_clkf        : IN  STD_LOGIC;
    Data            : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    busy            : OUT STD_LOGIC;
    T_Data          : OUT STD_LOGIC;	--WHEN T=0, IO = OUT; WHEN T=1, IO = IN;
    T_Clk           : OUT STD_LOGIC;	--WHEN T=0, IO = OUT; WHEN T=1, IO = IN;
    KbdData         : OUT STD_LOGIC;
    KbdClk          : OUT STD_LOGIC
);
  END KbdTxData;



ARCHITECTURE Behavioral OF KbdTxData IS

TYPE state_type IS (reset,INit, clkLow,
                    startSEND,startbit,
                    bitshIFt,bitsEND,
                    parity,tempo_parity,
                    stopbit,akn,
                    DevRelease,ENDFSM);
SIGNAL state, next_state: state_type ;

SIGNAL cnt          : std_logic_vector(12 DOWNTO 0):=(OTHERS=>'0');
SIGNAL startCount   : std_logic:='0';
SIGNAL ENDCount     : std_logic:='0';
SIGNAL shIFt        : std_logic:='0';
SIGNAL ENDshIFt     : std_logic:='0';
SIGNAL shIFtcnt     : std_logic_vector(2 DOWNTO 0):=(OTHERS=>'0');
SIGNAL dataReg      : std_logic_vector(7 DOWNTO 0):=(OTHERS=>'0');
SIGNAL INt_busy     : std_logic;
SIGNAL INt_T_Clk    : std_logic;
SIGNAL INt_T_Data   : std_logic;
SIGNAL INt_KbdData  : std_logic;
SIGNAL INt_KbdClk   : std_logic;



BEGIN

Sequential: PROCESS (clk,rst)
BEGIN
    IF (rst = '1') THEN
        state <= INit;
    ELSIF (clk='1' and clk'Event) THEN
        state <= next_state;
    END IF;
END PROCESS;

-- Counter
PROCESS (clk,rst)
BEGIN
    IF (rst = '1') THEN
        cnt      <= (OTHERS=>'0');
        ENDCount <= '0';
    ELSIF (clk = '1' and clk'Event) THEN
        ENDCount <= '0';
        cnt      <= (OTHERS=>'0');
        IF(startCount = '1') THEN
            cnt      <= cnt+'1';
            IF (cnt = X"1388") THEN          -- 100 us
                cnt      <= (OTHERS=>'0');
                ENDCount <= '1';
            END IF;
        END IF;
    END IF;
END PROCESS;


Dataproc:PROCESS(clk,rst)
BEGIN
    IF (rst = '1') THEN
        dataReg  <= X"FF";
        shIFtcnt <= "000";
        ENDshIFt <= '0';
    ELSIF (clk = '1' and clk'Event) THEN
        IF (state = INit) THEN
            dataReg  <= data;
            shIFtcnt <= "000";
            ENDshIFt <= '0';
        ELSIF (shIFtcnt = "111") THEN
            shIFtcnt <= "000";
            ENDshIFt <= '1';
        ELSIF (shIFt = '1') THEN
            ENDshIFt <= '0';
            shIFtcnt <= shIFtcnt + '1';
            dataReg  <= dataReg(0) & dataReg(7 DOWNTO 1);
        END IF;
    END IF;
END PROCESS;




CntrlFSM :  PROCESS (state, kbd_clkf, kbd_dataf,ENDCount,Tx_en,ENDshIFt)
BEGIN
    CASE state IS
        WHEN reset =>
            INt_busy       <= '0';
            INt_T_Clk      <= '1';
            INt_T_Data     <= '1';
            shIFt          <= '0';
            startCount     <= '0';
            INt_KbdData    <= '1';
            INt_KbdClk     <= '1';
            next_state     <= clkLow;
            
        WHEN INit =>
            INt_busy       <= '0';
            INt_T_Clk      <= '1';
            INt_T_Data     <= '1';
            shIFt          <= '0';
            startCount     <= '0';
            INt_KbdData    <= '1';
            INt_KbdClk     <= '1';
            IF (Tx_en = '1') THEN
                next_state <= clkLow;
            ELSIF (Tx_en='0') THEN
                next_state <= INit;
            END IF;

        WHEN clkLow =>
            INt_busy    <= '1';
            INt_T_Clk   <= '0';
            INt_T_Data  <= '1';
            shIFt       <= '0';
            INt_KbdData <= '1';
            INt_KbdClk  <= '0';
            IF (ENDCount = '1') THEN
                startCount <= '0';
                next_state <= startSEND;
            ELSE
                startCount <= '1';
                next_state <= clkLow;
            END IF;


        WHEN startSEND =>
            INt_busy       <= '1';
            INt_T_Clk      <= '1';
            INt_T_Data     <= '0';
            shIFt          <= '0';
            INt_KbdClk     <= '1';
            INt_KbdData    <= '0';
            startCount <= '0';
            IF (kbd_clkf = '1') THEN
                next_state <= startbit;
            ELSE
                next_state <= startSEND;
            END IF;

        WHEN startbit =>
            INt_busy       <= '1';
            INt_T_Clk      <= '1';
            INt_T_Data     <= '0';
            shIFt          <= '0';
            INt_KbdClk     <= '1';
            INt_KbdData    <= '0';
            startCount <= '0';
            IF (kbd_clkf = '0') THEN
                next_state <= bitshIFt;
            ELSE
                next_state <= startbit;
            END IF;

        WHEN bitshIFt =>
            INt_busy       <= '1';
            INt_T_Clk      <= '1';
            INt_T_Data     <= '0';
            shIFt          <= '0';
            INt_KbdClk     <= '1';
            INt_KbdData    <= dataReg(0);
            startCount <='0';
            IF (kbd_clkf = '1') THEN
                next_state <= bitsEND;
            ELSE
                next_state <= bitshIFt;
            END IF;

        WHEN bitsEND =>
            INt_busy       <= '1';
            INt_T_Clk      <= '1';
            INt_T_Data     <= '0';
            INt_KbdClk     <= '1';
            INt_KbdData    <= dataReg(0);
            startCount <= '0';
            IF (kbd_clkf = '1') THEN
                shIFt      <= '0';
                next_state <= bitsEND;
            ELSIF (ENDshIFt = '1') THEN
                 shIFt      <= '0';
                 next_state <= parity;
            ELSE
                 shIFt      <= '1';
                 next_state <= bitshIFt;
            END IF;

        WHEN parity =>
            INt_busy       <= '1';
            INt_T_Clk      <= '1';
            INt_T_Data     <= '0';
            shIFt          <= '0';
            INt_KbdClk     <= '1';
            INt_KbdData    <= not(DataReg(7) xor DataReg(6) xor DataReg(5) xor DataReg(4) xor DataReg(3) xor DataReg(2) xor DataReg(1) xor DataReg(0));
            startCount <= '0';
            IF (kbd_clkf = '1') THEN
                next_state <= tempo_parity;
            ELSE
                next_state <= parity;
            END IF;

        WHEN tempo_parity =>
            INt_busy       <= '1';
            INt_T_Clk      <= '1';
            INt_T_Data     <= '0';
            shIFt          <= '0';
            INt_KbdClk     <= '1';
            INt_KbdData    <= not(DataReg(7) xor DataReg(6) xor DataReg(5) xor DataReg(4) xor DataReg(3) xor DataReg(2) xor DataReg(1) xor DataReg(0));
            startCount <= '0';
            IF (kbd_clkf = '0') THEN
                next_state <= stopbit;
            ELSE
                next_state <= tempo_parity;
            END IF;

        WHEN stopbit =>
            INt_busy       <= '1';
            INt_T_Clk      <= '1';
            INt_T_Data     <= '0';
            shIFt          <= '0';
            INt_KbdClk     <= '1';
            INt_KbdData    <= '1';
            startCount     <= '0';
            IF kbd_clkf = '1' THEN
                next_state <= akn;
            ELSE
                next_state <= stopbit;
            END IF;

        WHEN Akn =>
            INt_busy       <= '1';
            INt_T_Clk      <= '1';
            INt_T_Data     <= '1';
            shIFt          <= '0';
            INt_KbdClk     <= '1';
            INt_KbdData    <= '1';
            startCount     <= '0';
            IF (kbd_dataf = '0') THEN
                next_state <= DevRelease;
            ELSE
                next_state <= Akn;
            END IF;


        WHEN DevRelease =>
            INt_busy       <= '1';
            INt_T_Clk      <= '1';
            INt_T_Data     <= '1';
            shIFt          <= '0';
            startCount     <= '0';
            INt_KbdData    <= '1';
            INt_KbdClk     <= '1';
            IF (kbd_dataf = '1') THEN
                next_state <= ENDFSM;
            ELSE
                next_state <= DevRelease;
            END IF;

        WHEN ENDFSM =>
            INt_busy    <= '0';
            INt_T_Clk   <= '1';
            INt_T_Data  <= '1';
            shIFt       <= '0';
            startCount  <= '0';
            INt_KbdData <= '1';
            INt_KbdClk  <= '1';
            next_state  <= INit;
    END case;
END PROCESS;


OUTput: PROCESS (clk,rst)
BEGIN
    IF (rst = '1') THEN
        busy    <= '0';
        T_Clk   <= '1';
        T_Data  <= '1';
        KbdData <= '1';
        KbdClk  <= '1';
    ELSIF (clk='1' and clk'Event) THEN
        busy    <= INt_busy;
        T_Clk   <= INt_T_Clk;
        T_Data  <= INt_T_Data;
        KbdData <= INt_KbdData;
        KbdClk  <= INt_KbdClk;
    END IF;
END PROCESS;


END Behavioral;
