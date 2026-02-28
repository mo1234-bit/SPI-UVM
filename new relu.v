module Relu
#(
    parameter IN_BITS = 16  // 16-bit signed (output of 8b pixel * 8b signed filter)
)
(  
  input rst,                
  input clk,
  input Enable,            
  input [IN_BITS-1:0] in,   
  output reg [IN_BITS-1:0] out,
  output reg finish,
  input valid,
  input wire input_valid ,
  input wire [4:0] sel_Relu,
  input local_rst_all_relu    
); 
always @(posedge clk or negedge rst) begin
  if (rst || local_rst_all_relu) begin
    out <= 0;
    finish<=0; 
  end
  else if (Enable&&!valid) begin

    if (input_valid || sel_Relu != 5'b00011) begin  // If from Add, check validity
      out <= (in[IN_BITS-1]) ? 0 : in; 
      finish <= 1;
    end

  end
  else  begin
    finish<=0;
  end
end
endmodule