`timescale 1ns/1ps

module tb_ALU_decoder;

    // DUT inputs
    reg [1:0] ALU_op;
    reg       op5;
    reg [2:0] funct3;
    reg       funct7_5;

    // DUT output
    wire [2:0] ALU_CONTROL;

    // Instantiate DUT
    ALU_decoder dut (
        .ALU_op(ALU_op),
        .op5(op5),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .ALU_CONTROL(ALU_CONTROL)
    );

    // task for checking results
    task check;
        input [2:0] expected;
        input [127:0] testname;
        begin
            #1;
            if (ALU_CONTROL !== expected) begin
                $display("❌ FAIL: %s | Expected=%b Got=%b",
                          testname, expected, ALU_CONTROL);
            end else begin
                $display("✅ PASS: %s", testname);
            end
        end
    endtask

    initial begin
        $display("----- ALU Decoder Testbench -----");

        // --------------------------------
        // ALUOp = 00 → ADD (lw, sw)
        // --------------------------------
        ALU_op   = 2'b00;
        funct3  = 3'bxxx;
        op5     = 1'bx;
        funct7_5= 1'bx;
        check(3'b000, "ALUOp=00 (lw/sw)");

        // --------------------------------
        // ALUOp = 01 → SUB (beq)
        // --------------------------------
        ALU_op   = 2'b01;
        funct3  = 3'bxxx;
        op5     = 1'bx;
        funct7_5= 1'bx;
        check(3'b001, "ALUOp=01 (beq)");

        // --------------------------------
        // R-type ADD
        // --------------------------------
        ALU_op   = 2'b10;
        funct3  = 3'b000;
        op5     = 1'b0;
        funct7_5= 1'b0;
        check(3'b000, "R-type ADD");

        // --------------------------------
        // R-type SUB
        // --------------------------------
        ALU_op   = 2'b10;
        funct3  = 3'b000;
        op5     = 1'b1;
        funct7_5= 1'b1;
        check(3'b001, "R-type SUB");

        // --------------------------------
        // R-type SLT
        // --------------------------------
        ALU_op   = 2'b10;
        funct3  = 3'b010;
        op5     = 1'bx;
        funct7_5= 1'bx;
        check(3'b101, "R-type SLT");

        // --------------------------------
        // R-type OR
        // --------------------------------
        ALU_op   = 2'b10;
        funct3  = 3'b110;
        op5     = 1'bx;
        funct7_5= 1'bx;
        check(3'b011, "R-type OR");

        // --------------------------------
        // R-type AND
        // --------------------------------
        ALU_op   = 2'b10;
        funct3  = 3'b111;
        op5     = 1'bx;
        funct7_5= 1'bx;
        check(3'b010, "R-type AND");

        $display("----- TESTBENCH COMPLETE -----");
        $finish;
    end

    initial begin
        $dumpfile("alu_decoder.vcd");
        $dumpvars(0, tb_ALU_decoder);
    end

endmodule
