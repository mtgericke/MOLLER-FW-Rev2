
module subsystem_clock (
    input wire clk_osc_125, // oscillator 125MHz
    input wire clk_cc_250, // clock cleaner 250 MHz output (TD_250)

    input wire cc_locked,
    input wire soc_ready,

    input wire [1:0] clkin0_prediv,

    output wire clk_out_125,
    output wire rst_out_125,

    output wire clk_out_250,
    output wire rst_out_250,

    output wire clk_625,

    // LMK clock cleaner pins
    output wire LMK_UWIRE_CLK,
    output wire LMK_UWIRE_DATA,
    output wire LMK_UWIRE_LE,

    // Statistics and counters
    output wire [1:0][31:0] fc_clk_som_in,
    output wire [31:0] fc_clk_osc,
    output wire [31:0] fc_clk_td
);

localparam FREQ_OSCILLATOR = 125000000;
localparam FREQ_125 = 125000000;
localparam NUM_UWIRE_DATA_WORDS = 26;

reg rst_osc = 1'b1;
reg rst_250 = 1'b1;
reg rst_125 = 1'b1;
reg rst_mmcm = 1'b1;

wire [NUM_UWIRE_DATA_WORDS-1:0][31:0] uwire_cfg_data;
wire [31:0] uwire_cfg_q;
wire uwire_start;
wire uwire_ready;
wire uwire_done;

wire psdone;
wire mmcm_adc_locked;

assign rst_out_125 = rst_125;
assign rst_out_250 = rst_250;

// LMK04816 Clock cleaner configuration
assign uwire_cfg_data = {
    32'h00160140, // CLK 0/1 (250MHz for TI)
    32'h00140140, // CLK 0/1 (out of reset)
    32'h80140281, // CLK 2/3 (Powered Down,  SOM IN (currently unused) set to 125MHz
    32'h00140282, // CLK 4/5  (MGT B229/230 REFCLKs, 125 MHz)
    32'h00140283, // CLK 6/7  (MGT B228/ REP OUT, 125)
    32'h00140284, // CLK 8/9  SMA_CLK_OUT1 (125 MHz)
    32'h00140145, // CLK 10/11 SMA_CLK_OUT0, 250 MHz
    32'h11110006, // Clock Types (LVDS) and Delay
    32'h01110007, // Disabling Clock 7
    32'h01010008, // Disabling Clock 11 and 9
    32'h55555549,
    32'h914249AA,
    32'h1403000B,
    32'h0B8C01AC,
    32'h130086ED,
    32'h1000000E,
    32'h8000800F,
    32'hC1550410,
    32'h000000D8,
    32'h02C9C419,
    32'hAFA8001A,
    8'h1D, 2'b10, clkin0_prediv, 20'h0065B, // 32'h1E90065B,
    32'h0040191C,
    32'h0180015D,
    32'h0500015E,
    32'h001F001F
};

reg [2:0] r_soc_ready_sync;
reg r_soc_ready;
always@(posedge clk_out_125) begin
    r_soc_ready_sync <= { r_soc_ready_sync[1:0], soc_ready };
    r_soc_ready <= &r_soc_ready_sync;
end

reg [5:0] r_soc_ready_sync_250; // make twice as long as 125MHz version of signal so they come out of reset closer to each other
reg r_soc_ready_250;
always@(posedge clk_out_250) begin
    r_soc_ready_sync_250 <= { r_soc_ready_sync_250[4:0], soc_ready };
    r_soc_ready_250 <= &r_soc_ready_sync_250;
end

reg [15:0] r_cc_locked_sync;
reg r_cc_locked;
reg [31:0] rst_osc_delay = 32'h0;
always@(posedge clk_osc_125) begin
    r_cc_locked_sync <= { r_cc_locked_sync[14:0], cc_locked };
    r_cc_locked <= &r_cc_locked_sync;

    rst_osc_delay <= (rst_osc_delay < 32'd125000000) ? rst_osc_delay + 1'b1 : rst_osc_delay;

    // just dump the reset, oscillator should be long stable by time FPGA is read from SDcard via bootloader
    rst_osc <= (rst_osc_delay < 32'd125000000) ? 1'b1 : 1'b0;
    rst_mmcm <= ~r_cc_locked;
end

always@(posedge clk_out_125) begin
    rst_125 <= ~(mmcm_adc_locked & r_soc_ready);
end

always@(posedge clk_out_250) begin
    rst_250 <= ~(mmcm_adc_locked & r_soc_ready_250);
end

uwire_lmk04816 #(
    .CLK_PERIOD(FREQ_OSCILLATOR) // clk = 125 MHz, so 8ns period
) cleaner_uwire (
    .clk	    ( clk_osc_125 ),
    .rst	    ( rst_osc ),
    .start	    ( uwire_start ),
    .d		    ( uwire_cfg_q ),
    .ready		( uwire_ready ),
    .CLKuWire   ( LMK_UWIRE_CLK ),
    .DATAuWire  ( LMK_UWIRE_DATA ),
    .LEuWire    ( LMK_UWIRE_LE )
);

uwire_loader #(
    .NUM_WORDS(NUM_UWIRE_DATA_WORDS)
) cleaner_loader (
    .clk    ( clk_osc_125 ),
    .rst    ( rst_osc ),
    .d	    ( uwire_cfg_data ),
    .q	    ( uwire_cfg_q ),
    .ready  ( uwire_ready ),
    .start  ( uwire_start ),
    .done   ( uwire_done )
);

mmcm_adc adc_mmcm (
    // Status and control signals
    .reset( rst_mmcm ),
    .locked( mmcm_adc_locked ),

    // Clock in ports
    .clk_in1( clk_cc_250 ),

    // Clock out ports
    .clk_adc_cnv( clk_out_250 ),
    .clk_adc ( clk_out_125 ),
    .clk_625 ( clk_625 )
);

freq_counter #(
    .REF_FREQ(FREQ_125)
) fc_osc (
    .clk        ( clk_out_125 ),
    .rst        ( rst_out_125 ),
    .clk_freq   ( clk_osc_125 ),
    .q          ( fc_clk_osc )
);

freq_counter #(
    .REF_FREQ(FREQ_125)
) fc_td (
    .clk        ( clk_out_125 ),
    .rst        ( rst_out_125 ),
    .clk_freq   ( clk_cc_250 ),
    .q          ( fc_clk_td )
);

endmodule
