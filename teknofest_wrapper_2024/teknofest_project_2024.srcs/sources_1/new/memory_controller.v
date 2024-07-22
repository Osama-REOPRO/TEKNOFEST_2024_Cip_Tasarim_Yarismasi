`timescale 1us / 1ns
`include "cache_ops.vh"

module memory_controller(
	input clk_i, rst_i,
	// -------------------- core signals
	// instruction mem operations
	input   		  instr_we_i,
	input  [31:0] instr_adrs_i,
	input  [31:0] instr_wdata_i,
	input  [2:0]  instr_wsize_i, // 0:byte, 1:half, 2:word
	input   		  instr_req_i,
	output 		  instr_done_o,
	output [31:0] instr_rdata_o,
	// data mem operations
	input   		  data_we_i,
	input  [31:0] data_adrs_i,
	input  [31:0] data_wdata_i,
	input  [2:0]  data_wsize_i, // 0:byte, 1:half, 2:word
	input     	  data_req_i,
	output	  	  data_done_o,
	output [31:0] data_rdata_o,
	// -------------------- main mem signals
	output 		   main_we_o,
	output [31:0]  main_adrs_o,
	output [127:0] main_wdata_o,
	output [15:0]  main_wstrb_o, // careful, strb not size
	output 		   main_req_o,
	input      	 	main_done_i,
	input  [127:0] main_rdata_i,
	// -------------------- memory-mapped i/o signals
	output 		   io_we_o,
	output [31:0]  io_adrs_o,
	output [31:0]  io_wdata_o,
	// input  [2:0]  data_wsize_i, // ignored, always word read/write
	output 		   io_req_o,
	input      	 	io_done_i,
	input  [31:0]  io_rdata_i
);

// todo: replace with final params
localparam C_instr = 32; // capacity (total words)
localparam b_instr = 4; // block size (words per block)
localparam N_instr = 1; // degree of associativity (blocks per set)

localparam C_data = 32; // capacity (total words)
localparam b_data = 4; // block size (words per block)
localparam N_data = 2; // degree of associativity (blocks per set)

// ----------------- intermediate signals
// between io router and caches
wire 		    instr_we;
wire [31:0]  instr_adrs;
wire [31:0]  instr_wdata;
wire [2:0]   instr_wstrb;
wire 		    instr_req;
wire     	 instr_done;
wire [31:0]  instr_rdata;

wire 		    data_we;
wire [31:0]  data_adrs;
wire [31:0]  data_wdata;
wire [2:0]   data_wstrb;
wire 		    data_req;
wire     	 data_done;
wire [31:0]  data_rdata;
// between caches and main mem
wire 		    instr_main_we;
wire [31:0]  instr_main_adrs;
wire [127:0] instr_main_wdata;
wire [15:0]  instr_main_wstrb;
wire 		    instr_main_req;
wire     	 instr_main_done;
wire [127:0] instr_main_rdata;

wire 		    data_main_we;
wire [31:0]  data_main_adrs;
wire [127:0] data_main_wdata;
wire [15:0]  data_main_wstrb;
wire 		    data_main_req;
wire     	 data_main_done;
wire [127:0] data_main_rdata;

