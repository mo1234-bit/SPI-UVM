/////////////////////////////////@CopyRights/////////////////////////////////////////////////
// Company: No sponsorship
// Team: Mohamed Gamal & Ahmed Reda & Abdallah Sabah & Abdallah sleem & Mohamed Ahmed & Ibrahim Hamdy & Beshoy Maher & Mostafa Osman
// Supervisior Dr: Sherif Fathy
// Team Leader: Mohamed Ahmed Ibrahim
// Technical Head : Mohamed Gamal & Ahmed Reda 
// Human Resource : Beshoy Magdy  
// Check Date: 19/2/2025 11:44:49 PM
// Design Name:CNN unit
// Module Name: Top module
// Project Name: Graduation project
/////////////////////////////////@CopyRights/////////////////////////////////////////////////

module top( input clk,
    input rst_n,
    output active,
    input   nice_req_valid,
   // input  [31:0]       nice_req_inst,
   // input  [31:0]       nice_req_rs1,
    //input  [31:0]       nice_req_rs2,
   output    nice_req_ready,
   output nice_rsp_valid,
    input nice_rsp_ready,
    output [31:0] nice_rsp_rdat,
    output        nice_icb_cmd_valid,
    input         nice_icb_cmd_ready,
    output [31:0] nice_icb_cmd_addr,
    output        nice_icb_cmd_read,
    output [31:0] nice_icb_cmd_rdata,
    input         nice_icb_rsp_valid,
    output        nice_icb_rsp_ready,
    input  [31:0] nice_icb_rsp_Wdata,
   
   
   input  [127:0] i_m_readdata_1,
   input  [127:0] i_m_readdata_2, 
   input  [127:0] i_m_readdata_3, 
   input  [127:0] i_m_readdata_4,   
   input [31:0] PE1_result ,
   input [31:0] PE2_result ,
   input [31:0] PE3_result ,
   input [31:0] PE4_result ,
   output [31:0] src_A1 ,
   output [31:0] src_A2 ,
   output [31:0] src_A3 ,
   output [31:0] src_A4 ,
   output [31:0] src_C1 ,
   output [31:0] src_C2 ,
   output [31:0] src_C3 ,
   output [31:0] src_C4 ,
   output  [127:0] o_m_writedata_1, 
   output  [127:0] o_m_writedata_2,
   output  [127:0] o_m_writedata_3, 
   output  [127:0] o_m_writedata_4,


input finish_pe,
output [4:0] crossbar_sel,
output [4:0] pe_mode,
output [31:0] o_p_src_b_kernel,       //review its size

output [25:0] o_m_addr_1_top,
output [3:0] o_m_byte_en_1_top,

output [25:0] o_m_addr_2_top,
output [3:0] o_m_byte_en_2_top,

output [25:0] o_m_addr_3_top,
output [3:0] o_m_byte_en_3_top,

output [25:0] o_m_addr_4_top,
output [3:0] o_m_byte_en_4_top
 );



wire o_p_readdata_valid;    //review on 4 caches
wire mem_request_valid;
wire [31:0]rs1;
wire [31:0]rs2 = 0;
wire [31:0]CNN_Result_to_EAI;
wire nice_rsp_valid_1;
wire[31:0]p_data;
wire [31:0] mem_request_data;
wire [31:0]coe_cache_data;
wire [31:0]  o_p_readdata ;       //review on cache 1 and 2
wire decoder_ready;
wire decoder_valid_top;
wire cfg_ready;
wire [31:0] instr_top;
wire send_en;        //signal inducate approval to send to pe
wire [4:0] input_to_addess_block_rs1;         //after //    //       //       //
wire [4:0] input_to_addess_block_rs2;        //after mohamed gamal finish its module
wire [2:0] fun_for_data_fetcher;
wire xs1_out;
wire xs2_out;
wire wr_flag;
wire rd_flag;
wire req_data;
wire [31:0] DATA_ADDRESS;
wire finish_cnn;
wire bank_s_sel;
wire bank_en;
wire [1:0] PE1_sel;
wire src_A_en;
wire src_C_en;

