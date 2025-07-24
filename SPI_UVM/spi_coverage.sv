package spi_coverage;
	import spi_seq_item::*;
			import uvm_pkg::*;
`include "uvm_macros.svh";
class spi_coverage extends  uvm_component;
	`uvm_component_utils(spi_coverage);
	spi_seq_item seq_item;
	uvm_analysis_export #(spi_seq_item)covr_export;
	uvm_tlm_analysis_fifo #(spi_seq_item)covr_fifo;

	covergroup cg();
		a:coverpoint seq_item.SS_n;
		b:coverpoint seq_item.MOSI;
		r:coverpoint seq_item.MISO;
		y:coverpoint seq_item.rst_n;
	endgroup : cg
		function  new(string name="spi_coverage",uvm_component parent=null);
		super.new(name,parent);
		cg=new();
	endfunction

	function void build_phase(uvm_phase phase);
	    	super.build_phase(phase);
	    	covr_export=new("covr_export",this);
	    	covr_fifo=new("covr_fifo",this);
	 endfunction  

	 function void connect_phase(uvm_phase phase);
	 	super.connect_phase(phase);
	 	covr_export.connect(covr_fifo.analysis_export);
	 endfunction 

	 task run_phase(uvm_phase phase);
	 	super.run_phase(phase);
         forever begin
         	covr_fifo.get(seq_item);
         	cg.sample();
         end
	 endtask : run_phase
endclass : spi_coverage
endpackage : spi_coverage