memory_mapped_io_router io_router (
	.clk_i(clk_i),
	.rst_i(rst_i),
	// -------------- incoming
	// instr
	.instr_we_i	   (instr_we_i),
	.instr_adrs_i  (instr_adrs_i),
	.instr_wdata_i (instr_wdata_i),
	.instr_wsize_i (instr_wsize_i),
	.instr_req_i   (instr_req_i),
	.instr_done_o  (instr_done_o),
	.instr_rdata_o (instr_rdata_o),
	// data
	.data_we_i	   (data_we_i),
	.data_adrs_i   (data_adrs_i),
	.data_wdata_i  (data_wdata_i),
	.data_wsize_i  (data_wsize_i),
	.data_req_i    (data_req_i),
	.data_done_o   (data_done_o),
	.data_rdata_o  (data_rdata_o),
	// -------------- result
	// instr
	.instr_we_o	   (instr_we),
	.instr_adrs_o  (instr_adrs),
	.instr_wdata_o (instr_wdata),
	.instr_wstrb_o (instr_wsize),
	.instr_req_o   (instr_req),
	.instr_done_i  (instr_done),
	.instr_rdata_i (instr_rdata),
	// data
	.data_we_o	   (data_we),
	.data_adrs_o   (data_adrs),
	.data_wdata_o  (data_wdata),
	.data_wstrb_o  (data_wsize),
	.data_req_o    (data_req),
	.data_done_i   (data_done),
	.data_rdata_i  (data_rdata),
	// io memory map
	.io_we_o	  		(io_we_o),
	.io_adrs_o  	(io_adrs_o),
	.io_wdata_o 	(io_wdata_o),
	.io_req_o		(io_req_o),
	.io_done_i		(io_done_i),
	.io_rdata_i		(io_rdata_i)
);

cache_controller
#(
	.C(C_instr), // capacity (words)
	.b(b_instr), // block size (words in block)
	.N(N_instr)  // degree of associativity
) 
cache_ctrl_instr
(
	.clk_i(clk_i),
	.rst_i(rst_i),

	.we_i		(instr_we_i),
	.adrs_i	(instr_adrs_i),
	.wdata_i (instr_wdata_i),
	.wsize_i (instr_wsize_i),
	.req_i	(instr_req_i),
	.done_o	(instr_done_o),
	.rdata_o (instr_rdata_o),

	.main_we_o	  	(instr_main_we),
	.main_adrs_o  	(instr_main_adrs),
	.main_wdata_o 	(instr_main_wdata),
	.main_wstrb_o 	(instr_main_wstrb),
	.main_req_o		(instr_main_req),
	.main_done_i	(instr_main_done),
	.main_rdata_i	(instr_main_rdata)
);

cache_controller
#(
	.C(C_data), // capacity (words)
	.b(b_data), // block size (words in block)
	.N(N_data)  // degree of associativity
) 
cache_ctrl_data
(
	.clk_i(clk_i),
	.rst_i(rst_i),

	.we_i		(data_we_i),
	.adrs_i	(data_adrs_i),
	.wdata_i (data_wdata_i),
	.wsize_i (data_wsize_i),
	.req_i	(data_req_i),
	.done_o	(data_done_o),
	.rdata_o (data_rdata_o),

	.main_we_o	  	(data_main_we),
	.main_adrs_o  	(data_main_adrs),
	.main_wdata_o 	(data_main_wdata),
	.main_wstrb_o 	(data_main_wstrb),
	.main_req_o		(data_main_req),
	.main_done_i	(data_main_done),
	.main_rdata_i	(data_main_rdata)
);

// resolve conflicts between signals coming from caches to main
conflict_resolver_caches_main con_res_main(
	.clk_i(clk_i),
	.rst_i(rst_i),
	// instr
	.instr_we_i	   (instr_main_we),
	.instr_adrs_i  (instr_main_adrs),
	.instr_wdata_i (instr_main_wdata),
	.instr_wstrb_i (instr_main_wstrb),
	.instr_req_i   (instr_main_req),
	.instr_done_o  (instr_main_done),
	.instr_rdata_o (instr_main_rdata),
	// data
	.data_we_i	   (data_main_we),
	.data_adrs_i   (data_main_adrs),
	.data_wdata_i  (data_main_wdata),
	.data_wstrb_i  (data_main_wstrb),
	.data_req_i    (data_main_req),
	.data_done_o   (data_main_done),
	.data_rdata_o  (data_main_rdata),
	// result
	.res_we_o	  	(main_we_o),
	.res_adrs_o  	(main_adrs_o),
	.res_wdata_o 	(main_wdata_o),
	.res_wstrb_o 	(main_wstrb_o),
	.res_req_o		(main_req_o),
	.res_done_i		(main_done_i),
	.res_rdata_i	(main_rdata_i)
);

endmodule
