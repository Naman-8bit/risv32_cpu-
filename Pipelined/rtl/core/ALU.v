module ALU (
    input wire[31:0] A,B, //inputs for the ALU
    input wire[2:0] ALU_ctrl, //control logic for the ALU
    output reg[31:0] Result, //output from the ALU
    output reg Zero, //the zero flag
    output reg Negative,//negative number
    output reg Carry,//carry flag
    output reg oVerflow//overflow flag
);
    
    // instructions implemented
    /*

    ALU_CONTROL    Function
    000            ADD
    001            SUBTRACT
    010            AND
    011            OR
    101            SLT (set if less than operations)

    */

    // wire [31:0] add= A+B;

    // wire [31:0] sub = A - B;

    // changing subtract logic for flags

    wire cout;
    wire [31:0] sum;

    assign {cout,sum} = (ALU_ctrl[0] == 1'b0) ? A + B : (A + ((~B)+1)) ; // adder subtractor

    wire [31:0] and_ = A & B;
    wire [31:0] or_  = A | B;
    wire [31:0] slt = (A < B) ? 32'd1 : 32'd0;

    always@(*) begin
        Result=32'd0;
        case(ALU_ctrl)
            3'b000: Result=sum; //add
            3'b001: Result=sum; //subtract
            3'b010: Result=and_;
            3'b011: Result=or_;
            3'b101: Result=slt;
        endcase
        //flags
        Zero=(Result==32'd0)? 1:0;
        Negative= Result[31]; //negative
        Carry= (cout&~(ALU_ctrl[1])); // cout
        oVerflow= (~ALU_ctrl[1]) & (A[31]^sum[31]) & (~(A[31]^B[31]^ALU_ctrl[0]));
    end

endmodule