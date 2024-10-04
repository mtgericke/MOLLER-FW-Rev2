----------------------------------------------------------------------------------
-- Company: Thomas Jefferson National Accelerator Facility
-- Engineer:  GU
--
-- Create Date: 09/19/2018 1:37:43 AM
-- Design Name: TInode
-- Module Name: TInode - Behavioral
-- Project Name: Data Acquisition computer interface
-- Target Devices:  Xilinx Zync UltraScale+, zcu106
-- Tool Versions:  Vivado 2019.1
-- Description:  The TI node to be implemented in FPGA
--       The design is copied from TIpcieUS, which is beased on TIFPGAC.
--           The design should be the same as a TI, which can be either
--           a TImaster or a standard TI, with Fiber port#1 support only.
--
-- Dependencies:
--
-- Revision:
--
--   Feb. 14, 2019: Set the destination addresses to EC:CD:9A:06:8E:Timer(99:92)
--                  set the source addresses to      DO:EL:ST:DC:10(11,12,13):Timer(99:92)
--   June 10, 2020: Simplify to TI function only (removing the STDC functions)
--   July 17, 2020: un-wrap the xdmaWrapper module
--   Apr.20-May 3,2022: Updates from the latest TIpcieUS modules


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity TInode is
  Port (
  -- TI#1 interface
    TICLK_P     : in  std_logic;  -- Trigger MGT reference clock,  to be consistent with the ip core:
    TICLK_N     : in  std_logic;  --   TI1_x0y14 (MGT_x0Y14 for the FMC test board on zcu106)

    TI1RX_P     : in  std_logic;  -- serialized trigger/MGT IOB
    TI1RX_N     : in  std_logic;  -- QSFP RxTx(0) connection
    TI1TX_P     : out std_logic;
    TI1TX_N     : out std_logic;

    TI1SYNCRX_P : in  std_logic; -- TI_SYNC lvds signals
    TI1SYNCRX_N : in  std_logic; -- QSFP RxTx(2) connection
    TI1SYNCTX_P : out std_logic;
    TI1SYNCTX_N : out std_logic;

    -- TI1FMRX_P   : in  std_logic;  -- TI aux, or FiberMeasurement
    -- TI1FMRX_N   : in  std_logic;  -- QSFP RxTx(3) connection
    -- TI1FMTX_P   : out std_logic;
    -- TI1FMTX_N   : out std_logic;

    CLKREFO_P : out std_logic; -- clk_output from FPGA TI receiver
    CLKREFO_N : out std_logic;

  -- FPGA / TI logic clocks
    CLK250        : in std_logic;  -- system clock related to Clk250, 250MHz
    CLK625        : in std_logic;  -- system clock related to Clk250, 250MHz/4 = 62.5MHz
    CLKPrg        : in std_logic;  -- Always available clock, 50 MHz prefered.

  -- Decoded trigger/Reset, which can be used in the FPGA
    GENOUTP : out std_logic_vector(16 downto 1);  -- equivalent to the TI front panel (34-pin connector) outputs, and LED signals
    TCSOUT  : out std_logic_vector(16 downto 1);  -- Some extra RESET signals

  -- Trigger inputs, or TS_code inputs, which is similar to the TI front panel (34-pin connector) inputs
    GENINP  : in  std_logic_vector(16 downto 1);  -- ExtraIn(2:1) & TS(6:1) & Trg & BUSY
    SWM  : inout std_logic_vector(8 downto 1);

-- to interface with PCIe for IRQ
     axi_aresetn  : in std_logic; -- out axi_aresetn, synced with axi_aclk for axi interfaces reset
     usr_irq_req  : out std_logic_vector(3 downto 0); -- Interrupt(3 downto 0),
     usr_irq_ack  : out std_logic_vector(3 downto 0); -- PcieInterrupt_Ackd,
     msi_enable   : out std_logic; --    => Interrupt(15),

-- AXI light interface for register READ/WRITE.  512 Bytes are implemented.  (Addr(12:10) == 000, other bits are not checked)
    CLKReg      : in std_logic;
    m_axil_awaddr  : in STD_LOGIC_VECTOR(31 DOWNTO 0);   -- This signal is the address for a memory mapped write to the user logic from the HOST
    m_axil_awprot  : in STD_LOGIC_VECTOR(2 DOWNTO 0);    -- 3'h0
    m_axil_awvalid : in STD_LOGIC;                       -- the assertion of this signal means there is a valid write request to the address on m_axi_aWaddr
    m_axil_awready : out STD_LOGIC;                        -- Master write address ready
    m_axil_wdata   : in STD_LOGIC_VECTOR(31 DOWNTO 0);   -- master write data
    m_axil_wstrb   : in STD_LOGIC_VECTOR(3  DOWNTO 0);   -- master write strobe
    m_axil_wvalid  : in STD_LOGIC;  -- master write valid
    m_axil_wready  : out STD_LOGIC;   -- master write ready
    m_axil_araddr  : in STD_LOGIC_VECTOR(31 DOWNTO 0);  -- THis signal is the address for a memory mapped read to user logic from the host
    m_axil_arprot  : in STD_LOGIC_VECTOR(2 DOWNTO 0);   -- 3'h0
    m_axil_arvalid : in STD_LOGIC;                      -- the assertion of this signal means there is a valid read request to the address on m_axil_araddr
    m_axil_arready : out STD_LOGIC;                       -- master read address ready
    m_axil_rdata   : out STD_LOGIC_VECTOR(31 DOWNTO 0);   -- master read data
    m_axil_rresp   : out STD_LOGIC_VECTOR(1 DOWNTO 0);    -- master read response
    m_axil_rvalid  : out STD_LOGIC;                       -- master read valid
    m_axil_rready  : in STD_LOGIC;                      -- master  read ready

    m_axil_bresp : out STD_LOGIC_VECTOR(1 DOWNTO 0);  -- master write response
    m_axil_bvalid : out STD_LOGIC;
    m_axil_bready : in STD_LOGIC;

  -- Streaming interface to xDMA data readout, synced on ClkReg, common clock as the m_axi4_light interface
    -- C2H: from FPGA to Computer
    s_axis_c2h_tdata  : out STD_LOGIC_VECTOR(63 DOWNTO 0); -- transmit data from the user logic to the DMA
    s_axis_c2h_tlast  : out STD_LOGIC;                     -- The user logic asserts this signal to indicate the end of the DMA packet
    s_axis_c2h_tvalid : out STD_LOGIC;                     -- The user logic asserts this whenever it is driving valid data on s_axis_c2h_tdata
    s_axis_c2h_tready : in STD_LOGIC;                      -- DMA is ready to accept data.  If the DMA deassert this when the valid is high,
                                                           -- the user logic must keep the valid signal asserted until the ready signal is asserted.
    s_axis_c2h_tkeep  : out STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Bytes to keep, should be all 1s except the last word, where the 1s are LSB aligned

    -- H2C: from compputer to FPGA, not used
    m_axis_h2c_tdata   : in STD_LOGIC_VECTOR(63 DOWNTO 0);  -- Transmit data from the DMA to the user logic
    m_axis_h2c_tlast   : in STD_LOGIC;                      -- DMA asserts this siganl in the last beat of the DMApacket to indicate the end of the packet
    m_axis_h2c_tvalid  : in STD_LOGIC;                      -- The DMA asserts this whenever it is driving valid data on axis_h2c_tdata
    m_axis_h2c_tready  : out STD_LOGIC;                     -- Assertion of this signal by user logic indicates that it is ready to accept data. If the user logic deasserts the signal
                                                            -- when the valid signal is high, the DMA keeps the valid signal asserted until the ready signal is asserted.
    m_axis_h2c_tkeep   : in STD_LOGIC_VECTOR(7 DOWNTO 0) ); -- Bytes to keep, should be all 1s except the last word, where the 1s are LSB aligned
end TInode;

