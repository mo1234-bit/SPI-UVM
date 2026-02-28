module crossbar (
    input  wire clk,
    input  wire reset,
    
    // Data Inputs Cross Bar
    input  wire [31:0] src_A, add_out,
    input  wire  [15:0] conv_out, pool_out, relu_out,
    input  wire [4:0] sel_Conv,sel_Add, sel_Relu, sel_Pool, sel_Res,

    // RAM
    input  wire [9:0] addr_conv, addr_add, addr_relu, addr_pool, addr_src_A, // Addresses for RAM
    input  wire conv_read_en, conv_write_en,pool_read_en,pool_write_en,add_read_en,add_write_en,relu_read_en,relu_write_en,srcA_read_en,srcA_write_en ,// Control Signals for RAM
     
    // Data outputs Cross Bar
    output wire [31:0] result, add_in,  // Final 32-bit   result
    output wire  [15:0] relu_in, pool_in, // 16-bit  Inputs
    output wire  [7:0] conv_in,
    output reg indicator,
    output reg indicator1,
    output reg indicator2,
    output reg indicator3,
    output reg indicator4,
    output unvalid,
    output unvalid1,
    output unvalid2,
    output unvalid3            // 8-bit input
);

 wire  [15:0] conv_out_ram, pool_out_ram, relu_out_ram;
 wire [31:0] src_A_out_ram, add_out_ram;
 reg [31:0]prev_src_A;
    // Instantiate RAM for each of the modules
    ram #(.DATA_WIDTH(16)) ram_conv (
    .clk(clk),
    .reset(reset),
    .data_in(conv_out),
    .addr(addr_conv),
    .write_enable(conv_write_en),
    .read_enable(conv_read_en),
    .data_out(conv_out_ram)
);

    
    ram #(.DATA_WIDTH(32)) ram_add (
    .clk(clk),
    .reset(reset),
    .data_in(add_out),
    .addr(addr_add),
    .write_enable(add_write_en),
    .read_enable(add_read_en),
    .data_out(add_out_ram)
);

    
    ram #(.DATA_WIDTH(16)) ram_relu (
    .clk(clk),
    .reset(reset),
    .data_in(relu_out),
    .addr(addr_relu),
    .write_enable(relu_write_en),
    .read_enable(relu_read_en),
    .data_out(relu_out_ram)
);

    
   ram #(.DATA_WIDTH(16)) ram_pool (
    .clk(clk),
    .reset(reset),
    .data_in(pool_out),
    .addr(addr_pool),
    .write_enable(pool_write_en),
    .read_enable(pool_read_en),
    .data_out(pool_out_ram)
);

    
    ram #(.DATA_WIDTH(32)) ram_src_A (
    .clk(clk),
    .reset(reset),
    .data_in(src_A),
    .addr(addr_src_A),
    .write_enable(srcA_write_en),
    .read_enable(srcA_read_en),
    .data_out(src_A_out_ram)
);

    // Select inputs for conv
    assign conv_in = (sel_Conv == 5'b00000) ? src_A[31:24] :
                     (sel_Conv == 5'b00001) ? src_A[23:16] :
                     (sel_Conv == 5'b00010) ? src_A[15:8] :
                     (sel_Conv == 5'b00011) ? src_A[7:0] :
                     (sel_Conv == 5'b00100) ? conv_out[15:8] :
                     (sel_Conv == 5'b00101) ? conv_out[7:0] :
                     (sel_Conv == 5'b00110) ? add_out[31:24] :
                     (sel_Conv == 5'b00111) ? add_out[23:16] :
                     (sel_Conv == 5'b01000) ? add_out[15:8] :
                     (sel_Conv == 5'b01001) ? add_out[7:0] :
                     (sel_Conv == 5'b01010) ? pool_out[15:8] :
                     (sel_Conv == 5'b01011) ? pool_out[7:0] :
                     (sel_Conv == 5'b01100) ? relu_out[15:8] :
                     (sel_Conv == 5'b01101) ? relu_out[7:0] :
                     (sel_Conv == 5'b01110) ? src_A_out_ram[31:24] :
                     (sel_Conv == 5'b01111) ? src_A_out_ram[23:16] :
                     (sel_Conv == 5'b10000) ? src_A_out_ram[15:8] :
                     (sel_Conv == 5'b10001) ? src_A_out_ram[7:0] :
                     (sel_Conv == 5'b10010) ? conv_out_ram[15:8] :
                     (sel_Conv == 5'b10011) ? conv_out_ram[7:0] :
                     (sel_Conv == 5'b10100) ? add_out_ram[31:24] :
                     (sel_Conv == 5'b10101) ? add_out_ram[23:16] :
                     (sel_Conv == 5'b10110) ? add_out_ram[15:8] :
                     (sel_Conv == 5'b10111) ? add_out_ram[7:0] :
                     (sel_Conv == 5'b11000) ? pool_out_ram[15:8] :
                     (sel_Conv == 5'b11001) ? pool_out_ram[7:0] :
                     (sel_Conv == 5'b11010) ? relu_out_ram[15:8] :
                     (sel_Conv == 5'b11011) ? relu_out_ram[7:0] : 8'b0;
                     

    // Select inputs for add
    assign add_in = (sel_Add == 5'b00000) ? src_A :
                    (sel_Add == 5'b00001) ? {16'b0, conv_out} : // Zero-extend for unsigned
                    (sel_Add == 5'b00010) ? add_out :
                    (sel_Add == 5'b00011) ? {16'b0, pool_out} : // Zero-extend for unsigned
                    (sel_Add == 5'b00100) ? {16'b0, relu_out} : // Zero-extend for unsigned
                    (sel_Add == 5'b00101) ? src_A_out_ram :
                    (sel_Add == 5'b00110) ? {16'b0, conv_out_ram} : // Zero-extend for unsigned
                    (sel_Add == 5'b00111) ? add_out_ram :
                    (sel_Add == 5'b01000) ? {16'b0, pool_out_ram} : // Zero-extend for unsigned
                    (sel_Add == 5'b01001) ? {16'b0, relu_out_ram} : // Zero-extend for unsigned
                    32'b0; 

    // Select inputs for pool
    assign pool_in = (sel_Pool == 5'b00000) ? src_A[31:16] :
                     (sel_Pool == 5'b00001) ? src_A[15:0] :
                     (sel_Pool == 5'b00010) ? conv_out :
                     (sel_Pool == 5'b00011) ? add_out[31:16] :
                     (sel_Pool == 5'b00100) ? add_out[15:0] :
                     (sel_Pool == 5'b00101) ? pool_out :
                     (sel_Pool == 5'b00110) ? relu_out :
                     (sel_Pool == 5'b00111) ? src_A_out_ram[31:16] :
                     (sel_Pool == 5'b01000) ? src_A_out_ram[15:0] :
                     (sel_Pool == 5'b01001) ? conv_out_ram :
                     (sel_Pool == 5'b01010) ? add_out_ram[31:16] :
                     (sel_Pool == 5'b01011) ? add_out_ram[15:0] :
                     (sel_Pool == 5'b01100) ? pool_out_ram :
                     (sel_Pool == 5'b01101) ? relu_out_ram : 16'b0;

    // Select inputs for relu
    assign relu_in = (sel_Relu == 5'b00000) ? src_A[31:16] :
                     (sel_Relu == 5'b00001) ? src_A[15:0] :
                     (sel_Relu == 5'b00010) ? conv_out :
                     (sel_Relu == 5'b00011) ? add_out[31:16] :
                     (sel_Relu == 5'b00100) ? add_out[15:0] :
                     (sel_Relu == 5'b00101) ? pool_out :
                     (sel_Relu == 5'b00110) ? relu_out :
                     (sel_Relu == 5'b00111) ? src_A_out_ram[31:16] :
                     (sel_Relu == 5'b01000) ? src_A_out_ram[15:0] :
                     (sel_Relu == 5'b01001) ? conv_out_ram :
                     (sel_Relu == 5'b01010) ? add_out_ram[31:16] :
                     (sel_Relu == 5'b01011) ? add_out_ram[15:0] :
                     (sel_Relu == 5'b01100) ? pool_out_ram :
                     (sel_Relu == 5'b01101) ? relu_out_ram : 16'b0;

    // Select result output (ensure result)
    assign result = (sel_Res == 5'b00000) ? src_A :
                    (sel_Res == 5'b00001) ? {16'b0, conv_out} :  // Zero-extend for unsigned 
                    (sel_Res == 5'b00010) ? add_out :  
                    (sel_Res == 5'b00011) ? {16'b0, relu_out} :  // Zero-extend for unsigned
                    (sel_Res == 5'b00100) ? {16'b0, pool_out} :  // Zero-extend for unsigned 
                    (sel_Res == 5'b00101) ? src_A_out_ram :
                    (sel_Res == 5'b00110) ? {16'b0, conv_out_ram} :  // Zero-extend for unsigned 
                    (sel_Res == 5'b00111) ? add_out_ram :  
                    (sel_Res == 5'b01000) ? {16'b0, relu_out_ram} :  // Zero-extend for unsigned
                    (sel_Res == 5'b01001) ? {16'b0, pool_out_ram} :  // Zero-extend for unsigned 
                    32'b0;



assign unvalid=( sel_Conv > 5'b11011)?1:0;
assign unvalid1=(sel_Pool>5'b01101)?1:0;
assign unvalid2=(sel_Relu>5'b01101)?1:0;
assign unvalid3=(sel_Add>5'b01001)?1:0;

reg [1:0] counter; 

always @(posedge clk) begin
    if (reset) begin
        indicator <= 0;
        prev_src_A <= 32'h0;
        counter <= 2'b00;
        indicator1<=0;
        indicator2<=0;
    end
    else begin
        
        if ((src_A != 32'h0 && src_A != 32'hx && src_A != 32'hz) || (src_A != prev_src_A)) begin
            indicator <= 1;
            indicator1<=1;
            indicator2<=1;
            counter <= 2'b00; 
        end
        else if (counter < 2'b11) begin
        
            indicator <= 1;
            counter <= counter + 1'b1;
            indicator1<=0;
            indicator2<=0;
            if(counter<2'b10)
            indicator2<=1;
        end
         
        else begin
            indicator<=0;
            indicator1<=0;
            indicator2<=0;
        end
        

        prev_src_A <= src_A;
    end
end
/*
reg [31:0]prev_ADD;
always @(posedge clk) begin
    if (reset) begin
        indicator3 <= 0;
        prev_ADD <= 32'h0;
    end
    else begin
        
        if ((add_out != 32'h0 && add_out != 32'hx && add_out != 32'hz) || (add_out != prev_ADD)) begin
            indicator3 <= 1; 
        end
         
        else begin
            indicator3<=0;
        end
        

        prev_ADD <= add_out;
    end
end
reg [15:0]prev_RELU;
always @(posedge clk) begin
    if (reset) begin
        indicator4 <= 0;
        prev_RELU <= 16'h0;
    end
    else begin
        
        if ((relu_in != 32'h0 && relu_in != 32'hx && relu_in != 32'hz) || (relu_in != prev_RELU)) begin
            indicator4 <= 1; 
        end
         
        else begin
            indicator4<=0;
        end
        

        prev_RELU <= relu_in;
    end
end */
reg [15:0]prev_RELU;
reg [31:0]prev_ADD;

always @(posedge clk) begin
    if (reset) begin
        indicator4 <= 0;
        prev_RELU <= 16'h0;
        prev_ADD <= 32'h0;
    end
    else begin
        // Detect valid data from Add module
        if (( add_out != 32'hx && add_out != 32'hz) || (add_out != prev_ADD)) begin
            if (sel_Relu == 5'b00011 || sel_Relu == 5'b00100) begin
                indicator4 <= 1;
            end
        end
        
        // Detect valid data for ReLU from other sources
        if (( relu_in != 16'hx && relu_in != 16'hz) || (relu_in != prev_RELU)) begin
            indicator4 <= 1; 
        end
        else begin
            indicator4 <= 0;
        end

        prev_RELU <= relu_in;
        prev_ADD <= add_out;
    end
end
endmodule
