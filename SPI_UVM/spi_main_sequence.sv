package spi_main_sequence;
		import spi_seq_item::*;
			import uvm_pkg::*;
`include "uvm_macros.svh";
class spi_main_sequence extends uvm_sequence #(spi_seq_item);
	`uvm_object_utils(spi_main_sequence)
	spi_seq_item seq_item;
	function  new(string name="spi_main_sequence");
		super.new(name);
	endfunction 

	task body();
		repeat(10000)begin
			seq_item=spi_seq_item::type_id::create("seq_item");
			start_item(seq_item);
			assert(seq_item.randomize());
			finish_item(seq_item);
		end
	endtask : body
endclass : spi_main_sequence
endpackage : spi_main_sequence