interface spi_if (clk);
input clk;
logic MOSI,SS_n,rst_n;
logic MISO;
logic [10:0]container;
logic MISO_ref;
endinterface : spi_if