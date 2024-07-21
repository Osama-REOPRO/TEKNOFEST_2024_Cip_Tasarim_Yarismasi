`timescale 1us / 1ns
`include "cache_ops.vh"

module cache_controller();
// data cache (dc)
reg [`op_N:0]  op_dc;
reg 				mem_operation_dc;
wire 				mem_operation_done_dc;
reg  [15:0]		valid_bytes_dc;
reg  [127:0] 	write_data_dc;
wire [127:0] 	read_data_dc;


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
localparam read_begin_st = 0,
			  read_cache_st = 1,
			  read_main_st  = 2,
			  read_done_st  = 3;
// write sub states
localparam write_begin_st = 0,
			  write_cache_st = 1,
			  write_main_st  = 2,
			  write_done_st  = 3;

// ######################################### state machine tasks
// read_op: miss and no clean nor empty
// write_op: miss and no clean nor empty
wire evac_needed_dc = !hit_occurred_dc || (!empty_found_dc && !clean_found_dc);
// read_op: we read if hit or need evac
// write_op: we read if need evac
wire read_needed_cache_dc = evac_needed_dc || (op_dc && hit_occurred_dc);
// read_op: miss
// write_op: miss
wire read_needed_main_dc = !hit_occurred_dc;
// read_op: evac_needed_dc
// write_op: write_op or evac_needed_dc
wire write_needed_cache_dc = (op_dc == `write_op) || evac_needed_dc;
// read_op: evac_needed_dc
// write_op: evac_needed_dc
wire write_needed_main_dc = evac_needed_dc;

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
				case (cache_sub_state)
					init: begin
						op_dc 				<= `lookup_op;
						mem_operation_dc 	<= 1'b1;

						cache_sub_state   <= busy;
					end
					busy: begin
						if (mem_operation_done_dc) begin
							mem_operation_dc <= 1'b0;

							cache_sub_state 	  <= finish;
						end
					end
					finish: begin
						if (!mem_operation_done_dc) begin
							if (read_needed_cache_dc || read_needed_main_dc) 	state_dc <= read_st;
							else 																state_dc <= write_st;

							cache_sub_state <= init;
						end
					end
				endcase
			end

			read_st: begin
				case (op_sub_state)

					read_begin_st: begin
						op_sub_state <= read_needed_cache_dc? read_cache_st : read_main_st;
					end

					read_cache_st: begin
						// either we read to evacuate, or we read to return
						case (cache_sub_state)
							init: begin
								op_dc 			   <= `read_op;
								mem_operation_dc  <= 1'b1;
								valid_bytes_dc <= {(4*b_dc){1'b1}}; // how about all valid? while reading that it

								cache_sub_state		<= busy;
							end
							busy: begin
								if (mem_operation_done_dc) begin
									mem_operation_dc <= 1'b0;

									cache_sub_state 	  <= finish;
								end
							end
							finish: begin
								if (!mem_operation_done_dc) begin
									if ((op_dc == `read_op) && hit_occurred_dc) begin
										// if hit occurred and we are in read state then we simply return the data
										mem_data_rdata_o <= read_data_dc[(mem_data_adrs_i[3:2]*32)-1 +: 32]; // todo: verify
										op_sub_state <= read_done_st;
									end else begin
										op_sub_state <= read_main_st;
									end

									cache_sub_state  <= init;
								end
							end
						endcase
					end

					read_main_st: begin
						case (cache_sub_state)
							init: begin
								mem_main_we_o   <= 1'b0; // read op
								mem_main_req_o  <= 1'b1;

								cache_sub_state <= busy;
							end
							busy: begin
								if (mem_main_done_i) begin
									mem_main_req_o  <= 1'b0;

									cache_sub_state <= finish;
								end
							end
							finish: begin
								if (!mem_main_done_i) begin
									if (op_dc == `read_op) mem_data_rdata_o <= read_data_dc[(mem_data_adrs_i[3:2]*32)-1 +: 32]; // todo: verify

									op_sub_state <= read_done_st;
									cache_sub_state  <= init;
								end
							end
						endcase
					end

					read_done_st: begin
						if (write_needed_cache_dc || write_needed_main_dc) op_sub_state <= write_st;
						else op_sub_state <= done_st;

						op_sub_state <= read_begin_st;
					end

				endcase
			end

			write_st: begin
				// todo
				case (op_sub_state)

					write_begin_st: begin
						if (write_needed_cache_dc) op_sub_state <= write_cache_st;
						else op_sub_state <= write_main_st;
					end

					write_cache_st: begin
						case (cache_sub_state)
							init: begin
								op_dc 			   <= `write_op;
								mem_operation_dc  <= 1'b1;

								// valid_bytes_dc depend on whether we are writing
								// from input or we are writing missing data from main
								// mem. If we are writing from input then valid bytes
								// will be determined by mem_data_wsize_i, if we are
								// writing missing data from above then all are valid
								if (hit_occurred_dc) begin
									// only write valid bytes from input
									case (mem_data_wsize_i) // 0:byte, 1:half, 2:word
										2'h0: begin
											// byte, must be at the beginning of input word
											valid_bytes_dc <= {(4*b_dc){1'b0}};
											valid_bytes_dc[mem_data_adrs_i % (4*b_dc)] <= 1'b1; // todo: verify

											write_data_dc[((mem_data_adrs_i % (4*b_dc))*8)-1 +:8] <= mem_data_wdata_i[7:0]; // todo: verify
										end
										2'h1: begin
											// half word, must be at beginning of word (lower half)
											valid_bytes_dc <= {(4*b_dc){1'b0}};
											valid_bytes_dc[(mem_data_adrs_i*2) % (4*b_dc) +:2] <= 2'b11; // todo: verify

											write_data_dc[(((mem_data_adrs_i*2) % (4*b_dc))*16)-1 +:16] <= mem_data_wdata_i[15:0]; // todo: verify
										end
										2'h2: begin
											// word
											valid_bytes_dc <= {(4*b_dc){1'b0}};
											valid_bytes_dc[(mem_data_adrs_i*4) % (4*b_dc) +:4] <= 4'b1111; // todo: verify

											write_data_dc[(((mem_data_adrs_i*4) % (4*b_dc))*32)-1 +:32] <= mem_data_wdata_i; // todo: verify
										end
									endcase
								end else begin
									// write all from above
									valid_bytes_dc <= {(4*b_dc){1'b1}}; // all valid
									write_data_dc <= mem_main_rdata_i; // todo: verify
								end

								cache_sub_state		<= busy;
							end
							busy: begin
								if (mem_operation_done_dc) begin
									mem_operation_dc <= 1'b0;

									cache_sub_state 	  <= finish;
								end
							end
							finish: begin
								if (!mem_operation_done_dc) begin
									if (write_needed_main_dc) 	op_sub_state <= write_main_st;
									else 								op_sub_state <= write_done_st;

									cache_sub_state  <= init;
								end
							end
						endcase
					end

			  		write_main_st: begin
						// todo
						case (cache_sub_state)
							init: begin
								mem_main_we_o <= 1'b1;
								mem_main_req_o  <= 1'b1;
								mem_main_wstrb_o <= {(16){1'b1}}; // all valid
								mem_main_wdata_o <= read_data_dc; // we must be evacuating

								cache_sub_state		<= busy;
							end
							busy: begin
								if (mem_main_done_i) begin
									mem_main_req_o <= 1'b0;

									cache_sub_state 	  <= finish;
								end
							end
							finish: begin
								if (!mem_main_done_i) begin
									op_sub_state <= write_done_st;

									cache_sub_state  <= init;
								end
							end
						endcase
					end

			  		write_done_st: begin
						state_dc <= done_st;

						op_sub_state <= write_begin_st;
					end

				endcase
			end

		endcase
	end
end

cache 
#(
	.C(C_dc), // capacity (words)
	.b(b_dc), // block size (words in block)
	.N(N_dc)  // degree of associativity
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
endmodule
