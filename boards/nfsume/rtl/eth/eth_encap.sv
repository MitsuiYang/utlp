import endian_pkg::*;
import ethernet_pkg::*;
import ip_pkg::*;
import udp_pkg::*;

module eth_encap #(
	parameter frame_len = 16'd60,
	
	parameter pemu_hdr_len = 48,

//    parameter eth_dst   = 48'hFF_FF_FF_FF_FF_FF,
	parameter eth_dst   = 48'h90_E2_BA_5D_8D_C8,
	parameter eth_src   = 48'h00_11_22_33_44_55,
	parameter eth_proto = ETH_P_IP,
	parameter ip_saddr  = {8'd192, 8'd168, 8'd1, 8'd111},
	parameter ip_daddr  = {8'd192, 8'd168, 8'd1, 8'd122},
	parameter udp_sport = 16'd3776,
	parameter udp_dport = 16'd3776
)(
	input wire clk156,
	input wire sys_rst,

	// TLP packet (FIFO read)
	output logic        rd_en,
	input  logic [73:0] dout,
	input  logic        empty,

	// Eth+IP+UDP + TLP packet
	input  logic        m_axis_tready,
	output logic        m_axis_tvalid,
	output logic [63:0] m_axis_tdata,
	output logic [ 7:0] m_axis_tkeep,
	output logic        m_axis_tlast,
	output logic        m_axis_tuser
);

/* function: ipcheck_gen() */
function [15:0] ipcheck_gen();
	bit [23:0] sum;
	sum = {8'h0, IPVERSION, 4'd5, 8'h0}
	    + {8'h0, frame_len - ETH_HDR_LEN}   // tot_len
	    + {8'h0, 16'h0}
	    + {8'h0, 16'h0}
	    + {8'h0, IPDEFTTL, IP4_PROTO_UDP}
	    + {8'h0, 16'h0}                     // checksum (zero padding)
	    + {8'h0, ip_saddr[31:16]}
	    + {8'h0, ip_saddr[15: 0]}
	    + {8'h0, ip_daddr[31:16]}
	    + {8'h0, ip_daddr[15: 0]};
	ipcheck_gen = ~( sum[15:0] + {8'h0, sum[23:16]} );
endfunction :ipcheck_gen

// encap packet header
typedef union packed {
	bit [5:0][63:0] raw;          // 48B
	struct packed {
		ethhdr eth;                // 14B
		iphdr ip;                  // 20B
		udphdr udp;                //  8B
		bit [47:0] pad;            //  6B
	} hdr;
} packet_t;

// packet init
packet_t tx_pkt;

always_comb begin
	tx_pkt.hdr.eth.h_dest = eth_dst;
	tx_pkt.hdr.eth.h_source = eth_src;
	tx_pkt.hdr.eth.h_proto = eth_proto;

	tx_pkt.hdr.ip.version = IPVERSION;
	tx_pkt.hdr.ip.ihl = 4'd5;
	tx_pkt.hdr.ip.tos = 0;
	tx_pkt.hdr.ip.tot_len = frame_len - ETH_HDR_LEN;
	tx_pkt.hdr.ip.id = 0;
	tx_pkt.hdr.ip.frag_off = 0;
	tx_pkt.hdr.ip.ttl = IPDEFTTL;
	tx_pkt.hdr.ip.protocol = IP4_PROTO_UDP;
	tx_pkt.hdr.ip.saddr = ip_saddr;
	tx_pkt.hdr.ip.daddr = ip_daddr;
	tx_pkt.hdr.ip.check = ipcheck_gen();

	tx_pkt.hdr.udp.source = udp_sport;
	tx_pkt.hdr.udp.dest = udp_dport;
	tx_pkt.hdr.udp.len = frame_len - ETH_HDR_LEN - IP_HDR_DEFLEN;
	tx_pkt.hdr.udp.check = 0;
end


logic [15:0] tx_count, tx_count_next;
enum logic [1:0] { TX_IDLE, TX_HDR, TX_DATA } tx_state = TX_IDLE, tx_state_next;
always_ff @(posedge clk156) begin
	if (sys_rst) begin
		tx_state <= TX_IDLE;
		tx_count <= 0;
	end else begin
		tx_state <= tx_state_next;
		tx_count <= tx_count_next;
	end
end

always_comb begin
	tx_state_next = tx_state;
	tx_count_next = tx_count;

	rd_en = 0;

	case(tx_state)
		TX_IDLE: begin
			if (m_axis_tready && !empty) begin
				tx_state_next = TX_HDR;
			end
		end
		TX_HDR: begin
			if (m_axis_tready) begin
				tx_count_next = tx_count + 1;
				if (tx_count == 5) begin
					tx_state_next = TX_DATA;
					rd_en = 1;
				end
			end
		end
		TX_DATA: begin
			if (m_axis_tready) begin
				rd_en = 1;
				if (m_axis_tlast) begin
					tx_state_next = TX_IDLE;
					rd_en = 0;
				end
			end
		end
		default:
			rd_en = 0;
	endcase
end

// tvalid
always_comb m_axis_tvalid = (tx_state == TX_HDR || tx_state == TX_DATA);

// tkeep
always_comb begin
	if (tx_state == TX_HDR) begin
		case (tx_count)
			16'h0: m_axis_tkeep = 8'b1111_1111;
			16'h1: m_axis_tkeep = 8'b1111_1111;
			16'h2: m_axis_tkeep = 8'b1111_1111;
			16'h3: m_axis_tkeep = 8'b1111_1111;
			16'h4: m_axis_tkeep = 8'b1111_1111;
			16'h5: m_axis_tkeep = 8'b1111_1111;
			default:
				m_axis_tkeep = 8'b0;
		endcase
	end else if (tx_state == TX_DATA) begin
		m_axis_tkeep = dout[73:66];
	end
end

// tdata
logic [63:0] m_axis_tdata_reg;
always_comb begin
	if (tx_state == TX_HDR) begin
		case (tx_count)
			16'h0: m_axis_tdata_reg = tx_pkt.raw[5];
			16'h1: m_axis_tdata_reg = tx_pkt.raw[4];
			16'h2: m_axis_tdata_reg = tx_pkt.raw[3];
			16'h3: m_axis_tdata_reg = tx_pkt.raw[2];
			16'h4: m_axis_tdata_reg = tx_pkt.raw[1];
			16'h5: m_axis_tdata_reg = tx_pkt.raw[0];
			default:
				m_axis_tdata_reg = 64'b0;
		endcase
	end else if (tx_state == TX_DATA) begin
		m_axis_tdata_reg = dout[65:2];
	end
end
always_comb begin
	if (tx_state == TX_HDR) begin
		m_axis_tdata = endian_conv64(m_axis_tdata_reg);
	end else if (tx_state == TX_DATA) begin
		m_axis_tdata = m_axis_tdata_reg;
	end
end

// tlast
always_comb m_axis_tlast = (tx_state == TX_DATA) ? dout[1] : 1'b0;

// tuser
always_comb m_axis_tuser = (tx_state == TX_DATA) ? dout[0] : 1'b0;

endmodule
