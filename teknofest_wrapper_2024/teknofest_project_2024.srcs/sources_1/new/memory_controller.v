module memory_controller(
	input clk_i, rst_i,
	// instruction mem operations
	input  			mem_instr_we_i,
	input  [31:0]  mem_instr_adrs_i,
	input  [31:0]  mem_instr_wdata_i,
	input  [2:0]   mem_instr_wsize_i, // 0 > byte, 1 > half, 2 > word
	input  			mem_instr_req_i,
	output 			mem_instr_done_o,
	output [31:0]	mem_instr_rdata_o,
	// data mem operations
	input  			mem_data_we_i,
	input  [31:0]  mem_data_adrs_i,
	input  [31:0]  mem_data_wdata_i,
	input  [2:0]   mem_data_wsize_i, // 0 > byte, 1 > half, 2 > word
	input  			mem_data_req_i,
	output 			mem_data_done_o,
	output [31:0]	mem_data_rdata_o,
	// main mem operations
	output 		   mem_main_we_o,
	output [31:0]  mem_main_adrs_o,
	output [31:0]  mem_main_wdata_o,
	output [2:0]   mem_main_wsize_o,
	output 		   mem_main_req_o,
	input  		   mem_main_done_i,
	input  [31:0]  mem_main_rdata_i
);
// todo: instantiate cache here
endmodule;
