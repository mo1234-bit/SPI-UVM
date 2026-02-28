module decoder (
    input clk,
    input rst_n,               // Active-low reset
    // EAI Interface
    input ready,               // EAI (abo gamal) has valid instruction                          "decoder_valid"
    input [31:0] instruction,  // Custom instruction from EAI                                    " instr"
    output reg finish,          // Instruction processed and ready for another from gamal        "decoder_ready"



    // Config. Controller Interface
    input cfg_ready,           // Controller is ready                                            "cfg_ready"
    output reg cfg_valid,      // Decoder data is valid                                          "cfg_valid"
    output reg [6:0] funct7,                                                                     //"funct7"
    output reg [4:0] rs1,                                                                        //"rs1"
    output reg [4:0] rs2,                                                                        //"rs2"
    output reg [4:0] rd,                                                                         //"rd"
    output reg xs1,                                                                              //"xs1"
    output reg xs2,                                                                              //"xs2"
    output reg xd,
    output reg [8:0]index,
    input local_rst_decoder                                                                             //"xd"
);

parameter [1:0] IDLE = 2'b00;
parameter [1:0] DECODE = 2'b01;
parameter [1:0] DONE = 2'b10;

reg [1:0] state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || !local_rst_decoder) begin
            state <= IDLE;
            cfg_valid <= 0;
            finish <= 0;
            funct7 <= 0;
            rs1 <= 0;
            rs2 <= 0;
            rd <= 0;
            xs1 <= 0;
            xs2 <= 0;
            xd <= 0;
            index<=0;
        end else begin
            case (state)
                IDLE: begin
                    finish <= 0;
                    if (ready && cfg_ready) begin
                        finish <= 1;                   //ready to recieve instruction to the eai
                        state <= DECODE;
                    end
                end

                DECODE: begin
                    funct7 <= instruction[31:25];
                    rs2 <= instruction[24:20];
                    rs1 <= instruction[19:15];
                    xd  <= instruction[14];
                    xs1 <= instruction[13];
                    xs2 <= instruction[12];
                    rd  <= instruction[11:7];
                    cfg_valid <= 1;  // Data valid for controller, so that when the controller receive it begin to process the instruction

                    // Wait for controller to process data
                    if (!cfg_ready) begin
                        cfg_valid <= 0;  // Data accepted so that the controller stop check the case of (fun) untill the next instruction recieve
                        finish <= 1;     // Notify EAI that the instruction processed by the controller
                        state <= DONE;
                    end
                end

                DONE: begin
                    finish <= 0;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule