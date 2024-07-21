`timescale 1us / 1ns
`include "cache_ops.vh"

module memory_controller(
	input clk_i, rst_i,
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
	// main mem operations
	output 		   main_we_o,
	output [31:0]  main_adrs_o,
	output [127:0] main_wdata_o,
	output [15:0]  main_wstrb_o, // careful, strb not size
	output 		   main_req_o,
	input      	 	main_done_i,
	input  [127:0] main_rdata_i
);

// todo: replace with final params
localparam C_instr = 32; // capacity (total words)
localparam b_instr = 4; // block size (words per block)
localparam N_instr = 1; // degree of associativity (blocks per set)

localparam C_data = 32; // capacity (total words)
localparam b_data = 4; // block size (words per block)
localparam N_data = 2; // degree of associativity (blocks per set)

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

	.main_we_o	  	(main_we_instr),
	.main_adrs_o  	(main_adrs_instr),
	.main_wdata_o 	(main_wdata_instr),
	.main_wstrb_o 	(main_wstrb_instr),
	.main_req_o		(main_req_instr),
	.main_done_i	(main_done_instr),
	.main_rdata_i	(main_rdata_instr)
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

	.main_we_o	  	(main_we_data),
	.main_adrs_o  	(main_adrs_data),
	.main_wdata_o 	(main_wdata_data),
	.main_wstrb_o 	(main_wstrb_data),
	.main_req_o		(main_req_data),
	.main_done_i	(main_done_data),
	.main_rdata_i	(main_rdata_data)
);

// todo
conflict_resolver con_res(
	.clk_i(clk_i),
	.rst_i(rst_i),
	// instr
	.main_we_instr_i	  (main_we_instr),
	.main_adrs_instr_i  (main_adrs_instr),
	.main_wdata_instr_i (main_wdata_instr),
	.main_wstrb_instr_i (main_wstrb_instr),
	.main_req_instr_i   (main_req_instr),
	.main_done_instr_o  (main_done_instr),
	.main_rdata_instr_o (main_rdata_instr),
	// data
	.main_we_data_i	  (main_we_data),
	.main_adrs_data_i   (main_adrs_data),
	.main_wdata_data_i  (main_wdata_data),
	.main_wstrb_data_i  (main_wstrb_data),
	.main_req_data_i    (main_req_data),
	.main_done_data_o   (main_done_data),
	.main_rdata_data_o  (main_rdata_data),
	// result
	.main_we_o	  		  (main_we_o),
	.main_adrs_o  		  (main_adrs_o),
	.main_wdata_o 		  (main_wdata_o),
	.main_wstrb_o 		  (main_wstrb_o),
	.main_req_o			  (main_req_o),
	.main_done_i		  (main_done_i),
	.main_rdata_i		  (main_rdata_i)
);

endmodule
