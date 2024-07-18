
module hazard_unit(rst_H, PCSrcE, RegWriteM, RegWriteW, RD_M, RD_W, Rs1_E, Rs2_E, ForwardAE, ForwardBE,
                    rst_F,rst_D, rst_E, rst_M, rst_W);

    // Declaration of I/Os
    input rst_H, RegWriteM, RegWriteW, PCSrcE;
    input [4:0] RD_M, RD_W, Rs1_E, Rs2_E;
    output [1:0] ForwardAE, ForwardBE;
    output rst_F,rst_D, rst_E, rst_M, rst_W;
    
    
    assign ForwardAE = /*~rst_H ? 2'b00 :*/ 
                       (RegWriteM & (RD_M != 5'h00) & (RD_M == Rs1_E)) ? 2'b10 :
                       (RegWriteW & (RD_W != 5'h00) & (RD_W == Rs1_E)) ? 2'b01 :
                        2'b00;
                       
    assign ForwardBE = /*~rst_H ? 2'b00 :*/ 
                       (RegWriteM & (RD_M != 5'h00) & (RD_M == Rs2_E)) ? 2'b10 :
                       (RegWriteW & (RD_W != 5'h00) & (RD_W == Rs2_E)) ? 2'b01 : 
                       2'b00;
    assign rst_F = rst_H ? ~PCSrcE: 1'b0;
    assign rst_D = rst_H ? ~PCSrcE: 1'b0; 
    assign rst_E = rst_H ? 1'b1: 1'b0; 
    assign rst_M = rst_H ? 1'b1: 1'b0;  
    assign rst_W = rst_H ? 1'b1: 1'b0; 

endmodule