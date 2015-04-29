----------------------------------------------------------------------------------
-- Company: 
-- Engineer:       Ali Diouri
-- 
-- Create Date:    02:06:48 04/29/2015 
-- Design Name: 
-- Module Name:    testTop - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: The top module for the example of Keyboard IP --> Led
--
-- Dependencies: 
--              KbdCore.vhd
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY exampleTop IS
    PORT (  clk    : IN    std_logic; 
            rst    : IN    std_logic; 
            LED    : OUT   std_logic_vector (7 DOWNTO 0); 
            KBData : INOUT std_logic; 
            KBClk  : INOUT std_logic);
END exampleTop;

ARCHITECTURE Behavioral OF testTop IS

    COMPONENT KbdCore
        PORT (  clk             : IN    STD_LOGIC;
                rst             : IN    STD_LOGIC;
                rdOBuff         : IN    STD_LOGIC;
                wrIBuffer       : IN    STD_LOGIC;
                dataFromHost    : IN    STD_LOGIC_VECTOR(7 downto 0);
                KBData          : INOUT STD_LOGIC;
                KBClk           : INOUT STD_LOGIC;
                statusReg       : OUT   STD_LOGIC_VECTOR(7 downto 0);
                dataToHost      : OUT   STD_LOGIC_VECTOR(7 downto 0));
    END COMPONENT;

   SIGNAL dataToHost    : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL dataFromHost  : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL statusReg     : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL wr_en         : STD_LOGIC;
   SIGNAL rd_en         : STD_LOGIC;


BEGIN

    wr_en <= '0';
    dataFromHost <= (OTHERS => '0');

    KBD_Mod : KbdCore
        port map (  clk             =>  clk, 
                    rst             =>  rst,
                    rdOBuff         =>  rd_en,
                    wrIBuffer       =>  wr_en,
                    dataFromHost    =>  dataFromHost,
                    KBData          =>  KBData,
                    KBClk           =>  KBClk,
                    statusReg       =>  statusReg,
                    dataToHost      =>  dataToHost);
        
    -- read FIFO whenever the 8th bit status register is '0' 
    PROCESS (clk,rst)
    BEGIN
    IF (rst = '1') THEN
        rd_en <= '0';
    ELSIF RISING_EDGE(clk) THEN
        IF (statusReg(7) = '0') THEN
            rd_en <= '1';
        ELSE
            rd_en <= '0';
        END IF;
    END IF; 
    END PROCESS;
    
    -- link the data coming out from KbdCore to leds
    LED <= dataToHost;

END Behavioral;

