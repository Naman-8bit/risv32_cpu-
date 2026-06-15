module Hazard_unit(
    //Decode stage inputs
    input wire[4:0] Rs1D,
    input wire[4:0] Rs2D,

    //Execute stage inputs
    input wire[4:0] Rs1E,
    input wire[4:0] Rs2E,
    input wire[4:0] RdE,
    input wire PCSrcE,
    input wire[1:0] ResultSrcE,

    //Memory stage inputs
    input wire RegWriteM,
    input wire[4:0] RdM,

    //Writeback stage inputs
    input wire RegWriteW,
    input wire[4:0] RdW,

    output wire FlushD,
    output wire FlushE,
    output wire StallD,
    output wire StallF,

    output reg[1:0] ForwardAE,
    output reg[1:0] ForwardBE
);
    // intermediate wire
    wire lwStall;// Tells if the stall is due to the load word instr
    assign lwStall=(ResultSrcE[0] & ((Rs1D == RdE) | (Rs2D == RdE)));

    // flush when branch is taken or a load introduces a bubble
    assign FlushD = PCSrcE;
    assign FlushE = lwStall | PCSrcE;
    
    // stall when a load hazard has occured
    assign StallD=lwStall;
    assign StallF=lwStall;

    always@(*) begin
        if(((Rs1E == RdM) & RegWriteM) & (Rs1E != 0)) begin
            ForwardAE = 2'b10;
        end else if (((Rs1E == RdW) & RegWriteW) & (Rs1E != 0)) begin
            ForwardAE = 2'b01;
        end 
        else begin
            ForwardAE = 2'b00;
        end
    end

    always@(*) begin
        if(((Rs2E == RdM) & RegWriteM) & (Rs2E != 0)) begin
            ForwardBE = 2'b10;
        end else if (((Rs2E == RdW) & RegWriteW) & (Rs2E != 0)) begin
            ForwardBE = 2'b01;
        end 
        else begin
            ForwardBE = 2'b00;
        end
    end

endmodule