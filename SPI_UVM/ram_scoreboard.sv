package ram_scoreboard;
	import ram_seq_item::*;
	import pkg::*;
		import uvm_pkg::*;
`include "uvm_macros.svh";
class ram_scoreboard extends  uvm_scoreboard;
	`uvm_component_utils(ram_scoreboard)
	ram_seq_item seq_item;
	uvm_analysis_export #(ram_seq_item)sb_export;
	uvm_tlm_analysis_fifo #(ram_seq_item)sb_fifo;
	integer correct_count=0, error_count=0;
	function  new(string name="ram_scoreboard",uvm_component parent=null);
		super.new(name,parent);
	endfunction 
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		sb_export=new("sb_export",this);
		sb_fifo=new("sb_fifo",this);
	endfunction 
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		sb_export.connect(sb_fifo.analysis_export);
	endfunction 

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever begin
			sb_fifo.get(seq_item);
			
			if(seq_item.dout!==seq_item.dout_ref||seq_item.tx_valid!==seq_item.tx_valid_ref)begin
				`uvm_error("run_phase",$sformatf("%s dout_ref=%0b and tx_valid_ref=%0b",seq_item.convert2string(),seq_item.dout_ref,seq_item.tx_valid_ref ) );
                 error_count++;
             end 
             else 
             	correct_count++;
		end
	endtask 

	function void report_phase(uvm_phase phase);
		super.report_phase(phase);
		`uvm_info("report_phase",$sformatf("successful:%0d",correct_count),UVM_MEDIUM);
		`uvm_info("report_phase",$sformatf("faild:%0d",error_count),UVM_MEDIUM);
	endfunction 
	
endclass : ram_scoreboard
endpackage : ram_scoreboard