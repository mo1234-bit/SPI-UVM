module test_data();
reg clk,rst;
reg [31:0]instruction;
wire [31:0]data_out;
wire [31:0]instruction_out;

data_mem dut(
	clk,rst,
	instruction,
	data_out,
	instruction_out
	);
initial begin
	clk=0;
	forever 
	#1 clk=~clk;
end
initial begin
	rst=1;
	@(negedge clk);
    rst=0;
    instruction=32'b0000011_11011_00101_0_1_1_00000_1111111;
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    $stop;
end
endmodule