architecture Behavioral of TInode is

  component ClockCheck is
    Port ( ClkPrg : in STD_LOGIC;
           Clk250 : in STD_LOGIC;
           Clk625 : in STD_LOGIC;
           ClkChkd  : out STD_LOGIC_VECTOR (2 downto 0));
  end component ClockCheck;

  component SigReSync
    Port ( SigIn : in STD_LOGIC;
      ClkIn   : in  STD_LOGIC;
      ClkOut  : in  STD_LOGIC;
      SigOut  : out STD_LOGIC;
      SigOutR : out STD_LOGIC;
      SigOutF : out STD_LOGIC);
  end component SigReSync;

  component SigClkA2B is
    Port ( SigIn  : in STD_LOGIC;
           ClkIn  : in STD_LOGIC;
           ClkOut : in STD_LOGIC;
           SigOut : out STD_LOGIC);
  end component SigClkA2B;

  component ClockFreqMeas is
    Port ( Clock : in STD_LOGIC;
           ClkA : in STD_LOGIC;
           ClkB : in STD_LOGIC;
           ClkR : in STD_LOGIC;
           ClkFreq : out STD_LOGIC_VECTOR (31 downto 0));
  end component ClockFreqMeas;

  component RegisterSet is
    Port (Address : in  STD_LOGIC_VECTOR (8 downto 0);
      DataIn  : in std_logic_vector (31 downto 0);
      Clock   : in  STD_LOGIC;
      Reset   : in  STD_LOGIC;                          -- negative logic
      BAR     : in  STD_LOGIC_VECTOR (2 downto 0);
      Enable  : in  STD_LOGIC;
      CrateID : out std_logic_vector (7 downto 0);
      CrateIDEn : out std_logic;
      FiberEn   : out  STD_LOGIC_VECTOR (7 downto 0);
      TrgSyncOutEn : out  STD_LOGIC;
      IntrptID    : out  STD_LOGIC_VECTOR (7 downto 0);
      IntrptLevel : out  STD_LOGIC_VECTOR (2 downto 0);
      IntrptEn    : out std_logic;
      TrigDelayWidth : out  STD_LOGIC_VECTOR (31 downto 0);
      VmeAddress   : out  STD_LOGIC_VECTOR (31 downto 0);
      BlockSize    : out  STD_LOGIC_VECTOR (7 downto 0);
      TIDataFormat : out  STD_LOGIC_VECTOR (7 downto 0);
      VMESetting   : out  STD_LOGIC_VECTOR (31 downto 0);
      I2CAdd       : out  STD_LOGIC;
--    EnableCntl : out  STD_LOGIC_VECTOR (15 downto 0);
      TrgSrcEn  : out  STD_LOGIC_VECTOR (15 downto 0);
      TrgSrcSet : out std_logic;
      SyncSrcEn : out  STD_LOGIC_VECTOR (15 downto 0);
      BusySrcEn : out  STD_LOGIC_VECTOR (15 downto 0);
      ClkSrcSet : out std_logic;
      ClockSrc  : out  STD_LOGIC_VECTOR (31 downto 0);
      TrigPreScale : out  STD_LOGIC_VECTOR (15 downto 0);
      BlockTh    : out  STD_LOGIC_VECTOR (7 downto 0);
      TrigRule   : out  STD_LOGIC_VECTOR (31 downto 0);
      TrigWindow : out  STD_LOGIC_VECTOR (31 downto 0);
      GtpTrgEn   : out  STD_LOGIC_VECTOR (31 downto 0);
      ExtTrgEn   : out  STD_LOGIC_VECTOR (31 downto 0);
      FPTrgEn    : out  STD_LOGIC_VECTOR (31 downto 0);
      FPOutput   : out  STD_LOGIC_VECTOR (15 downto 0);
      SyncDelay  : out  STD_LOGIC_VECTOR (31 downto 0);
      GtpPreScaleA : out  STD_LOGIC_VECTOR (31 downto 0);
      GtpPreScaleB : out  STD_LOGIC_VECTOR (31 downto 0);
      GtpPreScaleC : out  STD_LOGIC_VECTOR (31 downto 0);
      GtpPreScaleD : out  STD_LOGIC_VECTOR (31 downto 0);
      ExtPreScaleA : out  STD_LOGIC_VECTOR (31 downto 0);
      ExtPreScaleB : out  STD_LOGIC_VECTOR (31 downto 0);
      ExtPreScaleC : out  STD_LOGIC_VECTOR (31 downto 0);
      ExtPreScaleD : out  STD_LOGIC_VECTOR (31 downto 0);
      LTTableLoad  : out std_logic;
      VmeEvtType   : out  STD_LOGIC_VECTOR (31 downto 0);
      SyncGenDelay : out  STD_LOGIC_VECTOR (7 downto 0);
      SyncWidth    : out  STD_LOGIC_VECTOR (7 downto 0);
      TrigCommandEn : out  STD_LOGIC;
      TrigCommand : out  STD_LOGIC_VECTOR (15 downto 0);
      RandomTrgEn : out  STD_LOGIC;
      RandomTrg   : out  STD_LOGIC_VECTOR (15 downto 0);
      SoftTrg1En  : out  STD_LOGIC;
      SoftTrg1    : out  STD_LOGIC_VECTOR (31 downto 0);
      SoftTrg2En : out  STD_LOGIC;
      SoftTrg2   : out  STD_LOGIC_VECTOR (31 downto 0);
      SyncCodeEn : out  STD_LOGIC;
      SyncCode   : out  STD_LOGIC_VECTOR (7 downto 0);
      RunCode    : out  STD_LOGIC_VECTOR (31 downto 0);
      SyncEvtGen : out  STD_LOGIC_VECTOR (31 downto 0);
      PromptTrgW : out std_logic_vector (7 downto 0);
      ROCEn      : out std_logic_vector (31 downto 0);
      EndOfRunBlk : out  STD_LOGIC_VECTOR (31 downto 0);
      TrgTblData  : out std_logic_vector(31 downto 0);
      TrgTblAdr : out std_logic_vector(3 downto 0);
      TrgTblWEN : out std_logic;
      ForceTrgSrcSet : out std_logic;
      RunGo   : out std_logic;
      Reg104D : out std_logic_vector(31 downto 0);
      Reg108D : out std_logic_vector(31 downto 0);
      Reg10cD : out std_logic_vector(31 downto 0);
      Reg110D : out std_logic_vector(31 downto 0);
      Reg114D : out std_logic_vector(31 downto 0);
      Reg118D : out std_logic_vector(31 downto 0);
      Reg11cD : out std_logic_vector(31 downto 0);
      Reg120D : out std_logic_vector(31 downto 0);
      Reg124D : out std_logic_vector(31 downto 0);
      Reg128D : out std_logic_vector(31 downto 0);
      Reg12cD : out std_logic_vector(31 downto 0);
      Reg130D : out std_logic_vector(31 downto 0);
      MinRuleWidth : out std_logic_vector(31 downto 0);
      I2CAddData   : out std_logic_vector(31 downto 0);
      VmeReset     : out std_logic_vector(31 downto 0)  );
  end component; --RegisterSet;

  component RegisterRead is
    port(O         : out std_logic_vector(31 downto 0);
      Sync98ReadEn : inout std_logic;
      EvtReadEn : inout std_logic;
      CrateID   : in std_logic_vector(7 downto 0);
      BoardID   : in std_logic_vector(7 downto 0);
      FiberLink : in std_logic_vector(15 downto 0);
      FiberEn   : in  STD_LOGIC_VECTOR (7 downto 0);
      TrgSyncOutEn   : in  STD_LOGIC;
      Interrupt      : in  STD_LOGIC_VECTOR (31 downto 0);
      TrigDelayWidth : in  STD_LOGIC_VECTOR (31 downto 0);
      VmeAddress     : in  STD_LOGIC_VECTOR (31 downto 0);
      BlockSize      : in  STD_LOGIC_VECTOR (7 downto 0);
      NewBlkSize     : in std_logic_vector(31 downto 0);
      TIDataFormat : in  STD_LOGIC_VECTOR (7 downto 0);
      VMESetting   : in  STD_LOGIC_VECTOR (31 downto 0);
      TrgSrcEn     : in  STD_LOGIC_VECTOR (15 downto 0);
      TrgSrcMon    : in  STD_LOGIC_VECTOR (15 downto 0);
      SyncSrcEn    : in  STD_LOGIC_VECTOR (7 downto 0);
      SyncMon      : in  STD_LOGIC_VECTOR (23 downto 0);
      BusySrcEn    : in  STD_LOGIC_VECTOR (15 downto 0);
      BusySrcMon   : in  STD_LOGIC_VECTOR (15 downto 0);
      ClockSrc     : in  STD_LOGIC_VECTOR (31 downto 0);
      TrigPreScale : in  STD_LOGIC_VECTOR (15 downto 0);
      BlockTh      : in  STD_LOGIC_VECTOR (7 downto 0);
      BlockAv      : in std_logic_vector (39 downto 0);
      SyncEvtSet   : in std_logic;
      SReqSet    : in std_logic;
      SyncReadEn : out std_logic_vector(7 downto 0);
      FillEvent  : in std_logic;
      EndOfRunBR : in std_logic;
      TrgLost : in std_logic;
      TrigRule   : in  STD_LOGIC_VECTOR (31 downto 0);
      TrigWindow : in  STD_LOGIC_VECTOR (31 downto 0);
      GtpTrgEn   : in  STD_LOGIC_VECTOR (31 downto 0);
      ExtTrgEn   : in  STD_LOGIC_VECTOR (31 downto 0);
      FPTrgEn    : in  STD_LOGIC_VECTOR (31 downto 0);
      FPOutput   : in  STD_LOGIC_VECTOR (15 downto 0);
      SyncDelay  : in  STD_LOGIC_VECTOR (31 downto 0);
      GtpPreScaleA : in  STD_LOGIC_VECTOR (31 downto 0);
      GtpPreScaleB : in  STD_LOGIC_VECTOR (31 downto 0);
      GtpPreScaleC : in  STD_LOGIC_VECTOR (31 downto 0);
      GtpPreScaleD : in  STD_LOGIC_VECTOR (31 downto 0);
      ExtPreScaleA : in  STD_LOGIC_VECTOR (31 downto 0);
      ExtPreScaleB : in  STD_LOGIC_VECTOR (31 downto 0);
      ExtPreScaleC : in  STD_LOGIC_VECTOR (31 downto 0);
      ExtPreScaleD : in  STD_LOGIC_VECTOR (31 downto 0);
      ROCAckRd   : in  std_logic_vector (63 downto 0);
      FPPreScale : in  STD_LOGIC_VECTOR (31 downto 0);
      SyncCode   : in  STD_LOGIC_VECTOR (7 downto 0);
      SyncGenDelay : in  STD_LOGIC_VECTOR (7 downto 0);
      SyncWidth    : in  STD_LOGIC_VECTOR (7 downto 0);
      TrigCommand  : in  STD_LOGIC_VECTOR (15 downto 0);
      RandomTrg  : in  STD_LOGIC_VECTOR (15 downto 0);
      SoftTrg1   : in std_logic_vector(31 downto 0);
      SoftTrg2   : in std_logic_vector(31 downto 0);
      BlockTotal : in std_logic_vector (31 downto 0);
      RunCode    : in  STD_LOGIC_VECTOR (31 downto 0);
      FiberDlyMeas : in std_logic_vector(63 downto 0);
      LiveTime   : in std_logic_vector (31 downto 0);
      BusyTime   : in std_logic_vector (31 downto 0);
      MgtStatus  : in std_logic_vector (63 downto 0);
      MgtTrigBuf : in std_logic_vector (31 downto 0);
      TsTrgNum   : in std_logic_vector(31 downto 0);
      TrgAck     : in std_logic_vector(159 downto 0);
      SyncEvtGen : in  STD_LOGIC_VECTOR (31 downto 0);
      PromptTrgW : in std_logic_vector (7 downto 0);
      RegL1ANum  : in std_logic_vector(47 downto 0);
      ROCEn      : in std_logic_vector (31 downto 0);
      TIResetReq : in std_logic_vector (8 downto 0);
      TsValid    : in std_logic_vector(31 downto 0);
      EndOfRunBlk : in  STD_LOGIC_VECTOR (31 downto 0);
      TsScalar : in std_logic_vector(191 downto 0);
      SyncData : in std_logic_vector (39 downto 0);
      TIinfo   : in std_logic_vector(287 downto 0);
      ChannelDelay : in std_logic_vector(63 downto 0);
      TDCEvtReg    : in std_logic_vector(3 downto 0);
      BusyCounter  : in std_logic_vector(511 downto 0);
      MinRuleWidth : in std_logic_vector(31 downto 0);
      I2CAddData : in std_logic_vector(31 downto 0);
      I2CBusy    : in std_logic;
      I2CRData : in std_logic_vector(31 downto 0);
      ReadAOut : in std_logic_vector(35 downto 0);
      ReadBOut : in std_logic_vector(35 downto 0);
      ClkFreq  : in std_logic_vector(31 downto 0);
      Clock    : in std_logic;
      Enable   : in std_logic;
      DlyRValid : in std_logic;
      Address  : in std_logic_vector(8 downto 0) );
  end component; -- RegisterRead;

  component TrgMGT1L
    Port ( ClkRef : in STD_LOGIC;
      ClkRcvd : out std_logic;
      ClkFree   : in std_logic;
      MasterMode : in STD_LOGIC_VECTOR (3 downto 1);
      WriteStart : in STD_LOGIC;
      ReadStart : in STD_LOGIC;
      StatusEn : in std_logic;
      RxGT_P : in STD_LOGIC;
      RxGT_N : in STD_LOGIC;
      TxGT_P : out STD_LOGIC;
      TxGT_N : out STD_LOGIC;
      Status : in STD_LOGIC_VECTOR (15 downto 0);
      TsData : in STD_LOGIC_VECTOR (15 downto 0);
      Reset : in STD_LOGIC;
      TrgSendEn : in STD_LOGIC;
      Clk250 : in STD_LOGIC;
      Clk625 : in STD_LOGIC;

 -- newly added signals
      RstGtp    : in std_logic;
      VRstGtp   : inout std_logic;
      SyncedRst : out std_logic;
      VmeReset  : in std_logic_vector(31 downto 0);
      FiberRdy  : in std_logic;
      TsWrStart : in std_logic;
      TsRdStart : in std_logic;
      TrgBufE   : out std_logic_vector(9 downto 0);
      GTPStA    : out std_logic_vector(31 downto 0);

      TrgAProm : out STD_LOGIC;
      TrgData  : out STD_LOGIC_VECTOR (15 downto 0);
      StatusA  : inout STD_LOGIC_VECTOR (15 downto 0);
      TsLpData : out STD_LOGIC_VECTOR (15 downto 0);
      GT5Data  : out std_logic_vector(15 downto 0);
      GT5K     : out std_logic_vector(1 downto 0);
      RxAErr : out STD_LOGIC;
      RxEn   : out std_logic_vector(1 downto 0);
      GTStatus : inout STD_LOGIC_VECTOR (95 downto 0));
  end component TrgMGT1L;

  Component FiberLength is
    Port ( Clock : in STD_LOGIC;
      MReturn : in STD_LOGIC;
      MasterMode : in STD_LOGIC;
      VmeRst : in STD_LOGIC_VECTOR (15 downto 0);
      DSMout : out STD_LOGIC;
      ReadData : out STD_LOGIC_VECTOR (31 downto 0);
      TestPt : out STD_LOGIC_VECTOR (8 downto 1));
  end component FiberLength;

  component TCSsyncNode is
    Port ( CLock : in STD_LOGIC;
      ClkSlow    : in std_logic;
      SyncIn_P   : in STD_LOGIC;
      SyncIn_N   : in STD_LOGIC;
      ReadStart  : out STD_LOGIC;
      WriteStart : out STD_LOGIC;
      TSRdStart  : out STD_LOGIC;
      TSWrStart  : out STD_LOGIC;
      DlyReady   : out STD_LOGIC;
      ClkLockEn  : in STD_LOGIC;
      SyncSrcEn  : in std_logic_vector(7 downto 0);
      ResetWidth : in std_logic_vector(7 downto 0);
      VmeRst     : in std_logic_vector(15 downto 0);
      SResetOut  : out STD_LOGIC_VECTOR (15 downto 0);
      Reset      : inout std_logic;
      SyncRst_P  : out std_logic;
      SyncRst_N  : out std_logic;
      FPsync     : in STD_LOGIC;
      TSInhibit  : out STD_LOGIC;
      SCReadEn   : in std_logic;
      SyncDelay  : in STD_LOGIC_VECTOR (31 downto 0);
      MasterMode : in STD_LOGIC_VECTOR (3 downto 1);
      SyncCodeIn : in STD_LOGIC_VECTOR (7 downto 0);
      SyncGenDly : in STD_LOGIC_VECTOR (7 downto 0);
      SyncCodeEn : in STD_LOGIC;
      ClkVme     : in STD_LOGIC;
      TIBusy     : in STD_LOGIC_VECTOR (8 downto 0);
      BusySrcEn  : in STD_LOGIC_VECTOR (15 downto 0);
      SRespTI    : in STD_LOGIC_VECTOR (8 downto 0);
      SReqSet    : in STD_LOGIC;
      TrgSyncOutEn : in std_logic;
      SetClkSrc    : in std_logic;
      IODlyRst     : in std_logic;
      TrgSendEn   : out STD_LOGIC;
      SyncCodedA  : out STD_LOGIC;
      SyncCodedB  : out STD_LOGIC;
      TestPt      : out std_logic_Vector(8 downto 1);
      SyncRead    : out std_logic_vector(31 downto 0);
      StatSync    : out std_logic_vector(7 downto 0);
      SyncCode    : out STD_LOGIC_VECTOR (39 downto 0));
  end component TCSsyncNode;

  component TrigMux
    port ( ClkUsr  : in    std_logic;
      Clk250       : in    std_logic;
      GtpRxEn      : in    std_logic_vector (8 downto 0);
      LBTrig       : in    std_logic_vector (15 downto 0);
      Reset        : in    std_logic;
      Rev2TS       : in    std_logic_vector (7 downto 0);
      SoftSW       : in    std_logic_vector (3 downto 1);
      SubTrig      : in    std_logic_vector (15 downto 0);
      TrigCode     : in    std_logic_vector (15 downto 0);
      TrgLenDly    : in    std_logic_vector (31 downto 0);
      TrgSrcEn     : in    std_logic_vector (15 downto 0);
      TrgSrcSet    : in    std_logic;
      TrgSyncOutEn : in    std_logic;
      TSrev2TrgIn  : in    std_logic;
      TsStrobe     : in    std_logic;
      VmeUpdtEn    : in    std_logic;
      AddTrgType   : out   std_logic_vector (16 downto 0);
      DSyncEvt     : out   std_logic;
      EvtTypeOut   : out   std_logic_vector (7 downto 0);
      L1Trged      : out   std_logic;
      NewBlkSize   : out   std_logic_vector (31 downto 0);
      RegTrgTime   : out   std_logic;
      SyncEvt      : out   std_logic;
      TestPt       : out   std_logic_vector (4 downto 1);
      TrgStat      : out   std_logic_vector (7 downto 0);
      Trg1Ack      : out   std_logic;
      Trg2Ack      : out   std_logic;
      Trigger1     : out   std_logic;
      Trigger2     : out   std_logic;
      TSrev2Sync   : out   std_logic;
      UpdateBS     : out   std_logic;
      UpdateBuf    : out   std_logic);
  end component;

  component TSTrigGen
    port ( BlkEnd     : in    std_logic;
      BlockSize       : in    std_logic_vector (7 downto 0);
      Busy            : in    std_logic;
      ChannelDelay    : in    std_logic_vector (63 downto 0);
      ClKSelTrgRule   : in    std_logic;
--      ClkSlow         : in    std_logic;
      ClkVme          : in    std_logic;
      Clk250          : in    std_logic;
      Clk625          : in    std_logic;
      EndOfRun        : in    std_logic;
      EndOfRunBlk     : in    std_logic_vector (31 downto 0);
      FiberTrged      : in    std_logic;
      ForceSyncEvt    : in    std_logic;
      FPTrgIn         : in    std_logic;
      MasterMode      : in    std_logic;
      MinRuleWidth    : in    std_logic_vector (31 downto 0);
      PeriodA         : in    std_logic_vector (31 downto 0);
      PSFactor        : in    std_logic_vector (15 downto 0);
      P2TrgIn         : in    std_logic;
      Reset           : in    std_logic;
      RTrgRate        : in    std_logic_vector (15 downto 0);
      ScalarEnableSet : in    std_logic_vector (2 downto 1);
      ScalarLatch     : in    std_logic;
      ScalarReset     : in    std_logic;
      SReqSet         : in    std_logic;
      SyncEvtGen      : in    std_logic_vector (31 downto 0);
      TrgSrcEn        : in    std_logic_vector (15 downto 0);
      TrgTblAdr       : in    std_logic_vector (3 downto 0);
      TrgTblData      : in    std_logic_vector (31 downto 0);
      TrgTblWE        : in    std_logic;
      TrgWidth        : in    std_logic_vector (7 downto 0);
      TSEn            : in    std_logic_vector (6 downto 1);
      TsIn            : in    std_logic_vector (6 downto 1);
      TsMatch         : in    std_logic_vector (31 downto 0);
      TsPreScale      : in    std_logic_vector (24 downto 1);
      TsVmeCmd        : in    std_logic_vector (11 downto 0);
      TsVmeEn         : in    std_logic;
      VmeEvtType      : in    std_logic_vector (31 downto 0);
      VmeTrg1Load     : in    std_logic;
      VmeTrg1Set      : in    std_logic_vector (31 downto 0);
      VmeTrg2Load     : in    std_logic;
      VmeTrg2Set      : in    std_logic_vector (31 downto 0);
      DisTrg          : out   std_logic;
      EndOfRunBR      : out   std_logic;
      FillEvent       : out   std_logic;
      GrsTrged        : out   std_logic;
      GrsTrgNum       : out   std_logic_vector (31 downto 0);
      PreTable        : out   std_logic_vector (6 downto 1);
      PromptTrg       : out   std_logic;
      SyncBlkEnd      : out   std_logic;
      TDTrig          : out   std_logic;
      TempBusy        : out   std_logic;
      TestPt          : out   std_logic_vector (24 downto 1);
      TrigCode        : out   std_logic;
      Triggered       : out   std_logic;
      TsData          : out   std_logic_vector (15 downto 0);
      Monitor         : out   std_logic_vector(31 downto 0);
      TsScalar        : out   std_logic_vector (191 downto 0);
      TsValid         : out   std_logic_vector (31 downto 0));
  end component;

  component DataGeneration
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
  end component;

  component TrgBitFifo
    Port ( GtpTrgIn : in  STD_LOGIC_VECTOR (31 downto 0);  -- They are all 4 ns wide pulses
      ExtTrgIn : in  STD_LOGIC_VECTOR (31 downto 0);
      FpTrgIn  : in  STD_LOGIC_VECTOR (31 downto 0);
      GtpTrgInEn : in std_logic;
      ExtTrgInEn : in std_logic;
      FpTrgInEN  : in std_logic;  -- These three channels work simultanousely
      SyncDly : in  STD_LOGIC_VECTOR (7 downto 0);
      SerialDly : in std_logic_vector(7 downto 0);
      QuadTime : in  STD_LOGIC_VECTOR (1 downto 0);
      Clk250 : in  STD_LOGIC;
      Reset : in  STD_LOGIC;
      WindowDly : in std_logic_vector(4 downto 0);
      TestPt    : out    std_logic_vector(10 downto 1);
      TrgInput : inout  STD_LOGIC_VECTOR (95 downto 0));
  end component TrgBitFifo;

  component TIinBusy
    port (SwaBusy     : in    std_logic;
      SwbBusy     : in    std_logic;
      BusySrcEn   : in    std_logic_vector (15 downto 0);
      Clock       : in    std_logic;
      CountLatch  : in    std_logic;
      CountReset  : in    std_logic;
      FadcBusy    : in    std_logic;
      FPBusy      : in    std_logic;
      FtdcBusy    : in    std_logic;
      P2Busy      : in    std_logic;
      TIFifoFull  : in    std_logic;
      BusyCounter : out   std_logic_vector (191 downto 0);
      StatBusy    : out   std_logic_vector (5 downto 0);
      TIBusy      : out   std_logic);
  end component;

  component TDTImBusy
    port (BlockTh : in    std_logic_vector (7 downto 0);
      BusySrcEn   : in    std_logic_vector (15 downto 0);
      ClkVme      : in    std_logic;
      Clk625      : in    std_logic;
      ClkRead     : in    std_logic;
      CountLatch  : in    std_logic;
      CountReset  : in    std_logic;
      GTPRxEn     : in    std_logic_vector (8 downto 0);
      LpBkEn      : in    std_logic;
      PulseTrig   : in    std_logic;
      ReadAen     : in    std_logic;
      ReadBen     : in    std_logic;
      Reset       : in    std_logic;
      ResetFS     : in    std_logic;
      ROCEN       : in    std_logic_vector (31 downto 0);
      StatusA     : in    std_logic_vector (15 downto 0);
      StatusB     : in    std_logic_vector (15 downto 0);
      StatusC     : in    std_logic_vector (15 downto 0);
      StatusD     : in    std_logic_vector (15 downto 0);
      StatusE     : in    std_logic_vector (15 downto 0);
      StatusF     : in    std_logic_vector (15 downto 0);
      StatusG     : in    std_logic_vector (15 downto 0);
      StatusH     : in    std_logic_vector (15 downto 0);
      StatusZ     : in    std_logic_vector (15 downto 0);
      SyncBlkEnd  : in    std_logic;
      TempBusy    : in    std_logic;
      TSInhibit   : in    std_logic;
      BoardRdy    : out   std_logic_vector (8 downto 0);
      BusyCounter : out   std_logic_vector (319 downto 0);
      BusyTI      : out   std_logic_vector (8 downto 0);
      ExtraAck    : out   std_logic;
      ReadAout    : out   std_logic_vector (35 downto 0);
      ReadBout    : out   std_logic_vector (35 downto 0);
      SReqSet     : out   std_logic;
      SRespTI     : out   std_logic_vector (8 downto 0);
      TestPt      : out   std_logic_vector (4 downto 1);
      TIBusy      : out   std_logic_vector (8 downto 0);
      TIinfo      : out   std_logic_vector (287 downto 0);
      TIResetReq  : out   std_logic_vector (8 downto 0);
      TrgLossBusy : out   std_logic;
      TSBusy      : out   std_logic;
      TsReadB     : out   std_logic_vector (159 downto 0));
  end component;

  component StatusGen
    Port (TrgEnDis   : in  STD_LOGIC;
      ForceTrgSrcSet : in std_logic;
      StatusIn       : in  STD_LOGIC_VECTOR (15 downto 0);
      StatusOut      : inout  STD_LOGIC_VECTOR (15 downto 0);
      GtpTxEn        : out  STD_LOGIC;
      Clk            : in std_logic;
      SRstReq        : in  STD_LOGIC;
      SendID         : in std_logic;
      BlkSizeUD      : in std_logic;
      NewBlkSize     : in std_logic_vector (31 downto 0);
      BufSizeUD      : in std_logic;
      CrateID        : in  STD_LOGIC_VECTOR (7 downto 0);
      TrgSrc         : in  STD_LOGIC_VECTOR (15 downto 0);
      TestPt         : out std_logic_vector (4 downto 1));
  end component;

  component IRQbusy
    Port (Busy    : out  STD_LOGIC;
      BlockTh     : in  STD_LOGIC_VECTOR (7 downto 0);
      BufSize     : in  STD_LOGIC_VECTOR (7 downto 0);
      VmeSetting  : in  STD_LOGIC_VECTOR (31 downto 0);
      IRQcount    : in  STD_LOGIC_VECTOR (7 downto 0)   );
  end component;

  component SignalExtend
    port (Clock : in    std_logic;
      SigIn     : in    std_logic;
      SigOut    : out   std_logic);
  end component;

  component SignalF2S
    Port ( Clk250 : in STD_LOGIC;
      Clk625      : in STD_LOGIC;
      SigIn250    : in STD_LOGIC;
      SigOut625   : inout STD_LOGIC);
  end component;

  component Signal2Clk
    Port (Clk   : in STD_LOGIC;
      FakeClkIn : in STD_LOGIC;
      SigOut    : inout STD_LOGIC);
  end component;

  component  WordBuffer is
    port (Clock  : in    std_logic;
      Data     : in    std_logic_vector (71 downto 0);
      FifoREn  : in    std_logic;
      Reset    : in    std_logic;
      Write_En : in    std_logic;
      FnEmpty  : out   std_logic;
      FnFull   : out   std_logic;
      Status   : out   std_logic_vector(31 downto 0);
      MedOut   : out   std_logic_vector (35 downto 0));
  end component;

  component BlockReadBuf is
    port ( ClkRead : in    std_logic;
      ClkWrite     : in    std_logic;
      DataIn       : in    std_logic_vector (71 downto 0);
      ReadEnIn     : in    std_logic;
      Reset        : in    std_logic;
      WriteEn      : in    std_logic;
      BufferBusy   : out   std_logic;
      DataOut      : out   std_logic_vector (71 downto 0);
      DataValid    : out   std_logic;
      DWAvailable  : out   std_logic_vector (15 downto 0);
      FifoPFull    : out   std_logic;
      ReadyForRead : out   std_logic;
      Status       : out   std_logic_vector (15 downto 0);
      WordCount    : out   std_logic_vector (15 downto 0));
  end component;

  COMPONENT Count48DSP
    PORT (CLK : IN STD_LOGIC;
      CE : IN STD_LOGIC;
      SCLR : IN STD_LOGIC;
      Q : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)  );
  END COMPONENT;

  COMPONENT AxisFifo
    PORT (s_axis_aresetn : IN STD_LOGIC;
      s_axis_aclk : IN STD_LOGIC;
      s_axis_tvalid : IN STD_LOGIC;
      s_axis_tready : OUT STD_LOGIC;
      s_axis_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      s_axis_tlast : IN STD_LOGIC;
      m_axis_tvalid : OUT STD_LOGIC;
      m_axis_tready : IN STD_LOGIC;
      m_axis_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      m_axis_tlast : OUT STD_LOGIC;
      almost_empty : OUT STD_LOGIC;
      almost_full : OUT STD_LOGIC  );
  END COMPONENT;

