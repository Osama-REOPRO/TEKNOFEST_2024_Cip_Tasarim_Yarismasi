`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2024 11:30:43 AM
// Design Name: 
// Module Name: divider_unit
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

module divider_unit (
    input clk,
    input [22:0] numerator, denominator,
    output [30:0] result
);
    reg [23:0] Q_dividend, M_divisor, Accumlator/*, M_divisor_complement*/;
    reg [4:0] count;
    wire [23:0] intermediate_result;
    wire [23:0] value_for_next_iteration;
    //reg active;
    

    // Prepare registers
    always @(*) begin
        //active = 1;
        Q_dividend = {numerator[22], numerator};
        M_divisor = {denominator[22], denominator};
        //M_divisor_complement = twos_complement(M_divisor);
        Accumlator = {24'd0 ,Q_dividend};   
        count = 5'd24;         
    end
        
    //Determination Block
    always @(posedge clk) begin
        if(count != 0) begin
            Accumlator = Accumlator << 1; //  Left shift AQ
            if (Accumlator[23] == 0) Accumlator = Accumlator  - M_divisor;/*Accumlator = Accumlator + M_divisor_complement;*/
            else Accumlator = Accumlator + M_divisor;
            
            if (Accumlator[23] == 0) Q_dividend[0] = 1;
            else Q_dividend[0] = 0;
             
            count = count -1;       
            if(count == 0) begin
                //active = 0;     
                if(Accumlator[23] != 0) Accumlator = Accumlator + M_divisor; // Restoring one time
            end
        end
    end
    // Combute leading zeros
    assign result = 
    { (expA - expB) + 127 - leading_zeros_counter_comb_32bit(numerator) +
     leading_zeros_counter_comb_32bit(denominator), Q_dividend[22:0]};
    // Accumlator is the reminder
endmodule
