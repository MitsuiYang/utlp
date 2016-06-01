module eth_tlptap #(
	parameter PL_LINK_CAP_MAX_LINK_WIDTH = 2,
	parameter C_DATA_WIDTH               = 64,
	parameter KEEP_WIDTH                 = C_DATA_WIDTH / 32,
)(
	// Eth+IP+UDP + TLP packet
	input logic [C_DATA_WIDTH-1:0] s_axis_tdata,
	input logic             [84:0] s_axis_tuser,
	input logic                    s_axis_tlast,
	input logic   [KEEP_WIDTH-1:0] s_axis_tkeep,
	input logic                    s_axis_tvalid,
	input logic             [21:0] s_axis_tready,

	// TLP packet (FIFO write)
	output logic        wr_en,
	output logic [73:0] din,
	input  logic        full
);

logic [7:0] tmp_tkeep = { 4{s_axis_tkeep[1]}, 4{s_axis_tkeep[0]} };
logic tmp_tready = s_axis_tready[0];
logic tmp_tuser = s_axis_tuser[0];

//always_comb begin
//	s_axis_tready = !full;
//	wr_en = s_axis_tready && s_axis_tvalid;
//	din = {s_axis_tkeep, s_axis_tdata, s_axis_tlast, s_axis_tuser};
//end

always_comb begin
	if (!full) begin
		wr_en = tmp_tready && s_axis_tvalid;
		din   = {tmp_tkeep, s_axis_tdata, s_axis_tlast, tmp_tuser};
	end
end

endmodule

