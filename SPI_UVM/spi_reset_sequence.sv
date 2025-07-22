package spi_reset_sequence;
		import spi_seq_item::*;
			import uvm_pkg::*;
`include "uvm_macros.svh";
class spi_reset_sequence extends  uvm_sequence #(spi_seq_item);
	`uvm_object_utils(spi_reset_sequence)
	spi_seq_item seq_item;
	function  new(string name="spi_reset_sequence");
		super.new(name);
	endfunction 

	task body();
		seq_item=spi_seq_item::type_id::create("seq_item");
		start_item(seq_item);
		seq_item.rst_n=0;
		seq_item.MISO=0;
		seq_item.SS_n=0;
		finish_item(seq_item);
	endtask : body
endclass : spi_reset_sequence
endpackage : spi_reset_sequence

