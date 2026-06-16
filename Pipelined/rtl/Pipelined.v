module pipelined_core (
    input clk,
    input rst
);
    // code is done stage by stage for easier debugging

    // ------------------------------------------------
    // FETCH STAGE
    // ------------------------------------------------
    wire[31:0] PCF_next;
    reg[31:0] PCF;
    wire[31:0] PCPlus4F;
    wire[31:0] RD;

    assign PCPlus4F=PCF+32'd4;

    // mux for pc source
    assign PCF_next=(PCSrcE)?PCTargetE:PCPlus4F;

    always @(posedge clk) begin
        if (rst) begin
            PCF <= 32'd0;
        end else if (~StallF) begin 
            PCF <= PCF_next;
        end
    end

    Instruction_memory instr(
        .instr(RD),
        .address(PCF)
    );

    FD_reg reg1(
        .InstrD(InstrD),
        .InstrF(RD),

        .PCD(PCD),
        .PCF(PCF),

        .PCPlus4D(PCPlus4D),
        .PCPlus4F(PCPlus4F),

        .clk(clk),
        .rst(FlushD | rst),
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
        .instr(InstrD),
        .imm_src(ImmSrcD),
        .imm_ext(ImmExtD)
    );

    DE_reg u_DE_reg (
        .clk(clk),
        .rst(FlushE | rst),
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
    assign PCSrcE = (JumpE | (BranchE & ZeroE));
    wire[31:0] PCTargetE;
    assign PCTargetE=PCE+ImmExtE;

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

    wire[31:0] ALUResultE;
    wire[31:0] WriteDataE;

    wire[31:0] SrcAE;
    wire[31:0] SrcBE;

    wire ZeroE;

    assign SrcAE=(ForwardAE[1])?ALUResultM:((ForwardAE[0])?ResultW:RD1E);

    assign WriteDataE=(ForwardBE[1])? ALUResultM : ((ForwardBE[0])? ResultW : RD2E);
    assign SrcBE=(ALUSrcE)? ImmExtE : WriteDataE ;
    
    ALU alu (
        .A(SrcAE),
        .B(SrcBE),
        .ALU_ctrl(ALU_ControlE),
        .Result(ALUResultE),
        .Zero(ZeroE),
        .Negative(),
        .Carry(),
        .oVerflow()
    );


    EM_reg u_EM_reg (
        .clk(clk),
        .rst(rst),//not sure if this rst is ever used
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .ALUResultE(ALUResultE),
        .WriteDataE(WriteDataE),
        .RdE(RdE),
        .PCPlus4E(PCPlus4E),
        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),
        .MemWriteM(MemWriteM),
        .ALUResultM(ALUResultM),
        .WriteDataM(WriteDataM),
        .RdM(RdM),
        .PCPlus4M(PCPlus4M)
    );

    // ------------------------------------------------
    // MEMORY STAGE
    // ------------------------------------------------
    wire RegWriteM;
    wire[1:0] ResultSrcM;
    wire MemWriteM;
    wire[31:0] ALUResultM;
    wire [31:0] WriteDataM; 
    wire [4:0] RdM;
    wire[31:0] PCPlus4M;

    wire[31:0] ReadDataM;

    data_Memory data_mem (
        .CLK(clk),
        .WE(MemWriteM),
        .A(ALUResultM),
        .WD(WriteDataM),
        .RD3(ReadDataM)
    );

    MW_reg u_MW_reg (
        .clk(clk),
        .rst(rst),
        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),
        .ALUResultM(ALUResultM),
        .ReadDataM(ReadDataM),
        .RdM(RdM),
        .PCPlus4M(PCPlus4M),
        .RegWriteW(RegWriteW),
        .ResultSrcW(ResultSrcW),
        .ALUResultW(ALUResultW),
        .ReadDataW(ReadDataW),
        .RdW(RdW),
        .PCPlus4W(PCPlus4W)
    );

    // ------------------------------------------------
    // WRITEBACK STAGE
    // ------------------------------------------------
    wire[31:0] ResultW;
    wire[4:0] RdW;
    wire RegWriteW;//goes to the decode stage
    wire[1:0] ResultSrcW;
    wire[31:0] PCPlus4W;
    wire[31:0] ReadDataW;
    wire[31:0] ALUResultW;

    assign ResultW=(ResultSrcW[1])? PCPlus4W : ((ResultSrcW[0])? ReadDataW: ALUResultW);

    // ------------------------------------------------
    // Hazard unit
    // ------------------------------------------------
    wire StallF;
    wire StallD;
    wire FlushD;
    wire FlushE;
    wire[1:0] ForwardAE;
    wire[1:0] ForwardBE;

    Hazard_unit u_Hazard_unit (
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdE(RdE),
        .PCSrcE(PCSrcE),
        .ResultSrcE(ResultSrcE),
        .RegWriteM(RegWriteM),
        .RdM(RdM),
        .RegWriteW(RegWriteW),
        .RdW(RdW),
        .FlushD(FlushD),
        .FlushE(FlushE),
        .StallD(StallD),
        .StallF(StallF),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE)
    );

endmodule