package spi_config;
		import uvm_pkg::*;
`include "uvm_macros.svh";
class spi_config extends uvm_object;
	`uvm_object_utils(spi_config)
virtual spi_if spi_if;
uvm_active_passive_enum is_active;
function  new(string name="spi_config");
	super.new(name);
endfunction 
endclass : spi_config
endpackage : spi_config