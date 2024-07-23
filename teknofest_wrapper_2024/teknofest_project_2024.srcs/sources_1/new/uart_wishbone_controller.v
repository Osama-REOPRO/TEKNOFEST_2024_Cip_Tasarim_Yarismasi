module uart_wishbone_controller(
	input clk_i, rst_i,
	// -------------------- memory-mapped uart signals
	input 		  uart_we_i,
	input  [31:0] uart_adrs_i,
	input  [31:0] uart_wdata_i,
	// input  [2:0]  data_wsize_i, // ignored, always word read/write
	input 		  uart_req_i,
	output        uart_done_o,
	output [31:0] uart_rdata_o,
	// wishbone
	input  [31:0] WB_ADR_I,
	output [31:0] WB_DAT_O,
	input  [31:0] WB_DAT_I,
	input 		  WB_WE_I,
	input 		  WB_CYC_I,
	input 		  WB_STB_I,
	output 		  WB_ACK_O,
	output 		  WB_RTY_O
);

// todo: interpret incoming memory requests as uart operations
// read/write data from/to appropriate locations in read/write data to
// internal registers below

reg  		  tx_en;
reg  		  rx_en;
reg [15:0] baud_div;
reg        tx_full;
reg        tx_empty;
reg        rx_full;
reg        rx_empty;
reg        wdata_write_request;
reg [31:0] wdata;
reg        rdata_read_request;
reg [31:0] rdata;

wb_m_core_uart wishbone_master_uart (
	.clk_i         (clk_i),
	.rst_i         (rst_i),
	// uart
	.tx_en_i       (tx_en),
	.rx_en_i       (rx_en),
	.baud_div_i    (baud_div),
	.tx_full_o     (tx_full),
	.tx_empty_o    (tx_empty),
	.rx_full_o     (rx_full),
	.rx_empty_o    (rx_empty),
	.wdata_write_request_i(wdata_write_request),
	.wdata_i       (wdata),
	.rdata_read_request_i(rdata_read_request),
	.rdata_o       (rdata),
	// wb
	.ADR_O         (WB_ADR_I),
	.DAT_I         (WB_DAT_O),
	.DAT_O         (WB_DAT_I),
	.WE_O          (WB_WE_I),
	.CYC_O         (WB_CYC_I),
	.STB_O         (WB_STB_I),
	.ACK_I         (WB_ACK_O),
	.RTY_I         (WB_RTY_O)
	 );

endmodule
