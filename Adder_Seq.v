module Adder_Seq #(
    //Parameterized values
	parameter N = 16
    )
    (
    input reset, clk, local_reset,en_add,
    input [N-1:0] in1,
    input [N-1:0] in2,
    output [N-1:0] sum_f ,
	output	reg    overflow
    );
    reg [N-1:0] res;

assign sum_f  = res;

always @(posedge clk, posedge reset) begin
    if (reset)
       res <= 32'd0 ;
      
   else if (local_reset)
       res <= 32'd0 ;
   else if (en_add) 
   if(in1==0&&in2==0)
	res<=0;
	// both negative or both positive
	else if(in1[N-1] == in2[N-1]) begin						//Since they have the same sign, absolute magnitude increases
		{overflow,res[N-2:0]} <= in1[N-2:0] + in2[N-2:0];
		                                                   	//So we just add the two numbers
		
		res[N-1] <= in1[N-1];		//and set the sign appropriately...  Doesn't matter which one we use, 
															//they both have the same sign
															 
		end												
	//	one of them is negative...
	else if(in1[N-1] == 0 && in2[N-1] == 1) begin		//subtract in1-in2
		if( in1[N-2:0] > in2[N-2:0] ) begin					//if in1 is greater than in2,
			{overflow,res[N-2:0]} <= in1[N-2:0] - in2[N-2:0];			//then just subtract in2 from in1
			res[N-1] <= 0;
											               //and manually set the sign to positive
			end
		else begin												//	if in1 is less than in2,
			{overflow,res[N-2:0]} <= in2[N-2:0] - in1[N-2:0];	
				                                        //		we'll actually subtract in1 from in2 to avoid in1 2's complement answer
			if (in2[N-2:0] ==in1[N-2:0])
				res[N-1] <= 0;
														//		to not put negative zero....
			else
				res[N-1] <= 1;										//		and manually set the sign to negative
			end
		end
	else begin												//	subtract in2-in1 (in1 negative, in2 positive)
		if( in1[N-2:0] > in2[N-2:0] ) begin					//	if in1 is greater than in2,
			{overflow,res[N-2:0]} <= in1[N-2:0] - in2[N-2:0];	
				//		we'll actually subtract in2 from in1 to avoid in1 2's complement answer
			if (res[N-2:0] == 0)
				res[N-1] <= 0;										//		 to not put negative zero....
			else
				res[N-1] <= 1;										//		and manually set the sign to negative
			end
		else begin												//	if in1 is less than in2,
			{overflow,res[N-2:0]}<= in2[N-2:0] - in1[N-2:0];			//		then just subtract in1 from in2
			res[N-1] <= 0;
										//		and manually set the sign to positive
			end
		end
	end
	
endmodule
