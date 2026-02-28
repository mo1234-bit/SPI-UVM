module maxpool_unit (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [7:0] Np,          
    input wire [2:0] P,           
    input wire [15:0] data_in, 
    output reg [15:0] data_out,
    output reg finish,
    input wire unvalid,
    output reg valid_out,
    input wire local_rst_all_pool
);
    

    (* ram_style = "block" *) reg [15:0] reg_file [0:1023];     
    (* ram_style = "distributed" *) reg [15:0] output_file [0:255];
    
    // Counters and state variables
    reg [15:0] write_index, read_index;
    reg [7:0] pool_row, pool_col;     // Which pooling window we're working on
    reg [2:0] window_row, window_col; // Position within current pooling window
    reg [15:0] window_max;
    reg first_in_window;
    
    // Helper variables for calculations
    reg [15:0] src_row, src_col, src_index;
    reg [15:0] output_index;
    
    // Derived parameters - use wire for synthesis optimization
    wire [15:0] total_inputs = Np * Np;
    wire [7:0] output_size = Np / P;
    wire [15:0] total_outputs = output_size * output_size;
    
    // State machine parameters
    parameter IDLE = 3'b000,
              WRITE = 3'b001,
              POOL_START = 3'b010,
              POOL_SCAN = 3'b011,
              POOL_NEXT = 3'b100,
              OUTPUT = 3'b101;

    reg [2:0] state;
    
    // Synthesis-friendly comparison function for signed numbers
   function [15:0] compare_max(input [15:0] a, input [15:0] b);
        reg a_sign, b_sign;
        reg [14:0] a_mag, b_mag;
        begin
            a_sign = a[15];
            b_sign = b[15];
            a_mag = a[14:0];
            b_mag = b[14:0];

    
            if (a_sign != b_sign) begin
                compare_max = (a_sign == 0) ? a : b;
            end
        
            else if (a_sign == 0) begin
                compare_max = (a_mag > b_mag) ? a : b;
            end
        
            else begin
                compare_max = (a_mag < b_mag) ? a : b; 
            end
        end
    endfunction


    // Optional debug flag - set to 0 for synthesis, 1 for simulation
    `ifdef SYNTHESIS
        parameter DEBUG = 0;
    `else
        parameter DEBUG = 1;
    `endif

    always @(posedge clk) begin
        if (rst || local_rst_all_pool) begin
            state <= IDLE;
            write_index <= 0;
            read_index <= 0;
            pool_row <= 0;
            pool_col <= 0;
            window_row <= 0;
            window_col <= 0;
            finish <= 0;
            valid_out <= 0;
            data_out <= 0;
            window_max <= 0;
            first_in_window <= 0;
            src_row <= 0;
            src_col <= 0;
            src_index <= 0;
            output_index <= 0;
        end 
        else begin
            case (state)
                IDLE: begin
                    valid_out <= 0;
                    finish <= 0;
                    if (start) begin
                        write_index <= 0;
                        state <= WRITE;
                      
                    end
                end

                WRITE: begin
                    if (~unvalid && write_index < total_inputs) begin
                        reg_file[write_index] <= data_in;
                        
                        write_index <= write_index + 1;
                    end
                    else if (write_index >= total_inputs) begin
                        // All data written, start pooling
                        state <= POOL_START;
                        pool_row <= 0;
                        pool_col <= 0;
                    end
                end

                POOL_START: begin
                    if (pool_row < output_size) begin
                        // Start scanning a new pooling window
                        window_row <= 0;
                        window_col <= 0;
                        first_in_window <= 1;
                        state <= POOL_SCAN;
                        
                    end else begin
                        // All pooling complete
                        state <= OUTPUT;
                        read_index <= 0;
                        finish <= 1;
                        
                    end
                end

                POOL_SCAN: begin
                    // Calculate source matrix position
                    src_row <= pool_row * P + window_row;
                    src_col <= pool_col * P + window_col;
                    src_index <= (pool_row * P + window_row) * Np + (pool_col * P + window_col);
                    
                   
                    
                    if (first_in_window) begin
                        window_max <= reg_file[(pool_row * P + window_row) * Np + (pool_col * P + window_col)];
                        first_in_window <= 0;
                    end else begin
                        window_max <= compare_max(window_max, reg_file[(pool_row * P + window_row) * Np + (pool_col * P + window_col)]);
                    end
                    
                    // Move to next position in window
                    if (window_col < P - 1) begin
                        window_col <= window_col + 1;
                    end else begin
                        window_col <= 0;
                        if (window_row < P - 1) begin
                            window_row <= window_row + 1;
                        end else begin
                            // Window scan complete
                            state <= POOL_NEXT;
                        end
                    end
                end

                POOL_NEXT: begin
                    // Store the result and move to next pooling position
                    output_index <= pool_row * output_size + pool_col;
                    output_file[pool_row * output_size + pool_col] <= window_max;
                    
                 
                    
                    // Move to next pooling window
                    if (pool_col < output_size - 1) begin
                        pool_col <= pool_col + 1;
                    end else begin
                        pool_col <= 0;
                        pool_row <= pool_row + 1;
                    end
                    
                    state <= POOL_START;
                end

                OUTPUT: begin
                    if (read_index < total_outputs) begin
                        data_out <= output_file[read_index];
                        valid_out <= 1;
                       
                        read_index <= read_index + 1;
                    end else begin
                        valid_out <= 0;
                        finish <= 0;
                        state <= IDLE;
                        
                    end
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule