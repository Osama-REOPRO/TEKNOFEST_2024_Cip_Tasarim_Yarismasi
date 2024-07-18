`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/14/2024 02:21:52 PM
// Design Name: 
// Module Name: comparator_unit
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

module comparator_unit(
    input [31:0] a, // Input SPFN A
    input [31:0] b, // Input SPFN B
    output reg gt,  // Output: A > B
    output reg eq,  // Output: A == B
    output reg lt   // Output: A < B
);

    // Split the inputs into sign, exponent, and mantissa
    wire sign_a, sign_b;
    wire [7:0] exponent_a, exponent_b;
    wire [22:0] mantissa_a, mantissa_b;

    assign sign_a = a[31];
    assign sign_b = b[31];
    assign exponent_a = a[30:23];
    assign exponent_b = b[30:23];
    assign mantissa_a = a[22:0];
    assign mantissa_b = b[22:0];

    always @(*) begin
        // Initialize outputs
        gt = 0;
        eq = 0;
        lt = 0;

        // Compare signs first
        if (sign_a != sign_b) begin
            gt = sign_b;
            lt = sign_a;
        end else begin
            // If signs are the same, compare exponents
            if (exponent_a != exponent_b) begin
                gt = (exponent_a > exponent_b) ^ sign_a; // If signs are negative, reverse logic
                lt = (exponent_a < exponent_b) ^ sign_a;
            end else begin
                // If exponents are the same, compare mantissas
                if (mantissa_a != mantissa_b) begin
                    gt = (mantissa_a > mantissa_b) ^ sign_a;
                    lt = (mantissa_a < mantissa_b) ^ sign_a;
                end else begin
                    // If all parts are the same, numbers are equal
                    eq = 1'b1;
                end
            end
        end
    end

endmodule
