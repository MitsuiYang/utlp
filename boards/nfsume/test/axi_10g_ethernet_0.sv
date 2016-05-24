module axi_10g_ethernet_0 (
	input  logic         tx_axis_aresetn,
	input  logic         rx_axis_aresetn,
	input  logic   [7:0] tx_ifg_delay,
	input  logic         dclk,
	output logic         txp,
	output logic         txn,
	input  logic         rxp,
	input  logic         rxn,
	input  logic         signal_detect,
	input  logic         tx_fault,
	output logic         tx_disable,
	output logic   [7:0] pcspma_status,
	input  logic         sim_speedup_control,
	output logic         rxrecclk_out,
	input  logic  [79:0] mac_tx_configuration_vector,
	input  logic  [79:0] mac_rx_configuration_vector,
	output logic   [1:0] mac_status_vector,
	input  logic [535:0] pcs_pma_configuration_vector,
	output logic [447:0] pcs_pma_status_vector,
	output logic         areset_datapathclk_out,
	output logic         txusrclk_out,
	output logic         txusrclk2_out,
	output logic         gttxreset_out,
	output logic         gtrxreset_out,
	output logic         txuserrdy_out,
	output logic         coreclk_out,
	output logic         resetdone_out,
	output logic         reset_counter_done_out,
	output logic         qplllock_out,
	output logic         qplloutclk_out,
	output logic         qplloutrefclk_out,
	input  logic         refclk_p,
	input  logic         refclk_n,
	input  logic         reset,
	input  logic  [63:0] s_axis_tx_tdata,
	input  logic   [7:0] s_axis_tx_tkeep,
	input  logic         s_axis_tx_tlast,
	output logic         s_axis_tx_tready,
	input  logic   [0:0] s_axis_tx_tuser,
	input  logic         s_axis_tx_tvalid,
	input  logic  [15:0] s_axis_pause_tdata,
	input  logic         s_axis_pause_tvalid,
	output logic  [63:0] m_axis_rx_tdata,
	output logic   [7:0] m_axis_rx_tkeep,
	output logic         m_axis_rx_tlast,
	output logic         m_axis_rx_tuser,
	output logic         m_axis_rx_tvalid,
	output logic         tx_statistics_valid,
	output logic  [25:0] tx_statistics_vector,
	output logic         rx_statistics_valid,
	output logic  [29:0] rx_statistics_vector
);

always_comb coreclk_out = refclk_p;

always_ff @(posedge refclk_p) begin
	if (reset) begin
		s_axis_tx_tready <= 1'b0;
	end else begin
		s_axis_tx_tready <= 1'b1;
	end
end

endmodule

