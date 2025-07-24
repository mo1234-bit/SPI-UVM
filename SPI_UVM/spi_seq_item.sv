package spi_seq_item;
		import uvm_pkg::*;
`include "uvm_macros.svh";
class spi_seq_item extends  uvm_sequence_item;
	`uvm_object_utils(spi_seq_item)
	rand logic[10:0]container;
	function  new(string name ="spi_seq_item");
		super.new(name);
container=0;
	endfunction 
rand logic MOSI,SS_n,rst_n;
logic MISO;
logic MISO_ref;
logic add_sent;
function void pre_randomize();
	if(!rst_n)
		add_sent=0;
	else begin
		if(container[10:8]==3'b110)
			add_sent=1;
		else
			add_sent=0;
	end
     
endfunction 
constraint data {
	if(container[10]&&add_sent){
		container[9:8]==2'b11;
	}else{
	container[10:8] inside {3'b110,3'b001,3'b000};
	}
}

constraint a {
	SS_n dist {1:=20,0:=80};
}

constraint rst {
	rst_n dist {1:=98,0:=2};
}



function string convert2string();
	return $sformatf("%s SS_n=%0b rst_n=%0b MOSI=%0b  MISO=%0b",super.convert2string(),SS_n,rst_n,MOSI,MISO );
endfunction 

endclass : spi_seq_item
endpackage : spi_seq_item