package ram_coverage;
	import ram_seq_item::*;
	import uvm_pkg::*;
`include "uvm_macros.svh";
class ram_coverage extends  uvm_component;
	`uvm_component_utils(ram_coverage);
	ram_seq_item seq_item;
    uvm_analysis_export #(ram_seq_item)covr_export;
    uvm_tlm_analysis_fifo #(ram_seq_item)covr_fifo;

    covergroup cg();
    	a:coverpoint seq_item.rx_valid;
    	b:coverpoint seq_item.din;
    	c:coverpoint seq_item.dout;
    	d:coverpoint seq_item.tx_valid;
    	f:coverpoint seq_item.din[9:8]{
    	 bins set_wr_op = {2'b00};
         bins write_mem = {2'b01};
         bins set_rd_op = {2'b10};
         bins read_mem = {2'b11};}
         o:coverpoint seq_item.rst_n;
    	// e:cross a,f,d iff (seq_item.rst_n){
    	// illegal_bins q=binsof(f.set_wr_op)&&binsof(a)intersect{1}&&binsof(d)intersect{1};
    	// illegal_bins t=binsof(f.write_mem)&&binsof(a)intersect{1}&&binsof(d)intersect{1};
    	// illegal_bins i=binsof(f.set_rd_op)&&binsof(a)intersect{1}&&binsof(d)intersect{1};
    	// illegal_bins po=binsof(f.read_mem)&&binsof(a)intersect{1}&&binsof(d)intersect{0};
    	// }
    endgroup : cg

    function  new(string name="ram_coverage",uvm_component parent=null);
    	super.new(name,parent );
    	cg=new;
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
endclass : ram_coverage
endpackage : ram_coverage