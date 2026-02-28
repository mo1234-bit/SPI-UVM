/////////////////////////////////@CopyRights/////////////////////////////////////////////////
// Company: No sponsorship
// Team: Mohamed Gamal & Ahmed Reda & Abdallah Sabah & Abdallah sleem & Mohamed Ahmed & Ibrahim Hamdy & Beshoy Maher & Mostafa Osman
// Supervisior Dr: Sherif Fathy
// Team Leader: Mohamed Ahmed
// Technical Head : Mohamed Gamal & Ahmed Reda
// Human Resource : Beshoy Magdy  
// Check Date: 19/2/2025 11:44:49 PM
// Design Name:CNN unit
// Module Name: ReConfig. Controller
// Project Name: Graduation project
//Designer: Abdallah sleem & Mohamed Ahmed
/////////////////////////////////@CopyRights/////////////////////////////////////////////////

module config_controller (
    input clk,
    input rst_n,


   //interface with address block
output reg [4:0] to_address_block_rs1,
output reg [4:0] to_address_block_rs2,
output reg address_block_en,
output reg addr_wr,

    // Decoder Interface
    input cfg_valid,          // Data from decoder is valid to send to our king cofig. controller
    input [6:0] funct7,     
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input xs1,
    input xs2,
    input xd,
    output reg cfg_ready,     // Controller is ready for new data from our king decoder





    // Control Signals
    output reg reset_en,              // acc.rest
    output reg [4:0] start_cal,      // acc.sc
   



    
    output reg [2:0] fun_for_data_fetcher,  //for data fetcher
    output reg xs1_out,  //for data fetcher
    output reg xs2_out,  //for data fetcher

   //@@@@@@@@@@@@@@@@@@@@@@@@@@EAI controller@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    output reg RD_FLAG,    //for EAI controller      "rd"
    output reg WR_FLAG,    //for EAI controller      "wr"
    output reg REQ_DATA,    //for EAI controller from the output storage as it doesnot in the caches  "req_data"
    output reg [31:0] DATA_ADDRESS,    //for EAI controller     "data_addr"
    output reg finish, //for EAI controller that inducate that the total convolution is end




//@@@@@@@@@@@@@@@@@@@@@@@@@@@for DATA_SELECTOR@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    output reg BANKID,  // "1" bank 3 and "0" bank 4
    output reg BANK_READY, // wait to see it in besho and hema signals
    output reg [1:0] PEID,  //for DATA_SELECTOR
    output reg src_a_enable, // enable sending to src_a not scr_c
    output reg src_c_enable,
    output reg send_en, //to enable data selector to send to pe "enable sending to pe"
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@PE interface@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
input finish_pe, //to inducate the PE has finish so disenable the start Mah.sc
output reg [4:0] crossbar_sel,
output reg [4:0] pe_mode,


//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 1 interface (the o_p mean input to me)
input      o_p_waitrequest_1,         // signal tell me the cache is ready to recieve data       //review
output reg i_p_read_1, i_p_write_1,              // to tell him the cache to read or write operation
input   o_m_read_1, o_m_write_1,             //read and write to me to send it to eai as wr_en, or rd_en   //review                     
output reg      i_m_readdata_valid_1,    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
output reg      i_m_waitrequest_1,     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)

//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////    
//cache 2 interface
input       o_p_waitrequest_2,         // signal tell me the cache is ready to recieve data       //review
output reg i_p_read_2, i_p_write_2,               // to tell him the cache to read or write operation
input   o_m_read_2, o_m_write_2,              //read and write to me to send it to eai as wr_en, or rd_en   //review                     
output reg      i_m_readdata_valid_2,    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
output reg      i_m_waitrequest_2,     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)

//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 3 interface
input         o_p_waitrequest_3,         // signal tell me the cache is ready to recieve data       //review
output reg i_p_read_3, i_p_write_3,               // to tell him the cache to read or write operation
input   o_m_read_3, o_m_write_3,              //read and write to me to send it to eai as wr_en, or rd_en   //review                     
output reg      i_m_readdata_valid_3,    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
output reg      i_m_waitrequest_3,     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)

//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 4 interface
input        o_p_waitrequest_4,         // signal tell me the cache is ready to recieve data       //review
output reg i_p_read_4, i_p_write_4,               // to tell him the cache to read or write operation
input   o_m_read_4, o_m_write_4,             //read and write to me to send it to eai as wr_en, or rd_en   //review                     
output reg      i_m_readdata_valid_4,    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
output reg      i_m_waitrequest_4    //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)





);


reg [4:0] counter;
reg [4:0] counter_2;
reg inducation_signal;


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reset_en <= 1;
            start_cal <= 0;
            cfg_ready <= 1; 
addr_wr<=0;
//DATA FETCHER SIGNALS

fun_for_data_fetcher <= 0;
xs1_out <= 0;
xs2_out <= 0;

