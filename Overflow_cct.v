//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/12/2021 07:12:01 PM
// Design Name: 
// Module Name: Overflow_cct
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


module Overflow_cct(
input reset,
input clock,
input Overflow_Add,
output Overflow
    );

reg Overflow_Add_shifted;
    
    always@(posedge clock)
    begin
    if (reset)
    Overflow_Add_shifted<=0;
    else
        Overflow_Add_shifted <= Overflow_Add;
    end
    
    assign Overflow = Overflow_Add_shifted;

endmodule
