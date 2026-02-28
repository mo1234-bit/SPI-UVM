module conv_buffer (
    input clk,
    input reset,
    input [7:0] pixel_in,
    input [7:0]N,
    input valid_in,
    output reg [71:0] window,
    output reg window_valid
);
parameter P=256;
reg [7:0] LB0 [P-1:0]; 
reg [7:0] LB1 [P-1:0]; 
reg [7:0] curr_row [P-1:0]; 

reg [7:0] col_count;
reg [7:0] row_count;

reg [7:0] sr0_0, sr0_1, sr0_2; 
reg [7:0] sr1_0, sr1_1, sr1_2; 
reg [7:0] sr2_0, sr2_1, sr2_2; 

integer i;

always @(posedge clk) begin
    if (reset) begin
        col_count <= 0;
        row_count <= 0;
        window_valid <= 0;
        
        for (i = 0; i < N; i = i + 1) begin
            LB0[i] <= 0;
            LB1[i] <= 0;
            curr_row[i] <= 0;
        end
        {sr0_0, sr0_1, sr0_2} <= 0;
        {sr1_0, sr1_1, sr1_2} <= 0;
        {sr2_0, sr2_1, sr2_2} <= 0;
    end
    else if (valid_in) begin
      
        curr_row[col_count] <= pixel_in;

     
        if (col_count == N-1) begin
            for (i = 0; i < N; i = i + 1) begin
                LB0[i] <= LB1[i];
                LB1[i] <= curr_row[i];
            end
        end
        
      
        if (row_count >= 2) begin
            sr0_0 <= sr0_1;
            sr0_1 <= sr0_2;
           
            if (col_count == N-1) begin
                sr0_2 <= LB1[col_count]; 
            end else begin
                sr0_2 <= LB0[col_count];
            end
        end

    
        if (row_count >= 1) begin
            sr1_0 <= sr1_1;
            sr1_1 <= sr1_2;
           
            if (col_count == N-1) begin
                sr1_2 <= curr_row[col_count];  
            end else begin
                sr1_2 <= LB1[col_count];
            end
        end

        
        sr2_0 <= sr2_1;
        sr2_1 <= sr2_2;
        sr2_2 <= pixel_in;

        
        if (col_count == N-1) begin
            col_count <= 0;
            row_count <= (row_count == N-1) ? 0 : row_count + 1;
        end
        else begin
            col_count <= col_count + 1;
        end

        window_valid <= (row_count >= 2) && (col_count >= 2);
    end
end

always @(*) begin
    window = {sr0_0, sr0_1, sr0_2,
              sr1_0, sr1_1, sr1_2,
              sr2_0, sr2_1, sr2_2};
end

endmodule