-- used clock names
  signal ClkPcieIn : std_logic;
  signal ClkPcieInRef : std_logic; -- Ref CLock to GT
  signal Clk100Pcie : std_logic;
  signal ClkCore : std_logic; -- Core clock from TenGigaEth block to QSFP
  signal CsTime : std_logic_vector(47 downto 0);
  signal Reset : std_logic;
  signal Rsync : std_logic;
-- interface for PCIE completer
  signal EvtReadEn  : std_logic;   -- bump the data read fifo
  signal Sync98ReadEn : std_logic;
  signal SyncReadEn : std_logic_vector(7 downto 0);  -- bump the Sync history fifo
  signal BlockAv : std_logic_vector(39 downto 0);
  signal SyncEvtSet  : std_logic;
  signal SReqSet   : std_logic;
  signal FillEvent : std_logic;
  signal EndOfRunBR : std_logic;
  signal MasterOld   : std_logic;
  signal BoardBusy   : std_logic;
  signal BoardActive : std_logic;
  signal BusyCntEn  : std_logic;
  signal LiveCntEn  : std_logic;
  signal LiveTime : std_logic_vector(39 downto 0);
  signal BusyTime : std_logic_vector(39 downto 0);
  signal LLiveTime : std_logic_vector(31 downto 0);
  signal LBusyTime : std_logic_vector(31 downto 0);
  signal ROCAckRd : std_logic_vector(63 downto 0);
  signal BlockTotal : std_logic_vector(31 downto 0);
  signal FiberDlyMeas : std_logic_vector(63 downto 0);
  signal TrgAck : std_logic_vector(159 downto 0);
  signal RegL1ANum : std_logic_vector(47 downto 0);
  signal TIResetReq : std_logic_vector(8 downto 0);
  signal TsValid : std_logic_vector(31 downto 0);
  signal TsScalar : std_logic_vector(191 downto 0);
  signal SyncData : std_logic_vector(39 downto 0);
  signal TIinfo    : std_logic_vector(287 downto 0);
  signal ChannelDelay : std_logic_vector(63 downto 0);
  signal TDCEvtReg : std_logic_vector(3 downto 0);
  signal NewBlkSize : std_logic_vector(31 downto 0);
  signal TrgBufE : std_logic_vector(31 downto 0);
  signal BusyCounter : std_logic_vector(511 downto 0);
-- signals for QSFP
  signal ClkQsfp : std_logic;
  signal Clk2Qsfp : std_logic;
  signal DataPcie : std_logic_vector(269 downto 0);
  signal H2CReady    : std_logic;
  signal H2CFifoFull : std_logic;

  signal FQEmpty : std_logic;
  signal FQReadEn : std_logic;
--  signal FIFODataA : std_logic_vector(539 downto 0);
  signal FIFOValA : std_logic;
  signal FIFODataB : std_logic_vector(269 downto 0);
  signal FIFOValB : std_logic;
  signal DataValidP : std_logic;
  signal QSFPReady : std_logic;
  signal PCIERdyTI   : std_logic;
  signal PCIERdySTDC : std_logic;
  signal PCIERdyGBE  : std_logic;
  signal gtwiz_reset_tx_done : std_logic;
  signal gtwiz_reset_rx_done : std_logic;
  signal ClkQsfpInRef : std_logic;
  signal ClkQsfpIn : std_logic;
  signal TxKmark : std_logic_vector(63 downto 0);
  signal RxKmark : std_logic_vector(127 downto 0);
  signal RxNotinTable : std_logic_vector(63 downto 0);
  signal RxDisparityErr : std_logic_vector(127 downto 0);
  signal TestSig : std_logic_vector(7 downto 0);
  signal ChBdata : std_logic_vector(4 downto 0);
  signal DlyGTCnt : std_logic_vector(15 downto 0);
  signal gt_drpaddr : STD_LOGIC_VECTOR(8 DOWNTO 0);
  signal gt_drpdi :  STD_LOGIC_VECTOR(15 DOWNTO 0);
  signal gt_drpwe :  STD_LOGIC;
  signal gt_drpen :  STD_LOGIC;
  signal ClkSynGth : std_logic;
-- buffers between QSFP and PCIe
  signal FifoAvP : std_logic_vector(11 downto 0);
  signal FifoAvTI   : std_logic_vector(11 downto 0);
  signal FifoAvSTDC : std_logic_vector(11 downto 0);
  signal FifoAvGBE  : std_logic_vector(11 downto 0);
  signal ClkUsrQ : std_logic;
  signal FIFOstatus : std_logic_vector(7 downto 0);
  signal PCIEWrite : std_logic;
-- PCIE packet word counts
  signal PcieWC : std_logic_vector(31 downto 0);
  signal LastWord : std_logic;
  signal DmaSize : std_logic_vector(15 downto 0);
  signal DmaNumber : std_logic_vector(31 downto 0);
  signal PciRxNumber : std_logic_vector(31 downto 0);
  signal PciRxNumEn  : std_logic;
  signal PcieRWC : std_logic_vector(31 downto 0);
  signal D2PSTDC : std_logic_vector(269 downto 0);
  signal D2PGBE  : std_logic_vector(269 downto 0);
  signal D2PValidSTDC : std_logic;
  signal D2PValidGBE  : std_logic;
  signal PcieSize : std_logic_vector(31 downto 0);

  signal CLKOUT4 : std_logic;
  signal ProbeI2C : std_logic_vector(1 downto 0);

-- in core common signals, (output from X0Y17, input to X0Y16)
  signal coreclk :  STD_LOGIC;
  signal txusrclk :  STD_LOGIC;
  signal txusrclk2 :  STD_LOGIC;
  signal areset_coreclk :  STD_LOGIC;
  signal gttxreset :  STD_LOGIC;
  signal gtrxreset :  STD_LOGIC;
  signal txuserrdy :  STD_LOGIC;
  signal reset_counter_done : STD_LOGIC;
  signal qpll0lock :  STD_LOGIC;
  signal qpll0outclk : STD_LOGIC;
  signal qpll0outrefclk : STD_LOGIC;

-- 10 GBE received data
  signal Data16Out : std_logic_vector(31 downto 0);
  signal Data16OE : std_logic;
  signal Clk16Out : std_logic;
  signal Data17Out : std_logic_vector(31 downto 0);
  signal Data17OE : std_logic;
  signal Clk17Out : std_logic;
  signal Data18Out : std_logic_vector(31 downto 0);
  signal Data18OE : std_logic;
  signal Clk18Out : std_logic;
  signal TenG16MAC : std_logic_vector(95 downto 0);
  signal TenG17MAC : std_logic_vector(95 downto 0);
  signal TenG18MAC : std_logic_vector(95 downto 0);
  signal TenG19MAC : std_logic_vector(95 downto 0);
-- xdma register received data
  signal XDMAtoQSFPD : std_logic_vector(31 downto 0);
  signal XDMAtoQSFPC : std_logic;
  signal XDMAtoQSFPE : std_logic;
  signal TimeStamp : std_logic_vector(7 downto 0);
  signal ToQSFPrden : std_logic; -- fifo readen for data to QSFP_x0y3
  signal MACTableWen  : std_logic;
  signal MACTableSel  : std_logic_vector(4 downto 1);
  signal MACTableData : std_logic_vector(31 downto 0);
  signal ClkMonOut : std_logic_vector(4 downto 1);
  signal TCPIPReg : std_logic_vector(255 downto 0);

-- clocks used on the board
--  signal Clk625 : std_logic;
--  signal Clk250 : std_logic;
  signal Clk3125 : std_logic;
  signal ClkSlow : std_logic;    -- also derived from EMC_CLK, 1.5625 MHz

-- signals for overall board
  signal MasterMode : std_logic_vector(3 downto 1);
  signal VmeReset : std_logic_vector(31 downto 0);
-- signals for Trigger MGT interface
  signal WriteStart : STD_LOGIC;
  signal ReadStart  : STD_LOGIC;
  signal SubWStart  : STD_LOGIC;
  signal SubRStart  : STD_LOGIC;
  signal STATUS     : STD_LOGIC_VECTOR (15 downto 0);
  signal TsData     : STD_LOGIC_VECTOR (15 downto 0);
  signal TrgSendEn  : STD_LOGIC;
  signal TrgData    : STD_LOGIC_VECTOR (15 downto 0);
  signal SubTrgData : STD_LOGIC_VECTOR (15 downto 0);
  signal TsLpData   : STD_LOGIC_VECTOR (15 downto 0);
  signal StatusA    : STD_LOGIC_VECTOR (15 downto 0);
  signal StatusE    : STD_LOGIC_VECTOR (15 downto 0);
  signal GTStatus   : STD_LOGIC_VECTOR (95 downto 0);
  signal RxAErr     : STD_LOGIC_vector(4 downto 1);
  signal Trig1      : std_logic;
  signal Trig2      : std_logic;
  signal TIselfBusy : std_logic;
  signal TSrev2Sync : std_logic;
  signal GTPStAB    : std_logic_vector(63 downto 0);

