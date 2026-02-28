module cnn_top_module(
    input wire clk,
    input wire rst_n,
    input wire reset,
    // External interface
    input wire nice_req_valid,
    output wire nice_req_ready,
    output wire nice_rsp_valid,
    input wire nice_rsp_ready,
    output wire [31:0] nice_rsp_rdat,
    
    // Memory interface
    output wire nice_icb_cmd_valid,
    input wire nice_icb_cmd_ready,
    output wire [31:0] nice_icb_cmd_addr,
    output wire nice_icb_cmd_read,
    output wire [31:0] nice_icb_cmd_rdata,
    input wire nice_icb_rsp_valid,
    output wire nice_icb_rsp_ready,
    input wire [31:0] nice_icb_rsp_Wdata
);

    // Internal wires
    wire [31:0]direct_path;
    wire active;
    wire [31:0] instruction;
    wire decoder_valid;
    wire decoder_ready;
    wire cfg_valid;
    wire cfg_ready;
    wire [6:0] funct7;
    wire [4:0] rs1_addr, rs2_addr, rd_addr;
    wire direct;
    wire xs1, xs2, xd;
    wire [31:0] instr_out;
    wire [10:0]index_4;
    // Controller signals
    wire [4:0] crossbar_sel;
    wire [4:0] pe_mode;
    wire Conv_en, adder_en, pool_en, relu_en;
    wire [3:0] F;
    wire [7:0] Np;
    wire [2:0] P;
    wire [4:0] sel_Conv, sel_Add, sel_Relu, sel_Pool, sel_Res;
    wire [9:0] addr_conv, addr_add, addr_relu, addr_pool, addr_src_A;
    wire conv_read_en, conv_write_en, pool_read_en, pool_write_en;
    wire add_read_en, add_write_en, relu_read_en, relu_write_en;
    wire srcA_read_en, srcA_write_en;
    wire [3:0] finish_conv, finish_pool, finish_relu, finish_adder;
    wire [1:0] PEID;
    wire src_A_en, src_C_en, send_en;
    wire finish_operation;
     wire finish_op = (crossbar_sel==1)?finish_conv:(crossbar_sel==2||crossbar_sel==6||crossbar_sel==9)?(finish_pool||addr_pool==(Np/P)*(Np/P)||addr_pool==(Np/P)*(Np/P)-1):(crossbar_sel==3)?finish_adder:(crossbar_sel==4||crossbar_sel==5||crossbar_sel==7||crossbar_sel==8)?finish_relu:0;
    // Cache interface
    wire o_p_waitrequest_1, o_p_waitrequest_2, o_p_waitrequest_3, o_p_waitrequest_4;
    wire i_p_read_1, i_p_write_1, i_p_read_2, i_p_write_2;
    wire i_p_read_3, i_p_write_3, i_p_read_4, i_p_write_4;
    wire i_m_readdata_valid_1, i_m_waitrequest_1;
    wire i_m_readdata_valid_2, i_m_waitrequest_2;
    wire i_m_readdata_valid_3, i_m_waitrequest_3;
    wire i_m_readdata_valid_4, i_m_waitrequest_4;
    
    // Data fetcher signals
    wire [2:0] fun_for_data_fetcher;
    wire xs1_out, xs2_out;
    
    // Address block interface
    wire [4:0] to_address_block_rs1, to_address_block_rs2;
    wire address_block_en, addr_wr;
    
    // EAI controller interface
    wire RD_FLAG, WR_FLAG, REQ_DATA;
    wire [31:0] DATA_ADDRESS;
    
    // PE interface
    wire finish_pe;
    wire bank_s_sel, bank_s_en;
    wire [7:0]hit1;
    wire [7:0]hit2;
    wire [7:0]hit3;
    wire [7:0]hit4;
    
    // Shared indicator signals for all PEs
    wire indicator, indicator1, indicator2, indicator3, indicator4, valid_pool, unvalid2;
    wire indicator_pe1, indicator1_pe1, indicator2_pe1, indicator3_pe1, indicator4_pe1, valid_pool_pe1, unvalid2_pe1;
    wire indicator_pe2, indicator1_pe2, indicator2_pe2, indicator3_pe2, indicator4_pe2, valid_pool_pe2, unvalid2_pe2;
    wire indicator_pe3, indicator1_pe3, indicator2_pe3, indicator3_pe3, indicator4_pe3, valid_pool_pe3, unvalid2_pe3;
    wire indicator_pe4, indicator1_pe4, indicator2_pe4, indicator3_pe4, indicator4_pe4, valid_pool_pe4, unvalid2_pe4;
    
    
    // Memory address signals for all PEs
    wire [9:0] addr_read_add, addr_read_pool, addr_read_conv, addr_read_src_A, addr_read_relu;
    
    // Cache memory interfaces
    wire [127:0] i_m_readdata_1, i_m_readdata_2, i_m_readdata_3, i_m_readdata_4;
    wire [127:0] o_m_writedata_1, o_m_writedata_2, o_m_writedata_3, o_m_writedata_4;
    wire [25:0] o_m_addr_1, o_m_addr_2, o_m_addr_3, o_m_addr_4;
    wire [3:0] o_m_byte_en_1, o_m_byte_en_2, o_m_byte_en_3, o_m_byte_en_4;
    wire o_m_read_1, o_m_write_1, o_m_read_2, o_m_write_2;
    wire o_m_read_3, o_m_write_3, o_m_read_4, o_m_write_4;
    wire old;
    // PE connections
    wire [31:0] src_A1, src_A2, src_A3, src_A4;
    wire [31:0] src_C1, src_C2, src_C3, src_C4;
    wire [31:0] PE1_Result, PE2_Result, PE3_Result, PE4_Result;
    wire [31:0] o_p_src_b_kernel;
    wire [3:0] overflow;
    wire [31:0]instruction1;
    wire [31:0]data_rs1;
    wire [31:0]instruction_out;
    wire[31:0]direct_out;
    // Address calculation
    wire [24:0] address_25_bit;
    wire [3:0] byte_enable_4_bits;
    wire [31:0]o_p_readdata_21;
    // Data flow signals
    wire [31:0] cache_bank1_data;
    wire [31:0] cache_bank2_data;
    wire [31:0] cache_bank3_data;
    wire [31:0] coe_cache_data;
    wire [31:0] bank3_s_to_cache;
    wire [31:0] bank4_s_to_cache;
    wire [31:0] mem_request_data;
    wire [31:0] p_data;
    wire [31:0] o_p_readdata, o_p_readdata_2, o_p_readdata_3, o_p_readdata_4;
    wire o_p_readdata_valid, o_p_readdata_valid_3, o_p_readdata_valid_4;
    wire [31:0] CNN_Result;
    wire [31:0] rs1_data, rs2_data;
    wire [8:0]index;
    wire [31:0]o_p_readdata_31;
    wire [7:0]N;
    // DECLARE as internal wires in top module
    wire local_rst_pe1, local_rst_pe2, local_rst_pe3, local_rst_pe4;
    wire local_rst_data_fetcher, local_rst_data_selector;
    wire local_reset,local_rst_all_conv, local_rst_all_pool, local_rst_all_relu, local_rst_all_add;
    wire local_rst_address_block; 
    wire local_rst_inst_mem, local_rst_data_mem, local_rst_decoder, local_rst_eai;
    wire[10:0]index_4_1,index_4_2,index_4_3,index_4_4;
    wire oo_p_readdata_valid;
    assign oo_p_readdata_valid=(direct)?1:(o_p_readdata_valid_4 | o_p_readdata_valid_3);
    assign o_p_readdata_3=(direct)?direct_out:o_p_readdata_31;
    assign direct_path=(direct)?cache_bank1_data:0;
    wire [31:0]data_out;
    wire finish12=((valid_pool&&addr_pool<(Np/P)*(Np/P))||finish_conv)?1'b1:0;
    wire finish23=1'b0;
    ram_out out(
          clk,
     reset,
    PE1_Result,
     finish12,
     finish23,
   data_out);

    instruction_memory inst_mem(
    .clk(clk),
     .rst(rst_n),
     .local_rst_inst_mem(local_rst_inst_mem),
     .instruction(instruction1)
);

data_mem dat_mem(
    .clk(clk),
    .rst(rst_n),
    .local_rst_data_mem(local_rst_data_mem),
    .instruction(instruction1),
    .data_out(data_rs1),
    .instruction_out(instruction_out)
    );
     
    // CNN Accelerator Controller
    // EAI controller
    EAI eai_ctrl(
        .clk(clk),
        .rst_n(rst_n),
        .local_rst_eai(local_rst_eai),
        .active(active),
        // Nice interface
        .nice_req_valid(nice_req_valid),
        .nice_req_ready(nice_req_ready),
        .nice_req_inst(instruction_out),
        .nice_req_rs1(data_rs1),
        .nice_req_rs2(32'd0),
        .nice_rsp_valid(nice_rsp_valid),
        .nice_rsp_ready(nice_rsp_ready),
        .nice_rsp_rdat(nice_rsp_rdat),
        // Memory interface
        .nice_icb_cmd_valid(nice_icb_cmd_valid),
        .nice_icb_cmd_ready(nice_icb_cmd_ready),
        .nice_icb_cmd_addr(nice_icb_cmd_addr),
        .nice_icb_cmd_read(nice_icb_cmd_read),
        .nice_icb_cmd_rdata(nice_icb_cmd_rdata),
        .nice_icb_rsp_valid(nice_icb_rsp_valid),
        .nice_icb_rsp_ready(nice_icb_rsp_ready),
        .nice_icb_rsp_Wdata(nice_icb_rsp_Wdata),
        // Control signals
        .data_addr(DATA_ADDRESS),
        .req_data(REQ_DATA),
        .wr(WR_FLAG),
        .rd(RD_FLAG),
        .CNN_Result(CNN_Result),
        .finish((direct)?finish_op:1'd1),
        // Decoder interface
        .instr(instruction),
        .rs1(rs1_data),
        .rs2(rs2_data),
        .decoder_valid(decoder_valid),
        .decoder_ready(decoder_ready),
        .mem_request_valid(mem_request_valid),
        .p_data(p_data),
        .unfinished_data(mem_request_data)
    );
    
    // Instruction decoder
    decoder instr_decoder(
        .clk(clk),
        .rst_n(rst_n),
        .local_rst_decoder(local_rst_decoder),
        .ready(decoder_valid),
        .instruction(instruction),
        .finish(decoder_ready),
        .cfg_ready(cfg_ready),
        .cfg_valid(cfg_valid),
        .funct7(funct7),
        .rs1(rs1_addr),
        .rs2(rs2_addr),
        .rd(rd_addr),
        .xs1(xs1),
        .xs2(xs2),
        .xd(xd),
        .index(index)
    );
   
    cnn_accelerator_controller controller(
        .clk(clk),
        .rst_n(rst_n),
        // Controller to PE interface
        .crossbar_sel(crossbar_sel),
        .pe_mode(pe_mode),
        .Conv_en(Conv_en),
        .adder_en(adder_en),
        .pool_en(pool_en),
        .relu_en(relu_en),
        .F(F),
        .Np(Np),
        .P(P),
        // Crossbar configuration
        .sel_Conv(sel_Conv),
        .sel_Add(sel_Add),
        .sel_Relu(sel_Relu),
        .sel_Pool(sel_Pool),
        .sel_Res(sel_Res),
        // Memory addressing and control
        .addr_conv(addr_conv),
        .addr_add(addr_add),
        .addr_relu(addr_relu),
        .addr_pool(addr_pool),
        .addr_src_A(addr_src_A),
        .conv_read_en(conv_read_en),
        .conv_write_en(conv_write_en),
        .pool_read_en(pool_read_en),
        .pool_write_en(pool_write_en),
        .add_read_en(add_read_en),
        .add_write_en(add_write_en),
        .relu_read_en(relu_read_en),
        .relu_write_en(relu_write_en),
        .srcA_read_en(srcA_read_en),
        .srcA_write_en(srcA_write_en),
        // PE completion signals
        .finish_conv(finish_conv),
        .finish_pool(finish_pool),
        .finish_relu(finish_relu),
        .finish_adder(finish_adder),
        // Data routing control
        .PEID(PEID),
        .src_A_en(src_A_en),
        .src_C_en(src_C_en),
        .send_en(send_en),
        // Instruction interface
        .funct7(funct7),
        .rs1(rs1_addr),
        .rs2(rs2_addr),
        .rd(rd_addr),
        .cfg_valid(cfg_valid),
        .cfg_ready(cfg_ready),
        // Cache interface signals
        .o_p_waitrequest_1(o_p_waitrequest_1),
        .i_p_read_1(i_p_read_1),
        .i_p_write_1(i_p_write_1),
        .i_m_readdata_valid_1(i_m_readdata_valid_1),
        .i_m_waitrequest_1(i_m_waitrequest_1),
        
        .o_p_waitrequest_2(o_p_waitrequest_2),
        .i_p_read_2(i_p_read_2),
        .i_p_write_2(i_p_write_2),
        .i_m_readdata_valid_2(i_m_readdata_valid_2),
        .i_m_waitrequest_2(i_m_waitrequest_2),
        
        .o_p_waitrequest_3(o_p_waitrequest_3),
        .i_p_read_3(i_p_read_3),
        .i_p_write_3(i_p_write_3),
        .i_m_readdata_valid_3(i_m_readdata_valid_3),
        .i_m_waitrequest_3(i_m_waitrequest_3),
        
        .o_p_waitrequest_4(o_p_waitrequest_4),
        .i_p_read_4(i_p_read_4),
        .i_p_write_4(i_p_write_4),
        .i_m_readdata_valid_4(i_m_readdata_valid_4),
        .i_m_waitrequest_4(i_m_waitrequest_4),
        
        // Address block interface
        .to_address_block_rs1(to_address_block_rs1),
        .to_address_block_rs2(to_address_block_rs2),
        .address_block_en(address_block_en),
        .addr_wr(addr_wr),
        
        // Data fetcher interface
        .fun_for_data_fetcher(fun_for_data_fetcher),
        .xs1_out(xs1_out),
        .xs2_out(xs2_out),
        
        // EAI controller interface
        .RD_FLAG(RD_FLAG),
        .WR_FLAG(WR_FLAG),
        .REQ_DATA(REQ_DATA),
        .DATA_ADDRESS(DATA_ADDRESS),
        .N(N),
        // Status signals
        .finish_pe(finish_pe),
        .finish_operation(), // should be empty
        .bank_s_sel(bank_s_sel),
        .bank_s_en(bank_s_en),
        .hit1(hit1),
        .hit2(hit2),
        .hit3(hit3),
        .hit4(hit4),
        .index(index),
        .indicator(indicator),
        .indicator1(indicator1),
        .indicator2(indicator2),
        .valid_pool(valid_pool),
        .indicator3(indicator3),
        .indicator4(indicator4),
        .addr_read_conv(addr_read_conv),
        .addr_read_add(addr_read_add),
        .addr_read_relu(addr_read_relu),
        .addr_read_pool(addr_read_pool),
        .addr_read_src_A(addr_read_src_A),
        .unvalid2(unvalid2),
        // Connect local reset outputs
        .local_rst_pe1(local_rst_pe1),
        .local_rst_pe2(local_rst_pe2),
        .local_rst_pe3(local_rst_pe3),
        .local_rst_pe4(local_rst_pe4),
        .local_rst_data_fetcher(local_rst_data_fetcher),
        .local_rst_data_selector(local_rst_data_selector),
        .local_rst_address_block(local_rst_address_block),
        .local_rst_all_conv(local_rst_all_conv),
        .local_rst_all_pool(local_rst_all_pool),
        .local_rst_all_relu(local_rst_all_relu),
        .local_rst_all_add(local_rst_all_add),
        .local_rst_inst_mem(local_rst_inst_mem),
        .local_rst_data_mem(local_rst_data_mem),
        .local_rst_decoder(local_rst_decoder), 
        .local_rst_eai(local_rst_eai),
        .index_4(index_4),
        .direct(direct),
        .old(old)
    );
    
    // Address block
    address addr_block(
        .wr(addr_wr),
        .clk(clk),
        .rst_n(rst_n),
        .local_rst_address_block(local_rst_address_block),
        .valid(address_block_en),
        .rs1(to_address_block_rs1),
        .rs2(to_address_block_rs2),
        .cache_address_i(address_25_bit),
        .byte_en(byte_enable_4_bits)
    );
    
    cache coe(
        .clk(clk),
        .rst(rst_n),
        .i_p_addr(address_25_bit),
        .i_p_byte_en(byte_enable_4_bits),
        .i_p_writedata(coe_cache_data),
        .i_p_read(i_p_read_1),
        .i_p_write(i_p_write_1),
        .o_p_readdata(o_p_src_b_kernel),
        .o_p_readdata_valid(o_p_readdata_valid),
        .o_p_waitrequest(o_p_waitrequest_1),
        .hit(hit1),
        .o_m_addr(o_m_addr_1),
        .o_m_byte_en(o_m_byte_en_1),
        .o_m_writedata(o_m_writedata_1),
        .o_m_read(o_m_read_1),
        .o_m_write(o_m_write_1),
        .i_m_readdata(i_m_readdata_1),
        .i_m_readdata_valid(i_m_readdata_valid_1),
        .i_m_waitrequest(i_m_waitrequest_1)
    );
    
    cache cache2(
        .clk(clk),
        .rst(rst_n),
        .i_p_addr(address_25_bit),
        .i_p_byte_en(byte_enable_4_bits),
        .i_p_writedata(cache_bank1_data),
        .i_p_read(i_p_read_2),
        .i_p_write(i_p_write_2),
        .o_p_readdata(o_p_readdata_2),
        .o_p_readdata_valid(o_p_readdata_valid),
        .o_p_waitrequest(o_p_waitrequest_2),
        .hit(hit2),
        .o_m_addr(o_m_addr_2),
        .o_m_byte_en(o_m_byte_en_2),
        .o_m_writedata(o_m_writedata_2),
        .o_m_read(o_m_read_2),
        .o_m_write(o_m_write_2),
        .i_m_readdata(128'd0),
        .i_m_readdata_valid(i_m_readdata_valid_2),
        .i_m_waitrequest(i_m_waitrequest_2)
    );
    
    cache cache3(
        .clk(clk),
        .rst(rst_n),
        .i_p_addr(address_25_bit),
        .i_p_byte_en(byte_enable_4_bits),
        .i_p_writedata(bank3_s_to_cache),
        .i_p_read(i_p_read_3),
        .i_p_write(i_p_write_3),
        .o_p_readdata(o_p_readdata_31),
        .o_p_readdata_valid(o_p_readdata_valid_3),
        .o_p_waitrequest(o_p_waitrequest_3),
        .hit(hit3),
        .o_m_addr(o_m_addr_3),
        .o_m_byte_en(o_m_byte_en_3),
        .o_m_writedata(o_m_writedata_3),
        .o_m_read(o_m_read_3),
        .o_m_write(o_m_write_3),
        .i_m_readdata(i_m_readdata_3),
        .i_m_readdata_valid(i_m_readdata_valid_3),
        .i_m_waitrequest(i_m_waitrequest_3)
    );
    
    cache cache4(
        .clk(clk),
        .rst(rst_n),
        .i_p_addr(address_25_bit),
        .i_p_byte_en(byte_enable_4_bits),
        .i_p_read(i_p_read_4),
        .i_p_write(i_p_write_4),
        .i_p_writedata(cache_bank1_data),
        .o_p_readdata(o_p_readdata_4),
        .o_p_readdata_valid(o_p_readdata_valid_4),
        .o_p_waitrequest(o_p_waitrequest_4),
        .hit(hit4),
        .o_m_addr(o_m_addr_4),
        .o_m_byte_en(o_m_byte_en_4),
        .o_m_writedata(o_m_writedata_4),
        .o_m_read(o_m_read_4),
        .o_m_write(o_m_write_4),
        .i_m_readdata(i_m_readdata_4),
        .i_m_readdata_valid(i_m_readdata_valid_4),
        .i_m_waitrequest(i_m_waitrequest_4)
    );
// Data fetcher
    data_fetcher fetcher(
        .clk(clk),
        .rst_n(rst_n),
        .local_rst_data_fetcher(local_rst_data_fetcher),
        .finish(finish_operation),
        .instruction(fun_for_data_fetcher),
        .Xs1(xs1_out),
        .Xs2(xs2_out),
        .nice_icb_cmd_ready(nice_icb_cmd_ready),
        .nice_rsp_valid(nice_rsp_valid),
        .mem_response_valid(nice_req_ready),
        .data_response_1(rs1_data),
        .data_response_2(rs2_data),
        .mem_request_valid(mem_request_valid),
        .mem_request_data(mem_request_data),
        .cache_bank1_data(cache_bank1_data),
        .cache_bank2_data(cache_bank2_data),
        .cache_bank3_data(cache_bank3_data),
        .CNN_Result_to_EAI_Conroller(CNN_Result),
        .o_p_readdata_valid(oo_p_readdata_valid),
        .cache_bank2_output(o_p_readdata_3),
        .cache_bank3_output(o_p_readdata_4),
        .p_data(nice_icb_rsp_Wdata),
        .coe_cache_data(coe_cache_data)
        
    );   
    assign o_p_readdata_21=(old)?o_p_readdata_31:o_p_readdata_2;
// Data Selector/Router
    DataSelector data_sel(
        .clk(clk),
        .rst(rst_n),
        .local_rst_data_selector(local_rst_data_selector),
        .cache1_data(o_p_readdata_21),
        .cache2_data(o_p_readdata_4),
        .src_A_en(src_A_en),
        .src_C_en(src_C_en),
        .send_en(send_en),
        .PE1_sel(PEID),
        .bank_s_sel(bank_s_sel),
        .bank_s_en(bank_s_en),
        .store_result1(PEID),
        .PE1_result(PE1_Result),
        .PE2_result(PE2_Result),
        .PE3_result(PE3_Result),
        .PE4_result(PE4_Result),
        .src_A1(src_A1),
        .src_A2(src_A2),
        .src_A3(src_A3),
        .src_A4(src_A4),
        .src_C1(src_C1),
        .src_C2(src_C2),
        .src_C3(src_C3),
        .src_C4(src_C4),
        .bank3_s(bank3_s_to_cache),
        .bank4_s(bank4_s_to_cache),
        .direct(direct),
        .direct_path(direct_path),
        .direct_out(direct_out)
    );
    
    // PE instances
    PE pe1(
        .clk(clk),
        .reset(~rst_n),
        .local_reset(local_rst_pe1),
        .srcA(src_A1),
        .srcB(o_p_src_b_kernel),
        .srcC(src_C1),
        .Conv_en(Conv_en & (PEID == 2'b00)),
        .adder_en(adder_en & (PEID == 2'b00)),
        .pool_en(pool_en & (PEID == 2'b00)),
        .relu_en(relu_en & (PEID == 2'b00)),
        .F(F),
        .sel_Conv(sel_Conv),
        .sel_Add(sel_Add),
        .sel_Relu(sel_Relu),
        .sel_Pool(sel_Pool),
        .sel_Res(sel_Res),
        .addr_conv(addr_conv),
        .addr_add(addr_add),
        .addr_relu(addr_relu),
        .addr_pool(addr_pool),
        .addr_src_A(addr_src_A),
        .conv_read_en(conv_read_en & (PEID == 2'b00)),
        .conv_write_en(conv_write_en & (PEID == 2'b00)),
        .pool_read_en(pool_read_en & (PEID == 2'b00)),
        .pool_write_en(pool_write_en & (PEID == 2'b00)),
        .add_read_en(add_read_en & (PEID == 2'b00)),
        .add_write_en(add_write_en & (PEID == 2'b00)),
        .relu_read_en(relu_read_en & (PEID == 2'b00)),
        .relu_write_en(relu_write_en & (PEID == 2'b00)),
        .srcA_read_en(srcA_read_en & (PEID == 2'b00)),
        .srcA_write_en(srcA_write_en & (PEID == 2'b00)),
        .Np(Np),
        .P(P),
        .Result(PE1_Result),
        .overflow(overflow[0]),
        .finish_conv(finish_conv[0]),
        .finish_pool(finish_pool[0]),
        .finish_relu(finish_relu[0]),
        .finish_adder(finish_adder[0]),
        .indicator(indicator_pe1),
        .indicator1(indicator1_pe1),
        .indicator2(indicator2_pe1),
        .indicator3(indicator3_pe1),
        .indicator4(indicator4_pe1),
        .valid_pool(valid_pool_pe1),
        .addr_read_conv((PEID == 2'b00)?addr_read_conv:10'd0),
        .addr_read_add(  (PEID == 2'b00)?addr_read_add:10'd0),
        .addr_read_relu( (PEID == 2'b00)?addr_read_relu:10'd0),
        .addr_read_pool( (PEID == 2'b00)?addr_read_pool:10'd0),
        .addr_read_src_A( (PEID == 2'b00)?addr_read_src_A:10'd0),
        .unvalid2(unvalid2_pe1),
        .local_rst_all_conv(local_rst_all_conv),
        .local_rst_all_pool(local_rst_all_pool),
        .local_rst_all_relu(local_rst_all_relu),
        .local_rst_all_add(local_rst_all_add),
        .index_4(index_4_1),
        .N(N)
    );
    
    PE pe2(
        .clk(clk),
        .reset(~rst_n),
        .local_reset(local_rst_pe2),
        .srcA(src_A2),
        .srcB(o_p_src_b_kernel),
        .srcC(src_C2),
        .Conv_en(Conv_en & (PEID == 2'b01)),
        .adder_en(adder_en & (PEID == 2'b01)),
        .pool_en(pool_en & (PEID == 2'b01)),
        .relu_en(relu_en & (PEID == 2'b01)),
        .F(F),
        .sel_Conv(sel_Conv),
        .sel_Add(sel_Add),
        .sel_Relu(sel_Relu),
        .sel_Pool(sel_Pool),
        .sel_Res(sel_Res),
        .addr_conv(addr_conv),
        .addr_add(addr_add),
        .addr_relu(addr_relu),
        .addr_pool(addr_pool),
        .addr_src_A(addr_src_A),
        .conv_read_en(conv_read_en & (PEID == 2'b01)),
        .conv_write_en(conv_write_en & (PEID == 2'b01)),
        .pool_read_en(pool_read_en & (PEID == 2'b01)),
        .pool_write_en(pool_write_en & (PEID == 2'b01)),
        .add_read_en(add_read_en & (PEID == 2'b01)),
        .add_write_en(add_write_en & (PEID == 2'b01)),
        .relu_read_en(relu_read_en & (PEID == 2'b01)),
        .relu_write_en(relu_write_en & (PEID == 2'b01)),
        .srcA_read_en(srcA_read_en & (PEID == 2'b01)),
        .srcA_write_en(srcA_write_en & (PEID == 2'b01)),
        .Np(Np),
        .P(P),
        .Result(PE2_Result),
        .overflow(overflow[1]),
        .finish_conv(finish_conv[1]),
        .finish_pool(finish_pool[1]),
        .finish_relu(finish_relu[1]),
        .finish_adder(finish_adder[1]),
        .indicator(indicator_pe2),
        .indicator1(indicator1_pe2),
        .indicator2(indicator2_pe2),
        .indicator3(indicator3_pe2),
        .indicator4(indicator4_pe2),
        .valid_pool(valid_pool_pe2),
        .addr_read_conv((PEID == 2'b01)?addr_read_conv:10'd0),
        .addr_read_add(  (PEID == 2'b01)?addr_read_add:10'd0),
        .addr_read_relu( (PEID == 2'b01)?addr_read_relu:10'd0),
        .addr_read_pool( (PEID == 2'b01)?addr_read_pool:10'd0),
        .addr_read_src_A( (PEID == 2'b01)?addr_read_src_A:10'd0),
        .unvalid2(unvalid2_pe2),
        .local_rst_all_conv(local_rst_all_conv),
        .local_rst_all_pool(local_rst_all_pool),
        .local_rst_all_relu(local_rst_all_relu),
        .local_rst_all_add(local_rst_all_add),
        .index_4(index_4_2),
        .N(N)
    );
    
    PE pe3(
        .clk(clk),
        .reset(~rst_n),
        .local_reset(local_rst_pe3),
        .srcA(src_A3),
        .srcB(o_p_src_b_kernel),
        .srcC(src_C3),
        .Conv_en(Conv_en & (PEID == 2'b10)),
        .adder_en(adder_en & (PEID == 2'b10)),
        .pool_en(pool_en & (PEID == 2'b10)),
        .relu_en(relu_en & (PEID == 2'b10)),
        .F(F),
        .sel_Conv(sel_Conv),
        .sel_Add(sel_Add),
        .sel_Relu(sel_Relu),
        .sel_Pool(sel_Pool),
        .sel_Res(sel_Res),
        .addr_conv(addr_conv),
        .addr_add(addr_add),
        .addr_relu(addr_relu),
        .addr_pool(addr_pool),
        .addr_src_A(addr_src_A),
        .conv_read_en(conv_read_en & (PEID == 2'b10)),
        .conv_write_en(conv_write_en & (PEID == 2'b10)),
        .pool_read_en(pool_read_en & (PEID == 2'b10)),
        .pool_write_en(pool_write_en & (PEID == 2'b10)),
        .add_read_en(add_read_en & (PEID == 2'b10)),
        .add_write_en(add_write_en & (PEID == 2'b10)),
        .relu_read_en(relu_read_en & (PEID == 2'b10)),
        .relu_write_en(relu_write_en & (PEID == 2'b10)),
        .srcA_read_en(srcA_read_en & (PEID == 2'b10)),
        .srcA_write_en(srcA_write_en & (PEID == 2'b10)),
        .Np(Np),
        .P(P),
        .Result(PE3_Result),
        .overflow(overflow[2]),
        .finish_conv(finish_conv[2]),
        .finish_pool(finish_pool[2]),
        .finish_relu(finish_relu[2]),
        .finish_adder(finish_adder[2]),
        .indicator(indicator_pe3),
        .indicator1(indicator1_pe3),
        .indicator2(indicator2_pe3),
        .indicator3(indicator3_pe3),
        .indicator4(indicator4_pe3),
        .valid_pool(valid_pool_pe3),
       .addr_read_conv((PEID == 2'b10)?addr_read_conv:10'd0),
        .addr_read_add(  (PEID == 2'b10)?addr_read_add:10'd0),
        .addr_read_relu( (PEID == 2'b10)?addr_read_relu:10'd0),
        .addr_read_pool( (PEID == 2'b10)?addr_read_pool:10'd0),
        .addr_read_src_A( (PEID == 2'b10)?addr_read_src_A:10'd0),
        .unvalid2(unvalid2_pe3),
        .local_rst_all_conv(local_rst_all_conv),
        .local_rst_all_pool(local_rst_all_pool),
        .local_rst_all_relu(local_rst_all_relu),
        .local_rst_all_add(local_rst_all_add),
        .index_4(index_4_3),
        .N(N)
    );
    
    PE pe4(
        .clk(clk),
        .reset(~rst_n),
        .local_reset(local_rst_pe4),
        .srcA(src_A4),
        .srcB(o_p_src_b_kernel),
        .srcC(src_C4),
        .Conv_en(Conv_en & (PEID == 2'b11)),
        .adder_en(adder_en & (PEID == 2'b11)),
        .pool_en(pool_en & (PEID == 2'b11)),
        .relu_en(relu_en & (PEID == 2'b11)),
        .F(F),
        .sel_Conv(sel_Conv),
        .sel_Add(sel_Add),
        .sel_Relu(sel_Relu),
        .sel_Pool(sel_Pool),
        .sel_Res(sel_Res),
        .addr_conv(addr_conv),
        .addr_add(addr_add),
        .addr_relu(addr_relu),
        .addr_pool(addr_pool),
        .addr_src_A(addr_src_A),
        .conv_read_en(conv_read_en & (PEID == 2'b11)),
        .conv_write_en(conv_write_en & (PEID == 2'b11)),
        .pool_read_en(pool_read_en & (PEID == 2'b11)),
        .pool_write_en(pool_write_en & (PEID == 2'b11)),
        .add_read_en(add_read_en & (PEID == 2'b11)),
        .add_write_en(add_write_en & (PEID == 2'b11)),
        .relu_read_en(relu_read_en & (PEID == 2'b11)),
        .relu_write_en(relu_write_en & (PEID == 2'b11)),
        .srcA_read_en(srcA_read_en & (PEID == 2'b11)),
        .srcA_write_en(srcA_write_en & (PEID == 2'b11)),
        .Np(Np),
        .P(P),
        .Result(PE4_Result),
        .overflow(overflow[3]),
        .finish_conv(finish_conv[3]),
        .finish_pool(finish_pool[3]),
        .finish_relu(finish_relu[3]),
        .finish_adder(finish_adder[3]),
        .indicator(indicator_pe4),
        .indicator1(indicator1_pe4),
        .indicator2(indicator2_pe4),
        .indicator3(indicator3_pe4),
        .indicator4(indicator4_pe4),
        .valid_pool(valid_pool_pe4),
        .addr_read_conv((PEID == 2'b11)?addr_read_conv:10'd0),
        .addr_read_add(  (PEID == 2'b11)?addr_read_add:10'd0),
        .addr_read_relu( (PEID == 2'b11)?addr_read_relu:10'd0),
        .addr_read_pool( (PEID == 2'b11)?addr_read_pool:10'd0),
        .addr_read_src_A( (PEID == 2'b11)?addr_read_src_A:10'd0),
        .unvalid2(unvalid2_pe4),
        .local_rst_all_conv(local_rst_all_conv),
        .local_rst_all_pool(local_rst_all_pool),
        .local_rst_all_relu(local_rst_all_relu),
        .local_rst_all_add(local_rst_all_add) ,
        .index_4(index_4_4),
        .N(N)
    );
    
    // Finish PE combined signal
    assign finish_pe = finish_conv[PEID] & finish_pool[PEID] & finish_relu[PEID] & finish_adder[PEID];

    assign indicator = (PEID == 2'b00) ? indicator_pe1 :
                       (PEID == 2'b01) ? indicator_pe2 :
                       (PEID == 2'b10) ? indicator_pe3 : indicator_pe4;

    assign indicator1 = (PEID == 2'b00) ? indicator1_pe1 :
                        (PEID == 2'b01) ? indicator1_pe2 :
                        (PEID == 2'b10) ? indicator1_pe3 : indicator1_pe4;

    assign indicator2 = (PEID == 2'b00) ? indicator2_pe1 :
                        (PEID == 2'b01) ? indicator2_pe2 :
                        (PEID == 2'b10) ? indicator2_pe3 : indicator2_pe4;

    assign indicator3 = (PEID == 2'b00) ? indicator3_pe1 :
                        (PEID == 2'b01) ? indicator3_pe2 :
                        (PEID == 2'b10) ? indicator3_pe3 : indicator3_pe4;

    assign indicator4 = (PEID == 2'b00) ? indicator4_pe1 :
                        (PEID == 2'b01) ? indicator4_pe2 :
                        (PEID == 2'b10) ? indicator4_pe3 : indicator4_pe4;

    assign valid_pool = (PEID == 2'b00) ? valid_pool_pe1 :
                        (PEID == 2'b01) ? valid_pool_pe2 :
                        (PEID == 2'b10) ? valid_pool_pe3 : valid_pool_pe4;

    assign unvalid2   = (PEID == 2'b00) ? unvalid2_pe1 :
                        (PEID == 2'b01) ? unvalid2_pe2 :
                        (PEID == 2'b10) ? unvalid2_pe3 : unvalid2_pe4;

  assign index_4   = (PEID == 2'b00) ? index_4_1 :
                        (PEID == 2'b01) ? index_4_2:
                        (PEID == 2'b10) ? index_4_3 : index_4_4;
endmodule