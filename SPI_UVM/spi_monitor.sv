package spi_monitor;
	import spi_seq_item::*;
		import uvm_pkg::*;
`include "uvm_macros.svh";
class spi_monitor extends  uvm_monitor;
	`uvm_component_utils(spi_monitor);
	spi_seq_item seq_item;
	virtual spi_if spi_if;
	uvm_analysis_port #(spi_seq_item)mon_ap;
	function  new(string name="spi_monitor",uvm_component parent=null);
		super.new(name,parent);
	endfunction 
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		mon_ap=new("mon_ap",this);
		endfunction
		
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever begin
			seq_item=spi_seq_item::type_id::create("seq_item");
			@(negedge spi_if.clk);
			seq_item.MOSI=spi_if.MOSI;
			seq_item.SS_n=spi_if.SS_n;
			seq_item.rst_n=spi_if.rst_n;
			seq_item.MISO=spi_if.MISO;
			seq_item.container=spi_if.container;
			seq_item.MISO_ref=spi_if.MISO_ref;
			mon_ap.write(seq_item);
		end
	endtask : run_phase
endclass : spi_monitor
endpackage : spi_monitor