module project_ram(din,clk,rst_n,rx_valid,dout,tx_valid); 
    parameter MEM_DEPTH = 256; 
    parameter ADDR_SIZE = 8; 
    input rx_valid,clk,rst_n; 
    input [9:0] din; 
    output reg tx_valid; 
    output reg [7:0] dout; 

    import "DPI-C" function void ram_sim_immediate(
        input int din,
        input int clk,
        input int rst_n,
        input int rx_valid
    );
    
    import "DPI-C" function int get_dout_int();
    import "DPI-C" function int get_tx_valid_int();

    always @(posedge clk or negedge rst_n) begin
       
            ram_sim_immediate(int'(din), 1'b1, int'(rst_n), int'(rx_valid));
            dout <= get_dout_int()[ADDR_SIZE-1:0];
            tx_valid <= get_tx_valid_int() ? 1'b1 : 1'b0;
        
    end

endmodule