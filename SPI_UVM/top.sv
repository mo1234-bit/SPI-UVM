import spi_test::*;
import ram_test::*;
import uvm_pkg::*;
`include "uvm_macros.svh";
module top1 ();
bit clk;
initial begin
	forever 
	#1 clk=~clk;
end 

spi_if spiif(clk);
ram_if ramif(clk);
project dut (spiif.MOSI,spiif.MISO,spiif.SS_n,clk,spiif.rst_n);
project dut1(spiif.MOSI,spiif.MISO_ref,spiif.SS_n,clk,spiif.rst_n); 
project_ram dut3(ramif.din,ramif.rx_valid,ramif.dout_ref,ramif.tx_valid_ref,clk,ramif.rst_n);
initial begin
	uvm_config_db#(virtual spi_if)::set(null,"uvm_test_top","spi_if",spiif);
	uvm_config_db#(virtual ram_if)::set(null,"uvm_test_top","ram_if",ramif);
	run_test("spi_test");
end

assign ramif.rst_n=spiif.rst_n;
assign ramif.rx_valid=dut.rx_valid;
assign ramif.din=dut.rx_data;
assign ramif.dout=dut.tx_data;
assign ramif.tx_valid=dut.tx_valid;

endmodule 