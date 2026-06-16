module pipelined_core (
    input clk,
    input rst
);
    // code is done stage by stage for easier debugging

    // ------------------------------------------------
    // FETCH STAGE
    // ------------------------------------------------
    wire[31:0] PC_next;
    reg[31:0] PCF;
    wire[31:0] PCPlus4F;
    wire[31:0] RD;

    assign PCPlus4F=PCF+32'd4;

    // mux for pc source
    assign PC_next=(PCSrcE)?PCTargetE:PCPlus4F;

    always @(posedge clk) begin
        if (rst) begin
            PCF <= 32'd0;
        end else if (~StallF) begin 
            PCF <= PCF_next;
        end
    end

    Instruction_memory instr(
        .instr(PCF),
        .address(RD)
    );

    FD_reg reg1(
        .InstrD(InstrD),
        .InstrF(RD),

        .PCD(PCD),
        .PCF(PCF),

        .PCPlus4D(PCPlus4D),
        .PCPlus4F(PCPlus4F),

        .clk(clk),
        .rst(FlushD),
        .En(~StallD)
    );

    // ------------------------------------------------
    // DECODE STAGE
    // ------------------------------------------------
    wire[31:0] InstrD;
    wire[31:0] PCD;
    wire[31:0] PCPlus4D;

    wire[31:0] RD1D;
    wire[31:0] RD2D;

    wire RegWriteD;
    wire [1:0] ResultSrcD;
    wire MemWriteD;
    wire JumpD;
    wire BranchD;
    wire [2:0] ALU_ControlD;
    wire ALUSrcD;
    wire [1:0] ImmSrcD;

    wire[31:0] ImmExtD;

    wire [4:0] Rs1D = InstrD[19:15];
    wire [4:0] Rs2D = InstrD[24:20];
    wire [4:0] RdD  = InstrD[11:7];

    Reg_file regfile(
        .WE3(RegWriteW),

        .A1(InstrD[19:15]),
        .A2(InstrD[24:20]),
        .A3(RdW),
        .WD3(ResultW),

        .clk(clk),
        .rst(rst),

        .RD1(RD1D),
        .RD2(RD2D)
    );

    // Control Unit Instantiation Template
    Control_Unit control(
        .op(InstrD[6:0]),
        .funct3(InstrD[14:12]),
        .funct7_5(InstrD[30]),

        .RegWrite(RegWriteD),
        .ResultSrc(ResultSrcD),
        .MemWrite(MemWriteD),
        .Jump(JumpD),
        .Branch(BranchD),
        .ALU_Control(ALU_ControlD),
        .ALUSrc(ALUSrcD),
        .ImmSrc(ImmSrcD)
    );

    extend ex(
        .instr(InstrD[31:7]),
        .imm_src(ImmSrcD),
        .imm_ext(ImmExtD)
    );

    DE_reg u_DE_reg (
        .clk(clk),
        .rst(FlushE),
        .ResultSrcD(ResultSrcD),
        .ALUSrcD(ALUSrcD),
        .ALU_ControlD(ALU_ControlD),
        .RegWriteD(RegWriteD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .RD1D(RD1D),
        .RD2D(RD2D),
        .PCD(PCD),
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .RdD(RdD),
        .ImmExtD(ImmExtD),
        .PCPlus4D(PCPlus4D),
        .ResultSrcE(ResultSrcE),
        .ALUSrcE(ALUSrcE),
        .ALU_ControlE(ALU_ControlE),
        .RegWriteE(RegWriteE),
        .MemWriteE(MemWriteE),
        .JumpE(JumpE),
        .BranchE(BranchE),
        .RD1E(RD1E),
        .RD2E(RD2E),
        .PCE(PCE),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdE(RdE),
        .ImmExtE(ImmExtE),
        .PCPlus4E(PCPlus4E)
    );
    // ------------------------------------------------
    // EXECUTE STAGE
    // ------------------------------------------------
    wire PCSrcE;
    wire[31:0] PCTargetE;

    wire [1:0] ResultSrcE;
    wire ALUSrcE;
    wire [2:0] ALU_ControlE;
    wire RegWriteE;
    wire MemWriteE;
    wire JumpE;
    wire BranchE;
    wire [31:0] RD1E;
    wire [31:0] RD2E;
    wire [31:0] PCE;
    wire [4:0] Rs1E;
    wire [4:0] Rs2E;
    wire [4:0] RdE;
    wire [31:0] ImmExtE;
    wire [31:0] PCPlus4E;


    // ------------------------------------------------
    // MEMORY STAGE
    // ------------------------------------------------




    // ------------------------------------------------
    // WRITEBACK STAGE
    // ------------------------------------------------
    wire[31:0] ResultW;
    reg[4:0] RdW;
    wire RegWriteW;

    // ------------------------------------------------
    // Hazard unit
    // ------------------------------------------------
    wire StallF;
    wire StallD;
    wire FlushD;
    wire FlushE;


endmodule