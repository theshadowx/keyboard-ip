----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Ali Diouri
-- 
-- Create Date:    20:59:21 05/03/2012 
-- Design Name: 
-- Module Name:    KbdCore - Behavioral 
-- Project Name:   Keyboard IP
-- Target Devices: 
-- Tool versions:  Xilinx ISE 14.4
-- Description: 
--  Keyboard Core Top file
--  
-- Dependencies: 
--                  KbdRxData.vhd
--                  KbdTxData.vhd
--                  KbdDataCtrl.vhd
--                  KbdFilter.vhd
--                  IOBuffer.xco
                    
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
--      statusReg : 
--                  0 : Full OUTput buffer
--                  1 : Full Input buffer
--                  2 : 
--                  3 : 
--                  4 : 
--                  5 : 
--                  6 : Empty Input buffer
--                  7 : Empty OUTput buffer


--      controlReg : 
--                  0 : 
--                  1 : 
--                  2 : 
--                  3 : 
--                  4 : 
--                  5 : 
--                  6 : 
--                  7 : 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;


entity KbdCore is
PORT ( 
    clk                 : IN    STD_LOGIC;
    rst                 : IN    STD_LOGIC;
    rdOBuff             : IN    STD_LOGIC;
    wrIBuffer           : IN    STD_LOGIC;
    dataFromHost        : IN    STD_LOGIC_VECTOR(7 downto 0);
    KBData              : INOUT STD_LOGIC;
    KBClk               : INOUT STD_LOGIC;
    statusReg           : OUT   STD_LOGIC_VECTOR(7 downto 0);
    dataToHost          : OUT   STD_LOGIC_VECTOR(7 downto 0)
);
end KbdCore;


architecture Behavioral of KbdCore is

Component KbdTxData 
PORT(
    clk                 : IN  STD_LOGIC;
    rst                 : IN  STD_LOGIC;
    Tx_en               : IN  STD_LOGIC;
    kbd_dataf           : IN  STD_LOGIC;
    kbd_clkf            : IN  STD_LOGIC;
    Data                : IN  STD_LOGIC_VECTOR(7 downto 0);
    busy                : OUT STD_LOGIC;
    T_Data              : OUT STD_LOGIC;	--when T=0, IO = OUT; when T=1, IO = IN;
    T_Clk               : OUT STD_LOGIC;	--when T=0, IO = OUT; when T=1, IO = IN;
    KbdData             : OUT STD_LOGIC;
    KbdClk              : OUT STD_LOGIC
);
end component;

Component KbdRxData
PORT(
    clk                 : IN  STD_LOGIC;
    rst                 : IN  STD_LOGIC;
    kbd_Data            : IN  STD_LOGIC;
    kbd_clk             : IN  STD_LOGIC;
    Rx_en               : IN  STD_LOGIC;
    busy                : OUT STD_LOGIC;
    dataValid           : OUT STD_LOGIC;
    Data                : OUT STD_LOGIC_VECTOR (7 downto 0)
);
end component;


Component KbdDataCtrl
PORT(
    clk                 : IN  STD_LOGIC;
    rst                 : IN  STD_LOGIC;
    busyRx              : IN  STD_LOGIC;
    busyTx              : in  STD_LOGIC;
    validDataKb         : IN  STD_LOGIC;
    dataInIBuff         : IN  STD_LOGIC;
    DataFromKb          : IN  STD_LOGIC_VECTOR (7 downto 0);
    DataFromIBuff       : IN  STD_LOGIC_VECTOR (7 downto 0);
    Rx_en               : OUT STD_LOGIC;
    Tx_en               : OUT STD_LOGIC;
    rd_en               : OUT STD_LOGIC;
    wr_en               : OUT STD_LOGIC;
    DataTokb            : OUT STD_LOGIC_VECTOR (7 downto 0);
    DataToOBuff         : OUT STD_LOGIC_VECTOR (7 downto 0)
);
end component;

Component KbdFilter
PORT(
    clk                 : IN  STD_LOGIC;
    rst                 : IN  STD_LOGIC;
    kbdClk              : IN  STD_LOGIC;
    kbdData             : IN  STD_LOGIC;
    kbdClkF             : OUT STD_LOGIC;
    kbdDataF            : OUT STD_LOGIC
);
end component;