-- signal for USB3, high speed interface (basicall two TenGBE
  signal DataToUSB : STD_LOGIC_VECTOR (255 downto 0);
  signal DataToUSBEn : STD_LOGIC;
  signal DataFrmUSB  : STD_LOGIC_VECTOR (269 downto 0);
  signal DataFrmUSBVal : STD_LOGIC;
  signal USB3Error   : STD_LOGIC;
  signal USB3Status  : std_logic_vector(95 downto 0);

-- fake signals
  signal STDCCh : std_logic_vector(32 downto 1);
  signal FakeCh : std_logic;
  signal TI1FM : std_logic;
  signal TI1SYNC : std_logic;
  signal TI2FM : std_logic;
  signal TI2SYNC : std_logic;

-- signals for TI controls
  signal TrgSrcEn  :  STD_LOGIC_VECTOR (15 downto 0);
  signal TrgSrcSet : std_logic;
  signal SyncSrcEn :  STD_LOGIC_VECTOR (15 downto 0);
  signal BusySrcEn :  STD_LOGIC_VECTOR (15 downto 0);
  signal ClkSrcSet : std_logic;
  signal ClockSrc  :  STD_LOGIC_VECTOR (31 downto 0);
  signal ClockSrcMon  :  STD_LOGIC_VECTOR (31 downto 0);
  signal TrigPreScale :  STD_LOGIC_VECTOR (15 downto 0);
  signal BlockTh    :  STD_LOGIC_VECTOR (7 downto 0);
  signal TrigRule   :  STD_LOGIC_VECTOR (31 downto 0);
  signal TrigWindow :  STD_LOGIC_VECTOR (31 downto 0);
  signal GtpTrgEn  :  STD_LOGIC_VECTOR (31 downto 0);
  signal ExtTrgEn  :  STD_LOGIC_VECTOR (31 downto 0);
  signal FPTrgEn   :  STD_LOGIC_VECTOR (31 downto 0);
  signal FPOutput  :  STD_LOGIC_VECTOR (15 downto 0);
  signal SyncDelay :  STD_LOGIC_VECTOR (31 downto 0);
  signal GtpPreScaleA :  STD_LOGIC_VECTOR (31 downto 0);
  signal GtpPreScaleB :  STD_LOGIC_VECTOR (31 downto 0);
  signal GtpPreScaleC :  STD_LOGIC_VECTOR (31 downto 0);
  signal GtpPreScaleD :  STD_LOGIC_VECTOR (31 downto 0);
  signal ExtPreScaleA :  STD_LOGIC_VECTOR (31 downto 0);
  signal ExtPreScaleB :  STD_LOGIC_VECTOR (31 downto 0);
  signal ExtPreScaleC :  STD_LOGIC_VECTOR (31 downto 0);
  signal ExtPreScaleD :  STD_LOGIC_VECTOR (31 downto 0);
  signal LTTableLoad  : std_logic;
  signal VmeEvtType   :  STD_LOGIC_VECTOR (31 downto 0);
  signal SyncGenDelay :  STD_LOGIC_VECTOR (7 downto 0);
  signal SyncWidth    :  STD_LOGIC_VECTOR (7 downto 0);
  signal TrigCommandEn :  STD_LOGIC;
  signal TrigCommand   :  STD_LOGIC_VECTOR (15 downto 0);
  signal RandomTrgEn :  STD_LOGIC;
  signal RandomTrg   :  STD_LOGIC_VECTOR (15 downto 0);
  signal SoftTrg1En  :  STD_LOGIC;
  signal SoftTrg1    :  STD_LOGIC_VECTOR (31 downto 0);
  signal SoftTrg2En  :  STD_LOGIC;
  signal SoftTrg2    :  STD_LOGIC_VECTOR (31 downto 0);
  signal SyncCodeEn  :  STD_LOGIC;
  signal SyncCode    :  STD_LOGIC_VECTOR (7 downto 0);
  signal SyncCodedA  : std_logic;
  signal SyncCodedB  : std_logic;
  signal SyncEvtGen  :  STD_LOGIC_VECTOR (31 downto 0);
  signal PromptTrgW  : std_logic_vector (7 downto 0);
  signal ROCEn       : std_logic_vector (31 downto 0);
  signal EndOfRunBlk :  STD_LOGIC_VECTOR (31 downto 0);
  signal TrgTblData  : std_logic_vector(31 downto 0);
  signal TrgTblAdr   : std_logic_vector(3 downto 0);
  signal TrgTblWEN   : std_logic;
  signal RunCode     : std_logic_vector(31 downto 0);
  signal TandemEn    : std_logic;  -- in tandem mode, enable the STDC channel input

-- other signals for TI
  signal TSInhibit  : std_logic;
  signal TsRdStart  : std_logic;
  signal TsWrStart  : std_logic;
  signal IODlyRst : std_logic;
  signal MonRst   : std_logic;
  signal SRespTI : std_logic_vector(8 downto 0);
  signal TrgSyncBusy : std_logic_vector(31 downto 0);
  signal TrgSyncOutEn : std_logic;
  signal DlyReady : std_logic;
  signal AlignRead : std_logic_vector(31 downto 0);
  signal SReset : std_logic_vector(15 downto 0);
  signal SyncReset : std_logic;
  signal ResetInt  : std_logic; -- reset for the TI logic;
  signal ResetTRG  : std_logic; -- reset for the TI_MGT logic;
  signal ResetAdd1  : std_logic; -- reset for the Extra logic;
  signal ResetAdd2  : std_logic; -- reset for the Extra logic;
  signal FPTrgIn   : std_logic;
  signal NewMaster : std_logic;
  signal CountRst  : std_logic;
  signal PromTrg   : std_logic;
  signal PulseTrig : std_logic;
  signal ExtendedTrg : std_logic;
  signal BlkEnd : std_logic;
  signal TSBusy : std_logic;
  signal TrgStbR  : std_logic;
  signal TsVmeEn : std_logic;
  signal VmeSetting : std_logic_vector(31 downto 0);
  signal MinRuleWidth : std_logic_vector(31 downto 0);
  signal ScalarEnableSet : std_logic_vector(2 downto 1);
  signal TsVmeCmd : std_logic_vector(11 downto 0);
  signal GrsTrgNum: std_logic_vector(31 downto 0);
  signal TrgBusy : std_logic;
  signal PreTable : std_logic_vector(32 downto 1);
  signal SyncBlkEnd : std_logic;
  signal TempBusy   : std_logic;
  signal TestTsGen  : std_logic_vector(8 downto 1);
  signal PreTableEn : std_logic;
  signal GTPRxEn    : std_logic_vector(8 downto 0);
  signal GTPlpEn    : std_logic;
  signal NewPulseTrig : std_logic;
  signal ReadAen : std_logic;
  signal ReadBen : std_logic;
  signal NewSyncBlkEnd : std_logic;
  signal StatusOut : std_logic_vector(15 downto 0);
  signal FiberConn : std_logic_vector(31 downto 0);
  signal ReadAout : std_logic_vector(35 downto 0);
  signal ReadBout : std_logic_vector(35 downto 0);
  signal ExtraAck : std_logic;
  signal MonBusy : std_logic_vector(4 downto 1);
  signal TrgEnDis : std_logic;
  signal FCTrgSrcSet : std_logic;
  signal SyncSRstReq : std_logic;
  signal SyncSendID : std_logic;
  signal UpdateBS  : std_logic;
  signal UpdateBuf : std_logic;
  signal CrateID   : std_logic_vector(7 downto 0);
  signal TestPtSG  : std_logic_vector(4 downto 1);
  signal RawTrgIn  : std_logic_vector(95 downto 0);
  signal AddTrgType : std_logic_vector(16 downto 0);
  signal DataFormat : std_logic_vector(7 downto 0);
  signal FnFull   : std_logic_vector(8 downto 1);
  signal EvtType  : std_logic_vector(7 downto 0);
  signal DaqData  : std_logic_vector(71 downto 0);
  signal DSyncEvt : std_logic;
  signal ReadoutTrg : std_logic;
  signal RegTrgTime : std_logic;
  signal SyncEvt    : std_logic;
  signal TrgInhibit : std_logic;
  signal TsStrobe   : std_logic;
  signal DaqDEn     : std_logic;
  signal DataBusy   : std_logic;
  signal DGFull     : std_logic_vector(2 downto 1);
  signal IRQCount : std_logic_vector(7 downto 0);
  signal EvtInf : std_logic_vector(31 downto 0);
  signal TestDataG : std_logic_vector(8 downto 1);
  signal TestClk : std_logic_vector(8 downto 1);
  signal Dly4L1A    : std_logic;
  signal FnextFull  : std_logic;
  signal TIfifoFull : std_logic;
  signal TrgLost : std_logic;
  signal TSack   : std_logic;
  signal TrgLenDly : std_logic_vector(31 downto 0);
--  signal  : std_logic;
--  signal  : std_logic_vector( downto 0);
  signal Running : std_logic;
  signal Clk50V   : std_logic;
  signal ForceOsc : std_logic;
  signal ForcedClk : std_logic;
  signal MonRestart : std_logic;
  signal RstGTP : std_logic;
  signal BusyIRQ  : std_logic;
  signal UnsymSig : std_logic;
  signal UnSymP1 : std_logic;
  signal UnSymP2 : std_logic;
-- LED displays
  signal RxAErrIn : std_logic;
  signal ExtReset    : std_logic;
  signal ReadTrgExtd : std_logic;
  signal DtackExtd   : std_logic;
  signal LEDCounter  : std_logic_vector(23 downto 0);
  signal DTackEn     : std_logic;
  signal ThisTIMBusy : std_logic;
  signal ExtedOut2 : std_logic;
  signal RegReadoutTrg : std_logic;
  signal TestPt : std_logic_vector(12 downto 1);
  signal RunGo : std_logic;
  signal DisableTrg : std_logic;
  signal DisTrgCnt : std_logic_vector(7 downto 0);
  signal TestPtSpeed : std_logic_vector(4 downto 1);
  signal ExtendedBlk : std_logic;
  signal PreNewSyncBlk : std_logic;
  signal DlyTrgSrcSet : std_logic;
  signal DlyFCTrgSrcSet : std_logic;
  signal SendID    : std_logic;
  signal SRstReq   : std_logic;
  signal ForceTrgSrcSet : std_logic;
  signal GENOUTX : std_logic_vector(16 downto 1);

-- signals for TI data readout through PCIexpress
  signal WordBufRen : std_logic;
  signal SingleWordREN : std_logic;
  signal DataValid : std_logic;
  signal FnEmpty : std_logic;
  signal BlkBufRen : std_logic;
  signal DataReadEn : std_logic;
  signal TrnTdstRdyN : std_logic;
  signal BlkBufFull : std_logic;
  signal BlockReady : std_logic;
  signal Data2PCI : std_logic_vector(71 downto 0);
  signal DReadStatus : std_logic_vector(31 downto 0);
  signal DWAvailable : std_logic_vector(15 downto 0);

-- signals for Streaming TDC data
  signal ClkTdc10   : std_logic;
  signal ClkTdc10In : std_logic;
  signal TDCData : std_logic_vector(255 downto 0);
-- Fifo read_enables for TI_fifo and STDC_fifo
  signal TIfifoReadEn : std_logic;
  signal DlyTIreadEn : std_logic;
  signal Dly2TIreadEn : std_logic;
  signal STDCfifoReadEn : std_logic;
  signal DlySTDCreadEn : std_logic;
  signal Dly2STDCreadEn : std_logic;
  signal TIfifoVal : std_logic;
  signal STDCfifoVal : std_logic;
  signal LastSTDCWord : std_logic;
-- SEU counter
  signal ResetClk250 : std_logic;
  signal TMRCountA  : std_logic_vector(63 downto 0);
  signal TMRCountB  : std_logic_vector(63 downto 0);
  signal ErrorCount : std_logic_vector(31 downto 0);
  signal ErrorFound : std_logic := '0';
  signal TestTCS    : std_logic_vector(8 downto 1);
  signal GENIN      : std_logic_vector(6 downto 1);

-- newly added for the re-structruing
  signal USB2A     : std_logic;
  signal USB2B     : std_logic;
  signal TestOut   : std_logic_vector(31 downto 0);
  signal Pre_m_axil_rvalid  : STD_LOGIC;                   -- master read valid
  signal m_axil_rvalid_int : std_logic;
  signal m_axil_bvalid_int : std_logic;
-- serial interfaces
  signal m_axil_arvDLY : std_logic;
  signal WriteStrobe : std_logic;
  signal ReadStrobe  : std_logic;
  signal DlyReadStrobe   : std_logic;
  signal Dly2ReadStrobe  : std_logic;


--  ****** might be overkill by coping all the signals from xdma wrapper
    signal  ComplReset_n    : std_logic;
  signal  RqstReset_n     : std_logic;
  signal  IntptReset_n    : std_logic;
  signal  user_reset      : std_logic;
  signal  user_resetn     : std_logic;
  signal  pcie_tfc_nph_av : STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal  pcie_tfc_npd_av : STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal  PcieInterrupt_Ackd :  STD_LOGIC_vector(3 downto 0);
  signal  pcie_perstn1_in :  STD_LOGIC;
  signal  pcie_perstn0_out :  STD_LOGIC;
  signal  pcie_perstn1_out :  STD_LOGIC;
  signal  int_qpll1lock_out :  STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal  int_qpll1outrefclk_out :  STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal  int_qpll1outclk_out :  STD_LOGIC_VECTOR(1 DOWNTO 0);
-- signals between the PCIE completer and Requester
  signal  DMASetting : std_logic_vector(31 downto 0);
  signal  DMAAddress : std_logic_vector(31 downto 0);

-- signals for registers
  signal PciRegWEn  : std_logic; -- pci register write enable;
  signal WriteEn    : std_logic;
  signal RegData      : std_logic_vector(31 downto 0);
  signal PciRegREn    : std_logic;
  signal DlyPciRegREn  : std_logic;
  signal Dly2PciRegREn : std_logic;
  signal Dly3PciRegREn : std_logic;
  signal DlyPciRegRAdd   : std_logic_vector(12 downto 0);
  signal RegReadValid : std_logic;

  signal FiberEn     : STD_LOGIC_VECTOR (7 downto 0);
  signal VmeAddress  : STD_LOGIC_VECTOR (31 downto 0);
  signal BlockSize   : STD_LOGIC_VECTOR (7 downto 0);

  --         EnableCntl :  STD_LOGIC_VECTOR (15 downto 0);
  signal Reg10cD : std_logic_vector(31 downto 0);
  signal Reg110D : std_logic_vector(31 downto 0);
  signal Reg114D : std_logic_vector(31 downto 0);
  signal Reg118D : std_logic_vector(31 downto 0);
  signal Reg11cD : std_logic_vector(31 downto 0);
  signal Reg120D : std_logic_vector(31 downto 0);
  signal Reg124D : std_logic_vector(31 downto 0);
  signal Reg128D : std_logic_vector(31 downto 0);
  signal Reg12cD : std_logic_vector(31 downto 0);
  signal Reg130D : std_logic_vector(31 downto 0);
  signal Interrupt  : std_logic_vector(31 downto 0);
  signal ComplRst_n : std_logic;
  signal C2HLast    : std_logic_vector(2 downto 0);
  signal VetoLast   : std_logic_vector(2 downto 0);
  signal PcieReady  : std_logic_vector(2 downto 0);
  signal C2HReadEn  : std_logic_vector(2 downto 0);
  signal DlyC2HReadEn  : std_logic_vector(2 downto 0);
  signal C2HPFull   : std_logic_vector(2 downto 0);
  signal C2HPEmpty  : std_logic_vector(2 downto 0);
  signal C2HDataVal : std_logic_vector(2 downto 0);
  type   MatrixData   is array (integer range 0 to 2) of std_logic_vector(288 downto 0);
  type   MatrixCount  is array (integer range 0 to 2) of std_logic_vector(7 downto 0);
  signal C2HData   : MatrixData;  -- 0: TI data; 1: STDC data; 2: 10GBE data
  signal C2HBlkCnt : MatrixCount;
  signal BlockRcvd : std_logic_vector(2 downto 0);  -- synced with ClkPci
  signal BlockIn   : std_logic_vector(2 downto 0);  -- Synced with ClkIn
  signal PreBlock  : std_logic_vector(2 downto 0);  -- Synced with ClkIn, but cleared by BlockRcvd
  signal PreBlockSent : std_logic_vector(2 downto 0);  -- synced with ClkPci
  signal BlockSent    : std_logic_vector(2 downto 0);  -- synced with ClkPci
  signal OKtoRead     : std_logic_vector(2 downto 0);
  signal C2HBlkReady  : std_logic_vector(2 downto 0);
  signal XdmaStatus : std_logic_vector(31 downto 0);
  signal M_axil_Ready : std_logic_vector(3 downto 0) := "Z111"; -- (0): WAdd_Ready, (1): WData_Ready, (2): RAdd_Ready, (3): RData_Ready(output)
  signal DlysBusy     : std_logic_vector(3 downto 0) := "0000"; -- delays of the I2CBusy and JTAGBusy
  signal DlysReadEn   : std_logic_vector(3 downto 0) := "0000"; -- delays of the I2CDeviceR and JTAGDeviceR
  signal  gen_interrupt : std_logic_vector(2 downto 0); -- Legacy, MSI, MSIx
  signal  interrupt_done : std_logic; -- Indicates whether interrupt is done or in process
-- MSI Interrupt Interface
  signal  PcieInterrupt_msi_enable : std_logic;
-- registered port for RegisterSet
  signal RegSetAdd  : std_logic_vector(12 downto 0);
  signal RegReadAdd : std_logic_vector(12 downto 0);
  signal RegSetData : std_logic_vector(31 downto 0);
  signal PciRegBar  : std_logic_vector(2 downto 0);
  signal RegisterW  : std_logic;
  signal RegisterR  : std_logic;
  signal RegWEn     : std_logic;

  signal McapSwitch  : std_logic;
  signal ClkMonitor  : std_logic_vector(7 downto 0);
-- use virtual IO to control the registers
  signal VInPcie  : std_logic_vector(63 downto 0);
  signal VOutPcie : std_logic_vector(95 downto 0);
  signal EdgeDelay : std_logic_vector(31 downto 0);
-- ** might be overkill
-- extra buffer related signals
  signal UltraTvalid  : std_logic;
  signal UltraNotFull : std_logic;
  signal UltraTdata : std_logic_vector(71 downto 0);
  signal UltraTready : std_logic;
  signal UltraTlast  : std_logic;
  signal UltraMTlast : std_logic;
  signal UltraAempty : std_logic;
  signal UltraAfull  : std_logic;
  signal FifoResetS   : std_logic;
  signal FifoResetU  : std_logic;
  signal FifoResetN  : std_logic;
  signal working : std_logic;
  signal TItimeMon : std_logic_vector(15 downto 0);
  signal MonTest   : std_logic_vector(31 downto 0);

  -- signals added with the TIpcieUS --> TInode modification
  signal ClkFB3125in : std_logic;
  signal ClkRCVD  : std_logic;
  signal CLkREF   : std_logic;
  signal MReturn  : std_logic;
  signal TIMaster : std_logic;
  signal DSMOut   : std_logic;
  signal LEDG    : std_logic_vector(11 downto 0);
  signal LEDQ    : std_logic_vector(5 downto 0);
  signal XLEDG   : std_logic_vector(5 downto 0);
  signal FIBERICK : std_logic;
  signal FIBERIDA : std_logic;
  signal FIBERIDB : std_logic;
  signal ClkLocked  : std_logic_vector(3 downto 0);
  signal TC80ns     : std_logic_vector(5 downto 0);
  signal INTs_axis_c2h_tdata  : STD_LOGIC_VECTOR(255 DOWNTO 0); -- transmit data from the user logic to the DMA
  signal INTs_axis_c2h_tkeep  : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal INTm_axis_h2c_tdata  : STD_LOGIC_VECTOR(255 DOWNTO 0);  -- Transmit data from the DMA to the user logic
  signal INTm_axis_h2c_tkeep  : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Bytes to keep, should be all 1s except the last word, where the 1s are LSB aligned
  signal NewBlockTh    : std_logic_vector(7 downto 0);
  signal TIbusyLatch   : std_logic;
  signal CountRstBusy  : std_logic;
-- signals for SingleWord Register readout
  signal SW2PCI  : std_logic_vector(35 downto 0);
  signal SWStatus : std_logic_vector(31 downto 0);
  signal SWFifoFull : std_logic;
  signal Dly1RValid : std_logic;
  signal Dly2RValid : std_logic;
  signal ClkFreq  : std_logic_vector(31 downto 0);
  signal BoardID  : std_logic_vector(7 downto 0);
  signal Clk625Mon : std_logic := '0';

begin

  ClockInputCheck : ClockCheck
    port map( ClkPrg => ClkPrg, -- in STD_LOGIC;
           Clk250 => Clk250,    -- in STD_LOGIC;
           Clk625 => Clk625,    -- in STD_LOGIC;
           ClkChkd  => TrgBufE(31 downto 29) ); -- out STD_LOGIC_VECTOR (2 downto 0));

  TrgBufE(28) <= (RxAErr(1) and (BusySrcEn(8) or TrgSrcEn(1)))
              or (RxAErr(3) and (BusySrcEn(12) or TrgSrcEn(10)));
  TrgBufE(27) <= Running;
  TrgBufE(26) <= DlyReady;

  ClkLocked(0) <= TrgBufE(31) and TrgBufE(29);
  process (ClkReg)
  begin
    if (ClkReg'event and ClkReg = '1') then
      MonRst <= ClkSrcSet;
      ClkLocked(1) <= ClkLocked(0);
      ClkLocked(2) <= ClkLocked(1);
      if (TC80ns(5) = '1') then
        IODLyRst <= '0';
        TC80ns <= (others => '0');
      elsif ( (ClkLocked(1) = '1' and ClkLocked(2) = '0') or (VmeReset(14) = '1') ) then
        IODLyRst <= '1';
      elsif (IODlyRst = '1') then
        TC80ns <= TC80ns + 1;
      end if;
    end if;
  end process;

        Reset <= SyncReset;
        ResetInt <= SyncReset;
        ResetTRG <= SyncReset;
        ResetAdd1 <= SyncReset;
        ResetAdd2 <= SyncReset;
  user_reset <= not user_resetn;
  working <= not SyncReset;

  CLkFreqMeas : ClockFreqMeas
    Port map( Clock => ClkReg, -- in STD_LOGIC;
           ClkA => Clk250,      -- in STD_LOGIC;
           ClkB => Clk625,      -- in STD_LOGIC;
           ClkR => ClkReg,        --  in STD_LOGIC;
           ClkFreq => ClkFreq );  -- out STD_LOGIC_VECTOR (31 downto 0));

