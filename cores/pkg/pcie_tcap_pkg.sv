/* PCIe TLP global header for pemu (tcap)
 * Byte 6
 *
 * 15               7             0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * | Ver |Dir|Rsrvd|               |
 * +-+-+-+-+-+-+-+-+               |
 * |           Timestamp           |
 * |                               |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 *
 */

package pcie_tcap_pkg;
	parameter PCIE_TCAP_LEN = 6;

	typedef struct packed {
		bit [ 2:0] ver;
		bit [ 1:0] dir;
		bit [ 2:0] rsrv;
		bit [39:0] ts;
	} pcie_tcaphdr;

	function pcie_tcaphdr tcap_init();
		tcap_init.ver = 2'b01;
		tcap_init.dir = 0;
		tcap_init.rsrv = 0;
		tcap_init.ts = 0;
	endfunction :tcap_init

endpackage :pcie_tcap_pkg