wire o_p_waitrequest_1_top;
wire i_p_read_1_top; 
wire i_p_write_1_top;

wire o_m_read_1_top; 
wire o_m_write_1_top;
wire i_m_readdata_valid_1_top;
wire i_m_waitrequest_1_top;

wire o_p_waitrequest_2_top;
wire i_p_read_2_top; 
wire i_p_write_2_top;

wire o_m_read_2_top; 
wire o_m_write_2_top;
wire i_m_readdata_valid_2_top;
wire i_m_waitrequest_2_top;

wire o_p_waitrequest_3_top;
wire i_p_read_3_top; 
wire i_p_write_3_top;

wire o_m_read_3_top; 
wire o_m_write_3_top;
wire i_m_readdata_valid_3_top;
wire i_m_waitrequest_3_top;

wire o_p_waitrequest_4_top;
wire i_p_read_4_top; 
wire i_p_write_4_top;

wire o_m_read_4_top; 
wire o_m_write_4_top;
wire i_m_readdata_valid_4_top;
wire i_m_waitrequest_4_top;

wire [31:0] bank3_s_to_cache;
wire [31:0] bank4_s_to_cache;
wire [31:0] o_p_readdata_2;
wire [31:0] o_p_readdata_4;

wire [31:0] cache_bank1_data_top;
wire [6:0] funct7_top;
wire [4:0] rs1_addr;
wire [4:0] rs2_addr;
wire [4:0] rd_addr;
wire xs1_top;
wire xs2_top;
wire xd_top;
wire [31:0] output_cnn_to_data_fetcher;

