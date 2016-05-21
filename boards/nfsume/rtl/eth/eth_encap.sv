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

	output logic        s_axis_tready,
	input  logic        s_axis_tvalid,
	input  logic [63:0] s_axis_tdata,
	input  logic [ 7:0] s_axis_tkeep,
	input  logic        s_axis_tlast,
	input  logic        s_axis_tuser,

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

// 
logic        tmp_tready0, tmp_tready1, tmp_tready2, tmp_tready3, tmp_tready4, tmp_tready5, tmp_tready6;
logic        tmp_tvalid0, tmp_tvalid1, tmp_tvalid2, tmp_tvalid3, tmp_tvalid4, tmp_tvalid5, tmp_tvalid6;
logic [63:0] tmp_tdata0, tmp_tdata1, tmp_tdata2, tmp_tdata3, tmp_tdata4, tmp_tdata5, tmp_tdata6;
logic [ 7:0] tmp_tkeep0, tmp_tkeep1, tmp_tkeep2, tmp_tkeep3, tmp_tkeep4, tmp_tkeep5, tmp_tkeep6;
logic        tmp_tlast0, tmp_tlast1, tmp_tlast2, tmp_tlast3, tmp_tlast4, tmp_tlast5, tmp_tlast6;
logic        tmp_tuser0, tmp_tuser1, tmp_tuser2, tmp_tuser3, tmp_tuser4, tmp_tuser5, tmp_tuser6;
// tready
always_ff @(posedge clk156) begin
	tmp_tready0   <= m_axis_tready;
	tmp_tready1   <= tmp_tready0;
	tmp_tready2   <= tmp_tready1;
	tmp_tready3   <= tmp_tready2;
	tmp_tready4   <= tmp_tready3;
	tmp_tready5   <= tmp_tready4;
	tmp_tready6   <= tmp_tready5;
	s_axis_tready <= tmp_tready6;
end

// tvalid
always_ff @(posedge clk156) begin
	tmp_tvalid0   <= s_axis_tvalid;
	tmp_tvalid1   <= tmp_tvalid0;
	tmp_tvalid2   <= tmp_tvalid1;
	tmp_tvalid3   <= tmp_tvalid2;
	tmp_tvalid4   <= tmp_tvalid3;
	tmp_tvalid5   <= tmp_tvalid4;
	tmp_tvalid6   <= tmp_tvalid5;
	m_axis_tvalid <= tmp_tvalid6;
end

// tdata
always_ff @(posedge clk156) begin
	tmp_tdata0   <= s_axis_tdata;
	tmp_tdata1   <= tmp_tdata0;
	tmp_tdata2   <= tmp_tdata1;
	tmp_tdata3   <= tmp_tdata2;
	tmp_tdata4   <= tmp_tdata3;
	tmp_tdata5   <= tmp_tdata4;
	tmp_tdata6   <= tmp_tdata5;
	m_axis_tdata <= tmp_tdata6;
end

// tkeep
always_ff @(posedge clk156) begin
	tmp_tkeep0   <= s_axis_tkeep;
	tmp_tkeep1   <= tmp_tkeep0;
	tmp_tkeep2   <= tmp_tkeep1;
	tmp_tkeep3   <= tmp_tkeep2;
	tmp_tkeep4   <= tmp_tkeep3;
	tmp_tkeep5   <= tmp_tkeep4;
	tmp_tkeep6   <= tmp_tkeep5;
	m_axis_tkeep <= tmp_tkeep6;
end

// tlast
always_ff @(posedge clk156) begin
	tmp_tlast0   <= s_axis_tlast;
	tmp_tlast1   <= tmp_tlast0;
	tmp_tlast2   <= tmp_tlast1;
	tmp_tlast3   <= tmp_tlast2;
	tmp_tlast4   <= tmp_tlast3;
	tmp_tlast5   <= tmp_tlast4;
	tmp_tlast6   <= tmp_tlast5;
	m_axis_tlast <= tmp_tlast6;
end

// tuser
always_ff @(posedge clk156) begin
	tmp_tuser0   <= s_axis_tuser;
	tmp_tuser1   <= tmp_tuser0;
	tmp_tuser2   <= tmp_tuser1;
	tmp_tuser3   <= tmp_tuser2;
	tmp_tuser4   <= tmp_tuser3;
	tmp_tuser5   <= tmp_tuser4;
	tmp_tuser6   <= tmp_tuser5;
	m_axis_tuser <= tmp_tuser6;
end

endmodule

