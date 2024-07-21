module Pipeline_top(
	input clk, rst_H,
	// instruction mem operations
	output 			mem_instr_we_o,
	output [31:0]  mem_instr_adrs_o,
	output [31:0]  mem_instr_wdata_o,
	output [2:0]   mem_instr_wsize_o,// 0 > byte, 1 > half, 2 > word
	output 			mem_instr_req_o,
	input  			mem_instr_done_i,
	input  [31:0]	mem_instr_rdata_i,
	// data mem operations
	output 			mem_data_we_o,
	output [31:0]  mem_data_adrs_o,
	output [31:0]  mem_data_wdata_o,
	output [2:0]   mem_data_wsize_o, // 0 > byte, 1 > half, 2 > word
	output 			mem_data_req_o,
	input  			mem_data_done_i,
	input  [31:0]	mem_data_rdata_i
);

	// translate pipeline signals into memory signals
	// and vice versa
	// could do sign extension here
	core_memory_interface cmi(
		.clk_i(clk), .rst_i(rst_H),
		// core signals
			// todo
		// external signals
		// instruction mem operations
		.mem_instr_we_o(mem_instr_we_o),
		.mem_instr_adrs_o(mem_instr_adrs_o),
		.mem_instr_wdata_o(mem_instr_wdata_o),
		.mem_instr_wsize_o(mem_instr_wsize_o),
		.mem_instr_req_o(mem_instr_req_o),
		.mem_instr_done_i(mem_instr_done_i),
		.mem_instr_rdata_i(mem_instr_rdata_i),
		// data mem operations
		.mem_data_we_o(mem_data_we_o),
		.mem_data_adrs_o(mem_data_adrs_o),
		.mem_data_wdata_o(mem_data_wdata_o),
		.mem_data_wsize_o(mem_data_wsize_o),
		.mem_data_req_o(mem_data_req_o),
		.mem_data_done_i(mem_data_done_i),
		.mem_data_rdata_i(mem_data_rdata_i)
	);

  
    // Declaration of Interim Wires
    wire rst_F,rst_D, rst_E, rst_M, rst_W;
    wire PCSrcE, RegWriteW, RegWriteE, JtypeE,ALUSrcE, MemWriteE, ResultSrcE, BranchE, RegWriteM, MemWriteM, ResultSrcM, ResultSrcW;
    wire [5:0] ALUControlE;
    wire [4:0] RD_E, RD_M, RDW;
    wire [31:0] PCTargetE, InstrD, PCD, PCPlus4D, ResultW, RD1_E, RD2_E, Imm_Ext_E, PCE, PCPlus4E, PCPlus4M, WriteDataM, ALU_ResultM;
    wire [31:0] PCPlus4W, ALU_ResultW, ReadDataW;
    wire [4:0] RS1_E, RS2_E;
    wire [1:0] ForwardBE, ForwardAE;
    wire [2:0] funct3_E, WordSize_M;
    
//    wire reservation_valid;
//    reg reservation_set;

    // Module Initiation
    // Fetch Stage
    fetch_cycle Fetch (
                        .clk(clk), 
                        .rst(rst_F), 
                        .PCSrcE(PCSrcE), 
                        .PCTargetE(PCTargetE), 
                        .InstrD(InstrD), 
                        .PCD(PCD), 
                        .PCPlus4D(PCPlus4D)
                    );

    // Decode Stage
    decode_cycle Decode (
                        .clk(clk), 
                        .rst(rst_D), 
                        .InstrD(InstrD), 
                        .PCD(PCD), 
                        .PCPlus4D(PCPlus4D), 
                        .RegWriteW(RegWriteW), 
                        .RDW(RDW), 
                        .ResultW(ResultW), 
                        .RegWriteE(RegWriteE), 
                        .ALUSrcE(ALUSrcE), 
                        .JtypeE(JtypeE),
                        .MemWriteE(MemWriteE), 
                        .ResultSrcE(ResultSrcE),
                        .BranchE(BranchE),  
                        .ALUControlE(ALUControlE), 
                        .RD1_E(RD1_E), 
                        .RD2_E(RD2_E), 
                        .Imm_Ext_E(Imm_Ext_E), 
                        .RD_E(RD_E), 
                        .PCE(PCE), 
                        .PCPlus4E(PCPlus4E),
                        .RS1_E(RS1_E),
                        .RS2_E(RS2_E),
                        .funct3_E(funct3_E) // output;
                    );

    // Execute Stage
    execute_cycle Execute (
                        .clk(clk), 
                        .rst(rst_E), 
                        .RegWriteE(RegWriteE), 
                        .ALUSrcE(ALUSrcE),
                        .MemWriteE(MemWriteE), 
                        .ResultSrcE(ResultSrcE), 
                        .BranchE(BranchE), 
                        .ALUControlE(ALUControlE), 
                        .RD1_E(RD1_E), 
                        .RD2_E(RD2_E), 
                        .Imm_Ext_E(Imm_Ext_E), 
                        .RD_E(RD_E), 
                        .PCE(PCE), 
                        .JtypeE(JtypeE),
                        .PCPlus4E(PCPlus4E), 
                        .PCSrcE(PCSrcE), 
                        .PCTargetE(PCTargetE), 
                        .RegWriteM(RegWriteM), 
                        .MemWriteM(MemWriteM), 
                        .ResultSrcM(ResultSrcM), 
                        .RD_M(RD_M), 
                        .PCPlus4M(PCPlus4M), 
                        .WriteDataM(WriteDataM), 
                        .ALU_ResultM(ALU_ResultM),
                        .ResultW(ResultW),
                        .ForwardA_E(ForwardAE),
                        .ForwardB_E(ForwardBE),
                        .funct3_E(funct3_E),
                        .WordSize_M(WordSize_M)
                    );
    
    // Memory Stage
    memory_cycle Memory (
                        .clk(clk), 
                        .rst(rst_M), 
                        .RegWriteM(RegWriteM), 
                        .MemWriteM(MemWriteM), 
                        .ResultSrcM(ResultSrcM), 
                        .RD_M(RD_M), 
                        .PCPlus4M(PCPlus4M), 
                        .WriteDataM(WriteDataM), 
                        .ALU_ResultM(ALU_ResultM), 
                        .RegWriteW(RegWriteW), 
                        .ResultSrcW(ResultSrcW), 
                        .RD_W(RDW), 
                        .PCPlus4W(PCPlus4W), 
                        .ALU_ResultW(ALU_ResultW), 
                        .ReadDataW(ReadDataW),
                        .WordSize_M(WordSize_M)
                    );

    // Write Back Stage
    writeback_cycle WriteBack (
                        .clk(clk), 
                        .rst(rst_W),
                        .RegWriteW(RegWriteW),
                        .ResultSrcW(ResultSrcW), 
                        .PCPlus4W(PCPlus4W), 
                        .ALU_ResultW(ALU_ResultW), 
                        .ReadDataW(ReadDataW), 
                        .ResultW(ResultW)
                    );

    // Hazard Unit
    hazard_unit Forwarding_block (
                        .rst_H(rst_H), 
                        .PCSrcE(PCSrcE),
                        .RegWriteM(RegWriteM), 
                        .RegWriteW(RegWriteW), 
                        .RD_M(RD_M), 
                        .RD_W(RDW), 
                        .Rs1_E(RS1_E), 
                        .Rs2_E(RS2_E), 
                        .ForwardAE(ForwardAE), 
                        .ForwardBE(ForwardBE),
                        .rst_F(rst_F), 
                        .rst_D(rst_D), 
                        .rst_E(rst_E), 
                        .rst_M(rst_M), 
                        .rst_W(rst_W)
                        );

endmodule
