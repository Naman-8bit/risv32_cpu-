module single_cycle(
    input clk,
    input rst
);

    //1.wires needed
    wire[31:0] pc;
    wire[31:0] pc_next;

    wire[31:0] instr;

    wire[4:0] rs1;
    wire[11:0] imm;
    wire [4:0] rd;
    wire [4:0] rs2;
    wire [31:0] RD2;

    wire[31:0] SrcA;//for ALU input
    wire[31:0] SrcB;//for ALU input
    wire[31:0] ALU_result;
    wire[2:0] ALU_ctrl;
    // danger temp and remove it later
    assign ALU_ctrl = 3'b000;

    wire[31:0] Read_data;
    wire Reg_write;
    // danger: temp
    assign Reg_write=1'b1;

    wire[31:0] PCPlus4;
    assign PCPlus4 = pc + 32'd4;

    //2.instantiate blocks and connections
    program_counter pc1(
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .pc_next(PCPlus4) // warning : temporary has to be replaced by mux selecting bw pc target and pc plus 4
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
        .WD3(Read_data), 
        .A1(rs1),
        .A2(rs2),
        .A3(rd),
        .RD1(SrcA),
        .RD2(RD2)
    );

    extend ext(
        .instr(instr),
        .imm_ext(SrcB)
    );


    ALU alu(
        .A(SrcA),
        .B(SrcB),
        .ALU_ctrl(ALU_ctrl),
        .Zero(),
        .Carry(),
        .Negative(),
        .oVerflow(),
        .Result(ALU_result)
    );

    data_Memory data_mem(
        .CLK(clk),
        .WE(1'b0),
        .A(ALU_result),
        .WD(32'd0),
        .RD3(Read_data)
    );

endmodule