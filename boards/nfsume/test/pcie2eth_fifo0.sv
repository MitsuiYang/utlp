`default_nettype none
module pcie2eth_fifo0 (
	input  wire rst,
	input  wire wr_clk,
	input  wire rd_clk,
	input  wire rd_en,
	input  wire wr_en,

	input  wire [73:0] din,
	output wire [73:0] dout,
	output wire empty,
	output wire full
);

asfifo #(
	.DATA_WIDTH(74),
	.ADDRESS_WIDTH(7)
) asfifo0 (
	.*
);

endmodule
`default_nettype wire
