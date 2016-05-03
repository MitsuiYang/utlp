`include "../rtl/setup.v"
`timescale 1ps / 1ps

module top #(
	parameter PL_LINK_CAP_MAX_LINK_WIDTH = 8
)(
	output wire [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_txp,
	output wire [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_txn,
	input  wire [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_rxp,
	input  wire [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_rxn,

	input wire sys_clk_p,
	input wire sys_clk_n,
	input wire sys_rst_n,

	input wire FPGA_SYSCLK_P,
	input wire FPGA_SYSCLK_N,

	output wire [7:0] led
);

pcie_top pcie_top (.*);


endmodule

