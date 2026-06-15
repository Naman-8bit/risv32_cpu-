// pipeline reg just after the fetch stage
module FD_reg (
    input clk,
    input rst,//dunno if needed just added here just in case
    
    input[31:0] InstrF,
    input[31:0] PCF,
    input[31:0] PCPlus4F,

    output reg[31:0] InstrD,
    output reg[31:0] PCD,
    output reg[31:0] PCPlus4D
);
    always@(posedge clk)begin
        if(rst) begin
            InstrD<=32'd0;
            PCD<=32'd0;
            PCPlus4D<=32'd0;
        end
        else begin
            InstrD<=InstrF;
            PCD<=PCF;
            PCPlus4D<=PCPlus4F;
        end
    end
 
endmodule

module DE_reg (
    input clk,
    input rst,

    input [1:0]  ResultSrcD,
    input ALUSrcD,
    input [1:0]  ALU_op,
    input [2:0]  ALU_ControlD,
    input RegWriteD,
    input MemWriteD,
    input JumpD,
    input BranchD,
    input [31:0] PCD,
    input [31:0] PCPlus4D,
    input [4:0]  RdD,
    input [31:0] ImmExtD,
    input [31:0] RD1D,
    input [31:0] RD2D,


    output reg [1:0]  ResultSrcE,
    output reg ALUSrcE,
    output reg [1:0]  ALU_opE,
    output reg [2:0]  ALU_ControlE,
    output reg RegWriteE,
    output reg MemWriteE,
    output reg JumpE,
    output reg BranchE,
    output reg [31:0] PCE,
    output reg [31:0] PCPlus4E,
    output reg [4:0]  RdE,
    output reg [31:0] ImmExtE,
    output reg [31:0] RD1E,
    output reg [31:0] RD2E
);
    always @(posedge clk) begin
        if (rst) begin
            // Clear all registers on reset
            ResultSrcE <= 2'b00;
            ALUSrcE <= 1'b0;
            ALU_opE <= 2'b00;
            ALU_ControlE <= 3'b000;
            RegWriteE <= 1'b0;
            MemWriteE <= 1'b0;
            JumpE <= 1'b0;
            BranchE <= 1'b0;

            PCE <= 32'b0;
            PCPlus4E <= 32'b0;
            RdE <= 5'b0;
            ImmExtE <= 32'b0;
            RD1E <= 32'b0;
            RD2E <= 32'b0;
        end else begin
            // Pass Decode signals to Execute stage
            ResultSrcE <= ResultSrcD;
            ALUSrcE <= ALUSrcD;
            ALU_opE <= ALU_op;
            ALU_ControlE <= ALU_ControlD;
            RegWriteE <= RegWriteD;
            MemWriteE <= MemWriteD;
            JumpE <= JumpD;
            BranchE <= BranchD;

            PCE <= PCD;
            PCPlus4E <= PCPlus4D;
            RdE <= RdD;
            ImmExtE <= ImmExtD;
            RD1E <= RD1D;
            RD2E <= RD2D;
        end
    end

endmodule

module EM_reg (
    input clk,
    input rst,

    
    // Control Signals
    input        RegWriteE,
    input [1:0]  ResultSrcE,
    input        MemWriteE,
    
    // Datapath Signals
    input [31:0] ALUResultE,
    input [31:0] WriteDataE,
    input [4:0]  RdE,
    input [31:0] PCPlus4E,

    // Control Signals
    output reg        RegWriteM,
    output reg [1:0]  ResultSrcM,
    output reg        MemWriteM,
    
    // Datapath Signals
    output reg [31:0] ALUResultM,
    output reg [31:0] WriteDataM,
    output reg [4:0]  RdM,
    output reg [31:0] PCPlus4M
);

    always @(posedge clk) begin
        if (rst) begin
            // Clear all registers on reset
            RegWriteM  <= 1'b0;
            ResultSrcM <= 2'b00;
            MemWriteM  <= 1'b0;
            
            ALUResultM <= 32'b0;
            WriteDataM <= 32'b0;
            RdM        <= 5'b0;
            PCPlus4M   <= 32'b0;
        end else begin
            // Pass Execute signals to Memory stage
            RegWriteM  <= RegWriteE;
            ResultSrcM <= ResultSrcE;
            MemWriteM  <= MemWriteE;
            
            ALUResultM <= ALUResultE;
            WriteDataM <= WriteDataE;
            RdM        <= RdE;
            PCPlus4M   <= PCPlus4E;
        end
    end

endmodule
    

module MW_reg (
    input clk,
    input rst,

    // Control Signals
    input        RegWriteM,
    input [1:0]  ResultSrcM,
    
    // Datapath Signals
    input [31:0] ALUResultM,
    input [31:0] ReadDataM,   // From Data Memory RD port
    input [4:0]  RdM,
    input [31:0] PCPlus4M,

    // Control Signals
    output reg        RegWriteW,
    output reg [1:0]  ResultSrcW,
    
    // Datapath Signals
    output reg [31:0] ALUResultW,
    output reg [31:0] ReadDataW,
    output reg [4:0]  RdW,
    output reg [31:0] PCPlus4W
);

    always @(posedge clk) begin
        if (rst) begin
            // Clear all registers on reset
            RegWriteW  <= 1'b0;
            ResultSrcW <= 2'b00;
            
            ALUResultW <= 32'b0;
            ReadDataW  <= 32'b0;
            RdW        <= 5'b0;
            PCPlus4W   <= 32'b0;
        end else begin
            // Pass Memory signals to Writeback stage
            RegWriteW  <= RegWriteM;
            ResultSrcW <= ResultSrcM;
            
            ALUResultW <= ALUResultM;
            ReadDataW  <= ReadDataM;
            RdW        <= RdM;
            PCPlus4W   <= PCPlus4M;
        end
    end

endmodule