/////////////////////////////////@CopyRights/////////////////////////////////////////////////
// Company: No sponsorship
// Team: Mohamed Gamal & Ahmed Reda & Abdallah Sabah & Abdallah sleem & Mohamed Ahmed & Ibrahim Hamdy & Beshoy Maher & Mostafa Osman
// Supervisior Dr: Sherif Fathy
// Team Leader: Mohamed Ahmed Ibrahim
// Technical Head : Mohamed Gamal & Ahmed Reda 
//// Human Resource : Beshoy Magdy  
// Check Date: 19/2/2025 11:44:49 PM
// Design Name:CNN unit
// Module Name: Data Selector
// Project Name: Graduation project
//Designer: Mostafa Othman
/////////////////////////////////@CopyRights/////////////////////////////////////////////////

module DataSelector (
    input  clk ,
    input  rst ,
    input [31:0] cache1_data ,  //with caches (fetch from it)
    input [31:0]direct_path,
    input direct,
    input [31:0] cache2_data ,  //with caches (fetch from it)
    input src_A_en ,       //signal inducate approval to send data through scr_a to pe
    input src_C_en ,       //signal inducate approval to send data through scr_c to pe
    input send_en ,        //signal inducate approval to send to pe
    input [1:0] PE1_sel ,  //to select which PE to deal with (PEID) (send data to pe
    input bank_s_sel ,    // "1" bank 3 and "0" bank 4
    input bank_s_en ,     // enable signal to store in the bank (the bank is ready to recieve data and store)
    input [1:0] store_result1 ,  //to select which PE to deal with (PEID) (recieve data from pe)
    input [31:0] PE1_result ,
    input [31:0] PE2_result ,
    input [31:0] PE3_result ,
    input [31:0] PE4_result ,
    output reg [31:0] src_A1 ,
    output reg [31:0] src_A2 ,
    output reg [31:0] src_A3 ,
    output reg [31:0] src_A4 ,
    output reg [31:0] src_C1 ,
    output reg [31:0] src_C2 ,
    output reg [31:0] src_C3 ,
    output reg [31:0] src_C4 ,
    output reg [31:0] bank3_s ,       //with caches (store in it)
    output reg [31:0] bank4_s,  
    output reg [31:0] direct_out,      //with caches (store in it)
    input local_rst_data_selector
);

    //sending block
    always @(posedge clk) begin
        if (!rst || !local_rst_data_selector) begin
            src_A1 <= 0; src_C1 <= 0;
            src_A2 <= 0; src_C2 <= 0;
            src_A3 <= 0; src_C3 <= 0;
            src_A4 <= 0; src_C4 <= 0;
        end
        else 
        begin
        
        if (~direct&send_en & src_A_en) begin
            case (PE1_sel)
               2'b00 : src_A1 <= cache1_data; 
               2'b01 : src_A2 <= cache1_data;
               2'b10 : src_A3 <= cache1_data;
               2'b11 : src_A4 <= cache1_data;
                default : begin src_A1 <= 0;
                        src_A2 <= 0;
                        src_A3 <= 0;
                        src_A4 <= 0;
                end
            endcase

        end 
        else begin
            case (PE1_sel)
               2'b00 : src_A1 <= direct_path; 
               2'b01 : src_A2 <= direct_path;
               2'b10 : src_A3 <= direct_path;
               2'b11 : src_A4 <= direct_path;
                default : begin src_A1 <= 0;
                        src_A2 <= 0;
                        src_A3 <= 0;
                        src_A4 <= 0;
                end
            endcase
        end
         if (send_en & src_C_en) begin
            case (PE1_sel)
               2'b00 : src_C1 <= cache2_data; 
               2'b01 : src_C2 <= cache2_data;
               2'b10 : src_C3 <= cache2_data;
               2'b11 : src_C4 <= cache2_data;
                default : begin src_C1 <= 0;
                        src_C2 <= 0;
                        src_C3 <= 0;
                        src_C4 <= 0;
                end
            endcase
        end
    end
    end




    //storing block
    always @(posedge clk) begin
        if (!rst || !local_rst_data_selector) begin
            bank3_s <= 0;
            bank4_s <= 0;
        end

        else begin

        if (~direct&bank_s_en & bank_s_sel) begin
            case (store_result1)
                2'b00 : bank3_s <= PE1_result;
                2'b01 : bank3_s <= PE2_result;
                2'b10 : bank3_s <= PE3_result;
                2'b11 : bank3_s <= PE4_result;
                default: begin
                bank3_s <= 0;
                end
            endcase

        end 
        else if(direct&bank_s_en & bank_s_sel)  begin
            case (store_result1)
                2'b00 : direct_out <= PE1_result;
                2'b01 : direct_out <= PE2_result;
                2'b10 : direct_out <= PE3_result;
                2'b11 : direct_out <= PE4_result;
                default: begin
                direct_out <= 0;
                end
            endcase

        end 
        else if (bank_s_en & ~bank_s_sel) begin
                     case (store_result1)
                2'b00 : bank4_s <= PE1_result;
                2'b01 : bank4_s <= PE2_result;
                2'b10 : bank4_s <= PE3_result;
                2'b11 : bank4_s <= PE4_result;
                default: begin
                bank4_s <= 0;
                end
            endcase
        end 
    end


    end

endmodule