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
    output reg  [DATA_WIDTH-1:0] data_out
);

    // Declare memory based on DATA_WIDTH and SIGNED
    generate
            reg [DATA_WIDTH-1:0] memory [0:(1<<ADDR_WIDTH)-1];
            integer i;
            always @(posedge clk or posedge reset) begin
                if (reset) begin
                    for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1)
                        memory[i] <= 0;
                end else if (write_enable) begin
                    memory[addr] <= data_in;
                end else if (read_enable) begin
                    data_out <= memory[addr];
                end
            end
    endgenerate
endmodule
