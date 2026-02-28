/////////////////////////////////@CopyRights/////////////////////////////////////////////////
// Company: No sponsorship
// Team: Mohamed Gamal & Ahmed Reda & Abdallah Sabah & Abdallah sleem & Mohamed Ahmed & Ibrahim Hamdy & Beshoy Maher & Mostafa Osman
// Supervisior Dr: Sherif Fathy
// Team Leader: Mohamed Ahmed Ibrahim
// Technical Head : Mohamed Gamal & Ahmed Reda 
// Human Resource : Beshoy Magdy  
// Check Date: 19/2/2025 11:44:49 PM
// Design Name:CNN unit
// Module Name: EAI Controller
// Project Name: Graduation project
//Designer: Mohamed Gamal & Abdullah Sabah
/////////////////////////////////@CopyRights/////////////////////////////////////////////////

module EAI( input clk,
    input rst_n,
    output active,



    // Control cmd_req
    input   nice_req_valid,
    output reg   nice_req_ready,
    input  [31:0]       nice_req_inst,
    input  [31:0]       nice_req_rs1,
    input  [31:0]       nice_req_rs2,


    // Control cmd_rsp	
    output reg nice_rsp_valid,
    input nice_rsp_ready,
    output reg[31:0] nice_rsp_rdat,


    // Memory lsu_req	
    output reg  nice_icb_cmd_valid,
    input nice_icb_cmd_ready,
    output reg[31:0] nice_icb_cmd_addr,
    output reg  nice_icb_cmd_read,
    output reg[31:0] nice_icb_cmd_rdata,


    input nice_icb_rsp_valid,
    output  reg nice_icb_rsp_ready,
    input  [31:0] nice_icb_rsp_Wdata,



    input  [31:0]                  data_addr,       //comment
    input  [31:0]                  unfinished_data,  //comment (important flow)
    output reg [31:0]              p_data,          //not now
    input                          finish,          //comment controller
    input                          req_data,        //comment
    input                          wr,                   //comment
    input                          rd,                   //comment
    input      [31:0]              CNN_Result,          //not now
    output reg [31:0]              instr,            //comment                       
    output reg [31:0]              rs1,             //data_1 to data fetcher
    output reg [31:0]              rs2,             //data_2 to data fetcher
    output reg                     decoder_valid,      //comment decoder
    input  reg                     decoder_ready,       //comment  


//hand check for the data fetcher

input mem_request_valid
 );





// Request channel
always @(posedge clk) begin
    if (!rst_n) begin
        nice_req_ready <= 0;
        instr <= 0;
        rs1 <= 0;
        rs2 <= 0;
        decoder_valid <= 0;
    end else begin
        if (nice_req_valid) begin
            decoder_valid <= 1;

            if (decoder_ready) begin
                instr <= nice_req_inst;
                nice_req_ready <= 1;
                if(mem_request_valid)
                begin
                rs1 <= nice_req_rs1;
                rs2 <= nice_req_rs2;
                
            //connect to data fetcher "mem_response_valid"
                end
            end
        end else begin
            nice_req_ready <= 0;
            decoder_valid <= 0;
        end
    end
end





// Response channel
always @(posedge clk) begin
    if (!rst_n) begin
        nice_rsp_valid <= 0;
        nice_rsp_rdat <= 0;
    end else begin
        if (finish) begin
            nice_rsp_valid <= 1;
            if(nice_rsp_ready)
            nice_rsp_rdat <= CNN_Result;
        end else begin
            nice_rsp_valid <= 0;
        end
    end
end




//nice_icb_cmd_ready
// Memory request channel         //to get data from external memory, send req_data flag and address 32bit and rd flag
always @(posedge clk) begin
    if (!rst_n) begin
        nice_icb_cmd_valid <= 0;
        nice_icb_cmd_addr <= 0;
        nice_icb_cmd_read <= 0;
        nice_icb_cmd_rdata<=0;
    end else begin
        if (req_data) begin 
            nice_icb_cmd_valid <= 1;
            if(nice_icb_cmd_ready)
            begin
            nice_icb_cmd_addr <= data_addr;    
            if (rd) begin
                if( mem_request_valid)   
                begin
                nice_icb_cmd_read <= 1;
                nice_icb_cmd_rdata<=unfinished_data;
                end
             
            end else if (wr) begin
                nice_icb_cmd_read <= 0;
            end
            end
        end else begin
            nice_icb_cmd_valid <= 0;
        end
    end
end



//Memory response channel
always @(posedge clk) begin
    if (!rst_n) begin
        nice_icb_rsp_ready<=0;
        p_data<=0;
    end else begin
        if (nice_icb_rsp_valid) begin
            nice_icb_rsp_ready<=1;             //connect to data fetcher "mem_response_valid"
            if(mem_request_valid)
            p_data<=nice_icb_rsp_Wdata;
        end
    end
end

assign active = nice_req_valid;

endmodule

