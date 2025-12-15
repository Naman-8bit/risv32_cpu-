`timescale 1ns/1ps

module ALU_tb;

    reg  [31:0] A, B;
    reg  [2:0]  ALU_ctrl;

    wire [31:0] Result;
    wire        Zero;
    wire        Negative;
    wire        Carry;
    wire        oVerflow;

    // DUT
    ALU dut (
        .A(A),
        .B(B),
        .ALU_ctrl(ALU_ctrl),
        .Result(Result),
        .Zero(Zero),
        .Negative(Negative),
        .Carry(Carry),
        .oVerflow(oVerflow)
    );

    // Check task
    task check;
        input [31:0] exp_result;
        input        exp_zero;
        input        exp_neg;
        input        exp_carry;
        input        exp_ovf;
        begin
            #1;
            if (Result !== exp_result ||
                Zero   !== exp_zero   ||
                Negative !== exp_neg  ||
                Carry  !== exp_carry  ||
                oVerflow !== exp_ovf) begin

                $display("❌ FAIL | ctrl=%b A=%h B=%h | R=%h Z=%b N=%b C=%b V=%b | EXP R=%h Z=%b N=%b C=%b V=%b",
                         ALU_ctrl, A, B,
                         Result, Zero, Negative, Carry, oVerflow,
                         exp_result, exp_zero, exp_neg, exp_carry, exp_ovf);
            end else begin
                $display("✅ PASS | ctrl=%b A=%h B=%h | R=%h Z=%b N=%b C=%b V=%b",
                         ALU_ctrl, A, B,
                         Result, Zero, Negative, Carry, oVerflow);
            end
        end
    endtask

    initial begin
        $display("---- ALU FLAG TEST START ----");
        $monitor("sum=%h cout=%b", dut.sum, dut.cout);
        // ADD (no overflow)
        A = 32'd10; B = 32'd20; ALU_ctrl = 3'b000;
        check(32'd30, 0, 0, 0, 0);

        // ADD (carry)
        A = 32'hFFFF_FFFF; B = 32'd1; ALU_ctrl = 3'b000;
        check(32'd0, 1, 0, 1, 0);

        // ADD (signed overflow)
        A = 32'h7FFF_FFFF; B = 32'd1; ALU_ctrl = 3'b000;
        check(32'h8000_0000, 0, 1, 0, 1);

        // SUB (no borrow)
        A = 32'd20; B = 32'd5; ALU_ctrl = 3'b001;
        check(32'd15, 0, 0, 0, 0);

        // SUB (borrow)
        A = 32'd5; B = 32'd20; ALU_ctrl = 3'b001;
        check(32'hFFFF_FFF1, 0, 1, 1, 0);

        // SUB (signed overflow)
        A = 32'h8000_0000; B = 32'd1; ALU_ctrl = 3'b001;
        check(32'h7FFF_FFFF, 0, 0, 0, 1);

        // AND
        A = 32'hF0F0; B = 32'h0FF0; ALU_ctrl = 3'b010;
        check(32'h00F0, 0, 0, 0, 0);

        // OR
        A = 32'hF0F0; B = 32'h0FF0; ALU_ctrl = 3'b011;
        check(32'hFFF0, 0, 0, 0, 0);

        // SLT (true)
        A = 32'd5; B = 32'd10; ALU_ctrl = 3'b101;
        check(32'd1, 0, 0, 1, 0);

        // SLT (false)
        A = 32'd10; B = 32'd5; ALU_ctrl = 3'b101;
        check(32'd0, 1, 0, 0, 0);

        $display("---- ALU FLAG TEST END ----");
        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, ALU_tb);
    end

endmodule


