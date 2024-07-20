`timescale 1us / 1ns
`include "cache_ops.vh"

module memory_controller(
	input clk_i, rst_i,
	// instruction mem operations
	input  			mem_instr_we_i,
	input  [31:0]  mem_instr_adrs_i,
	input  [31:0]  mem_instr_wdata_i,
	input  [2:0]   mem_instr_wsize_i, // 0:byte, 1:half, 2:word
	input  			mem_instr_req_i,
	output 			mem_instr_done_o,
	output [31:0]	mem_instr_rdata_o,
	// data mem operations
	input  				mem_data_we_i,
	input  [31:0]  	mem_data_adrs_i,
	input  [31:0]  	mem_data_wdata_i,
	input  [2:0]   	mem_data_wsize_i, // 0:byte, 1:half, 2:word
	input  				mem_data_req_i,
	output reg			mem_data_done_o,
	output reg [31:0]	mem_data_rdata_o,
	// main mem operations
	output 		   mem_main_we_o,
	output [31:0]  mem_main_adrs_o,
	output [31:0]  mem_main_wdata_o,
	output [2:0]   mem_main_wsize_o,
	output 		   mem_main_req_o,
	input  		   mem_main_done_i,
	input  [31:0]  mem_main_rdata_i
);
// data cache (dc)
reg [`op_N:0]  op_dc;
reg 				mem_operation_dc;
wire 				mem_operation_done_dc;
reg  [15:0]		valid_bytes_dc;
reg  [128:0] 	write_data_dc;
wire [128:0] 	read_data_dc;

// todo: correct params
localparam C_dc = 32; // capacity (total words)
localparam b_dc = 4; // block size (words per block)
localparam N_dc = 2; // degree of associativity (blocks per set)

reg set_valid_dc;
reg set_tag_dc;
reg set_dirty_dc;
reg set_use_dc;

wire hit_occurred_dc;
wire empty_found_dc;
wire clean_found_dc;

// state machine
reg [3:0] state_dc;
localparam idle_st	= 0,
			  lookup_st	= 1,
			  read_st	= 2,
			  write_st	= 3,
			  done_st	= 4;

reg [3:0] cache_sub_state;
localparam init   = 0,
			  busy   = 1,
			  finish = 2;

reg [3:0] op_sub_state;
// read sub states
localparam read_L1_st    = 0,
			  read_Main_st  = 1,
			  read_done_st  = 2;
// write sub states
localparam write_L1_st   = 0,
			  write_Main_st = 1,
			  write_done_st = 2;

integer i;
always @(posedge clk_i) begin
	if(rst_i) begin
		i 						<= 0;
		state_dc				<= 0;
		cache_sub_state	<= 0;
		op_sub_state		<= 0;

		{	op_dc,
			mem_operation_dc,
		 	valid_bytes_dc,
		 	write_data_dc,
			set_valid_dc,
			set_tag_dc,
			set_dirty_dc,
			set_use_dc
			} <= 0;

	end else begin
		case (state_dc)

			idle_st: begin
				mem_data_done_o <= 1'b0;
				if (mem_data_req_i) begin
					state_dc <= lookup_st;
				end
			end

			done_st: begin
				mem_data_done_o = 1'b1;
				if (!mem_data_req_i) state_dc = idle_st;
			end

			lookup_st: begin
				// todo
			end

			read_st: begin
				// todo
			end

			write_st: begin
				// todo
			end

		endcase
	end
end

cache 
#(
	.C(C), // capacity (words)
	.b(b), // block size (words in block)
	.N(N)  // degree of associativity
) 
cache_data
(
	.i_clk(clk_i),
	.i_rst(rst_i),

	.i_op(op_dc),

	.i_address(mem_data_adrs_i),

	// todo: decide how these work
	.i_set_valid(set_valid_dc),
	.i_set_tag(set_tag_dc),
	.i_set_dirty(set_dirty_dc),
	.i_set_use(set_use_dc),

	.i_mem_operation(mem_operation_dc),

	.o_hit_occurred(hit_occurred_dc),
	.o_empty_found(empty_found_dc),
	.o_clean_found(clean_found_dc),

	.i_valid_bytes(valid_bytes_dc),

	.i_write_data(write_data_dc),
	.o_read_data(read_data_dc),

	.o_mem_operation_done(mem_operation_done_dc)
);
//
// todo: add instruction cache
// because treatment is identical for both caches, maybe just turn all that
// into a new module and instantiate it twice

endmodule;
