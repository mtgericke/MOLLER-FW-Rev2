----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2020 09:18:21 AM
-- Design Name: 
-- Module Name: DataGeneration - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity DataGeneration is
  port ( AddTrgType  : in    std_logic_vector (16 downto 0); 
    BlockLevel  : in    std_logic_vector (7 downto 0); 
    BoardID     : in    std_logic_vector (4 downto 0); 
    ClkRead     : in    std_logic; 
    ClkUsr      : in    std_logic; 
    ClkVme      : in    std_logic; 
    Clk250      : in    std_logic; 
    CountReset  : in    std_logic; 
    DataFormat  : in    std_logic_vector (7 downto 0); 
    DSyncEvt    : in    std_logic; 
    FnFull      : in    std_logic_vector (8 downto 1); 
    RawTrgIn    : in    std_logic_vector (32 downto 1); 
    ReadOutTrg  : in    std_logic; 
    ReadoutType : in    std_logic_vector (7 downto 0); 
    RegTrgTime  : in    std_logic; 
    Reset       : in    std_logic; 
    ROCAckIn    : in    std_logic_vector (8 downto 1); 
    ROCEn       : in    std_logic_vector (8 downto 1); 
    SyncEvt     : in    std_logic; 
    TrgInhibit  : in    std_logic; 
    TsStrobe    : in    std_logic; 
    VmeReset    : in    std_logic_vector (15 downto 0); 
    BlkEnd      : out   std_logic; 
    BlkRcvd     : out   std_logic; 
    DaqData     : out   std_logic_vector (71 downto 0); 
    DaqDEn      : out   std_logic; 
    DataBusy    : out   std_logic; 
    DGFull      : out   std_logic_vector (2 downto 1); 
    Dly4L1A     : out   std_logic; 
    FnextFull   : out   std_logic; 
    IRQCount    : out   std_logic_vector (7 downto 0); 
    Nblk        : out   std_logic_vector (23 downto 0); 
    NEvt        : out   std_logic_vector (7 downto 0); 
    RegNum      : out   std_logic_vector (47 downto 0); 
    ROCack      : out   std_logic; 
    ROCAckRd    : out   std_logic_vector (63 downto 0); 
    SyncEvtSet  : out   std_logic; 
    TDCEvtReg   : out   std_logic_vector (3 downto 0); 
    TestPt      : out   std_logic_vector (8 downto 1); 
    TIfifoFull  : out   std_logic; 
    TItimeMon   : out   std_logic_vector(15 downto 0);
    TrgLost     : out   std_logic; 
    TSack       : out   std_logic);
end DataGeneration;

architecture Behavioral of DataGeneration is

  component L1ADMux
    port ( TTime      : in    std_logic_vector (47 downto 0); 
      Numb       : in    std_logic_vector (47 downto 0); 
      TrgType    : in    std_logic_vector (7 downto 0); 
      WordCnt    : in    std_logic_vector (2 downto 0); 
      DOut       : out   std_logic_vector (31 downto 0); 
      AddTrgType : in    std_logic_vector (15 downto 0); 
      RawTrgIn   : in    std_logic_vector (32 downto 1); 
      SelE       : in    std_logic; 
      SelD       : in    std_logic; 
      SelC       : in    std_logic; 
      SelB       : in    std_logic; 
      SelA       : in    std_logic);
  end component;

  component BlkData
    port ( BlkHead   : in    std_logic; 
      Blk2Head  : in    std_logic; 
      BlkTail   : in    std_logic; 
      EvtData   : in    std_logic; 
      ExtraWord : in    std_logic; 
      BoardID   : in    std_logic_vector (4 downto 0); 
      TimeStamp : in    std_logic; 
      BlkSize   : in    std_logic_vector (7 downto 0); 
      WordCount : in    std_logic_vector (15 downto 0); 
      L1AData   : in    std_logic_vector (35 downto 0); 
      BlkNumb   : in    std_logic_vector (23 downto 0); 
      JlabBID   : in    std_logic_vector (3 downto 0); 
      BlkData   : out   std_logic_vector (35 downto 0));
  end component;

  component bram18to36
    port ( rst    : in    std_logic; 
      din    : in    std_logic_vector (17 downto 0); 
      wr_clk : in    std_logic; 
      rd_clk : in    std_logic; 
      wr_en  : in    std_logic; 
      rd_en  : in    std_logic; 
      dout   : out   std_logic_vector (35 downto 0); 
      full   : out   std_logic; 
      empty  : out   std_logic);
  end component;

  component BRAM36
    port ( din         : in    std_logic_vector (35 downto 0); 
      wr_en       : in    std_logic; 
      wr_clk      : in    std_logic; 
      rd_en       : in    std_logic; 
      rd_clk      : in    std_logic; 
      dout        : out   std_logic_vector (35 downto 0); 
      almost_full : out   std_logic; 
      empty       : out   std_logic; 
      full        : out   std_logic; 
      rst         : in    std_logic);
  end component;

  component TDCEvtFifo
    port ( din   : in    std_logic_vector (3 downto 0); 
      full  : out   std_logic; 
      empty : out   std_logic; 
      wr_en : in    std_logic; 
      rd_en : in    std_logic; 
      clk   : in    std_logic; 
      rst   : in    std_logic; 
      dout  : out   std_logic_vector (3 downto 0));
  end component;

  component TimeFifo
    port ( clk   : in    std_logic; 
      wr_en : in    std_logic; 
      rd_en : in    std_logic; 
      din   : in    std_logic_vector (15 downto 0); 
      rst   : in    std_logic; 
      empty : out   std_logic; 
      full  : out   std_logic; 
      dout  : out   std_logic_vector (15 downto 0));
  end component;

  component ROCAckBuf is
    Port (Clock : in STD_LOGIC;
      ROCiAckIn : in STD_LOGIC;
      Reset     : in STD_LOGIC;
      ROCAckd   : in STD_LOGIC;
      ROCiReady : out std_logic;
      ROCAckBuf : out STD_LOGIC_VECTOR (7 downto 0));
  end component ROCAckBuf;

  COMPONENT Count48DSP
    PORT (CLK : IN STD_LOGIC;
      CE : IN STD_LOGIC;
      SCLR : IN STD_LOGIC;
      Q : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)  );
  END COMPONENT;

