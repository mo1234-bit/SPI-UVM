module Multiplier  #(
	//Parameterized values
	parameter N = 8
	)
	(
	 input mul_en,clk,
	 input	    	[N-1:0]	a,
	 input		[N-1:0]	b,
	 output	reg	[2*N-1:0]	out
	 );
	 
	
	reg [2*N-1:0]	r_result;		
	
	always @(*)	begin	
         
         if(a[N-1]==1&&b!=0&&b[N-1]!=1)begin
          r_result[2*N-1:0] = a[N-1:0] * b[N-1:0];
         end
         else if(b==0)
           r_result=0;
         else if(b[N-1]==1&&a[N-1]==1)begin
           r_result[2*N-1:0] = a[N-1:0] * {1'b0,b[N-2:0]};
           r_result[2*N-1]=1'b1;
           end
         else  begin
        r_result[2*N-2:0] = a[N-2:0] * b[N-2:0];
		r_result[2*N-1] = a[N-1] ^ b[N-1];
			end													
		end
	always@(posedge clk)begin
	  if(~mul_en)
	    out <= 32'b0;
      else
		out <= r_result;
	end
		

endmodule