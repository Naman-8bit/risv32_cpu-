`timescale 1ns/1ps

module ALU_tb;

    reg  [31:0] A, B;
    reg  [2:0]  ALU_ctrl;
    wire [31:0] Result;
    wire        Zero;

    // DUT instantiation
    ALU dut (
        .A(A),
        .B(B),
        .ALU_ctrl(ALU_ctrl),
        .Result(Result),
        .Zero(Zero)
    );

    // Self-checking task
    task check;
        input [31:0] exp_result;
        input        exp_zero;
        begin
            #1; // allow combinational settle
            if (Result !== exp_result || Zero !== exp_zero) begin
                $display("❌ FAIL | ctrl=%b A=%0d B=%0d | Result=%0d Zero=%b | Expected=%0d Zero=%b",
                          ALU_ctrl, A, B, Result, Zero, exp_result, exp_zero);
            end else begin
                $display("✅ PASS | ctrl=%b A=%0d B=%0d | Result=%0d Zero=%b",
                          ALU_ctrl, A, B, Result, Zero);
            end
        end
    endtask

    initial begin
        $display("---- ALU TEST START ----");

        // ADD
        A = 10; B = 20; ALU_ctrl = 3'b000;
        check(32'd30, 1'b0);

        // SUB
        A = 25; B = 5; ALU_ctrl = 3'b001;
        check(32'd20, 1'b0);

        // SUB → zero
        A = 15; B = 15; ALU_ctrl = 3'b001;
        check(32'd0, 1'b1);

        // AND
        A = 32'hF0F0; B = 32'h0FF0; ALU_ctrl = 3'b010;
        check(32'h00F0, 1'b0);

        // OR
        A = 32'hF0F0; B = 32'h0FF0; ALU_ctrl = 3'b011;
        check(32'hFFF0, 1'b0);

        // SLT → true
        A = 5; B = 10; ALU_ctrl = 3'b101;
        check(32'd1, 1'b0);

        // SLT → false
        A = 20; B = 10; ALU_ctrl = 3'b101;
        check(32'd0, 1'b1);

        // Edge case
        A = 0; B = 0; ALU_ctrl = 3'b000;
        check(32'd0, 1'b1);

        $display("---- ALU TEST END ----");
        $finish;
    end

    // Optional waveform dump
    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, ALU_tb);
    end

endmodule