-- Up to 8 ROC can be enabled for data readout
  signal ROCackInt : std_logic := '0';
  signal ROCReady  : std_logic_vector(8 downto 1) := (others => '0');
  signal L1ANum    : std_logic_vector(47 downto 0) := (others => '0');
  signal TimeTI    : std_logic_vector(47 downto 0) := (others => '0');
  signal TimeFifoRen : std_logic;
  signal TimeTIFifo : std_logic_vector(47 downto 0);
  signal DLyedL1A  : std_logic_vector(7 downto 0) := (others => '0');  -- to replace Dly1L1A, Dly2L1A ...
  signal PreTrg    : std_logic := '0';
  signal TrgForbid : std_logic := '0';
  signal TrgRead   : std_logic;
  signal RegReadOut : std_logic;
  signal ReadClkUsr : std_logic;
  signal ForceBlkEnd : std_logic;
  signal Pre2BHStart : std_logic := '0';      
  signal PreBHStart : std_logic := '0';      
  signal BHeadStart : std_logic := '0';      
  signal BHWord     : std_logic := '0';      
  signal BH2Word    : std_logic := '0';      
  signal NewBlk     : std_logic := '0';      
  signal L1AWord    : std_logic := '0';  
  signal ExtraWord  : std_logic := '0';    
-- VmeReg (to sync ClkVme to ClkUsr)
  signal ClkVmeHalf : std_logic_vector(3 downto 0) := (others => '0');
  signal ClkVmeD1   : std_logic := '0';
  signal ClkVmeD2   : std_logic;
  signal VmeReg     : std_logic;
-- Data generation
  signal L1AData    : std_logic_vector(35 downto 0);
  signal BlkEndInt  : std_logic;
  signal DlyBlkEnd  : std_logic_vector(3 downto 1);
  signal SingleEvt : std_logic;
  signal BlkRSet   : std_logic;
  signal BlkCnt    : std_logic_vector(7 downto 0) := (others => '0');
  signal L1FWrite  : std_logic;
  signal L1FRead   : std_logic;
  signal L1FD      : std_logic_vector(35 downto 0);
  signal L1FEm     : std_logic;  
  signal BTWord    : std_logic;
  signal FBlkEnd   : std_logic;
  signal DlyFBlkEnd : std_logic;
  signal WordCnt : std_logic_vector(15 downto 0) := "0000000000000011"; 
  signal BlkNUM   : std_logic_vector(23 downto 0) := "000000000000000000000001";
  signal IntBlk   : std_logic_vector(23 downto 0);
  signal TIData   : std_logic_vector(35 downto 0); -- Data from the block assembly
  signal PBufWen  : std_logic;
  signal PBufRen  : std_logic;
  signal TIDataMid : std_logic_vector(35 downto 0);
  signal EmptyMid : std_logic;
  signal TIffFullInt : std_logic;
  signal FullA    : std_logic;
  signal FullB    : std_logic;
  signal MidWen   : std_logic;
  signal RegPBufRen : std_logic;
  signal ReadEn  : std_logic;
  signal EmptyA  : std_logic;
  signal EmptyB  : std_logic;
  signal L1APreTrg  : std_logic;
  signal L1APreTrgD : std_logic;
  signal L1AClkX    : std_logic;
  signal BlkEndReg  : std_logic;
  signal BlkRcvdInt : std_logic;
  signal PreForceBE : std_logic_vector(4 downto 1); -- pre Foced Block End
  signal IRQCntInt  : std_logic_vector(7 downto 0) := (others => '0');
  signal IRQCntEn  : std_logic;
  signal SyncEvtSetInt : std_logic;
  signal CountUp    : std_logic;
  signal DDSyncEvt  : std_logic;
  signal DBTWord    : std_logic;
  signal CntNotZero : std_logic;
  signal DlyROCAck  : std_logic;
  signal PreDataBusy : std_logic;
  signal PreTSack    : std_logic;
  signal NotTSack    : std_logic;
  signal TDCEvt    : std_logic_vector(3 downto 0);
  signal PreTrgEnable   : std_logic := '0';
  signal D1PreTrgEnable : std_logic := '0';  -- ClkUsr delayed PreTrgEnable
  signal D2PreTrgEnable : std_logic := '0';
  signal working    : std_logic := '0';
  signal ClkUsrMon  : std_logic := '0';
  signal ROCAckRdInt    : std_logic_vector (63 downto 0); 