-- ClkRef differential receiver
  RefClkReceiver : IBUFDS_GTE4
    generic map (REFCLK_EN_TX_PATH => '0', -- Refer to Transceiver User Guide
      REFCLK_HROW_CK_SEL => "10",          -- ODIV2 selection (00: ODIV2 = O; 01: ODIV2 = O/2; 10: ODIV2 = LOW; 11: reserved)
      REFCLK_ICNTL_RX    => "00" )         -- Refer to Transceiver User Guide
    port map (O => CLKREF,      -- 1-bit output: Refer to Transceiver User Guide
      ODIV2     => open,        -- 1-bit output: Refer to Transceiver User Guide
      CEB       => '0',         -- 1-bit input: Low_true enable
      I         => TICLK_P,    -- 1-bit input: Refer to Transceiver User Guide
      IB        => TICLK_N );  -- 1-bit input: Refer to Transceiver User Guide
  RecoveredClk : OBUFDS_GTE4
    generic map (REFCLK_EN_TX_PATH => '1',   -- Refer to Transceiver User Guide
      REFCLK_ICNTL_TX => "00111" )           -- AR#67919
    port map (O => ClkRefO_P,   -- 1-bit output: Refer to Transceiver User Guide
            OB  => ClkRefO_N,   -- 1-bit output: Refer to Transceiver User Guide
            CEB => '0',         -- 1-bit input: Refer to Transceiver User Guide
            I   => CLKRCVD );   -- 1-bit input: Refer to Transceiver User Guide

  RstGtp <= '0'; -- specifically assign it to '0'

  TI1andLPBK_MGT : TrgMGT1L
    Port map(ClkRef  => CLKREF,   -- in STD_LOGIC;
      ClkRcvd     => ClkRcvd,   -- out std_logic;
      ClkFree     => ClkPrg, -- in std_logic;
      MasterMode  => MasterMode(3 downto 1), -- in STD_LOGIC_VECTOR (3 downto 1);
      WriteStart  => WriteStart, -- in STD_LOGIC;
      ReadStart   => ReadStart,  -- in STD_LOGIC;
      StatusEn    => GTPlpEn, -- StatusEn, -- in std_logic;
      RxGT_P   => TI1RX_P, -- in STD_LOGIC_VECTOR (1 downto 0);
      RxGT_N   => TI1RX_N, -- in STD_LOGIC_VECTOR (1 downto 0);
      TxGT_P   => TI1TX_P, -- out STD_LOGIC_VECTOR (1 downto 0);
      TxGT_N   => TI1TX_N, -- out STD_LOGIC_VECTOR (1 downto 0);
      Status      => StatusOut(15 downto 0), -- in STD_LOGIC_VECTOR (15 downto 0); come from StatusGen block
      TsData      => TsData(15 downto 0),    -- in STD_LOGIC_VECTOR (15 downto 0);
      Reset       => Reset,     -- in STD_LOGIC;
      TrgSendEn   => TrgSendEn, -- in STD_LOGIC;
      Clk250      => Clk250,    -- in STD_LOGIC;
      Clk625      => Clk625,    -- in STD_LOGIC;
      RstGtp      => RstGtp,   --  in std_logic;
      VRstGtp     => open, --VRstGtp,  -- inout, syned reset of RstGtp, to reset other MGTs
      SyncedRst   => open, --SyncedVmeRst, -- out std_logic;
      VmeReset    => VmeReset,  -- in std_logic_vector(31 downto 0);
      FiberRdy    => FiberConn(17), -- FiberRdy(1), -- in std_logic_vector(8 downto 1);
      TsWrStart   => TsWrStart, --  in std_logic;
      TsRdStart   => TsRdStart, -- in std_logic;
      TrgBufE     => TrgBufE(9 downto 0),  -- out std_logic_vector(25 downto 0);
      GTPStA      => GTPStAB(31 downto 0),  -- out std_logic_vector(31 downto 0);
      TrgAProm    => TrgStbR, --open, --TrgAProm,               -- out STD_LOGIC;
      TrgData     => TrgData(15 downto 0),    -- out STD_LOGIC_VECTOR (15 downto 0);
      StatusA     => StatusA(15 downto 0),    -- out STD_LOGIC_VECTOR (15 downto 0);
      TsLpData    => TsLpData(15 downto 0),   -- out STD_LOGIC_VECTOR (15 downto 0);
      GT5Data     => open, -- GT5Data(15 downto 0),
      GT5K        => open, --GT5K(1 downto 0),
      RxAErr      => RxAErr(1),                  -- out STD_LOGIC;
      RxEn        => GTPRxEn(1 downto 0),     -- out std_logic_vector(8 downto 0);
      GTStatus    => GTStatus(95 downto 0) ); -- out STD_LOGIC_VECTOR (95 downto 0)

-- --  Input to the FPGA
--   Fiber1Input : IBUFDS
--     port map (O => MReturn, -- 1-bit output: Buffer output
--       I  => TI1FMRX_P,    -- 1-bit input: Diff_p buffer input (connect directly to top-level port)
--       IB => TI1FMRX_N );  -- 1-bit input: Diff_n buffer input (connect directly to top-level port)
--  -- Output from the FPGA
--   Fiber1Output : OBUFDS
--     port map (O => TI1FMTX_P, -- 1-bit output: Diff_p output (connect directly to top-level port)
--       OB => TI1FMTX_N,        -- 1-bit output: Diff_n output (connect directly to top-level port)
--       I  => DSMOut );          -- 1-bit input: Buffer input
--   TIMaster <= (not MasterMode(3)) and (MasterMode(1) xnor MasterMode(2));
--   Fiber1Measure : FiberLength
--     Port map(Clock => Clk250,  -- in STD_LOGIC;
--       MReturn    => MReturn,  -- in STD_LOGIC;
--       MasterMode => TIMaster, -- in STD_LOGIC;
--       VmeRst     => VmeReset(15 downto 0),   -- in STD_LOGIC_VECTOR (15 downto 0);
--       DSMout     => DSMOut,   --  out STD_LOGIC;
--       ReadData   => FiberDlyMeas(31 downto 0), -- out STD_LOGIC_VECTOR (31 downto 0);
--       TestPt     => TestPt(8 downto 1) );  -- out STD_LOGIC_VECTOR (4 downto 1));


  SYNCmodNode : TCSsyncNode
    port map(ClkVme => ClkReg, -- ClkPci,     -- in std_logic; Clock synced with the sync_code setting
      BusySrcEn    => BusySrcEn(15 downto 0), -- in std_logic_vector (15 downto 0);
      ClkLockEn    => TrgBufE(31), -- in  std_logic;
      Clock        => Clk250,      -- in  std_logic;
      ClkSlow      => Clk625,      -- in  std_logic;
      FPSync       => GENINP(1), -- FPBusySync,  -- in  std_logic;
      IODlyRst     => IODlyRst,
      MasterMode   => Mastermode,   -- in  std_logic_vector (3 downto 1);
      SCReadEn     => Sync98ReadEn, -- in  std_logic;
      SetClkSrc    => MonRst,       -- in  std_logic;
      SReqSet      => SReqSet,      -- in  std_logic;
      SRespTI      => SRespTI(8 downto 0),  -- in  std_logic_vector (8 downto 0);
      SyncCodeEn   => SyncCodeEn,           -- in  std_logic;
      SyncCodeIn   => SyncCode(7 downto 0), -- in  std_logic_vector (7 downto 0);
      SyncDelay    => SyncDelay,    -- in  std_logic_vector (31 downto 0);
      SyncGenDly   => SyncGenDelay, -- in  std_logic_vector (7 downto 0);
      SyncIn_N     => TI1SYNCRX_N,  -- in  std_logic;
      SyncIn_P     => TI1SYNCRX_P,  -- in  std_logic;
      SyncSrcEn(1 downto 0)  => SyncSRcEn(1 downto 0), -- in  std_logic_vector (7 downto 0);
      SyncSrcEn(2)           => '0', -- in  std_logic_vector (7 downto 0);
      SyncSrcEn(7 downto 3)  => SyncSRcEn(7 downto 3), -- in  std_logic_vector (7 downto 0);
      TIBusy       => TrgSyncBusy(15 downto 7), -- in  std_logic_vector (8 downto 0);
      TrgSyncOutEn => TrgSyncOutEn,           -- in  std_logic;
      VmeRst       => VmeReset(15 downto 0),  -- in  std_logic_vector (15 downto 0);
      ResetWidth   => SyncWidth(7 downto 0),   -- in  std_logic_vector (7 downto 0);
      SyncRead     => AlignRead(31 downto 0), -- out std_logic_vector (31 downto 0);
      DlyReady     => DlyReady,            -- out std_logic;
      Reset        => SyncReset,           -- out std_logic;
      SResetOut    => SReset(15 downto 0), -- out std_logic_vector (15 downto 0);
      StatSync     => TrgSyncBusy(23 downto 16), -- out std_logic_vector (7 downto 0);
      SyncCode     => SyncData(39 downto 0), -- out std_logic_vector (39 downto 0);
      SyncCodedA   => SyncCodedA,  -- out std_logic;
      SyncCodedB   => open, --SyncCodedB,  -- out std_logic;
      SyncRst_N    => open, -- TestD27_N,   -- out std_logic;
      SyncRst_P    => open, --TestD27_P,   -- out std_logic;
      TrgSendEn    => TrgSendEn,   -- out std_logic;
      TSInhibit    => TSInhibit,   -- out std_logic;
      TsRdStart    => TsRdStart,   -- out std_logic;
      TsWrStart    => TsWrStart,   -- out std_logic;
      TestPt       => TestTCS,
      ReadStart    => ReadStart,   -- out std_logic;
      WriteStart   => WriteStart); -- out std_logic);
  SyncCodedTI1 : OBUFDS
    port map (O  => TI1SYNCTX_P,   -- 1-bit output: Diff_p output (connect directly to top-level port)
      OB => TI1SYNCTX_N,   -- 1-bit output: Diff_n output (connect directly to top-level port)
      I  => SyncCodedA );  -- 1-bit input: Buffer input

  TsStrobe <= '0';  -- disable Rev2 TS strobe
  TriggerMux : TrigMux
    port map(ClkUsr => Clk625,   -- in  std_logic;
      Clk250       => Clk250,    -- in  std_logic;
      GtpRxEn(1 downto 0)  => GTPRxEn(1 downto 0), -- in  std_logic_vector (8 downto 0);
      GtpRxEn(8 downto 2)  => "0000000",  -- disable the Fiber2-8
      LBTrig       => TsLpData,   -- in  std_logic_vector (15 downto 0);
      Reset        => Reset,      -- in  std_logic;
      Rev2TS       => "00000000", -- in  std_logic_vector (7 downto 0);
      SoftSW       => MasterMode, -- in  std_logic_vector (3 downto 1);
      SubTrig      => SubTrgData, -- in  std_logic_vector (15 downto 0);
      TrigCode     => TrgData,    -- in  std_logic_vector (15 downto 0);
      TrgLenDly    => TrgLenDly(31 downto 0), -- in  std_logic_vector (31 downto 0);
      TrgSrcEn     => TrgSrcEn(15 downto 0),  -- in  std_logic_vector (15 downto 0);
      TrgSrcSet    => TrgSrcSet,      -- in  std_logic;
      TrgSyncOutEn => TrgSyncOutEn,   -- in  std_logic;
      TSrev2TrgIn  => FPTrgIn,        -- in  std_logic;
      TsStrobe     => TsStrobe,       -- in  std_logic;
      VmeUpdtEn    => VmeSetting(21), -- in  std_logic;
      AddTrgType   => AddTrgType(16 downto 0), -- out std_logic_vector (16 downto 0);
      DSyncEvt     => DSyncEvt,            -- out std_logic;
      EvtTypeOut   => EvtType(7 downto 0), -- out std_logic_vector (7 downto 0);
      L1Trged      => ReadoutTrg,          -- out std_logic;
      NewBlkSize   => NewBlkSize(31 downto 0), -- out std_logic_vector (31 downto 0);
      RegTrgTime   => RegTrgTime,    -- out std_logic;
      SyncEvt      => SyncEvt,       -- out std_logic;
      TestPt       => open,          -- out std_logic_vector (4 downto 1);
      TrgStat      => TrgSyncbusy(31 downto 24), -- out std_logic_vector (7 downto 0);
      Trg1Ack      => Status(10),    -- out std_logic;
      Trg2Ack      => Status(9),     -- out std_logic;
      Trigger1     => Trig1,         -- out std_logic;
      Trigger2     => Trig2,         -- out std_logic;
      TSrev2Sync   => TSrev2Sync,    -- out std_logic;
      UpdateBS     => UpdateBS,      -- out std_logic;
      UpdateBuf    => UpdateBuf );   -- out std_logic);

-- signals for TSGen block
  NewMaster <= (not MasterMode(3)) and (MasterMode(1) xnor MasterMode(2));
  CountRst <= VmeReset(25) or SReset(11);
  ScalarEnableSet(2) <= VmeSetting(28);
  ScalarEnableSet(1) <= RunGo and (not VmeSetting(27));

  process(ClkReg)
  begin
    if (ClkReg'event and ClkReg = '1') then
      if (Reset = '1') then
        TsVmeCmd(11 downto 0) <= (others => '0');
        TsVmeEn <= '0';
      else
        TsVmeCmd(11 downto 0) <= TrigCommand(11 downto 0);
        TsVmeEn <= TrigCommandEn;
      end if;
    end if;
  end process;

  TStriggerGen: TSTrigGen
    port map( BlkEnd  => BlkEnd,   -- in    std_logic;
      BlockSize       => NewBlkSize(7 downto 0), -- in    std_logic_vector (7 downto 0);
      Busy            => TSBusy,   -- in    std_logic;
      ChannelDelay    => ChannelDelay(63 downto 0), -- in    std_logic_vector (63 downto 0);
      ClKSelTrgRule   => VmeSetting(31), -- in    std_logic;
--      ClkSlow         => Clkslow,  -- in    std_logic;
      ClkVme          => ClkReg, --ClkPci,   -- in    std_logic;
      Clk250          => Clk250,   -- in    std_logic;
      Clk625          => Clk625,   -- in    std_logic;
      EndOfRun        => VmeReset(31),             -- in std_logic;
      EndOfRunBlk     => EndOfRunBlk(31 downto 0), -- in std_logic_vector (31 downto 0);
      FiberTrged      => TrgStbR,      -- in    std_logic;
      ForceSyncEvt    => VmeReset(20), -- in    std_logic;
      FPTrgIn         => GENINP(2), --FPTrgIn,      -- in    std_logic;
      MasterMode      => NewMaster,    -- in    std_logic;
      MinRuleWidth    => MinRuleWidth(31 downto 0), -- in  std_logic_vector (31 downto 0);
      PeriodA         => TrigRule(31 downto 0),     -- in  std_logic_vector (31 downto 0);
      PSFactor        => TrigPreScale(15 downto 0),  -- in  std_logic_vector (15 downto 0);
      P2TrgIn         => '0',   --P2Busy, -- in    std_logic;
      Reset           => Reset, -- in    std_logic;
      RTrgRate        => RandomTrg(15 downto 0),       -- in  std_logic_vector (15 downto 0);
      ScalarEnableSet => ScalarEnableSet(2 downto 1), -- in  std_logic_vector (2 downto 1);
      ScalarLatch     => VmeReset(24), -- in    std_logic;
      ScalarReset     => CountRst,    -- in    std_logic;
      SReqSet         => SReqSet,     -- in    std_logic;
      SyncEvtGen      => SyncEvtGen(31 downto 0), -- in  std_logic_vector (31 downto 0);
      TrgSrcEn        => TrgSrcEn(15 downto 0),   -- in  std_logic_vector (15 downto 0);
      TrgTblAdr       => TrgTblAdr(3 downto 0),   -- in  std_logic_vector (3 downto 0);
      TrgTblData      => TrgTblData(31 downto 0), -- in  std_logic_vector (31 downto 0);
      TrgTblWE        => TrgTblWEN,               -- in  std_logic;
      TrgWidth        => PromptTrgW(7 downto 0),  -- in  std_logic_vector (7 downto 0);
      TSEn            => ExtTrgEn(5 downto 0),    -- in  std_logic_vector (6 downto 1);
      TsIn            => GENINP(8 downto 3), -- GENIN(6 downto 1),     -- in  std_logic_vector (6 downto 1);
      TsMatch         => TrigWindow(31 downto 0), -- in  std_logic_vector (31 downto 0);
      TsPreScale      => ExtPreScaleA(23 downto 0), -- in  std_logic_vector (24 downto 1);
      TsVmeCmd        => TsVmeCmd(11 downto 0),   -- in  std_logic_vector (11 downto 0);
      TsVmeEn         => TsVmeEn,                 -- in  std_logic;
      VmeEvtType      => VmeEvtType(31 downto 0), -- in  std_logic_vector (31 downto 0);
      VmeTrg1Load     => SoftTrg1En, --VmeTrg1Load, -- in    std_logic;
      VmeTrg1Set      => SoftTrg1(31 downto 0),   -- VmeTrg1Set(31 downto 0), -- in std_logic_vector (31 downto 0);
      VmeTrg2Load     => SoftTrg2En, -- VmeTrg2Load, -- in    std_logic;
      VmeTrg2Set      => SoftTrg2(31 downto 0),   -- VmeTrg2Set(31 downto 0), -- in std_logic_vector (31 downto 0);
      DisTrg          => TrgBusy,    -- out std_logic;
      EndOfRunBR      => EndOfRunBR, -- out std_logic;
      FillEvent       => FillEvent,  -- out std_logic;
      GrsTrged        => open,       -- out std_logic;
      GrsTrgNum       => GrsTrgNum(31 downto 0), -- out std_logic_vector (31 downto 0);
      PreTable        => PreTable(6 downto 1),   -- out std_logic_vector (6 downto 1);
      PromptTrg       => PromTrg,    -- out std_logic;
      SyncBlkEnd      => SyncBlkEnd, -- out std_logic;
      TDTrig          => open,       -- out std_logic;
      TempBusy        => TempBusy,   -- out std_logic;
      TestPt          => open, --TestTsGen(8 downto 1), -- out std_logic_vector (8 downto 1);
      TrigCode        => PreTableEn,  -- out std_logic;
      Triggered       => PulseTrig,   -- out std_logic;
      TsData          => TsData(15 downto 0),    -- out std_logic_vector (15 downto 0);
      Monitor         => MonTest, -- out   std_logic_vector(31 downto 0);
      TsScalar        => TsScalar(191 downto 0), -- out std_logic_vector (191 downto 0);
      TsValid         => TsValid(31 downto 0) ); -- out std_logic_vector (31 downto 0));

  FnFull(8 downto 3) <= (others => '0');

