`timescale 1 ns / 1 ps

module tb_adc_trainer();

parameter WAIT_COUNT = 5;
parameter CHECK_COUNT = 10;
parameter START_DELAY = 1;

// Declare a clock period constant.
parameter CLOCK_PERIOD = 4; // clock period of readback clock
parameter jitter = 500;  // ns x 1000
parameter NUM_ADC = 2;
parameter VALID_CYCLES = 2;

integer seed = 1;

reg clk;
reg rst;
reg [3:0] rst_count;
reg valid;
reg [NUM_ADC-1:0] ch_valid;
reg [NUM_ADC-1:0][17:0] ch_data;
reg [3:0] valid_cnt;
reg [7:0] phase_pos;


wire [63:0] fifo_tdata;
wire fifo_tvalid;
wire fifo_tlast;

wire testpat;
wire done;
wire adjust_phase;
wire [55:0] phase_error;

// Clock
initial clk = 0;
always #((CLOCK_PERIOD/2)+$dist_uniform(seed,-jitter,jitter)/1000.0) clk = ~clk;

// Reset
initial begin
   rst = 1'b1;
   rst_count = 4'hF;
end

// Reset logic
always@(posedge clk) begin
    rst <= (rst_count == 0) ? 1'b0 : 1'b1;
    rst_count <= (rst_count > 0) ? rst_count - 1'b1 : rst_count;
end

always@(posedge clk) begin
    if(rst) begin
        valid <= 1'b0;
        valid_cnt <= 0;
        phase_pos <= 0;
    end else begin
        valid <= (valid_cnt == VALID_CYCLES) ? 1'b1 : 1'b0;
        valid_cnt <= (valid_cnt == VALID_CYCLES) ? 0 : valid_cnt + 1'b1;
        phase_pos <= (adjust_phase) ? (phase_pos < 55) ? phase_pos + 1'b1 : 0 : phase_pos;
    end
end

genvar n;
generate
for(n=0; n<NUM_ADC; n = n + 1) begin

always@(posedge clk) begin
    if(rst) begin
        ch_valid[n] <= 0;
        ch_data[n] <= 0;
    end else begin
        if(phase_pos < 14) begin
            ch_valid[n] <= (valid_cnt == VALID_CYCLES) ? 1'b1 : 1'b0;
            ch_data[n] <= 18'b110011000011111100;
        end else if(phase_pos < 28) begin
            ch_valid[n] <= 0;
            ch_data[n] <= 0;
        end else if(phase_pos < 42) begin
            ch_valid[n] <= (valid_cnt == VALID_CYCLES) ? 1'b1 : 1'b0;
            ch_data[n] <= 18'b110011000011111100;
        end else begin
            ch_valid[n] <= 0;
            ch_data[n] <= 0;
        end

    end
end

end
endgenerate

adc_trainer #(
    .NUM_ADC( NUM_ADC ),
    .WAIT_COUNT( WAIT_COUNT ),
    .CHECK_COUNT( CHECK_COUNT ),
    .START_DELAY( START_DELAY )
) trainer (
    .clk(clk),
    .rst(rst),
    .valid(valid),
    .ch_data(ch_data),
    .ch_valid(ch_valid),

    .convert(),

    .fifo_tdata( fifo_tdata ),
    .fifo_tvalid( fifo_tvalid ),
    .fifo_tlast(fifo_tlast),
    .fifo_tready(1'b1),

    .adjust_phase(adjust_phase),
    .phase_error(phase_error),
    .testpat(testpat),
    .done(done)
);

endmodule
