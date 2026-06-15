// made this cause of significant changes from single cycle one
// reused both the main decoder and the alu decoder and placing them in one wrapper called control
// also no more generating the PCSrc and Zero inside the main decoder that is now done by pipe reg logic
// changed the main decoder to give Jump and Brach as outputs

module Control_Unit (
    // inputs from the IF/ID Pipeline Register (Instruction fields)
    input wire [6:0] op,
    input wire [2:0] funct3,
    input wire funct7_5, // Instruction bit [30]

    // Outputs to the ID/EX Pipeline Register
    output wire RegWrite,
    output wire [1:0] ResultSrc,
    output wire MemWrite,
    output wire Jump,
    output wire Branch,
    output wire [2:0] ALU_Control,
    output wire ALUSrc,
    output wire [1:0] ImmSrc
);

    wire [1:0] ALU_op;//wire for internal connection
    
    wire op5 = op[5];

    // Instantiate Main Decoder
    Main_decoder main_dec (
        .op(op),
        .ResultSrc(ResultSrc),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .ALU_op(ALU_op),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .Jump(Jump),
        .Branch(Branch)
    );

    // Instantiate ALU Decoder
    ALU_decoder alu_dec (
        .ALU_op(ALU_op),
        .op5(op5),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .ALU_CONTROL(ALU_Control)
    );

endmodule

module Main_decoder (
    input wire [6:0]  op,  
    output reg [1:0]  ResultSrc,
    output reg ALUSrc,
    output reg [1:0]  ImmSrc,
    output reg [1:0]  ALU_op,
    output reg RegWrite,
    output reg MemWrite,
    output reg Jump,
    output reg Branch
);

    // Opcodes mapped to localparams
    localparam [6:0]
    OP_LW   = 7'b0000011,
    OP_SW   = 7'b0100011,
    OP_R    = 7'b0110011,
    OP_I    = 7'b0010011,
    OP_BEQ  = 7'b1100011,
    OP_Jal  = 7'b1101111;

    wire isLW  = (op == OP_LW);
    wire isSW  = (op == OP_SW);
    wire isR   = (op == OP_R);
    wire isBEQ = (op == OP_BEQ);
    wire isI   = (op == OP_I);
    wire isJal = (op == OP_Jal);

    always @(*) begin
        // to avoid latches
        RegWrite  = 0;
        MemWrite  = 0;
        ResultSrc = 2'b00;
        Branch=0;
        ALUSrc    = 0;
        ALU_op     = 2'b00;
        ImmSrc    = 2'b00;
        Jump    = 1'b0;
        if (isLW) begin
            RegWrite  = 1;
            ALUSrc    = 1;
            ResultSrc = 2'b01;
            ImmSrc    = 2'b00;
        end
        else if (isSW) begin
            MemWrite = 1;
            ALUSrc   = 1;
            ImmSrc   = 2'b01;
        end
        else if (isBEQ) begin
            Branch=1'b1;
            ALU_op  = 2'b01;
            ImmSrc = 2'b10;
        end
        else if (isR) begin
            RegWrite = 1;
            ALU_op    = 2'b10;
        end
        else if (isI) begin
            RegWrite = 1;
            ALUSrc   = 1;
            ALU_op   = 2'b10;   // use funct3
            ImmSrc   = 2'b00;  // I-type immediate
        end
        else if (isJal) begin
            RegWrite = 1;
            ImmSrc   = 2'b11;
            ResultSrc = 2'b10;
            Jump = 1'b1;
        end
    end
    
endmodule

module ALU_decoder (
    input wire [1:0] ALU_op,
    input wire       op5,
    input wire [2:0] funct3,
    input wire       funct7_5,
    output reg [2:0] ALU_CONTROL
);

    always @(*) begin
        ALU_CONTROL = 3'b000; // to avoid latches
        case (ALU_op)
            2'b00: ALU_CONTROL = 3'b000;
            2'b01: ALU_CONTROL = 3'b001;
            2'b10: begin
                case (funct3)
                    3'b000: ALU_CONTROL = ({op5, funct7_5} == 2'b11) ? 3'b001 : 3'b000;
                    3'b010: ALU_CONTROL = 3'b101;
                    3'b110: ALU_CONTROL = 3'b011;
                    3'b111: ALU_CONTROL = 3'b010;
                endcase
            end
            default: ALU_CONTROL = 3'b000;
        endcase
    end
    
endmodule