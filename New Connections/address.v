/////////////////////////////////@CopyRights/////////////////////////////////////////////////
// Company: No sponsorship
// Team: Mohamed Gamal & Ahmed Reda & Abdallah Sabah & Abdallah sleem & Mohamed Ahmed & Ibrahim Hamdy & Beshoy Maher & Mostafa Osman
// Supervisior Dr: Sherif Fathy
// Team Leader: Mohamed Ahmed Ibrahim
// Technical Head : Mohamed Gamal & Ahmed Reda 
// Human Resource : Beshoy Magdy  
// Check Date: 19/2/2025 11:44:49 PM
// Design Name:CNN unit
// Module Name: Address block
// Project Name: Graduation project
// Designer: Mohamed Gamal
/////////////////////////////////@CopyRights/////////////////////////////////////////////////
module address (
    input wire wr,
    input wire clk,    // Clock
    input wire rst_n,  //synchronous reset active low
    input wire valid,  // when it come it activate the addrees block (no need for handcheck)
    input wire [4:0]rs1,//base address is the  starting point or reference location in memory
    input wire [4:0]rs2,// An offset is a value that indicates how far you need to move from the base address.
    output wire [24:0]cache_address_i,
    output wire[3:0]byte_en
);
wire [9:0]rs1_rs2;
assign rs1_rs2={rs2,rs1};
reg [31:0]address;//BaseAddress+Offset
reg[31:0]mem[512:0];
always @(posedge clk) begin
    if (!rst_n) begin
        address<=0;
    end
    else if (valid) begin
        address<=mem[rs1_rs2];
    end
