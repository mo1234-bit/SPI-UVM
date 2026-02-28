/////////////////////////////////@CopyRights/////////////////////////////////////////////////
// Company: No sponsorship
// Team: Mohamed Gamal & Ahmed Reda & Abdallah Sabah & Abdallah sleem & Mohamed Ahmed & Ibrahim Hamdy & Beshoy Maher & Mostafa Osman
// Supervisior Dr: Sherif Fathy
// Team Leader: Mohamed Ahmed
// Technical Head : Mohamed Gamal & Ahmed Reda
// Human Resource : Beshoy Magdy  
// Check Date: 19/2/2025 11:44:49 PM
// Design Name:CNN unit
// Module Name: Test bench of the top module
// Project Name: Graduation project
/////////////////////////////////@CopyRights/////////////////////////////////////////////////

module test2();
    reg clk;
    reg rst_n;
    wire active;
    reg nice_req_valid;
    reg [31:0] nice_req_inst;
    reg [31:0] nice_req_rs1;
    reg [31:0] nice_req_rs2;
    wire nice_req_ready;
    wire nice_rsp_valid;
    reg nice_rsp_ready;
    reg nice_icb_cmd_ready;
    wire [31:0] nice_rsp_rdat;
    wire [31:0] nice_icb_cmd_addr;
    wire nice_icb_cmd_read;
    wire [31:0] nice_icb_cmd_rdata;
    wire nice_icb_cmd_valid;
    wire nice_icb_rsp_ready;
    reg nice_icb_rsp_valid;
    reg [31:0] nice_icb_rsp_Wdata;

    // Cache and PE Inputs
    reg [127:0] i_m_readdata_1, i_m_readdata_2, i_m_readdata_3, i_m_readdata_4;
    reg [31:0] PE1_result, PE2_result, PE3_result, PE4_result;
    reg finish_pe;

    // Output Wires
    wire [31:0] src_A1, src_A2, src_A3, src_A4, src_C1, src_C2, src_C3, src_C4;
    wire [127:0] o_m_writedata_1, o_m_writedata_2, o_m_writedata_3, o_m_writedata_4;
    wire [4:0] crossbar_sel, pe_mode;
    wire [31:0] o_p_src_b_kernel;
    wire [25:0] o_m_addr_1_top, o_m_addr_2_top, o_m_addr_3_top, o_m_addr_4_top;
    wire [3:0] o_m_byte_en_1_top, o_m_byte_en_2_top, o_m_byte_en_3_top, o_m_byte_en_4_top;

    // Instantiate DUT
    top dut (
        .clk(clk),
        .rst_n(rst_n),
        .active(active),
        .nice_req_valid(nice_req_valid),
        .nice_req_inst(nice_req_inst),
        .nice_req_rs1(nice_req_rs1),
        .nice_req_rs2(nice_req_rs2),
        .nice_req_ready(nice_req_ready),
        .nice_rsp_valid(nice_rsp_valid),
        .nice_rsp_ready(nice_rsp_ready),
        .nice_rsp_rdat(nice_rsp_rdat),
        .nice_icb_cmd_valid(nice_icb_cmd_valid),
        .nice_icb_cmd_ready(nice_icb_cmd_ready),
        .nice_icb_cmd_addr(nice_icb_cmd_addr),
        .nice_icb_cmd_read(nice_icb_cmd_read),
        .nice_icb_cmd_rdata(nice_icb_cmd_rdata),
        .nice_icb_rsp_valid(nice_icb_rsp_valid),
        .nice_icb_rsp_ready(nice_icb_rsp_ready),
        .nice_icb_rsp_Wdata(nice_icb_rsp_Wdata),
        .i_m_readdata_1(i_m_readdata_1),
        .i_m_readdata_2(i_m_readdata_2),
        .i_m_readdata_3(i_m_readdata_3),
        .i_m_readdata_4(i_m_readdata_4),
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
        .o_m_writedata_1(o_m_writedata_1),
        .o_m_writedata_2(o_m_writedata_2),
        .o_m_writedata_3(o_m_writedata_3),
        .o_m_writedata_4(o_m_writedata_4),
        .finish_pe(finish_pe),
        .crossbar_sel(crossbar_sel),
        .pe_mode(pe_mode),
        .o_p_src_b_kernel(o_p_src_b_kernel),

        .o_m_addr_1_top(o_m_addr_1_top),
        .o_m_byte_en_1_top(o_m_byte_en_1_top),

        .o_m_addr_2_top(o_m_addr_2_top),
        .o_m_byte_en_2_top(o_m_byte_en_2_top),

        .o_m_addr_3_top(o_m_addr_3_top),
        .o_m_byte_en_3_top(o_m_byte_en_3_top),

        .o_m_addr_4_top(o_m_addr_4_top),
        .o_m_byte_en_4_top(o_m_byte_en_4_top)
        );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Main Test Sequence
    initial begin
        // Initialize
        rst_n = 0;
        nice_req_valid = 0;
        nice_req_inst = 0;
        nice_req_rs1 = 0;
        nice_req_rs2 = 0;
        nice_icb_cmd_ready = 1;
        nice_icb_rsp_valid = 0;
        nice_icb_rsp_Wdata = 0;
        i_m_readdata_1 = 128'h0;
        i_m_readdata_2 = 128'h0;
        i_m_readdata_3 = 128'h0;
        i_m_readdata_4 = 128'h0;
        PE1_result = 32'h0;
        PE2_result = 32'h0;
        PE3_result = 32'h0;
        PE4_result = 32'h0;
        finish_pe = 0;
            @(negedge clk);

        // Reset System
        rst_n = 1;

        // Test All Instructions Sequentially
        // 1. Mah.Rest (Reset Accelerator)
        send_instruction(32'b0000001_00000_00000_0_0_0_00000_1111111);
           repeat (25) @(negedge clk);

        // 2. Mah.load.ke.cache (Load Kernel to Cache 1)
        send_instruction(32'b0000010_00001_00010_0_0_0_00000_1111111);
           repeat (25) @(negedge clk);

        // 3. Mah.load.img.cache (Load Image to Cache 2)
        send_instruction(32'b0000011_00011_00100_0_0_0_00000_1111111);
           repeat (25) @(negedge clk);

        // 4. Mah.cfg.ldl.img.cache.pe (Load Image to PE)
        send_instruction(32'b0000100_00011_00100_0_0_0_00000_1111111);
           repeat (25) @(negedge clk);

        // 5. Mah.cfg.sdl.cnn.result.pe.cache2 (Store CNN Result to Cache 2)
        send_instruction(32'b0000101_00111_01000_0_0_0_00000_1111111);
           repeat (25) @(negedge clk);

        // 6. Mah.cfg.sdl.cnn.result.external (Store CNN Result to External)
        send_instruction(32'b0000110_00111_01000_0_0_0_00000_1111111);
           repeat (25) @(negedge clk);

        // 7. Mah.cfg.sdl.result.external.cache (Store Result to Cache 4)
        send_instruction(32'b0000111_01011_01100_0_0_0_00000_1111111);
           repeat (25) @(negedge clk);

        // 8. Mah.cfg.ldo.ke.coe.pe (Load Kernel to PE)
        send_instruction(32'b0001000_00001_00010_0_0_0_00000_1111111);
           repeat (25) @(negedge clk);

        // 9. Mah.cfg.sdl.old.cache.external (Store Old Data to External)
        send_instruction(32'b0001001_01111_10000_0_0_0_00000_1111111);
           repeat (25) @(negedge clk);

        // 10. Mah.cfg.ldo.old.cache.pe (Load Old Data to PE)
        send_instruction(32'b0001010_10001_10010_0_0_0_00000_1111111);
           repeat (25) @(negedge clk);

        // 11. Mah.cfg.sdl.old.pe.cache (Store Old Data to Cache 4)
        send_instruction(32'b0001011_10011_10100_0_0_0_00000_1111111);
           repeat (25) @(negedge clk);

        // 12. Mah.wm (Configure Crossbar and PE Mode)
        send_instruction(32'b0001100_10101_10110_0_0_0_00000_1111111);
           repeat (25) @(negedge clk);

        // 13. Mah.sc (Start Computation)
        send_instruction(32'b0001101_10111_11000_0_0_0_00000_1111111);
        // Simulate PE finish
        #50 finish_pe = 1;
        #10 finish_pe = 0;
           repeat (25) @(negedge clk);

        $stop;
    end

    // Task: Send Instruction
    task send_instruction(input [31:0] inst);
        begin
            @(negedge clk);
            nice_req_valid = 1;
            nice_req_inst = inst;
            nice_req_rs1 = 32'h1234; // Example data
            nice_req_rs2 = 32'h5678;
            @(negedge clk);
            //nice_req_valid = 0;
        end
    endtask


endmodule