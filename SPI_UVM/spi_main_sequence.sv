package spi_main_sequence;
		import spi_seq_item::*;
			import uvm_pkg::*;
`include "uvm_macros.svh";
class spi_main_sequence extends uvm_sequence #(spi_seq_item);
	`uvm_object_utils(spi_main_sequence)
	spi_seq_item seq_item;
	logic [1:0] prev_opcode=2'bxx;
	function  new(string name="spi_main_sequence");
		super.new(name);
	endfunction 

	task body();
		repeat(10000)begin
			seq_item=spi_seq_item::type_id::create("seq_item");
			start_item(seq_item);
			 if (prev_opcode == 2'b00) begin
          assert(seq_item.randomize() with { container[9:8] == 2'b01; })
          prev_opcode = 2'b01;
        end
        else if (prev_opcode == 2'b10) begin
          assert(seq_item.randomize() with { container[9:8] == 2'b11; })
          prev_opcode = 2'b11;

        end
        else begin
          assert(seq_item.randomize())
          prev_opcode = seq_item.container[9:8];
        end

			finish_item(seq_item);
		end
	endtask : body
endclass : spi_main_sequence
endpackage : spi_main_sequence
