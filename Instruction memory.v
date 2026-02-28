module instruction_memory (
    input clk,
    input rst,
    output reg [31:0] instruction,
    input local_rst_inst_mem
);

   parameter CLOCK_CYCLE=21;
   parameter CLOCK_CYCLE1=3;
   parameter CLOCK_CYCLE2=15;
   wire [4:0]clock=(instruction[31:25]==7'b0000110)?CLOCK_CYCLE1:(instruction[31:25]==7'b0000011||instruction[31:25]==7'b0000111
    ||instruction[31:25]==7'b0000010||instruction[31:25]==7'b1000000||instruction[31:25]==7'b0001100)?CLOCK_CYCLE2:CLOCK_CYCLE; 
    reg [31:0]mem[4024:0]; 
    integer i;
    integer j;
    integer w;
    integer o;
    integer q;
    integer s;
    reg[31:0] cycle_count; // Needs to count up to 30
    reg[31:0] instr_count;  // counter for instruction memory
    
    reg [8:0]temp1;
 
   //Initialize instruction memory
    // initial begin
    //     for (i = 0; i < 256; i = i + 1)
    //         mem[i] = {7'b0000111 ,i[9:0] , 15'b1_1_1_00011_0000011}; // index=35  // store old data in cache
    // end

    // initial begin
    //     for (o = 256; o < 512; o = o + 1) begin
    //         mem[o] = {7'b0000011,o[9:0]-10'd256 , 15'b1_1_1_00011_0000011}; // index=35 //store image in cache
             
    //     end
    // end

     initial begin
         
        for (j = 512; j < 519; j = j + 1)
            mem[j] = { 7'b0000010 ,j[9:0]-10'd512 , 15'b1_1_1_00011_0000011};  // index=35 // store filter

        end     
   // initial begin
   // for(w=10;w<574;w=w+1)begin
   //      mem[w]={7'b0001101 ,w[9:0]-10'd10 ,15'b1_1_1_00011_0000011};  //sc
   // end
   // mem[9]={ 7'b0001100 ,10'b00001_00001 , 15'b1_1_1_00000_0000011};

   //  end
    // initial begin
         
    //     for (j = 1420; j < 1427; j = j + 1)
    //         mem[j] = { 7'b0000010 ,j[9:0]-10'd396 , 15'b1_1_1_00011_0000011};

    //          end

initial begin
   for(w=575;w<1137;w=w+1)begin
        mem[w]={7'b0001101 ,w[9:0]-10'd575 ,15'b1_1_1_00011_0000011};  //sc
   end
   mem[574]={ 7'b0001100 ,10'b00001_00001 , 15'b1_1_1_10000_0000011};

 end
//     initial begin
//    for(w=1138;w<1699;w=w+1)begin
//         mem[w]={7'b0001101 ,w[9:0]-10'd114 ,15'b1_1_1_00011_0000011};  //sc
//    end
//    mem[1137]={ 7'b0001100 ,10'b01101_01001 , 15'b1_1_1_10000_0000011};

//     end
//     initial begin
//    for(w=1696;w<2261;w=w+1)begin
//         mem[w]={7'b0001101 ,w[9:0]-10'd672 ,15'b1_1_1_00011_0000011};  //sc
//    end
//    mem[1695]={ 7'b0001100 ,10'b01101_01001 , 15'b1_1_1_10000_0000011};

//     end
//     initial begin
//    for(w=2262;w<2823;w=w+1)begin
//         mem[w]={7'b0001101 ,w[9:0]-10'd214 ,15'b1_1_1_00011_0000011};  //sc
//    end
//    mem[2261]={ 7'b0001100 ,10'b01101_01001 , 15'b1_1_1_10000_0000011};

//     end
// initial begin
//    for(w=2824;w<3385;w=w+1)begin
//         mem[w]={7'b0001101 ,w[9:0]-10'd776 ,15'b1_1_1_00011_0000011};  //sc
//    end
//    mem[2823]={ 7'b0001100 ,10'b01101_01001 , 15'b1_1_1_10000_0000011};

//     end

   //  initial begin
   // for(w=3386;w<4286;w=w+1)begin
   //      mem[w]={7'b0001101 ,w[9:0]-10'd314 ,15'b1_1_1_00011_0000011};  //sc
   // end
   // mem[3385]={ 7'b0001100 ,10'b01101_01001 , 15'b1_1_1_10000_0000011};

  //  end
 // Conv_en <= pe_mode[0];
 //         adder_en <= pe_mode[1];
 //          pool_en <= pe_mode[2];
 //   relu_en <= pe_mode[3];

   // initial begin
   // for(q=1125;q<2025;q=q+1)
   //      mem[q]={7'b1000000 ,q[9:0]-10'd101 , 15'b1_1_1_00011_0000011};
   // mem[1124]={ 7'b0001100 ,10'b0000_000001, 15'b1_1_1_00000_0000011};
   //  end

 // initial begin
 //   for(q=2026;q<2926;q=q+1)
 //        mem[q]={7'b0001101 ,q[9:0]-10'd1002 , 15'b1_1_1_00011_0000011};
 //   mem[2025]={ 7'b0001100 ,10'b1010000010, 15'b1_1_1_00000_0000011};
 //    end

 // initial begin
 //   for(q=2927;q<3500;q=q+1)
 //        mem[q]={7'b1000000 ,q[9:0]-10'd427 , 15'b1_1_1_00011_0000011};
 //   mem[2926]={ 7'b0001100 ,10'b0000000010, 15'b1_1_1_00000_0000011};
 //    end

   //  initial begin
   // for(s=2025;s<2926;s=s+1)
   //      mem[s]={7'b0000110 ,s[9:0]-10'd1001 , 15'b1_1_1_00011_0000011};
   // end

    always @(posedge clk ) begin
        if (~rst || !local_rst_inst_mem) begin
            instr_count <= 0;
            cycle_count <= 0;
            instruction <= mem[0];
        end else begin
            if (cycle_count < clock) begin 
                cycle_count <= cycle_count + 1;
            end else begin
                cycle_count <= 0;
                instr_count <= instr_count + 1;
                if (instr_count == 4096)
                 instr_count <= 0;
                instruction <= mem[instr_count+1];
            end
        end
    end

endmodule
