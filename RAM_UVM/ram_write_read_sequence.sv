package ram_write_read_sequence;
	import ram_seq_item::*;
		import uvm_pkg::*;
`include "uvm_macros.svh";
class ram_write_read_sequence extends  uvm_sequence #(ram_seq_item);
	`uvm_object_utils(ram_write_read_sequence)
	ram_seq_item seq_item;
	function  new(string name="ram_write_read_sequence");
		super.new(name);
	endfunction 
	task body();
		repeat(10000)begin
			seq_item=ram_seq_item::type_id::create("seq_item");
			start_item(seq_item);
			seq_item.wr.constraint_mode(0);
			seq_item.rd.constraint_mode(0);
			assert(seq_item.randomize());
			finish_item(seq_item);
		end
	endtask : body
endclass : ram_write_read_sequence
endpackage : ram_write_read_sequence