# ----------------------------------------------------------------------------------
# Copyright (c) 2021 by Enclustra GmbH, Switzerland.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this hardware, software, firmware, and associated documentation files (the
# "Product"), to deal in the Product without restriction, including without
# limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Product, and to permit persons to whom the
# Product is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Product.
#
# THE PRODUCT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# PRODUCT OR THE USE OR OTHER DEALINGS IN THE PRODUCT.
# ----------------------------------------------------------------------------------

set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]

# ----------------------------------------------------------------------------------
# Important! Do not remove this constraint!
# This property ensures that all unused pins are set to high impedance.
# If the constraint is removed, all unused pins have to be set to HiZ in the top level file.
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]
# ----------------------------------------------------------------------------------

# J800

set_property -dict {PACKAGE_PIN A12 IOSTANDARD LVCMOS25 PULLUP TRUE} [get_ports {SW1[1]}]
set_property -dict {PACKAGE_PIN A11 IOSTANDARD LVCMOS25 PULLUP TRUE} [get_ports {SW1[2]}]
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS25 PULLUP TRUE} [get_ports {SW1[3]}]
set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS25 PULLUP TRUE} [get_ports {SW1[4]}]
set_property -dict {PACKAGE_PIN B10 IOSTANDARD LVCMOS25 PULLUP TRUE} [get_ports {SW1[5]}]
set_property -dict {PACKAGE_PIN A10 IOSTANDARD LVCMOS25 PULLUP TRUE} [get_ports {SW1[6]}]

set_property -dict {PACKAGE_PIN E14 IOSTANDARD LVCMOS33 } [get_ports {DATA_ModPRSn}]
set_property -dict {PACKAGE_PIN E13 IOSTANDARD LVCMOS33 } [get_ports {DATA_INTn}]

set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33 } [get_ports {TI_ModPRSn}]
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33 } [get_ports {TI_INTn}]

set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33 } [get_ports {DATA_RESETn}]
set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33 } [get_ports {DATA_ModSELn}]

set_property -dict {PACKAGE_PIN B14 IOSTANDARD LVCMOS33 } [get_ports {TI_RESETn}]
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33 } [get_ports {TI_ModSELn}]

set_property -dict {PACKAGE_PIN B13 IOSTANDARD LVCMOS33} [get_ports {LED_DSP[3]}]
set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports {LED_DSP[2]}]
set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS33} [get_ports {LED_DSP[1]}]
set_property -dict {PACKAGE_PIN H13 IOSTANDARD LVCMOS33} [get_ports {LED_DSP[0]}]

# Incompatible with normal LVDS, in HD bank
set_property -dict {PACKAGE_PIN G10 IOSTANDARD LVCMOS25} [get_ports {EXT_LVDS_IN_P}]
set_property -dict {PACKAGE_PIN F10 IOSTANDARD LVCMOS25} [get_ports {EXT_LVDS_IN_N}]
set_property -dict {PACKAGE_PIN H12 IOSTANDARD LVCMOS25} [get_ports {EXT_LVDS_OUT_P}]
set_property -dict {PACKAGE_PIN G11 IOSTANDARD LVCMOS25} [get_ports {EXT_LVDS_OUT_N}]
#set_property -dict {PACKAGE_PIN AJ5 IOSTANDARD IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {EXT_LVDS_IN_P}]
#set_property -dict {PACKAGE_PIN AK5 IOSTANDARD IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {EXT_LVDS_IN_N}]
#set_property -dict {PACKAGE_PIN AF6 IOSTANDARD IOSTANDARD LVDS} [get_ports {EXT_LVDS_OUT_P}]
#set_property -dict {PACKAGE_PIN AF5 IOSTANDARD IOSTANDARD LVDS} [get_ports {EXT_LVDS_OUT_N}]

set_property -dict {PACKAGE_PIN G13 IOSTANDARD LVCMOS33} [get_ports {TTL_INPUT[0]}]
set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33} [get_ports {TTL_INPUT[1]}]

set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports {LMK_UWIRE_CLK}]
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports {LMK_UWIRE_DATA}]
set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS33} [get_ports {LMK_UWIRE_LE}]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {LMK_STAT_LD}]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {LMK_STAT_CLKin0}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {LMK_STAT_CLKin1}]
set_property -dict {PACKAGE_PIN K14 IOSTANDARD LVCMOS33} [get_ports {LMK_STAT_CLKin2_SYNC}]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {LMK_STAT_HOLDOVER}]

