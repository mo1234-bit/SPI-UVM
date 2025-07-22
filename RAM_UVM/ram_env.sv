package ram_env;
	import ram_agent::*;
	import ram_scoreboard::*;
	import ram_coverage::*;
	import uvm_pkg::*;
`include "uvm_macros.svh";
class ram_env extends  uvm_env;
	`uvm_component_utils(ram_env);
    ram_agent agt;
    ram_scoreboard sb;
    ram_coverage covr;
    function  new(string name="ram_env",uvm_component parent=null);
    	super.new(name,parent);
    endfunction 
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
    	agt=ram_agent::type_id::create("agt",this);
    	sb=ram_scoreboard::type_id::create("sb",this);
    	covr=ram_coverage::type_id::create("covr",this);
    endfunction 

    function void connect_phase(uvm_phase phase);
    	super.connect_phase(phase);
    	agt.agt_ap.connect(sb.sb_export);
    	agt.agt_ap.connect(covr.covr_export);
    endfunction 
endclass : ram_env
endpackage : ram_env