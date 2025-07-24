package ram_agent;
	import ram_sequencer::*;
	import ram_driver::*;
	import ram_config::*;
	import ram_monitor::*;
	import ram_seq_item::*;
			import uvm_pkg::*;
`include "uvm_macros.svh";
class ram_agent extends  uvm_agent;
	`uvm_component_utils(ram_agent)
	ram_sequencer sqr;
	ram_driver dri;
	ram_config conf;
	ram_monitor mon;
	uvm_analysis_port #(ram_seq_item) agt_ap;
	function  new(string name="ram_agent",uvm_component parent=null);
		super.new(name,parent);
	endfunction 

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(ram_config)::get(this,"","CFG",conf))begin
			`uvm_fatal("build_phase","unable to get interface in agent")
		end
		if(conf.is_active==UVM_ACTIVE)begin
		sqr=ram_sequencer::type_id::create("sqr",this);
		dri=ram_driver::type_id::create("dri",this);
	    end
		mon=ram_monitor::type_id::create("mon",this);
		agt_ap=new("agt_ap",this);   //
		
	endfunction 

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		if(conf.is_active==UVM_ACTIVE)begin
		dri.ram_if=conf.ram_if;
		dri.seq_item_port.connect(sqr.seq_item_export);
	end
		mon.mon_ap.connect(agt_ap);
		mon.ram_if=conf.ram_if;
	endfunction 
endclass : ram_agent
endpackage : ram_agent