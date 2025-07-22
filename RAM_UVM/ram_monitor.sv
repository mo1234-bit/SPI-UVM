package ram_monitor;
	import ram_seq_item::*;
			import uvm_pkg::*;
`include "uvm_macros.svh";
class ram_monitor extends  uvm_monitor;
	`uvm_component_utils(ram_monitor);
	ram_seq_item seq_item;
	virtual ram_if ram_if;
	uvm_analysis_port #(ram_seq_item)mon_ap;
	function  new(string name="ram_monitor",uvm_component parent=null);
		super.new(name,parent);
	endfunction 

    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
    	mon_ap=new("mon_ap",this);
    endfunction

    task run_phase(uvm_phase phase);
    	super.run_phase(phase);
    	forever begin
    		seq_item=ram_seq_item::type_id::create("seq_item");
    		@(negedge ram_if.clk);
    		seq_item.rst_n=ram_if.rst_n;
    		seq_item.din=ram_if.din;
    		seq_item.rx_valid=ram_if.rx_valid;
    		seq_item.dout=ram_if.dout;
    		seq_item.tx_valid=ram_if.tx_valid;
    		mon_ap.write(seq_item);
    		

    	end
    endtask : run_phase

endclass : ram_monitor
endpackage : ram_monitor