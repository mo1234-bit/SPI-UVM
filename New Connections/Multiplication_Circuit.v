module Multiplication_Circuit (
input clk,reset,
input [24:0] MUL_EN,
input [199:0] IF_map_Out,
input [199:0] KW_map_Out,
output [399:0] Mult_out
);

//////////////////// Internal signals //////////////////////
wire [24:0] ovr;
wire [7:0] IF_map_array [24:0]; // local array
wire [7:0] KW_map_array [24:0]; // local array
wire [15:0] Mult_out_array [24:0]; // local array
 //Assign Local Arrays to Inputs;

assign {IF_map_array[24],
        IF_map_array[23],IF_map_array[22],IF_map_array[21],IF_map_array[20],IF_map_array[19],
        IF_map_array[18],IF_map_array[17],IF_map_array[16],IF_map_array[15],IF_map_array[14],
        IF_map_array[13],IF_map_array[12],IF_map_array[11],IF_map_array[10],IF_map_array[9],
        IF_map_array[8],IF_map_array[7],IF_map_array[6],IF_map_array[5],IF_map_array[4],
        IF_map_array[3],IF_map_array[2],IF_map_array[1],IF_map_array[0]} =  IF_map_Out;

assign {KW_map_array[24],
        KW_map_array[23],KW_map_array[22],KW_map_array[21],KW_map_array[20],KW_map_array[19],
        KW_map_array[18],KW_map_array[17],KW_map_array[16],KW_map_array[15],KW_map_array[14],
        KW_map_array[13],KW_map_array[12],KW_map_array[11],KW_map_array[10],KW_map_array[9],
        KW_map_array[8],KW_map_array[7],KW_map_array[6],KW_map_array[5],KW_map_array[4],
        KW_map_array[3],KW_map_array[2],KW_map_array[1],KW_map_array[0]} =  KW_map_Out;
        
assign  Mult_out ={Mult_out_array[24],
        Mult_out_array[23],Mult_out_array[22],Mult_out_array[21],Mult_out_array[20],Mult_out_array[19],
        Mult_out_array[18],Mult_out_array[17],Mult_out_array[16],Mult_out_array[15],Mult_out_array[14],
        Mult_out_array[13],Mult_out_array[12],Mult_out_array[11],Mult_out_array[10],Mult_out_array[9],
        Mult_out_array[8],Mult_out_array[7],Mult_out_array[6],Mult_out_array[5],Mult_out_array[4],
        Mult_out_array[3],Mult_out_array[2],Mult_out_array[1],Mult_out_array[0]} ;


Multiplier M0(.out(Mult_out_array [0]),.clk(clk),.mul_en(MUL_EN[0]),.a(IF_map_array[0]),.b(KW_map_array[0]));
Multiplier M1(.out(Mult_out_array [1]),.clk(clk),.mul_en(MUL_EN[1]),.a(IF_map_array[1]),.b(KW_map_array[1]));
Multiplier M2(.out(Mult_out_array [2]),.clk(clk),.mul_en(MUL_EN[2]),.a(IF_map_array[2]),.b(KW_map_array[2]));
Multiplier M3(.out(Mult_out_array [3]),.clk(clk),.mul_en(MUL_EN[3]),.a(IF_map_array[3]),.b(KW_map_array[3]));
Multiplier M4(.out(Mult_out_array [4]),.clk(clk),.mul_en(MUL_EN[4]),.a(IF_map_array[4]),.b(KW_map_array[4]));
Multiplier M5(.out(Mult_out_array [5]),.clk(clk),.mul_en(MUL_EN[5]),.a(IF_map_array[5]),.b(KW_map_array[5]));
Multiplier M6(.out(Mult_out_array [6]),.clk(clk),.mul_en(MUL_EN[6]),.a(IF_map_array[6]),.b(KW_map_array[6]));
Multiplier M7(.out(Mult_out_array [7]),.clk(clk),.mul_en(MUL_EN[7]),.a(IF_map_array[7]),.b(KW_map_array[7]));
Multiplier M8(.out(Mult_out_array [8]),.clk(clk),.mul_en(MUL_EN[8]),.a(IF_map_array[8]),.b(KW_map_array[8]));
Multiplier M9(.out(Mult_out_array [9]),.clk(clk),.mul_en(MUL_EN[9]),.a(IF_map_array[9]),.b(KW_map_array[9]));
Multiplier M10(.out(Mult_out_array [10]),.clk(clk),.mul_en(MUL_EN[10]),.a(IF_map_array[10]),.b(KW_map_array[10]));
Multiplier M11(.out(Mult_out_array [11]),.clk(clk),.mul_en(MUL_EN[11]),.a(IF_map_array[11]),.b(KW_map_array[11]));
Multiplier M12(.out(Mult_out_array [12]),.clk(clk),.mul_en(MUL_EN[12]),.a(IF_map_array[12]),.b(KW_map_array[12]));
Multiplier M13(.out(Mult_out_array [13]),.clk(clk),.mul_en(MUL_EN[13]),.a(IF_map_array[13]),.b(KW_map_array[13]));
Multiplier M14(.out(Mult_out_array [14]),.clk(clk),.mul_en(MUL_EN[14]),.a(IF_map_array[14]),.b(KW_map_array[14]));
Multiplier M15(.out(Mult_out_array [15]),.clk(clk),.mul_en(MUL_EN[15]),.a(IF_map_array[15]),.b(KW_map_array[15]));
Multiplier M16(.out(Mult_out_array [16]),.clk(clk),.mul_en(MUL_EN[16]),.a(IF_map_array[16]),.b(KW_map_array[16]));
Multiplier M17(.out(Mult_out_array [17]),.clk(clk),.mul_en(MUL_EN[17]),.a(IF_map_array[17]),.b(KW_map_array[17]));
Multiplier M18(.out(Mult_out_array [18]),.clk(clk),.mul_en(MUL_EN[18]),.a(IF_map_array[18]),.b(KW_map_array[18]));
Multiplier M19(.out(Mult_out_array [19]),.clk(clk),.mul_en(MUL_EN[19]),.a(IF_map_array[19]),.b(KW_map_array[19]));
Multiplier M20(.out(Mult_out_array [20]),.clk(clk),.mul_en(MUL_EN[20]),.a(IF_map_array[20]),.b(KW_map_array[20]));
Multiplier M21(.out(Mult_out_array [21]),.clk(clk),.mul_en(MUL_EN[21]),.a(IF_map_array[21]),.b(KW_map_array[21]));
Multiplier M22(.out(Mult_out_array [22]),.clk(clk),.mul_en(MUL_EN[22]),.a(IF_map_array[22]),.b(KW_map_array[22]));
Multiplier M23(.out(Mult_out_array [23]),.clk(clk),.mul_en(MUL_EN[23]),.a(IF_map_array[23]),.b(KW_map_array[23]));
Multiplier M24(.out(Mult_out_array [24]),.clk(clk),.mul_en(MUL_EN[24]),.a(IF_map_array[24]),.b(KW_map_array[24]));

endmodule