module test_mem();
reg clk,rst;
wire [31:0]instruction;

instruction_memory dut(
    clk,
     rst,
     instruction
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
repeat(300)@(negedge clk);
$stop;
end
endmodule