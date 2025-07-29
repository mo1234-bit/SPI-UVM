module ram(din,clk,rst_n,rx_valid,dout,tx_valid);
parameter MEM_DEPTH=512;
parameter ADDER_SIZE=8;
input [9:0]din;
input clk,rst_n,rx_valid;
output reg [ADDER_SIZE-1:0]dout;
output reg tx_valid;

    reg [ADDER_SIZE-1:0] mem [MEM_DEPTH-1:0];
    reg [ADDER_SIZE-1:0] wr_op, rd_op;

    always @(posedge clk ) begin
        if (~rst_n) begin
            dout <= 0;
            tx_valid <= 0;
            wr_op <= 0;
            rd_op <= 0;
        end else if (rx_valid) begin
            case (din[9:8])
                2'b00: begin
                    wr_op <= din[7:0];
                    tx_valid <= 0;
                end
                2'b01: begin
                    mem[wr_op] <= din[7:0];
                    tx_valid <= 0;
                end
                2'b10: begin
                    rd_op <= din[7:0];
                    tx_valid <= 0;
                end
                2'b11: begin
                    dout <= mem[rd_op];
                    tx_valid <= 1;
                end
                default: begin
                    tx_valid <= 0;
                end
            endcase
           
        end
            
        
    end
    `ifdef FORMAL
   
    reg past_rx_valid1;
    reg past_din10,past_din00,past_din01;
    reg past_rx_valid;
    initial begin 
    past_rx_valid1 <= 0;
    past_rx_valid<=0;
     past_din10<=0;
         past_din00<=0;
         past_din01<=0;
    end
always @(posedge clk) begin
    if (~rst_n) begin
        past_rx_valid <= 0;
         past_rx_valid1 <= 0;
         past_din10<=0;
         past_din00<=0;
         past_din01<=0;
    end else begin
    if (din[9:8]!==2'b11&&rx_valid==1) past_rx_valid <=1 ;else past_rx_valid <=0 ;
    
    if (din[9:8]==2'b11&&rx_valid==1) past_rx_valid1 <=1 ;else past_rx_valid1 <=0 ;
     if (din[9:8]==2'b00&&rx_valid==1) past_din00 <=1 ;else past_din00 <=0 ;
     
      if (din[9:8]==2'b10&&rx_valid==1) past_din10 <=1 ;else past_din10 <=0 ;
         
        if ( past_rx_valid == 1) begin
          a:  assert (!tx_valid);
        end
        if ( past_rx_valid1 == 1) begin
          tx1:  assert (tx_valid); 
        end
         if ( past_din00 == 1) begin
          wr:  assert (wr_op==$past(din[7:0])); 
        end
         if ( past_din10 == 1) begin
          rd:  assert (rd_op==$past(din[7:0])); 
        end
       
    end
end
reg past_rst_n;
initial begin
  past_rst_n<=1;
end

always @(posedge clk) begin
  if(!rst_n)
         past_rst_n<=0;
         else
         past_rst_n<=1;
         
         if(!past_rst_n&&!rst_n)begin
         b: assert (dout == '0 && tx_valid==0 && wr_op=='0 && rd_op=='0);
         end
      
    end

    `endif // FORMAL
    
endmodule
