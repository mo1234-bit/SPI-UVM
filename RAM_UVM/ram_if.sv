import pkg::*;
interface ram_if (clk);
	input clk;
	logic [9:0]din;
logic rst_n,rx_valid;
logic  [ADDER_SIZE-1:0]dout;
logic  tx_valid;

modport dut (input clk, din, rst_n, rx_valid, output dout, tx_valid);
endinterface 