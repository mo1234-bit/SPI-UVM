module SIPO (clk,SS_n ,MOSI,rx_data);  
input  clk,MOSI,SS_n;  
output [9:0] rx_data;  
reg [9:0] tmp;  
  
  always @(posedge clk)  
  begin 
    if(!SS_n)  
    tmp = {tmp[8:0],MOSI};  
  end  
  assign rx_data = tmp;  
endmodule 
module PISO(clk,tx_valid,counter,tx_data,dout); 
 
output reg dout; 
input [7:0] tx_data; 
input clk ; 
input tx_valid ; 
input [3:0] counter; 
reg [7:0]temp; 
 
always @ (posedge clk) begin 
    if (tx_valid) begin 
        if (counter==0) 
            temp <= tx_data; 
        else begin 
            dout <= temp[7]; 
            temp <= {temp[6:0],1'b0}; 
        end 
    end 
end 
endmodule
module up_counter(input clk,rst_n,output[3:0] counter); 
reg [3:0] counter_up; 
 
always @(posedge clk or negedge rst_n) 
begin 
if(~rst_n||counter_up==4'd10) 
 counter_up <= 4'd0; 
else 
 counter_up <= counter_up + 4'd1; 
end  
assign counter = counter_up; 
endmodule
module SPI_ref (MOSI,MISO,SS_n,clk,rst_n,rx_valid,rx_data,tx_valid,tx_data); 
   typedef enum bit[2:0] {IDLE,CHK_CMD,WRITE,READ_ADD,READ_DATA} state_e ; 
//input output decleration 
input MOSI,SS_n,clk,rst_n,tx_valid; 
input [7:0]tx_data; 
output reg MISO,rx_valid; 
output reg [9:0]rx_data; 
reg g;
reg flag,counter_rst_n; 
state_e cs,ns; 
wire dout; 
wire [9:0]din; 
wire [3:0]counter_out; 
//SIPO instan. 
SIPO shift_reg(clk,rx_valid,MOSI,din); 
//up_counter piso instan. 
up_counter counter(clk,counter_rst_n,counter_out); 
//PISO instan. 
PISO shift_regII(clk,tx_valid,counter_out,tx_data,dout); 
//state memory 
always @(posedge clk ) begin 
 if (~rst_n)  
   cs <= IDLE; 
 else 
   cs <= ns; 
end 
//next state logic 
always @(cs,MOSI,SS_n) begin //bug∶ MOSI MUST NOT BE in the sensetivity list !! 
case(cs) 
  IDLE:begin 
    if(!rst_n) 
      flag =0 ; 
   if(SS_n==0) begin 
     ns=CHK_CMD; 
   end   
   else 
     ns=IDLE; 
  end  
  CHK_CMD: 
   if(SS_n==1) 
     ns=IDLE; 
   else if (SS_n==0&&MOSI==0) 
     ns=WRITE; 
   else if (SS_n==0&&MOSI==1&&flag==0) begin 
     ns=READ_ADD; 
   end   else begin  
     ns=READ_DATA; 
     flag=0; 
   end 
  WRITE: 
   if(SS_n==1) begin 
     ns=IDLE; 
   end 
   else 
     ns=WRITE; 
  READ_ADD: 
   if(SS_n==1) begin 
     ns=IDLE; 
     flag=1; 
   end 
   else 
     ns=READ_ADD; 
default:    
  if(SS_n==1) 
     ns=IDLE; 
  else 
     ns=READ_DATA; 
endcase 
end 
//output logic 
always @(posedge clk ) begin 
if(!rst_n) 
begin 
rx_valid<=0; 
rx_data<=0;   
MISO<=0;// the mOSI MUST RESET TOO ! 
end 
else 
begin 
  if (ns==CHK_CMD) begin //THE CONDITIONING MUST BE ON THE ns not cs 
counter_rst_n <= 1'b0; 
end  else  
counter_rst_n <= 1'b1; 
if(cs==IDLE) 
g=0; 
if (((cs==WRITE)||(cs==READ_ADD))&&(!SS_n)) begin  
if (counter_out == 4'd10 && (g==0)) begin 
rx_valid<=1; 
rx_data<=din; 
g=1; 
end 
end 
else if ((cs==WRITE||cs==READ_ADD)&&SS_n==1) begin 
rx_valid<=0; 
end     else if (cs==READ_DATA&&SS_n==0) begin 
if (counter_out == 4'd10 &&(g==0)) begin 
rx_valid<=1; 
rx_data<=din; 
g=1; 
end
MISO <= dout; 
end 
else if (cs==READ_DATA&&SS_n==1) begin 
rx_valid<=0; 
end 
end 
//rx_valid must be 0 at the SS_N=1; 
end 
endmodule
module project_ram(din,rx_valid,dout,tx_valid,clk,rst_n); 
    parameter MEM_DEPTH = 256; 
    parameter ADDR_SIZE = 8; 
    input rx_valid,clk,rst_n; 
    input [9:0] din; 
    output reg tx_valid; 
    output reg [7:0] dout; 
    reg [ADDR_SIZE-1:0] addr_rd,addr_wr; 
    reg [7:0] mem [MEM_DEPTH-1:0]; 
    always @(posedge clk ) begin 
        if (!rst_n) begin 
// make integer i = 0 to be int i = 0 inside the for loop to be in its scope and  
// Not to take in code coverage report as it can't make 100 % its 32 bits Toggle 
            dout <= 0;     // "Bug Fix" Zero For all the Following outside For Loop 
            tx_valid <= 0; 
            addr_rd <= 0;       // "Bug Fix" make addr_rd <= 0 When rst_n 
            addr_wr <= 0;       // "Bug Fix" make addr_wr <= 0 When rst_n 
        end 
        else if (rx_valid) begin     
            if (din[9:8] == 2'b00) begin 
                addr_wr <= din[7:0]; 
                tx_valid <= 0; 
            end 
            else if (din[9:8] == 2'b01) begin 
                mem [addr_wr] <= din[7:0]; 
                tx_valid <= 0;
              end
                 else if (din[9:8] == 2'b10) begin 
                addr_rd <= din[7:0]; 
                tx_valid <= 0; 
            end 
            else if (din[9:8] == 2'b11) begin 
                dout <= mem[addr_rd]; 
                tx_valid <= 1; 
            end 
            else begin 
                dout <= 0; 
                tx_valid <= 0; 
            end 
        end  
    end 
endmodule
module spi_wrapper(mosi,miso,ss_n,clk,rst_n); 
input mosi,ss_n,clk,rst_n; 
output miso; 
wire rx_valid,tx_valid; 
wire [9:0] rx_data; 
wire [7:0] tx_data; 
SPI_ref spislave(mosi,miso,ss_n,clk,rst_n,rx_valid,rx_data,tx_valid,tx_data); 
project_ram mem(rx_data,rx_valid,tx_data,tx_valid,clk,rst_n); 
endmodule