module mac (
input wire clock, reset,local_reset ,
input [24:0] MUL_EN, 
input [199:0] IF_map_Out_mac,
input [199:0] KW_map_Out_mac,
output [15:0] out_of_mac,
output Overflow
);

wire [399:0] input_of_tree;
wire  Overflow_Add;

Multiplication_Circuit  u0 (.clk(clock),.reset(reset),.MUL_EN(MUL_EN),.IF_map_Out(IF_map_Out_mac), .KW_map_Out(KW_map_Out_mac),.Mult_out(input_of_tree));

adder_tree u1( .clk(clock),.reset(reset),.local_reset(local_reset),.data_in(input_of_tree), .result(out_of_mac), .Overflow_Add(Overflow_Add));

Overflow_cct Ovr(.reset(reset),.clock(clock),.Overflow_Add(Overflow_Add),.Overflow(Overflow));

endmodule