-- TrgInhibit generation logic;
  DisableTrg <= FnextFull or TIfifoFull;

  process (Clk625, DisableTrg)
    begin
      if (DisableTrg = '0') then
        DisTrgCnt  <= (others => '0');
        TrgInhibit <= '0';
      elsif (Clk625'event and Clk625 = '1') then
        DisTrgCnt <= DisTrgCnt + 1;
        if ((DisTrgCnt(6)='1') and (DisTrgCnt(7)='1')) then
          TrgInhibit <= '1';
        end if;
      end if;
  end process;
  ModDataGeneration : DataGeneration
    port map( AddTrgType => AddTrgType(16 downto 0),   -- in std_logic_vector (16 downto 0);
      BlockLevel  => NewBlkSize(7 downto 0),           -- in std_logic_vector (7 downto 0);
      BoardID     => "01010", -- TIDSaddr(4 downto 0), -- in std_logic_vector (4 downto 0);
      ClkRead     => ClkReg, -- ClkPci,   -- in    std_logic;
      ClkUsr      => Clk625,   -- in    std_logic;
      ClkVme      => ClkReg, -- ClkPci,   -- in    std_logic;
      Clk250      => Clk250,   -- in    std_logic;
      CountReset  => CountRst, -- in    std_logic;
      DataFormat  => DataFormat(7 downto 0), -- in  std_logic_vector (7 downto 0);
      DSyncEvt    => DSyncEvt,               -- in  std_logic;
      FnFull      => FnFull(8 downto 1),     -- in  std_logic_vector (8 downto 1);
      RawTrgIn    => RawTrgIn(95 downto 64), -- in  std_logic_vector (32 downto 1);
      ReadOutTrg  => ReadoutTrg,             -- in  std_logic;
      ReadoutType => EvtType(7 downto 0),    -- in  std_logic_vector (7 downto 0);
      RegTrgTime  => RegTrgTime,           -- in    std_logic;
      Reset       => Reset,                -- in    std_logic;
      ROCAckIn(1) => VmeReset(7),
      ROCAckIn(8 downto 2) => "0000000",   -- in    std_logic_vector (8 downto 1);
      ROCEn       => ROCEn(7 downto 0),    -- in    std_logic_vector (8 downto 1);
      SyncEvt     => SyncEvt,    -- in    std_logic;
      TrgInhibit  => TrgInhibit, -- in    std_logic;
      TsStrobe    => TsStrobe,   -- in    std_logic;
      VmeReset    => VmeReset(15 downto 0), -- in   std_logic_vector (15 downto 0);
      BlkEnd      => BlkEnd,                -- ou   std_logic;
      BlkRcvd     => Status(8),             -- out  std_logic;
      DaqData     => DaqData(71 downto 0),  -- out  std_logic_vector (71 downto 0);
      DaqDEn      => DaqDEn,               -- out   std_logic;
      DataBusy    => DataBusy,             -- out   std_logic;
      DGFull      => DGFull(2 downto 1),   -- out   std_logic_vector (2 downto 1);
      Dly4L1A     => Dly4L1A,              -- out   std_logic;
      FnextFull   => FnextFull,            -- out   std_logic;
      IRQCount    => IRQCount(7 downto 0), -- out   std_logic_vector (7 downto 0);
      Nblk        => BlockAv(23 downto 0), -- out   std_logic_vector (23 downto 0);
      NEvt        => BlockAv(31 downto 24),  -- out std_logic_vector (7 downto 0);
      RegNum      => RegL1ANum(47 downto 0), -- out std_logic_vector (47 downto 0);
      ROCack      => Status(7),             -- out  std_logic;
      ROCAckRd    => ROCAckRd(63 downto 0), -- out  std_logic_vector (63 downto 0);
      SyncEvtSet  => SyncEvtSet,            -- out  std_logic;
      TDCEvtReg   => TDCEvtReg(3 downto 0), -- out  std_logic_vector (3 downto 0);
      TestPt      => TestDataG(8 downto 1), -- out  std_logic_vector (4 downto 1);
      TIfifoFull  => TIfifoFull, -- out   std_logic;
      TItimeMon   => TItimeMon(15 downto 0), -- out 15:0
      TrgLost     => TrgLost,    -- out   std_logic;
      TSack       => TSack );    -- out   std_logic);
  BlockAv(39 downto 32) <= IRQCount(7 downto 0);

-- Data buffer and data readout; single word readout
  SingleWordREN <= '0';
  WordBufRen <= EvtReadEn; -- and D2RValid; -- or SingleWordREN;
  SingleWordReadBuf : WordBuffer
    port map(Clock => ClkReg, -- ClkPci,             -- in    std_logic;
      Data       => DaqData(71 downto 0), -- in    std_logic_vector (71 downto 0);
      FifoREn    => WordBufRen,           -- in    std_logic;
      Reset      => FifoResetS, --Reset,     -- in    std_logic;
      Write_En   => DaqDEn,    -- in    std_logic;
      FnEmpty    => FnEmpty,   -- out   std_logic;
      FnFull     => SWFifoFull, -- out   std_logic;
      Status     => SWStatus(31 downto 0), --
      MedOut     => SW2PCI(35 downto 0) ); -- out   std_logic_vector (35 downto 0));

  FnFull(1) <= (SWFifoFull and BlkBufFull) and (not VmeSetting(15));

  FifoResetS <= Reset or VmeReset(4);
-- to add the ExtraDataBuffer
  BlockMemoryBuf : BlockReadBuf
    port map( ClkRead => ClkReg, -- ClkPci,    -- in  std_logic;
      ClkWrite     => ClkReg, -- ClkPci,    -- in  std_logic;
      DataIn       => DaqData(71 downto 0), -- in  std_logic_vector (71 downto 0);
      ReadEnIn     => UltraNotFull, -- in  std_logic;
      Reset        => FifoResetS, -- Reset,     -- in  std_logic;
      WriteEn      => DaqDEn,    -- in  std_logic;
      BufferBusy   => open,      -- out std_logic;
      DataOut(71 downto 68) => UltraTData(71 downto 68),    -- out std_logic_vector (71 downto 0);
      DataOut(67 downto 36) => UltraTdata(63 downto 32),    -- out std_logic_vector (71 downto 0);
      DataOut(35 downto 32) => UltraTdata(67 downto 64),    -- out std_logic_vector (71 downto 0);
      DataOut(31 downto 0 ) => UltraTdata(31 downto 0 ),    -- out std_logic_vector (71 downto 0);
      DataValid    => UltraTvalid,                -- out std_logic;
      DWAvailable  => DWAvailable(15 downto 0), -- out std_logic_vector (15 downto 0);
      FifoPFull    => BlkBufFull, -- out std_logic;
      ReadyForRead => BlockReady, -- out std_logic;
      Status       => DReadStatus(15 downto 0),    -- out std_logic_vector (15 downto 0);
      WordCount    => DReadStatus(31 downto 16) ); -- out std_logic_vector (15 downto 0);

  UltraNotFull <= ((not UltraAfull) and UltraTready);
  UltraTlast <= UltraTData(71) and UltraTvalid;
  Data2PCI(71) <= UltraMTlast;
  Data2PCI(70 downto 64) <= "0100001";

  FifoResetU <= user_reset  or VmeReset(4);
  FifoResetN <= user_resetn and (not VmeReset(4));
  ExtraDataBuffer : AxisFifo
    PORT MAP(
      s_axis_aresetn => FifoResetN, -- user_resetn, --  IN STD_LOGIC;
      s_axis_aclk => ClkReg, --  IN STD_LOGIC;
      s_axis_tvalid => UltraTvalid, --  IN STD_LOGIC;
      s_axis_tready => UltraTready, --  OUT STD_LOGIC;
      s_axis_tdata => UltraTdata(63 downto 0), --   IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      s_axis_tlast => UltraTlast, --   IN STD_LOGIC;
      m_axis_tvalid => DataValid, --   OUT STD_LOGIC;
      m_axis_tready => BlkBufRen, --   IN STD_LOGIC;
      m_axis_tdata => Data2PCI(63 downto 0), --   OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      m_axis_tlast => UltraMTlast, --   OUT STD_LOGIC;
      almost_empty => UltraAempty, --   OUT STD_LOGIC;
      almost_full => UltraAfull); --   OUT STD_LOGIC

-- assign the signals to KU3P interface
  C2HData(0)(255 downto 0) <= x"71E5DA7A" & x"5948A5" & Data2PCI(71 downto 0) & x"71E5DA7A" & x"594869"& Data2PCI(71 downto 0);
  -- C2HLast(0) <= UltraMTlast;  use UltraMTlast directly
  C2HDataVal(0) <= DataValid;
  BlkBufRen <= PcieReady(0);

  TrgBitFifoMod : TrgBitFifo
    Port map(
      GtpTrgIn   => x"00000000", -- in  STD_LOGIC_VECTOR (31 downto 0);  -- They are all 4 ns wide pulses
      ExtTrgIn   => x"00000000", -- in  STD_LOGIC_VECTOR (31 downto 0);
      FpTrgIn    => PreTable(32 downto 1), -- in  STD_LOGIC_VECTOR (31 downto 0);
      GtpTrgInEn => '0',        -- in std_logic;
      ExtTrgInEn => '0',        -- in std_logic;
      FpTrgInEN  => PreTableEn, -- in std_logic;  -- These three channels work simultanousely
      SyncDly    => SyncDelay(23 downto 16),  -- in  STD_LOGIC_VECTOR (7 downto 0);
      SerialDly  => SyncGenDelay(7 downto 0), -- in std_logic_vector(7 downto 0);
      QuadTime   => "00",    -- in  STD_LOGIC_VECTOR (1 downto 0);
      Clk250     => Clk250,  -- in  STD_LOGIC;
      Reset      => Reset,   -- in  STD_LOGIC;
      WindowDly  => "01000", -- RegWidth(4 downto 0), -- in std_logic_vector(4 downto 0);
      TestPt   => open,    -- out  std_logic_vector(10 downto 1);
      TrgInput   => RawTrgIn(95 downto 0) ); -- inout  STD_LOGIC_VECTOR (95 downto 0));

  Resync_TIbusyLatch : SigClkA2B
    port map (SigIn  => VmeReset(24), -- in STD_LOGIC;
              ClkIn  => ClkReg, -- in STD_LOGIC;
              ClkOut => ClkPrg, -- in STD_LOGIC;
              SigOut => TIbusyLatch ); -- out STD_LOGIC);
  Resync_TIbusyReset : SigClkA2B
    port map (SigIn  => CountRst, -- in STD_LOGIC;
              ClkIn  => Clk250, -- in STD_LOGIC;
              ClkOut => ClkPrg, -- in STD_LOGIC;
              SigOut => CountRstBusy ); -- out STD_LOGIC);

  TIBUSYmode : TIinBusy
    port map(Clock => ClkPrg,  -- in  std_logic;
      SwaBusy     => '0', -- USB2A,  -- in  std_logic;
      SwbBusy     => '0', -- USB2B,  -- in  std_logic;
      BusySrcEn   => BusySrcEn(15 downto 0), -- in std_logic_vector (15 downto 0);
      CountLatch  => TIbusyLatch, --VmeReset(24), -- in  std_logic;
      CountReset  => CountRstBusy,    -- in  std_logic;
      FadcBusy    => '0',         -- in  std_logic;
      FPBusy      => GENINP(1), -- FPBusySync,  -- in  std_logic;
      FtdcBusy    => '0',         -- in  std_logic;
      P2Busy      => '0',         -- in  std_logic;
      TIFifoFull  => TIfifoFull,  -- in  std_logic;
      BusyCounter => BusyCounter(191 downto 0), -- out std_logic_vector (191 downto 0);
      StatBusy    => TrgSyncBusy(5 downto 0),   -- out std_logic_vector (5 downto 0);
      TIBusy      => TIselfBusy );              -- out std_logic);

  Status(11) <= (TIselfBusy or SyncEvtSet or BusyIRQ or (FnextFull and BusySrcEn(7)) );

-- signals for TdTsBusy
  ExtendPulse : SignalF2S   -- move from Clk250 (4ns wide) to Clk625 (16ns wide)
    Port map( Clk250 => CLk250,   -- in STD_LOGIC;
      Clk625    => Clk625,        -- in STD_LOGIC;
      SigIn250  => ReadoutTrg,    -- in STD_LOGIC;
      SigOut625 => ExtendedTrg ); -- inout STD_LOGIC);
  ExtendBlkEnd : SignalF2S
    Port map( Clk250 => CLk250,   -- in STD_LOGIC;
      Clk625    => Clk625,        -- in STD_LOGIC;
      SigIn250  => BlkEnd,        -- in STD_LOGIC;
      SigOut625 => ExtendedBlk ); -- inout STD_LOGIC);
  NewPulseTrig  <= ExtendedTrg when (MasterMode(3) = '1') else PulseTrig;
  NewSyncBlkEnd <= ExtendedBlk when (MasterMode(3) = '1') else SyncBlkEnd;
  NewBlockTh    <= NewBlkSize(23 downto 16) when (MasterMode(3) = '1') else BlockTh;

  ReadAen <= RegisterR and RegReadAdd(8) and (not RegReadAdd(7)) and RegReadAdd(6) and RegReadAdd(5) and RegReadAdd(4) and (not RegReadAdd(3)) and (not RegReadAdd(2));
  ReadBen <= RegisterR and RegReadAdd(8) and (not RegReadAdd(7)) and RegReadAdd(6) and RegReadAdd(5) and RegReadAdd(4) and (not RegReadAdd(3)) and RegReadAdd(2);
  ModTDTImTSbusy : TDTImBusy
    port map(BlockTh => NewBlockTh(7 downto 0), -- in std_logic_vector (7 downto 0);
      BusySrcEn   => BusySrcEn(15 downto 0), -- in std_logic_vector (15 downto 0);
      ClkVme      => ClkPrg, -- in std_logic;   Clock for Busy counter
      Clk625      => Clk625, -- in std_logic;
      ClkRead     => ClkReg, -- ClkPci, -- in std_logic;   Clock for FIFO data readout
      CountLatch  => TIbusyLatch, -- VmeReset(24), -- in std_logic;
      CountReset  => CountRstBusy,    -- in std_logic;
      GTPRxEn(1 downto 0) => GTPRxEn(1 downto 0), -- in std_logic_vector (8 downto 0);
      GTPRxEn(8 downto 2) => "0000000", -- disable the fiber 2-8
      LpBkEn      => GTPlpEn,      -- in std_logic;
      PulseTrig   => NewPulseTrig, -- in std_logic;
      ReadAen     => ReadAen,      -- in std_logic;
      ReadBen     => ReadBen,      -- in std_logic;
      Reset       => Reset,        -- in std_logic;
      ResetFS     => SReset(10),   -- in std_logic;
      ROCEN       => ROCEn(31 downto 0),     -- in std_logic_vector (31 downto 0);
      StatusA     => StatusA(15 downto 0),   -- in std_logic_vector (15 downto 0);
      StatusB     => x"0000",                -- in std_logic_vector (15 downto 0);
      StatusC     => x"0000",                -- in std_logic_vector (15 downto 0);
      StatusD     => x"0000",                -- in std_logic_vector (15 downto 0);
      StatusE     => x"0000", -- StatusE(15 downto 0),   -- in std_logic_vector (15 downto 0);
      StatusF     => x"0000",                -- in std_logic_vector (15 downto 0);
      StatusG     => x"0000",                -- in std_logic_vector (15 downto 0);
      StatusH     => x"0000",                -- in std_logic_vector (15 downto 0);
      StatusZ     => StatusOut(15 downto 0), -- in std_logic_vector (15 downto 0);
      SyncBlkEnd  => NewSyncBlkEnd, -- in  std_logic;
      TempBusy    => TempBusy,      -- in  std_logic;
      TSInhibit   => TSInhibit,     -- in  std_logic;
      BoardRdy    => FiberConn(24 downto 16),     -- out std_logic_vector (8 downto 0);
      BusyCounter => BusyCounter(511 downto 192), -- out std_logic_vector (319 downto 0);
      BusyTI      => open,     -- out std_logic_vector (8 downto 0);
      ExtraAck    => ExtraAck, -- out std_logic;
      ReadAout    => ReadAout(35 downto 0), -- out std_logic_vector (35 downto 0);
      ReadBout    => ReadBout(35 downto 0), -- out std_logic_vector (35 downto 0);
      SReqSet     => SReqSet,             -- out std_logic;
      SRespTI     => SRespTI(8 downto 0), -- out std_logic_vector (8 downto 0);
      TestPt      => MonBusy(4 downto 1), -- out std_logic_vector (4 downto 1);
      TIBusy      => TrgSyncBusy(15 downto 7), -- out std_logic_vector (8 downto 0);
      TIinfo      => TIinfo(287 downto 0),     -- out std_logic_vector (287 downto 0);
      TIResetReq  => TIResetReq(8 downto 0),   -- out std_logic_vector (8 downto 0);
      TrgLossBusy => TrgSyncBusy(6),           -- out std_logic;
      TSBusy      => TSBusy,                   -- out std_logic;
      TsReadB     => TrgAck(159 downto 0) );  -- out std_logic_vector (159 downto 0));

  process (ClkReg)
  begin
    if (ClkReg'event and ClkReg = '1') then
      DlyTrgSrcSet <= TrgSrcSet;
      DlyFCTrgSrcSet <= ForceTrgSrcSet;
    end if;
  end process;

  TrgEnDis2Clk : Signal2Clk
    Port map(Clk => Clk625,       -- in STD_LOGIC;
      FakeClkIn  => DlyTrgSrcSet, -- in STD_LOGIC;
      SigOut     => TrgEnDis );   -- inout STD_LOGIC);
  FCTrgSrcSet2Clk : Signal2Clk
    Port map(Clk => Clk625,         -- in STD_LOGIC;
      FakeClkIn  => DlyFCTrgSrcSet, -- in STD_LOGIC;
      SigOut     => FCTrgSrcSet );  -- inout STD_LOGIC);
  SyncSendID2Clk : Signal2Clk
    Port map(Clk => Clk625,        -- in STD_LOGIC;
      FakeClkIn  => SendID,        -- in STD_LOGIC;
      SigOut     => SyncSendID );  -- inout STD_LOGIC);
