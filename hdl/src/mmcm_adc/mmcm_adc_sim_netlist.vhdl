-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
-- Date        : Tue Jun 17 13:40:09 2025
-- Host        : gu-pc2.jlab.org running 64-bit Red Hat Enterprise Linux release 8.10 (Ootpa)
-- Command     : write_vhdl -force -mode funcsim /home/jgu/fpga_vivado/molleradc/hdl/src/mmcm_adc/mmcm_adc_sim_netlist.vhdl
-- Design      : mmcm_adc
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xczu6cg-ffvc900-1-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity mmcm_adc_mmcm_adc_clk_wiz is
  port (
    clk_adc_cnv : out STD_LOGIC;
    clk_adc : out STD_LOGIC;
    clk_625 : out STD_LOGIC;
    clk_50 : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of mmcm_adc_mmcm_adc_clk_wiz : entity is "mmcm_adc_clk_wiz";
end mmcm_adc_mmcm_adc_clk_wiz;

architecture STRUCTURE of mmcm_adc_mmcm_adc_clk_wiz is
  signal clk_50_mmcm_adc : STD_LOGIC;
  signal clk_50_mmcm_adc_en_clk : STD_LOGIC;
  signal clk_625_mmcm_adc : STD_LOGIC;
  signal clk_625_mmcm_adc_en_clk : STD_LOGIC;
  signal clk_adc_cnv_mmcm_adc : STD_LOGIC;
  signal clk_adc_cnv_mmcm_adc_en_clk : STD_LOGIC;
  signal clk_adc_mmcm_adc : STD_LOGIC;
  signal clk_adc_mmcm_adc_en_clk : STD_LOGIC;
  signal clk_in1_mmcm_adc : STD_LOGIC;
  signal clkfbout_buf_mmcm_adc : STD_LOGIC;
  signal clkfbout_mmcm_adc : STD_LOGIC;
  signal \^locked\ : STD_LOGIC;
  signal seq_reg1 : STD_LOGIC_VECTOR ( 7 downto 0 );
  attribute RTL_KEEP : string;
  attribute RTL_KEEP of seq_reg1 : signal is "true";
  attribute async_reg : string;
  attribute async_reg of seq_reg1 : signal is "true";
  signal seq_reg2 : STD_LOGIC_VECTOR ( 7 downto 0 );
  attribute RTL_KEEP of seq_reg2 : signal is "true";
  attribute async_reg of seq_reg2 : signal is "true";
  signal seq_reg3 : STD_LOGIC_VECTOR ( 7 downto 0 );
  attribute RTL_KEEP of seq_reg3 : signal is "true";
  attribute async_reg of seq_reg3 : signal is "true";
  signal seq_reg4 : STD_LOGIC_VECTOR ( 7 downto 0 );
  attribute RTL_KEEP of seq_reg4 : signal is "true";
  attribute async_reg of seq_reg4 : signal is "true";
  signal NLW_mmcme4_adv_inst_CDDCDONE_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcme4_adv_inst_CLKFBOUTB_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcme4_adv_inst_CLKFBSTOPPED_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcme4_adv_inst_CLKINSTOPPED_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcme4_adv_inst_CLKOUT0B_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcme4_adv_inst_CLKOUT1B_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcme4_adv_inst_CLKOUT2B_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcme4_adv_inst_CLKOUT3B_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcme4_adv_inst_CLKOUT4_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcme4_adv_inst_CLKOUT5_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcme4_adv_inst_CLKOUT6_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcme4_adv_inst_DRDY_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcme4_adv_inst_PSDONE_UNCONNECTED : STD_LOGIC;
  signal NLW_mmcme4_adv_inst_DO_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  attribute BOX_TYPE : string;
  attribute BOX_TYPE of clkf_buf : label is "PRIMITIVE";
  attribute XILINX_LEGACY_PRIM : string;
  attribute XILINX_LEGACY_PRIM of clkf_buf : label is "BUFG";
  attribute BOX_TYPE of clkin1_bufg : label is "PRIMITIVE";
  attribute XILINX_LEGACY_PRIM of clkin1_bufg : label is "BUFG";
  attribute BOX_TYPE of clkout1_buf : label is "PRIMITIVE";
  attribute BOX_TYPE of clkout1_buf_en : label is "PRIMITIVE";
  attribute BOX_TYPE of clkout2_buf : label is "PRIMITIVE";
  attribute BOX_TYPE of clkout2_buf_en : label is "PRIMITIVE";
  attribute BOX_TYPE of clkout3_buf : label is "PRIMITIVE";
  attribute BOX_TYPE of clkout3_buf_en : label is "PRIMITIVE";
  attribute BOX_TYPE of clkout4_buf : label is "PRIMITIVE";
  attribute BOX_TYPE of clkout4_buf_en : label is "PRIMITIVE";
  attribute BOX_TYPE of mmcme4_adv_inst : label is "PRIMITIVE";
  attribute ASYNC_REG_boolean : boolean;
  attribute ASYNC_REG_boolean of \seq_reg1_reg[0]\ : label is std.standard.true;
  attribute KEEP : string;
  attribute KEEP of \seq_reg1_reg[0]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg1_reg[1]\ : label is std.standard.true;
  attribute KEEP of \seq_reg1_reg[1]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg1_reg[2]\ : label is std.standard.true;
  attribute KEEP of \seq_reg1_reg[2]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg1_reg[3]\ : label is std.standard.true;
  attribute KEEP of \seq_reg1_reg[3]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg1_reg[4]\ : label is std.standard.true;
  attribute KEEP of \seq_reg1_reg[4]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg1_reg[5]\ : label is std.standard.true;
  attribute KEEP of \seq_reg1_reg[5]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg1_reg[6]\ : label is std.standard.true;
  attribute KEEP of \seq_reg1_reg[6]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg1_reg[7]\ : label is std.standard.true;
  attribute KEEP of \seq_reg1_reg[7]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg2_reg[0]\ : label is std.standard.true;
  attribute KEEP of \seq_reg2_reg[0]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg2_reg[1]\ : label is std.standard.true;
  attribute KEEP of \seq_reg2_reg[1]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg2_reg[2]\ : label is std.standard.true;
  attribute KEEP of \seq_reg2_reg[2]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg2_reg[3]\ : label is std.standard.true;
  attribute KEEP of \seq_reg2_reg[3]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg2_reg[4]\ : label is std.standard.true;
  attribute KEEP of \seq_reg2_reg[4]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg2_reg[5]\ : label is std.standard.true;
  attribute KEEP of \seq_reg2_reg[5]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg2_reg[6]\ : label is std.standard.true;
  attribute KEEP of \seq_reg2_reg[6]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg2_reg[7]\ : label is std.standard.true;
  attribute KEEP of \seq_reg2_reg[7]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg3_reg[0]\ : label is std.standard.true;
  attribute KEEP of \seq_reg3_reg[0]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg3_reg[1]\ : label is std.standard.true;
  attribute KEEP of \seq_reg3_reg[1]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg3_reg[2]\ : label is std.standard.true;
  attribute KEEP of \seq_reg3_reg[2]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg3_reg[3]\ : label is std.standard.true;
  attribute KEEP of \seq_reg3_reg[3]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg3_reg[4]\ : label is std.standard.true;
  attribute KEEP of \seq_reg3_reg[4]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg3_reg[5]\ : label is std.standard.true;
  attribute KEEP of \seq_reg3_reg[5]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg3_reg[6]\ : label is std.standard.true;
  attribute KEEP of \seq_reg3_reg[6]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg3_reg[7]\ : label is std.standard.true;
  attribute KEEP of \seq_reg3_reg[7]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg4_reg[0]\ : label is std.standard.true;
  attribute KEEP of \seq_reg4_reg[0]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg4_reg[1]\ : label is std.standard.true;
  attribute KEEP of \seq_reg4_reg[1]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg4_reg[2]\ : label is std.standard.true;
  attribute KEEP of \seq_reg4_reg[2]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg4_reg[3]\ : label is std.standard.true;
  attribute KEEP of \seq_reg4_reg[3]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg4_reg[4]\ : label is std.standard.true;
  attribute KEEP of \seq_reg4_reg[4]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg4_reg[5]\ : label is std.standard.true;
  attribute KEEP of \seq_reg4_reg[5]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg4_reg[6]\ : label is std.standard.true;
  attribute KEEP of \seq_reg4_reg[6]\ : label is "yes";
  attribute ASYNC_REG_boolean of \seq_reg4_reg[7]\ : label is std.standard.true;
  attribute KEEP of \seq_reg4_reg[7]\ : label is "yes";
begin
  locked <= \^locked\;
clkf_buf: unisim.vcomponents.BUFGCE
    generic map(
      CE_TYPE => "ASYNC",
      SIM_DEVICE => "ULTRASCALE_PLUS"
    )
        port map (
      CE => '1',
      I => clkfbout_mmcm_adc,
      O => clkfbout_buf_mmcm_adc
    );
clkin1_bufg: unisim.vcomponents.BUFGCE
    generic map(
      CE_TYPE => "ASYNC",
      SIM_DEVICE => "ULTRASCALE_PLUS"
    )
        port map (
      CE => '1',
      I => clk_in1,
      O => clk_in1_mmcm_adc
    );
clkout1_buf: unisim.vcomponents.BUFGCE
    generic map(
      CE_TYPE => "SYNC",
      IS_CE_INVERTED => '0',
      IS_I_INVERTED => '0',
      SIM_DEVICE => "ULTRASCALE",
      STARTUP_SYNC => "FALSE"
    )
        port map (
      CE => seq_reg1(7),
      I => clk_adc_cnv_mmcm_adc,
      O => clk_adc_cnv
    );
clkout1_buf_en: unisim.vcomponents.BUFGCE
    generic map(
      CE_TYPE => "SYNC",
      IS_CE_INVERTED => '0',
      IS_I_INVERTED => '0',
      SIM_DEVICE => "ULTRASCALE",
      STARTUP_SYNC => "FALSE"
    )
        port map (
      CE => '1',
      I => clk_adc_cnv_mmcm_adc,
      O => clk_adc_cnv_mmcm_adc_en_clk
    );
clkout2_buf: unisim.vcomponents.BUFGCE
    generic map(
      CE_TYPE => "SYNC",
      IS_CE_INVERTED => '0',
      IS_I_INVERTED => '0',
      SIM_DEVICE => "ULTRASCALE",
      STARTUP_SYNC => "FALSE"
    )
        port map (
      CE => seq_reg2(7),
      I => clk_adc_mmcm_adc,
      O => clk_adc
    );
clkout2_buf_en: unisim.vcomponents.BUFGCE
    generic map(
      CE_TYPE => "SYNC",
      IS_CE_INVERTED => '0',
      IS_I_INVERTED => '0',
      SIM_DEVICE => "ULTRASCALE",
      STARTUP_SYNC => "FALSE"
    )
        port map (
      CE => '1',
      I => clk_adc_mmcm_adc,
      O => clk_adc_mmcm_adc_en_clk
    );
clkout3_buf: unisim.vcomponents.BUFGCE
    generic map(
      CE_TYPE => "SYNC",
      IS_CE_INVERTED => '0',
      IS_I_INVERTED => '0',
      SIM_DEVICE => "ULTRASCALE",
      STARTUP_SYNC => "FALSE"
    )
        port map (
      CE => seq_reg3(7),
      I => clk_625_mmcm_adc,
      O => clk_625
    );
clkout3_buf_en: unisim.vcomponents.BUFGCE
    generic map(
      CE_TYPE => "SYNC",
      IS_CE_INVERTED => '0',
      IS_I_INVERTED => '0',
      SIM_DEVICE => "ULTRASCALE",
      STARTUP_SYNC => "FALSE"
    )
        port map (
      CE => '1',
      I => clk_625_mmcm_adc,
      O => clk_625_mmcm_adc_en_clk
    );
clkout4_buf: unisim.vcomponents.BUFGCE
    generic map(
      CE_TYPE => "SYNC",
      IS_CE_INVERTED => '0',
      IS_I_INVERTED => '0',
      SIM_DEVICE => "ULTRASCALE",
      STARTUP_SYNC => "FALSE"
    )
        port map (
      CE => seq_reg4(7),
      I => clk_50_mmcm_adc,
      O => clk_50
    );
clkout4_buf_en: unisim.vcomponents.BUFGCE
    generic map(
      CE_TYPE => "SYNC",
      IS_CE_INVERTED => '0',
      IS_I_INVERTED => '0',
      SIM_DEVICE => "ULTRASCALE",
      STARTUP_SYNC => "FALSE"
    )
        port map (
      CE => '1',
      I => clk_50_mmcm_adc,
      O => clk_50_mmcm_adc_en_clk
    );
mmcme4_adv_inst: unisim.vcomponents.MMCME4_ADV
    generic map(
      BANDWIDTH => "HIGH",
      CLKFBOUT_MULT_F => 6.000000,
      CLKFBOUT_PHASE => 0.000000,
      CLKFBOUT_USE_FINE_PS => "FALSE",
      CLKIN1_PERIOD => 4.000000,
      CLKIN2_PERIOD => 0.000000,
      CLKOUT0_DIVIDE_F => 6.000000,
      CLKOUT0_DUTY_CYCLE => 0.500000,
      CLKOUT0_PHASE => 0.000000,
      CLKOUT0_USE_FINE_PS => "FALSE",
      CLKOUT1_DIVIDE => 12,
      CLKOUT1_DUTY_CYCLE => 0.500000,
      CLKOUT1_PHASE => 0.000000,
      CLKOUT1_USE_FINE_PS => "FALSE",
      CLKOUT2_DIVIDE => 24,
      CLKOUT2_DUTY_CYCLE => 0.500000,
      CLKOUT2_PHASE => 0.000000,
      CLKOUT2_USE_FINE_PS => "FALSE",
      CLKOUT3_DIVIDE => 30,
      CLKOUT3_DUTY_CYCLE => 0.500000,
      CLKOUT3_PHASE => 0.000000,
      CLKOUT3_USE_FINE_PS => "FALSE",
      CLKOUT4_CASCADE => "FALSE",
      CLKOUT4_DIVIDE => 1,
      CLKOUT4_DUTY_CYCLE => 0.500000,
      CLKOUT4_PHASE => 0.000000,
      CLKOUT4_USE_FINE_PS => "FALSE",
      CLKOUT5_DIVIDE => 1,
      CLKOUT5_DUTY_CYCLE => 0.500000,
      CLKOUT5_PHASE => 0.000000,
      CLKOUT5_USE_FINE_PS => "FALSE",
      CLKOUT6_DIVIDE => 1,
      CLKOUT6_DUTY_CYCLE => 0.500000,
      CLKOUT6_PHASE => 0.000000,
      CLKOUT6_USE_FINE_PS => "FALSE",
      COMPENSATION => "BUF_IN",
      DIVCLK_DIVIDE => 1,
      IS_CLKFBIN_INVERTED => '0',
      IS_CLKIN1_INVERTED => '0',
      IS_CLKIN2_INVERTED => '0',
      IS_CLKINSEL_INVERTED => '0',
      IS_PSEN_INVERTED => '0',
      IS_PSINCDEC_INVERTED => '0',
      IS_PWRDWN_INVERTED => '0',
      IS_RST_INVERTED => '0',
      REF_JITTER1 => 0.010000,
      REF_JITTER2 => 0.010000,
      SS_EN => "FALSE",
      SS_MODE => "CENTER_HIGH",
      SS_MOD_PERIOD => 10000,
      STARTUP_WAIT => "FALSE"
    )
        port map (
      CDDCDONE => NLW_mmcme4_adv_inst_CDDCDONE_UNCONNECTED,
      CDDCREQ => '0',
      CLKFBIN => clkfbout_buf_mmcm_adc,
      CLKFBOUT => clkfbout_mmcm_adc,
      CLKFBOUTB => NLW_mmcme4_adv_inst_CLKFBOUTB_UNCONNECTED,
      CLKFBSTOPPED => NLW_mmcme4_adv_inst_CLKFBSTOPPED_UNCONNECTED,
      CLKIN1 => clk_in1_mmcm_adc,
      CLKIN2 => '0',
      CLKINSEL => '1',
      CLKINSTOPPED => NLW_mmcme4_adv_inst_CLKINSTOPPED_UNCONNECTED,
      CLKOUT0 => clk_adc_cnv_mmcm_adc,
      CLKOUT0B => NLW_mmcme4_adv_inst_CLKOUT0B_UNCONNECTED,
      CLKOUT1 => clk_adc_mmcm_adc,
      CLKOUT1B => NLW_mmcme4_adv_inst_CLKOUT1B_UNCONNECTED,
      CLKOUT2 => clk_625_mmcm_adc,
      CLKOUT2B => NLW_mmcme4_adv_inst_CLKOUT2B_UNCONNECTED,
      CLKOUT3 => clk_50_mmcm_adc,
      CLKOUT3B => NLW_mmcme4_adv_inst_CLKOUT3B_UNCONNECTED,
      CLKOUT4 => NLW_mmcme4_adv_inst_CLKOUT4_UNCONNECTED,
      CLKOUT5 => NLW_mmcme4_adv_inst_CLKOUT5_UNCONNECTED,
      CLKOUT6 => NLW_mmcme4_adv_inst_CLKOUT6_UNCONNECTED,
      DADDR(6 downto 0) => B"0000000",
      DCLK => '0',
      DEN => '0',
      DI(15 downto 0) => B"0000000000000000",
      DO(15 downto 0) => NLW_mmcme4_adv_inst_DO_UNCONNECTED(15 downto 0),
      DRDY => NLW_mmcme4_adv_inst_DRDY_UNCONNECTED,
      DWE => '0',
      LOCKED => \^locked\,
      PSCLK => '0',
      PSDONE => NLW_mmcme4_adv_inst_PSDONE_UNCONNECTED,
      PSEN => '0',
      PSINCDEC => '0',
      PWRDWN => '0',
      RST => reset
    );
\seq_reg1_reg[0]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_adc_cnv_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => \^locked\,
      Q => seq_reg1(0)
    );
