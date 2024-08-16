`timescale 1 ns / 1 ps

module tb_adc();

// Declare a clock period constant.
parameter CLOCK_PERIOD = 4; // clock period of readback clock
parameter CLK_TO_DCO_DELAY = 0.5; // part varies from 0.7 to 2.3, nominally 1.3
parameter [17:0] ANALOG_DATA = 18'b110011000011111100; // 18-bit analog data value to expect

reg clk;
reg cnv_clk;
reg rst;
reg [3:0] rst_count;
reg enable;
reg [15:0] enable_off_count;
reg [63:0] ts;

wire ready;
wire dco;
wire [1:0] d;

wire adc_clk;
wire adc_valid;
wire adc_convert;
wire [17:0] q;
wire [63:0] q_ts;
wire [9:0] q_dco;
wire adc_ch_valid;

// Clock
initial begin
    cnv_clk = 0;
    forever begin
        #(CLOCK_PERIOD / 2) cnv_clk = ~cnv_clk;
    end
end

// Clock
initial begin
    clk = 0;
    forever begin
        #(CLOCK_PERIOD) clk = ~clk;
    end
end


// Reset
initial begin
   rst = 1'b1;
   rst_count = 4'hF;
   ts = 0;
   enable = 1'b1;
   enable_off_count = 16'h00000050;

end

always@(posedge clk) begin
    rst_count <= (rst_count > 0) ? rst_count - 1'b1 : rst_count;
    rst <= (rst_count == 0) ? 1'b0 : 1'b1;
    ts <= (rst) ? 0 : ts + 1'b1;
    enable_off_count <= (enable_off_count > 0) ? enable_off_count - 1'b1 : enable_off_count;
    enable <= (enable_off_count == 0) ? 1'b0 : 1'b1;

    if(adc_valid) begin
        $display("%s Clock %d ns, Delay %.1f ns, Ex %b Rx %b", (ANALOG_DATA != q) ? "FAIL" : "PASS", CLOCK_PERIOD, CLK_TO_DCO_DELAY, ANALOG_DATA, q);
    end
end

ltc2387_18 #(
    .CLK_TO_DCO_DELAY( CLK_TO_DCO_DELAY )
) emu_adc (
    .rst( rst ),
    .clk( adc_clk ),
    .analog_data( ANALOG_DATA ),
    .cnv( adc_convert ),
    .dco( dco ),
    .d( d )
);

ltc2387_deserializer_twolane #(
    .CLOCK_PERIOD( CLOCK_PERIOD )
) adc0 (
    .rst( rst ),
    .clk( clk ),
    .clk_cnv( cnv_clk ),
    .start( enable ),
    .in_ts( ts ),
    .ready( ready) ,
    .adc_cnv( adc_convert ), // conversion start request
    .adc_clk( adc_clk ), // clock send to ADC
    .adc_dco( dco ),
    .adc_da( d[0] ),
    .adc_db( d[1] ),
    .q_valid( adc_valid ),
    .q_ch_valid( adc_ch_valid ),
    .q_data( q ),
    .q_ts( q_ts )
);

localparam MAX_ALLOWED_ALIGN_CNT = 10;

reg [15:0] align_cnt;
reg phase_adjust;
always@(posedge clk) begin
    if(rst) begin
        phase_adjust <= 1'b0;
        align_cnt <= 0;
    end else begin
        if(align_cnt > MAX_ALLOWED_ALIGN_CNT) begin
            phase_adjust <= 1'b1;
            align_cnt <= 0;
        end else begin
            phase_adjust <= 1'b0;
            align_cnt <= (adc_valid) ? 0 : align_cnt + 1'b1;
        end
    end
end

endmodule
