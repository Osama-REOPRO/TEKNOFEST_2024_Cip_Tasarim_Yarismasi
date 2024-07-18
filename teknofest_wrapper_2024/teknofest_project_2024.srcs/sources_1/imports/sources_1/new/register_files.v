`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2024 06:28:30 PM
// Design Name: 
// Module Name: register_files
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Integer_RF(clk,WE3,WD3,A1,A2,A3,RD1,RD2);
    input clk,WE3;
    input [4:0]A1,A2,A3;
    input [31:0]WD3;
    output [31:0]RD1,RD2;

    reg [31:0] Register [31:0];

    always @ (posedge clk) begin
        if(WE3 & (A3 != 5'h00))
            Register[A3] <= WD3;
    end

    assign RD1 = /*(rst==1'b0) ? 32'd0 : */ Register[A1];
    assign RD2 = /*(rst==1'b0) ? 32'd0 : */ Register[A2];

    genvar i;
    generate for (i = 0; i < 32; i = i + 1) 
        begin : init_loop
            initial begin
                Register[i] = 32'h0;
            end
        end
    endgenerate

endmodule


module Floating_RF(clk,WE4,WD4,A1,A2,A3, A4, RD1,RD2, RD3);
    input clk,WE4;
    input [4:0]A1,A2,A3, A4;
    input [31:0]WD4;
    output [31:0]RD1,RD2, RD3;

    reg [31:0] Register [31:0];

    always @ (posedge clk) begin
        if(WE4) Register[A4] <= WD4;
    end

    assign RD1 = /*(rst==1'b0) ? 32'd0 : */ Register[A1];
    assign RD2 = /*(rst==1'b0) ? 32'd0 : */ Register[A2];
    assign RD3 = /*(rst==1'b0) ? 32'd0 : */ Register[A3];

    genvar i;
    generate for (i = 0; i < 32; i = i + 1) 
        begin : init_loop
            initial begin
                Register[i] = 32'h0;
            end
        end
    endgenerate

endmodule




module CSR_RF(clk,WE2,WD2,A1,A2,RD1);
    input clk, WE2; //write enable for A2 i.e. rd
    input [4:0] A1,A2; //rs and rd
    input [31:0] WD2; // write data for A2 i.e. rd
    output [31:0] RD1; // read data of rs

    reg [4069:0] Register [31:0];

    always @ (posedge clk) begin
        if(WE2) Register[A2] <= WD2;
    end

    assign RD1 = /*(rst==1'b0) ? 32'd0 : */ Register[A1];


endmodule