`timescale 1ns/1ps

module tb;

    reg clk = 0;
    reg rst = 0;

    // Instantiate DUT
    single_cycle dut(.clk(clk), .rst(rst));

    // 10 ns clock
    always #5 clk = ~clk;

    initial begin
        $display("\nTime   PC        x1   x2   x3   x4");
        $display("-----------------------------------");

        // Apply reset
        rst = 0;
        #20;
        rst = 1;

        // Run for a few cycles
        repeat (10) begin
            @(posedge clk);
            $display("%4t   %08h   %0d   %0d   %0d   %0d",
                     $time,
                     dut.pc,
                     dut.reg_f.x[1],
                     dut.reg_f.x[2],
                     dut.reg_f.x[3],
                     dut.reg_f.x[4]);
        end

        $finish;
    end

endmodule


