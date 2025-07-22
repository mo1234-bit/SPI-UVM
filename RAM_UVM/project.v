module project (MOSI,MISO,SS_n,clk,rst_n);
input MOSI,clk,rst_n,SS_n;
output MISO;
wire rx_valid,tx_valid;
wire[7:0]tx_data;
wire [9:0]rx_data;
SPI dut(MOSI,MISO,SS_n,clk,rst_n,rx_data,rx_valid,tx_data,tx_valid);
ram dut1(rx_data,clk,rst_n,rx_valid,tx_data,tx_valid);
endmodule