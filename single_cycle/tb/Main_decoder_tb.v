`timescale 1ns/1ps

module tb_Main_decoder;

    reg  [6:0] op;
    reg        Zero;

    wire       PCSrc;
    wire       ResultSrc;
    wire       ALUSrc;
    wire [1:0] ImmSrc;
    wire [1:0] ALU_op;
    wire       RegWrite;
    wire       MemWrite;

    // Instantiate DUT
    Main_decoder dut (
        .Zero(Zero),
        .op(op),
        .PCSrc(PCSrc),
        .ResultSrc(ResultSrc),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .ALU_op(ALU_op),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite)
    );

    // Task for checking outputs
    task check;
        input exp_RegWrite;
        input exp_MemWrite;
        input exp_ResultSrc;
        input exp_ALUSrc;
        input [1:0] exp_ImmSrc;
        input [1:0] exp_ALUOp;
        input exp_PCSrc;
        begin
            #1;
            if (RegWrite  !== exp_RegWrite  ||
                MemWrite  !== exp_MemWrite  ||
                ResultSrc !== exp_ResultSrc ||
                ALUSrc    !== exp_ALUSrc    ||
                ImmSrc    !== exp_ImmSrc    ||
                ALU_op    !== exp_ALUOp     ||
                PCSrc     !== exp_PCSrc)
            begin
                $display("❌ FAIL @ time %0t", $time);
                $display("op=%b Zero=%b", op, Zero);
                $display("Got: RegWrite=%b MemWrite=%b ResultSrc=%b ALUSrc=%b ImmSrc=%b ALUOp=%b PCSrc=%b",
                         RegWrite, MemWrite, ResultSrc, ALUSrc, ImmSrc, ALU_op, PCSrc);
                $stop;
            end
            else begin
                $display("✅ PASS @ time %0t op=%b", $time, op);
            end
        end
    endtask

    initial begin
        $display("Starting Main_decoder testbench");

        // LW
        op   = 7'b0000011;
        Zero = 0;
        check(1, 0, 1, 1, 2'b00, 2'b00, 0);

        // SW
        op   = 7'b0100011;
        Zero = 0;
        check(0, 1, 0, 1, 2'b01, 2'b00, 0);

        // R-type
        op   = 7'b0110011;
        Zero = 0;
        check(1, 0, 0, 0, 2'b00, 2'b10, 0);

        // BEQ (not taken)
        op   = 7'b1100011;
        Zero = 0;
        check(0, 0, 0, 0, 2'b10, 2'b01, 0);

        // BEQ (taken)
        op   = 7'b1100011;
        Zero = 1;
        check(0, 0, 0, 0, 2'b10, 2'b01, 1);

        $display("🎉 All tests PASSED");
        $finish;
    end

endmodule
