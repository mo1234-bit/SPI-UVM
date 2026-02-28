module maxpool_unit (
    input wire clk,
    input wire rst,
    input wire local_reset,
    input wire start,
    input wire [7:0] Np,  
    input wire [2:0] P,  
    input wire [15:0] data_in, 
    output reg [15:0] data_out,
    output reg finish,
    input unvalid,
    output reg valid_out
);
    
    reg [15:0] reg_file [0:255];    
    reg [15:0] output_file [0:255]; 
    integer x, y, i, j;
    integer write_index, read_index;

    parameter IDLE = 2'b00,
              WRITE = 2'b01,
              POOL = 2'b10,
              OUTPUT = 2'b11;

reg first_element;
integer idx;
reg [1:0] state;
reg [15:0] window_max;

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

    always @(posedge clk or posedge rst) begin
        if (rst||local_reset) begin
            state <= IDLE;
            write_index <= 0;
            read_index <= 0;
            finish <= 0;
            valid_out <= 0;
            data_out <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        write_index <= 0;
                        finish <= 0;
                        state <= WRITE;
                    end
                end

                WRITE: begin
                    if(~unvalid)begin
                    reg_file[write_index] <= data_in; 
                      if (write_index == (Np*Np) - 1) begin
                        write_index <= 0;
                        state <= POOL;
                       end else  begin
                        write_index <= write_index + 1;
                        end
                    end
                end

                POOL: begin 
    for (y = 0; y < Np/P; y = y + 1) begin
        for (x = 0; x < Np/P; x = x + 1) begin
            
            first_element = 1'b1;

            for (i = 0; i < P; i = i + 1) begin
                for (j = 0; j < P; j = j + 1) begin
                     idx = (y*P + i) * Np + (x*P + j);
                    if (first_element) begin
                        window_max = reg_file[idx];
                        first_element = 1'b0;
                    end else begin
                        window_max = compare_max(window_max, reg_file[idx]);
                    end
                end
            end
            output_file[y * (Np/P) + x] <= window_max;
                     end
                   end
                 read_index <= 0;
                 finish <= 1;
                state <= OUTPUT;
                end

                OUTPUT: begin
                    if (read_index < (Np/P)*(Np/P)) begin
                        data_out <= output_file[read_index];
                       // valid_out <= 1;
                        @(negedge clk);
                        read_index <= read_index + 1;
                    end else begin
                       // valid_out <= 0;
                        state <= IDLE;
                    end
                   
                end
            endcase
        end
    end

    always @(*) begin
    if(state==OUTPUT && read_index < (Np/P)*(Np/P))
        valid_out <= 1;
    else 
        valid_out <= 0;
end
endmodule