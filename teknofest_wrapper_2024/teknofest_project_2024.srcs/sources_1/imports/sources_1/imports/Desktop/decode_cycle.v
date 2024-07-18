module decode_cycle(clk, rst, InstrD, PCD, PCPlus4D, RegWriteW, RDW, ResultW, RegWriteE, ALUSrcE, MemWriteE, ResultSrcE,
    BranchE,  ALUControlE, RD1_E,JtypeE, RD2_E, Imm_Ext_E, RD_E, PCE, PCPlus4E, RS1_E, RS2_E,
    funct3_E);

    // Declaring I/O
    input clk, rst, RegWriteW;
    input [4:0] RDW;
    input [31:0] InstrD, PCD, PCPlus4D, ResultW;

    output RegWriteE,ALUSrcE,MemWriteE,JtypeE,ResultSrcE,BranchE;
    output [5:0] ALUControlE;
    output [31:0] RD1_E, RD2_E, Imm_Ext_E;
    output [4:0] RS1_E, RS2_E, RD_E;
    output [31:0] PCE, PCPlus4E;
    output [3:0] funct3_E;

    // Declare Interim Wires
    wire RegWriteD,ALUSrcD,MemWriteD,ResultSrcD,BranchD,JtypeD;
    wire [2:0] ImmSrcD;
    wire [5:0] ALUControlD;
    wire [31:0] RD1_D, RD2_D, Imm_Ext_D;

    // Declaration of Interim Register
    reg RegWriteD_r,ALUSrcD_r,MemWriteD_r,ResultSrcD_r,BranchD_r,JtypeD_r;
    reg [5:0] ALUControlD_r;
    reg [31:0] RD1_D_r, RD2_D_r, Imm_Ext_D_r;
    reg [4:0] RD_D_r, RS1_D_r, RS2_D_r;
    reg [31:0] PCD_r, PCPlus4D_r;
    reg [3:0] funct3_D_r;


    // Initiate the modules
    // Control Unit
    Control_Unit_Top control (
                            .Op(InstrD[6:0]),
                            .RegWrite(RegWriteD),
                            .ImmSrc(ImmSrcD),
                            .ALUSrc(ALUSrcD),
                            .MemWrite(MemWriteD),
                            .Jtype(JtypeD),
                            .ResultSrc(ResultSrcD),
                            .Branch(BranchD),
                            .funct3(InstrD[14:12]),
                            .funct7(InstrD[31:25]),
                            .funct5(InstrD[24:20]),
                            .ALUControl(ALUControlD)
                            );

    // Register File
    Integer_RF I_rf (
                        .clk(clk),
                        //.rst(rst),
                        .WE3(RegWriteW),
                        .WD3(ResultW),
                        .A1(InstrD[19:15]),
                        .A2(InstrD[24:20]),
                        .A3(RDW),
                        .RD1(RD1_D),
                        .RD2(RD2_D)
                        );

    // Sign Extension
    Sign_Extend_Immediate extension (
                        .In(InstrD),
                        .Imm_Ext(Imm_Ext_D),
                        .ImmSrc(ImmSrcD)
                        );

    // Declaring Register Logic
    always @(negedge rst) begin
        RegWriteD_r <= 1'b0;
        ALUSrcD_r <= 1'b0;
        MemWriteD_r <= 1'b0;
        ResultSrcD_r <= 1'b0;
        BranchD_r <= 1'b0;
        JtypeD_r <= 1'b0;    
        ALUControlD_r <= 6'b0000000;
        RD1_D_r <= 32'h00000000; 
        RD2_D_r <= 32'h00000000; 
        Imm_Ext_D_r <= 32'h00000000;
        RD_D_r <= 5'h00;
        PCD_r <= 32'h00000000; 
        PCPlus4D_r <= 32'h00000000;
        RS1_D_r <= 5'h00;
        RS2_D_r <= 5'h00;
        funct3_D_r <= 3'h0;
    end
    always @(posedge clk) 
        begin
            RegWriteD_r <= RegWriteD;
            ALUSrcD_r <= ALUSrcD;
            MemWriteD_r <= MemWriteD;
            ResultSrcD_r <= ResultSrcD;
            BranchD_r <= BranchD;
            JtypeD_r <= JtypeD; 
            ALUControlD_r <= ALUControlD;
            RD1_D_r <= RD1_D; 
            RD2_D_r <= RD2_D; 
            Imm_Ext_D_r <= Imm_Ext_D;
            RD_D_r <= InstrD[11:7];
            PCD_r <= PCD; 
            PCPlus4D_r <= PCPlus4D;
            RS1_D_r <= InstrD[19:15];
            RS2_D_r <= InstrD[24:20];
            funct3_D_r <= InstrD[14:12];
        end

    // Output asssign statements
    assign RegWriteE = RegWriteD_r;
    assign ALUSrcE = ALUSrcD_r;
    assign MemWriteE = MemWriteD_r;
    assign ResultSrcE = ResultSrcD_r;
    assign BranchE = BranchD_r;
    assign JtypeE = JtypeD_r; //CAUSED Jtype TO ACT CORRECTLY IN THE WAVEFORM, ALSO MAKES US ONLY FETCH TWO INSTRUCTIONS
    assign ALUControlE = ALUControlD_r;
    assign RD1_E = RD1_D_r;
    assign RD2_E = RD2_D_r;
    assign Imm_Ext_E = Imm_Ext_D_r;
    assign RD_E = RD_D_r;
    assign PCE = PCD_r;
    assign PCPlus4E = PCPlus4D_r;
    assign RS1_E = RS1_D_r;
    assign RS2_E = RS2_D_r;
    assign funct3_E = funct3_D_r;