set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS25} [get_ports {ADC_TESTPAT}]
set_property -dict {PACKAGE_PIN K12 IOSTANDARD LVCMOS25} [get_ports {SEL_TI_MGTn}]
set_property -dict {PACKAGE_PIN AH11 IOSTANDARD LVCMOS18} [get_ports {ADC_PDn}]

set_property -dict {PACKAGE_PIN J10 IOSTANDARD LVCMOS25} [get_ports {ADC_CNVT_SEL}]

# on ADC_V1, TACH1 is J11, LVCMOS25, SEL_TI_MGTe is AJ1, LVCMOS18
set_property -dict {PACKAGE_PIN J11 IOSTANDARD LVCMOS25} [get_ports {TACH1}]
set_property -dict {PACKAGE_PIN AJ1 IOSTANDARD LVCMOS18} [get_ports {SEL_TI_MGTe}]
# on ADC_v2, TACH1 is AJ1, LVCMOS18, SEL_TI_MGTe is removed
#set_property -dict {PACKAGE_PIN J11 IOSTANDARD LVCMOS25} [get_ports {SEL_TI_MGTe}]
#set_property -dict {PACKAGE_PIN AJ1 IOSTANDARD LVCMOS18} [get_ports {TACH1}]
set_property -dict {PACKAGE_PIN H11 IOSTANDARD LVCMOS25} [get_ports {TACH2}]
set_property -dict {PACKAGE_PIN J12 IOSTANDARD LVCMOS25} [get_ports {TACH3}]

set_property -dict {PACKAGE_PIN W7  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_P[12]}]
set_property -dict {PACKAGE_PIN W6  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_N[12]}]
set_property -dict {PACKAGE_PIN T1  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_P[12]}]
set_property -dict {PACKAGE_PIN U1  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_N[12]}]
set_property -dict {PACKAGE_PIN W5  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_P[12]}]
set_property -dict {PACKAGE_PIN Y5  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_N[12]}]

set_property -dict {PACKAGE_PIN V4  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_P[5]}]
set_property -dict {PACKAGE_PIN W4  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_N[5]}]
set_property -dict {PACKAGE_PIN U5  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_P[5]}]
set_property -dict {PACKAGE_PIN U4  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_N[5]}]
set_property -dict {PACKAGE_PIN U7  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_P[5]}]
set_property -dict {PACKAGE_PIN U6  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_N[5]}]

set_property -dict {PACKAGE_PIN U9  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_P[4]}]
set_property -dict {PACKAGE_PIN V9  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_N[4]}]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_P[4]}]
set_property -dict {PACKAGE_PIN U10 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_N[4]}]
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_P[4]}]
set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_N[4]}]

set_property -dict {PACKAGE_PIN W11 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_P[3]}]
set_property -dict {PACKAGE_PIN W10 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_N[3]}]
set_property -dict {PACKAGE_PIN U8  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_P[3]}]
set_property -dict {PACKAGE_PIN V8  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_N[3]}]
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_P[3]}]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_N[3]}]

set_property -dict {PACKAGE_PIN P11 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_P[2]}]
set_property -dict {PACKAGE_PIN P10 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_N[2]}]
set_property -dict {PACKAGE_PIN N10 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_P[2]}]
set_property -dict {PACKAGE_PIN M10 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_N[2]}]
set_property -dict {PACKAGE_PIN N12 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_P[2]}]
set_property -dict {PACKAGE_PIN M12 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_N[2]}]

set_property -dict {PACKAGE_PIN Y9  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_P[1]}]
set_property -dict {PACKAGE_PIN Y8  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_N[1]}]
set_property -dict {PACKAGE_PIN L12 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_P[1]}]
set_property -dict {PACKAGE_PIN L11 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_N[1]}]
set_property -dict {PACKAGE_PIN L10 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_P[1]}]
set_property -dict {PACKAGE_PIN K10 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_N[1]}]

set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_P[11]}]
set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_N[11]}]
set_property -dict {PACKAGE_PIN AB8  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_P[11]}]
set_property -dict {PACKAGE_PIN AC8  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_N[11]}]
set_property -dict {PACKAGE_PIN AA8  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_P[11]}]
set_property -dict {PACKAGE_PIN AA7  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_N[11]}]

