module cnn_top_testbench();

    // Test signals
    reg clk;
    reg rst_n;
    
    // EAI interface
    reg nice_req_valid;
    reg [31:0] nice_req_inst;
    reg [31:0] nice_req_rs1;
    reg [31:0] nice_req_rs2;
    wire nice_req_ready;
    wire nice_rsp_valid;
    reg nice_rsp_ready;
    wire [31:0] nice_rsp_rdat;
    
    // Memory interface
    wire nice_icb_cmd_valid;
    reg nice_icb_cmd_ready;
    wire [31:0] nice_icb_cmd_addr;
    wire nice_icb_cmd_read;
    wire [31:0] nice_icb_cmd_rdata;
    reg nice_icb_rsp_valid;
    wire nice_icb_rsp_ready;
    reg [31:0] nice_icb_rsp_Wdata;

    // Instantiate the CNN top module
    cnn_top_module dut(
        .clk(clk),
        .rst_n(rst_n),
        
        // EAI interface
        .nice_req_valid(nice_req_valid),
        .nice_req_inst(nice_req_inst),
        .nice_req_rs1(nice_req_rs1),
        .nice_req_rs2(nice_req_rs2),
        .nice_req_ready(nice_req_ready),
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
        .nice_icb_rsp_Wdata(nice_icb_rsp_Wdata)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Instruction encoding constants
    localparam MAH_REST        = 7'b0000001;  // Reset accelerator
    localparam MAH_LOAD_CACHE  = 7'b0000010;  // Load kernel coefficients
    localparam MAH_LOAD_IMG    = 7'b0000011;  // Load image to cache
    localparam MAH_CFG_LDL     = 7'b0000100;  // Load data from cache to PE
    localparam MAH_CFG_SDL_CNN = 7'b0000101;  // Store CNN result from PE to cache
    localparam MAH_CFG_SDL_EXT = 7'b0000110;  // Store result to external memory
    localparam MAH_CFG_EXT_CAC = 7'b0000111;  // Store external data to cache
    localparam MAH_CFG_KE_COE  = 7'b0001000;  // Load kernel from COE to PE
    localparam MAH_CFG_CAC_EXT = 7'b0001001;  // Read old data from cache to external
    localparam MAH_CFG_OLD_PE  = 7'b0001010;  // Load old data from cache to PE
    localparam MAH_CFG_PE_CAC  = 7'b0001011;  // Store old data from PE to cache
    localparam MAH_WM          = 7'b0001100;  // Set working mode
    localparam MAH_SC          = 7'b0001101;  // Start calculation
    
    // Function to create instruction format
    function [31:0] encode_instruction;
        input [6:0] funct7;
        input [4:0] rd;
        input [4:0] rs1;
        input [4:0] rs2;
        input xs1, xs2, xd;
        begin
            encode_instruction = {funct7, rs2, rs1, xd, xs1, xs2, 5'b00000, 7'b1111111};
        end
    endfunction
    
    // Test scenario
    initial begin
        // Initialize signals
        rst_n = 0;
        nice_req_valid = 0;
        nice_req_inst = 0;
        nice_req_rs1 = 0;
        nice_req_rs2 = 0;
        nice_rsp_ready = 1;
        nice_icb_cmd_ready = 1;
        nice_icb_rsp_valid = 0;
        nice_icb_rsp_Wdata = 0;
        
        // Reset sequence
        #20;
        rst_n = 1;
        #20;
        
        // Test Case 1: Reset the accelerator
        $display("Test Case 1: Reset accelerator");
        send_instruction(encode_instruction(MAH_REST, 5'b00000, 5'b00000, 5'b00000, 0, 0, 0));
        wait_cycles(10);
        
        // Test Case 2: Load kernel coefficients
        $display("Test Case 2: Load kernel coefficients");
        send_instruction(encode_instruction(MAH_LOAD_CACHE, 5'b00000, 5'b00001, 5'b00010, 1, 1, 0));
        nice_req_rs1 = 32'h10000000; // Coefficient source address
        nice_req_rs2 = 32'h00010020; // Length | Cache base address
        wait_cycles(5);
        
        // Simulate memory response with kernel data
        nice_icb_rsp_valid = 1;
        nice_icb_rsp_Wdata = 32'h01020304; // Example kernel data
        wait_cycles(1);
        nice_icb_rsp_valid = 0;
        wait_cycles(10);
        
        // Test Case 3: Load image to cache
        $display("Test Case 3: Load image to cache");
        send_instruction(encode_instruction(MAH_LOAD_IMG, 5'b00000, 5'b00011, 5'b00100, 1, 1, 0));
        nice_req_rs1 = 32'h20000000; // Image source address
        nice_req_rs2 = 32'h00100040; // Length | Cache base address
        wait_cycles(5);
        
        // Simulate memory response with image data
        nice_icb_rsp_valid = 1;
        nice_icb_rsp_Wdata = 32'h0A0B0C0D; // Example image data
        wait_cycles(1);
        nice_icb_rsp_valid = 0;
        wait_cycles(10);
        
        // Test Case 4: Configure data loading from cache to PE
        $display("Test Case 4: Configure data loading from cache to PE");
        send_instruction(encode_instruction(MAH_CFG_LDL, 5'b00000, 5'b00101, 5'b00110, 1, 1, 0));
        nice_req_rs1 = 32'h00000100; // Source data address
        nice_req_rs2 = 32'h00000001; // Location
        wait_cycles(15);
        
        // Test Case 5: Configure working mode
        $display("Test Case 5: Configure working mode");
        send_instruction(encode_instruction(MAH_WM, 5'b00001, 5'b00111, 5'b01000, 1, 1, 0));
        nice_req_rs1 = 32'h00000005; // Crossbar path - Conv->ReLU
        nice_req_rs2 = 32'h00000009; // Operation mode - Conv+ReLU
        wait_cycles(10);
        
        // Test Case 6: Start calculation
        $display("Test Case 6: Start calculation");
        send_instruction(encode_instruction(MAH_SC, 5'b00000, 5'b00000, 5'b00000, 0, 0, 0));
        wait_cycles(20);
        
        // Test Case 7: Store CNN result to cache
        $display("Test Case 7: Store CNN result to cache");
        send_instruction(encode_instruction(MAH_CFG_SDL_CNN, 5'b00000, 5'b01001, 5'b01010, 1, 1, 0));
        nice_req_rs1 = 32'h00000200; // Destination address
        nice_req_rs2 = 32'h00000002; // Location
        wait_cycles(15);
        
        // Test Case 8: Store result to external memory
        $display("Test Case 8: Store result to external memory");
        send_instruction(encode_instruction(MAH_CFG_SDL_EXT, 5'b00000, 5'b01011, 5'b01100, 1, 1, 0));
        nice_req_rs1 = 32'h30000000; // External memory address
        nice_req_rs2 = 32'h00000003; // Configuration
        wait_cycles(15);
        
        // Complete the test
        #100;
        $display("Testbench completed successfully");
        $finish;
    end
    
    // Task to send an instruction
    task send_instruction;
        input [31:0] inst;
        begin
            @(posedge clk);
            nice_req_valid = 1;
            nice_req_inst = inst;
            wait(nice_req_ready);
            @(posedge clk);
            nice_req_valid = 0;
        end
    endtask
    
    // Task to wait for specified number of clock cycles
    task wait_cycles;
        input integer n;
        begin
            repeat(n) @(posedge clk);
        end
    endtask
    
    // Monitor signals
    initial begin
        $monitor("Time=%0t: req_valid=%b, req_ready=%b, rsp_valid=%b, rsp_data=%h", 
                 $time, nice_req_valid, nice_req_ready, nice_rsp_valid, nice_rsp_rdat);
    end
    
    // Check for stability and errors
    always @(posedge clk) begin
        if (rst_n && $isunknown(nice_req_ready))
            $error("Error: nice_req_ready has unknown value at time %0t", $time);
            
        if (rst_n && nice_rsp_valid && $isunknown(nice_rsp_rdat))
            $error("Error: nice_rsp_rdat has unknown value at time %0t", $time);
    end

endmodule