COMPONENT IOBuffer
PORT (
    clk                 : IN    STD_LOGIC;
    rst                 : IN    STD_LOGIC;
    din                 : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en               : IN    STD_LOGIC;
    rd_en               : IN    STD_LOGIC;
    dOUT                : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
    full                : OUT   STD_LOGIC;
    empty               : OUT   STD_LOGIC
);
END COMPONENT;


COMPONENT IOBUF
PORT ( 
    I                  : IN    std_logic; 
    IO                 : INOUT std_logic; 
    O                  : OUT   std_logic; 
    T                  : IN    std_logic
);
END COMPONENT;
        
SIGNAL dataFromKB      : STD_LOGIC;
SIGNAL dataToKB        : STD_LOGIC;
SIGNAL ClkToKb         : STD_LOGIC;
SIGNAL ClkFromKb       : STD_LOGIC;
SIGNAL TData           : STD_LOGIC;  --when T=0, IO = OUT; when T=1, IO = IN;
SIGNAL TClk            : STD_LOGIC;  --when T=0, IO = OUT; when T=1, IO = IN;
SIGNAL Tx_en           : STD_LOGIC;
SIGNAL Rx_en           : STD_LOGIC;
SIGNAL busyRx          : STD_LOGIC;
SIGNAL busyTx          : STD_LOGIC;
SIGNAL dataValid       : STD_LOGIC;
SIGNAL kbdDataF	       : STD_LOGIC;
SIGNAL kbdClkF         : STD_LOGIC;
SIGNAL emptyIBuff      : STD_LOGIC;
SIGNAL wrOBuff         : STD_LOGIC;
SIGNAL rdIBuff         : STD_LOGIC;
SIGNAL DataFromIBuff   : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL DataToOBuff     : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL DataTxKb	       : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL DataRxKb        : STD_LOGIC_VECTOR(7 downto 0);
	
BEGIN
SendKB: KbdTxData 
PORT MAP(
    clk             => clk,
    rst             => rst,
    Tx_en           => Tx_en,
    kbd_dataf       => kbdDataF,
    kbd_clkf        => kbdClkF,
    Data            => DataTxKb,
    busy            => busyTx,
    T_Data          => TData,
    T_Clk           => TClk,
    KbdData         => dataToKb,
    KbdClk          => ClkToKb
);

RecieveKb: KbdRxData 
PORT MAP(
    clk             => clk,
    rst             => rst,
    kbd_Data        => kbdDataF,
    kbd_clk         => kbdClkF,
    Rx_en           => Rx_en,
    busy            => BusyRx,
    dataValid       => dataValid,
    Data            => DataRxKb
);


ProcData:KbdDataCtrl 
PORT MAP(
    clk             => clk,
    rst             => rst,
    busyRx          => busyRx,
    busyTx          => busyTx,
    validDataKb     => dataValid,
    dataInIBuff     => emptyIBuff,
    DataFromKb      => DataRxKb,
    DataFromIBuff   => DataFromIBuff,
    rd_en           => rdIBuff,
    wr_en           => wrOBuff,
    Rx_en           => Rx_en,
    Tx_en           => Tx_en,
    DataTokb        => DataTxKb,
    DataToOBuff     => DataToOBuff
);


Filter:KbdFilter 
PORT MAP(
    clk             => clk,
    rst             => rst,
    kbdClk          => clkFromKb,
    kbdData         => dataFromKb,
    kbdClkF         => kbdClkF,
    kbdDataF        => kbdDataF
);


OBuffer : IOBuffer 
PORT MAP (
    clk             => clk,
    rst             => rst,
    din             => DataToOBuff,
    wr_en           => wrOBuff,
    rd_en           => rdOBuff,
    dOUT            => dataToHost,
    full            => statusReg(0),
    empty           => statusReg(7)
);

IBuffer : IOBuffer 
PORT MAP (
    clk             => clk,
    rst             => rst,
    din             => dataFromHost,
    wr_en           => wrIBuffer,
    rd_en           => rdIBuff,
    dOUT            => DataFromIBuff,
    full            => statusReg(1),
    empty           => emptyIBuff
);


IOData: IOBUF
PORT MAP( 
    I               => dataToKb,
    IO              => KBData, 
    O               => dataFromKB,
    T               => TData
);

IOClk: IOBUF
PORT MAP( 
    I               => ClkToKb,
    IO              => KBClk,
    O               => ClkFromKb,
    T               => TClk
);


statusReg(6 DOWNTO 2) <= (OTHERS => '0');

end Behavioral;

