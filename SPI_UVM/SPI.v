module SPI(MOSI,MISO,SS_n,clk,rst_n,rx_data,rx_valid,tx_data,tx_valid);
input MOSI,SS_n,clk,rst_n,tx_valid;
input [7:0]tx_data;
output reg MISO,rx_valid;
output reg[9:0]rx_data;
parameter IDLE=3'b000;
parameter CHK_CMD=3'b001;
parameter WRITE=3'b010;
parameter READ_ADD=3'b011;
parameter READ_DATA=3'b100;
reg read_sel;
reg [2:0]cs,ns;
reg [4:0]counter;
reg [2:0]counter1;
always @(posedge clk ) begin
	if (~rst_n) 
		cs<=IDLE;
	else 
		cs<=ns;
end
always@(*)begin
	case(cs)
	IDLE:begin
		if(SS_n)
		ns=IDLE;
		else begin
		ns=CHK_CMD;
		end
	end

	CHK_CMD:begin
     if(SS_n)begin
            ns=IDLE;end
		else if(SS_n==0&&MOSI==0)begin
		ns=WRITE;end
		else if(SS_n==0&&MOSI==1&&read_sel==0)begin
		ns=READ_ADD;end
		else 
		ns=READ_DATA;
	end
	WRITE:begin
	if (SS_n==0)
	ns=WRITE;	
	else 
	ns=IDLE;
	end
	READ_ADD:begin
	 if(SS_n==0)
		ns=READ_ADD;
		else
                ns=IDLE;
	end
	READ_DATA:begin
		if(SS_n==0)
            ns=READ_DATA;
            else
                    ns=IDLE;
    end
    default: 
    ns=IDLE;
    
    endcase
    end
    always @(posedge clk) begin
    	if (~rst_n) begin
    	read_sel<=0;
    	rx_data<=10'h3ff;
    	MISO<=0;
    	rx_valid<=0;
    	counter<='h0a;
    	counter1<=0;
    	end else begin
    	case(cs)
    	WRITE:begin
       
    	       if(counter>=0)begin
                rx_data [counter] <= MOSI;
                counter <= counter - 1 ;     
                if(counter == 0) begin
                    counter <= 10;  
                    rx_valid <= 1;
                end  else if(counter!=0)
                   rx_valid<=0;
                    end
                    end
    	
    	READ_ADD: begin

    	if(counter>=0)begin
    	rx_data[counter] <= MOSI;
                counter <= counter - 1;
                if(counter ==0 ) begin
                    counter <= 10;
                    rx_valid <= 1;end
                    else if(counter!=0)
                    rx_valid<=0;
        end
        read_sel<=1;
    	
    	end
        READ_DATA:begin
            
        if(counter>=0)begin
                rx_data[counter] <= MOSI;
                counter<=counter-1;end
                if(counter==8)
                rx_valid<=1;
                else 
                    
                rx_valid<=0;
                
                if(counter==0)begin
                rx_valid<=0;
                counter<=10;
            end
            if(tx_valid==1)begin
            if(counter1>=0)begin
                MISO<=tx_data[counter1];
                if(counter1!=0)
                counter1<=counter1-1;
                // if(counter1==0)
                // counter1<=7;
            end
            read_sel<=0;
            end
end
    	 IDLE:begin
        MISO<=0;
            counter1 <= 7;
           
    	end
        default: rx_data<=10'h000;
        endcase 
        end
        end
        endmodule