-- Use SigClkA2B for SRstReq
  Resync_SRstReq : SigClkA2B
    port map (SigIn  => VmeReset(23), -- in STD_LOGIC;
              ClkIn  => ClkReg, -- in STD_LOGIC;
              ClkOut => Clk625, -- in STD_LOGIC;
              SigOut => SyncSRstReq ); -- out STD_LOGIC);
--  SRstReq <= VmeReset(23);
--  SynSRstReq2Clk : Signal2Clk
--    Port map(Clk => Clk625,         -- in STD_LOGIC;
--      FakeClkIn  => SRstReq,        -- in STD_LOGIC;
--      SigOut     => SyncSRstReq );  -- inout STD_LOGIC);
  StatusGenMod : StatusGen
    Port map(TrgEnDis => TrgEnDis,   -- in  STD_LOGIC;
      ForceTrgSrcSet => FCTrgSrcSet, -- in  std_logic;
      StatusIn       => Status(15 downto 0),    -- in  STD_LOGIC_VECTOR (15 downto 0);
      StatusOut      => StatusOut(15 downto 0), -- inout STD_LOGIC_VECTOR (15 downto 0);
      GtpTxEn        => GTPlpEn,     -- out  STD_LOGIC;
      Clk            => Clk625,      -- in  std_logic;
      SRstReq        => SyncSRstReq, -- in  STD_LOGIC;
      SendID         => SyncSendID,  -- in  std_logic;
      BlkSizeUD      => UpdateBS,    -- in  std_logic;
      NewBlkSize     => NewBlkSize(31 downto 0), -- in  std_logic_vector (31 downto 0);
      BufSizeUD      => UpdateBuf,               -- in  std_logic;
      CrateID        => CrateID(7 downto 0),     -- in  STD_LOGIC_VECTOR (7 downto 0);
      TrgSrc         => TrgSrcEn(15 downto 0),   -- in  STD_LOGIC_VECTOR (15 downto 0);
      TestPt         => TestPtSG(4 downto 1) );  -- out std_logic_vector (4 downto 1));

-- Some generic outputs
  GENOUTX(11) <= PulseTrig;
  GENOUTX(12) <= Trig1;
  GENOUTX(13) <= Trig2;
  GENOUTX(14) <= TIselfBusy;
  GENOUTX(7)  <= PulseTrig;
  GENOUTX(8)  <= PromTrg;
  GENOUTX(15) <= TMRCountA(42);
  GENOUTX(16) <= TMRCountB(45);

  TIfifoVal <= FIFOValB;

  FifoAvTI(9) <= not FIFOstatus(3);
  FifoAvTI(8 downto 0) <= "000000000";
  FifoAvTI(11 downto 10) <= "00";
-- Fifo to QSFP
  PCIEWrite <= DataValidP;

