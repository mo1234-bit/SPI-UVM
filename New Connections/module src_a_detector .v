module src_a_detector (
    input wire clk,
    input wire rst,
    input wire [31:0] src_A,    // Assuming src_A is 32 bits
    output reg  indicator  // Assuming sel_conv is 5 bits
);

   

    // Register to store previous value of src_A
    reg [31:0] prev_src_A;

reg [1:0] counter; // 2-bit counter for counting up to 4 cycles

always @(posedge clk) begin
    if (rst) begin
        indicator <= 0;
        prev_src_A <= 32'h0;
        counter <= 2'b00;
    end
    else begin
        // Condition to start or maintain the indicator
        if ((src_A != 32'h0 && src_A != 32'hx && src_A != 32'hz) || (src_A != prev_src_A)) begin
            indicator <= 1;
            counter <= 2'b00; // rst counter when new activation occurs
        end
        else if (counter < 2'b11) begin
            // Keep indicator high if counter hasn't reached 3 (4 cycles total)
            indicator <= 1;
            counter <= counter + 1'b1;
        end
        else begin
            indicator <= 0;
        end
        
        // Update previous value (outside of conditionals)
        prev_src_A <= src_A;
    end
end
endmodule
