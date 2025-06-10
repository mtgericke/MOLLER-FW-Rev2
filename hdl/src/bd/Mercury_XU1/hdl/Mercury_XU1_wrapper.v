//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
//Date        : Mon Jun  9 23:48:25 2025
//Host        : davmtest0 running 64-bit Ubuntu 18.04.6 LTS
//Command     : generate_target Mercury_XU1_wrapper.bd
//Design      : Mercury_XU1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module Mercury_XU1_wrapper
   (CLK250,
    CLK625,
    CLKPrg,
    CLKREFO_N,
    CLKREFO_P,
    CLK_IBERT,
    GENINP,
    GENOUTP,
    PHY_RESET,
    SWM,
    TCSOUT,
    TI1RX_N,
    TI1RX_P,
    TI1SYNCRX_N,
    TI1SYNCRX_P,
    TI1SYNCTX_N,
    TI1SYNCTX_P,
    TI1TX_N,
    TI1TX_P,
    TICLK_N,
    TICLK_P,
    TI_C2H_tdata,
    TI_C2H_tkeep,
    TI_C2H_tlast,
    TI_C2H_tready,
    TI_C2H_tvalid,
    adc_ctrl_ch_disable,
    adc_ctrl_clear_counters,
    adc_ctrl_ena,
    adc_ctrl_power_down,
    adc_ctrl_sample_rate,
    adc_ctrl_testpattern,
    adc_delay_value,
    adc_fifo_tdata,
    adc_fifo_tlast,
    adc_fifo_tready,
    adc_fifo_tvalid,
    adc_load_value,
    adc_test_data_bad_dco_counter,
    adc_test_data_bad_pattern_counter,
    clk_125,
    freq_osc_value,
    freq_som0_value,
    freq_som1_value,
    freq_td_value,
    revision_value,
    rst_125_n,
    run_fifo_tdata,
    run_fifo_tlast,
    run_fifo_tready,
    run_fifo_tvalid,
    sfp_gem_rxn,
    sfp_gem_rxp,
    sfp_gem_txn,
    sfp_gem_txp,
    sfp_refclk_clk_n,
    sfp_refclk_clk_p,
    sfp_signal_detect,
    soc_in_reset,
    status_adc_train_done,
    status_clk_holdover,
    status_clk_lockdetect,
    stream_ctrl_ch0,
    stream_ctrl_ch1,
    stream_ctrl_enable,
    stream_ctrl_num_samples,
    stream_ctrl_rate_div);
  input CLK250;
  input CLK625;
  input CLKPrg;
  output CLKREFO_N;
  output CLKREFO_P;
  input CLK_IBERT;
  input [16:1]GENINP;
  output [16:1]GENOUTP;
  input [0:0]PHY_RESET;
  inout [8:1]SWM;
  output [16:1]TCSOUT;
  input TI1RX_N;
  input TI1RX_P;
  input TI1SYNCRX_N;
  input TI1SYNCRX_P;
  output TI1SYNCTX_N;
  output TI1SYNCTX_P;
  output TI1TX_N;
  output TI1TX_P;
  input TICLK_N;
  input TICLK_P;
  output [63:0]TI_C2H_tdata;
  output [7:0]TI_C2H_tkeep;
  output TI_C2H_tlast;
  input TI_C2H_tready;
  output TI_C2H_tvalid;
  output [15:0]adc_ctrl_ch_disable;
  output [0:0]adc_ctrl_clear_counters;
  output [0:0]adc_ctrl_ena;
  output [0:0]adc_ctrl_power_down;
  output [7:0]adc_ctrl_sample_rate;
  output [0:0]adc_ctrl_testpattern;
  input [143:0]adc_delay_value;
  input [63:0]adc_fifo_tdata;
  input adc_fifo_tlast;
  output adc_fifo_tready;
  input adc_fifo_tvalid;
  output [143:0]adc_load_value;
  input [255:0]adc_test_data_bad_dco_counter;
  input [255:0]adc_test_data_bad_pattern_counter;
  input clk_125;
  input [31:0]freq_osc_value;
  input [31:0]freq_som0_value;
  input [31:0]freq_som1_value;
  input [31:0]freq_td_value;
  input [31:0]revision_value;
  input rst_125_n;
  input [63:0]run_fifo_tdata;
  input run_fifo_tlast;
  output run_fifo_tready;
  input run_fifo_tvalid;
  input sfp_gem_rxn;
  input sfp_gem_rxp;
  output sfp_gem_txn;
  output sfp_gem_txp;
  input sfp_refclk_clk_n;
  input sfp_refclk_clk_p;
  input sfp_signal_detect;
  output soc_in_reset;
  input [0:0]status_adc_train_done;
  input [0:0]status_clk_holdover;
  input [0:0]status_clk_lockdetect;
  output [3:0]stream_ctrl_ch0;
  output [3:0]stream_ctrl_ch1;
  output [0:0]stream_ctrl_enable;
  output [15:0]stream_ctrl_num_samples;
  output [6:0]stream_ctrl_rate_div;

  wire CLK250;
  wire CLK625;
  wire CLKPrg;
  wire CLKREFO_N;
  wire CLKREFO_P;
  wire CLK_IBERT;
  wire [16:1]GENINP;
  wire [16:1]GENOUTP;
  wire [0:0]PHY_RESET;
  wire [8:1]SWM;
  wire [16:1]TCSOUT;
  wire TI1RX_N;
  wire TI1RX_P;
  wire TI1SYNCRX_N;
  wire TI1SYNCRX_P;
  wire TI1SYNCTX_N;
  wire TI1SYNCTX_P;
  wire TI1TX_N;
  wire TI1TX_P;
  wire TICLK_N;
  wire TICLK_P;
  wire [63:0]TI_C2H_tdata;
  wire [7:0]TI_C2H_tkeep;
  wire TI_C2H_tlast;
  wire TI_C2H_tready;
  wire TI_C2H_tvalid;
  wire [15:0]adc_ctrl_ch_disable;
  wire [0:0]adc_ctrl_clear_counters;
  wire [0:0]adc_ctrl_ena;
  wire [0:0]adc_ctrl_power_down;
  wire [7:0]adc_ctrl_sample_rate;
  wire [0:0]adc_ctrl_testpattern;
  wire [143:0]adc_delay_value;
  wire [63:0]adc_fifo_tdata;
  wire adc_fifo_tlast;
  wire adc_fifo_tready;
  wire adc_fifo_tvalid;
  wire [143:0]adc_load_value;
  wire [255:0]adc_test_data_bad_dco_counter;
  wire [255:0]adc_test_data_bad_pattern_counter;
  wire clk_125;
  wire [31:0]freq_osc_value;
  wire [31:0]freq_som0_value;
  wire [31:0]freq_som1_value;
  wire [31:0]freq_td_value;
  wire [31:0]revision_value;
  wire rst_125_n;
  wire [63:0]run_fifo_tdata;
  wire run_fifo_tlast;
  wire run_fifo_tready;
  wire run_fifo_tvalid;
  wire sfp_gem_rxn;
  wire sfp_gem_rxp;
  wire sfp_gem_txn;
  wire sfp_gem_txp;
  wire sfp_refclk_clk_n;
  wire sfp_refclk_clk_p;
  wire sfp_signal_detect;
  wire soc_in_reset;
  wire [0:0]status_adc_train_done;
  wire [0:0]status_clk_holdover;
  wire [0:0]status_clk_lockdetect;
  wire [3:0]stream_ctrl_ch0;
  wire [3:0]stream_ctrl_ch1;
  wire [0:0]stream_ctrl_enable;
  wire [15:0]stream_ctrl_num_samples;
  wire [6:0]stream_ctrl_rate_div;

  Mercury_XU1 Mercury_XU1_i
       (.CLK250(CLK250),
        .CLK625(CLK625),
        .CLKPrg(CLKPrg),
        .CLKREFO_N(CLKREFO_N),
        .CLKREFO_P(CLKREFO_P),
        .CLK_IBERT(CLK_IBERT),
        .GENINP(GENINP),
        .GENOUTP(GENOUTP),
        .PHY_RESET(PHY_RESET),
        .SWM(SWM),
        .TCSOUT(TCSOUT),
        .TI1RX_N(TI1RX_N),
        .TI1RX_P(TI1RX_P),
        .TI1SYNCRX_N(TI1SYNCRX_N),
        .TI1SYNCRX_P(TI1SYNCRX_P),
        .TI1SYNCTX_N(TI1SYNCTX_N),
        .TI1SYNCTX_P(TI1SYNCTX_P),
        .TI1TX_N(TI1TX_N),
        .TI1TX_P(TI1TX_P),
        .TICLK_N(TICLK_N),
        .TICLK_P(TICLK_P),
        .TI_C2H_tdata(TI_C2H_tdata),
        .TI_C2H_tkeep(TI_C2H_tkeep),
        .TI_C2H_tlast(TI_C2H_tlast),
        .TI_C2H_tready(TI_C2H_tready),
        .TI_C2H_tvalid(TI_C2H_tvalid),
        .adc_ctrl_ch_disable(adc_ctrl_ch_disable),
        .adc_ctrl_clear_counters(adc_ctrl_clear_counters),
        .adc_ctrl_ena(adc_ctrl_ena),
        .adc_ctrl_power_down(adc_ctrl_power_down),
        .adc_ctrl_sample_rate(adc_ctrl_sample_rate),
        .adc_ctrl_testpattern(adc_ctrl_testpattern),
        .adc_delay_value(adc_delay_value),
        .adc_fifo_tdata(adc_fifo_tdata),
        .adc_fifo_tlast(adc_fifo_tlast),
        .adc_fifo_tready(adc_fifo_tready),
        .adc_fifo_tvalid(adc_fifo_tvalid),
        .adc_load_value(adc_load_value),
        .adc_test_data_bad_dco_counter(adc_test_data_bad_dco_counter),
        .adc_test_data_bad_pattern_counter(adc_test_data_bad_pattern_counter),
        .clk_125(clk_125),
        .freq_osc_value(freq_osc_value),
        .freq_som0_value(freq_som0_value),
        .freq_som1_value(freq_som1_value),
        .freq_td_value(freq_td_value),
        .revision_value(revision_value),
        .rst_125_n(rst_125_n),
        .run_fifo_tdata(run_fifo_tdata),
        .run_fifo_tlast(run_fifo_tlast),
        .run_fifo_tready(run_fifo_tready),
        .run_fifo_tvalid(run_fifo_tvalid),
        .sfp_gem_rxn(sfp_gem_rxn),
        .sfp_gem_rxp(sfp_gem_rxp),
        .sfp_gem_txn(sfp_gem_txn),
        .sfp_gem_txp(sfp_gem_txp),
        .sfp_refclk_clk_n(sfp_refclk_clk_n),
        .sfp_refclk_clk_p(sfp_refclk_clk_p),
        .sfp_signal_detect(sfp_signal_detect),
        .soc_in_reset(soc_in_reset),
        .status_adc_train_done(status_adc_train_done),
        .status_clk_holdover(status_clk_holdover),
        .status_clk_lockdetect(status_clk_lockdetect),
        .stream_ctrl_ch0(stream_ctrl_ch0),
        .stream_ctrl_ch1(stream_ctrl_ch1),
        .stream_ctrl_enable(stream_ctrl_enable),
        .stream_ctrl_num_samples(stream_ctrl_num_samples),
        .stream_ctrl_rate_div(stream_ctrl_rate_div));
endmodule
