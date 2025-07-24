package ram_config;
	import uvm_pkg::*;
`include "uvm_macros.svh";
class ram_config extends uvm_object;
	`uvm_object_utils(ram_config)
	virtual ram_if ram_if;
	uvm_active_passive_enum is_active;
	function  new(string name="ram_config");
		super.new(name);
	endfunction 
endclass : ram_config
endpackage : ram_config