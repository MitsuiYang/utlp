module eth_txarb (
	input logic clk,
	input logic rst,

	// data in : fifo0
	input  logic [73:0] fifo0_dout,
	input  logic        fifo0_empty,
	output logic        fifo0_rd_en,

	// data in : fifo1
	input  logic [73:0] fifo1_dout,
	input  logic        fifo1_empty,
	output logic        fifo1_rd_en,

	// data write
	output logic [73:0] din,
	input  logic        full,
	output logic        wr_en
);

wire fifo0_tlast = fifo0_dout[1];
wire fifo1_tlast = fifo1_dout[1];

enum logic [1:0] { IDLE, FIFO0, FIFO1 } state;
always_ff @(posedge clk) begin
	if (rst) begin
		state       <= IDLE;
		fifo0_rd_en <= 1'b0;
		fifo1_rd_en <= 1'b0;
		din         <= 74'b0;
		wr_en       <= 1'b0;
	end else begin
		case (state)
			IDLE: begin
				fifo0_rd_en <= 1'b0;
				fifo1_rd_en <= 1'b0;
				wr_en       <= 1'b0;
				if (!full && !fifo0_empty) begin
					state <= FIFO0;
				end else if (!full && !fifo1_empty) begin
					state <= FIFO1;
				end
			end
			FIFO0: begin
				fifo0_rd_en <= 1'b1;
				wr_en       <= 1'b1;
				din         <= fifo0_dout;
				if (fifo0_tlast) begin
					state <= IDLE;
				end
			end
			FIFO1: begin
				fifo1_rd_en <= 1'b1;
				wr_en       <= 1'b1;
				din         <= fifo1_dout;
				if (fifo1_tlast) begin
					state <= IDLE;
				end
			end
			default: begin
				state <= IDLE;
			end
		endcase
	end
end

endmodule

