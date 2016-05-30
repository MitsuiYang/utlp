`timescale 1ns / 1ps

module eth_top #(
	parameter ifg_len = 28'hFFFF
)(
	input logic user_clk,
	input logic clk100,
	input logic cold_reset,

	input  logic SFP_CLK_P,
	input  logic SFP_CLK_N,
	output logic SFP_REC_CLK_P,
	output logic SFP_REC_CLK_N,

	input  logic ETH1_TX_P,
	input  logic ETH1_TX_N,
	output logic ETH1_RX_P,
	output logic ETH1_RX_N,

	inout logic I2C_FPGA_SCL,
	inout logic I2C_FPGA_SDA,

	input logic SFP_CLK_ALARM_B,

	input  logic ETH1_TX_FAULT,
	input  logic ETH1_RX_LOS,
	output logic ETH1_TX_DISABLE
);

logic sys_rst;
always @(posedge clk156) begin
	sys_rst <= cold_reset;
end

logic clk156;

// sfp_refclk_init
sfp_refclk_init sfp_refclk_init0 (
	.CLK(clk100),
	.RST(sys_rst),
	.*
);

// pcs_pma_conf
logic [535:0] pcs_pma_configuration_vector;
pcs_pma_conf pcs_pma_conf0(.*);

// eth_mac_conf
logic [79:0] mac_tx_configuration_vector;
logic [79:0] mac_rx_configuration_vector;
eth_mac_conf eth_mac_conf0(.*);

// eth_send
logic        s_axis_tx_tvalid;
logic        s_axis_tx_tready;
logic [63:0] s_axis_tx_tdata;
logic [ 7:0] s_axis_tx_tkeep;
logic        s_axis_tx_tlast;
logic        s_axis_tx_tuser;
eth_send #(
	.ifg_len(ifg_len)
) eth_send0 (
	.clk156(user_clk),
	.reset(cold_reset),
	.*
);

// pcie2eth_fifo
logic wr_en, rd_en;
logic full, empty;
logic [73:0] din, dout;
pcie2eth_fifo pcie2eth_fifo0 (
	.rst(sys_rst),
	.wr_clk(user_clk),    // data in (pcie)
	.rd_clk(clk156),      // data out(eth)
	.*
);

// eth_tlptap (PCIe to FIFO)
//logic        s_axis_tlptap_tvalid;
//logic        s_axis_tlptap_tready;
//logic [63:0] s_axis_tlptap_tdata;
//logic [ 7:0] s_axis_tlptap_tkeep;
//logic        s_axis_tlptap_tlast;
//logic        s_axis_tlptap_tuser;
eth_tlptap eth_tlptap0 (
	// data in(tap)
	.s_axis_tvalid(s_axis_tx_tvalid),
	.s_axis_tready(s_axis_tx_tready),
	.s_axis_tdata (s_axis_tx_tdata),
	.s_axis_tkeep (s_axis_tx_tkeep),
	.s_axis_tlast (s_axis_tx_tlast),
	.s_axis_tuser (s_axis_tx_tuser),

	// FIFO write
	.wr_en(wr_en),
	.din(din),
	.full(full)
);

// eth_encap (FIFO to eth_encap)
logic        m_axis_encap_tvalid;
logic        m_axis_encap_tready;
logic [63:0] m_axis_encap_tdata;
logic [ 7:0] m_axis_encap_tkeep;
logic        m_axis_encap_tlast;
logic        m_axis_encap_tuser;
eth_encap eth_encap0 (
	.clk156(clk156),
	.sys_rst(sys_rst),

	// FIFO read
	.rd_en(rd_en),
	.dout(dout),
	.empty(empty),

	// data out(encap)
	.m_axis_tvalid(m_axis_encap_tvalid),
	.m_axis_tready(m_axis_encap_tready),
	.m_axis_tdata (m_axis_encap_tdata),
	.m_axis_tkeep (m_axis_encap_tkeep),
	.m_axis_tlast (m_axis_encap_tlast),
	.m_axis_tuser (m_axis_encap_tuser)
);

// Ethernet IP
logic txusrclk_out;
logic txusrclk2_out;
logic gttxreset_out;
logic gtrxreset_out;
logic txuserrdy_out;
logic areset_datapathclk_out;
logic reset_counter_done_out;
logic qplllock_out;
logic qplloutclk_out;
logic qplloutrefclk_out;
logic [447:0] pcs_pma_status_vector;
logic [1:0] mac_status_vector;
logic [7:0] pcspma_status;
logic rx_statistics_valid;
logic tx_statistics_valid;
axi_10g_ethernet_0 axi_10g_ethernet_0_ins (
	.coreclk_out(clk156),
	.refclk_n(SFP_CLK_N),
	.refclk_p(SFP_CLK_P),
	.dclk(clk156),
	.reset(sys_rst),
	.rx_statistics_vector(),
	.rxn(ETH1_TX_N),
	.rxp(ETH1_TX_P),
	.s_axis_pause_tdata(16'b0),
	.s_axis_pause_tvalid(1'b0),
	.signal_detect(!ETH1_RX_LOS),
	.tx_disable(ETH1_TX_DISABLE),
	.tx_fault(ETH1_TX_FAULT),
	.tx_ifg_delay(8'd8),
	.tx_statistics_vector(),
	.txn(ETH1_RX_N),
	.txp(ETH1_RX_P),

	.rxrecclk_out(),
	.resetdone_out(),

	// eth tx
	.s_axis_tx_tready(m_axis_encap_tready),
	.s_axis_tx_tdata (m_axis_encap_tdata),
	.s_axis_tx_tkeep (m_axis_encap_tkeep),
	.s_axis_tx_tlast (m_axis_encap_tlast),
	.s_axis_tx_tvalid(m_axis_encap_tvalid),
	.s_axis_tx_tuser (m_axis_encap_tuser),
	
	// eth rx
	.m_axis_rx_tdata(),
	.m_axis_rx_tkeep(),
	.m_axis_rx_tlast(),
	.m_axis_rx_tuser(),
	.m_axis_rx_tvalid(),

	.sim_speedup_control(1'b0),
	.rx_axis_aresetn(1'b1),
	.tx_axis_aresetn(1'b1),

	.*
);

endmodule

