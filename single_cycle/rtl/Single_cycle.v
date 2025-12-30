module single_cycle(
    input clk,
    input rst
);

    //-------------------------------------------------------------------------------------------------
    // 1> WIRES NEEDED
    // 
    // ------------------------------------------------------------------------------------------------
    wire[31:0] pc;
    wire[31:0] pc_next;

    wire[31:0] instr;

    wire[4:0] rs1;
    wire[11:0] imm;
    wire [4:0] rd;
    wire [4:0] rs2;

    wire[31:0] SrcA;//for ALU input
    wire[31:0] SrcB;//for ALU input
    wire[31:0] ALU_result;
    reg[31:0] ImmExtend;

    wire[31:0] Read_data;
    
    // danger: temp
    // assign Reg_write=1'b1;

    wire[31:0] PCPlus4;
    assign PCPlus4 = pc + 32'd4;

    wire [31:0] Write_data;

    //wire for control signals from the control unit
    wire ALU_src;
    wire[2:0] ALU_ctrl;
    wire Result_src;
    wire Reg_write;
    wire[1:0] ImmSrc;
    wire MemWrite;
    wire PCSrc;
    wire[1:0] ALU_op;

    wire Zero;

    wire[6:0] op;
    assign op = instr[6:0];

    wire[2:0] funct3;
    assign funct3= instr[14:12];

    wire funct7_5;
    assign funct7_5= instr[30];

    wire[31:0] PCtarget;
    assign PCtarget= pc+ImmExtend;

    // mux for pc_next
    assign pc_next=(PCSrc)? PCtarget : PCPlus4 ;

    //-------------------------------------------------------------------------------------------------
    // 2> INSTANTIATION AND CONNECTIONS
    // 
    // ------------------------------------------------------------------------------------------------

    program_counter pc1(
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .pc_next(pc_next) // warning : temporary has to be replaced by mux selecting bw pc target and pc plus 4
    );

    Instruction_memory instr_mem(
        .instr(instr),
        .address(pc)
    );

    // instruction has to be split into different fields
    assign rs1=instr[19:15];
    assign rd=instr[11:7];
    assign rs2 = instr[24:20];

    Reg_file reg_f(
        .clk(clk),
        .rst(rst),
        .WE3(Reg_write),
        .WD3(Result), 
        .A1(rs1),
        .A2(rs2),
        .A3(rd),
        .RD1(SrcA),
        .RD2(Write_data)
    );

    extend ext(
        .instr(instr),
        .imm_src(ImmSrc),
        .imm_ext(ImmExtend)
    );

    // mux for SrcB
    assign SrcB = (ALU_src)? ImmExtend : Write_data ;
    wire[31:0] Result;
    assign Result= (Result_src)? Read_data : ALU_result ;

    ALU alu(
        .A(SrcA),
        .B(SrcB),
        .ALU_ctrl(ALU_ctrl),
        .Zero(Zero),
        .Carry(),
        .Negative(),
        .oVerflow(),
        .Result(ALU_result)
    );

    data_Memory data_mem(
        .CLK(clk),
        .WE(MemWrite),
        .A(ALU_result),
        .WD(Write_data),
        .RD3(Read_data)
    );

    // wire ALU_src;
    // wire[2:0] ALU_ctrl;
    // wire Result_src;
    // wire Reg_write;
    // wire[1:0] ImmSrc;
    // wire MemWrite;
    // wire PCSrc;

    Main_decoder Main1(
        .Zero(Zero),
        .op(op),  
        .PCSrc(PCSrc),
        .ResultSrc(Result_src),
        .ALUSrc(ALU_src),
        .ImmSrc(ImmSrc),
        .ALU_op(ALU_op),
        .RegWrite(Reg_write),
        .MemWrite(MemWrite)
    );

    ALU_decoder ALU_decoder1(
        .ALU_op(ALU_op),
        .op5(op[5]),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .ALU_CONTROL(ALU_ctrl)
    );

endmodule