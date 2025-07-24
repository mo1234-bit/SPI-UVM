package spi_env;
	import spi_scoreboard::*;
	import spi_agent::*;
	import spi_coverage::*;
	import uvm_pkg::*;
`include "uvm_macros.svh";
class spi_env extends  uvm_env;
	`uvm_component_utils(spi_env)
	spi_agent agt;
	spi_scoreboard sb;
	spi_coverage covr;
	function  new(string name="spi_env",uvm_component parent =null);
		super.new(name,parent);
	endfunction 
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		agt=spi_agent::type_id::create("agt",this);
		sb=spi_scoreboard::type_id::create("sb",this);
		covr=spi_coverage::type_id::create("covr",this);
	endfunction 

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		agt.agt_ap.connect(sb.sb_export);
		agt.agt_ap.connect(covr.covr_export);
	endfunction 
endclass : spi_env
endpackage : spi_env