-- Use the DSP counter instead
  PcieWCCounterDSP : Count48DSP
    PORT MAP (CLK => Clk250,         -- IN STD_LOGIC;
      CE          => DataValid,       -- IN STD_LOGIC;
      SCLR        => '0',  -- IN STD_LOGIC;
      Q(31 downto 0)  => PcieWC(31 downto 0), -- OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
      Q(47 downto 32) => open   );
  process(Clk250)
  begin
    if (Clk250'event and Clk250 = '1') then
      if (Reset = '1') then
--        PcieWC    <= (others => '0') ;
        DmaSize   <= (others => '0');
        DmaNumber <= (others => '0');
        LastWord  <= '0';
      elsif (FIFOValB = '1') then
--        PcieWC <= PcieWC + 1;
        if (LastWord = '1') then
          DmaSize <= (others => '0');
          DmaNumber <= DmaNumber + 1;
          LastWord <= '0';
        elsif ( (DmaSize(15 downto 3) = PcieSize(12 downto 0))
                 and (DmaSize(2) = '1') ) then
          LastWord <= '1';
        else
          DmaSize <= DmaSize + 1;
        end if;
      end if;
    end if;
  end process;

-- switching between TI data fifo and the STDC data fifo
  process (Clk250)
  begin
    if (Clk250'event and Clk250 = '1') then
      if (Reset = '1') then  -- set the TI data to default
        TIfifoReadEn <= '1';
        STDCfifoReadEn <= '0';
        LastSTDCWord <= '0';
      elsif (Dly2TIreadEn = '1' and TIfifoVal = '0') then
        TIfifoReadEn <= '0';
        STDCfifoReadEn <= '1';
      elsif (Dly2STDCreadEn = '1' and STDCfifoVal = '0') then
        LastSTDCWord <= '1';
        TIfifoReadEn <= '1';
        STDCfifoReadEn <= '0';
      else
        LastSTDCWord <= '0';
      end if;
      DlyTIreadEn <= TIfifoReadEn;
      Dly2TIreadEn <= DlyTIreadEn;
      DlySTDCreadEn <= STDCfifoReadEn;
      Dly2STDCreadEn <= DlySTDCreadEn;
    end if;
  end process;

-- replace with dsp counter
  PcieRWCCounterDSP : Count48DSP
    PORT MAP (CLK => Clk250,         -- IN STD_LOGIC;
      CE          => DataValidP,     -- IN STD_LOGIC;
      SCLR        => Reset,  -- IN STD_LOGIC;
      Q(31 downto 0)  => PcieRWC(31 downto 0), -- OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
      Q(47 downto 32) => open   );
  PciRxNumEn <= DataValidP and DataPcie(256);
  PciRxCounterDSP : Count48DSP
    PORT MAP (CLK => Clk250,         -- IN STD_LOGIC;
      CE          => PciRxNumEn,     -- IN STD_LOGIC;
      SCLR        => Reset,  -- IN STD_LOGIC;
      Q(31 downto 0)  => PciRxNumber(31 downto 0), -- OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
      Q(47 downto 32) => open   );

  H2CReady <= '1';
-- Block detect

  process (ClkReg, BlockRcvd(0))
  begin
    if (BlockRcvd(0) = '1') then
      PreBlock(0) <= '0';
    elsif (ClkReg'event and ClkReg = '1') then
      BlockIn(0) <= (Data2PCI(71) or Data2PCI(70)) and DataValid;
      if (BlockIn(0) = '1') then
        PreBlock(0) <= '1';
      end if;
    end if;
  end process;
  PreBlockSent(0) <= (C2HData(0)(71) or C2HData(0)(70)) and C2HDataVal(0);

  C2HdmaControl:  for iC2H in 0 to 0 generate
  begin
    C2HLast(iC2H)  <= PreBlockSent(iC2H) and not VetoLast(iC2H);
    C2HReadEn(iC2H) <= (VmeReset(iC2H+3) or ((not PreBlockSent(iC2H)) and PcieReady(iC2H) and OKtoRead(iC2H)));
    C2HBlkReady(iC2H) <= C2HBlkCnt(iC2H)(0) or C2HBlkCnt(iC2H)(1) or C2HBlkCnt(iC2H)(2) or C2HBlkCnt(iC2H)(3)
                      or C2HBlkCnt(iC2H)(4) or C2HBlkCnt(iC2H)(5) or C2HBlkCnt(iC2H)(6) or C2HBlkCnt(iC2H)(7);
    process (ClkReg)
    begin
      if (ClkReg'event and ClkReg = '1') then
        BlockRcvd(iC2H) <= PreBlock(iC2H);
        BlockSent(iC2H) <= PreBlockSent(iC2H);
        DlyC2HReadEn(iC2H) <= C2HReadEn(iC2H);
        VetoLast(iC2H) <= PreBlockSent(iC2H);
        if (user_reset = '1') then
          C2HBlkCnt(iC2H) <= (others => '0');
        elsif (BlockRcvd(iC2H) = '1' and BlockSent(iC2H) = '0') then
          C2HBlkCnt(iC2H) <= C2HBlkCnt(iC2H) + 1;
        elsif (BlockRcvd(iC2H) = '0' and BlockSent(iC2H) = '1' and C2HBlkReady(iC2H) = '1') then
          C2HBlkCnt(iC2H) <= C2HBlkCnt(iC2H) - 1;
        end if;
        if (DlyC2HReadEn(iC2H) = '1' and C2HReadEn(iC2H) = '0') then -- ReadEn falling edge
          OKtoRead(iC2H) <= '0';
        elsif (C2HBlkReady(iC2H) = '1' or C2HPFull(iC2H) = '1') then
          OKtoRead(iC2H) <= '1';
        end if;
      end if;
    end process;
  end generate;

  process (ClkReg)
    begin
      if (ClkReg'event and ClkReg = '1') then
        if (m_axil_awvalid = '1') then
          RegSetAdd <= m_axil_awaddr(12 downto 0);
          RegisterW   <= (not m_axil_awaddr(12)) and (not m_axil_awaddr(11)) and (not m_axil_awaddr(10)); -- 000: 512 Byte registers
          RegisterR   <= '0';
          if (m_axil_awaddr(12 downto 10) = "000") then
            PciRegBar <= "110";
          else
            PciRegBar <= "111";
          end if;
        elsif (m_axil_arvalid = '1') then
          RegReadAdd <= m_axil_araddr(12 downto 0);
          RegisterR   <= (not m_axil_araddr(12)) and (not m_axil_araddr(11)) and (not m_axil_araddr(10));
          RegisterW   <= '0';

        end if;
        if (m_axil_wvalid = '1') then
          RegSetData <= m_axil_wdata(31 downto 0);
        end if;

        PciRegWEn <= m_axil_wstrb(0) and m_axil_wvalid; -- m_axil_wvalid;
        PCiRegREn <= m_axil_rvalid_int;

--        DatatoQSFPen <= m_axil_wvalid or PciRegWEn;
      end if;
  end process;

  RegWEn  <= RegisterW   and PciRegWEn;
  DTackEn <= PciRegWEn or PciRegRen;

  ModRegisterSet: RegisterSet
    Port map( Address =>  RegSetAdd(8 downto 0),
      DataIn => RegSetData(31 downto 0),
      Clock => ClkReg,  -- ClkPci
      Reset =>  user_resetn,          -- negative logic
      BAR => PciRegBar, -- RegSetAdd(11 downto 9), -- "110", -- PciBARLegacy(2 downto 0),
                        -- use the converted back BAR, so no change in RegisterSet
      Enable => RegWEn, -- PciRegWEn,
      CrateID => CrateID(7 downto 0),
      CrateIDEn => SendID,
      FiberEn => FiberEn(7 downto 0),
      TrgSyncOutEn => TrgSyncOutEn,
      IntrptID => Interrupt(7 downto 0),
      IntrptLevel => Interrupt(10 downto 8),
      IntrptEn => Interrupt(16),
      TrigDelayWidth => TrgLenDly(31 downto 0),
      VmeAddress => VmeAddress(31 downto 0),
      BlockSize => BlockSize(7 downto 0),
      TIDataFormat => DataFormat(7 downto 0),
      VMESetting => VMESetting(31 downto 0),
      I2CAdd => open, --I2CAdd,
--    EnableCntl => out   (15 downto 0),
      TrgSrcEn => TrgSrcEn(15 downto 0),
      TrgSrcSet => TrgSrcSet,
      SyncSrcEn => SyncSrcEn(15 downto 0),
      BusySrcEn => BusySrcEn(15 downto 0),
      ClkSrcSet => ClkSrcSet,
      ClockSrc => ClockSrc(31 downto 0),
      TrigPreScale => TrigPreScale(15 downto 0),
      BlockTh => BlockTh(7 downto 0),
      TrigRule => TrigRule(31 downto 0),
      TrigWindow => TrigWindow(31 downto 0),
      GtpTrgEn => GtpTrgEn(31 downto 0),
      ExtTrgEn => ExtTrgEn(31 downto 0),
      FPTrgEn => FPTrgEn(31 downto 0),
      FPOutput => FPOutput(15 downto 0),
      SyncDelay => SyncDelay(31 downto 0),
      GtpPreScaleA => open, -- DMASetting(31 downto 0),
      GtpPreScaleB => open, -- DMAAddress(31 downto 0),
      GtpPreScaleC => GtpPreScaleC(31 downto 0),
      GtpPreScaleD => GtpPreScaleD(31 downto 0),
      ExtPreScaleA => ExtPreScaleA(31 downto 0),
      ExtPreScaleB => ExtPreScaleB(31 downto 0),
      ExtPreScaleC => ExtPreScaleC(31 downto 0),
      ExtPreScaleD => ExtPreScaleD(31 downto 0),
      LTTableLoad => LTTableLoad,
      VmeEvtType => VmeEvtType(31 downto 0),
      SyncGenDelay => SyncGenDelay(7 downto 0),
      SyncWidth => syncWidth(7 downto 0),
      TrigCommandEn => TrigCommandEn,
      TrigCommand => TrigCommand(15 downto 0),
      RandomTrgEn => RandomTrgEn,
      RandomTrg => RandomTrg(15 downto 0),
      SoftTrg1En => SoftTrg1En ,
      SoftTrg1 => SoftTrg1(31 downto 0),
      SoftTrg2En => SoftTrg2En,
      SoftTrg2 => SoftTrg2(31 downto 0),
      SyncCodeEn => SyncCodeEn,
      SyncCode => SyncCode(7 downto 0),
      RunCode => RunCode(31 downto 0),
      SyncEvtGen => SyncEvtGen(31 downto 0),
      PromptTrgW => PromptTrgW(7 downto 0),
      ROCEn => ROCEn(31 downto 0),
      EndOfRunBlk => EndOfRunBlk(31 downto 0),
      TrgTblData => TrgTblData(31 downto 0),
      TrgTblAdr => TrgTblAdr(3 downto 0),
      TrgTblWEN => TrgTblWEN,
      ForceTrgSrcSet => ForceTrgSrcSet, --  out std_logic;
      RunGo => RunGo , -- out std_logic;
      Reg104D => ChannelDelay(31 downto 0),
      Reg108D => ChannelDelay(63 downto 32),
      Reg10cD => Reg10cD(31 downto 0),
      Reg110D => Reg110D(31 downto 0),
      Reg114D => Reg114D(31 downto 0),
      Reg118D => Reg118D(31 downto 0),
      Reg11cD => Reg11cD(31 downto 0),
      Reg120D => Reg120D(31 downto 0),
      Reg124D => Reg124D(31 downto 0),
      Reg128D => Reg128D(31 downto 0),
      Reg12cD => Reg12cD(31 downto 0),
      Reg130D => Reg130D(31 downto 0),
      MinRuleWidth => MinRuleWidth(31 downto 0),
      I2CAddData => open, -- I2CAddData,
      VmeReset => VmeReset(31 downto 0)   );

  ClockSrcMon(31 downto 24) <= '0' & ForcedClk  & SWM(3 downto 1) & MasterMode(3 downto 1);
  ClockSrcMon(23 downto 22) <= SWM(6) & '1';
  ClockSrcMon(21 downto 16) <= ClockSrc(21 downto 16);
  ClockSrcMon(15 downto 12) <= SWM(8) & SWM(7) & SWM(5) & SWM(4);
  ClockSrcMon(11 downto 0) <= ClockSrc(11 downto 0);

  ModRegisterRead: RegisterRead
    port map(O   => RegData(31 downto 0),
      Sync98ReadEn => Sync98ReadEn, -- inout std_logic;
      EvtReadEn => EvtReadEn, -- inout std_logic;
      CrateID  => CrateID(7 downto 0),
      BoardID => BoardID, -- "01001000",
      FiberLink => "0000000000000000",
      FiberEn => FiberEn(7 downto 0),
      TrgSyncOutEn => TrgSyncOutEn,
      Interrupt => Interrupt(31 downto 0),
      TrigDelayWidth => TrgLenDly(31 downto 0),
      VmeAddress => VmeAddress(31 downto 0),
      BlockSize => BlockSize(7 downto 0),
      NewBlkSize  => NewBlkSize(31 downto 0),
      TIDataFormat => DataFormat(7 downto 0),
      VMESetting => VMESetting(31 downto 0),
      TrgSrcEn => TrgSrcEn(15 downto 0),
      TrgSrcMon => TrgSyncBusy(31 downto 16),
      SyncSrcEn => SyncSrcEn(7 downto 0),
      SyncMon => TrgSyncBusy(23 downto 0),
      BusySrcEn => BusySrcEn(15 downto 0),
      BusySrcMon => TrgSyncBusy(15 downto 0),
      ClockSrc => ClockSrcMon(31 downto 0),
      TrigPreScale => TrigPreScale(15 downto 0),
      BlockTh => BlockTh(7 downto 0),
      BlockAv => BlockAv(39 downto 0),
      SyncEvtSet  => SyncEvtSet,
      SReqSet  => SReqSet,
      SyncReadEn => SyncReadEn, -- std_logic_vector(7 downto 0);
      FillEvent => FillEvent,
      EndOfRunBR  => EndOfRunBr,
      TrgLost => TrgLost, --  in std_logic;
      TrigRule => TrigRule(31 downto 0),
      TrigWindow => TrigWindow(31 downto 0),
      GtpTrgEn => GtpTrgEn(31 downto 0),
      ExtTrgEn => ExtTrgEn(31 downto 0),
      FPTrgEn => FPTrgEn(31 downto 0),
      FPOutput => FPOutput(15 downto 0),
      SyncDelay => SyncDelay(31 downto 0),
      GtpPreScaleA => x"00000000", --DMASetting(31 downto 0),
      GtpPreScaleB => x"00000000", --DMAAddress(31 downto 0),
      GtpPreScaleC => GtpPreScaleC(31 downto 0),
      GtpPreScaleD => GtpPreScaleD(31 downto 0),
-- Trigger data readout by single register access (0x68)
      ExtPreScaleA(31 downto 0) => SWStatus(31 downto 0),
      ExtPreScaleB => SW2PCI(31 downto 0), -- FTDCMon(31 downto 0), -- ExtPreScaleB(31 downto 0), --
--      ExtPreScaleA => ExtPreScaleA(31 downto 0),
--      ExtPreScaleB => ExtPreScaleB(31 downto 0), -- SW2PCI(31 downto 0),
      ExtPreScaleC => ExtPreScaleC(31 downto 0),
      ExtPreScaleD => ExtPreScaleD(31 downto 0),
      ROCAckRd => ROCAckRd(63 downto 0),
      FPPreScale => VmeEvtType(31 downto 0),
      SyncCode => SyncCode(7 downto 0),
      SyncGenDelay => SyncGenDelay(7 downto 0),
      SyncWidth => SyncWidth(7 downto 0),
      TrigCommand => TrigCommand(15 downto 0),
      RandomTrg => RandomTrg(15 downto 0),
      SoftTrg1  => SoftTrg1(31 downto 0),
      SoftTrg2  => SoftTrg2(31 downto 0),
      BlockTotal => BlockTotal(31 downto 0),
      RunCode => RunCode(31 downto 0),
      FiberDlyMeas => FiberDlyMeas(63 downto 0),
      LiveTime => LLiveTime(31 downto 0),
      BusyTime => LBusyTime(31 downto 0),
      MgtStatus => GtpStAB(63 downto 0),
      MgtTrigBuf => TrgBufE(31 downto 0),
      TsTrgNum => GrsTrgNum(31 downto 0),
      TrgAck => TrgAck(159 downto 0),
      SyncEvtGen => SyncEvtGen(31 downto 0),
      PromptTrgW => PromptTrgW(7 downto 0),
      RegL1ANum  => regL1ANum(47 downto 0),
      ROCEn => ROCEn(31 downto 0),
      TIResetReq => TIResetReq(8 downto 0),
      TsValid => TsValid(31 downto 0),
      EndOfRunBlk => EndOfRunBlk(31 downto 0),
      TsScalar=> TSScalar(191 downto 0),
      SyncData => SyncData(39 downto 0),
      TIinfo  => TIinfo(287 downto 0),
      ChannelDelay => ChannelDelay(63 downto 0),
      TDCEvtReg => TDCEvtReg(3 downto 0),
      BusyCounter(511 downto 0) => BusyCounter(511 downto 0),
      MinRuleWidth => MinRuleWidth(31 downto 0),
      I2CAddData => x"00000000", -- I2CAddData,
      I2CBusy => '0', --I2CBusy,
      I2CRData => x"00000000", --I2CRData,
      ReadAOut => ReadAOut, --  in std_logic_vector(35 downto 0);
      ReadBOut => ReadBOut, -- in std_logic_vector(35 downto 0);
      ClkFreq => ClkFreq, -- in (31:0),
      Clock => ClkReg, -- ClkPci
      Enable =>  RegisterR,
      DlyRValid => m_axil_arvDLY, -- in std_logic;
      Address => RegReadAdd(8 downto 0)  );

-- I2C and Jtag decoding (mmeory space seperation)
  process (ClkReg)
  begin
    if (ClkReg'event and ClkReg = '1') then
      m_axil_arvDLY <= m_axil_arvalid;
      WriteStrobe <= m_axil_wstrb(0) and m_axil_wvalid;
      ReadStrobe  <= m_axil_arvalid and (not m_axil_arvDLY);
      m_axil_rdata <= RegData(31 downto 0);
      if (DlyReadStrobe = '1' and m_axil_rvalid_int = '0') then
        m_axil_rvalid_int <= '1'; -- m_axil_arvalid and RegisterR;
      end if;
      if (m_axil_rvalid_int = '1' and m_axil_rready = '1') then  -- change tom_axil_rready to low , back to '1'
        -- Pre_m_axil_rvalid <= '0';
        m_axil_rvalid_int <= '0';
      end if;

      -- handle write response
      if(m_axil_wvalid = '1' and m_axil_bvalid_int = '0') then
        m_axil_bvalid_int <= '1';
      end if;

      if(m_axil_bready = '1' and m_axil_bvalid_int = '1') then
          m_axil_bvalid_int <= '0';
      end if;

      DlyReadStrobe <= ReadStrobe;
      Dly2ReadStrobe <= DlyReadStrobe;
    end if;
  end process;
  m_axil_bvalid <= m_axil_bvalid_int;
  m_axil_rvalid <= m_axil_rvalid_int; -- or Pre_m_axil_rvalid;
  m_axil_awready <= '1'; --(not I2CBusy);
  m_axil_wready  <= '1'; --(not I2CBusy);

  m_axil_bresp <= "00";

  user_resetn <= axi_aresetn;  --  axi_aresetn, synced with axi_aclk for axi interfaces reset
  usr_irq_req(3 downto 0) <= Interrupt(3 downto 0);
  usr_irq_ack(3 downto 0) <= PcieInterrupt_Ackd;
  msi_enable       <=  Interrupt(15);
  m_axil_arready <= '1';
  m_axil_rresp <= "00";

  INTs_axis_c2h_tdata  <= C2HData(0)(255 downto 0);  -- in
  s_axis_c2h_tdata <= INTs_axis_c2h_tdata(63 downto 0);
  s_axis_c2h_tlast  <= UltraMTlast;   -- C2HLast(0),               --  FifoDataA(256), -- in
  s_axis_c2h_tvalid <= C2HDataVal(0);           -- in
  PcieReady(0) <= s_axis_c2h_tready;            -- FifoRenA, -- out
  INTs_axis_c2h_tkeep  <= x"FFFFFFFF"; -- in
  s_axis_c2h_tkeep <= INTs_axis_c2h_tkeep(7 downto 0);
  DataPcie(255 downto 0) <= INTm_axis_h2c_tdata(255 downto 64) & m_axis_h2c_tdata(63 downto 0); -- out
  DataPcie(256) <= m_axis_h2c_tlast;  -- out
  DataValidP  <= m_axis_h2c_tvalid;   -- out
  m_axis_h2c_tready <= H2CReady;   -- in
  DataPcie(269 downto 257) <= "01010" & m_axis_h2c_tkeep(7 downto 0);
--      m_axis_h2c_tkeep(31 downto 13) => open , -- out

  MasterMode(2 downto 1) <= ClockSrc(1 downto 0);
  MasterMode(3) <= (not CLockSrc(19)) and CLockSrc(18) and (not CLockSrc(17)) and CLockSrc(16); -- 0101 to be safe
  Running <= (not RunCode(7)) and RunCode(6) and RunCode(5) and RunCode(4) and
             (not RunCode(3)) and (not RunCode(2)) and (not RunCode(1)) and RunCode(0);
  LEDG(1) <= Running;      -- Front panel LED#1,
  LEDG(4) <= not Running;  -- Front Panel LED#2,

  ModIRQBUSY : IRQbusy
    Port map(Busy => BusyIRQ,   -- out  STD_LOGIC);
      BlockTh     => BlockTh(7 downto 0),      -- in  STD_LOGIC_VECTOR (7 downto 0);
      BufSize     => NewBlkSize(23 downto 16), -- in  STD_LOGIC_VECTOR (7 downto 0);
      VmeSetting  => VmeSetting(31 downto 0),  -- in  STD_LOGIC_VECTOR (31 downto 0);
      IRQcount    => IRQCount(7 downto 0) );   -- in  STD_LOGIC_VECTOR (7 downto 0);

-- LED display
-- TI compatible LEDs
  RxAErrIn <= ((MasterMode(1) xnor MasterMode(2)) and ((BusySrcEn(8) and RxAErr(1)) or (BusySrcEn(12) and RxAErr(3))))
           or (((MasterMode(1) xor MasterMode(2)) or MasterMode(3)) and ((RxAErr(1) and TrgSrcEn(1)) or (RxAErr(3) and TrgSrcEn(10))))
           or TestTSGen(1);

  ResetExtend : SignalExtend
    port map (Clock => Clk625, -- ClkSlow, -- in    std_logic;
      SigIn   => Reset,      -- in    std_logic;
      SigOut  => ExtReset ); -- out   std_logic);
  XLEDG(2) <= (not (RxAErrIn or ExtReset or Reset));  -- add the RxErr and Reset

  process (ClkPrg)
  begin
    if (ClkPrg'event and ClkPrg = '1') then
      if (ForcedClk = '1') then
        LEDCounter <= LEDCounter + 1;
      end if;
    end if;
  end process;

  BoardID <= RxAErrIn & Reset & ExtReset & TrgBufE(31) & TrgBufE(30) & TrgBufE(29) & DlyReady & ForcedClk;
  LEDG(0) <= (not (TrgBufE(31) and TrgBufE(30) and TrgBufE(29) and DlyReady and (LEDCounter(23) or (not ForcedClk)))); -- Red of LED_General_#1
  LEDG(9) <= (not (RxAErrIn or ExtReset or Reset));

  DTACKExtend : SignalExtend
    port map (Clock => Clk625, --ClkSlow, -- in  std_logic;
      SigIn   => DTackEn,       -- in  std_logic;
      SigOut  => DTackExtd );     -- out std_logic);
  LEDG(3) <= (not DTackExtd);
  XLEDG(0) <= (not DTackExtd);
  TriggerExtend : SignalExtend
    port map ( Clock => Clk625, -- ClkSlow, -- in    std_logic;
      SigIn   => ReadoutTrg,     -- in    std_logic;
      SigOut  => ReadTrgExtd );      -- out   std_logic);
  LEDG(6) <= (not ReadTrgExtd);
  XLEDG(1) <= (not ReadTrgExtd);
-- GENOut
  ThisTIMBusy <= TrgBusy or TempBusy;
  GENOUTX(1) <= ThisTIMBusy when NewMaster = '1' else DataBusy;
  process (Clk250)
  begin
    if (Clk250'event and Clk250 = '1') then
      if (ExtedOut2 = '1') then
        RegReadoutTrg <= '0';
      elsif (ReadoutTrg = '1') then
        RegReadoutTrg <= '1';
      end if;
    end if;
  end process;

-- Use DSP counter
  BlockTotalCounterDSP : Count48DSP
    PORT MAP (CLK => Clk625,         -- IN STD_LOGIC;
      CE          => NewSyncBlkEnd,  -- IN STD_LOGIC;
      SCLR        => Reset,          -- IN STD_LOGIC;
      Q(31 downto 0)  => BlockTotal(31 downto 0), -- OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
      Q(47 downto 32) => open   );
  process (Clk625)
  begin
    if (CLk625'event and Clk625 = '1') then
      ExtedOut2 <= RegReadoutTrg;
    end if;
  end process;
  GENOUTX(2) <= ExtedOut2;
  TestPt(12 downto 9) <= SReset(14) & Reset & TsWrStart & TsRdStart;
-- switch control
  GENOUTX(6 downto 3) <= FPOutput(3 downto 0);

  SWM(8) <= MasterMode(1) and (not MasterMode(3));
  SWM(7) <= MasterMode(3) or MasterMode(2);
  SWM(6 downto 1) <= (others => '0');

  GENOUTP(1) <= GENOUTX(1);
  GENOUTP(2) <= GENOUTX(2);  -- disable the inverter for ECL output
  GENOUTP(3) <= GENOUTX(3);
  GENOUTP(4) <= GENOUTX(4);
  GENOUTP(5) <= GENOUTX(5);
  GENOUTP(6) <= GENOUTX(6);
  GENOUTP(7) <= GENOUTX(7); -- disable the inverter for ECL output
  GENOUTP(8) <= GENOUTX(8);
--  XLEDG(2 downto 0)  <= GENOUTX(16 downto 14);
  LEDG(11 downto 10) <= (not GENOUTX(13 downto 12));
  LEDG(8 downto 7)   <= (not GENOUTX(11 downto 10));
  LEDG(5) <= (not GENOUTX(9));

  GENOUTP(12 downto 9) <= LEDG(9) & LEDG(6) & LEDG(3) & LEDG(0); -- Same four LEDs as the TI
  GENOUTP(16 downto 13) <= GENOUTX(14 downto 12) & Clk625Mon;  -- replace GenOutX(11) with Clk625Mon  
-- Busy counter and Live counter
  BoardActive <= TrgSrcEn(10) or TrgSrcEn(7) or TrgSrcEn(6) or TrgSrcEn(5)
              or TrgSrcEn(4) or TrgSrcEn(3) or TrgSrcEn(2) or TrgSrcEn(1);
  MasterOld <= MasterMode(1) xnor MasterMode(2);
  process (MasterMode, MasterOld, Status, ThisTIMBusy)
  begin
    if (MasterMode(3) = '1') then
      BoardBusy <= (Status(11) or ThisTIMBusy);
    elsif (MasterOld = '1') then
      BoardBusy <= ThisTIMBusy;
    else
      BoardBusy <= Status(11);
    end if;
  end process;
-- use DSP48 as counter
  BusyCntEn <= BoardActive and BoardBusy;
  LiveCntEn <= BoardActive and (not BoardBusy);
  BusyCounterDSP : Count48DSP
    PORT MAP (CLK => ClkPrg,       -- IN STD_LOGIC;
      CE          => BusyCntEn,    -- IN STD_LOGIC;
      SCLR        => Reset,        -- IN STD_LOGIC;
      Q(39 downto 0)  => BusyTime, -- OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
      Q(47 downto 40) => open   );
  LiveCounterDSP : Count48DSP
    PORT MAP (CLK => ClkPrg,       -- IN STD_LOGIC;
      CE          => LiveCntEn,    -- IN STD_LOGIC;
      SCLR        => Reset,        -- IN STD_LOGIC;
      Q(39 downto 0)  => LiveTime, -- OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
      Q(47 downto 40) => open   );

--  Add the latch for timer readout
  process (ClkReg)
  begin
    if (CLkReg'event and ClkReg = '1') then
      if (VmeReset(24) = '1') then
        LLiveTime(31 downto 0) <= LiveTime(39 downto 8);
        LBusyTime(31 downto 0) <= BusyTime(39 downto 8);
      end if;
    end if;
  end process;
  process (Clk625)
  begin
    if (Clk625'event and Clk625 = '1') then
      Clk625Mon <= not Clk625Mon;
    end if;
  end process;
  TCSOut(10 downto 1) <= SReset(11) & SReset(9) & SReset(7) & SReset(5) & SReset(3) & SReset(2) & Status(7) & Reset & Trig1 & IODlyRst;
  TCSOut(16 downto 11) <= MasterMode(3 downto 1) & SReset(14 downto 12);
end Behavioral;
