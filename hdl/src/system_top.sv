
module system_top
    import moller_regs_pkg::MOLLER_REVISION;
#(
    parameter NUM_ADC_CH = 16
)(
    input wire [6:1] SW1,

    input wire DATA_ModPRSn,    // Module presence, active low
    input wire DATA_INTn,       // Interrupt, active low (indicates fault)
    output wire DATA_RESETn,    // Reset, active low  (pulse for 10us)
    output wire DATA_ModSELn,   // Module select, enables I2C, active low

    input wire TI_ModPRSn,      // Module presence, active low
    input wire TI_INTn,         // Interrupt, active low (indicates fault)
    output wire TI_RESETn,      // Reset, active low (pulse for 10us)
    output wire TI_ModSELn,     // Module select, enables I2C, active low

    output wire [3:0] LED_DSP,  // 4 Red LEDs, vertically stacked

    output wire EXT_LVDS_IN_P, // 2.5V LVDS, may need to be used as 4 separate 2.5V inputs
    output wire EXT_LVDS_IN_N, // 2.5V LVDS, may need to be used as 4 separate 2.5V inputs

    output wire EXT_LVDS_OUT_P, // 2.5V LVDS, may need to be used as 4 separate 2.5V inputs
    output wire EXT_LVDS_OUT_N, // 2.5V LVDS, may need to be used as 4 separate 2.5V inputs

    input wire [1:0] TTL_INPUT,   // Galvanically isolated user-inputs via LEMO (Labelled TTL0/1)

    // LMK04816 clock cleaner pins
    output wire LMK_UWIRE_CLK,
    output wire LMK_UWIRE_DATA,
    output wire LMK_UWIRE_LE,
    output wire LMK_STAT_CLKin0, // acts as CLKin select
    output wire LMK_STAT_CLKin1, // acts as CLKin select
    output wire LMK_STAT_CLKin2_SYNC, // SYNC for clock cleaner
    input wire LMK_STAT_LD,  // MUXable, can be readback pin
    input wire LMK_STAT_HOLDOVER, // MUXable, can be readback pin

    output wire ADC_CNVT_SEL,
    output wire ADC_TESTPAT,
    output wire SEL_TI_MGTn,
    output wire SEL_TI_MGTe,  // does not exist on ADC_V2 boards
    output wire ADC_PDn,

    input wire [NUM_ADC_CH:1] ADC_DCO_P,
    input wire [NUM_ADC_CH:1] ADC_DCO_N,
    input wire [NUM_ADC_CH:1] ADC_DB_P,
    input wire [NUM_ADC_CH:1] ADC_DB_N,
    input wire [NUM_ADC_CH:1] ADC_DA_P,
    input wire [NUM_ADC_CH:1] ADC_DA_N,

    // @TODO: Output these for diagnostics
    input wire TACH3,
    input wire TACH2,
    input wire TACH1,

    // LEMO NIM Inputs, Labelled NIM0/1
    input wire [1:0] LVDS_NIM_P,
    input wire [1:0] LVDS_NIM_N,

    input wire RX_TI_SYNC_P,
    input wire RX_TI_SYNC_N,

    // Oscillator from clock cleaner, should be 125MHz
    input wire CLNR_OSC_P,
    input wire CLNR_OSC_N,

    // 250 MHz clock from LMK04816 CLK_OUT10
    input wire FPGA_CLK250_TD_P,
    input wire FPGA_CLK250_TD_N,

    // FPGA controlled ADC output clock for reading data from ADCs
    output wire SOM_OUT_CLKA_P,
    output wire SOM_OUT_CLKA_N,
    output wire SOM_OUT_CLKB_P,
    output wire SOM_OUT_CLKB_N,

    // FPGA controlled ADC start-of-conversion signal
    output wire SOM_OUT_CNVA_P,
    output wire SOM_OUT_CNVA_N,
    output wire SOM_OUT_CNVB_P,
    output wire SOM_OUT_CNVB_N,

    // I2C_PL
    inout wire I2C_SCL_PL,	// PS_I2C_SCL
    inout wire I2C_SDA_PL,	// PS_I2C_SDA

    // LED
    output wire LED2_N_PWR_SYNC, // leave this high-z

    // MGT ref clocks, needs to be set appropriately for chosen protocol
    // B228 will also be output the LVDS REF CLK Output LEMO
    input wire MGT_B228_REFCLK1_P,
    input wire MGT_B228_REFCLK1_N,

    // SFP
    output wire MGT_B228_TX0_P,
    output wire MGT_B228_TX0_N,
    input wire MGT_B228_RX0_P,
    input wire MGT_B228_RX0_N

    /*
    output wire MGT_B228_TX1_P,
    output wire MGT_B228_TX1_N,
    input wire MGT_B228_RX1_P,
    input wire MGT_B228_RX1_N
    */

    // input wire MGT_B229_REFCLK1_P,
    // input wire MGT_B229_REFCLK1_N,
    /*
    input wire MGT_B230_REFCLK0_P,
    input wire MGT_B230_REFCLK0_N,

    output wire MGT_B230_TX0_P,
    output wire MGT_B230_TX0_N,
    input wire MGT_B230_RX0_P,
    input wire MGT_B230_RX0_N
    */

    /*
    // DATA QSFP 10/100/1000/2500 ethernet
    output wire MGT_B229_TX0_P,
    output wire MGT_B229_TX0_N,
    input wire MGT_B229_RX0_P,
    input wire MGT_B229_RX0_N,

    output wire MGT_B229_TX1_P,
    output wire MGT_B229_TX1_N,
    input wire MGT_B229_RX1_P,
    input wire MGT_B229_RX1_N,

    output wire MGT_B229_TX2_P,
    output wire MGT_B229_TX2_N,
    input wire MGT_B229_RX2_P,
    input wire MGT_B229_RX2_N,

    output wire MGT_B229_TX3_P,
    output wire MGT_B229_TX3_N,
    input wire MGT_B229_RX3_P,
    input wire MGT_B229_RX3_N,



    output wire MGT_B228_TX2_P,
    output wire MGT_B228_TX2_N,
    input wire MGT_B228_RX2_P,
    input wire MGT_B228_RX2_N,

    output wire MGT_B228_TX3_P,
    output wire MGT_B228_TX3_N,
    input wire MGT_B228_RX3_P,
    input wire MGT_B228_RX3_N
    */
);