set_property -dict {PACKAGE_PIN AB9  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_P[10]}]
set_property -dict {PACKAGE_PIN AC9  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_N[10]}]
set_property -dict {PACKAGE_PIN AD9  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_P[10]}]
set_property -dict {PACKAGE_PIN AE9  IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_N[10]}]
set_property -dict {PACKAGE_PIN AD10 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_P[10]}]
set_property -dict {PACKAGE_PIN AE10 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_N[10]}]

set_property -dict {PACKAGE_PIN AD4 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_P[9]}]
set_property -dict {PACKAGE_PIN AE4 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_N[9]}]
set_property -dict {PACKAGE_PIN AD5 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_P[9]}]
set_property -dict {PACKAGE_PIN AE5 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_N[9]}]
set_property -dict {PACKAGE_PIN AC4 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_N[9]}]
set_property -dict {PACKAGE_PIN AB4 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_P[9]}]

set_property -dict {PACKAGE_PIN AA6 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_P[8]}]
set_property -dict {PACKAGE_PIN AA5 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_N[8]}]
set_property -dict {PACKAGE_PIN AE3 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_P[8]}]
set_property -dict {PACKAGE_PIN AE2 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_N[8]}]
set_property -dict {PACKAGE_PIN AB6 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_P[8]}]
set_property -dict {PACKAGE_PIN AB5 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_N[8]}]

set_property -dict {PACKAGE_PIN AC2 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_P[7]}]
set_property -dict {PACKAGE_PIN AD2 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_N[7]}]
set_property -dict {PACKAGE_PIN AC1 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_P[7]}]
set_property -dict {PACKAGE_PIN AD1 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_N[7]}]
set_property -dict {PACKAGE_PIN AB3 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_P[7]}]
set_property -dict {PACKAGE_PIN AC3 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_N[7]}]

set_property -dict {PACKAGE_PIN AC6 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_P[6]}]
set_property -dict {PACKAGE_PIN AD6 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_N[6]}]
set_property -dict {PACKAGE_PIN AA1 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_P[6]}]
set_property -dict {PACKAGE_PIN AB1 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_N[6]}]
set_property -dict {PACKAGE_PIN AA3 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_P[6]}]
set_property -dict {PACKAGE_PIN AA2 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_N[6]}]

# set_property -dict {PACKAGE_PIN V7 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {SOM_IN_CLK_P[0]}]
# set_property -dict {PACKAGE_PIN V6 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {SOM_IN_CLK_N[0]}]

# set_property -dict {PACKAGE_PIN AC7 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {SOM_IN_CLK_P[1]}]
# set_property -dict {PACKAGE_PIN AD7 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {SOM_IN_CLK_N[1]}]

set_property -dict {PACKAGE_PIN AF10 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {LVDS_NIM_P[0]}]
set_property -dict {PACKAGE_PIN AG10 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {LVDS_NIM_N[0]}]

set_property -dict {PACKAGE_PIN AF8 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {LVDS_NIM_P[1]}]
set_property -dict {PACKAGE_PIN AF7 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {LVDS_NIM_N[1]}]

set_property -dict {PACKAGE_PIN AG8 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {RX_TI_SYNC_P}]
set_property -dict {PACKAGE_PIN AH8 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {RX_TI_SYNC_N}]

set_property -dict {PACKAGE_PIN AH9 IOSTANDARD LVDS} [get_ports {SOM_OUT_CLKA_P}]
set_property -dict {PACKAGE_PIN AJ9 IOSTANDARD LVDS} [get_ports {SOM_OUT_CLKA_N}]

set_property -dict {PACKAGE_PIN AK9 IOSTANDARD LVDS} [get_ports {SOM_OUT_CLKB_P}]
set_property -dict {PACKAGE_PIN AK8 IOSTANDARD LVDS} [get_ports {SOM_OUT_CLKB_N}]

set_property -dict {PACKAGE_PIN AH12 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_P[15]}]
set_property -dict {PACKAGE_PIN AJ12 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_N[15]}]
set_property -dict {PACKAGE_PIN AJ11 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_P[15]}]
set_property -dict {PACKAGE_PIN AK11 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_N[15]}]
set_property -dict {PACKAGE_PIN AK13 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_P[15]}]
set_property -dict {PACKAGE_PIN AK12 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_N[15]}]

