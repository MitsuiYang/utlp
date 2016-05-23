module eth_tlptap (
	input wire clk200,
	input wire sys_rst,

	// Eth+IP+UDP + TLP packet
	output logic        s_axis_tready,
	input  logic        s_axis_tvalid,
	input  logic [63:0] s_axis_tdata,
	input  logic [ 7:0] s_axis_tkeep,
//	input  logic        s_axis_tlast,
//	input  logic        s_axis_tuser,

	// TLP packet (FIFO write)
	output logic        wr_en,
	output logic [71:0] din,
	input  logic        full
);

always_comb begin
	s_axis_tready = !full;
	wr_en = s_axis_tready && s_axis_tvalid;
	din = {s_axis_tkeep, s_axis_tdata};
end

endmodule

