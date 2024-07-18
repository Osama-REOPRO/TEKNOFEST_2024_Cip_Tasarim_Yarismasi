`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/01/2024 04:49:43 PM
// Design Name: 
// Module Name: sqrt_unit
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


module sqrt_unit(
    input [31:0] radicand,
    input clk,
    output [31:0] result, output reg [31:0] remainder
    );
    reg [31:0] quotient, D;
    reg count;
    // Prepare registers
    always @(*) begin
        remainder = 31'b0;
        quotient = 31'b0;
        D = radicand;
        count = 15;  
    end
    //
    always @(posedge clk) begin
        if (count >= 0) begin
            remainder = (remainder << 2)|((D >> (count+1)) &3 );
            quotient = quotient << 2;
            if(remainder >= 0) remainder = remainder -(quotient|1);
            else remainder = remainder +(quotient|3);
            
            quotient = (quotient <<1);
            if(remainder >= 0) quotient = (quotient |1);
            else begin
                quotient = (quotient |0);
                remainder = remainder + ((quotient)|1);
            end
            if(remainder >= 0) remainder = remainder -((quotient <<2)|1);
            else remainder = remainder +((quotient <<2)|3);

            count = count - 1;
        end
    end
    assign result = quotient;
    
endmodule
