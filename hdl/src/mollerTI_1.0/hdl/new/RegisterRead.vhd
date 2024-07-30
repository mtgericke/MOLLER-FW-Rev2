
-- GU, Oct. 17, 2014


library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity RegisterRead is
  port(O   : out std_logic_vector(31 downto 0);
    Sync98ReadEn : inout std_logic;
    EvtReadEn : inout std_logic;
    CrateID  : in std_logic_vector(7 downto 0);
    BoardID : in std_logic_vector(7 downto 0);
    FiberLink : in std_logic_vector(15 downto 0);
    FiberEn : in  STD_LOGIC_VECTOR (7 downto 0);
    TrgSyncOutEn : in  STD_LOGIC;
    Interrupt : in  STD_LOGIC_VECTOR (31 downto 0);
    TrigDelayWidth : in  STD_LOGIC_VECTOR (31 downto 0);
    VmeAddress : in  STD_LOGIC_VECTOR (31 downto 0);
    BlockSize : in  STD_LOGIC_VECTOR (7 downto 0);
    NewBlkSize  : in std_logic_vector(31 downto 0);
    TIDataFormat : in  STD_LOGIC_VECTOR (7 downto 0);
    VMESetting : in  STD_LOGIC_VECTOR (31 downto 0);
    TrgSrcEn : in  STD_LOGIC_VECTOR (15 downto 0);
    TrgSrcMon : in  STD_LOGIC_VECTOR (15 downto 0);
    SyncSrcEn : in  STD_LOGIC_VECTOR (7 downto 0);
    SyncMon : in  STD_LOGIC_VECTOR (23 downto 0);
    BusySrcEn : in  STD_LOGIC_VECTOR (15 downto 0);
    BusySrcMon : in  STD_LOGIC_VECTOR (15 downto 0);
    ClockSrc : in  STD_LOGIC_VECTOR (31 downto 0);
    TrigPreScale : in  STD_LOGIC_VECTOR (15 downto 0);
    BlockTh : in  STD_LOGIC_VECTOR (7 downto 0);
    BlockAv : in std_logic_vector (39 downto 0);
    SyncEvtSet  : in std_logic;
    SReqSet  : in std_logic;
    SyncReadEn : out std_logic_vector(7 downto 0);
    FillEvent : in std_logic;
    EndOfRunBR  : in std_logic;
    TrgLost : in std_logic;
    TrigRule : in  STD_LOGIC_VECTOR (31 downto 0);
    TrigWindow : in  STD_LOGIC_VECTOR (31 downto 0);
    GtpTrgEn : in  STD_LOGIC_VECTOR (31 downto 0);
    ExtTrgEn : in  STD_LOGIC_VECTOR (31 downto 0);
    FPTrgEn : in  STD_LOGIC_VECTOR (31 downto 0);
    FPOutput : in  STD_LOGIC_VECTOR (15 downto 0);
    SyncDelay : in  STD_LOGIC_VECTOR (31 downto 0);
    GtpPreScaleA : in  STD_LOGIC_VECTOR (31 downto 0);
    GtpPreScaleB : in  STD_LOGIC_VECTOR (31 downto 0);
    GtpPreScaleC : in  STD_LOGIC_VECTOR (31 downto 0);
    GtpPreScaleD : in  STD_LOGIC_VECTOR (31 downto 0);
    ExtPreScaleA : in  STD_LOGIC_VECTOR (31 downto 0);
    ExtPreScaleB : in  STD_LOGIC_VECTOR (31 downto 0);
    ExtPreScaleC : in  STD_LOGIC_VECTOR (31 downto 0);
    ExtPreScaleD : in  STD_LOGIC_VECTOR (31 downto 0);
    ROCAckRd : in std_logic_vector (63 downto 0);
    FPPreScale : in  STD_LOGIC_VECTOR (31 downto 0);
    SyncCode : in  STD_LOGIC_VECTOR (7 downto 0);
    SyncGenDelay : in  STD_LOGIC_VECTOR (7 downto 0);
    SyncWidth : in  STD_LOGIC_VECTOR (7 downto 0);
    TrigCommand : in  STD_LOGIC_VECTOR (15 downto 0);
    RandomTrg : in  STD_LOGIC_VECTOR (15 downto 0);
    SoftTrg1  : in std_logic_vector(31 downto 0);
    SoftTrg2  : in std_logic_vector(31 downto 0);
    BlockTotal : in std_logic_vector (31 downto 0);
    RunCode    : in STD_LOGIC_VECTOR (31 downto 0);
    FiberDlyMeas : in std_logic_vector(63 downto 0);
    LiveTime : in std_logic_vector (31 downto 0);
    BusyTime : in std_logic_vector (31 downto 0);
    MgtStatus : in std_logic_vector (63 downto 0);
    MgtTrigBuf : in std_logic_vector (31 downto 0);
    TsTrgNum : in std_logic_vector(31 downto 0);
    TrgAck : in std_logic_vector(159 downto 0);
    SyncEvtGen : in  STD_LOGIC_VECTOR (31 downto 0);
    PromptTrgW : in std_logic_vector (7 downto 0);
    RegL1ANum  : in std_logic_vector(47 downto 0);
    ROCEn : in std_logic_vector (31 downto 0);
    TIResetReq : in std_logic_vector (8 downto 0);
    TsValid : in std_logic_vector(31 downto 0);
    EndOfRunBlk : in  STD_LOGIC_VECTOR (31 downto 0);
    TsScalar: in std_logic_vector(191 downto 0);
    SyncData : in std_logic_vector (39 downto 0);
    TIinfo  : in std_logic_vector(287 downto 0);
    ChannelDelay : in std_logic_vector(63 downto 0);
    TDCEvtReg : in std_logic_vector(3 downto 0);
    BusyCounter : in std_logic_vector(511 downto 0);
    MinRuleWidth : in std_logic_vector(31 downto 0);
    I2CAddData : in std_logic_vector(31 downto 0);
    I2CBusy : in std_logic;
    I2CRData : in std_logic_vector(31 downto 0);
    ReadAOut : in std_logic_vector(35 downto 0);
    ReadBOut : in std_logic_vector(35 downto 0);
    ClkFreq  : in std_logic_vector(31 downto 0);
    RegE4SPI  : in std_logic_vector(31 downto 0);
    Clock : in std_logic;
    Enable : in std_logic;
    DlyRValid : in std_logic;
    Address : in std_logic_vector(8 downto 0) );
