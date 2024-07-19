`timescale 1us / 1ns

module vr_mem
#(
	parameter size = 32 // number of words
)
(
	input         		i_clk, 
	input      			i_rst,

	input      		 	i_mem_write,
	input		  [31:0]	i_address,

	input  	  [7:0] 	i_write_data,
	output reg [7:0] 	o_read_data,

	input 				i_mem_operation,
	output 				o_mem_operation_done
);
	reg [7:0] mem [size:0] [3:0]; // 4 bytes in each word
	integer i;
	// state machine vars
	localparam idle_st = 0, read_st = 1, write_st = 2, valid_st = 3;
	reg [$clog2(3)-1:0] state;

	assign o_mem_operation_done = state == valid_st;

	always @(posedge i_clk) begin
		if (i_rst) begin
			i <= 0;
			state <= 0;
			o_read_data <= 0;
			for (i=0; i<=size; i=i+1) begin
				{mem[i][3], mem[i][2], mem[i][1], mem[i][0]} <= 0;
			end
		end else begin
			case(state)
				idle_st: begin
					if (i_mem_operation) begin
						state <= i_mem_write ? write_st : read_st;
					end
				end
				read_st: begin
					o_read_data <= #20000 mem[i_address[31:2]][i_address[1:0]];
					#20000;
					state <= valid_st;
				end
				write_st: begin
					mem[i_address[31:2]][i_address[1:0]] <= #20000 i_write_data;
					#20000;
					state <= valid_st;
				end
				valid_st: begin
					if (!i_mem_operation) begin
						state <= idle_st;
					end
				end
			endcase
		end
	end
endmodule
