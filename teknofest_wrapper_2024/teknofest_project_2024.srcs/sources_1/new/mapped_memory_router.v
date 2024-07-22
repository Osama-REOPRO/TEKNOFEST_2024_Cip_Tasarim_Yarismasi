module mapped_memory_router(
	input clk_i,
	input rst_i,
	// ----------- incoming
	// instr
	input  		  instr_we_i,
	input  [31:0] instr_adrs_i,
	input  [31:0] instr_wdata_i,
	input  [2:0]  instr_wsize_i,
	input  		  instr_req_i,
	output     	  instr_done_o,
	output [31:0] instr_rdata_o,
	// data
	input  		  data_we_i,
	input  [31:0] data_adrs_i,
	input  [31:0] data_wdata_i,
	input  [2:0]  data_wsize_i,
	input  		  data_req_i,
	output     	  data_done_o,
	output [31:0] data_rdata_o,
	// ----------- outgoing
	// instr
	input  		  instr_we_o,
	input  [31:0] instr_adrs_o,
	input  [31:0] instr_wdata_o,
	input  [2:0]  instr_wsize_o,
	input  		  instr_req_o,
	output     	  instr_done_i,
	output [31:0] instr_rdata_i,
	// data
	input  		  data_we_o,
	input  [31:0] data_adrs_o,
	input  [31:0] data_wdata_o,
	input  [2:0]  data_wsize_o,
	input  		  data_req_o,
	output     	  data_done_i,
	output [31:0] data_rdata_i,
	// io
	output 		  io_we_o,
	output [31:0] io_adrs_o,
	output [31:0] io_wdata_o,
	output 		  io_req_o,
	input      	  io_done_i,
	input  [31:0] io_rdata_i
);

wire io_adrs_instr = instr_adrs_i >= 32'h20000000 && instr_adrs_i <= (32'h2000000c + 32'd4);

assign instr_we_o;
assign instr_adrs_o;
assign instr_wdata_o;
assign instr_wsize_o;
assign instr_req_o;
assign  = instr_done_i;
assign  = instr_rdata_i;

assign data_we_o;
assign data_adrs_o;
assign data_wdata_o;
assign data_wsize_o;
assign data_req_o;
assign  = data_done_i;
assign  = data_rdata_i;

assign io_we_o;
assign io_adrs_o;
assign io_wdata_o;
assign io_req_o;
assign  = io_done_i;
assign  = io_rdata_i;










endmodule
