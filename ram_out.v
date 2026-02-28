module ram_out #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 11
)
(
    input  wire clk,
    input  wire reset,
    input  wire [DATA_WIDTH-1:0] data_in,
    input  wire write_enable,
    input  wire read_enable,
    output reg  [DATA_WIDTH-1:0] data_out
);
     reg [ADDR_WIDTH-1:0]addr;
    // Declare memory based on DATA_WIDTH
    reg [DATA_WIDTH-1:0] memory [0:(2**ADDR_WIDTH)-1];
    integer i;
    
    always @(posedge clk or posedge reset) begin
        if (~reset) begin
            data_out <= 0;
            addr<=0;
        end 
        else begin
            if (write_enable) begin
                 addr<=addr+1;
                memory[addr] <= data_in;
            end 
           
        end
    end
    integer file, w;

always @(posedge clk ) begin
    if(write_enable)begin
    // Open file for writing
    file = $fopen("ram_output.txt", "w");

    // Check if file opened successfully
    if (file == 0) begin
        $display("Failed to open file.");
        $finish;
    end

    // Write RAM contents
    for (w = 0; w < 901; w = w + 1) begin
        $fdisplay(file, "%02h", memory[w]); // Each value as 2-digit hex
    end

    $fclose(file);  // Close file
    $display("RAM contents written to ram_output.txt");
end
end


endmodule