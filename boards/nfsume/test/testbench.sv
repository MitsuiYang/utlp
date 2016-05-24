`timescale 1ps / 1ps
`define SIMULATION

module testbench(
	input wire user_clk,
	input wire clk100,
	input wire cold_reset,
	input wire SFP_CLK_P
);

wire SFP_REC_CLK_P;
wire SFP_REC_CLK_N;
wire ETH1_RX_P;
wire ETH1_RX_N;
wire ETH1_TX_DISABLE;
eth_top eth1_top(
	.user_clk        (user_clk),
	.clk100          (clk100),
	.cold_reset      (cold_reset),
	.SFP_CLK_P       (SFP_CLK_P),
	.SFP_CLK_N       (1'b0),
	.SFP_REC_CLK_P   (SFP_REC_CLK_P),
	.SFP_REC_CLK_N   (SFP_REC_CLK_N),
	.ETH1_TX_P       (1'b0),
	.ETH1_TX_N       (1'b0),
	.ETH1_RX_P       (ETH1_RX_P),
	.ETH1_RX_N       (ETH1_RX_N),
	.I2C_FPGA_SCL    (1'b0),
	.I2C_FPGA_SDA    (1'b0),
	.SFP_CLK_ALARM_B (1'b0),
	.ETH1_TX_FAULT   (1'b0),
	.ETH1_RX_LOS     (1'b0),
	.ETH1_TX_DISABLE (ETH1_TX_DISABLE)
);
endmodule