set_property -dict {PACKAGE_PIN AH7 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_P[16]}]
set_property -dict {PACKAGE_PIN AJ7 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_N[16]}]
set_property -dict {PACKAGE_PIN AG13 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_P[16]}]
set_property -dict {PACKAGE_PIN AH13 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_N[16]}]
set_property -dict {PACKAGE_PIN AF11 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_P[16]}]
set_property -dict {PACKAGE_PIN AG11 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_N[16]}]

set_property -dict {PACKAGE_PIN AE13 IOSTANDARD LVDS} [get_ports {SOM_OUT_CNVB_P}]
set_property -dict {PACKAGE_PIN AF13 IOSTANDARD LVDS} [get_ports {SOM_OUT_CNVB_N}]

set_property -dict {PACKAGE_PIN AB13 IOSTANDARD LVDS} [get_ports {SOM_OUT_CNVA_P}]
set_property -dict {PACKAGE_PIN AC13 IOSTANDARD LVDS} [get_ports {SOM_OUT_CNVA_N}]

set_property -dict {PACKAGE_PIN AF2 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_P[13]}]
set_property -dict {PACKAGE_PIN AF1 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_N[13]}]
set_property -dict {PACKAGE_PIN AF3 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_P[13]}]
set_property -dict {PACKAGE_PIN AG3 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_N[13]}]
set_property -dict {PACKAGE_PIN AG1 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_P[13]}]
set_property -dict {PACKAGE_PIN AH1 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_N[13]}]

set_property -dict {PACKAGE_PIN AG6 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {CLNR_OSC_P}]
set_property -dict {PACKAGE_PIN AG5 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {CLNR_OSC_N}]

set_property -dict {PACKAGE_PIN AH3 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_P[14]}]
set_property -dict {PACKAGE_PIN AH2 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DCO_N[14]}]
set_property -dict {PACKAGE_PIN AK4 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_P[14]}]
set_property -dict {PACKAGE_PIN AK3 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DA_N[14]}]
set_property -dict {PACKAGE_PIN AH4 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_P[14]}]
set_property -dict {PACKAGE_PIN AJ4 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {ADC_DB_N[14]}]

set_property -dict {PACKAGE_PIN AH6 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {FPGA_CLK250_TD_P}]
set_property -dict {PACKAGE_PIN AJ6 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {FPGA_CLK250_TD_N}]

# I2C_PL
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS18} [get_ports {I2C_SCL_PL}]
set_property -dict {PACKAGE_PIN Y7 IOSTANDARD LVCMOS18} [get_ports {I2C_SDA_PL}]

# LED
set_property -dict {PACKAGE_PIN AE8 IOSTANDARD LVCMOS18} [get_ports {LED2_N_PWR_SYNC}]

# MGT
# set_property -dict {PACKAGE_PIN J8} [get_ports {MGT_B229_REFCLK1_P}]
# set_property -dict {PACKAGE_PIN J7} [get_ports {MGT_B229_REFCLK1_N}]
set_property -dict {PACKAGE_PIN N8} [get_ports {MGT_B228_REFCLK1_P}]
set_property -dict {PACKAGE_PIN N7} [get_ports {MGT_B228_REFCLK1_N}]

# set_property -dict {PACKAGE_PIN G8} [get_ports {MGT_B230_REFCLK0_P}]
# set_property -dict {PACKAGE_PIN G7} [get_ports {MGT_B230_REFCLK0_N}]

# set_property -dict {PACKAGE_PIN D6} [get_ports {MGT_B230_TX0_P}]
# set_property -dict {PACKAGE_PIN D5} [get_ports {MGT_B230_TX0_N}]
# set_property -dict {PACKAGE_PIN D2} [get_ports {MGT_B230_RX0_P}]
# set_property -dict {PACKAGE_PIN D1} [get_ports {MGT_B230_RX0_N}]

# set_property -dict {PACKAGE_PIN C8} [get_ports {MGT_B230_TX1_P}]
# set_property -dict {PACKAGE_PIN C7} [get_ports {MGT_B230_TX1_N}]
# set_property -dict {PACKAGE_PIN C4} [get_ports {MGT_B230_RX1_P}]
# set_property -dict {PACKAGE_PIN C3} [get_ports {MGT_B230_RX1_N}]

