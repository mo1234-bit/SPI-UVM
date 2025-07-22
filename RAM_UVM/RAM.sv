module ram(ram_if.dut ramif);
parameter MEM_DEPTH=512;
parameter ADDER_SIZE=8;

    reg [ADDER_SIZE-1:0] mem [MEM_DEPTH-1:0];
    reg [ADDER_SIZE-1:0] wr_op, rd_op;

    always @(posedge ramif.clk ) begin
        if (~ramif.rst_n) begin
            ramif.dout <= 0;
            ramif.tx_valid <= 0;
            wr_op <= 0;
            rd_op <= 0;
        end else if (ramif.rx_valid) begin
            case (ramif.din[9:8])
                2'b00: begin
                    wr_op <= ramif.din[7:0];
                    ramif.tx_valid <= 0;
                end
                2'b01: begin
                    mem[wr_op] <= ramif.din[7:0];
                    ramif.tx_valid <= 0;
                end
                2'b10: begin
                    rd_op <= ramif.din[7:0];
                    ramif.tx_valid <= 0;
                end
                2'b11: begin
                    ramif.dout <= mem[rd_op];
                    ramif.tx_valid <= 1;
                end
                default: begin
                    ramif.tx_valid <= 0;
                end
            endcase
        end
    end
endmodule