\seq_reg1_reg[1]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_adc_cnv_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg1(0),
      Q => seq_reg1(1)
    );
\seq_reg1_reg[2]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_adc_cnv_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg1(1),
      Q => seq_reg1(2)
    );
\seq_reg1_reg[3]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_adc_cnv_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg1(2),
      Q => seq_reg1(3)
    );
\seq_reg1_reg[4]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_adc_cnv_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg1(3),
      Q => seq_reg1(4)
    );
\seq_reg1_reg[5]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_adc_cnv_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg1(4),
      Q => seq_reg1(5)
    );
\seq_reg1_reg[6]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_adc_cnv_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg1(5),
      Q => seq_reg1(6)
    );
\seq_reg1_reg[7]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_adc_cnv_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg1(6),
      Q => seq_reg1(7)
    );
\seq_reg2_reg[0]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_adc_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => \^locked\,
      Q => seq_reg2(0)
    );
\seq_reg2_reg[1]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_adc_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg2(0),
      Q => seq_reg2(1)
    );
\seq_reg2_reg[2]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_adc_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg2(1),
      Q => seq_reg2(2)
    );
\seq_reg2_reg[3]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_adc_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg2(2),
      Q => seq_reg2(3)
    );
\seq_reg2_reg[4]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_adc_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg2(3),
      Q => seq_reg2(4)
    );
