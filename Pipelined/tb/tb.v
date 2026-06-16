`timescale 1ns/1ps

module tb_pipelined_core;

    reg clk = 0;
    reg rst = 0;

    // Instantiate your CPU
    pipelined_core dut (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu_pipeline.vcd");
        $dumpvars(0, tb_pipelined_core);
        // Dump the internal signals of the CPU too
        $dumpvars(0, dut); 

        // Reset pulse (Using active-high based on your earlier code)
        rst = 1;
        #20 rst = 0;

        // Give the CPU enough time to push all 6 instructions through the 
        // 5 stages, including the 1-cycle stall. 30 cycles is plenty.
        repeat (30) @(posedge clk);

        $display("\n--- PIPELINED RISC-V CORE TEST ---");

        // 1. addi x1, x0, 5
        check(1, 5);   
        // 2. addi x2, x0, 10
        check(2, 10);  
        // 3. add x3, x1, x2 (Tests Execute Forwarding)
        check(3, 15);  
        // 4 & 5. sw / lw (Tests Data Memory write/read)
        check(4, 15);  
        // 6. add x5, x4, x4 (Tests Load-Use Stall and Forwarding)
        check(5, 30);  

        $display("\nALL PIPELINE HAZARD TESTS PASSED!");
        $finish;
    end

    // Self-checking task
    task check(input int regnum, input int expected);
        // Updated path: dut -> regfile -> rf
        if (dut.regfile.x[regnum] !== expected) begin 
            $display("FAIL: x%0d = %0d (expected %0d)",
                     regnum, dut.regfile.x[regnum], expected);
            $fatal; // Stop simulation on first failure
        end else begin
            $display("PASS: x%0d = %0d", regnum, expected);
        end
    endtask

endmodule