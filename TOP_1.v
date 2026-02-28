module top_conv(
	input [7:0]pixel_in,
	input clk,
	input [31:0]Kernal,
	input reset,
	input local_reset,
	input [3:0] F,
	input [7:0]N,
	input conv_en,
	output [15:0]conv_result,
	output finish,
	output Overflow,
	input unvalid,
	input local_rst_all_conv,
	output reg [10:0]index_4
	);


wire [199:0]window5;
wire [71:0] window3;
wire [199:0]window;
reg [199:0]filter;
wire window_valid;
wire window_valid1;
wire window_valid2;
wire [24:0]MUL_EN;
integer index,index_1,counter,counter1;
reg signal;
wire EN;
assign EN=(conv_en&&F==5)?1:0;
assign MUL_EN =(F==5&&index>0)?25'b1111111111111111111111111:(F==3&&index>0)?25'b0000000000000000111111111:25'd0 ;
assign window=(F==5)?window5:{128'd0,window3};
assign window_valid=window_valid1||window_valid2;
reg [199:0]mem[1024:0];
reg [7:0]mem2[1024:0];
reg[199:0]Window;
reg[7:0]pixel;
integer index_2;
integer index_3;
wire [9:0]S=(F==5)?784:900;
wire [9:0]W=(F==5)?785:901;
always @(posedge clk ) begin
	if (reset || local_rst_all_conv) begin
	counter1<=0;
	filter<=0;	
	end
	else if(conv_en)begin
	counter1<=counter1+1;
	if (counter1<162) begin
		if(counter1==5)
           filter[199:168]<=Kernal;
           else if(counter1==29)
           filter[167:136]<=Kernal;
           else if(counter1==55)
           filter[135:104]<=Kernal;
           else if(counter1==81)
           filter[103:72]<=Kernal;
           else if(counter1==107)
           filter[71:40]<=Kernal;
           else if(counter1==133)
           filter[39:8]<=Kernal;
           else if(counter1==159)
           filter[7:0]<=Kernal[7:0];
			end
end
end

conv_buffer_5x5 dut(
     .clk(clk),
    .reset(reset),
    .pixel_in(pixel),
    .N(N),
    .valid_in(EN&&conv_en&&signal),
     .window(window5), 
    .window_valid(window_valid1)
);


conv_buffer dut1(
     .clk(clk),
    .reset(reset),
    .pixel_in(pixel),
    .N(N),
    .valid_in(~EN&&conv_en&&signal),
     .window(window3), 
    .window_valid(window_valid2)
);	
always @(posedge clk) begin
	if (reset||local_rst_all_conv)  begin
		// reset
		pixel<=0;
		index_2<=0;
		index_3<=0;
		signal<=0;
	end
	else if (~unvalid) begin
		mem2[index_2]<=pixel_in;
		index_2<=index_2+1;
	end
    if(index_2>=1024&&index_3<index_2)begin
     signal <=1;
      pixel<=mem2[index_3];
      index_3<=index_3+1;
       end

end



always @(posedge clk) begin
	if (reset||local_rst_all_conv) begin
		// reset
		index<=0;
	end
	else if (window_valid&&index<(N-F+1)*(N-F+1)) begin
		mem[index]<=window;
		index<=index+1;
	end

end
always @(posedge clk) begin
     if(reset||local_rst_all_conv)begin
     Window<=0;
     index_1<=0;
     end
      else if(index>1&&finish&&index_1<(N-F+1)*(N-F+1))begin
      	Window<=mem[index_1];
      	index_1<=index_1+1;
      end
	
end
assign finish=(counter==4&&conv_en&&index_4<=(N-F+1)*(N-F+1)+1)?1:0;
always @(posedge clk) begin
	if (reset||local_rst_all_conv)
	counter<=0;
		
	else if (window_valid)
	counter<=counter+1;
	if(finish)
	counter<=0;

end

always@(posedge clk)begin
if(reset||local_rst_all_conv)
index_4<=0;
else if(finish)
index_4<=index_4+1;end

wire [15:0]conv_result_1;

mac dut3(
clk,
reset,
local_reset,
MUL_EN, 
Window,
filter,
conv_result_1,
Overflow
);
assign conv_result=(index_4>=(N-F+1)*(N-F+1)+1)?0:conv_result_1;

endmodule