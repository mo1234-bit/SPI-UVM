package spi_agent;
	import spi_config::*;
	import spi_seq_item::*;
	import spi_sequencer::*;
	import spi_monitor::*;
	import spi_driver::*;
	import uvm_pkg::*;
`include "uvm_macros.svh";
class spi_agent extends  uvm_agent;
	`uvm_component_utils(spi_agent)
	spi_config conf;
	spi_sequencer sqr;
	spi_monitor mon;
	spi_driver dri;
	uvm_analysis_port #(spi_seq_item) agt_ap;
	function  new(string name="spi_agent",uvm_component parent=null);
		super.new(name,parent);
	endfunction 
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(spi_config)::get(this,"","CFG",conf))begin
			`uvm_fatal("build_phase","unable to get interface in agent");
		end
		if(conf.is_active==UVM_ACTIVE)begin
		sqr=spi_sequencer::type_id::create("sqr",this);
         dri=spi_driver::type_id::create("dri",this);
	end
	mon=spi_monitor::type_id::create("mon",this);
		agt_ap=new("agt_ap",this);
		

	endfunction
	function void connect_phase(uvm_phase phase);
	 	super.connect_phase(phase);
	 	if(conf.is_active==UVM_ACTIVE)begin
	 	dri.spi_if=conf.spi_if;
	 	dri.seq_item_port.connect(sqr.seq_item_export);
	 end
	 	mon.spi_if=conf.spi_if;
	 	mon.mon_ap.connect(agt_ap);
	 		 endfunction  
endclass : spi_agent
endpackage : spi_agent