/////////////////////////////////@CopyRights/////////////////////////////////////////////////
// Company: No sponsorship
// Team: Mohamed Gamal & Ahmed Reda & Abdallah Sabah & Abdallah sleem & Mohamed Ahmed & Ibrahim Hamdy & Beshoy Maher & Mostafa Osman
// Supervisior Dr: Sherif Fathy
// Team Leader: Mohamed Ahmed Ibrahim
// Technical Head : Mohamed Gamal & Ahmed Reda 
// Human Resource : Beshoy Magdy  
// Check Date: 19/2/2025 11:44:49 PM
// Design Name:CNN unit
// Module Name: Test bench of the top module
// Project Name: Graduation project
/////////////////////////////////@CopyRights/////////////////////////////////////////////////

module test_g();

    reg  clk;
    reg  rst_n;
    
    // External interface
    reg  nice_req_valid;
    wire  nice_req_ready;
    wire  nice_rsp_valid;
    reg  nice_rsp_ready;
    wire  [31:0] nice_rsp_rdat;
    
    // Memory interface
    wire  nice_icb_cmd_valid;
    reg  nice_icb_cmd_ready;
    wire  [31:0] nice_icb_cmd_addr;
    wire  nice_icb_cmd_read;
    wire  [31:0] nice_icb_cmd_rdata;
    reg  nice_icb_rsp_valid;
    wire  nice_icb_rsp_ready;
    reg  [31:0] nice_icb_rsp_Wdata;


    cnn_top_module dut(
      clk,
      rst_n,
    
    // External interface
      nice_req_valid,
      nice_req_ready,
      nice_rsp_valid,
      nice_rsp_ready,
      nice_rsp_rdat,
    
    // Memory interface
      nice_icb_cmd_valid,
      nice_icb_cmd_ready,
       nice_icb_cmd_addr,
      nice_icb_cmd_read,
       nice_icb_cmd_rdata,
      nice_icb_rsp_valid,
      nice_icb_rsp_ready,
       nice_icb_rsp_Wdata
);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //  localparam STORE_COEFFICIENTS = 3'b000;
    //  localparam STORE_INPUT_IMAGE  = 3'b001;
    // localparam WRITE_BACK_OLD_DATA = 3'b010;
    // localparam STORE_OLD_DATA  = 3'b011;
    // localparam WRITE_BACK_RESULT_OF_CNN = 3'b100;

    initial begin
    // Initialize new signals (inputs=reg, we modify only the inputs and see (observe) the s)
    
   
////////////////////////////////////////////////////////////////////////////////////////////
    rst_n = 0;
    @(negedge clk);
    rst_n = 1;
    nice_req_valid = 1;
    nice_rsp_ready=1;
    nice_icb_cmd_ready=1;
    repeat (25227) @(negedge clk);
//     //ke <-> cache
//     nice_req_rs1 = 32'd10000;
//     nice_req_inst = 32'b0000010_11011_00100_0_1_1_00000_1111111; //ok
    
//    repeat (25) @(negedge clk);
//    //img <-> cache
//     nice_req_inst = 32'b0000011_11011_00101_0_1_1_00000_1111111;//ok
//     nice_req_rs1 = 32'd12;
//    repeat (25) @(negedge clk);
//    //img <-> cache <-> pe
//     nice_req_inst = 32'b0000100_11011_00101_0_1_1_00000_1111111;//ok
//     nice_req_rs1 = 32'd17;
//    repeat (25) @(negedge clk);
 
// //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//     //cnn <-> result <-> pe <-> cache2
//     nice_req_inst = 32'b0000101_11011_00101_0_1_1_00000_1111111;//ok
//     PE1_result = 32'd19;
//    repeat (25) @(negedge clk);
//     //cnn <-> result <-> external
//     nice_req_inst = 32'b0000110_11011_00101_0_1_1_00000_1111111;//ok
//     nice_req_rs1 = 32'd13;
//    repeat (25) @(negedge clk);
//     //old data from e203 to cache
//     nice_req_inst = 32'b0000111_11011_00101_0_1_1_00000_1111111;//ok
//     nice_req_rs1 = 32'd15;
//    repeat (25) @(negedge clk);
//    //ke <-> coe <-> pe
//     nice_req_inst = 32'b0001000_11011_00100_0_1_1_00000_1111111;//ok
//     nice_req_rs1 = 32'd14;
//    repeat (25) @(negedge clk);
//    //old data from cache to e203
//     nice_req_inst = 32'b0001001_11011_00101_0_1_1_00000_1111111;//ok
//     nice_req_rs1 = 32'd16;
//    repeat (25) @(negedge clk);
//    //old <-> cache <-> pe
//     nice_req_inst = 32'b0001010_11011_00101_0_1_1_00000_1111111;//ok
//     nice_req_rs1 = 32'd7;
//    repeat (25) @(negedge clk);
//    // old data <-> pe <-> cache
//     nice_req_inst = 32'b0001011_11111_11100_0_1_1_00000_1111111;//ok
//     PE1_result = 32'd25;

//    repeat (25) @(negedge clk);
    $stop;
    end

endmodule