// EAI CONTROLL SIGNALS
RD_FLAG <= 0;
WR_FLAG <= 0;
REQ_DATA <= 0;
DATA_ADDRESS <= 0;
finish <= 0;

//DATA SELECTORS SIGNALS
BANKID <= 0;
BANK_READY <= 0;
PEID <= 0;
src_a_enable <= 0;
src_c_enable <= 0;
send_en <= 0; //to enable data selector to send to pe "active sending"

// interface with address block
   //interface with address block
to_address_block_rs1 <= 0;
to_address_block_rs2 <= 0;
address_block_en <= 0;

// interface with cache block
i_p_read_1  <= 0;
i_p_write_1 <= 0;
i_m_readdata_valid_1 <= 0;
i_m_waitrequest_1 <= 1;

// interface with cache block
i_p_read_2  <= 0;
i_p_write_2 <= 0;
i_m_readdata_valid_2 <= 0;
i_m_waitrequest_2 <= 1;

// interface with cache block
i_p_read_3  <= 0;
i_p_write_3 <= 0;
i_m_readdata_valid_3 <= 0;
i_m_waitrequest_3 <= 1;

// interface with cache block
i_p_read_4 <= 0;
i_p_write_4 <= 0;
i_m_readdata_valid_4 <= 0;
i_m_waitrequest_4 <= 1;

counter <= 0;
counter_2 <= 0;
        end 
        
        
        else begin

            if (cfg_valid) begin

                // Generate control signals based on funct7
                case (funct7)

         7'b0000001: begin     // Mah. Rest 

                     reset_en <= 0;     

                     end



         7'b0000010: begin    // Mah.load.ke.cache 

// interface with decoder
cfg_ready <= 1'b1;  //Controller is ready for new data from our king decoder

//interface with address block
to_address_block_rs1 <= rs1;
to_address_block_rs2 <= rs2;
address_block_en <= 1'b1;

//interface with data fetcher   
fun_for_data_fetcher <= 3'b001;  //for data fetcher
xs1_out <= 1;  //for data fetcher
xs2_out <= 1;  //for data fetcher

