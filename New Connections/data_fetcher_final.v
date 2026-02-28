/////////////////////////////////@CopyRights/////////////////////////////////////////////////
// Company: No sponsorship
// Team: Mohamed Gamal & Ahmed Reda & Abdallah Sabah & Abdallah sleem & Mohamed Ahmed & Ibrahim Hamdy & Beshoy Maher & Mostafa Osman
// Supervisior Dr: Sherif Fathy
// Team Leader: Mohamed Ahmed Ibrahim
// Technical Head : Mohamed Gamal & Ahmed Reda 
// Human Resource : Beshoy Magdy  
// Check Date: 19/2/2025 11:44:49 PM
// Design Name:CNN unit
// Module Name: Data Fetcher block
// Project Name: Graduation project
//Designer: Ahmed Reda
/////////////////////////////////@CopyRights/////////////////////////////////////////////////


module data_fetcher (
    input clk,
    input  rst_n,
    
// hardware for unfinished data

    output reg finish,
    // Memory interface with LSU via EAI Controller
    input  mem_response_valid,             //comment
    input  [31:0] data_response_1,         //comment
    input  [31:0] data_response_2,         //comment
    input  Xs1,                           //comment
    input  Xs2,                          //comment
    input  nice_icb_cmd_ready,
    input  nice_rsp_valid,    //enable to send result
    output reg mem_request_valid,            //comment
    output reg [31:0] mem_request_data,      //comment

    
    // Instruction from Decoder
    input  [2:0] instruction,             //from decoder three bits to inducate its function.
    
    // Cache Banks (store old & intermediate results)
    output reg [31:0] cache_bank1_data, // Stores Input Image
    output reg [31:0] cache_bank2_data, // Stores Old Data
    output reg [31:0]  CNN_Result_to_EAI_Conroller, 
    input  o_p_readdata_valid,    // for data fetcher to tell there is a data so ready to recieve it

    input  [31:0] cache_bank3_output, // Data for Write-back
    input  [31:0] p_data, // old data that proccessed and return from e203 such as division
    input  [31:0] cache_bank2_output,
    // COE Cache for Kernel Coefficients
    output reg [31:0] coe_cache_data,
    output reg [31:0] cache_bank3_data //Old Data from EAI 
    
);

   // Instruction Encoding
    localparam DELETE_Output_data = 3'b000;
    localparam STORE_COEFFICIENTS = 3'b001;
    localparam STORE_INPUT_IMAGE  = 3'b111;
    localparam WRITE_BACK_OLD_DATA = 3'b010;
    localparam STORE_OLD_DATA  = 3'b011;
    localparam WRITE_BACK_RESULT_OF_CNN = 3'b100;

    //reg [31:0] selected_data;
   // reg [31:0] data_saved_and_ready_to_EAI;

    // always @(posedge clk) begin 
    //      if (!rst_n) begin
    //         selected_data <= 32'b0;
    //     end 
        //else begin
      //  case ({Xs1})
       //     1'b1: selected_data <= data_response_1;
       //     1'b0: selected_data <= data_response_2;
   // endcase
     //   end
    //end

    always @(posedge clk) begin
        if (!rst_n) begin
            mem_request_valid <= 0;
            coe_cache_data <= 0;
            cache_bank1_data <= 0;
            cache_bank2_data <= 0;
            mem_request_data <= 0;
            CNN_Result_to_EAI_Conroller <= 0;
            cache_bank3_data <= 0;
             mem_request_valid <= 0;
             finish<=0;

        end else begin
            case (instruction)
                DELETE_Output_data: begin
                 coe_cache_data <= 0;
                 cache_bank1_data <= 0;
                 cache_bank2_data <= 0;
                 mem_request_data <= 0;
                 CNN_Result_to_EAI_Conroller <= 0;
                 cache_bank3_data <= 0;
                
                end
                STORE_COEFFICIENTS: begin
                     mem_request_valid <= 1;
                    if (mem_response_valid)
                        coe_cache_data <= data_response_1;
                     // mem_request_valid <= 0;
                end
                STORE_INPUT_IMAGE: begin
                    mem_request_valid <= 1;
                    if (mem_response_valid) 
                          
                         cache_bank1_data <= data_response_1;
                         // mem_request_valid <= 0;
                end
                WRITE_BACK_RESULT_OF_CNN: begin
                    mem_request_valid <= 0;
                    if(o_p_readdata_valid) begin
                     //  data_saved_and_ready_to_EAI <= cache_bank2_output;
                       finish<=1;
                        CNN_Result_to_EAI_Conroller <= cache_bank2_output;end
                end
                STORE_OLD_DATA: begin
                    mem_request_valid <= 1; 
                    if (mem_response_valid)
                        cache_bank3_data <= data_response_1;
                   // finish<=1;end
                end
                WRITE_BACK_OLD_DATA: begin
                    mem_request_valid <= 1;
                    if( o_p_readdata_valid)
                    if(nice_icb_cmd_ready)
                    mem_request_data <= cache_bank3_output;
                end
                default: begin
                    mem_request_valid <= 0;
                end
            endcase
        end
    end

endmodule