end RegisterRead;

architecture RegisterRead_v of RegisterRead is

  signal Sync98ReadEnInt : std_logic;
  signal EvtReadEnInt : std_logic;

begin
  EvtReadEn <= EvtReadEnInt;
  Sync98ReadEn <= Sync98ReadEnInt;

  process(Clock, Enable)
  begin
    if (Clock'event and Clock = '1') then
      if (EvtReadEnInt = '1') then
        EvtReadEnInt <= '0';
      end if;
      if (Sync98ReadEnInt = '1') then
        Sync98ReadEnInt <= '0';
      end if;

      if (Enable = '1') then
        case Address(8 downto 2) is
          when "0000000" =>  O(31 downto 16) <= "0111000111100100";  -- 0x5dac  for Streaming Data ACquisition
                             O(15 downto 8) <= BoardID;
                             O(7 downto 0) <= CrateID;
          when "0000001" =>  O(7 downto 0) <= FiberEn(7 downto 0);
                             O(8) <= TrgSyncOutEn;
                             O(31 downto 16) <= FiberLink(15 downto 0);
          when "0000010" =>  O <= Interrupt;
          when "0000011" =>  O <= TrigDelayWidth;
          when "0000100" =>  O <= VMEAddress;
          when "0000101" =>  O(7 downto 0) <= BlockSize(7 downto 0);
                             O(31 downto 16) <= NewBlkSize(15 downto 0);
          when "0000110" =>  O(7 downto 0) <= TIDataFormat;
                             O(31 downto 16) <= NewBlkSize(31 downto 16);
          when "0000111" =>  O(31 downto 0) <= VmeSetting;
          when "0001000" =>  O(15 downto 0) <= TrgSrcEn(15 downto 0);
                             O(31 downto 16) <= TrgSrcMon(15 downto 0);
          when "0001001" =>  O(7 downto 0) <= SyncSrcEn(7 downto 0);
                             O(31 downto 8) <= SyncMon(23 downto 0);
          when "0001010" =>  O(15 downto 0) <= BusySrcEn(15 downto 0);
                             O(31 downto 16) <= BusySrcMon(15 downto 0);
          when "0001011" =>  O(31 downto 0) <= ClockSrc(31 downto 0);
          when "0001100" =>  O(15 downto 0) <= TrigPreScale;
          when "0001101" =>  O(7 downto 0) <= BlockTh(7 downto 0);
--        if (BlockAv(15 downto 8) = "00000000") then
--          O(15 downto 8) <= BlockAv(7 downto 0); -- BlockAv (15:0): number of blocks available,
--        else
--          O(15 downto 8) <= "11111111";        -- BlockAv(23:16): number of event before the full block
--        end if;
--        O(23 downto 16) <= BlockAv(23 downto 16);
                             O(15 downto 8) <= BlockAv(39 downto 32);
                             O(23 downto 16) <= BlockAv(31 downto 24);
                             if (TDCEvtReg(3) = '1' )  then
                               O(26 downto 24) <= "111";
                             else
                               O(26 downto 24) <= TDCEvtReg(2 downto 0);
                             end if;
                             O(27) <= TrgLost;
                             O(28) <= EndOfRunBR;
                             O(29) <= FillEvent;
                             O(30) <= SReqSet;
                             O(31) <= SyncEvtSet;
          when "0001110" =>  O <= TrigRule;
          when "0001111" =>  O <= TrigWindow;
          when "0010000" =>  O <= GtpTrgEn;
          when "0010001" =>  O <= ExtTrgEn;
          when "0010010" =>  O(31 downto 0) <= FPTrgEn;
          when "0010011" =>  O(15 downto 0) <= FPOutput;  -- software set output
                             O(31 downto 24) <= BlockAv(31 downto 24);
                             O(23 downto 16) <= BlockAv(39 downto 32);-- number of blocks for interrupt
          when "0010100" =>  O <= SyncDelay;
          when "0010101" =>  O <= GtpPreScaleA; -- ROCAckRd(31 downto 0);  moved ROCackRd to 0xC8 and 0xCC, Aug. 31, 2017
          when "0010110" =>  O <= GtpPreScaleB; -- ROCAckRd(63 downto 32);
          when "0010111" =>  O <= GtpPreScaleC(31 downto 0);
          when "0011000" =>  O <= GtpPreScaleD(31 downto 0);
          when "0011001" =>  O <= ExtPreScaleA(31 downto 0);
          when "0011010" =>  O <= ExtPreScaleB(31 downto 0);
                             EvtReadEnInt <= DlyRValid; -- '1';
          when "0011011" =>  O <= ExtPreScaleC(31 downto 0);
          when "0011100" =>  O <= ExtPreScaleD(31 downto 0);
          when "0011101" =>  O(31 downto 0) <= FPPreScale;
          when "0011110" =>  O(7 downto 0) <= SyncCode(7 downto 0);
          when "0011111" =>  O(7 downto 0) <= SyncGenDelay(7 downto 0);
          when "0100000" =>  O(7 downto 0) <= SyncWidth(7 downto 0);  -- reset width
          when "0100001" =>  O(15 downto 0) <= TrigCommand;
          when "0100010" =>  O(15 downto 0) <= RandomTrg;
          when "0100011" =>  O(31 downto 0) <= SoftTrg1;
          when "0100100" =>  O(31 downto 0) <= SoftTrg2;
          when "0100101" =>  O <= BlockAv(31 downto 0);  -- bit(31:24): number of events before the full block
          when "0100110" =>  Sync98ReadEnInt <= DlyRValid; -- '1';
                             if (SyncData(36) = '1') then
                               O <= "00000000000000000000000000000000";
                             else  -- SyncData(37): empty from FIFO; SyncData(36): registered empty;
            -- SyncData(38): prog_full; SyncData(39): Full; SyncData(35:20): timer using 31.25MHz clock
                               O <= SyncData(31 downto 0);
                             end if;
          when "0100111" =>  O(31 downto 0) <= RunCode;
          when "0101000" =>  O <= FiberDlyMeas(31 downto 0);
          when "0101001" =>  O <= FiberDlyMeas(63 downto 32);
          when "0101010" =>  O <= LiveTime;
          when "0101011" =>  O <= BusyTime;
          when "0101100" =>  O(31 downto 0) <= MgtStatus(31 downto 0);
          when "0101101" =>  O <= MgtStatus(63 downto 32);
          when "0101110" =>  O(31 downto 0) <= MgtTrigBuf(31 downto 0);
          when "0101111" =>  O <= TsTrgNum;
  --          when "0110000" => O <= TrgAck(31 downto 0);
  --          when "0110001" => O <= TrgAck(63 downto 32);
   --         when "0110010" => O <= TrgAck(95 downto 64);
   --         when "0110011" => O <= TrgAck(127 downto 96);
          when "0110000" =>  O(15 downto 0) <= TrgAck(15 downto 0);  -- bit(15:0) for TI#1, bit(31:16) for loopback
                             O(31 downto 16) <= TrgAck(143 downto 128);
          when "0110001" =>  O <= ROCAckRd(31 downto 0); -- TrgAck(63 downto 32);
          when "0110010" =>  O <= TrgAck(159 downto 144) & TrgAck(79 downto 64);
          when "0110011" =>  O <= ROCAckRd(63 downto 32); -- TrgAck(127 downto 96);
        --when "0110100" =>
         --O(15 downto 0) <= D21(15 downto 0);
        --O(31 downto 16) <= TrgAck(143 downto 128);
          when "0110100" =>  O(15 downto 0) <= TrgAck(159 downto 144);
                             O(31 downto 16) <= TrgAck(143 downto 128);
          when "0110101" =>  O <= SyncEvtGen;
          when "0110110" =>  O(7 downto 0) <= PromptTrgW;
                             O(31 downto 16) <= RegL1ANum(47 downto 32);
          when "0110111" =>  O <= RegL1ANum(31 downto 0);
          when "0111000" =>  O <= ClkFreq;
          when "0111001" =>  O <= RegE4SPI;
          when "0111011" =>  O(18 downto 0) <= ROCEn(18 downto 0);
                             O(28 downto 20) <= TIResetReq(8 downto 0);
          when "0111100" =>  O <= TsValid;
          when "0111111" =>  O <= EndOfRunBlk;
          when "1000001" =>  O <= ChannelDelay(31 downto 0);
          when "1000010" =>  O <= ChannelDelay(63 downto 32);
          when "1000100" =>  O <= BusyCounter(31 downto 0);
          when "1000101" =>  O <= BusyCounter(63 downto 32);
          when "1000110" =>  O <= BusyCounter(95 downto 64);
          when "1000111" =>  O <= BusyCounter(127 downto 96);
          when "1001000" =>  O <= BusyCounter(159 downto 128);
          when "1001001" =>  O <= BusyCounter(191 downto 160);
          when "1001010" =>  O <= BusyCounter(223 downto 192);
          when "1001110" =>  O <= MinRuleWidth(31 downto 0);
          when "1001111" => -- 0x13C newly added
                             O <= BlockTotal(31 downto 0);
          when "1011100" =>  O <= ReadAOut(34) & ReadAOut(30 downto 0);
          when "1011101" =>  O <= ReadBOut(34) & ReadBOut(30 downto 0);
          when "1100000" =>  SyncReadEn(2) <= '1';
                             O <= TsScalar(31 downto 0);
          when "1100001" =>  SyncReadEn(3) <= '1';
                             O <= TsScalar(63 downto 32);
          when "1100010" =>  SyncReadEn(4) <= '1';
                             O <= TsScalar(95 downto 64);
          when "1100011" =>  SyncReadEn(5) <= '1';
                             O <= TsScalar(127 downto 96);
          when "1100100" =>  SyncReadEn(6) <= '1';
                             O <= TsScalar(159 downto 128);
          when "1100101" =>  SyncReadEn(7) <= '1';
                             O <= TsScalar(191 downto 160);
          when "1100111" =>  O <= BusyCounter(255 downto 224);
          when "1101000" =>  O <= BusyCounter(287 downto 256);
          when "1101001" =>  O <= BusyCounter(319 downto 288);
          when "1101010" =>  O <= BusyCounter(351 downto 320);
          when "1101011" =>  O <= BusyCounter(383 downto 352);
          when "1101100" =>  O <= BusyCounter(415 downto 384);
          when "1101101" =>  O <= BusyCounter(447 downto 416);
          when "1101110" =>  O <= BusyCounter(479 downto 448);
          when "1101111" =>  O <= BusyCounter(511 downto 480);
          when "1110000" =>  O <= I2CBusy & I2CAddData(30 downto 16) & I2CRData(15 downto 0);
          when "1110100" =>  O(7 downto 0) <= TIinfo(7 downto 0);
                             O(15 downto 8) <= TIinfo(79 downto 72);
                             O(23 downto 16) <= TIinfo(151 downto 144);
                             O(31 downto 24) <= TIinfo(223 downto 216);
          when "1110101" =>  O(7 downto 0) <= TIinfo(15 downto 8);
                             O(15 downto 8) <= TIinfo(87 downto 80);
                             O(23 downto 16) <= TIinfo(159 downto 152);
                             O(31 downto 24) <= TIinfo(231 downto 224);
          when "1110110" =>  O(7 downto 0) <= TIinfo(23 downto 16);
                             O(15 downto 8) <= TIinfo(95 downto 88);
                             O(23 downto 16) <= TIinfo(167 downto 160);
                             O(31 downto 24) <= TIinfo(239 downto 232);
          when "1110111" =>  O(7 downto 0) <= TIinfo(31 downto 24);
                             O(15 downto 8) <= TIinfo(103 downto 96);
                             O(23 downto 16) <= TIinfo(175 downto 168);
                             O(31 downto 24) <= TIinfo(247 downto 240);
          when "1111000" =>  O(7 downto 0) <= TIinfo(39 downto 32);
                             O(15 downto 8) <= TIinfo(111 downto 104);
                             O(23 downto 16) <= TIinfo(183 downto 176);
                             O(31 downto 24) <= TIinfo(255 downto 248);
          when "1111001" =>  O(7 downto 0) <= TIinfo(47 downto 40);
                             O(15 downto 8) <= TIinfo(119 downto 112);
                             O(23 downto 16) <= TIinfo(191 downto 184);
                             O(31 downto 24) <= TIinfo(263 downto 256);
          when "1111010" =>  O(7 downto 0) <= TIinfo(55 downto 48);
                             O(15 downto 8) <= TIinfo(127 downto 120);
                             O(23 downto 16) <= TIinfo(199 downto 192);
                             O(31 downto 24) <= TIinfo(271 downto 264);
          when "1111011" =>  O(7 downto 0) <= TIinfo(63 downto 56);
                             O(15 downto 8) <= TIinfo(135 downto 128);
                             O(23 downto 16) <= TIinfo(207 downto 200);
                             O(31 downto 24) <= TIinfo(279 downto 272);
          when "1111100" =>  O(7 downto 0) <= TIinfo(71 downto 64);
                             O(15 downto 8) <= TIinfo(143 downto 136);
                             O(23 downto 16) <= TIinfo(215 downto 208);
                             O(31 downto 24) <= TIinfo(287 downto 280);
          when others =>     O <= x"bad" & x"add" & x"32"; -- BadAddVR (4-bit Version, 4-bit revision) V1.5 on Dec. 7, 2021
--        when others =>     O <= "0111000111100010" & "1001000000011101"; -- 0x71E2_901d (gold) on Jan. 10, 2022
        end case;
      else
        O <= "10111010110110101101110100010001"; --(others =>'0');
        SyncReadEn <= (others => '0');
      end if; -- end of enable
    end if; -- end of clock
  end process;
end RegisterRead_v;
