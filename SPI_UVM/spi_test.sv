package spi_test;
	import ram_env::*;
	import ram_reset_sequence::*;
	import ram_write_sequence::*;
	import ram_read_sequence::*;
	import ram_write_read_sequence::*;
	import ram_config::*;
	import spi_config::*;
	import spi_reset_sequence::*;
	import spi_main_sequence::*;
	import spi_env::*;
	import uvm_pkg::*;
`include "uvm_macros.svh";
class spi_test extends  uvm_test;
	`uvm_component_utils(spi_test);
	spi_config conf;
	spi_reset_sequence reset_seq;
	spi_main_sequence main_seq;
	spi_env env;
	ram_config ram_conf;
	ram_env ram_env1;
	ram_reset_sequence ram_reset_seq;
	ram_write_sequence write_seq;
	ram_read_sequence read_seq;
	ram_write_read_sequence wr_rd_seq;
	function  new(string name="spi_test",uvm_component parent =null);
		super.new(name,parent);
	endfunction 
	function void  build_phase(uvm_phase phase);
		super.build_phase(phase);

		env=spi_env::type_id::create("env",this);
		conf=spi_config::type_id::create("conf");
		reset_seq=spi_reset_sequence::type_id::create("reset_seq");
		main_seq=spi_main_sequence::type_id::create("main_seq");
		ram_conf=ram_config::type_id::create("ram_conf");
		ram_env1=ram_env::type_id::create("ram_env1",this);
		ram_reset_seq=ram_reset_sequence::type_id::create("ram_reset_seq");
		write_seq=ram_write_sequence::type_id::create("write_seq");
		read_seq=ram_read_sequence::type_id::create("read_seq");
		wr_rd_seq=ram_write_read_sequence::type_id::create("wr_rd_seq");

		if(!uvm_config_db#(virtual ram_if)::get(this,"","ram_if",ram_conf.ram_if))begin
			`uvm_fatal("build_phase","unable to get interface in test")
		end
		uvm_config_db#(ram_config)::set(this,"*","CFG",ram_conf);
		ram_conf.is_active=UVM_PASSIVE;
		if(!uvm_config_db#(virtual spi_if)::get(this,"","spi_if",conf.spi_if))begin
			`uvm_fatal("build_phase","unable to get interface in test");
		end
         uvm_config_db#(spi_config)::set(this,"*","CFG",conf);
         conf.is_active=UVM_ACTIVE;
	endfunction 


	task run_phase  (uvm_phase phase);
		super.run_phase(phase);
		phase.raise_objection(this);
		reset_seq.start(env.agt.sqr);
		main_seq.start(env.agt.sqr);
		phase.drop_objection(this);
	 endtask : run_phase
endclass : spi_test
endpackage : spi_test