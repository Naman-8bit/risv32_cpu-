module data_Memory(
    input  wire        CLK,
    input  wire        WE,
    input  wire [31:0] A,
    input  wire [31:0] WD,
    output wire [31:0] RD3
);

    reg [31:0] x [0:1023];   // 4 KB memory

    //read
    assign RD3 = x[A[11:2]];

    initial begin
        x[0] = 32'd123;
    end


    // synchronous write
    always @(posedge CLK) begin
        if (WE)
            x[A[11:2]] <= WD;//set 11:2 as we only have 0 to 1023 memory in the data mem so the above bits can be ignored
    end

endmodule
