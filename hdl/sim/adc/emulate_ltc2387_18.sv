`timescale 1 ns / 1 ps

module ltc2387_18(
    input wire rst,
    input wire clk,
    input wire cnv,

    input wire [17:0] analog_data,

    output reg dco,
    output wire [1:0] d
);

// Clock is delayed 0.7 to 2.3 ns
parameter CLK_TO_DCO_DELAY = 0.7;


localparam tCONV = 63; // time to change zeros to sampled data from conversion high edge

// Internal Clock
reg [17:0] idata;
reg iclk;
reg [7:0] cnv_count;
reg [5:0] cap_count;
reg [21:0] cap_data;

wire irst = ((cnv_count == 1) || (rst)) ? 1'b1 : 1'b0;

always @clk dco <= #(CLK_TO_DCO_DELAY) clk;
assign d[0] = cap_data[cap_count];
assign d[1] = cap_data[cap_count-1];

// Internal clock 1ns period
initial begin
    iclk = 1;
    forever begin
        #(0.5) iclk = ~iclk;
    end
end

always@(posedge iclk) begin
    if(rst) begin
        idata <= 0;
        cnv_count <= 0;
        cap_data <= 0;
    end else begin
        if(cnv && (cnv_count == 0)) begin
            idata <= analog_data;
            cnv_count <= tCONV;
        end else begin
            idata <= idata;
            cnv_count <= (cnv_count > 0) ? cnv_count - 1'b1 : 0;
        end

        cap_data <= (cnv_count == 1) ? { 2'b00, idata, 2'b00 } : cap_data;
    end
end

always@(irst, dco) begin
    if(irst) begin
        cap_count <= 21;
    end else begin
        cap_count <= (cap_count > 1) ? cap_count - 2 : 1;
    end
end




endmodule
