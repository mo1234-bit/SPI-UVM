module Add_Module # (
    parameter DATA_WIDTH = 32
    ) 
(
    input wire [DATA_WIDTH-1:0] Add_In, // First input 
    input wire [DATA_WIDTH-1:0] Src_c, // Second input   //bias
    input wire Enable,            // Enable signal
    input wire Local_rst,       // Local reset signal
    input wire RST,               // Global reset signal
    input wire CLK,               // Clock signal      
    output [DATA_WIDTH-1:0] Add_Out, // Output result
    output reg Overflow_Add,     // Overflow signal
    output reg finish,
    input unvalid            // Finish signal
);

    reg [DATA_WIDTH-1:0] temp; // Temporary variable for calculations
  

    assign Add_Out = temp;

    always @(posedge CLK or posedge RST) begin
        if (RST || Local_rst) begin
            temp <= 32'b0;
            finish <= 0;
            //Overflow_Add <= 1'b0;
        end else if (Enable&&!unvalid) begin
            
            // Both inputs are either negative or positive
            if ((Add_In[DATA_WIDTH-1] == Src_c[DATA_WIDTH-1])) begin
                {Overflow_Add,temp[DATA_WIDTH-2:0]} <= Add_In[DATA_WIDTH-2:0] + Src_c[DATA_WIDTH-2:0]; // Since they have the same sign, absolute magnitude increases
                finish<=1;
                // if (temp[DATA_WIDTH-1] != Add_In[DATA_WIDTH-1])                        // Check for overflow by examining MSB
                //     Overflow_Add <= 1;                                                  // Overflow occurs when sign changes unexpectedly
                // else begin
                //     temp[DATA_WIDTH-1] <= Add_In[DATA_WIDTH-1];                         // Set the sign appropriately
                //     Overflow_Add <= 0;
                // end
                    
            end 

            // One of them is negative...
            else if (Add_In[DATA_WIDTH-1] == 0 && Src_c[DATA_WIDTH-1] == 1) begin      // Subtract Add_In - Src_c
                if (Add_In[DATA_WIDTH-2:0] > Src_c[DATA_WIDTH-2:0]) begin              // If Add_In is greater than Src_c
                    {Overflow_Add,temp[DATA_WIDTH-2:0]} <= Add_In[DATA_WIDTH-2:0] - Src_c[DATA_WIDTH-2:0];
                    temp[DATA_WIDTH-1] <= 0; // Result is positive
                    finish<=1;
                end else begin // If Add_In is less than Src_c
                    {Overflow_Add,temp[DATA_WIDTH-2:0]} <= Src_c[DATA_WIDTH-2:0] - Add_In[DATA_WIDTH-2:0];
                    finish<=1; // Subtract in reverse order
                    if (temp[DATA_WIDTH-2:0] == 0)
                        temp[DATA_WIDTH-1] <= 0; // Avoid negative zero
                    else
                        temp[DATA_WIDTH-1] <= 1; // Result is negative
                end
            end
            // Src_c is positive and Add_In is negative (Subtract Src_c - Add_In)
            else begin
                if (Add_In[DATA_WIDTH-2:0] > Src_c[DATA_WIDTH-2:0]) begin // If Add_In is greater than Src_c
                    {Overflow_Add,temp[DATA_WIDTH-2:0]} <= Add_In[DATA_WIDTH-2:0] - Src_c[DATA_WIDTH-2:0];
                    finish<=1;
                    if (temp[DATA_WIDTH-2:0] == 0)
                        temp[DATA_WIDTH-1] <= 0; // Avoid negative zero
                    else
                        temp[DATA_WIDTH-1] <= 1; // Result is negative
                end else begin // If Add_In is less than Src_c
                    {Overflow_Add,temp[DATA_WIDTH-2:0]} <= Src_c[DATA_WIDTH-2:0] - Add_In[DATA_WIDTH-2:0];
                    finish<=1;
                    temp[DATA_WIDTH-1] <= 0; // Result is positive

                end
            end
        end
        
        else finish<=0;
    end
    

endmodule