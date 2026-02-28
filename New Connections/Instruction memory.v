module instruction_memory (
    input clk,
    input rst,
    output reg [31:0] instruction
);

   parameter CLOCK_CYCLE=25; 
    reg [31:0]mem[1023:0]; 
    integer i;
    integer j;
    integer w;
    integer o;
    reg[31:0] cycle_count; // Needs to count up to 30
    reg[31:0] instr_count;  // counter for instruction memory
    
    reg [8:0]temp1;

    // Initialize instruction memory
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            mem[i] = {7'b0000111 ,i[9:0] , 15'b1_1_1_00011_0000011};// index=35
             
        end
    end

    initial begin
        for (o = 256; o < 512; o = o + 1) begin
            mem[o] = {7'b0000011,o[9:0]-10'd256 , 15'b1_1_1_00011_0000011};// index=35
             
        end
    end

    initial begin
         
        for (j = 512; j < 519; j = j + 1) begin
            mem[j] = { 7'b0000010 ,j[9:0]-10'd512 , 15'b1_1_1_00011_0000011};  // index=35
        end

        end     
        
   initial begin
   temp1=0;
   for(w=520;w<1024;w=w+1)begin
        mem[w]={temp1[8:6],4'b1101 ,10'b0110100111 ,temp1[5], 2'b11,temp1[4:2],7'b0000000,temp1[1:0]};
        if(w<800)
       temp1=temp1+9'd1;
   end
   mem[519]={ 7'b0001100 ,10'b0111101000 , 15'b1_1_1_00000_0000011};
    end
    always @(posedge clk ) begin
        if (~rst) begin
            instr_count <= 0;
            cycle_count <= 0;
            instruction <= mem[0];
        end else begin
            if (cycle_count < CLOCK_CYCLE) begin // Hold for 25 cycles
                cycle_count <= cycle_count + 1;
            end else begin
                cycle_count <= 0;
                instr_count <= instr_count + 1;
                if (instr_count == 1022)
                 instr_count <= 0;
                instruction <= mem[instr_count+1];
            end
        end
    end

endmodule
