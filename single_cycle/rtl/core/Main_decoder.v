module Main_decoder (
    input wire Zero,
    input wire[6:0] op,  
    output wire PCSrc,
    output reg ResultSrc,
    output reg ALUSrc,
    output reg[1:0] ImmSrc,
    output reg[1:0] ALU_op,
    output reg RegWrite,
    output reg MemWrite
);
    reg Branch;//intermediate wire for the output PCSrc
    // Instruction |  Op      | RegWrite | ImmSrc | ALUSrc | MemWrite | ResultSrc | Branch | ALUOp
    // --------------------------------------------------------------------------------------------
    // lw          | 0000011  |    1     |   00   |   1    |    0     |     1     |   0    |  00
    // sw          | 0100011  |    0     |   01   |   1    |    1     |     x     |   0    |  00
    // R-type      | 0110011  |    1     |   xx   |   0    |    0     |     0     |   0    |  10
    // beq         | 1100011  |    0     |   10   |   0    |    0     |     x     |   1    |  01

    //using assign here as it it better than case for realising the hardware and the clear truth table here gives easy implementation for it
    assign PCSrc= (Branch & Zero); //And gate

    // assign ResultSrc= ~(op[6]|op[5]); //Nor gate
    // not using assign statement like this as it may be issue later while pipelining or ISA extension cause it may break later so its much better to do it by instruction identity
    //synthesizers automatically optimize the hardware so better to let synth do it

    // instuctions implemented below (easy to extend later if needed)

    // A good practice while designing controllers is to decode it by instructions not by bit logic or conincidence
    // use one decode block per instruction 
    //avoid latches by assigning defaults
    //local param is good to make stuff more readable (this is used in FSM's)

    localparam [6:0]
    OP_LW   = 7'b0000011,
    OP_SW   = 7'b0100011,
    OP_R    = 7'b0110011,
    OP_I    = 7'b0010011,
    OP_BEQ  = 7'b1100011;
    

    wire isLW  = (op == OP_LW);
    wire isSW  = (op == OP_SW);
    wire isR   = (op == OP_R);
    wire isBEQ = (op == OP_BEQ);
    wire isI = (op == OP_I);

    always @(*) begin
        // to avoid latches
        RegWrite  = 0;
        MemWrite  = 0;
        ResultSrc = 0;
        Branch=0;
        ALUSrc    = 0;
        ALU_op     = 2'b00;
        ImmSrc    = 2'b00;

        if (isLW) begin
            RegWrite  = 1;
            ALUSrc    = 1;
            ResultSrc = 1;
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
    end
    
endmodule