wire address_block_en;
wire [4:0] to_address_block_rs1_top;
wire [4:0] to_address_block_rs2_top;
wire [24:0] address_25_bit_as_input_to_cache;
wire [3:0] byte_enable_4_bits_as_input_to_cache;
wire o_p_readdata_valid_4,o_p_readdata_valid_3;
wire o_p_readdata_valid_4_3;
assign o_p_readdata_valid_4_3=o_p_readdata_valid_4|o_p_readdata_valid_3;
wire [127:0]coe_data;
//assign coe_data={96'b0, coe_cache_data };
wire [31:0]DATA_CACHE3_FETCHER;
wire [31:0]DATA_IN_CACHE3;
assign DATA_IN_CACHE3=(fun_for_data_fetcher==3'b011)?DATA_CACHE3_FETCHER:bank4_s_to_cache;
wire adder_we_en;
wire finish;
wire [31:0]instruction;
wire [31:0]instruction_out;
wire [31:0]data_rs1;
instruction_memory inst_mem(
    .clk(clk),
     .rst(rst_n),
     .instruction(instruction)
);

data_mem dat_mem(
    .clk(clk),
    .rst(rst_n),
    .instruction(instruction),
    .data_out(data_rs1),
    .instruction_out(instruction_out)
    );

data_fetcher fetcher (
        .clk(clk),
        .rst_n(rst_n),
        .finish(finish),
        .instruction(fun_for_data_fetcher),
        .Xs1(xs1_out),
        .Xs2(xs2_out),
        .nice_icb_cmd_ready(nice_icb_cmd_ready),
        .mem_response_valid(nice_req_ready),
        .data_response_1(rs1),
        .data_response_2(32'b0), // Example connection
        .mem_request_valid(mem_request_valid),
        .CNN_Result_to_EAI_Conroller(CNN_Result_to_EAI),
        .cache_bank1_data(cache_bank1_data_top),
        .coe_cache_data(coe_cache_data),
        .cache_bank2_data(),
        .o_p_readdata_valid(o_p_readdata_valid_4_3),
        .cache_bank2_output(output_cnn_to_data_fetcher),      //imp
        .nice_rsp_valid(nice_rsp_valid_1),
        .p_data(p_data),
        .cache_bank3_data(DATA_CACHE3_FETCHER), //imp
        .cache_bank3_output(o_p_readdata_4),     //imp
        .mem_request_data(mem_request_data)
    );




 EAI eai_ctrl (
       .clk(clk),
       .rst_n(rst_n),
       .active(active),
       .nice_req_valid(nice_req_valid),
       .nice_req_ready(nice_req_ready),
       .nice_req_inst(instruction_out),
       .nice_req_rs1(data_rs1),
       .nice_req_rs2(32'b0),
       .nice_rsp_valid(nice_rsp_valid_1),
       .nice_rsp_ready(nice_rsp_ready),
       .nice_rsp_rdat(nice_rsp_rdat),

        // Memory Interface
        .nice_icb_cmd_valid(nice_icb_cmd_valid),
        .nice_icb_cmd_ready(nice_icb_cmd_ready),
        .nice_icb_cmd_addr(nice_icb_cmd_addr),
        .nice_icb_cmd_read(nice_icb_cmd_read),
        .nice_icb_cmd_rdata(nice_icb_cmd_rdata),
        .nice_icb_rsp_valid(nice_icb_rsp_valid),
        .nice_icb_rsp_ready(nice_icb_rsp_ready),
        .nice_icb_rsp_Wdata(nice_icb_rsp_Wdata),
        // Control Signals
        .data_addr(DATA_ADDRESS),
        .req_data(req_data),
        .wr(wr_flag),
        .rd(rd_flag),
        .CNN_Result(CNN_Result_to_EAI),
        .finish(finish),
        // Decoder Interface
        .instr(instr_top),
        .rs1(rs1),
        .rs2(rs2),
        .decoder_valid(decoder_valid_top),
        .decoder_ready(decoder_ready),
        .mem_request_valid(mem_request_valid),
        .p_data(p_data),
        .unfinished_data(mem_request_data)
    );


 cache cache1 (
        .clk(clk),
        .rst(rst_n),
        .i_p_addr(address_25_bit_as_input_to_cache),
        .i_p_byte_en(byte_enable_4_bits_as_input_to_cache),
        .i_p_read(i_p_read_1_top),
        .i_p_write(i_p_write_1_top),
        .o_p_waitrequest(o_p_waitrequest_1_top),
        .o_m_addr(o_m_addr_1_top),
        .o_m_byte_en(o_m_byte_en_1_top),
        .o_m_read(o_m_read_1_top),
        .o_m_write(o_m_write_1_top),
        .i_m_readdata_valid(i_m_readdata_valid_1_top),
        .i_m_waitrequest(i_m_waitrequest_1_top),
        .i_p_writedata(coe_cache_data),  //
        .o_p_readdata(o_p_src_b_kernel),  //
        .o_p_readdata_valid(o_p_readdata_valid), //
        .o_m_writedata(o_m_writedata_1),
        .i_m_readdata(i_m_readdata_1)


    );

     cache cache2 (
        .clk(clk),
        .rst(rst_n),
        .i_p_addr(address_25_bit_as_input_to_cache),
        .i_p_byte_en(byte_enable_4_bits_as_input_to_cache),
        .i_p_read(i_p_read_2_top),
        .i_p_write(i_p_write_2_top),
        .o_p_waitrequest(o_p_waitrequest_2_top),
        .o_m_addr(o_m_addr_2_top),
        .o_m_byte_en(o_m_byte_en_2_top),
        .o_m_read(o_m_read_2_top),
        .o_m_write(o_m_write_2_top),
        .i_m_readdata_valid(i_m_readdata_valid_2_top),
        .i_m_waitrequest(i_m_waitrequest_2_top),
        .i_p_writedata(cache_bank1_data_top),  
        .o_p_readdata(o_p_readdata_2),  
        .o_p_readdata_valid(o_p_readdata_valid), // think they must be 3 different input to the data fetcher from each cache to send on the correct cache
        .o_m_writedata(o_m_writedata_2),
        .i_m_readdata(i_m_readdata_2)


    );


     cache cache3 (
        .clk(clk),
        .rst(rst_n),
        .i_p_addr(address_25_bit_as_input_to_cache),
        .i_p_byte_en(byte_enable_4_bits_as_input_to_cache),
        .i_p_read(i_p_read_3_top),
        .i_p_write(i_p_write_3_top),
        .o_p_waitrequest(o_p_waitrequest_3_top),
        .o_m_addr(o_m_addr_3_top),
        .o_m_byte_en(o_m_byte_en_3_top),
        .o_m_read(o_m_read_3_top),
        .o_m_write(o_m_write_3_top),
        .i_m_readdata_valid(i_m_readdata_valid_3_top),
        .i_m_waitrequest(i_m_waitrequest_3_top),
        .i_p_writedata(bank3_s_to_cache),  
        .o_p_readdata(output_cnn_to_data_fetcher), 
        .o_p_readdata_valid(o_p_readdata_valid_3),
        .o_m_writedata(o_m_writedata_3),
        .i_m_readdata(i_m_readdata_3)


    );

     cache cache4 (
        .clk(clk),
        .rst(rst_n),
        .i_p_addr(address_25_bit_as_input_to_cache),
        .i_p_byte_en(byte_enable_4_bits_as_input_to_cache),
        .i_p_read(i_p_read_4_top),
        .i_p_write(i_p_write_4_top),
        .o_p_waitrequest(o_p_waitrequest_4_top),
        .o_m_addr(o_m_addr_4_top),
        .o_m_byte_en(o_m_byte_en_4_top),
        .o_m_read(o_m_read_4_top),
        .o_m_write(o_m_write_4_top),
        .i_m_readdata_valid(i_m_readdata_valid_4_top),
        .i_m_waitrequest(i_m_waitrequest_4_top),
        .i_p_writedata(DATA_IN_CACHE3),  
        .o_p_readdata(o_p_readdata_4),  
        .o_p_readdata_valid(o_p_readdata_valid_4), 
        .o_m_writedata(o_m_writedata_4),
        .i_m_readdata(i_m_readdata_4)


    );


     DataSelector data_sel (
        .clk(clk),
        .rst(rst_n),
        .cache1_data(o_p_readdata_2),
        .cache2_data(o_p_readdata_4),
        .PE1_result(PE1_result),
        .PE2_result(PE2_result),
        .PE3_result(PE3_result),
        .PE4_result(PE4_result),
        .src_A1(src_A1),
        .src_A2(src_A2),
        .src_A3(src_A3),
        .src_A4(src_A4),
        .src_C1(src_C1),
        .src_C2(src_C2),
        .src_C3(src_C3),
        .src_C4(src_C4),       
        .PE1_sel(PE1_sel),  
        .bank_s_sel(bank_s_sel),   
        .bank_s_en(bank_en),     
        .store_result1(PE1_sel) , 
        .src_A_en(src_A_en) ,     
        .src_C_en(src_C_en),       
        .send_en(send_en) ,
        .bank3_s(bank3_s_to_cache),
        .bank4_s(bank4_s_to_cache)

    );

   //DONE
    decoder instr_decoder (
        .clk(clk),
        .rst_n(rst_n),
        .ready(decoder_valid_top),
        .instruction(instr_top),
        .finish(decoder_ready),
        .cfg_ready(cfg_ready),
        .cfg_valid(cfg_valid),
        .funct7(funct7_top),
        .rs1(rs1_addr),
        .rs2(rs2_addr),
        .rd(rd_addr),
        .xs1(xs1_top),
        .xs2(xs2_top),
        .xd(xd_top)
    );





        config_controller cfg_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .reset_en(),                      

        // Decoder Interface
        .cfg_valid(cfg_valid),
        .funct7(funct7_top),
        .rs1(rs1_addr),
        .rs2(rs2_addr),
        .rd(rd_addr),
        .xs1(xs1_top),
        .xs2(xs2_top),
        .xd(xd_top),
        .cfg_ready(cfg_ready),


        // Cache 1 Interface
        .o_p_waitrequest_1(o_p_waitrequest_1_top),
        .i_p_read_1(i_p_read_1_top),
        .i_p_write_1(i_p_write_1_top),

        .o_m_read_1(o_m_read_1_top),
        .o_m_write_1(o_m_write_1_top),
        .i_m_readdata_valid_1(i_m_readdata_valid_1_top),
        .i_m_waitrequest_1(i_m_waitrequest_1_top),


        // Cache 2 Interface
        .o_p_waitrequest_2(o_p_waitrequest_2_top),
        .i_p_read_2(i_p_read_2_top),
        .i_p_write_2(i_p_write_2_top),

        .o_m_read_2(o_m_read_2_top),
        .o_m_write_2(o_m_write_2_top),
        .i_m_readdata_valid_2(i_m_readdata_valid_2_top),
        .i_m_waitrequest_2(i_m_waitrequest_2_top),


        // Cache 3 Interface
        .o_p_waitrequest_3(o_p_waitrequest_3_top),
        .i_p_read_3(i_p_read_3_top),
        .i_p_write_3(i_p_write_3_top),

        .o_m_read_3(o_m_read_3_top),
        .o_m_write_3(o_m_write_3_top),
        .i_m_readdata_valid_3(i_m_readdata_valid_3_top),
        .i_m_waitrequest_3(i_m_waitrequest_3_top),


        // Cache 4 Interface
        .o_p_waitrequest_4(o_p_waitrequest_4_top),
          .i_p_read_4(i_p_read_4_top),
          .i_p_write_4(i_p_write_4_top),

        .o_m_read_4(o_m_read_4_top),
        .o_m_write_4(o_m_write_4_top),
        .i_m_readdata_valid_4(i_m_readdata_valid_4_top),
        .i_m_waitrequest_4(i_m_waitrequest_4_top),


        // Data Fetcher Interface
        .fun_for_data_fetcher(fun_for_data_fetcher),
        .xs1_out(xs1_out),
        .xs2_out(xs2_out),


        // EAI Interface
        .RD_FLAG(rd_flag),
        .WR_FLAG(wr_flag),
        .REQ_DATA(req_data),
        .DATA_ADDRESS(DATA_ADDRESS),
        .finish(finish_cnn),


        // Data Selector Interface
        .BANKID(bank_s_sel),
        .BANK_READY(bank_en),  //to enable the data selector to send to what cache "default bank 3 as it reset by "0"
        .PEID(PE1_sel),
        .src_a_enable(src_A_en),
        .src_c_enable(src_C_en),
        .send_en (send_en),


        //PE interface 
        .finish_pe(finish_pe),
        .crossbar_sel(crossbar_sel),
        .pe_mode(pe_mode),
        .start_cal(),                       


   //interface with address block
        .address_block_en(address_block_en),
        .to_address_block_rs1(to_address_block_rs1_top),
        .to_address_block_rs2(to_address_block_rs2_top),
        .addr_wr(adder_we_en)

    );








    address addr (
    .wr(adder_we_en),
    .clk(clk),    
	.rst_n(rst_n),  
	.valid(address_block_en),    // when it come it activate the addrees block (no need for handcheck)
	.rs1(to_address_block_rs1_top),   //base address is the  starting point or reference location in memory
	.rs2(to_address_block_rs2_top),   // An offset is a value that indicates how far you need to move from the base address.
	.cache_address_i(address_25_bit_as_input_to_cache),
    .byte_en(byte_enable_4_bits_as_input_to_cache)
);

 endmodule