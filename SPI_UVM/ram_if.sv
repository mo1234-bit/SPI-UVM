import pkg::*;
interface ram_if (clk);
	input clk;
	logic [9:0]din;
logic rst_n,rx_valid;
logic  [ADDER_SIZE-1:0]dout;
logic  tx_valid;
logic  [ADDER_SIZE-1:0]dout_ref;
logic  tx_valid_ref;
endinterface 