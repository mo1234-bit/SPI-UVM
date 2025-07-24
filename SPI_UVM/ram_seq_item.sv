package ram_seq_item;
	import uvm_pkg::*;
`include "uvm_macros.svh";
import pkg::*;
class ram_seq_item extends  uvm_sequence_item;
	`uvm_object_utils(ram_seq_item);
	function  new(string name="ram_seq_item");
		super.new(name);
	endfunction 
	rand logic [9:0]din;
rand logic rst_n,rx_valid;
bit  [ADDER_SIZE-1:0]dout;
logic  tx_valid;
logic  [ADDER_SIZE-1:0]dout_ref;
logic  tx_valid_ref;
constraint wr {
	din[9:8] inside {2'b00,2'b01};
}

constraint rd {
	din[9:8] inside {2'b10,2'b11};
}

constraint rsest {
	rst_n dist {0:=2,1:=98};
}
constraint rx {
	rx_valid dist {0:=10,1:=90};
}
function string convert2string(); 
    return $sformatf("%s rst_n=%0b din=%0h rx_valid =%0b dout =%0b tx_valid=%0b ",super.convert2string(),rst_n,din,rx_valid,dout,tx_valid); 
endfunction  
function string convert2string_stimulus(); 
    return $sformatf("rst_n=%0b din=%0h rx_valid =%0b ",rst_n,din,rx_valid);
endfunction : convert2string_stimulus
endclass : ram_seq_item
endpackage : ram_seq_item