module data_mem(
      input wire clk,rst,
      input wire[31:0]instruction,
      output reg [31:0]data_out,
      output reg [31:0]instruction_out
      );

wire [4:0]rs1,rs2;
wire [9:0]address;
assign rs1 =instruction[19:15] ;
assign rs2 =instruction[24:20] ;
 assign address={rs2,rs1};

 reg [31:0]mem[1024:0];

 always @(posedge clk ) begin
      if (~rst) begin
 data_out<=0;     
 instruction_out<=0;
      end
      else begin
      instruction_out<=instruction;
      if(instruction[31:25]==7'b0000011)
      data_out<=mem[address];
       else if (instruction[31:25]==7'b0000010) begin
        data_out<=mem[address+10'd512];            
       end
       else if(instruction[31:25]==7'b0000111)
       data_out<=mem[address];
      end
 end

 initial begin
        $readmemh("image.mem", mem); 
        mem[512]=32'h0000_0000;
        mem[513]=32'h0000_0000;
        mem[514]=32'h0000_0000;
        mem[515]=32'h0000_0000; 
        mem[516]=32'b00000000_10000001_00000000_10000001;
        mem[517]=32'b00000101_10000001_00000000_10000001;
       mem[518]=32'h0000_0000;
    end
 endmodule