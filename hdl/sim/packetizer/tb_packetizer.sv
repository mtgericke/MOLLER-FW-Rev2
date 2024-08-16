`timescale 1 ns / 1 ps

module tb_packetizer();

// Declare a clock period constant.
parameter NUM_INPUTS = 4;

reg clk;
reg rst;
reg [3:0] rst_count;

reg capture;
reg [NUM_INPUTS-1:0][31:0] d;
wire [31:0] tdata;
wire tlast;
wire tvalid;

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


genvar n;
generate

for(n=0; n<NUM_INPUTS; n = n + 1) begin
    always@(posedge clk) begin
        d[n] <= n + 1;
    end
end

always@(posedge clk) begin
    if(rst == 1'b0) begin
        capture <= 1'b1;

    end else begin
        capture <= 1'b0;
    end
end

endgenerate

simple_packetizer #(
    .NUM_INPUTS( NUM_INPUTS )
) packetizer (
    .clk(clk),
    .rst(rst),
    .capture(capture),
    .d(d),
    .tready(1'b1),
    .tdata(tdata),
    .tvalid(tvalid),
    .tlast(tlast)
);

endmodule
