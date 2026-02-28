module conv_buffer_5x5 (
    input clk,
    input reset,
    input [7:0] pixel_in,
    input [7:0]N,
    input valid_in,
    output reg [199:0] window, 
    output reg window_valid
);
parameter P=256;
    
    reg [7:0] LB0 [P-1:0]; 
    reg [7:0] LB1 [P-1:0]; 
    reg [7:0] LB2 [P-1:0]; 
    reg [7:0] LB3 [P-1:0]; 
    reg [7:0] curr_row [P-1:0]; 

    reg [7:0] col_count; 
    reg [7:0] row_count; 

 
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
            window_valid <= 1'b0;
            
            for (i = 0; i < N; i = i + 1) begin
                LB0[i] <= 8'b0;
                LB1[i] <= 8'b0;
                LB2[i] <= 8'b0; 
                LB3[i] <= 8'b0;
                curr_row[i] <= 8'b0;
            end
        
            {sr0_0,sr0_1,sr0_2,sr0_3,sr0_4} <= 40'b0;
            {sr1_0,sr1_1,sr1_2,sr1_3,sr1_4} <= 40'b0;
            {sr2_0,sr2_1,sr2_2,sr2_3,sr2_4} <= 40'b0;
            {sr3_0,sr3_1,sr3_2,sr3_3,sr3_4} <= 40'b0;
            {sr4_0,sr4_1,sr4_2,sr4_3,sr4_4} <= 40'b0;
        end
        else if (valid_in) begin
           
            curr_row[col_count] <= pixel_in;

           
            if (col_count == N-1) begin
                for (i = 0; i < N; i = i + 1) begin
                    LB0[i] <= LB1[i];
                    LB1[i] <= LB2[i];
                    LB2[i] <= LB3[i];
                    LB3[i] <= curr_row[i]; 
                end
            end
            
           
            if (row_count >= 4) begin 
                sr0_0 <= sr0_1;
                 sr0_1 <= sr0_2; 
                 sr0_2 <= sr0_3; 
                 sr0_3 <= sr0_4;
              
                if (col_count == N-1) begin
                    sr0_4 <= LB1[col_count]; 
                end else begin
                    sr0_4 <= LB0[col_count];
                end
            end

            if (row_count >= 3) begin 
                sr1_0 <= sr1_1;
                 sr1_1 <= sr1_2; 
                 sr1_2 <= sr1_3;
                  sr1_3 <= sr1_4;
            
                if (col_count == N-1) begin
                    sr1_4 <= LB2[col_count]; 
                end else begin
                    sr1_4 <= LB1[col_count];
                end
            end
        
           
            if (row_count >= 2) begin 
                sr2_0 <= sr2_1;
                sr2_1 <= sr2_2;
                sr2_2 <= sr2_3;
                sr2_3 <= sr2_4;
                
                if (col_count == N-1) begin
                    sr2_4 <= LB3[col_count]; 
                end else begin
                    sr2_4 <= LB2[col_count];
                end
            end

          
            if (row_count >= 1) begin 
                sr3_0 <= sr3_1;
                 sr3_1 <= sr3_2;
                  sr3_2 <= sr3_3;
                   sr3_3 <= sr3_4;
               
                if (col_count == N-1) begin
                   
                    sr3_4 <= curr_row[col_count]; 
                end else begin
                    sr3_4 <= LB3[col_count];
                end
            end
            
         
            sr4_0 <= sr4_1;
             sr4_1 <= sr4_2;
              sr4_2 <= sr4_3;
               sr4_3 <= sr4_4;
            sr4_4 <= pixel_in; 

           
            if (col_count == N-1) begin
                col_count <= 0;
                row_count <= (row_count == N-1) ? 0 : row_count + 1; 
            end
            else begin
                col_count <= col_count + 1;
            end

            window_valid <= (row_count >= 4) && (col_count >= 4);
        end else begin
            window_valid <= 1'b0; 
        end
    end

    always @(*) begin
        window = {sr0_0,sr0_1,sr0_2,sr0_3,sr0_4, // Row N-4 of window
                  sr1_0,sr1_1,sr1_2,sr1_3,sr1_4, // Row N-3 of window
                  sr2_0,sr2_1,sr2_2,sr2_3,sr2_4, // Row N-2 of window
                  sr3_0,sr3_1,sr3_2,sr3_3,sr3_4, // Row N-1 of window
                  sr4_0,sr4_1,sr4_2,sr4_3,sr4_4}; // Row N of window
    end

endmodule
