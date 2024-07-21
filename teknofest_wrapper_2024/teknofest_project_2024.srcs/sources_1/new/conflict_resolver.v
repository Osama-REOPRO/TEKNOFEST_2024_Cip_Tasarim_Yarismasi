module conflict_resolver(
	input clk_i,
	input rst_i,
	// instr
	input  		   main_we_instr_i,
	input  [31:0]  main_adrs_instr_i,
	input  [127:0] main_wdata_instr_i,
	input  [15:0]  main_wstrb_instr_i,
	input  		   main_req_instr_i,
	output     		main_done_instr_o,
	output [127:0] main_rdata_instr_o,
	// data
	input  		   main_we_data_i,
	input  [31:0]  main_adrs_data_i,
	input  [127:0] main_wdata_data_i,
	input  [15:0]  main_wstrb_data_i,
	input  		   main_req_data_i,
	output     	 	main_done_data_o,
	output [127:0] main_rdata_data_o,
	// result
	output 		   main_we_o,
	output [31:0]  main_adrs_o,
	output [127:0] main_wdata_o,
	output [15:0]  main_wstrb_o,
	output 		   main_req_o,
	input      	 	main_done_i,
	input  [127:0] main_rdata_i
);
wire req_instr = main_req_instr_i;
wire req_data = main_req_data_i;

reg [3:0] allowed;
localparam none = 0, instr = 1, data = 2;

always @(clk_i) begin
	if (rst_i) begin
		// todo: reset regs
		allowed <= 0;
	end else begin
		case (allowed)
			none: begin
				if 		(req_instr) allowed <= instr;
				else if 	(req_data) 	allowed <= data;
				else 						allowed <= none;
			end
			instr: begin
				if (!main_req_o && !main_done_i) begin // done
					if (req_data) 	allowed <= data;
					else 				allowed <= none;
				end
			end
			data: begin
				if (!main_req_o && !main_done_i) begin // done
					if (req_instr) allowed <= instr;
					else 				allowed <= none;
				end
			end
		end
	end
end

assign main_we_o 	  = (allowed == instr)? main_we_instr_i		:(allowed == data)? main_we_data_i    : 0;
assign main_adrs_o  = (allowed == instr)? main_adrs_instr_i		:(allowed == data)? main_adrs_data_i  : 0;
assign main_wdata_o = (allowed == instr)? main_wdata_instr_i	:(allowed == data)? main_wdata_data_i : 0;
assign main_wstrb_o = (allowed == instr)? main_wstrb_instr_i	:(allowed == data)? main_wstrb_data_i : 0;
assign main_req_o   = (allowed == instr)? main_req_instr_i		:(allowed == data)? main_req_data_i   : 0;

assign main_done_instr_o  	= (allowed == instr)? 	main_done_i : 0;
assign main_done_data_o  	= (allowed == data)?		main_done_i : 0;
assign main_rdata_instr_o  = (allowed == instr)? 	main_rdata_i : 0;
assign main_rdata_data_o  	= (allowed == data)? 	main_rdata_i : 0;

endmodule