\seq_reg2_reg[5]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_adc_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg2(4),
      Q => seq_reg2(5)
    );
\seq_reg2_reg[6]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_adc_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg2(5),
      Q => seq_reg2(6)
    );
\seq_reg2_reg[7]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_adc_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg2(6),
      Q => seq_reg2(7)
    );
\seq_reg3_reg[0]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_625_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => \^locked\,
      Q => seq_reg3(0)
    );
\seq_reg3_reg[1]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_625_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg3(0),
      Q => seq_reg3(1)
    );
\seq_reg3_reg[2]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_625_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg3(1),
      Q => seq_reg3(2)
    );
\seq_reg3_reg[3]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_625_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg3(2),
      Q => seq_reg3(3)
    );
\seq_reg3_reg[4]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_625_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg3(3),
      Q => seq_reg3(4)
    );
\seq_reg3_reg[5]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_625_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg3(4),
      Q => seq_reg3(5)
    );
\seq_reg3_reg[6]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_625_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg3(5),
      Q => seq_reg3(6)
    );
\seq_reg3_reg[7]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_625_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg3(6),
      Q => seq_reg3(7)
    );
\seq_reg4_reg[0]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_50_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => \^locked\,
      Q => seq_reg4(0)
    );
\seq_reg4_reg[1]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_50_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg4(0),
      Q => seq_reg4(1)
    );
