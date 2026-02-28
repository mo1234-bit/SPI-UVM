module ram #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 10
)
(
    input  wire clk,
    input  wire reset,
    input  wire [DATA_WIDTH-1:0] data_in,
    input  wire [ADDR_WIDTH-1:0] addr,
    input  wire write_enable,
    input  wire read_enable,
    input  wire [9:0]addr_rd, 
    output reg  [DATA_WIDTH-1:0] data_out
);

    // Declare memory based on DATA_WIDTH
    reg [DATA_WIDTH-1:0] memory [0:(1<<ADDR_WIDTH)-1];
    integer i;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_out <= 0;
            for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1)
                memory[i] <= 0;
        end 
        else begin
            if (write_enable) begin
                memory[addr] <= data_in;
            end 
            if (read_enable) begin
                data_out <= memory[addr_rd];
            end
        end
    end

endmodule