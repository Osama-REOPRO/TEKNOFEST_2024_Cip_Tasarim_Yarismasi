module uart_wishbone_controller(
	input clk_i, rst_i,
	// -------------------- memory-mapped uart signals
	input 		  we_i,
	input  [31:0] adrs_i,
	input  [31:0] wdata_i,
	// input  [2:0]  wsize_i, // ignored, always word read/write
	input 		  req_i,
	output        done_o,
	output [31:0] rdata_o,
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

// uart memory maps
localparam adrs_uart_ctrl 	 = 32'h20000000;
localparam adrs_uart_status = 32'h20000004;
localparam adrs_uart_rdata  = 32'h20000008;
localparam adrs_uart_wdata  = 32'h2000000c;

// memory map checks
wire adrs_is_uart_ctrl   = (adrs_i >= adrs_uart_ctrl)   && (adrs_i <= adrs_uart_ctrl+32'd1);
wire adrs_is_uart_status = (adrs_i >= adrs_uart_status) && (adrs_i <= adrs_uart_status+32'd1);
wire adrs_is_uart_rdata  = (adrs_i >= adrs_uart_rdata)  && (adrs_i <= adrs_uart_rdata+32'd1);
wire adrs_is_uart_wdata  = (adrs_i >= adrs_uart_wdata)  && (adrs_i <= adrs_uart_wdata+32'd1);

reg [3:0] state;
localparam idle_st 					= 0,
			  done_st 					= 1,
			  read_uart_ctrl_st		= 2,
			  read_uart_status_st	= 3,
			  read_uart_rdata_st		= 4,
			  read_uart_wdata_st		= 5,
			  write_uart_ctrl_st		= 6,
			  write_uart_status_st	= 7,
			  write_uart_rdata_st	= 8,
			  write_uart_wdata_st	= 9;

reg [3:0] mem_sub_state;
localparam init   = 0,
			  busy   = 1,
			  finish = 2;

always @(posedge clk_i) begin
	if (rst_i) begin
		{  state,
			mem_sub_state,
			tx_en,
			rx_en,
			baud_div,
			tx_full,
			tx_empty,
			rx_full,
			rx_empty,
			wdata_write_request,
			wdata,
			rdata_read_request,
			rdata
			} <= 0;
	end else begin
		case (state)
			idle_st: begin
				done_o <= 1'b0;
				if (req_i) begin
					if			(adrs_is_uart_ctrl) 	 state <= we_i ? write_uart_ctrl_st   : read_uart_ctrl_st;
					else if 	(adrs_is_uart_status) state <= we_i ? write_uart_status_st : read_uart_status_st;
					else if	(adrs_is_uart_rdata)	 state <= we_i ? write_uart_rdata_st  : read_uart_rdata_st;
					else if	(adrs_is_uart_wdata)  state <= we_i ? write_uart_wdata_st  : read_uart_wdata_st;
					else 									 state <= idle_st;
				end
			end

			done_st: begin
				done_o <= 1'b1;
				if (!req_i) state = idle_st;
			end

			read_uart_ctrl_st: begin end
			write_uart_ctrl_st: begin end

			read_uart_status_st: begin end
			write_uart_status_st: begin end

			read_uart_rdata_st: begin end
			write_uart_rdata_st: begin end

			read_uart_wdata_st: begin end
			write_uart_wdata_st: begin end
		endcase
	end
end

// todo: interpret incoming memory requests as uart operations
// read/write data from/to appropriate locations in read/write data to
// internal registers below

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
