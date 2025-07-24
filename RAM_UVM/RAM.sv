module ram(din,clk,rst_n,rx_valid,dout,tx_valid);
parameter MEM_DEPTH=512;
parameter ADDER_SIZE=8;
input [9:0]din;
input clk,rst_n,rx_valid;
output reg [ADDER_SIZE-1:0]dout;
output reg tx_valid;

    reg [ADDER_SIZE-1:0] mem [MEM_DEPTH-1:0];
    reg [ADDER_SIZE-1:0] wr_op, rd_op;

    always @(posedge clk ) begin
        if (~rst_n) begin
            dout <= 0;
            tx_valid <= 0;
            wr_op <= 0;
            rd_op <= 0;
        end else if (rx_valid) begin
            case (din[9:8])
                2'b00: begin
                    wr_op <= din[7:0];
                    tx_valid <= 0;
                end
                2'b01: begin
                    mem[wr_op] <= din[7:0];
                    tx_valid <= 0;
                end
                2'b10: begin
                    rd_op <= din[7:0];
                    tx_valid <= 0;
                end
                2'b11: begin
                    dout <= mem[rd_op];
                    tx_valid <= 1;
                end
                default: begin
                    tx_valid <= 0;
                end
            endcase
        end
        
    end
endmodule
