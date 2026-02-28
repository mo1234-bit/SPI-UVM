module cnn_accelerator_controller (
    input wire clk,
    input wire rst_n,
    
    // Controller to PE interface
    output reg [4:0] crossbar_sel,
    output reg [4:0] pe_mode,
    output reg Conv_en,
    output reg adder_en,
    output reg pool_en,
    output reg relu_en,
    output reg [3:0] F,
    output reg [7:0] Np,
    output reg [2:0] P,
    
    // Crossbar configuration
    output reg [4:0] sel_Conv,
    output reg [4:0] sel_Add,
    output reg [4:0] sel_Relu,
    output reg [4:0] sel_Pool, 
    output reg [4:0] sel_Res,
    
    // Memory addressing and control
    output reg [9:0] addr_conv,
    output reg [9:0] addr_add,
    output reg [9:0] addr_relu,
    output reg [9:0] addr_pool,
    output reg [9:0] addr_src_A,
    output reg conv_read_en,
    output reg conv_write_en,
    output reg pool_read_en,
    output reg pool_write_en,
    output reg add_read_en,
    output reg add_write_en,
    output reg relu_read_en,
    output reg relu_write_en,
    output reg srcA_read_en,
    output reg srcA_write_en,
    
    // PE completion signals
    input wire [3:0] finish_conv,
    input wire [3:0] finish_pool,
    input wire [3:0] finish_relu,
    input wire [3:0] finish_adder,
    
    // Data routing control
    output reg [1:0] PEID,
    output reg src_A_en,
    output reg src_C_en,
    output reg send_en,
    
    // Instruction interface 
    input wire [6:0] funct7,
    input wire [4:0] rs1,
    input wire [4:0] rs2,
    input wire [4:0] rd,
    input wire cfg_valid,
    output reg cfg_ready,
    
    // Cache interface signals
    output reg i_p_read_1, i_p_write_1,
    input wire o_p_waitrequest_1,
    output reg i_m_readdata_valid_1,
    output reg i_m_waitrequest_1,
    
    output reg i_p_read_2, i_p_write_2,
    input wire o_p_waitrequest_2,
    output reg i_m_readdata_valid_2,
    output reg i_m_waitrequest_2,
    
    output reg i_p_read_3, i_p_write_3,
    input wire o_p_waitrequest_3,
    output reg i_m_readdata_valid_3,
    output reg i_m_waitrequest_3,
    
    output reg i_p_read_4, i_p_write_4,
    input wire o_p_waitrequest_4,
    output reg i_m_readdata_valid_4,
    output reg i_m_waitrequest_4,
    
    // Address block interface
    output reg [4:0] to_address_block_rs1,
    output reg [4:0] to_address_block_rs2,
    output reg address_block_en,
    output reg addr_wr,
    
    // Data fetcher interface
    output reg [2:0] fun_for_data_fetcher,
    output reg xs1_out,
    output reg xs2_out,
    
    // EAI controller interface
    output reg RD_FLAG,
    output reg WR_FLAG,
    output reg REQ_DATA,
    output reg [31:0] DATA_ADDRESS,
    
    // Status signals
    input wire finish_pe,
    output reg finish_operation,
    output reg bank_s_sel,
    output reg bank_s_en,
    input wire [7:0]hit1,
    input wire [7:0]hit2,
    input wire [7:0]hit3,
    input wire [7:0]hit4,
    input wire [8:0]index,
    input wire indicator,
    input wire indicator1,
    input wire indicator2,
    input wire valid_pool,
    input wire indicator3,
    input wire indicator4
);

    // FSM states
    localparam IDLE = 3'b000;
    localparam CONFIG = 3'b001;
    localparam EXECUTE = 3'b010;
    localparam WAIT_COMPLETION = 3'b011;
    localparam WRITE_BACK = 3'b100;
    wire [9:0]index1;
    reg [2:0] state, next_state;
    reg [4:0] counter;        // Counter for timing control
    reg [4:0] counter_2;      // Second counter for parallel timing
    reg inducation_signal;    // Signal for operation completion indication
    integer counter_3;
    integer counter_4;
    integer counter_5=0;
    integer counter_6=0;
    integer counter_7=0;
    integer counter_8=0;
    integer counter_9=0;
    integer counter_10=0;
    integer counter_11=0;
    integer counter_12=0;
    integer counter_13=0;
    integer counter_14=0;
    integer counter_15=0;
    integer counter_16=0;
    integer counter_17=0;
    integer counter_18=0;
    integer counter_19=0;
    integer counter_20=0;
    integer counter_21;
    integer counter_22;
    integer counter_23;
    integer counter_24;
    integer n;
    assign index1 =index+10'd256 ;
    // State machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            counter <= 0;
            counter_2 <= 0;
            inducation_signal <= 0;
            
            // Reset control signals
            crossbar_sel <= 5'b0;
            pe_mode <= 5'b0;
            Conv_en <= 1'b0;
            adder_en <= 1'b0;
            pool_en <= 1'b0;
            relu_en <= 1'b0;
            F <= 4'b0;
            Np <= 8'b0;
            P <= 3'b0;
            
            sel_Conv <= 5'b11111;
            sel_Add <= 5'b11111;
            sel_Relu <= 5'b11111;
            sel_Pool <= 5'b11111;
            sel_Res <= 5'b11111;
            
            addr_conv <= 7'b0;
            addr_add <= 7'b0;
            addr_relu <= 7'b0;
            addr_pool <= 7'b0;
            addr_src_A <= 7'b0;
            
            conv_read_en <= 1'b0;
            conv_write_en <= 1'b0;
            pool_read_en <= 1'b0;
            pool_write_en <= 1'b0;
            add_read_en <= 1'b0;
            add_write_en <= 1'b0;
            relu_read_en <= 1'b0;
            relu_write_en <= 1'b0;
            srcA_read_en <= 1'b0;
            srcA_write_en <= 1'b0;
            
            PEID <= 2'b0;
            src_A_en <= 1'b0;
            src_C_en <= 1'b0;
            send_en <= 1'b0;
            
            // Reset cache interface signals
            i_p_read_1 <= 0; i_p_write_1 <= 0;
            i_m_readdata_valid_1 <= 0; i_m_waitrequest_1 <= 1;
            
            i_p_read_2 <= 0; i_p_write_2 <= 0;
            i_m_readdata_valid_2 <= 0; i_m_waitrequest_2 <= 1;
            
            i_p_read_3 <= 0; i_p_write_3 <= 0;
            i_m_readdata_valid_3 <= 0; i_m_waitrequest_3 <= 1;
            
            i_p_read_4 <= 0; i_p_write_4 <= 0;
            i_m_readdata_valid_4 <= 0; i_m_waitrequest_4 <= 1;
            
            // Reset address block interface
            to_address_block_rs1 <= 0;
            to_address_block_rs2 <= 0;
            address_block_en <= 0;
            addr_wr <= 0;
            
            // Reset data fetcher interface
            fun_for_data_fetcher <= 0;
            xs1_out <= 0;
            xs2_out <= 0;
            counter_3<=0;
            counter_4<=0;
            counter_5<=0;
            // Reset EAI controller interface
            RD_FLAG <= 0;
            WR_FLAG <= 0;
            REQ_DATA <= 0;
            DATA_ADDRESS <= 0;
            
            bank_s_sel <= 0;
            bank_s_en <= 0;
            
            cfg_ready <= 1'b1;
            finish_operation <= 1'b0;

            // reset counters
                counter_3 <= 0;
                counter_4 <= 0;
                counter_5 <= 0;
                counter_6 <= 0;
                counter_7 <= 0;
                counter_8 <= 0;
                counter_9 <= 0;
                counter_10 <= 0;
                counter_11 <= 0;
                counter_12 <= 0;
                counter_13 <= 0;
                counter_14 <= 0;
                counter_15 <= 0;
                counter_16 <= 0;
                counter_17 <= 0;
                counter_18 <= 0;
                counter_19 <= 0;
                counter_20 <= 0;
                counter_21 <= 0;
                counter_22 <= 0;
                counter_23 <= 0;
                counter_24 <= 0;
        end else begin
            state <= next_state;
            
            case (state)
                IDLE: begin
                    // In IDLE state, reset operation flags
                    finish_operation <= 1'b0;
                    cfg_ready <= 1'b1;
                end
                
                CONFIG: begin
                    // Process the instruction based on funct7
                    casex (funct7)
                        7'b0000001: begin // Mah.rest - Reset accelerator
                            // All signals already reset at state transition, no need for additional resets
                        end
                        
                        7'b0000010: begin // Mah.load.ke.cache - Load kernel coefficients to cache
                            // Interface with address block
                            to_address_block_rs1 <= rs1;
                            to_address_block_rs2 <= rs2;
                            address_block_en <= 1'b1;
                            
                            // Interface with data fetcher
                            fun_for_data_fetcher <= 3'b001;  // STORE_COEFFICIENTS
                            xs1_out <= 1;
                            xs2_out <= 1;
                            
                            // Interface with EAI controller
                            DATA_ADDRESS <= {18'b0, rs1, rs2};
                            addr_wr <= 1;
                            
                            // Cache 1 interface settings
                            i_m_readdata_valid_1 <= 1;
                            i_m_waitrequest_1 <= 0;
                            
                            i_p_read_1 <= 0;
                            i_p_read_2 <= 0; 
                            i_p_write_2 <= 0;
                            i_m_readdata_valid_2 <= 0;
                            i_m_waitrequest_2 <= 1;
            
                               i_p_read_3 <= 0; 
                               i_p_write_3 <= 0;
                               i_m_readdata_valid_3 <= 0;
                               i_m_waitrequest_3 <= 1;
            
                              i_p_read_4 <= 0; 
                              i_p_write_4 <= 0;
                              i_m_readdata_valid_4 <= 0;
                              i_m_waitrequest_4 <= 1;
                            counter <= counter + 1;
                            
                            if (counter == 3) begin
                                i_p_write_1 <= 1;
                                counter <= 0;
                                cfg_ready <= 0;
                            end
                             if(|hit1)
                           i_p_write_1<=0;
                        end
                        
                        7'b0000011: begin // Mah.load.img.cache - Load image to cache
                            // Interface with address block
                            to_address_block_rs1 <= rs1;
                            to_address_block_rs2 <= rs2;
                            address_block_en <= 1'b1;
                            
                            // Interface with data fetcher
                            fun_for_data_fetcher <= 3'b111;  // STORE_INPUT_IMAGE
                            xs1_out <= 1;
                            xs2_out <= 1;
                            i_p_read_2 <= 0;
                            // Interface with EAI controller
                            DATA_ADDRESS <= {18'b0, rs1, rs2};
                            addr_wr <= 1;
                            // Cache 2 interface settings
                            i_m_readdata_valid_2 <= 1;
                            i_m_waitrequest_2 <= 0;
                            
                            i_p_read_1 <= 0;
                            i_p_write_1 <= 0;
                            i_m_readdata_valid_1 <= 0;
                            i_m_waitrequest_1 <= 1;
            
                            i_p_read_2 <= 0; 
            
                            i_p_read_3 <= 0; 
                            i_p_write_3 <= 0;
                            i_m_readdata_valid_3 <= 0; 
                            i_m_waitrequest_3 <= 1;
            
                            i_p_read_4 <= 0; 
                            i_p_write_4 <= 0;
                            i_m_readdata_valid_4 <= 0; 
                            i_m_waitrequest_4 <= 1;

                            counter <= counter + 1;
                            if (counter == 3) begin
                                i_p_write_2 <= 1;
                                counter <= 0;
                                cfg_ready <= 0;
                                end
                           if(|hit2)
                           i_p_write_2<=0;

                        end
                                              
                        7'b0000101: begin // Mah.cfg.sdl.cnn.result.pe.cache2 - Store CNN result from PE to cache
                            // Interface with address block
                            to_address_block_rs1 <= rs1;
                            to_address_block_rs2 <= rs2;
                            address_block_en <= 1'b1;
                            
                            // Interface with data fetcher
                            fun_for_data_fetcher <= 3'b100;  // WRITE_BACK_RESULT_OF_CNN
                            
                            // Interface with EAI controller
                            DATA_ADDRESS <= {18'b0, rs1, rs2};
                            
                            // For DATA_SELECTOR - select bank 3 (result storage)
                            bank_s_sel <= 1;  // Bank 3
                            bank_s_en <= 1;
                            PEID <= 2'b00;    // Source PE0
                            
                            i_p_read_1 <= 0;
                            i_p_write_1 <= 0;
                            i_m_readdata_valid_1 <= 0;
                            i_m_waitrequest_1 <= 1;
            
                            i_p_read_2 <= 0; 
                            i_p_write_2 <= 0;
                            i_m_readdata_valid_2 <= 0; 
                            i_m_waitrequest_2 <= 1;
            
                            i_p_read_3 <= 0; 
            
                            i_p_read_4 <= 0; 
                            i_p_write_4 <= 0;
                            i_m_readdata_valid_4 <= 0; 
                            i_m_waitrequest_4 <= 1;

                            counter_2 <= counter_2 + 1;
                            if (counter_2 == 5) begin
                                src_A_en <= 1;
                                send_en <= 1;
                                counter_2 <= 0;
                                cfg_ready <= 0;
                            end
                            i_p_read_3 <= 0;
                            // Write to Cache 3
                            counter <= counter + 1;
                            if (counter == 3) begin
                                i_p_write_3 <= 1;
                                i_m_readdata_valid_3 <= 1;
                                i_m_waitrequest_3 <= 0;
                                counter <= 0;
                            end
                            if(|hit3)
                           i_p_write_3<=0;
                        end
                        
                        7'b0000110: begin // Mah.cfg.sdl.cnn.result.external - Store result to external memory
                            // Interface with address block
                            to_address_block_rs1 <= rs1;
                            to_address_block_rs2 <= rs2;
                            address_block_en <= 1'b1;
                            
                            // Interface with data fetcher
                            fun_for_data_fetcher <= 3'b100;  // WRITE_BACK_RESULT_OF_CNN
                            xs1_out <= 1;
                            xs2_out <= 1;
                            
                            // Interface with EAI controller
                            DATA_ADDRESS <= {18'b0, rs1, rs2};
                            RD_FLAG <= 1;
                             i_p_write_3 <= 0;

                             i_p_read_1 <= 0;
                            i_p_write_1 <= 0;
                            i_m_readdata_valid_1 <= 0;
                            i_m_waitrequest_1 <= 1;
            
                            i_p_read_2 <= 0; 
                            i_p_write_2 <= 0;
                            i_m_readdata_valid_2 <= 0; 
                            i_m_waitrequest_2 <= 1;
            
                            
                            i_m_readdata_valid_3 <= 0; 
                            i_m_waitrequest_3 <= 1;
            
                            i_p_read_4 <= 0; 
                            i_p_write_4 <= 0;
                            i_m_readdata_valid_4 <= 0; 
                            i_m_waitrequest_4 <= 1;

                            // Cache 3 interface
                            counter <= counter + 1;
                            if (counter == 3) begin
                                i_p_read_3 <= 1;
                                counter <= 0;
                                cfg_ready <= 0;
                            end
                        end
                        
                        7'b0000111: begin // Mah.cfg.sdl.result.external.cache - Store external data to cache
                            // Interface with address block
                            to_address_block_rs1 <= rs1;
                            to_address_block_rs2 <= rs2;
                            address_block_en <= 1'b1;
                            
                            // Interface with data fetcher
                            fun_for_data_fetcher <= 3'b111;  // STORE_OLD_DATA
                            xs1_out <= 1;
                            xs2_out <= 1;
                            
                            // Interface with EAI controller
                            DATA_ADDRESS <= {18'b0, rs1, rs2};
                            WR_FLAG <= 1;
                            REQ_DATA <= 1;
                            
                            i_p_read_1 <= 0;
                            i_p_write_1 <= 0;
                            i_m_readdata_valid_1 <= 0;
                            i_m_waitrequest_1 <= 1;
            
                            i_p_read_2 <= 0; 
                            i_p_write_2 <= 0;
                            i_m_readdata_valid_2 <= 0; 
                            i_m_waitrequest_2 <= 1;
            
                            i_p_read_3 <= 0; 
                            i_p_write_3 <= 0;
                            i_m_readdata_valid_3 <= 0; 
                            i_m_waitrequest_3 <= 1;
            
                            i_p_read_4 <= 0; 
                            

                            // Write to Cache 4
                            counter <= counter + 1;
                            if (counter == 3) begin
                                i_p_write_4 <= 1;
                                i_m_readdata_valid_4 <= 1;
                                i_m_waitrequest_4 <= 0;
                                counter <= 0;
                                cfg_ready <= 0;
                            end
                            if(|hit4)
                           i_p_write_4<=0;
                        end
                        
                       
                        7'b0001001: begin // Mah.cfg.sdl.old.cache.external - Read old data from cache to external
                            // Interface with address block
                            to_address_block_rs1 <= rs1;
                            to_address_block_rs2 <= rs2;
                            address_block_en <= 1'b1;
                            
                            // Interface with data fetcher
                            fun_for_data_fetcher <= 3'b010;  // WRITE_BACK_OLD_DATA
                            xs1_out <= 1;
                            xs2_out <= 1;
                            
                            i_p_read_1 <= 0;
                            i_p_write_1 <= 0;
                            i_m_readdata_valid_1 <= 0;
                            i_m_waitrequest_1 <= 1;
            
                            i_p_read_2 <= 0; 
                            i_p_write_2 <= 0;
                            i_m_readdata_valid_2 <= 0; 
                            i_m_waitrequest_2 <= 1;
            
                            i_p_read_3 <= 0; 
                            i_p_write_3 <= 0;
                            i_m_readdata_valid_3 <= 0; 
                            i_m_waitrequest_3 <= 1;
            
                            
                            i_p_write_4 <= 0;
                            i_m_readdata_valid_4 <= 0; 
                            

                            // Interface with EAI controller
                            DATA_ADDRESS <= {18'b0, rs1, rs2};
                            RD_FLAG <= 1;
                            REQ_DATA <= 1;
                            
                            // Read from Cache 4
                            counter <= counter + 1;
                            if (counter == 3) begin
                                i_p_read_4 <= 1;
                                i_m_waitrequest_4 <= 0;
                                counter <= 0;
                                cfg_ready <= 0;
                            end
                        end
                        
                       
                        7'b0001011: begin // Mah.cfg.sdl.old.pe.cache - Store old data from PE to cache
                            // Interface with address block
                            to_address_block_rs1 <= rs1;
                            to_address_block_rs2 <= rs2;
                            address_block_en <= 1'b1;
                            
                            // Interface with EAI controller
                            DATA_ADDRESS <= {18'b0, rs1, rs2};
                            
                            // For DATA_SELECTOR
                            bank_s_sel <= 0;
                            bank_s_en <= 1;
                            PEID <= 2'b00;
                            
                            i_p_read_1 <= 0;
                            i_p_write_1 <= 0;
                            i_m_readdata_valid_1 <= 0;
                            i_m_waitrequest_1 <= 1;
            
                            i_p_read_2 <= 0; 
                            i_p_write_2 <= 0;
                            i_m_readdata_valid_2 <= 0; 
                            i_m_waitrequest_2 <= 1;
            
                            i_p_read_3 <= 0; 
                            i_p_write_3 <= 0;
                            i_m_readdata_valid_3 <= 0; 
                            i_m_waitrequest_3 <= 1;
            
                            i_p_read_4 <= 0; 
                           

                            counter_2 <= counter_2 + 1;
                            inducation_signal <= 1;
                            
                            if (counter_2 == 5) begin
                                src_C_en <= 1;
                                send_en <= 1;
                                counter_2 <= 0;
                                cfg_ready <= 0;
                            end
                            
                            // Write to Cache 4
                            counter <= counter + 1;
                            if (counter == 3) begin
                                i_p_write_4 <= 1;
                                i_m_readdata_valid_4 <= 1;
                                i_m_waitrequest_4 <= 0;
                                counter <= 0;
                            end
                        end
                        
                        7'b0001100: begin // Mah.wm - Set PE working mode
                            crossbar_sel <= rs1[4:0];  // Crossbar path configuration
                            pe_mode <= rs2[4:0];       // PE operation modes
                            PEID <= rd[1:0];           // Select active PE
                            cfg_ready <= 1;
                            counter <=0;
                            counter_2<=0;
                            counter_23<=0;
                            counter_24<=0;
                        end
                        
                        7'bxxx1101: begin // Mah.sc - Start calculation
                            to_address_block_rs1 <= index[4:0];
                            to_address_block_rs2 <= {1'b0,index[8:5]};
                            address_block_en <= 1'b1;
                            
                            // Interface with EAI controller
                            DATA_ADDRESS <= {18'b0, rs1, rs2};
                            
                            // For DATA_SELECTOR
                            bank_s_sel <= 0;
                            bank_s_en <= 1;
                            PEID <= 2'b00;
                            
                            counter_23 <= counter_23 + 1;
                            inducation_signal <= 0;
                            
                            
                          
            
                            i_p_read_3 <= 0; 
                            i_p_write_3 <= 0;
                            i_m_readdata_valid_3 <= 0; 
                            i_m_waitrequest_3 <= 1;
            
                            
                            i_p_write_4 <= 0;
                            i_m_readdata_valid_4 <= 0; 
                            

                            if (counter_23 == 5) begin
                                inducation_signal <= 1;
                                src_C_en <= 1;   // Enable srcC path
                                send_en <= 1;
                                counter_23 <= 0;
                                cfg_ready <= 0;
                            end
                            
                            if (inducation_signal) begin
                                src_C_en <= 0;
                                send_en <= 0;
                            end
                            
                            // Read from Cache 4
                            counter_24 <= counter_24 + 1;
                            if (counter_24 == 3) begin
                                i_p_read_4 <= 1;
                                i_m_waitrequest_4 <= 0;
                                counter_24 <= 0;
                            end
                        

                           to_address_block_rs1 <= index[4:0];
                            to_address_block_rs2 <= {1'b0,index[8:5]};
                            address_block_en <= 1'b1;
                            cfg_ready<=1;
                            // Interface with EAI controller
                            DATA_ADDRESS <= {18'b0, rs1, rs2};
                            

                            i_p_write_1 <= 0;
                            i_m_readdata_valid_1 <= 0;
            
                            i_p_read_3 <= 0; 
                            i_p_write_3 <= 0;
                            i_m_readdata_valid_3 <= 0; 
                            i_m_waitrequest_3 <= 1;
            
                           
                            // Read from Cache 1
                            counter <= counter + 1;
                            if (counter == 3) begin
                                i_p_read_1 <= 1;
                                i_m_waitrequest_1 <= 0;
                                counter <= 0;
                                //cfg_ready <= 0;
                            end 
                              
                               // Interface with address block
                            to_address_block_rs1 <= index[4:0];
                            to_address_block_rs2 <= {1'b0,index[8:5]};
                            address_block_en <= 1'b1;
                            
                            // Interface with data fetcher
                            fun_for_data_fetcher <= 3'b000;
                            
                            // Interface with EAI controller
                            DATA_ADDRESS <= {18'b0, rs1, rs2};
                            
                            // For DATA_SELECTOR
                            bank_s_sel <= 0;  // Select Bank 2
                            bank_s_en <= 1;
                            PEID <= 2'b00;    // Target PE0
                            
            
                           
                            i_m_readdata_valid_2 <= 0; 
                            
            
                            i_p_read_3 <= 0; 
                            i_p_write_3 <= 0;
                            i_m_readdata_valid_3 <= 0; 
                            i_m_waitrequest_3 <= 1;
            
                            

                            counter_2 <= counter_2 + 1;
                           // inducation_signal <= 1;
                            
                            if (counter_2 == 5) begin
                                src_A_en <= 1;    // Enable src_A path
                                send_en <= 1;     // Enable sending to PE
                                counter_2 <= 0;
                               // cfg_ready <= 0;
                            end 
                            
                            // Read from Cache 2
                            counter <= counter + 1;
                            if (counter == 3) begin
                                i_p_read_2 <= 1;
                                i_p_write_2<=0;
                                i_m_waitrequest_2 <= 0;
                                counter <= 0;
                            end
                            // Enable computational units based on pe_mode
                            Conv_en <= pe_mode[0];
                            adder_en <= pe_mode[1];
                            pool_en <= pe_mode[2];
                            relu_en <= pe_mode[3];
                           
                            if(indicator1)begin
                            srcA_write_en<=1;
                            counter_3<=counter_3+1;
                            srcA_read_en<=0;
                            end 
                            else srcA_write_en<=0;
                            addr_src_A<=counter_3;
                            // Configure crossbar paths based on mode
                            case (crossbar_sel)
                                5'h01: begin  // Convolution Only
                                    if(src_A_en&&indicator&&counter_5<4)begin
                                    counter_5<=counter_5+1;
                                    sel_Conv <= counter_5;
                                    end
                                   else if(counter_5>3)begin
                                    counter_5<=0;
                                    sel_Conv<=5'b11111; end 
                                    sel_Res <= 5'b00001;
                                    F <= 4'd3;
                                    conv_read_en<=0;
                                    
                                   if(finish_conv)begin
                                   counter_4<=counter_4+1;
                                   conv_write_en<=1;end
                                   else conv_write_en<=0;

                                    addr_conv <= counter_4;  
                                end
                                
                                5'h02:  begin   // Pool only
                                 i_p_read_1<=0;
                                 F<=0;
                                if(src_A_en&&indicator2&&counter_6<2)begin
                                    counter_6<=counter_6+1;
                                    sel_Pool <= counter_6;
                                    end

                                   if(counter_6>1)begin
                                    counter_6<=0;
                                    sel_Pool<=5'b11111; 
                                    end 

                                    sel_Res <= 5'b00100;
                                    Np <= 8'd4;  
                                    P <= 3'd2;  
                                
                                for (n=1; n<1024; n=n+1) begin
                                if(valid_pool && counter_7 < n*(Np/P)*(Np/P)) begin  // Add a size check
                                    counter_7 <= counter_7 + 1;
                                    pool_write_en <= 1;
                                end
                                else begin
                                    pool_write_en <= 0;
                               end
                               addr_pool <= counter_7;
                                end  
                               end
                                5'h03: begin  // Addition only
                                    sel_Add <= 5'b00000;
                                    sel_Res <= 5'b00010;
                                    if(indicator3) begin
                                        counter_8<=counter_8+1;
                                        add_write_en <= 1;
                                    end
                                    else begin
                                        add_write_en <= 0;
                                    end
                                    addr_add <= counter_8; 
                                end
                                
                                5'h04: begin  // ReLU only
                                 if( counter_9 < 2 )begin
                                    counter_9 <= counter_9 + 1;
                                    sel_Relu <= counter_9;
                                    end
                                   else if (counter_9>2) begin
                                    counter_9<=0;
                                    sel_Relu<=5'b11111; end 
                                    sel_Res <= 5'b00011;
                                    relu_read_en <=0;
                                    if(indicator4 && counter_10 <1024) begin
                                        counter_10 <= counter_10 + 1;
                                        relu_write_en <= 1;
                                    end
                                    else begin
                                        relu_write_en <= 0;
                                    end
                                    addr_relu <= counter_10;
                                end
                                5'h05: begin  // Conv -> ReLU
                                // Convolution
                                    if(src_A_en&&indicator&&counter_12<4)begin
                                    counter_12<=counter_12+1;
                                    sel_Conv <= counter_12;
                                    end
                                   else if(counter_12>3)begin
                                    counter_5<=0;
                                    sel_Conv<=5'b11111; end 
                                    sel_Relu <= 5'b00010;
                                    F <= 4'd3;
                                    conv_read_en<=0;
                                    
                                   if(finish_conv)begin
                                   counter_13<=counter_13+1;
                                   conv_write_en<=1;end
                                   else conv_write_en<=0;
                                   addr_conv <= counter_13;  
                                   conv_read_en<=1;
                                //Relu
                                    if(indicator4 && counter_14 <1024) begin
                                        counter_14 <= counter_14 + 1;
                                        relu_write_en <= 1;
                                    end
                                    else begin
                                        relu_write_en <= 0;
                                    end
                                    addr_relu <= counter_14;
                                    sel_Res <= 5'b00011;
                                    end
                                
                                5'h06: begin  // Conv -> Pool
                                //Convolution
                                    if(src_A_en&&indicator&&counter_15<4)begin
                                    counter_15<=counter_15+1;
                                    sel_Conv <= counter_15;
                                    end
                                   else if(counter_15>3)begin
                                    counter_15<=0;
                                    sel_Conv<=5'b11111; end 
                                
                                    F <= 4'd3;
                                    conv_read_en<=0;
                                    
                                   if(finish_conv)begin
                                   sel_Pool <= 5'b00010;
                                   
                                   counter_16<=counter_16+1;
                                   conv_write_en<=1;end
                                   else begin
                                    conv_write_en<=0;
                                    sel_Pool <= 5'b11111;end

                                   addr_conv <= counter_16;  
                                   conv_read_en<=1;
                                // Pool   
                                    Np <= 8'd4;
                                    P <= 3'd2;
                                   for (n=1; n<1024; n=n+1) begin
                                    if(valid_pool && counter_17 < n*(Np/P)*(Np/P)) begin  // Add a size check
                                    counter_17 <= counter_17 + 1;
                                    pool_write_en <= 1;
                                    end
                                    else begin
                                    pool_write_en <= 0;
                                    end
                                    addr_pool <= counter_17;
                                    end  
                                    sel_Res <= 5'b00100;
                                end
                                
                                5'h07: begin  // Conv -> Pool -> RELU
                                    F <= 4'd3;
                                    Np <= 8'd4;
                                    P <= 3'd2;
                                 //Convolution
                                    if(src_A_en&&indicator&&counter_18<4)begin
                                    counter_18<=counter_18+1;
                                    sel_Conv <= counter_18;
                                    end
                                   else if(counter_18>3)begin
                                    counter_18<=0;
                                    sel_Conv<=5'b11111; end 
                                    
                                    conv_read_en<=0;

                                   if(finish_conv)begin
                                   sel_Pool <= 5'b00010;
                                   counter_11<=counter_11+1;
                                   conv_write_en<=1;end
                                    else begin
                                    conv_write_en<=0;
                                    sel_Pool <= 5'b11111;end

                                   addr_conv <= counter_11;  
                                   conv_read_en<=1;

                                // Pool   
                                   for (n=1; n<1024; n=n+1) begin
                                    if(valid_pool && counter_19 < n*(Np/P)*(Np/P)) begin  // Add a size check
                                    counter_19 <= counter_19 + 1;
                                    pool_write_en <= 1;
                                    end
                                    else begin
                                    pool_write_en <= 0;
                                    end
                                    addr_pool <= counter_19;
                                    end
                                    pool_read_en <= 1;
                                 
                                    if(finish_pool)
                                    sel_Relu <= 5'b00101;
                                    else 
                                    sel_Relu<=5'b11111;
        
                                    sel_Res <= 5'b00011;
                                    relu_read_en <=0;
                                    if(indicator4 && counter_22 <1024) begin
                                        counter_22 <= counter_22 + 1;
                                        relu_write_en <= 1;
                                    end
                                    else begin
                                        relu_write_en <= 0;
                                    end
                                    relu_read_en <= 1;
                                    addr_relu <= counter_22;
                                end
                                
                                5'h08:begin  // Conv -> Pool -> Add -> ReLU 
                                    F <= 4'd3;
                                    Np <= 8'd4;
                                    P <= 3'd2;
                                 //Convolution
                                    if(src_A_en&&indicator&&counter_18<4)begin
                                    counter_18<=counter_18+1;
                                    sel_Conv <= counter_18;
                                    end
                                   else if(counter_18>3)begin
                                    counter_18<=0;
                                    sel_Conv<=5'b11111; end 
                                    
                                    conv_read_en<=0;

                                   if(finish_conv)begin
                                   sel_Pool <= 5'b00010;
                                   counter_11<=counter_11+1;
                                   conv_write_en<=1;end
                                    else begin
                                    conv_write_en<=0;
                                    sel_Pool <= 5'b11111;end

                                   addr_conv <= counter_11;  
                                   conv_read_en<=1;

                                // Pool   
                                   for (n=1; n<1024; n=n+1) begin
                                    if(valid_pool && counter_19 < n*(Np/P)*(Np/P)) begin  // Add a size check
                                    counter_19 <= counter_19 + 1;
                                    pool_write_en <= 1;
                                    end
                                    else begin
                                    pool_write_en <= 0;
                                    end
                                    addr_pool <= counter_19;
                                    end
                                    pool_read_en <= 1;

                                // ADD 
                                    if(finish_pool) begin
                                        sel_Add <= 5'b00011;  // Select pooling output as Add input
                                        counter_20 <= counter_20 + 1;
                                        add_write_en <= 1;
                                        end
                                    else begin
                                        sel_Add <= 5'b11111;
                                        add_write_en <= 0;
                                    end
                                    
                                    add_read_en <= 1;
                                    addr_add <= counter_20;

                                //Relu    
                                    if(finish_adder) begin
                                        // Start the counter when adder finishes
                                        counter_21 <= 1;  // Start at 1 to enter the sequence on next cycle
                                        // Don't set sel_Relu here - wait for the counter sequence
                                    end

                                    // Process the counter sequence separately from finish_adder
                                    if(counter_21 > 0) begin
                                        counter_21 <= counter_21 + 1;
                                        
                                        // Set sel_Relu based on counter sequence
                                        case(counter_21)
                                            1:  sel_Relu <= 5'b00011;
                                            2:  sel_Relu <= 5'b00100;  // Select upper 16 bits from add_out
                                            3:  sel_Relu <= 5'b00011;  // Keep selecting upper 16 bits
                                            4: begin
                                                sel_Relu <= 5'b00100;  // Reset selector
                                                counter_21 <= 1;       // Reset counter
                                            end
                                            default: sel_Relu <= 5'b11111;
                                        endcase
                                    end

                                    // Process ReLU output separately
                                    if((counter_21 >= 1 && counter_21 <= 4) && indicator4 && counter_22 < 1024) begin
                                        counter_22 <= counter_22 + 1;
                                        relu_write_en <= 1;
                                    end
                                    else begin
                                        relu_write_en <= 0;
                                    end

                                    sel_Res <= 5'b00011;
                                    relu_read_en <= 1;  // Keep read enabled
                                    addr_relu <= counter_22;
                                end
                                                                
                                default: begin
                                    // Default: simple convolution
                                    sel_Conv <= 5'b11111;
                                    sel_Res <= 5'b11111;
                                    sel_Add <= 5'b11111;
                                    sel_Pool <= 5'b11111;
                                    sel_Relu <= 5'b11111;
                                end
                            endcase
                            
                            // Enable data transfer to PE
                           //src_A_en <= 1'b1;
                            src_C_en <= pe_mode[1];  // Enable srcC if addition is enabled
                            send_en <= 1'b1;
                            
                          //  cfg_ready <= 0;
                            //next_state <= EXECUTE;
                        end
                        
                        default: begin
                            cfg_ready <= 0;
                        end
                    endcase
                end
                
                EXECUTE: begin
                    // Initialize memory addresses for computation
                    addr_conv <= 7'h0;    // Example address
                    addr_add <= 7'h10;    // Example address
                    addr_relu <= 7'h20;   // Example address
                    addr_pool <= 7'h30;   // Example address
                    
                    // Set memory read/write enables as needed
                    conv_read_en <= (Conv_en) ? 1'b1 : 1'b0;
                    add_read_en <= (adder_en && crossbar_sel == 5'h08) ? 1'b1 : 1'b0;
                end
                
                WAIT_COMPLETION: begin
                    // Wait for PE computation to complete
                    if (finish_pe || (
                        (!Conv_en || finish_conv[PEID]) &&
                        (!adder_en || finish_adder[PEID]) &&
                        (!pool_en || finish_pool[PEID]) &&
                        (!relu_en || finish_relu[PEID])
                    )) begin
                        // Reset all operation enables
                        conv_read_en <= 1'b0;
                        add_read_en <= 1'b0;
                        finish_operation <= 1'b1;
                    end
                end
                
                WRITE_BACK: begin
                    // Reset computational units
                    Conv_en <= 1'b0;
                    adder_en <= 1'b0;
                    pool_en <= 1'b0;
                    relu_en <= 1'b0;
                    
                    // Reset data path controls
                    src_A_en <= 1'b0;
                    src_C_en <= 1'b0;
                    send_en <= 1'b0;
                    
                    // Signal completion
                    finish_operation <= 1'b1;
                end
            endcase
        end
    end
    
    // Next state logic
    always @(*) begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (cfg_valid) begin
                    next_state = CONFIG;
                end
            end
            
            CONFIG: begin
                // State transition logic for the CONFIG state
                if (funct7 == 7'b0001101) begin  // Mah.sc
                    next_state = CONFIG;
                end else 
                if (!cfg_ready) begin
                    next_state = IDLE;
                end
            end
            
            EXECUTE: begin
                next_state = WAIT_COMPLETION;
            end
            
            WAIT_COMPLETION: begin
                if (finish_pe || (
                    (!Conv_en || finish_conv[PEID]) &&
                    (!adder_en || finish_adder[PEID]) &&
                    (!pool_en || finish_pool[PEID]) &&
                    (!relu_en || finish_relu[PEID])
                )) begin
                    next_state = WRITE_BACK;
                end
            end
            
            WRITE_BACK: begin
                next_state = IDLE;
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule