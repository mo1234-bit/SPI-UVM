module ram_sva (ram_if.dut ramif);

    property a;
    	@(posedge ramif.clk) disable iff(!ramif.rst_n) (ramif.din[9:8]==2'b11&&ramif.rx_valid==1)|=>ramif.tx_valid;
    endproperty

    	property b;
    		@(posedge ramif.clk) (!ramif.rst_n)|=>(ramif.dout==0&&!ramif.tx_valid&&!dut.wr_op&&!dut.rd_op);
    	endproperty

     property c;
     	@(posedge  ramif.clk) disable iff(!ramif.rst_n) (ramif.din[9:8]==2'b00&&ramif.rx_valid==1)|=>(dut.wr_op==$past(ramif.din[7:0]));
     endproperty
     	 property d;
     	@(posedge ramif.clk) disable iff(!ramif.rst_n) (ramif.din[9:8]==2'b10&&ramif.rx_valid==1)|=>(dut.rd_op==$past(ramif.din[7:0]));
     endproperty

  property e;
    	@(posedge ramif.clk) disable iff(!ramif.rst_n) ((ramif.din[9:8]==2'b10||ramif.din[9:8]==2'b00||ramif.din[9:8]==2'b01)&&ramif.rx_valid==1)|=>!ramif.tx_valid;
    endproperty

assert property(a);
assert property(b);
assert property(c);
assert property(d);
assert property(e);

cover property(a);
cover property(b);
cover property(c);
cover property(d);
cover property(e);
endmodule : ram_sva