\seq_reg4_reg[2]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_50_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg4(1),
      Q => seq_reg4(2)
    );
\seq_reg4_reg[3]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_50_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg4(2),
      Q => seq_reg4(3)
    );
\seq_reg4_reg[4]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_50_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg4(3),
      Q => seq_reg4(4)
    );
\seq_reg4_reg[5]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_50_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg4(4),
      Q => seq_reg4(5)
    );
\seq_reg4_reg[6]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_50_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg4(5),
      Q => seq_reg4(6)
    );
\seq_reg4_reg[7]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk_50_mmcm_adc_en_clk,
      CE => '1',
      CLR => reset,
      D => seq_reg4(6),
      Q => seq_reg4(7)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity mmcm_adc is
  port (
    clk_adc_cnv : out STD_LOGIC;
    clk_adc : out STD_LOGIC;
    clk_625 : out STD_LOGIC;
    clk_50 : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of mmcm_adc : entity is true;
end mmcm_adc;

architecture STRUCTURE of mmcm_adc is
begin
inst: entity work.mmcm_adc_mmcm_adc_clk_wiz
     port map (
      clk_50 => clk_50,
      clk_625 => clk_625,
      clk_adc => clk_adc,
      clk_adc_cnv => clk_adc_cnv,
      clk_in1 => clk_in1,
      locked => locked,
      reset => reset
    );
end STRUCTURE;
