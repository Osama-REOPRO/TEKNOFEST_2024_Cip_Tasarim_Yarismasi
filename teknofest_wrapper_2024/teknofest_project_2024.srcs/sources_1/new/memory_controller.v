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
localparam C = 8; // capacity (total words)
localparam b = 4; // block size (words per block)
localparam N = 2; // degree of associativity (blocks per set)

// todo: correct params
cache 
#(
	.C(C), // capacity (words)
	.b(b), // block size (words in block)
	.N(N)  // degree of associativity
) 
cache
(
	.i_clk(i_clk),
	.i_rst(i_rst),

	.i_op(op),

	.i_address(i_address),

	.i_set_valid(set_valid),
	.i_set_tag(set_tag),
	.i_set_dirty(set_dirty),
	.i_set_use(set_use),

	.i_mem_operation(mem_operation[1]),

	.o_hit_occurred(hit_occurred[1]),
	.o_empty_found(empty_found[1]),
	.o_clean_found(clean_found[1]),

	.i_valid_bytes(valid_bytes_L1),

	.i_write_data(write_data_L1),
	.o_read_data(read_data_L1),

	.o_mem_operation_done(mem_operation_done[1])
);

endmodule;
