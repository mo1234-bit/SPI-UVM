/////////////////////////////////@CopyRights/////////////////////////////////////////////////
// Company: No sponsorship
// Team: Mohamed Gamal & Ahmed Reda & Abdallah Sabah & Abdallah sleem & Mohamed Ahmed & Ibrahim Hamdy & Beshoy Maher & Mostafa Osman
// Supervisior Dr: Sherif Fathy
// Team Leader: Mohamed Ahmed Ibrahim
// Technical Head : Mohamed Gamal & Ahmed Reda 
// Human Resource : Beshoy Magdy  
// Check Date: 19/2/2025 11:44:49 PM
// Design Name:CNN unit
// Module Name: Simble ram block
// Project Name: Graduation project
//Designer: Ibrahim Hamdy & Beshoy Maher & Mohamed Gamal
/////////////////////////////////@CopyRights/////////////////////////////////////////////////

module simple_ram

  #(parameter width     = 1,      //8
    parameter widthad   = 1       //9
   )

   (
    input 		   clk,
    
    input [widthad-1:0]    wraddress,
    input 		   wren,
    input [width-1:0] 	   data,
    
    input [widthad-1:0]    rdaddress,
    output reg [width-1:0] q
    );


reg [width-1:0] mem [(2**widthad)-1:0];    //width of word 8 bits and depth = 512

always @(posedge clk) begin
    if(wren) mem[wraddress] <= data;
    
    q <= mem[rdaddress];
end


endmodule