localparam CLOCK_FREQ = 125000000;
localparam CONVERT_CLOCK_FREQ = 250000000;
localparam CNV_CLOCK_PERIOD = 4;

reg [31:0] valid_count;

wire [1:0] nim_input;
// wire [2:1] ext_sig;
wire rx_ti_sync;
wire clnr_osc;
wire fpga_clk250_td;

wire adc_clk;
wire adc_convert;
wire adc_ready;

wire adc_data_valid;
wire [NUM_ADC_CH-1:0] adc_ch_valid;
wire signed [NUM_ADC_CH-1:0][17:0] adc_data;

wire [63:0] adc_fifo_tdata;
wire adc_fifo_tfirst;
wire adc_fifo_tlast;
wire adc_fifo_tvalid;
wire adc_fifo_tready;

wire [63:0] run_fifo_tdata;
wire run_fifo_tlast;
wire run_fifo_tvalid;
wire run_fifo_tready;

wire [63:0] ti_source_tdata;
wire ti_source_tlast;
wire ti_source_tready;
wire ti_source_tvalid;

wire [63:0] ti_fifo_tdata;
wire ti_fifo_tlast;
wire ti_fifo_tready;
wire ti_fifo_tvalid;

wire udp_tx_clk;

wire clk;
wire clk_625;
wire clk_50;
wire rst;
wire clk_convert;
wire rst_convert;
wire [63:0] ts_run; // 64 bit timestamp
wire [63:0] ts_data; // 64 bit timestamp associated with ADC convert

wire [3:0] stream_ch0;
wire [3:0] stream_ch1;
wire stream_ena;
wire [15:0] stream_num_samples;
wire [6:0] stream_rate_div;

wire [31:0] freq_osc;
wire [1:0][31:0] freq_som;
wire [31:0] freq_td;

wire soc_in_reset;
wire soc_ready = ~soc_in_reset;

wire [NUM_ADC_CH-1:0] ctrl_adc_ch_disable;
wire [NUM_ADC_CH-1:0][8:0] adc_ch_delay;
wire [NUM_ADC_CH-1:0][8:0] adc_ch_load;
wire ctrl_adc_ena;