endmodule

module Control_Unit_Top(Op,RegWrite,Jtype,ImmSrc,ALUSrc,MemWrite,ResultSrc,Branch,funct3,funct5,funct7,ALUControl);

    input [6:0]Op,funct7;
    input [2:0]funct3;
    input [4:0]funct5;
    output RegWrite,Jtype,ALUSrc,MemWrite,ResultSrc,Branch;
    output [2:0] ImmSrc;
    output [5:0] ALUControl;

    wire [2:0]ALUOp;

    Main_Decoder Main_Decoder(
                .Op(Op),
                .RegWrite(RegWrite),
                .ImmSrc(ImmSrc),
                .MemWrite(MemWrite),
                .ResultSrc(ResultSrc),
                .Branch(Branch),
                .ALUSrc(ALUSrc),
                .ALUOp(ALUOp),
                .Jtype(Jtype)
    );

    ALU_Decoder ALU_Decoder(
                            .ALUOp(ALUOp),
                            .funct3(funct3),
                            .funct7(funct7),
                            .funct5(funct5),
                            .ALUControl(ALUControl)
    );


endmodule

module Sign_Extend_Immediate (In, ImmSrc, Imm_Ext);
    input [31:0] In;
    input [2:0] ImmSrc;
    output [31:0] Imm_Ext;

    assign Imm_Ext = (ImmSrc == 3'b000) ? {{20{In[31]}}, In[31:20]} : // I-type
                     (ImmSrc == 3'b001) ? {{20{In[31]}}, In[30:25], In[11:7]} : // S-type
                     (ImmSrc == 3'b010) ? {{19{In[31]}}, In[7], In[30:25], In[11:8], 1'b0} : // B-type
                     //LUI NEEDS NO OPERATION, CALCULATING THE IMMEDIATE ALLREADY SHIFTS IT BY 12
                     (ImmSrc == 3'b011) ? {In[31:12], 12'b0} : // U-type (LUI/AUIPC)
                     (ImmSrc == 3'b100) ? {{12{In[31]}}, In[19:12], In[20], In[30:21], 1'b0} : // J-type (JAL)
                     32'h00000000; // Default
endmodule


module Main_Decoder(Op, RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jtype);
    input [6:0] Op;
    output RegWrite, ALUSrc, MemWrite, ResultSrc, Branch, Jtype;
    output [2:0] ImmSrc, ALUOp;
    
    wire Load, JALR, ImmediateOP, Rtype, LUI, AUIPC, Itype, Utype, Store, Atomic;
    assign Load = (Op === 7'b0000011);
    assign ImmediateOP = (Op === 7'b0010011); // Immediate operations excluding loads
    assign Rtype = (Op === 7'b0110011);
    assign LUI = (Op === 7'b0110111);
    assign AUIPC = (Op === 7'b0010111);
    assign Utype = (LUI || AUIPC);
    assign JALR = (Op === 7'b1100111);
    assign Itype = (ImmediateOP || Load || JALR );
    assign Jtype = (Op === 7'b1101111); // THAT IS JAL, since JAL is the only Jtype insturction in I
    assign Branch = (Op === 7'b1100011);
    assign Store = (Op === 7'b0100011);
    assign Atomic = (Op === 7'b0101111);
        
    assign RegWrite = (~(Branch || Store));  // ALL instructios write to register except B and S

    assign ImmSrc = Store ? 3'b001 : // S-type: Stores
                    Branch ? 3'b010 : // B-type: branches
                    Utype ? 3'b011 : // U-type: LUI/AUIPC
                    Jtype ? 3'b100 : // J-type: JAL
                    3'b000; // Default - I-type (b0000011 and b0010011)

    assign ALUSrc = (Store || Utype || Itype ); // 1 for immediate and 0 for register

    assign MemWrite = Store; // Store

    assign ResultSrc = Load; // Load

    assign ALUOp = Rtype ? 3'b010 :  /*I AND M*/ 
                   Branch ? 3'b001 : // Branches
                   (ImmediateOP) ? 3'b000 : // I-type except loads and stores
                   (Load || Store) ? 3'b011 : // I, M and F
                   (LUI) ? 3'b100 :  
                   (AUIPC) ? 3'b101 :
                   (Jtype || JALR) ? 3'b110:
                   3'bxxx; // Default
                   
    
    assign isFPUOp = (Op[6:5] == 2'b10);
//    assign FPUOp = (Op == 7'b1010011) ? 2'b00: //R-TYPE: literarly all F except load, store, and fuse instructions.
//                   (Op == 7'b100xx11) ? 2'b01: // R4-Type (fuse instructions): FMADD, FMSUB, FNMSUB, FNMADD
//                   2'bxx; // Default

    //assign AlUorFPU = ALUOp ? 1'b0: 1'b1;
    
    
endmodule



module ALU_Decoder(ALUOp, funct3, funct5, funct7, ALUControl);
    input [2:0] ALUOp;
    input [2:0] funct3;
    input [4:0] funct5;
    input [6:0] funct7;
    output [5:0] ALUControl;
    /*
    000000: ADD
    000001: SUB
    000010: AND
    000011: OR
    000100: XOR
    000101: SLL, SLLI
    000110: SRLL, SRLI
    000111: SRA
    001000: SLT
    001001: SLTU
    001010: MUL
    001011: MULH, MULHU , MULHSU
    001100: DIV, DIVU
    001101: REM, REMU
    001110: LUI (imm << 12)
    001111: AUIPC
    010000: JAL, JALR
    BRANCH INSTRUCTIONS ARE NEG ENABLED BCZ THEY ARE HIGH WHEN THEY RESULT IN ZERO
    010001: BNE
    010010: BLT
    010011: BLTU
    
    010100: CLZ
    010101: CPOP
    010110: CTZ
    010111: ORC.B
    011000: REV8
    011001: RORI, ROR
    011010: BCLR, BCLRI
    011011: BEXT, BEXTI
    011100: BINV, BINVI
    011101: BSET, BSETI
    011110: SEXT.B
    011111: SEXT.H
    100000: ANDN
    100001: CLMUL
    100010: CLMULH
    100011: CLMULR
    100100: MAX
    100101: MAXU
    100110: MIN
    100111: MINU
    101000: ORN
    101001: ROL
    101010: SH1ADD
    101011: SH2ADD
    101100: SH3ADD
    101101: XNOR
    101110: ZEXT.H
    
    101111: 
    110000: 
    110001: 
    110010: 
    110011:    
    110100
    110101
    110110
    110111
    111000
    111001
    111010
    111011
    111100
    111101
    */
    assign ALUControl = (ALUOp == 3'b000) ?
                             (funct3 == 3'b000) ? 6'b000000 : // ADDI -> ADD
                             (funct3 == 3'b010) ? 6'b001000 : // SLTI
                             (funct3 == 3'b011) ? 6'b001001 : // SLTIU
                             (funct3 == 3'b100) ? 6'b000100 : // XORI
                             (funct3 == 3'b110) ? 6'b000011 : // ORI
                             (funct3 == 3'b111) ? 6'b000010 : // ANDI
                             (funct3 == 3'b101) ?
                                ((funct7 == 7'b0000000) ? 6'b000110 : // SRLI
                                (funct7 == 7'b0100000) ? 6'b000111 : // SRAI
                                (funct7 == 7'b0110100) ? 6'b011000 : // rev8
                                (funct7 == 7'b0110000) ? 6'b011001 : // RORI
                                (funct7 == 7'b0100100) ? 6'b011011 : // bext
                                6'bxxxxxx) : //default
                             (funct3 == 3'b001) ? 
                                (funct7 == 7'b0010011) ? 6'b000101 : // SLLI
                                (funct7 == 7'b0110000 ) ? 
                                   ((funct5 == 5'b00000) ? 6'b010100 : //CLZ
                                    (funct5 == 5'b00001) ? 6'b010110 : // CTZ
                                    (funct5 == 5'b00010) ? 6'b010101 : //CPOP
                                    (funct5 == 5'b00100) ? 6'b011110 : // sext.b
                                    (funct5 == 5'b00101) ? 6'b011111 : // sext.h
                                    6'bxxxxxx) : //default 
                                 (funct7 == 7'b0010100) ? 
                                    (funct5 == 5'b00111) ? 6'b010111 :// orc.b
                                     6'b011101 : // bseti
                                (funct7 == 7'b0100100) ?  6'b011010 :// bclr
                                (funct7 == 7'b0110100) ? 6'b011100 : // binv
                                6'bxxxxxx:
                             6'bxxxxxx : // Default
                        (ALUOp == 3'b001) ? //Branch
                             (funct3 == 3'b000) ? 6'b000001 : // BEQ - > SUB
                             (funct3 == 3'b001) ? 6'b010001 : // BNE
                             (funct3 == 3'b100) ? 6'b010010 : // BLT
                             (funct3 == 3'b101) ? 6'b001000 : // BGE -> SLT
                             (funct3 == 3'b110) ? 6'b010011 : // BLTU 
                             (funct3 == 3'b111) ? 6'b001001 : // BGEU -> SLTU
                             6'bxxxxxx : // Default
                        (ALUOp == 3'b010) ? // R-type
                            (funct7 == 7'b0000000) ?
                               ((funct3 == 3'b000) ? 6'b000000 : // ADD
                                (funct3 == 3'b001) ? 6'b000101 : // SLL
                                (funct3 == 3'b010) ? 6'b001000 : // SLT
                                (funct3 == 3'b011) ? 6'b001001 : // SLTU
                                (funct3 == 3'b100) ? 6'b000100 : // XOR
                                (funct3 == 3'b101) ? 6'b000110 : // SRL
                                (funct3 == 3'b110) ? 6'b000011 : // OR
                                (funct3 == 3'b111) ? 6'b000010 : // AND
                                6'bxxxxxx) : // Default (this defeaults dont make sense btw)
                            (funct7 == 7'b0000001) ?
                               ((funct3 == 3'b000) ? 6'b001010 : // MUL
                                (funct3 == 3'b001) ? 6'b001011 : // MULH
                                (funct3 == 3'b010) ? 6'b001011 : //MULHSU -> MULH
                                (funct3 == 3'b011) ? 6'b001011 : //MULHU -> MULH
                                (funct3 == 3'b100) ? 6'b001100 : // DIV
                                (funct3 == 3'b101) ? 6'b001100 : // DIVU -> DIV
                                (funct3 == 3'b110) ? 6'b001101 : // REM
                                (funct3 == 3'b111) ? 6'b001101 : // REMU -> REM
                                6'bxxxxxx) : // Default          
                            (funct7 == 7'b0100000) ?                
                               ((funct3 == 3'b000) ? 6'b000001 : // SUB
                                (funct3 == 3'b101) ? 6'b000111 : // SRA
                                (funct3 == 3'b100) ? 6'b101101 : // xnor
                                (funct3 == 3'b110) ? 6'b101000 : //orn
                                (funct3 == 3'b111) ? 6'b100000 : //ANDN
                                6'bxxxxxx): // Default
                            (funct7 == 7'b0000101) ?                
                               ((funct3 == 3'b001) ? 6'b100001 : // clmul
                                (funct3 == 3'b011) ? 6'b100010 : // clmulh
                                (funct3 == 3'b010) ? 6'b100011 : // clmulr
                                (funct3 == 3'b110) ? 6'b100100 : // max
                                (funct3 == 3'b111) ? 6'b100101 : // maxu
                                (funct3 == 3'b100) ? 6'b100110 : // min
                                (funct3 == 3'b101) ? 6'b100111 : // minu
                                6'bxxxxxx): // Default
                           (funct7 == 7'b0110000) ?                
                               ((funct3 == 3'b001) ? 6'b101001 : //rol
                                (funct3 == 3'b101) ? 6'b011001 : //ror
                                6'bxxxxxx): // Default
                           (funct7 == 7'b0100100) ?                
                               ((funct3 == 3'b001) ? 6'b011010 : // bclr
                                (funct3 == 3'b101) ? 6'b011011 : // bext
                                6'bxxxxxx): // Default
                           (funct7 == 7'b0010000) ?                
                               ((funct3 == 3'b010) ? 6'b101010 : //sh1add
                                (funct3 == 3'b100) ? 6'b101011 : //sh2add
                                (funct3 == 3'b110) ? 6'b101100 : //sh3add
                                6'bxxxxxx): // Default
                           (funct7 == 7'b0110100) ? 6'b011100 : // binv
                           (funct7 == 7'b0010100) ? 6'b011101 : // bset
                           (funct7 == 7'b0000100) ? 6'b101110 : // zext.h
                            6'bxxxxxx : // Default
                         (ALUOp == 3'b011) ? 6'b000000 : // ADD for Load
                         (ALUOp == 3'b100) ? 6'b001110 : // LUI (imm << 12)
                         (ALUOp == 3'b101) ? 6'b001111 : // AUIPC 
                         (ALUOp == 3'b110) ? 6'b010000 : // Jal and JALR
                         6'bxxxxxx; // default at the beginning   
endmodule
module FPU_Decoder(isFPUOp, funct3, op, funct5 ,FPUcontrol, Rmode);
//    input [1:0] FPUOp; // 00 is Computational instructions, 01 R4-type fuse instructions
    input isFPUOp;
    input [2:0] funct3; //This is either rm or a funct3
    input [6:0] op;
    input [4:0] funct5;
    output [3:0] FPUcontrol;
    output [2:0] Rmode;
    // fmt [26-25] is always 00 since it is single-precision is specifed
    /*
    () means same instruction (), () means same control signal but difference is to be found later in execute
    0000: ADD
    0001: SUB
    0010: MUL
    0011: DIV
    0100: SQRT
    0101: FMADD
    0110: FMSUB
    0111: FNMSUB
    1000: FNMADD
    1001: EQ
    1010: LT
    1011: LE
    1100: MIN
    1101: MAX
    1110:
    1111:
    
    fsgnj
    fsgnjn
    fsgnjx
    (CVT.W.S, CVT.WU.S),
    (CVT.S.W, CVT.S.WU)
    (MV.X.W), (MV.W.X)
    CLASS
    MV.W.X
    MV.X.W
    */        
    assign FPUcontrol = (isFPUOp) ?
                            op[4] ?
                                (funct5 == 5'b00000) ? 4'b0000 : //ADD
                                (funct5 == 5'b00001) ? 4'b0001 : //SUB
                                (funct5 == 5'b00010) ? 4'b0010 : //MUL
                                (funct5 == 5'b00011) ? 4'b0011 : //DIV
                                (funct5 == 5'b01010) ? 4'b0000 : //SQRT
                                (funct5 == 5'b10100) ?
                                   ((funct3 == 3'b010) ? 4'b1001 : //EQ
                                    (funct3 == 3'b001) ? 4'b1010 : //LT
                                    (funct3 == 3'b000) ? 4'b1011 : //LE
                                    4'b0000) : //Default
                                (funct5 == 5'b00101) ?
                                   ((funct3 == 3'b000) ? 4'b1100 : //MIN
                                    (funct3 == 3'b001) ? 4'b1101 : //MAX
                                    4'b0000): // Default
                            op[3:2] == 2'b00 ? 4'b1000 : //FNMADD
                            op[3:2] == 2'b01 ? 4'b0110 : //FMSUB
                            op[3:2] == 2'b10 ? 4'b0111 : //FNMSUB
                            op[3:2] == 2'b11 ? 4'b1000 : //FNMADD
                            4'b0000 :
                        4'b0000 : 
                    4'b0000; //Default
endmodule