----------------------------------------------------------------------------------
-- Company:  TJNAF
-- Engineer:  GU
-- 
-- Create Date: 09/15/2021 07:26:52 AM
-- Design Name: 
-- Module Name: ClockFreqMeas - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Using the known Clock as reference to measure the CLkA and ClkB frequency
--              Read the data out on the ClkR
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ClockFreqMeas is
    Port ( Clock : in STD_LOGIC;
           ClkA : in STD_LOGIC;
           ClkB : in STD_LOGIC;
           ClkR : in STD_LOGIC;
           ClkFreq : out STD_LOGIC_VECTOR (31 downto 0));
end ClockFreqMeas;

architecture Behavioral of ClockFreqMeas is

  component SigClkA2B is
    Port ( SigIn  : in STD_LOGIC;
           ClkIn  : in STD_LOGIC;
           ClkOut : in STD_LOGIC;
           SigOut : out STD_LOGIC);
  end component SigClkA2B;

  signal ClockCnt  : std_logic_vector(15 downto 0) := (others => '0');
  signal CntPause  : std_logic := '0';
  signal CntPauseA : std_logic := '0';
  signal CntPauseB : std_logic := '0';
  signal DlyPause  : std_logic := '0';
  signal Paused    : std_logic := '0';
  signal PausedA   : std_logic := '0';
  signal PausedB   : std_logic := '0';
  signal ClkCntA   : std_logic_vector(15 downto 0) := (others => '0');
  signal ClkCntB   : std_logic_vector(15 downto 0) := (others => '0');
  signal ClkFreqA  : std_logic_vector(15 downto 0) := (others => '0');
  signal ClkFreqB  : std_logic_vector(15 downto 0) := (others => '0');

begin

  process (Clock)
  begin
    if (Clock'event and Clock = '1') then
    -- 5000 clock cycles on 50 MHz is 25000 cycles on Clock 250 MHz, and 3125 cycles on Clock 31.25 MHz
      CntPause <= ClockCnt(12) and (not ClockCnt(11)) and (not ClockCnt(10)) and CLockCnt(9) and ClockCnt(8)
              and ClockCnt(7)  and (not ClockCnt(6) ) and (not ClockCnt(5))  and (not ClockCnt(4)) and ClockCnt(3) and (not ClockCnt(2));
      DlyPause <= CntPause;
      Paused  <= DlyPause and (not CntPause);
      if (paused = '1') then
        ClockCnt <= (others => '0');
      else
        ClockCnt <= ClockCnt + 1;
      end if;
    end if;
  end process;
  
  Resync_CntPauseA : SigClkA2B
  port map (SigIn  => CntPause, -- in STD_LOGIC;
            ClkIn  => Clock, -- in STD_LOGIC;
            ClkOut => ClkA, -- in STD_LOGIC;
            SigOut => CntPauseA ); -- out STD_LOGIC);
  Resync_CntPauseB : SigClkA2B
  port map (SigIn  => CntPause, -- in STD_LOGIC;
            ClkIn  => Clock, -- in STD_LOGIC;
            ClkOut => ClkB, -- in STD_LOGIC;
            SigOut => CntPauseB ); -- out STD_LOGIC);
  Resync_PausedA : SigClkA2B
  port map (SigIn  => Paused, -- in STD_LOGIC;
            ClkIn  => Clock, -- in STD_LOGIC;
            ClkOut => ClkA, -- in STD_LOGIC;
            SigOut => PausedA ); -- out STD_LOGIC);
  Resync_PausedB: SigClkA2B
  port map (SigIn  => Paused, -- in STD_LOGIC;
            ClkIn  => Clock, -- in STD_LOGIC;
            ClkOut => ClkB, -- in STD_LOGIC;
            SigOut => PausedB ); -- out STD_LOGIC);
  process(ClkA)
  begin
    if (ClkA'event and ClkA= '1') then
      if (CntPauseA = '1') then
        ClkFreqA <= ClkCntA;
      elsif (PausedA = '1') then
        ClkCntA <= (others => '0');
      else 
        ClkCntA <= ClkCntA + 1;
      end if;
    end if;
  end process;
  process(ClkB)
  begin
    if (ClkB'event and ClkB= '1') then
      if (CntPauseB = '1') then
        ClkFreqB <= ClkCntB;
      elsif (PausedB = '1') then
        ClkCntB <= (others => '0');
      else 
        ClkCntB <= ClkCntB + 1;
      end if;
    end if;
  end process;

  process(ClkR)
  begin
    if (ClkR'event and ClkR= '1') then
      ClkFreq <= ClkFreqA & ClkFreqB;
    end if;
  end process;

end Behavioral;
