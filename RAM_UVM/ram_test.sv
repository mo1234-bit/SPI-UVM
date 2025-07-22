package ram_test;
	import ram_env::*;
	import ram_config::*;
	import ram_reset_sequence::*;
	import ram_write_sequence::*;
	import ram_read_sequence::*;
	import ram_write_read_sequence::*;
		import uvm_pkg::*;
`include "uvm_macros.svh";
class ram_test extends  uvm_test;
	`uvm_component_utils(ram_test);
	ram_config conf;
	ram_env env;
	ram_reset_sequence reset_seq;
	ram_write_sequence write_seq;
	ram_read_sequence read_seq;
	ram_write_read_sequence wr_rd_seq;
	function  new(string name="uvm_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		conf=ram_config::type_id::create("conf");
		env=ram_env::type_id::create("env",this);
		reset_seq=ram_reset_sequence::type_id::create("reset_seq");
		write_seq=ram_write_sequence::type_id::create("write_seq");
		read_seq=ram_read_sequence::type_id::create("read_seq");
		wr_rd_seq=ram_write_read_sequence::type_id::create("wr_rd_seq");
		if(!uvm_config_db#(virtual ram_if)::get(this,"","ram_if",conf.ram_if))begin
			`uvm_fatal("build_phase","unable to get interface in test")
		end
		uvm_config_db#(ram_config)::set(this,"*","CFG",conf);
	endfunction 
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		phase.raise_objection(this);
		reset_seq.start(env.agt.sqr);
		write_seq.start(env.agt.sqr);
		read_seq.start(env.agt.sqr);
		wr_rd_seq.start(env.agt.sqr);
		phase.drop_objection(this);
	endtask : run_phase
endclass : ram_test
endpackage : ram_test