module test_PE();

	reg clk,reset,local_reset;
	reg [31:0]srcA;
	reg [31:0]srcB;
	reg [31:0]srcC;
	reg Conv_en;
	reg adder_en;
	reg pool_en;
	reg relu_en;
	reg [3:0]F;
	reg [4:0] sel_Conv;
    reg [4:0]sel_Add;
    reg[4:0]sel_Relu;
    reg [4:0] sel_Pool;
    reg [4:0] sel_Res;
    reg [6:0] addr_conv;
    reg [6:0]addr_add;
    reg [6:0]addr_relu;
    reg [6:0] addr_pool;
    reg [6:0] addr_src_A;
    reg  conv_read_en;
      reg conv_write_en;
    reg pool_read_en;
    reg pool_write_en;
    reg add_read_en;
    reg add_write_en;
    reg relu_read_en;
   reg  relu_write_en;
   reg srcA_read_en;
   reg srcA_write_en; 
	reg [7:0] Np;
	reg [2:0] P;
	wire  [31:0]Result;
	wire overflow;
  wire finish_conv,finish_pool,finish_relu,finish_adder;

	PE dut(
	 clk,reset,local_reset,
	srcA,
	srcB,
	 srcC,
	 Conv_en,
	 adder_en,
	 pool_en,
	 relu_en,
	 F,
	 sel_Conv,
    sel_Add,
    sel_Relu,
     sel_Pool,
     sel_Res,
     addr_conv,
     addr_add,
     addr_relu,
     addr_pool,
      addr_src_A,
       conv_read_en,
       conv_write_en,
     pool_read_en,
     pool_write_en,
     add_read_en,
     add_write_en,
     relu_read_en,
     relu_write_en,
    srcA_read_en,
    srcA_write_en, 
	 Np,
	 P,
	Result,
	overflow,
	 finish_conv,finish_pool,finish_relu,finish_adder
	);
integer i;
integer j;
integer k;
integer y;
integer w;
integer r;
integer q,t,u;
	initial begin
		clk=0;
		forever
		 #1 clk=~clk;
	end

	initial begin
   reset=1;
   local_reset=1;
   @(negedge clk);
   reset=0;
	local_reset=0;
	Conv_en=1;
	srcB=32'h0000_0000;
	@(negedge clk);
	srcB=32'h0000_0000;
	@(negedge clk);
	srcB=32'h0000_0000;
	@(negedge clk);
	srcB=32'h0000_0000;
	@(negedge clk);
	srcB=32'b00000000_10000001_00000000_10000001;
	@(negedge clk);
	srcB=32'b00000101_10000001_00000000_10000001;
	@(negedge clk);
	srcB=32'h0000_0000;
	@(negedge clk);
	F=3;
	for (i = 0; i < 730; i = i + 1) begin
           srcA = (i + 10000) ;
           for(j=0;j<4;j=j+1)begin
             sel_Conv=j;
            @(negedge clk);end
             
        end

     Conv_en=0;
    sel_Pool=5'b01001;
    pool_en=1;
     Np=4;
     P=2;

    for(y=0;y<128;y=y+1)begin
		addr_conv=y;
		conv_read_en=1;
		conv_write_en=0;
		 @(negedge clk);
		end

	   pool_en =0;
		adder_en=1;
		Np=0;
     P=0;
		srcC=32'd312;
	   sel_Add=5'b01000;
       for(r=0;r<128;r=r+1)begin
		addr_pool=r;
	   pool_read_en=1;
	   pool_write_en=0;
	   @(negedge clk);
	   end
      adder_en=0;
      relu_en=1;
      for(u=0;u<128;u=u+1)begin
		addr_add=u;
	   add_read_en=1;
	   add_write_en=0;
	   @(negedge clk);
	   for(q=0;q<2;q=q+1)begin
      sel_Relu=q+5'b01010;
      end
	   end
      
      relu_en=0;
	#50 $stop;
	end
	always @(*) begin
		if(finish_conv)begin
		sel_Res=1;
		conv_write_en=1;
		 end
		else begin
		sel_Res=5'b11111;
		conv_write_en=0;end

       if(finish_conv)begin
        for(k=0;k<128;k=k+1)begin
		addr_conv=k;
		@(posedge clk); end
        end

	end
	always@(*)begin
		if(finish_pool)begin
        sel_Add= 5'b00011;
        pool_write_en=1;end
         else begin 
		 sel_Add=5'b11111;
		 pool_write_en=0;end 

		 if(finish_pool)begin
        for(w=0;w<128;w=w+1)begin
        if(pool_en)
		addr_pool=w;
		@(posedge clk); end
        end
	end

always@(*)begin
		if(finish_adder)begin
        add_write_en=1;end
        else begin
		add_write_en=0;end 

		if(finish_adder)begin
        for(t=0;t<128;t=t+1)begin
		addr_add=t;
		@(negedge clk); end
        end
	end
	endmodule