begin

  working <= not reset;
-- Trigger receiving logic
-- Trigger read and trigger lost logic
  process (Clk250)
  begin
    if (Clk250'event and Clk250 = '1') then
      if (Reset = '1') then
        TrgLost <= '0';
      elsif ((TrgForbid = '1') and (TrgRead = '1')) then
        TrgLost <= '1';
      end if;
      RegReadOut <= ReadOutTrg;
      if (TrgForbid = '0') then
        PreTrg <= TrgRead;
      end if;
      TrgForbid <= TrgInhibit;
      DlyedL1A(0) <= PreTrg; -- DlyedL1A(0) = L1A
      DlyedL1A(1) <= DlyedL1A(0);
      DlyedL1A(2) <= DlyedL1A(1);
      DlyedL1A(3) <= DlyedL1A(2);
      DlyedL1A(4) <= DlyedL1A(3); 
      ReadClkUsr <= PreTrg;      -- ReadOut trigger to be synced to the ClkUsr
      -- use synchronous logic for BHEADSTART
      if (Reset = '1' or ForceBlkEnd = '1' ) then -- or BHeadStart = '1') then
        PreTrgEnable <= '0';
      elsif (PreTrg = '1') then
        PreTrgEnable <= '1';
      end if;
    end if;
  end process;
  TrgRead <= ReadOutTrg and (not RegReadOut);
  Dly4L1A <= DlyedL1A(4);
  
  BHeadStart <= D1PreTrgEnable and (not D2PreTrgEnable);

  process (ClkUsr)
  begin
    if (ClkUsr'event and ClkUsr = '1') then
      D1PreTrgEnable <= PreTrgEnable;
      D2PreTrgEnable <= D1PreTrgEnable;
      if (Reset = '1') then
        BHword <= '0';
        BH2word <= '0';
      else
        BHword <= BHeadStart or (ExtraWord and (not SyncEvtSetInt));
        BH2Word <= BHWord;
      end if;
      if (Reset = '1' or L1Aword = '1') then  -- ** need to check the L1Aword timing (CLR--> R) should be OK, June 16, 2020
        NewBlk <= '0';
      elsif (BH2Word = '1') then
        NewBlk <= '1';
      end if;
    end if;
  end process;

-- Forced Block End
  process (Clk250)
  begin
    if (CLk250'event and Clk250 = '1') then
      PreForceBE(4) <= DSyncEvt;
      PreForceBE(3) <= DSyncEvt and (not PreForceBE(4));
      PreForceBE(2) <= PreForceBE(3);
      ForceblkEnd <= PreForceBE(2);
    end if;
  end process;
  
-- Block header/trailer/data readout (on ClkUsr)
--  process (ClkUsr, ReadClkUsr, Reset, ForceBlkEnd, BHeadStart, Pre2BHStart, L1AWord)
--  begin
--    if (Reset = '1' or ForceBlkEnd = '1') then
--      Pre2BHStart <= '0';
--    elsif (ReadClkUsr'event and ReadClkUsr = '1') then
--      Pre2BHStart <= '1';
--    end if;
--    if (BHeadStart = '1') then
--      PreBHStart <= '0';
--    elsif (Pre2BHStart'event and Pre2BHStart = '1') then
--      PreBHStart <= '1';
--    end if;
--    if (CLkUsr'event and ClkUsr = '1') then
--      BHeadStart <= PreBHStart;
--      if (Reset = '1') then
--        BHWord <= '0';
--        BH2Word <= '0';
--      else
--        BHword <= BHeadStart or (ExtraWord and (not SyncEvtSetInt));
--        BH2Word <= BHWord;
--      end if;
--    end if;
--    if (L1AWord = '1' or Reset = '1') then
--      NewBlk <= '0';
--    elsif (CLkUsr'event and ClkUsr = '1') then
--      if (BH2Word = '1') then
--        NewBlk <= '1';
--      end if;
--    end if;
--  end process;    
  
  -- TI data generation
  Trigger_event_Data : L1ADMux
    port map(TTime => TImeTIFifo(47 downto 0), -- in  std_logic_vector (47 downto 0); 
      Numb       => L1ANum(47 downto 0),     -- in  std_logic_vector (47 downto 0); 
      TrgType    => ReadOutType(7 downto 0), -- in  std_logic_vector (7 downto 0); 
      WordCnt    => DataFormat(3 downto 1),  -- in  std_logic_vector (2 downto 0); 
      DOut       => L1AData(31 downto 0),    -- out std_logic_vector (31 downto 0); 
      AddTrgType => AddTrgType(15 downto 0), -- in  std_logic_vector (15 downto 0); 
      RawTrgIn   => RawTrgIn(32 downto 1),   -- in  std_logic_vector (32 downto 1); 
      SelE       => DlyedL1A(4),   -- in  std_logic; 
      SelD       => DlyedL1A(3),   -- in  std_logic; 
      SelC       => DlyedL1A(2),   -- in  std_logic; 
      SelB       => DlyedL1A(1),   -- in  std_logic; 
      SelA       => DlyedL1A(0) ); -- in  std_logic);
  L1AData(34) <= DlyedL1A(0);
  process (Clk250, BlkEndInt, DataFormat, DlyBlkEnd)
  begin
    if (CLk250'event and Clk250 = '1') then
      if (Reset = '1') then
        DlyBlkEnd(1) <= '0';
        DlyBlkEnd(2) <= '0';
        DlyBlkEnd(3) <= '0';
      else
        DlyBlkEnd(1) <= BlkEndInt;
        DlyBlkEnd(2) <= DlyBlkEnd(1);
        DlyBlkEnd(3) <= DlyBlkEnd(2);
      end if;
    end if;
    if (DataFormat(3) = '1') then
      L1AData(35) <= DlyBlkEnd(3);
    elsif (DataFormat(2) = '1') then
      L1AData(35) <= DlyBlkEnd(2);
    elsif (DataFormat(1) = '1') then
      L1AData(35) <= DlyBlkEnd(1);
    else
      L1AData(35) <= BlkEndInt;
    end if;
  end process;
  L1AData(33 downto 32) <= "00";
  -- Block data formation
  L1FWrite <= DlyedL1A(1) or DlyedL1A(0) or (DlyedL1A(2) and DataFormat(1))
           or (DlyedL1A(3) and DataFormat(2)) or (DlyedL1A(4) and DataFormat(3));
  BlockDataFifo : BRAM36
    port map(din   => L1AData(35 downto 0), -- in  std_logic_vector (35 downto 0); 
      wr_en        => L1FWrite,          -- in  std_logic; 
      wr_clk       => Clk250,            -- in  std_logic; 
      rd_en        => L1FRead,            -- in  std_logic; 
      rd_clk       => ClkUsr,            -- in  std_logic; 
      dout         => L1FD(35 downto 0), -- out std_logic_vector (35 downto 0); 
      almost_full  => open,              -- out std_logic; 
      empty        => L1FEm,             -- out std_logic; 
      full         => open,              -- out std_logic; 
      rst          => Reset );           -- in  std_logic);
      
  L1FRead <= (not BH2Word) and (NewBlk or (not L1FD(35))) and
             (not (L1FEm or BHWord or FBlkEnd or BHeadStart));  -- removed the BTword, as it is covered by FBlkEnd(two clock wide now)
 -- Word count per block  and extraWord logic
  process (ClkUsr, Reset, BHWord)
  begin
    if (ClkUsr'event and ClkUsr = '1') then
      BTWord <= FBlkEnd and (not DlyFBlkEnd);
      ExtraWord <= BTWord;
      DlyFBlkEnd <= FBlkEnd;
      if (BTWord = '1') then
        FBlkEnd <= '0';
      elsif (L1AWord = '1') then
        FBlkEnd <= L1FD(35);
      end if;
      if (Reset = '1') then
        L1AWord <= '0';
      else
        L1AWord <= L1FRead;
      end if;
      if (Reset = '1' or BHword = '1') then
        WordCnt <= "0000000000000011";
      elsif (L1Aword = '1') then
        WordCnt <= WordCnt + 1;
      end if;
    end if;
 -- also change the WordCnt to sync counter
--    if (Reset = '1' or BHWord = '1') then
--      WordCnt <= "0000000000000011";
--    elsif (ClkUsr'event and ClkUsr = '1') then
--      if (L1AWord = '1') then
--        WordCnt <= WordCnt + 1;
--      end if;
--    end if;
  end process;
  BlockDataSelection : BlkData
    port map( BlkHead => BHWord, -- in  std_logic; 
      Blk2Head  => BH2Word,      -- in  std_logic; 
      BlkTail   => BTWord,       -- in  std_logic; 
      EvtData   => L1AWord,      -- in  std_logic; 
      ExtraWord => ExtraWord,    -- in  std_logic; 
      BoardID   => BoardID(4 downto 0),    -- in  std_logic_vector (4 downto 0); 
      TimeStamp => DataFormat(1),          -- in  std_logic; 
      BlkSize   => BlockLevel(7 downto 0), -- in  std_logic_vector (7 downto 0); 
      WordCount => WordCnt(15 downto 0),   -- in  std_logic_vector (15 downto 0); 
      L1AData   => L1FD(35 downto 0),      -- in  std_logic_vector (35 downto 0); 
      BlkNumb   => BlkNUM(23 downto 0),    -- in  std_logic_vector (23 downto 0); 
      JlabBID   => "0000",   -- 0000 for TI,  in   std_logic_vector (3 downto 0); 
      BlkData   => TIData(35 downto 0) );  -- out  std_logic_vector (35 downto 0));

-- Block Number counter
  process (ClkUsr)
  begin
    if (ClkUsr'event and ClkUsr = '1') then
      if (Reset = '1' or BHeadStart = '1') then
        BlkNUM(23 downto 1) <= (others => '0');
        BlkNUM(0) <= '1';
        IntBlk(23 downto 0) <= (others => '0');
        Nblk(23 downto 0) <= (others => '0');
      else
        if (ExtraWord = '1') then
          BlkNUM <= BlkNUM + 1;
          IntBlk <= BlkNUM;
        end if;
        if (VmeReg = '1') then
          Nblk(23 downto 0) <= IntBlk(23 downto 0);
        end if;
        if (Reset = '1') then
          NEvt(7 downto 0) <= (others => '0');
          DGFull(2 downto 1) <= "00";
        else 
          if (VmeReg = '1') then
            NEvt(7 downto 0) <= BlkCnt(7 downto 0);
          end if;
          if (FullA = '1') then
            DGFull(1) <= '1';
          end if;
          if (FullB = '1') then
            DGFull(2) <= '1';
          end if;
        end if;
      end if;
      RegPBufRen <= PBufRen;
      MidWen <= RegPBufRen and (not EmptyMid);
    end if;
  end process;

-- TIData storage
  PBufWen <= BTWord or L1AWord or BHWord or BH2Word or
             (ExtraWord and WordCnt(0)); -- or (DummyEn and (Dummy1 or Dummy2));
  TIDataStorage  : BRAM36
    port map(din   => TIData(35 downto 0), -- in  std_logic_vector (35 downto 0); 
      wr_en        => PBufWen,          -- in  std_logic; 
      wr_clk       => ClkUsr,            -- in  std_logic; 
      rd_en        => PBufRen,            -- in  std_logic; 
      rd_clk       => ClkUsr,            -- in  std_logic; 
      dout         => TIDataMid(35 downto 0), -- out std_logic_vector (35 downto 0); 
      almost_full  => open,              -- out std_logic; 
      empty        => EmptyMid,             -- out std_logic; 
      full         => open,              -- out std_logic; 
      rst          => Reset );           -- in  std_logic);
  
  TIffFullInt <= FullA or FullB;
  PBufRen <= not TIffFullInt;
  TIfifoFull <= TIffFullInt;
--   Large FIFO for data storage
  WidthWidenA : bram18to36
    port map( rst => Reset, -- in    std_logic; 
      din    => TIDataMid(35 downto 18), -- in    std_logic_vector (17 downto 0); 
      wr_clk => ClkUsr, -- in    std_logic; 
      rd_clk => ClkRead, -- in    std_logic; 
      wr_en  => MidWen, -- in    std_logic; 
      rd_en  => ReadEn, -- in    std_logic; 
      dout(35 downto 34) => DaqData(35 downto 34), -- out   std_logic_vector (35 downto 0); 
      dout(33 downto 18) => DaqData(31 downto 16),
      dout(17 downto 16) => DaqData(71 downto 70),
      dout(15 downto 0) => DaqData(67 downto 52),
      full   => FullB, -- out   std_logic; 
      empty  => EmptyB ); -- out   std_logic);
  WidthWidenB : bram18to36
    port map( rst => Reset, -- in    std_logic; 
      din    => TIDataMid(17 downto 0), -- in    std_logic_vector (17 downto 0); 
      wr_clk => ClkUsr, -- in    std_logic; 
      rd_clk => ClkRead, -- in    std_logic; 
      wr_en  => MidWen, -- in    std_logic; 
      rd_en  => ReadEn, -- in    std_logic; 
      dout(35 downto 34) => DaqData(33 downto 32), -- out   std_logic_vector (35 downto 0); 
      dout(33 downto 18) => DaqData(15 downto 0),
      dout(17 downto 16) => DaqData(69 downto 68),
      dout(15 downto 0) => DaqData(51 downto 36),
      full   => FullA, -- out   std_logic; 
      empty  => EmptyA ); -- out   std_logic);
  process (ClkRead, EmptyA, EmptyB)
  begin
    if (EmptyA = '1' or EmptyB = '1') then
      ReadEn <= '0';
    elsif (ClkRead'event and ClkRead = '1') then
      ReadEn <= not (EmptyA or EmptyB);
    end if;
    if (ClkRead'event and ClkRead = '1') then
      DaqDEn <= ReadEn;
    end if;
  end process;



-- BlockEnd logic;
  SingleEvt <= not(BlockLevel(7) or BlockLevel(6) or BlockLevel(5) or BlockLevel(4)
                or BlockLevel(3) or BlockLevel(2) or BlockLevel(1) ); 
  BlkRSet <= BlockLevel(0) or SingleEvt;
  process (Clk250, BlockLevel)
  begin
    if (Clk250'event and Clk250 = '1') then
      if (Reset = '1' or BlkEndInt = '1') then
        BlkCnt <= (others => '0');
        BlkEndInt <= '0';
      else
        if (PreTrg = '1') then
          BlkCnt <= BlkCnt + 1;
        end if;
        BlkEndInt <= ForceBlkEnd or ((BlkCnt(7) xnor BlockLevel(7)) and (BlkCnt(0) xnor BlkRSet)
                and (BlkCnt(6) xnor BlockLevel(6)) and (BlkCnt(5) xnor BlockLevel(5))
                and (BlkCnt(4) xnor BlockLevel(4)) and (BlkCnt(3) xnor BlockLevel(3))
                and (BlkCnt(2) xnor BlockLevel(2)) and (BlkCnt(1) xnor BlockLevel(1)) );
      end if;
    end if;
  end process;
  BlkEnd <= BlkEndInt;
  
-- Trigger number counter  L1ANum(47 downto 0)
-- The Timer for data, buffered in the FIFO (to match with the data, as it is asynchronous
-- Use DSP counter, instead of the fabric counter
--  TimeTICounterDSP : Count48DSP
--    PORT MAP (CLK => Clk250,       -- IN STD_LOGIC;
--      CE          => working,    -- IN STD_LOGIC;
--      SCLR        => Reset,        -- IN STD_LOGIC;
--      Q(47 downto 0)  => TimeTI ); -- OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
  process (Clk250)
  begin
    if (Clk250'event and Clk250 = '1') then
      if (Reset = '1') then
        TimeTI <= (others => '0');
      else
        TimeTI <= TimeTI + 1;
      end if;
      if (CountReset = '1') then
        L1ANum <= (others => '0');
      elsif (PreTrg = '1') then
        L1ANum <= L1ANum + 1;
      end if;
    end if;
  end process;
--  L1ANumCounterDSP : Count48DSP
--    PORT MAP (CLK => Clk250,       -- IN STD_LOGIC;
--      CE          => PreTrg,    -- IN STD_LOGIC;
--      SCLR        => CountReset,        -- IN STD_LOGIC;
--      Q(47 downto 0)  => L1ANum ); -- OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
  process (Clk250)
  begin
    if (Clk250'event and Clk250 = '1') then
      if (Reset = '1') then
        TimeFifoRen <= '0';
--        TimeTI <= (others => '0');
      else
        TimeFifoRen <= DlyedL1A(3);
--        TimeTI <= TimeTI + 1;
      end if;
--      if (CountReset = '1') then
--        L1ANum <= (others => '0');
--      elsif (PreTrg = '1') then
--        L1ANum <= L1ANum + 1;
--      end if;
    end if;
  end process;
  TimeFifo15_0 : TimeFifo
    port map( clk => Clk250, -- in  std_logic; 
      wr_en => RegTrgTime,   -- in  std_logic; 
      rd_en => TimeFifoRen,  -- in  std_logic; 
      din   => TimeTI(15 downto 0), -- in  std_logic_vector (15 downto 0); 
      rst   => Reset,        -- in  std_logic; 
      empty => open,         -- out std_logic; 
      full  => open,         -- out std_logic; 
      dout  => TimeTIFifo(15 downto 0) ); -- out std_logic_vector (15 downto 0));
  TItimeMon(15 downto 0) <= TimeTI(12 downto 2) & TimeTIFifo(6 downto 2);
  TimeFifo31_16 : TimeFifo
    port map( clk => Clk250, -- in  std_logic; 
      wr_en => RegTrgTime,   -- in  std_logic; 
      rd_en => TimeFifoRen,  -- in  std_logic; 
      din   => TimeTI(31 downto 16), -- in  std_logic_vector (15 downto 0); 
      rst   => Reset,        -- in  std_logic; 
      empty => open,         -- out std_logic; 
      full  => open,         -- out std_logic; 
      dout  => TimeTIFifo(31 downto 16) ); -- out std_logic_vector (15 downto 0));
  TimeFifo47_32 : TimeFifo
    port map( clk => Clk250, -- in  std_logic; 
      wr_en => RegTrgTime,   -- in  std_logic; 
      rd_en => TimeFifoRen,  -- in  std_logic; 
      din   => TimeTI(47 downto 32), -- in  std_logic_vector (15 downto 0); 
      rst   => Reset,        -- in  std_logic; 
      empty => open,         -- out std_logic; 
      full  => open,         -- out std_logic; 
      dout  => TimeTIFifo(47 downto 32) ); -- out std_logic_vector (15 downto 0));

-- L1AClkX generation
  process(Clk250)
  begin
    if (Clk250'event and Clk250 = '1') then
      L1APreTrg <= PreTrg;
      if (L1AClkX = '1') then
        L1APreTrgD <= '0';
      elsif (L1APreTrg = '1') then
        L1APreTrgD <= '1';
      end if;
      if (BlkRcvdInt = '1') then
        BlkEndReg <= '0';
      elsif (BlkEndInt = '1') then
        BlkEndReg <= '1';
      end if;
    end if;
  end process;
  
-- VMeRegister setting on CLkUsr, also the RegNum
  process (ClkVme)
  begin
    if (ClkVme'event and ClkVme = '1') then
      L1AClkX <= L1APreTrgD;
      CLkVmeHalf <= ClkVmeHalf + 1; -- not ClkVmeHalf;
      if (CountReset = '1') then
        RegNum(47 downto 0) <= (others => '0');
      elsif (L1AClkX = '1') then
        RegNum(47 downto 0) <= L1ANum(47 downto 0);
      end if;
    end if;
  end process;
  process (ClkUsr)
  begin
    if (ClkUsr'event and ClkUsr = '1') then
      BlkRcvdInt <= BlkEndReg;
      ClkVmeD1 <= ClkVmeHalf(3);
      ClkVmeD2 <= ClkVmeD1;
      ClkUsrMon <= (not ClkUsrMon);
    end if;
  end process;
  VmeReg <= CLkVmeD1 and (not ClkVmeD2);
  BlkRcvd <= BlkRcvdInt;

  TestPt(8 downto 1) <= ROCackIn(1) & Reset & ROCackInt & ROCReady(1) & ROCAckRdInt(0) & ROCEn(1) & ClkUsrMon & BlkRcvdInt;
                
-- ROC Ack logic: There could be upto 8 ROC, and some ROC may get ackniledgement ahead of others
  ROCAcknoledgements :
  for iROC in 1 to 8 generate
  begin
    ROC_iROC_buffer : ROCAckBuf
      Port map(Clock => ClkUsr,      -- in STD_LOGIC;  should be 62.5MHz
        ROCiAckIn => ROCAckIn(iROC), -- in STD_LOGIC;
        Reset     => Reset,          -- in STD_LOGIC;
        ROCAckd   => ROCackInt,         -- in STD_LOGIC;
        ROCiReady => ROCReady(iROC), -- out std_logic;
        ROCAckBuf => ROCAckRdInt((8*iROC -1) downto ((iROC-1)*8)) ); --out STD_LOGIC_VECTOR (7 downto 0));
  end generate;
  ROCAckRd <= ROCAckRdInt;
  process (ClkUsr)
  begin
    if (ClkUsr'event and ClkUsr = '1') then
      if (ROCackInt = '1') then
        ROCackInt <= '0';
      else
        ROCackInt <= (ROCReady(8) or (not ROCEn(8))) and (ROCReady(7) or (not ROCEn(7)))
                 and (ROCReady(6) or (not ROCEn(6))) and (ROCReady(5) or (not ROCEn(5)))
                 and (ROCReady(4) or (not ROCEn(4))) and (ROCReady(3) or (not ROCEn(3)))
                 and (ROCReady(2) or (not ROCEn(2))) and (ROCReady(1) or (not ROCEn(1)));
      end if;
    end if;
  end process;
  ROCack <= ROCackInt;
  
  -- IRQ counter
  SyncEvtDelays : SRLC32E
    generic map (
INIT => X"00000000", -- Initial contents of shift register
      IS_CLK_INVERTED => '0' )        -- Optional inversion for CLK
    port map (
Q => DDSyncEvt,         -- 1-bit output: SRL Data
      Q31 => open,      -- 1-bit output: SRL Cascade Data
      A   => "00111",   -- 5-bit input: Selects SRL depth
      CE  => '1',       -- 1-bit input: Clock enable
      CLK => ClkUsr,    -- 1-bit input: Clock
      D   => SyncEvt ); -- 1-bit input: SRL Data
  CntNotZero <= IRQCntInt(0) or IRQCntInt(1) or IRQCntInt(2) or IRQCntInt(3)
             or IRQCntInt(4) or IRQCntInt(5) or IRQCntInt(6) or IRQCntInt(7);
  IRQCntEn <= (ROCackInt xor CountUp) and (CountUp or (ROCackInt and CntNotZero));
  process(ClkUsr)
  begin
    if (ClkUsr'event and ClkUsr = '1') then
      DlyROCAck <= ROCAckInt;
      if (Reset = '1') then
        IRQCntInt <= (others => '0');
      elsif (IRQCntEn = '1') then
        if (CountUp = '1') then
          IRQCntInt <= IRQCntInt + 1;
        else
          IRQCntInt <= IRQCntInt - 1;
        end if;
      end if;
      if (CountUp = '1') then
        CountUp <= '0';
      elsif (DDSyncEvt = '1' or DBTWord = '1') then
        CountUp <= '1';
      end if;
      if (SyncEvtSetInt = '0') then
        DBTWord <= BTWord;
      end if;
      if ((DlyROCAck = '1' and CntNotZero = '0' and DDSyncEvt = '0' and CountUp = '0')
          or (Reset = '1') ) then
        SyncEvtSetInt <= '0';
      elsif (DDSyncEvt = '1') then
        SyncEvtSetInt <= '1';
      end if;
      if (Reset = '1' or TsStrobe = '1') then
        PreTSack <= '0';
      elsif (ROCAckInt = '1') then
        PreTSack <= '1';
      end if;
      if (Reset = '1' or ROCAckInt = '1') then
        PreDataBusy <= '0';
      elsif (CntNotZero = '1') then
        PreDataBusy <= '1';
      end if;
      if (Reset = '1' or ExtraWord = '1') then  -- how many TDC events has data
        TDCEvt <= "0000";
      elsif (AddTrgType(16) = '1') then
        TDCEvt <= TDCEvt + 1;
      end if;
    end if;
  end process;
  IRQCount <= IRQCntInt;
  SyncEvtSet <= SyncEvtSetInt;
  process (ClkVme)
  begin
    if (ClkVme'event and ClkVme = '1') then
      NotTSack <= PreTSack;
      DataBusy <= PreDataBusy;
    end if;
  end process;
  TSack <= not NotTSack;
  TDCEventFifo :  TDCEvtFifo
    port map( din => TDCEvt(3 downto 0), -- in std_logic_vector (3 downto 0); 
      full  => open,      -- out   std_logic; 
      empty => open,      -- out   std_logic; 
      wr_en => BTWord,    -- in    std_logic; 
      rd_en => ROCAckInt, -- in    std_logic; 
      clk   => ClkUsr,    -- in    std_logic; 
      rst   => Reset,     -- in    std_logic; 
      dout  => TDCEvtReg(3 downto 0) ); -- out std_logic_vector (3 downto 0)
      
  FnextFull <= (FnFull(1) and ROCEn(1)) or (FnFull(2) and ROCEn(2))
            or (FnFull(3) and ROCEn(3)) or (FnFull(4) and ROCEn(4))
            or (FnFull(5) and ROCEn(5)) or (FnFull(6) and ROCEn(6))
            or (FnFull(7) and ROCEn(7)) or (FnFull(8) and ROCEn(8));
--  TestPt(8 downto 5) <= ReadOutTrg & TrgInhibit & FnFull(1) &  TIFFFullInt;
--  TestPt(4 downto 1) <= PreTrg & ExtraWord & BlkEndInt & SyncEvtSetInt;

end Behavioral;
