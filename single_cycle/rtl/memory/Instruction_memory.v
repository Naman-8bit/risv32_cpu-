module Instruction_memory #(
    input wire [31:0] address,
    //input rst, //to reset the memory
    output wire [31:0] instr
);
    reg [31:0] memory [0:255]; //256 registers

    // read instructions from a file named program.hex that is a hex file
    initial begin
    $readmemh("program.hex", memory);
    end

    assign instr=memory[address[31:2]];//assumed that reset sets it zero while it actually sets it to 32'h00000013 but you dont really need it if you are feeding in the hex file

endmodule