end
assign cache_address_i=(wr)?{address[24:2],2'b11}:address[24:0];
assign byte_en=address[6:3];

initial begin
    mem[0]   = 32'h1000_0000;
    mem[1]   = 32'h1024_0004;
    mem[2]   = 32'h1048_0008;
    mem[3]   = 32'h106C_000C;
    mem[4]   = 32'h1090_0010;
    mem[5]   = 32'h10B4_0020;
    mem[6]   = 32'h10D8_0030;
    mem[7]   = 32'h10FC_0040;
    mem[8]   = 32'h1120_0050;
    mem[9]   = 32'h1144_0060;
    mem[10]  = 32'h1168_0070;
    mem[11]  = 32'h118C_0080;
    mem[12]  = 32'h11B0_0090;
    mem[13]  = 32'h11D4_00A0;
    mem[14]  = 32'h11F8_00B0;
    mem[15]  = 32'h121C_00C0;
    mem[16]  = 32'h1240_00D0;
    mem[17]  = 32'h1264_00E0;
    mem[18]  = 32'h1288_00F0;
    mem[19]  = 32'h12AC_0100;
    mem[20]  = 32'h12D0_0110;
    mem[21]  = 32'h12F4_0120;
    mem[22]  = 32'h1318_0130;
    mem[23]  = 32'h133C_0140;
    mem[24]  = 32'h1360_0150;
    mem[25]  = 32'h1384_0160;
    mem[26]  = 32'h13A8_0170;
    mem[27]  = 32'h13CC_0180;
    mem[28]  = 32'h13F0_0190;
    mem[29]  = 32'h1414_01A0;
    mem[30]  = 32'h1438_01B0;
    mem[31]  = 32'h145C_01C0;
    mem[32]  = 32'h1480_01D0;
    mem[33]  = 32'h14A4_01E0;
    mem[34]  = 32'h14C8_01F0;
    mem[35]  = 32'h14EC_0200;
    mem[36]  = 32'h1510_0210;
    mem[37]  = 32'h1534_0220;
    mem[38]  = 32'h1558_0230;
    mem[39]  = 32'h157C_0240;
    mem[40]  = 32'h15A0_0250;
    mem[41]  = 32'h15C4_0260;
    mem[42]  = 32'h15E8_0270;
    mem[43]  = 32'h160C_0280;
    mem[44]  = 32'h1630_0290;
    mem[45]  = 32'h1654_02A0;
    mem[46]  = 32'h1678_02B0;
    mem[47]  = 32'h169C_02C0;
    mem[48]  = 32'h16C0_02D0;
    mem[49]  = 32'h16E4_02E0;
    mem[50]  = 32'h1708_02F0;
    mem[51]  = 32'h172C_0300;
    mem[52]  = 32'h1750_0310;
    mem[53]  = 32'h1774_0320;
    mem[54]  = 32'h1798_0330;
    mem[55]  = 32'h17BC_0340;
    mem[56]  = 32'h17E0_0350;
    mem[57]  = 32'h1804_0360;
    mem[58]  = 32'h1828_0370;
    mem[59]  = 32'h184C_0380;
    mem[60]  = 32'h1870_0390;
    mem[61]  = 32'h1894_03A0;
    mem[62]  = 32'h18B8_03B0;
    mem[63]  = 32'h18DC_03C0;
    mem[64]  = 32'h1900_03D0;
    mem[65]  = 32'h1924_03E0;
    mem[66]  = 32'h1948_03F0;
    mem[67]  = 32'h196C_0400;
    mem[68]  = 32'h1990_0410;
    mem[69]  = 32'h19B4_0420;
    mem[70]  = 32'h19D8_0430;
    mem[71]  = 32'h19FC_0440;
    mem[72]  = 32'h1A20_0450;
    mem[73]  = 32'h1A44_0460;
    mem[74]  = 32'h1A68_0470;
    mem[75]  = 32'h1A8C_0480;
    mem[76]  = 32'h1AB0_0490;
    mem[77]  = 32'h1AD4_04A0;
    mem[78]  = 32'h1AF8_04B0;
    mem[79]  = 32'h1B1C_04C0;
    mem[80]  = 32'h1B40_04D0;
    mem[81]  = 32'h1B64_04E0;
    mem[82]  = 32'h1B88_04F0;
    mem[83]  = 32'h1BAC_0500;
    mem[84]  = 32'h1BD0_0510;
    mem[85]  = 32'h1BF4_0520;
    mem[86]  = 32'h1C18_0530;
    mem[87]  = 32'h1C3C_0540;
    mem[88]  = 32'h1C60_0550;
    mem[89]  = 32'h1C84_0560;
    mem[90]  = 32'h1CA8_0570;
    mem[91]  = 32'h1CCC_0580;
    mem[92]  = 32'h1CF0_0590;
    mem[93]  = 32'h1D14_05A0;
    mem[94]  = 32'h1D38_05B0;
    mem[95]  = 32'h1D5C_05C0;
    mem[96]  = 32'h1DA4_05E0;
    mem[97]  = 32'h1DC8_05F0;
    mem[98]  = 32'h1DEC_0600;
    mem[99]  = 32'h1E10_0610;
    mem[100] = 32'h1E34_0620;
    mem[101] = 32'h1E58_0630;
    mem[102] = 32'h1E7C_0640;
    mem[103] = 32'h1EA0_0650;
    mem[104] = 32'h1EC4_0660;
    mem[105] = 32'h1EE8_0670;
    mem[106] = 32'h1F0C_0680;
    mem[107] = 32'h1F30_0690;
    mem[108] = 32'h1F54_06A0;
    mem[109] = 32'h1F78_06B0;
    mem[110] = 32'h1F9C_06C0;
    mem[111] = 32'h1FC0_06D0;
    mem[112] = 32'h1FE4_06E0;
    mem[113] = 32'h2008_06F0;
    mem[114] = 32'h202C_0700;
    mem[115] = 32'h2050_0710;
    mem[116] = 32'h2074_0720;
    mem[117] = 32'h2098_0730;
    mem[118] = 32'h20BC_0740;
    mem[119] = 32'h20E0_0750;
    mem[120] = 32'h2104_0760;
    mem[121] = 32'h2128_0770;
    mem[122] = 32'h214C_0780;
    mem[123] = 32'h2170_0790;
    mem[124] = 32'h2194_07A0;
    mem[125] = 32'h21B8_07B0;
    mem[126] = 32'h21DC_07C0;
    mem[127] = 32'h2200_07D0;
    mem[128] = 32'h2224_07E0;
    mem[129] = 32'h2248_07F0;
    mem[130] = 32'h314A_1EBC;
    mem[131] = 32'h3A9D_2FCD;
    mem[132] = 32'h45C3_3AD8;
    mem[133] = 32'h5E17_4EC9;
    mem[134] = 32'h6FA5_5FDC;
    mem[135] = 32'h7B3F_6AEB;
    mem[136] = 32'h89D4_01be;
    mem[137] = 32'h92B8_AAF5;
    mem[138] = 32'hA4D9_ca76;
    mem[139] = 32'hB7EF_afec;
    mem[140] = 32'hC8AD_AEB9;
    mem[141] = 32'hD4A9_CBED;
    mem[142] = 32'hE9FC_DA99;
    mem[143] = 32'hF5AB_ECFF;
    mem[144] = 32'h0123_0ACD;
    mem[145] = 32'h028F_19DE;
    mem[146] = 32'h03B4_2ABF;
    mem[147] = 32'h04C9_3FC8;
    mem[148] = 32'h051D_FFFF;
    mem[149] = 32'h065F_ABCD;
    mem[150] = 32'h0783_6BFD;
    mem[151] = 32'h08AA_AE9F;
    mem[152] = 32'h09B1_8F27;
    mem[153] = 32'h0AFC_9E88;
    mem[154] = 32'h0BDC_A9E9;
    mem[155] = 32'h0CC9_EB7A;
    mem[156] = 32'h0DE3_C1E4;
    mem[157] = 32'h0E9F_AAAA;
    mem[158] = 32'h0F88_E8BC;
    mem[159] = 32'h109A_ABAB;
    mem[160] = 32'h11CD_BBBB;
    mem[161] = 32'h12EF_BCBC;
    mem[162] = 32'h14B3_28AD;
    mem[163] = 32'h15C7_3BFA;
    mem[164] = 32'h169E_4A7B;
    mem[165] = 32'h17B8_CCCC;
    mem[166] = 32'h18EF_CDCD;
    mem[167] = 32'h19A3_7D2E;
    mem[168] = 32'h1ACF_8EB7;
    mem[169] = 32'h1BDA_DDDD;
    mem[170] = 32'h1CB7_DEDE;
    mem[171] = 32'h1DF4_EDED;
    mem[172] = 32'h1EAB_CBCB;
    mem[173] = 32'h1FCE_FDFD;
    mem[174] = 32'h20B3_EB4C;
    mem[175] = 32'h21DE_DCDC;
    mem[176] = 32'h22AC_01DA;
    mem[177] = 32'h23DA_FAFA;
    mem[178] = 32'h24FA_23E9;
    mem[179] = 32'h25AB_7777;
    mem[180] = 32'h26C1_4B27;
    mem[181] = 32'h27D5_5C8A;
    mem[182] = 32'h28E7_8888;
    mem[183] = 32'h29FA_9999;
    mem[184] = 32'h2A9C_6666;
    mem[185] = 32'h2BBE_9FA5;
    mem[186] = 32'h2CD4_B086;
    mem[187] = 32'h2DE5_9696;
    mem[188] = 32'h2EFC_9898;
    mem[189] = 32'h2FAB_E3D4;
    mem[190] = 32'h30C5_F4E7;
    mem[191] = 32'h31DA_05AB;
    mem[192] = 32'h32AE_168D;
    mem[193] = 32'h33DC_27BF;
    mem[194] = 32'h34F8_38EC;
    mem[195] = 32'h35C9_49AB;
    mem[196] = 32'h36E2_4444;
    mem[197] = 32'h37F3_8FBB;
    mem[198] = 32'h389A_7CD5;
    mem[199] = 32'h39BC_8DAE;
    mem[200] = 32'h3ACD_5555;
    mem[201] = 32'h3BDC_6767;
    mem[202] = 32'h3CF3_C0AB;
    mem[203] = 32'h3DAA_11EE;
    mem[204] = 32'h3EFC_E2B9;
    mem[205] = 32'h3FAC_A8E8;
    mem[206] = 32'h40B2_9E98;
    mem[207] = 32'h41C4_7878;
    mem[208] = 32'h42FA_22EE;
    mem[209] = 32'h43AC_379F;
    mem[210] = 32'h44D1_48DC;
    mem[211] = 32'h45B8_59C4;
    mem[212] = 32'h46FA_6A3E;
    mem[213] = 32'h47AC_7B29;
    mem[214] = 32'h48C3_99FF;
    mem[215] = 32'h49DA_FEFE;
    mem[216] = 32'h4AFC_AFEB;
    mem[217] = 32'h4BDE_C1FA;
    mem[218] = 32'h4CFA_AFAF;
    mem[219] = 32'h4DA9_E7C4;
    mem[220] = 32'h4EB3_FAC9;
    mem[221] = 32'h4FCC_0BDC;
    mem[222] = 32'h50FA_1C9B;
    mem[223] = 32'h51AC_ECEC;
    mem[224] = 32'h52C3_3F87;
    mem[225] = 32'h57D7_DBDB;
    mem[226] = 32'h54F8_5C7B;
    mem[227] = 32'h5345_2358;
    mem[228] = 32'h4678_8568;
    mem[229] = 32'h98EE_99CC;
    mem[230] = 32'h58FB_9EEC;
    mem[231] = 32'h9668_99BB;
    mem[232] = 32'h4678_1A9F;
    mem[233] = 32'hAAAA_1234;
    mem[234] = 32'hAAAA_5678;
    mem[235] = 32'hFFFF_9876;
    mem[236] = 32'h5EBB_04C8;
    mem[237] = 32'h5FCC_159E;
    mem[238] = 32'h62AC_48C9;
    mem[239] = 32'h6EBC_16CD;
    mem[240] = 32'h70DA_38D9;
    mem[241] = 32'hBBBB_F214;
    mem[242] = 32'hFEFE_EA87;
    mem[243] = 32'hABAB_EBAC;
    mem[244] = 32'h2395_2398;
    mem[245] = 32'h2222_2948;
    mem[246] = 32'h2323_5757;
    mem[247] = 32'h2934_2424;
    mem[248] = 32'h3293_F82a;
    mem[249] = 32'h5678_FA3A;
    mem[250] = 32'h247F_9796;
    mem[251] = 32'h2357_4545;
    mem[252] = 32'h9132_404E;
    mem[253] = 32'h9842_4967;
    mem[254] = 32'hFAE1_9896;
    mem[255] = 32'h1242_72FF;
    mem[256] = 32'h2357_4545;
    mem[257] = 32'h9132_404E;
    mem[258] = 32'h9842_4967;
    mem[259] = 32'hFAE1_9896;
    mem[260] = 32'h1242_72FF;
    mem[261] = 32'h5EBB_04C8;
    mem[262] = 32'h5FCC_159E;
    mem[263] = 32'h62AC_48C9;

end

endmodule