wire ctrl_adc_testpat;
wire ctrl_adc_pwr_down;
wire ctrl_clear_counters;
wire adc_testpat;
wire adc_phase_adjust;
wire [55:0] adc_phase_error;
wire [7:0] ctrl_sample_rate;

wire [NUM_ADC_CH-1:0] dco;
wire [NUM_ADC_CH-1:0] da;
wire [NUM_ADC_CH-1:0] db;

wire [16:1] tcsout;
wire [16:1] genoutp;
wire [16:1] geninp;

wire [NUM_ADC_CH-1:0][15:0] bad_dco_counter;
wire [NUM_ADC_CH-1:0][15:0] bad_data_counter;

wire ext_lvds_out;
wire ext_lvds_in;

wire [3:0] led_output;

wire clock_sync;
wire block_trigger;
wire clock_reset;

assign I2C_SCL_PL = 1'bZ;
assign I2C_SDA_PL = 1'bZ;
assign LED2_N_PWR_SYNC = 1'bZ;

// set to clock_sync
//assign LMK_STAT_CLKin2_SYNC = 1'b1; // SYNC for clock cleaner
assign LMK_STAT_CLKin2_SYNC = {~clock_sync}; // SYNC for clock cleaner

assign ADC_PDn = ~ctrl_adc_pwr_down;
assign ADC_TESTPAT = ctrl_adc_testpat;
//assign LMK_STAT_CLKin0 = SW1[6];
//assign LMK_STAT_CLKin1 = SW1[5];
assign LMK_STAT_CLKin0 = (tcsout[15] == tcsout[14]) ? 1'b0 : 1'b1; // 00=>10, 01=>11, 10=>01, 11=>00
assign LMK_STAT_CLKin1 = (tcsout[15] == 1'b0)? 1'b1 : 1'b0; 

assign SEL_TI_MGTn = (SW1[1] == 1'b1) ? 1'bZ : 1'b0; // 3V3 pullup on pin exceeds pins 2V5 IO voltage, infer open-drain buffer
// SEL_TI_MGTe does not exist on ADC_V2 board, 
assign SEL_TI_MGTe = (SW1[1] == 1'b1) ? 1'bZ : 1'b0; // 3V3 pullup on pin exceeds pins 2V5 IO voltage, infer open-drain buffer

// These are pulled up, so use output buffer to make open drain
assign TI_RESETn = 1'bZ; // let it get pulled high
assign TI_ModSELn = 1'bZ; // pulled high , must be if we have DATA_ModSELn low
assign DATA_RESETn = 1'bZ; // let it get pulled high
assign DATA_ModSELn = 1'bZ; // determines which QSFP slots i2c is used

assign ADC_CNVT_SEL = 1'b1;
assign clock_sync = { tcsout[9] & tcsout[6]};  // TCSOUT(9:7) = ClkSrc(7:5), to enable the commands to the ADC, Feb. 25, 2025
assign block_trigger = {tcsout[8] & genoutp[2]}; 
// rst is the OR of clock_reset and TI_reset (tcsout(3))
assign rst = (clock_reset | {tcsout[7] & tcsout[3]} );
// Connect the TTL_INPUT to TI_FP_trigger_In
assign geninp[2]  = {|TTL_INPUT};
assign geninp[10] = adc_fifo_tlast; // readout Acknowledge
assign geninp[1]  = {~adc_fifo_tready}; // assign fifo_not_ready as busy
//assign LED_DSP = (SW1[2]) ? led_output : { TTL_INPUT, nim_input };
assign LED_DSP = (SW1[2]) ? led_output : genoutp[12:9]; //{ TTL_INPUT, nim_input };

// Conversion Enable signal to ADCs
OBUFDS diff_som_out_cnv_a	(	.I(adc_convert),	    .O(SOM_OUT_CNVA_P),	.OB(SOM_OUT_CNVA_N)	);
OBUFDS diff_som_out_cnv_b	(	.I(adc_convert),  	    .O(SOM_OUT_CNVB_P),	.OB(SOM_OUT_CNVB_N)	);
OBUFDS diff_som_out_clk_a	(	.I(adc_clk),		    .O(SOM_OUT_CLKA_P),	.OB(SOM_OUT_CLKA_N)	);
OBUFDS diff_som_out_clk_b	(	.I(adc_clk),		    .O(SOM_OUT_CLKB_P),	.OB(SOM_OUT_CLKB_N)	);

// 16x ADC DCO/DB/DA signals
genvar n;
generate
for(n=0; n<NUM_ADC_CH; n=n+1) begin
    IBUFDS diff_dco(	.O(dco[n]), .I(ADC_DCO_P[n+1]), .IB(ADC_DCO_N[n+1]));
    IBUFDS diff_db(	    .O(db[n]),	.I(ADC_DB_P[n+1]),  .IB(ADC_DB_N[n+1]));
    IBUFDS diff_da(	    .O(da[n]),	.I(ADC_DA_P[n+1]),  .IB(ADC_DA_N[n+1]));
end
endgenerate

// Various Inputs
IBUFDS diff_lvds_nim0       (	.O(nim_input[0]),	    .I(LVDS_NIM_P[0]),      .IB(LVDS_NIM_N[0]) );
IBUFDS diff_lvds_nim1       (	.O(nim_input[1]),	    .I(LVDS_NIM_P[1]),      .IB(LVDS_NIM_N[1]) );
IBUFDS diff_clnr_osc        (	.O(clnr_osc),	        .I(CLNR_OSC_P),         .IB(CLNR_OSC_N) );        // 100 MHz VCXO
IBUFDS diff_fpga_250_td     (	.O(fpga_clk250_td),	    .I(FPGA_CLK250_TD_P),   .IB(FPGA_CLK250_TD_N) );  // Cleaner CLK_OUT10

//IBUFDS diff_ext_lvds_in     (	.O(ext_lvds_in),	    .I(EXT_LVDS_IN_P),      .IB(EXT_LVDS_IN_N) );
//OBUFDS diff_ext_lvds_out    (	.I(ext_lvds_out),	    .O(EXT_LVDS_OUT_P),     .OB(EXT_LVDS_OUT_N) );
//assignb ext_lvds_out = ext_lvds_in;
assign EXT_LVDS_OUT_P = genoutp[2]; // ReadoutTrigger EXT_LVDS_IN_P;
assign EXT_LVDS_OUT_N = {tcsout[3] | tcsout[12] | tcsout[11] };   // reset  EXT_LVDS_IN_N;
assign EXT_LVDS_IN_P = { tcsout[4] | tcsout[1] }; // ReadOut Acknowledge;
assign EXT_LVDS_IN_N = tcsout[13]; // genoutp[13]; // pulsed-trigger
// tcsout[13]=VmeReset[7]; tcsout[12]=Status[10] or Trigger1Ack; 
// tcsout[11]= status[8] or BlockReceived; tcsout[4]=status[7] or TI_Readout Acknoledgement

subsystem_clock clock_subsystem (
    .clk_osc_125( clnr_osc ), // oscillator 100MHz
    .clk_cc_250( fpga_clk250_td ), // clock cleaner 250 MHz output (TD_250)

    .soc_ready( soc_ready ),
    .cc_locked( LMK_STAT_HOLDOVER ),

    .clkin0_prediv( SW1[4:3] ),

    .clk_out_125( clk ),

    .clk_out_50( clk_50 ),
// output clock_reset
//    .rst_out_125( rst ),
    .rst_out_125( clock_reset ),

    .clk_out_250( clk_convert ),
    .rst_out_250( rst_convert ),

    .clk_625( clk_625 ),

    .LMK_UWIRE_CLK( LMK_UWIRE_CLK ),
    .LMK_UWIRE_DATA( LMK_UWIRE_DATA ),
    .LMK_UWIRE_LE( LMK_UWIRE_LE ),

    .fc_clk_som_in( freq_som ),
    .fc_clk_osc( freq_osc ),
    .fc_clk_td( freq_td )
);

wire led_ready;
subsystem_led #(
  .CLK_FREQ(CLOCK_FREQ),
  .INVERTED(1),
  .NUM_LED(4)
) led_subsystem (
    .clk( clk ),
    .rst( rst ),
    .led_in( {LMK_STAT_LD, LMK_STAT_HOLDOVER, ctrl_adc_testpat, adc_ready} ), // LED position order: top, middle top, middle bottom, bottom
    .led_out( led_output ),
    .ready( led_ready )
);

subsystem_timestamp #(
    .WIDTH(64)
) ts_subsystem (
    .clk( clk_convert ),
    .rst( rst_convert ),
    .load( 1'b0 ),
    .load_ts( 64'h0 ),
    .ts( ts_run )
);

subsystem_adc #(
    .NUM_ADC( NUM_ADC_CH ),
    .CLK_CONVERT_PERIOD( CNV_CLOCK_PERIOD )
) adc_subsystem(
    .rst(rst),
    .clk(clk),
    .clk_convert(clk_convert), // 2x clk, used for ADC CLK and ADC CONVERT signals

    .reset_counters( ctrl_clear_counters ),

    .convert( 1'b1 ),
    .sample_rate( ctrl_sample_rate ),

    .in_ts( ts_run ), //
    .convert_ready(),

    .bad_dco_counter( bad_dco_counter ),
    .bad_data_counter( bad_data_counter ),

    .adc_ch_delay(adc_ch_delay),
    .adc_ch_load(adc_ch_load),

    .adc_valid( adc_data_valid ), // indicates we can check q_ch_valid, *NOT* that all data is valid
    .adc_ts( ts_data ), // timestamp at time of conversion
    .adc_ch_valid( adc_ch_valid ),
    .adc_data( adc_data ),

    // Signals to LTC2387 ADCs
    .adc_testpat(ctrl_adc_testpat),
    .adc_convert(adc_convert),
    .adc_clock(adc_clk),
    .adc_dco(dco),
    .adc_da(da),
    .adc_db(db)
);

subsystem_stream stream_subsystem (
    .clk( clk ),
    .rst( rst ),
    .data(adc_data),
    .valid(adc_data_valid),
    .timestamp( ts_data ),
    .block( {TTL_INPUT, 1'b0} ),
    .ena( stream_ena ),

    .ch0_sel( stream_ch0 ),
    .ch1_sel( stream_ch1 ),
    .num_samples( stream_num_samples ),
    .rate_div( stream_rate_div ),

    .fifo_tdata( adc_fifo_tdata ),
    .fifo_tfirst( adc_fifo_tfirst ),
	.fifo_tlast( adc_fifo_tlast ),
	.fifo_tvalid( adc_fifo_tvalid ),
	.fifo_tready( adc_fifo_tready )
);

subsystem_capture #(
    .NUM_CH( NUM_ADC_CH ),
    .WIDTH( 18 )
) capture_subsystem (
    .clk( clk ),
    .rst( rst ),

    .ena( 1'b1 ),
// Change the start from TTL_INPUT to TI_trigger
//    .start( {|TTL_INPUT} ),
    .start( block_trigger ),

    .in_timestamp( ts_data ),
    .sample_valid( adc_data_valid ),
    .sample_ch_data( adc_data ),
    .sample_ch_valid( adc_ch_valid ),

    // streaming output
    .fifo_tdata( run_fifo_tdata ),
    .fifo_tvalid( run_fifo_tvalid ),
    .fifo_tlast( run_fifo_tlast ),
    .fifo_tready( run_fifo_tready )
);

always@(posedge clk) begin
	if(rst) begin
        valid_count <= 1;
	end else begin
        if(adc_data_valid) begin
            valid_count <= (valid_count < 8000) ? valid_count + 1'b1 : 8000;
        end else begin
            valid_count <= valid_count;
        end
	end
end

axi_stream_len_prepender #(
    .ID(8'hF0),
    .MAX_PKT_LEN(64),
    .DEPTH_BITS(8)
) ti_stream (
	.clk( clk ),
	.rst( rst ),
  	.ena( 1'b1 ),

  	.in_tdata( ti_source_tdata ),
	.in_tvalid(),
  	.in_tlast( ti_source_tlast ),
	.in_tready( ti_source_tready ),

  	.out_tdata( ti_fifo_tdata ),
	.out_tlast( ti_fifo_tlast ),
	.out_tvalid( ti_fifo_tvalid ),
	.out_tready( ti_fifo_tready )
);


Mercury_XU1 bd (
    .clk_125(clk),
    .rst_125_n(~rst),

    .soc_in_reset( soc_in_reset ), // reset output when SOC is done with internal reset

    .revision_value( moller_regs_pkg::MOLLER_REVISION ),

    // Run (Window?) packets
    .run_fifo_tdata( run_fifo_tdata ),
    .run_fifo_tlast( run_fifo_tlast ),
    .run_fifo_tready( run_fifo_tready ),
    .run_fifo_tvalid( run_fifo_tvalid ),

    // ADC streaming fifo
    .adc_fifo_tdata( adc_fifo_tdata ),
    .adc_fifo_tlast( adc_fifo_tlast ),
    .adc_fifo_tready( adc_fifo_tready ),
    .adc_fifo_tvalid( adc_fifo_tvalid ),

    // technically QSFP, but we are using one port
    .sfp_refclk_clk_n(MGT_B228_REFCLK1_N),
    .sfp_refclk_clk_p(MGT_B228_REFCLK1_P),

    /*
    .sfp_data_rx_gt_port_0_n(MGT_B228_RX1_N),
    .sfp_data_rx_gt_port_0_p(MGT_B228_RX1_P),
    .sfp_data_tx_gt_port_0_n(MGT_B228_TX1_N),
    .sfp_data_tx_gt_port_0_p(MGT_B228_TX1_P),
    */

    .sfp_gem_rxn(MGT_B228_RX0_N),
    .sfp_gem_rxp(MGT_B228_RX0_P),
    .sfp_gem_txn(MGT_B228_TX0_N),
    .sfp_gem_txp(MGT_B228_TX0_P),

    .CLK_IBERT(clnr_osc),
    .PHY_RESET(rst),
    .sfp_signal_detect(~DATA_ModPRSn),
    /*
    .sfp_reset(~LMK_STAT_LD),
    // Comblock 10g UDP client input stream
    .udp_tx_ack(),
    .udp_tx_cts(),
    .udp_tx_data(64'h0), // 64
    .udp_tx_data_valid({8{1'b0}}),   // 8
    .udp_tx_eof(1'b0),
    .udp_tx_nak(),
    .udp_tx_sof(1'b0),
    .udp_tx_clk(clk_udp_tx),
    */

    // Moved to internal regmap control
    //.udp_tx_dest_ip_addr(128'h00000000c0a80164), // 0xc0a80164 = 192.168.1.100
    //.udp_tx_dest_port_no(16'd5000), // 16
    //.udp_tx_source_port_no(16'd5000), // 16

    // Register map I/O
    .adc_delay_value(adc_ch_delay),
    .adc_load_value(adc_ch_load),
    .adc_test_data_bad_dco_counter( bad_dco_counter ),
    .adc_test_data_bad_pattern_counter( bad_data_counter ),

    .freq_osc_value( freq_osc ),
    .freq_som0_value( freq_som[0] ),
    .freq_som1_value( freq_som[1] ),
    .freq_td_value( freq_td ),

    .stream_ctrl_ch0(stream_ch0),
    .stream_ctrl_ch1(stream_ch1),
    .stream_ctrl_enable(stream_ena),
    .stream_ctrl_num_samples(stream_num_samples),
    .stream_ctrl_rate_div(stream_rate_div),

    .adc_ctrl_ch_disable( ctrl_adc_ch_disable ),
    .adc_ctrl_ena( ctrl_adc_ena ),
    .adc_ctrl_power_down( ctrl_adc_pwr_down ),
    .adc_ctrl_testpattern( ctrl_adc_testpat ),
    .adc_ctrl_sample_rate( ctrl_sample_rate ),
    .adc_ctrl_clear_counters( ctrl_clear_counters ),

    .status_clk_holdover( LMK_STAT_HOLDOVER ),
    .status_clk_lockdetect( LMK_STAT_LD ),

    // JLab TI
    .CLK250( clk_convert ),
    .CLK625( clk_625 ),
    .CLKPrg( clk_50 ),

    .CLKREFO_N(),
    .CLKREFO_P(),
    .GENINP(geninp),
    .GENOUTP(genoutp),
    .SWM(),
    .TCSOUT(tcsout),
    .TI1SYNCTX_N(),
    .TI1SYNCTX_P(),

    .TI1SYNCRX_N(RX_TI_SYNC_N),
    .TI1SYNCRX_P(RX_TI_SYNC_P),

    .TI1RX_N(MGT_B230_RX0_N),
    .TI1RX_P(MGT_B230_RX0_P),

    .TI1TX_N(MGT_B230_TX0_N),
    .TI1TX_P(MGT_B230_TX0_P),

    .TICLK_N(MGT_B230_REFCLK0_N),
    .TICLK_P(MGT_B230_REFCLK0_P)
);

endmodule
