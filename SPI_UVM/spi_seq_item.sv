package spi_seq_item;
		import uvm_pkg::*;
`include "uvm_macros.svh";
class spi_seq_item extends  uvm_sequence_item;
	`uvm_object_utils(spi_seq_item)
	rand logic[9:0]container;
	function  new(string name ="spi_seq_item");
		super.new(name);

	endfunction 
rand logic SS_n,rst_n;
logic MISO;
logic MISO_ref;
logic add_sent,add_sent_read;
logic MOSI;


constraint a {
	SS_n dist {1:=20,0:=80};
}

constraint rst {
	rst_n dist {1:=98,0:=2};
}



function string convert2string();
	return $sformatf("%s SS_n=%0b rst_n=%0b MOSI=%0b  MISO=%0b",super.convert2string(),SS_n,rst_n,MOSI,MISO );
endfunction 

endclass : spi_seq_item
endpackage : spi_seq_item
