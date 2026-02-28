module adder_tree 
#(parameter N = 16) // Data Width 
(
//inputs
input clk, reset,local_reset,
input [399:0] data_in, //from multiplier
//output
output [N-1:0] result,
output Overflow_Add
);

wire [N-1:0] in [24:0]; //local array
assign {in[0], in[1],in[2],in[3],in[4],in[5],in[6],in[7],in[8],in[9],in[10],in[11],in[12],in[13],in[14],in[15],in[16],
	in[17],in[18],in[19],in[20],in[21],in[22],in[23],in[24]} = data_in ;
//internal wires
wire [N-1:0] s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19,s20,s21,s22,s23,s24,s25,s26,s27,s28,s29,s30,s31,s32;
wire [N-1:0] s2_1,s2_2,s2_3,s2_4,s2_5,s2_6, s2_7,s2_8,s2_9,s2_10,s2_11,s2_12,s2_13,s2_14,s2_15,s2_16 ;
wire [N-1:0] s3_1,s3_2,s3_3,s3_4,s3_5,s3_6,s3_7,s3_8;
wire [N-1:0] s4_1,s4_2,s4_3,s4_4;
wire [N-1:0] s5_1,s5_2;
wire [24:0] Overflow;

//first level
Adder_Combo l1_1 (.in1(in[0]),  .in2(in[1]),  .sum(s1[N-1:0]),  .overflow(Overflow[0]),.en_addc(1'b1));
Adder_Combo l1_2 (.in1(in[2]),  .in2(in[3]),  .sum(s2[N-1:0]),  .overflow(Overflow[1]),.en_addc(1'b1));
Adder_Combo l1_3 (.in1(in[4]),  .in2(in[5]),  .sum(s3[N-1:0]),  .overflow(Overflow[2]),.en_addc(1'b1));
Adder_Combo l1_4 (.in1(in[6]),  .in2(in[7]),  .sum(s4[N-1:0]),  .overflow(Overflow[3]),.en_addc(1'b1));
Adder_Combo l1_5 (.in1(in[8]),  .in2(in[9]),  .sum(s5[N-1:0]),  .overflow(Overflow[4]),.en_addc(1'b1));
Adder_Combo l1_6 (.in1(in[10]), .in2(in[11]), .sum(s6[N-1:0]),  .overflow(Overflow[5]),.en_addc(1'b1));
Adder_Combo l1_7 (.in1(in[12]), .in2(in[13]), .sum(s7[N-1:0]),  .overflow(Overflow[6]),.en_addc(1'b1));
Adder_Combo l1_8 (.in1(in[14]), .in2(in[15]), .sum(s8[N-1:0]),  .overflow(Overflow[7]),.en_addc(1'b1));
Adder_Combo l1_9 (.in1(in[16]), .in2(in[17]), .sum(s9[N-1:0]),  .overflow(Overflow[8]),.en_addc(1'b1));
Adder_Combo l1_10(.in1(in[18]), .in2(in[19]), .sum(s10[N-1:0]), .overflow(Overflow[9]),.en_addc(1'b1));
Adder_Combo l1_11(.in1(in[20]), .in2(in[21]), .sum(s11[N-1:0]), .overflow(Overflow[10]),.en_addc(1'b1));
Adder_Combo l1_12(.in1(in[22]), .in2(in[23]), .sum(s12[N-1:0]), .overflow(Overflow[11]),.en_addc(1'b1));
Adder_Combo l1_13(.in1(in[24]), .in2(16'd0), .sum(s13[N-1:0]), .overflow(),.en_addc(1'b1));


//second level
Adder_Combo l2_1 (.in1(s1),  .in2(s2), .sum(s2_1[N-1:0]), .overflow(Overflow[12]),.en_addc(1'b1));
Adder_Combo l2_2 (.in1(s3),  .in2(s4), .sum(s2_2[N-1:0]), .overflow(Overflow[13]),.en_addc(1'b1));
Adder_Combo l2_3 (.in1(s5),  .in2(s6), .sum(s2_3[N-1:0]), .overflow(Overflow[14]),.en_addc(1'b1));
Adder_Combo l2_4 (.in1(s7),  .in2(s8), .sum(s2_4[N-1:0]), .overflow(Overflow[15]),.en_addc(1'b1));
Adder_Combo l2_5 (.in1(s9),  .in2(s10),.sum(s2_5[N-1:0]), .overflow(Overflow[16]),.en_addc(1'b1));
Adder_Combo l2_6 (.in1(s11), .in2(s12),.sum(s2_6[N-1:0]), .overflow(Overflow[17]),.en_addc(1'b1));
Adder_Combo l2_7 (.in1(s13), .in2(16'd0),.sum(s2_7[N-1:0]), .overflow(),.en_addc(1'b1));


//third level
Adder_Combo l3_1 (.in1(s2_1),  .in2(s2_2),  .sum(s3_1[N-1:0]),.overflow(Overflow[19]),.en_addc(1'b1));
Adder_Combo l3_2 (.in1(s2_3),  .in2(s2_4),  .sum(s3_2[N-1:0]),.overflow(Overflow[20]),.en_addc(1'b1));
Adder_Combo l3_3 (.in1(s2_5),  .in2(s2_6),  .sum(s3_3[N-1:0]),.overflow(Overflow[21]),.en_addc(1'b1));
Adder_Combo l3_4 (.in1(s2_7),  .in2(16'd0),  .sum(s3_4[N-1:0]),.overflow(Overflow[22]),.en_addc(1'b1));


//fourth level
Adder_Combo l4_1 (.in1(s3_1), .in2(s3_2), .sum(s4_1[N-1:0]),.overflow(Overflow[23]),.en_addc(1'b1));
Adder_Combo l4_2 (.in1(s3_3), .in2(s3_4), .sum(s4_2[N-1:0]),.overflow(Overflow[24]),.en_addc(1'b1));

//last level
Adder_Seq l6_1 (.clk(clk),.reset(reset),.local_reset(local_reset),.en_add(1'b1),.in1(s4_1), .in2(s4_2), .sum_f(result), .overflow(Overflow[18]));

// Overflow 
assign Overflow_Add = Overflow[0]  || Overflow[1]  || Overflow[2]  || Overflow[3]  || Overflow[4]  || Overflow[5]  || Overflow[6]  || Overflow[7]  || 
				      Overflow[8]  || Overflow[9]  || Overflow[10] || Overflow[11] || Overflow[12] || Overflow[13] || Overflow[14] || Overflow[15] ||
					  Overflow[16] || Overflow[17] || Overflow[18] || Overflow[19] || Overflow[20] || Overflow[21] || Overflow[22] || Overflow[23] || 
					  Overflow[24] ;



endmodule