module PE(
	input clk,reset,local_reset,local_rst_all_conv, local_rst_all_pool, local_rst_all_relu, local_rst_all_add,
	input [31:0]srcA,
	input [31:0]srcB,
	input [31:0]srcC,
	input Conv_en,
	input adder_en,
	input pool_en,
	input relu_en,
	input [3:0]F,
	input [4:0] sel_Conv,
    input [4:0]sel_Add,
    input[4:0]sel_Relu,
    input [4:0] sel_Pool,
    input [4:0] sel_Res,
    input [9:0] addr_conv,
    input [9:0]addr_add,
    input [9:0]addr_relu,
    input [9:0] addr_pool,
    input [9:0] addr_src_A,
    input [9:0] addr_read_conv, addr_read_add, addr_read_relu, addr_read_pool, addr_read_src_A,
    input  conv_read_en,
      input conv_write_en,
    input pool_read_en,
    input pool_write_en,
    input add_read_en,
    input [7:0]N,
    input add_write_en,
    input relu_read_en,
   input  relu_write_en,
   input srcA_read_en,
   input srcA_write_en,
	input [7:0] Np,
	input [2:0] P,
	output  [31:0]Result,
	output overflow,
	output finish_conv,finish_pool,finish_relu,finish_adder,
    output indicator, indicator1, indicator2,indicator3,indicator4,
    output valid_pool,
    output wire unvalid2,
    output [10:0]index_4
	);



wire [7:0]pixel_in;
wire [15:0]conv_result;
wire Overflow_conv;
wire [15:0] in_pool;
wire [15:0] out_pool;
wire [15:0] in_relu;
wire [15:0] out_relu;
wire [31:0]Add_In;
wire [31:0]Add_Out;
wire Overflow_Add;
wire unvalid;
wire unvalid1;
wire unvalid3;
assign overflow= Overflow_Add | Overflow_conv;
wire add_to_relu_valid;
wire [15:0]conv_result_1;
assign add_to_relu_valid = finish_adder;
assign conv_result=(finish_pool)?0:conv_result_1;
top_conv conv(
    pixel_in,
    clk,
    srcB,
    reset,
    local_reset,
    F,
    N,
    Conv_en,
    conv_result_1,
    finish_conv,
    Overflow_conv,
    unvalid,
    local_rst_all_conv,
    index_4
    );

maxpool_unit maxpool(
    clk,
    reset,
    pool_en,
    Np,  
    P,  
    in_pool, 
    out_pool,
    finish_pool,
    unvalid1,
    valid_pool,
    local_rst_all_pool
);

Relu relu(  
    reset,                
    clk,
    relu_en,            
    in_relu,   
    out_relu,
    finish_relu,
    unvalid2,
    add_to_relu_valid,
    sel_Relu,
    local_rst_all_relu     
);

Add_Module adder(
    Add_In,
    srcC,
    adder_en,         
    reset,              
    clk,                    
    Add_Out,
    Overflow_Add,    
    finish_adder,
    unvalid3,
    local_rst_all_add            
);


crossbar crossbar(
    clk,
    reset,
    srcA,
    Add_Out,
    conv_result_1,
    out_pool,
    out_relu,
    sel_Conv,
    sel_Add,
    sel_Relu,
    sel_Pool,
    sel_Res, 
    addr_conv,
    addr_add,
    addr_relu,
    addr_pool,
    addr_src_A,
    conv_read_en,
    conv_write_en,
    pool_read_en,
    pool_write_en,
    add_read_en,
    add_write_en,
    relu_read_en,
    relu_write_en,
    srcA_read_en,
    srcA_write_en,
    addr_read_conv,
    addr_read_add,
    addr_read_relu,
    addr_read_pool,
    addr_read_src_A,
    Result,
    Add_In,
    in_relu,
    in_pool,
    pixel_in,
    indicator,
    indicator1,
    indicator2,
    indicator3,
    indicator4,
    unvalid ,
    unvalid1 ,
    unvalid2,
    unvalid3         
);

endmodule