//interface with EAI controller
DATA_ADDRESS <= {18'b0, rs1, rs2};    //for EAI controller     "data_addr"
 RD_FLAG <= 0;      //for EAI controller      "rd"
 WR_FLAG <= 0;     //for EAI controller      "wr"
 REQ_DATA <= 0;   //for EAI controller from the output storage as it doesnot in the caches  "req_data"
 finish <= 0;   //for EAI controller that inducate that the total convolution is end


//for DATA_SELECTOR
//output reg BANKID,  // "1" bank 3 and "0" bank 4
 BANK_READY <= 0; 
 PEID <= 2'b00;  //on the output pe0
 src_a_enable <= 0; // enable sending to src_a not scr_c
 src_c_enable <= 0;
 send_en <= 0; //to enable data selector to send to pe "enable sending to pe"


//cache 1 interface (the o_p mean input to me)

i_p_write_1 <= 0;       // to tell him the cache to read or write operation
i_p_read_1 <= 0;       // to tell him the cache to read or write operation
                 
i_m_readdata_valid_1 <= 1;   //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_1 <= 0;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)

addr_wr<=1;

counter <= counter +1'b1;

if (counter == 3)
begin

//cache 1 interface (the o_p mean input to me)

i_p_write_1 <= 1;       // to tell him the cache to read or write operation
i_p_read_1 <= 0;       // to tell him the cache to read or write operation
                 
i_m_readdata_valid_1 <= 1;   //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_1 <= 0;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)

counter <= 0;

// interface with decoder
cfg_ready <= 1'b0;  //Controller is ready for new data from our king decoder
end

//cache 2 interface (the o_p mean input to me)

i_p_write_2 <= 0;       // to tell him the cache to read or write operation
i_p_read_2 <= 0;       // to tell him the cache to read or write operation
             
i_m_readdata_valid_2 <= 0;   //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_2 <= 1;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


//cache 3 interface (the o_p mean input to me)

i_p_write_3 <= 0;       // to tell him the cache to read or write operation
i_p_read_3 <= 0;       // to tell him the cache to read or write operation
                 
i_m_readdata_valid_3 <= 0;   //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_3 <= 1;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


//cache 4 interface (the o_p mean input to me)

i_p_write_4 <= 0;       // to tell him the cache to read or write operation
i_p_read_4 <= 0;       // to tell him the cache to read or write operation
             
i_m_readdata_valid_4 <= 0;   //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_4 <= 1;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


                     end


                                  
                                  
         7'b0000011: begin   // Mah.load.img.cache 
// interface with decoder
cfg_ready <= 1'b1;  //Controller is ready for new data from our king decoder


//interface with address block
to_address_block_rs1 <= rs1;
to_address_block_rs2 <= rs2;
address_block_en <= 1'b1;


//interface with data fetcher   
fun_for_data_fetcher <= 3'b111;  //for data fetcher
xs1_out <= 1;  //for data fetcher
xs2_out <= 1;  //for data fetcher


//interface with EAI controller
DATA_ADDRESS <= {18'b0, rs1, rs2};    //for EAI controller     "data_addr"
 RD_FLAG <= 0;      //for EAI controller      "rd"
 WR_FLAG <= 0;     //for EAI controller      "wr"
 REQ_DATA <= 0;   //for EAI controller from the output storage as it doesnot in the caches  "req_data"
 finish <= 0;   //for EAI controller that inducate that the total convolution is end

//for DATA_SELECTOR
//output reg BANKID,  // "1" bank 3 and "0" bank 4
 BANK_READY <= 0; 
 PEID <= 2'b00;  //on the output pe0
 src_a_enable <= 0; // enable sending to src_a not scr_c
 src_c_enable <= 0;
 send_en <= 0; //to enable data selector to send to pe "enable sending to pe"

//cache 1 interface (the o_p mean input to me)
i_p_write_1 <= 0;       // to tell him the cache to read or write operation
i_p_read_1 <= 0;       // to tell him the cache to read or write operation
                 
i_m_readdata_valid_1 <= 0;   //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_1 <= 1;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)

//cache 2 interface (the o_p mean input to me)
i_p_write_2 <= 0;       // to tell him the cache to read or write operation
i_p_read_2 <= 0;       // to tell him the cache to read or write operation
                   
i_m_readdata_valid_2 <= 1;   //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_2 <= 0;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


counter <= counter +1'b1;

if (counter == 3)
begin
//cache 2 interface (the o_p mean input to me)
i_p_write_2 <= 1;       // to tell him the cache to read or write operation
i_p_read_2 <= 0;       // to tell him the cache to read or write operation
                   
i_m_readdata_valid_2 <= 1;   //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_2 <= 0;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)

counter <= 0;

// interface with decoder
cfg_ready <= 1'b0;  //Controller is ready for new data from our king decoder
end

//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 3 interface
i_p_read_3 <= 0;
i_p_write_3 <= 0;              // to tell him the cache to read or write operation
                 
i_m_readdata_valid_3 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_3 <= 1;    //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 4 interface
i_p_read_4 <= 0;
i_p_write_4 <= 0;              // to tell him the cache to read or write operation
                 
i_m_readdata_valid_4 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_4  <= 1;   //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)

                     end


         7'b0000100: begin   // Mah.cfg.ldl.img.cache.pe 



// interface with decoder
cfg_ready <= 1'b1;  //Controller is ready for new data from our king decoder


//interface with address block
to_address_block_rs1 <= rs1;
to_address_block_rs2 <= rs2;
address_block_en <= 1'b1;


//interface with data fetcher   
fun_for_data_fetcher <= 3'b000;  //for data fetcher
xs1_out <= 0;  //for data fetcher
xs2_out <= 0;  //for data fetcher


//interface with EAI controller
DATA_ADDRESS <= {18'b0, rs1, rs2};    //for EAI controller     "data_addr"
 RD_FLAG <= 0;      //for EAI controller      "rd"
 WR_FLAG <= 0;     //for EAI controller      "wr"
 REQ_DATA <= 0;   //for EAI controller from the output storage as it doesnot in the caches  "req_data"
 finish <= 0;   //for EAI controller that inducate that the total convolution is end

//for DATA_SELECTOR
 BANKID <= 0;  // "1" bank 3 and "0" bank 4
 BANK_READY <= 1; 
 PEID <= 2'b00;  //on the output pe0
 src_a_enable <= 0; // enable sending to src_a not scr_c
 src_c_enable <= 0;
 send_en <= 0; //to enable data selector to send to pe "enable sending to pe"

counter_2 <= counter_2 + 1'b1;
inducation_signal <= 1;
if (counter_2 == 5)
begin
//for DATA_SELECTOR
 BANKID <= 0;  // "1" bank 3 and "0" bank 4
 BANK_READY <= 1; 
 PEID <= 2'b00;  //on the output pe0
 src_a_enable <= 1; // enable sending to src_a not scr_c
 src_c_enable <= 0;
 send_en <= 1; //to enable data selector to send to pe "enable sending to pe"
 counter_2 <= 0;

 // interface with decoder
cfg_ready <= 1'b0;  //Controller is ready for new data from our king decoder
end

//cache 1 interface (the o_p mean input to me)
i_p_write_1 <= 0;       // to tell him the cache to read or write operation
i_p_read_1 <= 0;       // to tell him the cache to read or write operation
            
i_m_readdata_valid_1 <= 0;   //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_1 <= 1;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)

//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////    
//cache 2 interface
 i_p_read_2 <= 0;
 i_p_write_2 <= 0;           
 
 i_m_readdata_valid_2 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
 i_m_waitrequest_2 <= 0;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)

counter <= counter +1'b1;

if (counter == 3)
begin

//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////    
//cache 2 interface
 i_p_read_2 <= 1;
 i_p_write_2 <= 0;           
 
 i_m_readdata_valid_2 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
 i_m_waitrequest_2 <= 0;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)

counter <= 0;

end

//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 3 interface
i_p_read_3 <= 0;
i_p_write_3 <= 0;              // to tell him the cache to read or write operation
                 
i_m_readdata_valid_3 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_3 <= 1;    //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 4 interface
i_p_read_4 <= 0;
i_p_write_4 <= 0;              // to tell him the cache to read or write operation
                 
i_m_readdata_valid_4 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_4  <= 1;   //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


                     end


         7'b0000101: begin   // Mah.cfg.sdl.cnn.result.pe.cache2 


// interface with decoder
cfg_ready <= 1'b1;  //Controller is ready for new data from our king decoder
fun_for_data_fetcher <= 3'b100;

//interface with address block
to_address_block_rs1 <= rs1;
to_address_block_rs2 <= rs2;
address_block_en <= 1'b1;


//interface with EAI controller
DATA_ADDRESS <= {18'b0, rs1, rs2};    //for EAI controller     "data_addr"
 RD_FLAG <= 0;      //for EAI controller      "rd"
 WR_FLAG <= 0;     //for EAI controller      "wr"
 REQ_DATA <= 0;   //for EAI controller from the output storage as it doesnot in the caches  "req_data"
 finish <= 0;   //for EAI controller that inducate that the total convolution is end

counter_2 <= counter_2 + 1'b1;
inducation_signal <= 1;
if (counter_2 == 5)
begin
//for DATA_SELECTOR
 BANKID <= 1;  // "1" bank 3 and "0" bank 4
 BANK_READY <= 1; 
 PEID <= 2'b00;  //on the output pe0
 src_a_enable <= 1; // enable sending to src_a not scr_c
 src_c_enable <= 0;
 send_en <= 1; //to enable data selector to send to pe "enable sending to pe"
 counter_2 <= 0;

 // interface with decoder
cfg_ready <= 1'b0;  //Controller is ready for new data from our king decoder
end

//for DATA_SELECTOR
 BANKID <= 1;  // "1" bank 3 and "0" bank 4
 BANK_READY <= 1; 
 PEID <= 2'b00;                              //@@@@@@@@@@@@@   input data on pe0   @@@@@@@@@@@@@@@@@
 src_a_enable <= 0; // enable sending to src_a not scr_c
 src_c_enable <= 0;
 send_en <= 0; //to enable data selector to send to pe "enable sending to pe"


//cache 1 interface (the o_p mean input to me)
i_p_write_1 <= 0;       // to tell him the cache to read or write operation
i_p_read_1 <= 0;       // to tell him the cache to read or write operation
            
i_m_readdata_valid_1 <= 0;   //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_1 <= 1;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


counter <= counter +1'b1;

if (counter == 3)
begin
//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////    
//cache 2 interface
 i_p_read_3 <= 0;
 i_p_write_3 <= 1;           
 
 i_m_readdata_valid_3 <= 1;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
 i_m_waitrequest_3 <= 0;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)
counter <= 0;
end



//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 3 interface
i_p_read_2 <= 0;
i_p_write_2 <= 0;              // to tell him the cache to read or write operation
                 
i_m_readdata_valid_2 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_2 <= 1;    //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 4 interface
i_p_read_4 <= 0;
i_p_write_4 <= 0;              // to tell him the cache to read or write operation
                 
i_m_readdata_valid_4 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_4  <= 1;   //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


                     end


          7'b0000110: begin  // Mah.cfg.sdl.cnn.result.external 

       
// interface with decoder
cfg_ready <= 1'b1;  //Controller is ready for new data from our king decoder


//interface with address block
to_address_block_rs1 <= rs1;
to_address_block_rs2 <= rs2;
address_block_en <= 1'b1;

//interface with data fetcher   
fun_for_data_fetcher <= 3'b100;  //for data fetcher
xs1_out <= 1;  //for data fetcher
xs2_out <= 1;  //for data fetcher


//interface with EAI controller
DATA_ADDRESS <= {18'b0, rs1, rs2};    //for EAI controller     "data_addr"
RD_FLAG <= 1;    //for EAI controller      "rd"
WR_FLAG <= 0;    //for EAI controller      "wr"
REQ_DATA <= 0;   //for EAI controller from the output storage as it doesnot in the caches  "req_data"
finish <= 0;   //for EAI controller that inducate that the total convolution is end

//for DATA_SELECTOR
 BANKID <= 0;  // "1" bank 3 and "0" bank 4
 BANK_READY <= 0; 
 PEID <= 2'b00;                              //@@@@@@@@@@@@@   input data on pe0   @@@@@@@@@@@@@@@@@
 src_a_enable <= 0; // enable sending to src_a not scr_c
 src_c_enable <= 0;
 send_en <= 0; //to enable data selector to send to pe "enable sending to pe"


//cache 1 interface (the o_p mean input to me)
i_p_write_1 <= 0;       // to tell him the cache to read or write operation
i_p_read_1 <= 0;       // to tell him the cache to read or write operation
            
i_m_readdata_valid_1 <= 0;   //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_1 <= 1;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


counter <= counter +1'b1;

if (counter == 3)
begin
//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////    
//cache 2 interface
 i_p_read_3 <= 1;
 i_p_write_3 <= 0;           
 
 i_m_readdata_valid_2 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
 i_m_waitrequest_2 <= 0;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)
counter <= 0;
 // interface with decoder
cfg_ready <= 1'b0;  //Controller is ready for new data from our king decoder
end



//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 3 interface
i_p_read_2 <= 0;
i_p_write_2 <= 0;              // to tell him the cache to read or write operation
                 
i_m_readdata_valid_3 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_3 <= 1;    //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 4 interface
i_p_read_4 <= 0;
i_p_write_4 <= 0;              // to tell him the cache to read or write operation
                 
i_m_readdata_valid_4 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_4  <= 1;   //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)



                      end



         7'b0000111: begin   // Mah.cfg.sdl.result.external.cache (OLD DATA from e203 t0 cache)
    
    // interface with decoder
cfg_ready <= 1'b1;  //Controller is ready for new data from our king decoder


//interface with address block
to_address_block_rs1 <= rs1;
to_address_block_rs2 <= rs2;
address_block_en <= 1'b1;

//interface with data fetcher   
fun_for_data_fetcher <= 3'b011;  //for data fetcher
xs1_out <= 1;  //for data fetcher
xs2_out <= 1;  //for data fetcher


//interface with EAI controller
DATA_ADDRESS <= {18'b0, rs1, rs2};    //for EAI controller     "data_addr"
RD_FLAG <= 0;    //for EAI controller      "rd"
WR_FLAG <= 1;    //for EAI controller      "wr"
REQ_DATA <= 1;    //for EAI controller from the output storage as it doesnot in the caches  "req_data"
finish <= 0;   //for EAI controller that inducate that the total convolution is end

//for DATA_SELECTOR
 BANKID <= 0;  // "1" bank 3 and "0" bank 4
 BANK_READY <= 0; 
 PEID <= 2'b00;                              //@@@@@@@@@@@@@   input data on pe0   @@@@@@@@@@@@@@@@@
 src_a_enable <= 0; // enable sending to src_a not scr_c
 src_c_enable <= 0;
 send_en <= 0; //to enable data selector to send to pe "enable sending to pe"



//cache 1 interface (the o_p mean input to me)
i_p_write_1 <= 0;       // to tell him the cache to read or write operation
i_p_read_1 <= 0;       // to tell him the cache to read or write operation
            
i_m_readdata_valid_1 <= 0;   //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_1 <= 1;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////    
//cache 2 interface
 i_p_read_2 <= 0;
 i_p_write_2 <= 0;           
 
 i_m_readdata_valid_2 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
 i_m_waitrequest_2 <= 1;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)



//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 3 interface
i_p_read_3 <= 0;
i_p_write_3 <= 0;              // to tell him the cache to read or write operation
                 
i_m_readdata_valid_3 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_3 <= 1;    //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


counter <= counter +1'b1;

if (counter == 3)
begin
//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 4 interface
i_p_read_4 <= 0;
i_p_write_4 <= 1;              // to tell him the cache to read or write operation
                 
i_m_readdata_valid_4 <= 1;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_4  <= 0;   //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)
counter <= 0;
 // interface with decoder
cfg_ready <= 1'b0;  //Controller is ready for new data from our king decoder
end
i_p_read_4 <= 0;
if(i_m_readdata_valid_4)
i_p_write_4 <= 0;     

                     end


         7'b0001000: begin  // Mah.cfg.ldo.ke.coe.pe 
   

// interface with decoder
cfg_ready <= 1'b1;  //Controller is ready for new data from our king decoder


//interface with address block
to_address_block_rs1 <= rs1;
to_address_block_rs2 <= rs2;
address_block_en <= 1'b1;


//interface with EAI controller
DATA_ADDRESS <= {18'b0, rs1, rs2};    //for EAI controller     "data_addr"
RD_FLAG <= 0;    //for EAI controller      "rd"
WR_FLAG <= 0;    //for EAI controller      "wr"
REQ_DATA <= 0;    //for EAI controller from the output storage as it doesnot in the caches  "req_data"
finish <= 0;   //for EAI controller that inducate that the total convolution is end

//for DATA_SELECTOR
 BANKID <= 0;  // "1" bank 3 and "0" bank 4
 BANK_READY <= 0; 
 PEID <= 2'b00;                              //@@@@@@@@@@@@@   input data on pe0   @@@@@@@@@@@@@@@@@
 src_a_enable <= 0; // enable sending to src_a not scr_c
 src_c_enable <= 0;
 send_en <= 0; //to enable data selector to send to pe "enable sending to pe"

counter <= counter +1'b1;

if (counter == 3)
begin
//cache 1 interface (the o_p mean input to me)
i_p_write_1 <= 0;       // to tell him the cache to read or write operation
i_p_read_1 <= 1;       // to tell him the cache to read or write operation
            
i_m_readdata_valid_1 <= 0;   //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_1 <= 0;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)
counter <= 0;

// interface with decoder
cfg_ready <= 1'b0;  //Controller is ready for new data from our king decoder
end

//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////    
//cache 2 interface
 i_p_read_2 <= 0;
 i_p_write_2 <= 0;           
 
 i_m_readdata_valid_2 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
 i_m_waitrequest_2 <= 1;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)



//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 3 interface
i_p_read_3 <= 0;
i_p_write_3 <= 0;              // to tell him the cache to read or write operation
                 
i_m_readdata_valid_3 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_3 <= 1;    //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 4 interface
i_p_read_4 <= 0;
i_p_write_4 <= 0;              // to tell him the cache to read or write operation
                 
i_m_readdata_valid_4 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_4  <= 1;   //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)



                     end

                
         7'b0001001: begin // Mah.cfg.sdl.old.cache.external (from cache to e203)


     // interface with decoder
cfg_ready <= 1'b1;  //Controller is ready for new data from our king decoder


//interface with address block
to_address_block_rs1 <= rs1;
to_address_block_rs2 <= rs2;
address_block_en <= 1'b1;

//interface with data fetcher   
fun_for_data_fetcher <= 3'b010;  //for data fetcher
xs1_out <= 1;  //for data fetcher
xs2_out <= 1;  //for data fetcher


//interface with EAI controller
DATA_ADDRESS <= {18'b0, rs1, rs2};    //for EAI controller     "data_addr"
RD_FLAG <= 1;    //for EAI controller      "rd"
WR_FLAG <= 0;    //for EAI controller      "wr"
REQ_DATA <= 1;    //for EAI controller from the output storage as it doesnot in the caches  "req_data"
finish <= 0;   //for EAI controller that inducate that the total convolution is end

//for DATA_SELECTOR
 BANKID <= 0;  // "1" bank 3 and "0" bank 4
 BANK_READY <= 0; 
 PEID <= 2'b00;                              //@@@@@@@@@@@@@   input data on pe0   @@@@@@@@@@@@@@@@@
 src_a_enable <= 0; // enable sending to src_a not scr_c
 src_c_enable <= 0;
 send_en <= 0; //to enable data selector to send to pe "enable sending to pe"


//cache 1 interface (the o_p mean input to me)
i_p_write_1 <= 0;       // to tell him the cache to read or write operation
i_p_read_1 <= 0;       // to tell him the cache to read or write operation
            
i_m_readdata_valid_1 <= 0;   //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_1 <= 1;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////    
//cache 2 interface
 i_p_read_2 <= 0;
 i_p_write_2 <= 0;           
 
 i_m_readdata_valid_2 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
 i_m_waitrequest_2 <= 1;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)



//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 3 interface
i_p_read_3 <= 0;
i_p_write_3 <= 0;              // to tell him the cache to read or write operation
                 
i_m_readdata_valid_3 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_3 <= 1;    //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


counter <= counter +1'b1;

if (counter == 3)
begin
//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 4 interface
i_p_read_4 <= 1;
i_p_write_4 <= 0;              // to tell him the cache to read or write operation
                 
i_m_readdata_valid_4 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_4  <= 0;   //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)

counter <= 0;
// interface with decoder
cfg_ready <= 1'b0;  //Controller is ready for new data from our king decoder
end

                     end


         7'b0001010: begin // Mah.cfg.ldo.old.cache.pe 

   
// interface with decoder
cfg_ready <= 1'b1;  //Controller is ready for new data from our king decoder


//interface with address block
to_address_block_rs1 <= rs1;
to_address_block_rs2 <= rs2;
address_block_en <= 1'b1;


//interface with EAI controller
DATA_ADDRESS <= {18'b0, rs1, rs2};    //for EAI controller     "data_addr"
RD_FLAG <= 0;    //for EAI controller      "rd"
WR_FLAG <= 0;    //for EAI controller      "wr"
REQ_DATA <= 0;    //for EAI controller from the output storage as it doesnot in the caches  "req_data"
finish <= 0;   //for EAI controller that inducate that the total convolution is end


counter_2 <= counter_2 + 1'b1;
inducation_signal <= 0;
if (counter_2 == 5)
begin
//for DATA_SELECTOR
 BANKID <= 0;  // "1" bank 3 and "0" bank 4
 BANK_READY <= 1;
 inducation_signal <= 1; 
 PEID <= 2'b00;  //on the output pe0
 src_a_enable <= 0; // enable sending to src_a not scr_c
 src_c_enable <= 1;
 send_en <= 1;     //to enable data selector to send to pe "enable sending to pe"
counter_2 <= 0;
// interface with decoder
cfg_ready <= 1'b0;  //Controller is ready for new data from our king decoder
end

//for DATA_SELECTOR
 BANKID <= 0;  // "1" bank 3 and "0" bank 4
 BANK_READY <= 1; 
 PEID <= 2'b00;                              //@@@@@@@@@@@@@   input data on pe0   @@@@@@@@@@@@@@@@@
 src_a_enable <= 0;
   if(inducation_signal)begin // enable sending to src_a not scr_c
 src_c_enable <= 0;
 send_en <= 0;end //to enable data selector to send to pe "enable sending to pe"


//cache 1 interface (the o_p mean input to me)
i_p_write_1 <= 0;       // to tell him the cache to read or write operation
i_p_read_1 <= 0;       // to tell him the cache to read or write operation
            
i_m_readdata_valid_1 <= 0;   //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_1 <= 1;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////    
//cache 2 interface
 i_p_read_2 <= 0;
 i_p_write_2 <= 0;           
 
 i_m_readdata_valid_2 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
 i_m_waitrequest_2 <= 1;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)



//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 3 interface
i_p_read_3 <= 0;
i_p_write_3 <= 0;              // to tell him the cache to read or write operation
                 
i_m_readdata_valid_3 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_3 <= 1;    //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


counter <= counter +1'b1;

if (counter == 3)
begin
//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 4 interface
i_p_read_4 <= 1;
i_p_write_4 <= 0;              // to tell him the cache to read or write operation
                 
i_m_readdata_valid_4 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_4  <= 0;   //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)

counter <= 0;
end

i_p_read_4 <= 0;
i_p_write_4 <= 0;  


                     end

         7'b0001011: begin // Mah.cfg.sdl.old.pe.cache 

  
// interface with decoder
cfg_ready <= 1'b1;  //Controller is ready for new data from our king decoder


//interface with address block
to_address_block_rs1 <= rs1;
to_address_block_rs2 <= rs2;
address_block_en <= 1'b1;


//interface with EAI controller
DATA_ADDRESS <= {18'b0, rs1, rs2};    //for EAI controller     "data_addr"
RD_FLAG <= 0;    //for EAI controller      "rd"
WR_FLAG <= 0;    //for EAI controller      "wr"
REQ_DATA <= 0;    //for EAI controller from the output storage as it doesnot in the caches  "req_data"
finish <= 0;   //for EAI controller that inducate that the total convolution is end


counter_2 <= counter_2 + 1'b1;
inducation_signal <= 1;
if (counter_2 == 5)
begin
//for DATA_SELECTOR
 BANKID <= 0;  // "1" bank 3 and "0" bank 4
 BANK_READY <= 1; 
 PEID <= 2'b00;  //on the output pe0
 src_a_enable <= 0; // enable sending to src_a not scr_c
 src_c_enable <= 1;
 send_en <= 1; //to enable data selector to send to pe "enable sending to pe"
counter_2 <= 0;
// interface with decoder
cfg_ready <= 1'b0;  //Controller is ready for new data from our king decoder
end


//for DATA_SELECTOR
 BANKID <= 0;  // "1" bank 3 and "0" bank 4
 BANK_READY <= 1; 
 PEID <= 2'b00;                              //@@@@@@@@@@@@@   input data on pe0   @@@@@@@@@@@@@@@@@
 src_a_enable <= 0; // enable sending to src_a not scr_c
 src_c_enable <= 0;
 send_en <= 0; //to enable data selector to send to pe "enable sending to pe"

//cache 1 interface (the o_p mean input to me)
i_p_write_1 <= 0;       // to tell him the cache to read or write operation
i_p_read_1 <= 0;       // to tell him the cache to read or write operation
            
i_m_readdata_valid_1 <= 0;   //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_1 <= 1;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)


//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////    
//cache 2 interface
 i_p_read_2 <= 0;
 i_p_write_2 <= 0;           
 
 i_m_readdata_valid_2 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
 i_m_waitrequest_2 <= 1;     //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)



//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 3 interface
i_p_read_3 <= 0;
i_p_write_3 <= 0;              // to tell him the cache to read or write operation
                 
i_m_readdata_valid_3 <= 0;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_3 <= 1;    //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)

counter <= counter +1'b1;

if (counter == 3)
begin
//////////////////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////
//cache 4 interface
i_p_read_4 <= 0;
i_p_write_4 <= 1;              // to tell him the cache to read or write operation
                 
i_m_readdata_valid_4 <= 1;    //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_4  <= 0;   //busy untill the signal is zero (e3ml mn banha w msh5ol l7d ma ....... اخليهالك ب 0)
counter <= 0;
end
if(i_m_readdata_valid_4)begin
i_p_read_4 <= 0;
i_p_write_4 <= 0;            end  // to tell him the cache to read or write operation
                 
                       //tell the cache that the data fetcher is ready to send data or recieve data from it (cache is fadya (enable cache to send or recieve))
i_m_waitrequest_4  <= 0;

  
                     end


         7'b0001100: begin // Mah.wm 

                    crossbar_sel <= rs1; // Crossbar path
                    pe_mode      <= rs2; // PE modes

                     end

         7'b0001101: begin // Mah.sc // it should keep the instruction
              
                   start_cal <= 5'b11101;
                   if(finish_pe)
                   begin
                   start_cal <= 5'b00000;
                   finish <= 1;
                   end

                     end

//////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@////////////////////////////////////////

 /*     
         7'b0001110: begin 
             

                     end


         7'b0001111: begin 

                     end



         7'b0010000: begin 



                     end


        7'b0010000: begin 

    

                    end


        7'b0010001: begin 


                     end


        7'b0010010: begin 


                    end


        7'b0010011: begin end
        7'b0010100: begin end
        7'b0010101: begin end
        7'b0010110: begin end
        7'b0010111: begin end
        7'b0011000: begin end
        7'b0011001: begin end
        7'b0011010: begin end
        7'b0011011: begin end
        7'b0011100: begin end
        7'b0011101: begin end
        7'b0011110: begin end
        7'b0011111: begin end
        7'b0100000: begin end
        7'b0100001: begin end
        7'b0100010: begin end
        7'b0100011: begin end
        7'b0100100: begin end
        7'b0100101: begin end
        7'b0100110: begin end
        7'b0100111: begin end
        7'b0101000: begin end
        7'b0101001: begin end
        7'b0101010: begin end
        7'b0101011: begin end
        7'b0101100: begin end
        7'b0101101: begin end
        7'b0101110: begin end
        7'b0101111: begin end
        7'b0110000: begin end
        7'b0110001: begin end
        7'b0110010: begin end
        7'b0110011: begin end
        7'b0110100: begin end
        7'b0110101: begin end
        7'b0110110: begin end
        7'b0110111: begin end
        7'b0111000: begin end
        7'b0111001: begin end
        7'b0111010: begin end
        7'b0111011: begin end
        7'b0111100: begin end
        7'b0111101: begin end
        7'b0111110: begin end
        7'b0111111: begin end
        7'b1000000: begin end
        7'b1000001: begin end
        7'b1000010: begin end
        7'b1000011: begin end
        7'b1000100: begin end
        7'b1000101: begin end
        7'b1000110: begin end
        7'b1000111: begin end
        7'b1001000: begin end
        7'b1001001: begin end
        7'b1001010: begin end
        7'b1001011: begin end
        7'b1001100: begin end
        7'b1001101: begin end
        7'b1001110: begin end
        7'b1001111: begin end
        7'b1010000: begin end
        7'b1010001: begin end
        7'b1010010: begin end
        7'b1010011: begin end
        7'b1010100: begin end
        7'b1010101: begin end
        7'b1010110: begin end
        7'b1010111: begin end
        7'b1011000: begin end
        7'b1011001: begin end
        7'b1011010: begin end
        7'b1011011: begin end
        7'b1011100: begin end
        7'b1011101: begin end
        7'b1011110: begin end
        7'b1011111: begin end
        7'b1100000: begin end
        7'b1100001: begin end
        7'b1100010: begin end
        7'b1100011: begin end
        7'b1100100: begin end
        7'b1100101: begin end
        7'b1100110: begin end
        7'b1100111: begin end
        7'b1101000: begin end
        7'b1101001: begin end
        7'b1101010: begin end
        7'b1101011: begin end
        7'b1101100: begin end
        7'b1101101: begin end
        7'b1101110: begin end
        7'b1101111: begin end
        7'b1110000: begin end
        7'b1110001: begin end
        7'b1110010: begin end
        7'b1110011: begin end
        7'b1110100: begin end
        7'b1110101: begin end
        7'b1110110: begin end
        7'b1110111: begin end
        7'b1111000: begin end
        7'b1111001: begin end
        7'b1111010: begin end
        7'b1111011: begin end
        7'b1111100: begin end
        7'b1111101: begin end
        7'b1111110: begin end
        7'b1111111: begin end

*/
                endcase


                cfg_ready <= 0;  // we are busy please king donot send other instructions
            end

            // Reset cfg_ready after operation
            else
                cfg_ready <= 1; //we are ready to recieve another instruction
            end

    end

endmodule