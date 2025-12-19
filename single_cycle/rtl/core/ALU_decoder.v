module ALU_decoder (
    input wire[1:0] ALU_op,//alu op code
    input wire op5,//6th bit of the opcode
    input wire[2:0] funct3,//function 3
    input wire funct7_5,//6th bit of function 7
    output reg[2:0] ALU_CONTROL
);
//truth table to be followed
// ALUOp | funct3 | {op5, funct7[5]} | ALUControl | Instruction
// ----------------------------------------------------------------
//  00   |   x    |        x         |    000    | lw, sw   
//  01   |   x    |        x         |    001    | beq     
//
//  10   |  000   |     00,01,10     |    000    | add
//  10   |  000   |        11        |    001    | sub
//  10   |  010   |        x         |    101    | slt
//  10   |  110   |        x         |    011    | or
//  10   |  111   |        x         |    010    | and

// decoder uses op5 and funct7 to determine add or sub
// case statment and ternary operator used as they are perfectly synthesizable

always@(*) begin
    ALU_CONTROL=3'b000;//no latches
    case(ALU_op)
        2'b00: ALU_CONTROL=3'b000;
        2'b01: ALU_CONTROL=3'b001;
        2'b10: begin
            case(funct3)
                3'b000: ALU_CONTROL=({op5,funct7_5}==2'b11) ? 3'b001:3'b000;
                3'b010: ALU_CONTROL=3'b101;
                3'b110: ALU_CONTROL=3'b011;
                3'b111: ALU_CONTROL=3'b010;
            endcase
        end
        default: ALU_CONTROL=3'b000;
    endcase
end

    
endmodule