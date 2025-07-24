package spi_driver;
	import spi_seq_item::*;
		import uvm_pkg::*;
`include "uvm_macros.svh";
class spi_driver extends  uvm_driver #(spi_seq_item);
	`uvm_component_utils(spi_driver)
	spi_seq_item seq_item;
	virtual spi_if spi_if;
	function  new(string name ="spi_driver",uvm_component parent=null);
		super.new(name,parent);
	endfunction 

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever begin
			seq_item=spi_seq_item::type_id::create("seq_item");
			seq_item_port.get_next_item(seq_item);
			for(int i=0; i<11;i++)begin 
             spi_if.MOSI=seq_item.container[10-i];
             spi_if.SS_n=seq_item.SS_n;
             spi_if.rst_n=seq_item.rst_n;
             spi_if.container=seq_item.container;
             @(negedge spi_if.clk);end 
             if(seq_item.container[10:8]==3'b111)begin
             	repeat(12)begin
             	@(negedge spi_if.clk);
             end
             end
             @(negedge spi_if.clk);
             seq_item.SS_n=1;
             spi_if.MOSI=seq_item.container[10];
               spi_if.SS_n=seq_item.SS_n;
             spi_if.rst_n=seq_item.rst_n;
             spi_if.container=seq_item.container;
              @(negedge spi_if.clk);
             seq_item_port.item_done();
		end
	endtask : run_phase
endclass : spi_driver
endpackage : spi_driver