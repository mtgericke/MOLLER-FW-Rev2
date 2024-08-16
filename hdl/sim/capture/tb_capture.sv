`timescale 1 ns / 1 ps

module tb_capture();

// Declare a clock period constant.
parameter NUM_INPUTS = 1;
parameter WIDTH = 16;
parameter CYCLES_PER_CAPTURE = 40;

reg clk;
reg rst;
reg [3:0] rst_count;

reg fifo_tready;
wire [WIDTH-1:0] fifo_tdata;
wire fifo_tvalid;
wire fifo_tlast;

// Clock
initial begin
    clk = 0;
    forever begin
        #10 clk = ~clk;
    end
end

// Reset
initial begin
   rst = 1'b1;
   rst_count = 4'hF;
end

always@(posedge clk) begin
    rst_count <= (rst_count > 0) ? rst_count - 1'b1 : rst_count;
    if (rst_count == 0) begin
        rst <= 1'b0;
    end else begin
        rst <= 1'b1;
    end
end

integer state;

reg [7:0] run_count;
reg [NUM_INPUTS-1:0][WIDTH-1:0] data;
wire capture = (run_count == CYCLES_PER_CAPTURE) ? 1'b1 : 1'b0;

always@(posedge clk) begin
	if(rst) begin
		run_count <= 0;
		fifo_tready <= 0;
		data <= 0;
		state <= 0;
	end else begin
		case(state)
		0: fifo_tready <= 1'b1;
		1: fifo_tready <= (fifo_tready && fifo_tvalid) ? 1'b0 : (fifo_tvalid) ? 1'b1 : 1'b0;
		2: fifo_tready <= (run_count[2:0] == 3'b111) && fifo_tvalid ? 1'b1 : 1'b0;
		3: $stop;
		endcase
		state <= (fifo_tready && fifo_tvalid && fifo_tlast) ? state + 1'b1 : state;
		run_count <= (run_count < CYCLES_PER_CAPTURE) ? run_count + 1'b1 : 0;
		data <= { 16'h0A, 16'h0B, 16'h0C, 16'h0D };
	end
end

simple_packetizer #(
	.PREPEND_LEN(1),
	.ID(8'hAA),
    .NUM_INPUTS(NUM_INPUTS),
	.WIDTH(WIDTH)
) packetizer (
    .clk(clk),
    .rst(rst),
    .capture(capture),
    .d(data),
    .tready(fifo_tready),
    .tdata(fifo_tdata),
    .tvalid(fifo_tvalid),
    .tlast(fifo_tlast)
);

endmodule
