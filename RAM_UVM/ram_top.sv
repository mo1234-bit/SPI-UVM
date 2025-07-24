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

ram dut(ramif.din,clk,ramif.rst_n,ramif.rx_valid,ramif.dout,ramif.tx_valid);
project_ram dut2 (ramif.din,clk,ramif.rst_n,ramif.rx_valid,ramif.dout_ref,ramif.tx_valid_ref);


initial begin
	uvm_config_db#(virtual ram_if)::set(null,"uvm_test_top","ram_if",ramif);
	run_test("ram_test");
end

endmodule : top