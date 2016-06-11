import endian_pkg::*;
import ethernet_pkg::*;
import ip_pkg::*;
import udp_pkg::*;
import pcie_tcap_pkg::*;

module eth_txmux (
	// data in : fifo0
	output logic        fifo0_rd_en,
	input  logic [73:0] fifo0_dout,
	input  logic        fifo0_empty,

	// data in : fifo1
	output logic        fifo1_rd_en,
	input  logic [73:0] fifo1_dout,
	input  logic        fifo1_empty,

	// data out
	input  logic        rd_en,
	output logic [73:0] dout,
	output logic        empty
);

`ifdef NONE
logic [63:0] fifo0_tdata, fifo1_tdata;
logic [ 7:0] fifo0_tkeep, fifo1_tkeep;
logic        fifo0_tlast, fifo1_tlast;
logic        fifo0_tuser, fifo1_tuser;
always_comb begin
	{fifo0_tkeep, fifo0_tdata, fifo0_tlast, fifo0_tuser} = fifo0_dout;
	{fifo1_tkeep, fifo1_tdata, fifo1_tlast, fifo1_tuser} = fifo1_dout;
end

always_comb begin
	sel = 0;
	if (!fifo0_empty && (fifo0_tkeep != 0) && !fifo0_tlast) begin
		sel = 0;
	end else if (!fifo1_empty & (fifo1_tkeep != 0) & !fifo1_tlast) begin
		sel = 1;
	end
end
`endif

logic sel = 0;
always_comb begin
	if (sel) begin
		fifo1_rd_en = rd_en;
		dout        = fifo1_dout;
		empty       = fifo1_empty;
	end else begin
		fifo0_rd_en = rd_en;
		dout        = fifo0_dout;
		empty       = fifo0_empty;
	end
end

endmodule

