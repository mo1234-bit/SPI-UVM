import uvm_pkg::*;
`include "uvm_macros.svh";
import ram_test::*;
module top ();
bit clk;
initial begin
	forever
	#1 clk=~clk;
end

ram_if ramif(clk);

ram dut(ramif);

bind ram ram_sva sva(ramif);

initial begin
	uvm_config_db#(virtual ram_if)::set(null,"uvm_test_top","ram_if",ramif);
	run_test("ram_test");
end

endmodule : top