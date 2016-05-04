`include "../rtl/setup.v"
`timescale 1ps / 1ps

module top #(
	parameter PL_LINK_CAP_MAX_LINK_WIDTH = 8
)(
	input wire FPGA_SYSCLK_P,
	input wire FPGA_SYSCLK_N,
	inout wire I2C_FPGA_SCL,
	inout wire I2C_FPGA_SDA,

	// PCI Express
	output wire [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_txp,
	output wire [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_txn,
	input  wire [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_rxp,
	input  wire [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_rxn,
	input  wire sys_clk_p,
	input  wire sys_clk_n,
	input  wire sys_rst_n,

	// Ethernet
	input  wire SFP_CLK_P,
	input  wire SFP_CLK_N,
	output wire SFP_REC_CLK_P,
	output wire SFP_REC_CLK_N,
	input  wire SFP_CLK_ALARM_B,
	output wire [7:0] led,

	// Ethernet (ETH1)
	input  wire ETH1_TX_P,
	input  wire ETH1_TX_N,
	output wire ETH1_RX_P,
	output wire ETH1_RX_N,
	input  wire ETH1_TX_FAULT,
	input  wire ETH1_RX_LOS,
	output wire ETH1_TX_DISABLE
);

wire clk200;
IBUFDS IBUFDS_clk200 (
        .I(FPGA_SYSCLK_P),
        .IB(FPGA_SYSCLK_N),
        .O(clk200)
);

pcie_top pcie_top0 (.*);

eth_top eth1_top (.*);

endmodule

