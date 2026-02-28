module conv_buffer_5x5 (
    input clk,
    input reset,
    input [7:0] pixel_in,
    input valid_in,
    output reg [199:0] window, 
    output reg window_valid
);


reg [7:0] LB0 [31:0]; 
reg [7:0] LB1 [31:0]; 
reg [7:0] LB2 [31:0]; 
reg [7:0] LB3 [31:0]; 
reg [7:0] curr_row [31:0]; 

reg [5:0] col_count;
reg [5:0] row_count;


reg [7:0] sr0_0, sr0_1, sr0_2, sr0_3, sr0_4; 
reg [7:0] sr1_0, sr1_1, sr1_2, sr1_3, sr1_4; 
reg [7:0] sr2_0, sr2_1, sr2_2, sr2_3, sr2_4; 
reg [7:0] sr3_0, sr3_1, sr3_2, sr3_3, sr3_4; 
reg [7:0] sr4_0, sr4_1, sr4_2, sr4_3, sr4_4; 

integer i;

always @(posedge clk) begin
    if (reset) begin
        col_count <= 0;
        row_count <= 0;
        window_valid <= 0;

        for(i=0; i<32; i=i+1) begin
            LB0[i] <= 0;
            LB1[i] <= 0;
            LB2[i] <= 0; 
            LB3[i] <= 0;
            curr_row[i] <= 0;
        end
    
        {sr0_0,sr0_1,sr0_2,sr0_3,sr0_4} <= 0;
        {sr1_0,sr1_1,sr1_2,sr1_3,sr1_4} <= 0;
        {sr2_0,sr2_1,sr2_2,sr2_3,sr2_4} <= 0;
        {sr3_0,sr3_1,sr3_2,sr3_3,sr3_4} <= 0;
        {sr4_0,sr4_1,sr4_2,sr4_3,sr4_4} <= 0;
    end
    else if (valid_in) begin
        curr_row[col_count] <= pixel_in;
        if(row_count >= 4) begin
            sr0_0 <= sr0_1;
             sr0_1 <= sr0_2;
            sr0_2 <= sr0_3;
             sr0_3 <= sr0_4;
            sr0_4 <= LB0[col_count];
        end
        
        if(row_count >= 3) begin
            sr1_0 <= sr1_1; 
            sr1_1 <= sr1_2;
            sr1_2 <= sr1_3; 
            sr1_3 <= sr1_4;
            sr1_4 <= LB1[col_count];
        end

        if(row_count >= 2) begin
            sr2_0 <= sr2_1;
             sr2_1 <= sr2_2;
            sr2_2 <= sr2_3; 
            sr2_3 <= sr2_4;
            sr2_4 <= LB2[col_count];
        end

        if(row_count >= 1) begin
            sr3_0 <= sr3_1; 
            sr3_1 <= sr3_2;
            sr3_2 <= sr3_3; 
            sr3_3 <= sr3_4;
            sr3_4 <= LB3[col_count];
        end

        if(col_count == 0) begin
            {sr4_0, sr4_1, sr4_2, sr4_3, sr4_4} <= {32'b0, pixel_in};
        end else begin
            sr4_0 <= sr4_1;
            sr4_1 <= sr4_2;
            sr4_2 <= sr4_3;
            sr4_3 <= sr4_4;
            sr4_4 <= pixel_in;
        end

        if(col_count == 31) begin
            col_count <= 0;
            row_count <= (row_count == 31) ? 0 : row_count + 1;
            
        
            for(i=0; i<32; i=i+1) begin
                LB0[i] <= LB1[i];
                LB1[i] <= LB2[i];
                LB2[i] <= LB3[i];
                LB3[i] <= curr_row[i];
            end
        end
        else begin
            col_count <= col_count + 1;
        end

        window_valid <= (row_count >= 4) && (col_count >= 4);
    end
end

always @(*) begin
    window = {sr0_0,sr0_1,sr0_2,sr0_3,sr0_4,
             sr1_0,sr1_1,sr1_2,sr1_3,sr1_4,
             sr2_0,sr2_1,sr2_2,sr2_3,sr2_4,
             sr3_0,sr3_1,sr3_2,sr3_3,sr3_4,
             sr4_0,sr4_1,sr4_2,sr4_3,sr4_4};
end

endmodule
