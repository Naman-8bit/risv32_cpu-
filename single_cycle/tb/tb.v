`timescale 1ns/1ps

module tb;

    reg clk = 0;
    reg rst = 0;

    single_cycle dut(.clk(clk), .rst(rst));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, tb);
        $dumpvars(0, dut);

        rst = 0;
        #20 rst = 1;

        // Run enough cycles
        repeat (20) @(posedge clk);

        $display("\n--- RISC-V CORE TEST ---");

        check(1, 5);     // addi
        check(2, 10);    // addi
        check(3, 15);    // add
        check(4, 5);     // sub
        check(5, 0);     // and
        check(6, 15);    // or
        check(7, 1);     // slt
        check(8, 15);    // lw after sw
        check(9, 0);     // skipped by beq
        check(10, 123);  // branch target

        $display("\nALL RV32I TESTS PASSED 🎉");
        $finish;
    end

    task check(input int regnum, input int expected);
        if (dut.reg_f.x[regnum] !== expected) begin
            $display("FAIL: x%0d = %0d (expected %0d)",
                     regnum,
                     dut.reg_f.x[regnum],
                     expected);
            $fatal;
        end
        else begin
            $display("PASS: x%0d = %0d", regnum, expected);
        end
    endtask

endmodule