# Not used in this design
### set_property -dict {PACKAGE_PIN B6} [get_ports {MGT_B230_TX2_P}]
### set_property -dict {PACKAGE_PIN B5} [get_ports {MGT_B230_TX2_N}]
### set_property -dict {PACKAGE_PIN B2} [get_ports {MGT_B230_RX2_P}]
### set_property -dict {PACKAGE_PIN B1} [get_ports {MGT_B230_RX2_N}]
###
### set_property -dict {PACKAGE_PIN A8} [get_ports {MGT_B230_TX3_P}]
### set_property -dict {PACKAGE_PIN A7} [get_ports {MGT_B230_TX3_N}]
### set_property -dict {PACKAGE_PIN A4} [get_ports {MGT_B230_RX3_P}]
### set_property -dict {PACKAGE_PIN A3} [get_ports {MGT_B230_RX3_N}]

# set_property -dict {PACKAGE_PIN J4} [get_ports {MGT_B229_TX0_P}]
# set_property -dict {PACKAGE_PIN J3} [get_ports {MGT_B229_TX0_N}]
# set_property -dict {PACKAGE_PIN K2} [get_ports {MGT_B229_RX0_P}]
# set_property -dict {PACKAGE_PIN K1} [get_ports {MGT_B229_RX0_N}]
#
# set_property -dict {PACKAGE_PIN H6} [get_ports {MGT_B229_TX1_P}]
# set_property -dict {PACKAGE_PIN H5} [get_ports {MGT_B229_TX1_N}]
# set_property -dict {PACKAGE_PIN H2} [get_ports {MGT_B229_RX1_P}]
# set_property -dict {PACKAGE_PIN H1} [get_ports {MGT_B229_RX1_N}]
#
# set_property -dict {PACKAGE_PIN F6} [get_ports {MGT_B229_TX2_P}]
# set_property -dict {PACKAGE_PIN F5} [get_ports {MGT_B229_TX2_N}]
# set_property -dict {PACKAGE_PIN G4} [get_ports {MGT_B229_RX2_P}]
# set_property -dict {PACKAGE_PIN G3} [get_ports {MGT_B229_RX2_N}]
#
# set_property -dict {PACKAGE_PIN E4} [get_ports {MGT_B229_TX3_P}]
# set_property -dict {PACKAGE_PIN E3} [get_ports {MGT_B229_TX3_N}]
# set_property -dict {PACKAGE_PIN F2} [get_ports {MGT_B229_RX3_P}]
# set_property -dict {PACKAGE_PIN F1} [get_ports {MGT_B229_RX3_N}]
#
set_property -dict {PACKAGE_PIN P6} [get_ports {MGT_B228_TX0_P}]
set_property -dict {PACKAGE_PIN P5} [get_ports {MGT_B228_TX0_N}]
set_property -dict {PACKAGE_PIN R4} [get_ports {MGT_B228_RX0_P}]
set_property -dict {PACKAGE_PIN R3} [get_ports {MGT_B228_RX0_N}]
#
# set_property -dict {PACKAGE_PIN N4} [get_ports {MGT_B228_TX1_P}]
# set_property -dict {PACKAGE_PIN N3} [get_ports {MGT_B228_TX1_N}]
# set_property -dict {PACKAGE_PIN P2} [get_ports {MGT_B228_RX1_P}]
# set_property -dict {PACKAGE_PIN P1} [get_ports {MGT_B228_RX1_N}]
#
# set_property -dict {PACKAGE_PIN M6} [get_ports {MGT_B228_TX2_P}]
# set_property -dict {PACKAGE_PIN M5} [get_ports {MGT_B228_TX2_N}]
# set_property -dict {PACKAGE_PIN M2} [get_ports {MGT_B228_RX2_P}]
# set_property -dict {PACKAGE_PIN M1} [get_ports {MGT_B228_RX2_N}]
#
# set_property -dict {PACKAGE_PIN K6} [get_ports {MGT_B228_TX3_P}]
# set_property -dict {PACKAGE_PIN K5} [get_ports {MGT_B228_TX3_N}]
# set_property -dict {PACKAGE_PIN L4} [get_ports {MGT_B228_RX3_P}]
# set_property -dict {PACKAGE_PIN L3} [get_ports {MGT_B228_RX3_N}]


# Fix compilation issues with SOM_IN_CLKs
# set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets diff_som_in_clk0/O]
# set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets diff_som_in_clk1/O]
# End fix

# Fix for IDELAY blocks in moller TI causing issue with fixed IDELAY blocks in ADC subsystem
set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports ADC_DB_P[16]]
